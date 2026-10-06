-- The player's own lines: saving and repairing them, /fpe add|list|remove,
-- the {food} placeholder, and managing them in the options panel.

---The line after "feeds <pet> ... " in the last emote sent.
local function sentLine(client)
    local text = client:lastSent().text
    return text:match("^feeds Fluffy a .-|h|r%. (.*)$") or text:match("^feeds Fluffy%. (.*)$") or text
end

---Own lines at a chance of 100%, so the emote is predictable.
local function onlyOwn(client, ...)
    for _, line in ipairs({ ... }) do
        client:slash("add " .. line)
    end
    client:slash("chance 100")
end

test("a new character has no own lines", function()
    NewClient():login()
    eq(type(Saved().customLines), "table")
    eq(#Saved().customLines, 0)
end)

test("broken own-line settings are repaired; lines that are not text are dropped", function()
    NewClient({ savedDB = { customLines = "nope", customFallback = "yes" } }):login()
    eq(#Saved().customLines, 0)
    eq(Saved().customFallback, true)
    NewClient({ savedDB = { customLines = { "Keep me.", 42, "Me too." } } }):login()
    eq(#Saved().customLines, 2)
    eq(Saved().customLines[2], "Me too.")
end)

test("/fpe add saves the line as typed, trimmed, and says its number", function()
    local client = NewClient():login()
    client:slash("ADD   {pet} Wolfs It Down!  ")
    eq(Saved().customLines[1], "{pet} Wolfs It Down!")
    ok(client:printedContains("Line 1 added: {pet} Wolfs It Down!"))
end)

test("own lines join the built-in lines", function()
    local client = NewClient():login()
    local before = #client.E.EmotePool(12037, "Mystery Meat")
    client:slash("add Chomp.")
    local pool = client.E.EmotePool(12037, "Mystery Meat")
    eq(#pool, before + 1)
    contains(pool, "Chomp.")
    contains(pool, "Nice kitty!")
end)

test("at a chance of 100% the emote uses one of the own lines", function()
    local client = NewClient():login()
    onlyOwn(client, "Chomp.")
    client:feed(12037)
    eq(sentLine(client), "Chomp.")
end)

test("{pet}, {food} and pronouns are filled in own lines", function()
    local client = NewClient():login()
    onlyOwn(client, "{pet} wolfs down the {food}, as {he} does.")
    client:feed(12037)
    eq(sentLine(client), "Fluffy wolfs down the Mystery Meat, as he does.")
end)

test("a line with {food} is left out when the food is unknown", function()
    local client = NewClient():login()
    onlyOwn(client, "Mmm, {food}.")
    -- Its only own line needs the food, so the built-in lines stand in.
    local pool = client.E.EmotePool(19223, nil)
    contains(pool, "Nice kitty!")
    for _, line in ipairs(pool) do
        ok(line ~= "Mmm, {food}.", "{food} line offered without a food name")
    end
    client:slash("add Chomp.")
    client:castSucceeded()
    eq(sentLine(client), "Chomp.")
end)

test("lines that would break the emote are refused and not saved", function()
    local client = NewClient():login()
    client:slash("add")
    ok(client:printedContains("Type the line after /fpe add"))
    client:slash("add " .. string.rep("x", client.E.CUSTOM_LINE_MAX + 1))
    ok(client:printedContains("too long for an emote: at most 150 bytes"))
    client:slash("add |cffff0000red|r")
    ok(client:printedContains("cannot contain the | character"))
    eq(#Saved().customLines, 0)
    client:slash("add " .. string.rep("x", client.E.CUSTOM_LINE_MAX))
    eq(#Saved().customLines, 1, "a line of exactly the maximum fits")
end)

test("the same line twice is refused", function()
    local client = NewClient():login()
    client:slash("add Chomp.")
    client:slash("add  Chomp. ")
    eq(#Saved().customLines, 1)
    ok(client:printedContains("You already have that line."))
end)

test("/fpe list numbers the lines", function()
    local client = NewClient():login()
    client:slash("list")
    ok(client:printedContains("You have no lines of your own yet."))
    client:slash("add Chomp.")
    client:slash("add Crunch.")
    client:slash("list")
    ok(client:printedContains("Your lines (2):"))
    ok(client:printedContains("1. Chomp."))
    ok(client:printedContains("2. Crunch."))
end)

test("/fpe remove takes a line out by its number", function()
    local client = NewClient():login()
    client:slash("add Chomp.")
    client:slash("add Crunch.")
    client:slash("remove 1")
    ok(client:printedContains("Line removed: Chomp."))
    eq(#Saved().customLines, 1)
    eq(Saved().customLines[1], "Crunch.")
    client:slash("remove 5")
    ok(client:printedContains("There is no line 5"))
    client:slash("remove two")
    ok(client:printedContains("There is no line two"))
    eq(#Saved().customLines, 1)
end)

test("own lines survive a reload", function()
    local client = NewClient():login()
    client:slash("add Chomp.")
    client:slash("chance 100")
    local reloaded = NewClient({ savedDB = Saved() }):login()
    eq(Saved().customLines[1], "Chomp.")
    reloaded:castSucceeded()
    eq(sentLine(reloaded), "Chomp.")
end)

test("/fpe lists the own-line commands; selftest counts the lines", function()
    local client = NewClient():login()
    client:slash("")
    ok(client:printedContains("/fpe add [conditions] <line>"))
    client:slash("add Chomp.")
    client:slash("selftest")
    ok(client:printedContains("Own lines: 1, this character's."))
end)

-- The options panel.

---The first frame of a kind (and with a text) the addon made.
---The first frame of a kind (and text); the website box is not the editor.
local function panelPart(client, kind, text)
    for _, frame in ipairs(client.frames) do
        if frame.kind == kind and frame ~= client.E.WebsiteBox and (not text or frame:GetText() == text) then
            return frame
        end
    end
end

---The panel's scroll frame, and the frame scrolled in it that holds everything.
local function listFrames(client)
    local scroll = panelPart(client, "ScrollFrame")
    for _, frame in ipairs(client.frames) do
        if frame.parent == scroll then return scroll, frame end
    end
end

---The visible font strings in the list that show an own line ("1. ...").
local function shownRows(client)
    local _, list = listFrames(client)
    local rows = {}
    for _, region in ipairs(client.fontStrings) do
        local text = region:GetText()
        if region.parent == list and region.shown and text and text:match("^%d+%. ") then rows[#rows + 1] = text end
    end
    table.sort(rows)
    return rows
end

local function showPanel(client)
    client.optionsPanel.scripts.OnShow(client.optionsPanel)
end

local function typeLine(client, text)
    local input = panelPart(client, "EditBox")
    input:SetText(text)
    input.scripts.OnEnterPressed(input)
    return input
end

test("the panel adds a line with Enter or the Add button", function()
    local client = NewClient():login()
    showPanel(client)
    local input = typeLine(client, "Chomp.")
    eq(input:GetText(), "", "the box is emptied")
    input.scripts.OnEscapePressed(input)
    input:SetText("Crunch.")
    local add = panelPart(client, "Button", "Add")
    add.scripts.OnClick(add)
    eq(#Saved().customLines, 2)
    eq(table.concat(shownRows(client), "|"), "1. Chomp.|2. Crunch.")
end)

test("the panel shows why a line is refused, and clears it after a good one", function()
    local client = NewClient():login()
    showPanel(client)
    typeLine(client, "a | b")
    local function problemShown()
        for _, region in ipairs(client.fontStrings) do
            if region:GetText() == "A line cannot contain the | character." then return true end
        end
        return false
    end
    ok(problemShown())
    eq(#Saved().customLines, 0)
    typeLine(client, "Chomp.")
    ok(not problemShown())
end)

test("a row's X button takes out its own line and says so in its tooltip", function()
    local client = NewClient():login()
    client:slash("add Chomp.")
    client:slash("add Crunch.")
    client:slash("add Munch.")
    showPanel(client)
    eq(#shownRows(client), 3)
    local _, list = listFrames(client)
    local removes = {}
    for _, frame in ipairs(client.frames) do
        if frame.parent == list and frame.template == "UIPanelCloseButton" then removes[#removes + 1] = frame end
    end
    eq(#removes, 3)
    removes[2].scripts.OnEnter(removes[2])
    eq(GameTooltip.owner, removes[2])
    eq(GameTooltip:GetText(), "Remove")
    ok(GameTooltip:IsShown())
    removes[2].scripts.OnLeave(removes[2])
    ok(not GameTooltip:IsShown())
    removes[2].scripts.OnClick(removes[2])
    eq(table.concat(Saved().customLines, "|"), "Chomp.|Munch.")
    eq(table.concat(shownRows(client), "|"), "1. Chomp.|2. Munch.")
    ok(not removes[3].shown, "the row left over is hidden")
end)

test("the panel scrolls, and what it scrolls grows by one row per line", function()
    local client = NewClient():login()
    local scroll, content = listFrames(client)
    eq(scroll.parent, client.optionsPanel)
    eq(scroll.template, "UIPanelScrollFrameTemplate")
    local heights = {}
    function content:SetHeight(height)
        heights[#heights + 1] = height
    end
    showPanel(client)
    local base = heights[#heights]
    for i = 1, 30 do
        client:slash("add Line " .. i .. ".")
    end
    showPanel(client)
    eq(heights[#heights] - base, 30 * 24)
    eq(#shownRows(client), 30)
end)

test("the list's title says whose lines it shows and how many", function()
    local client = NewClient():login()
    client:slash("add Chomp.")
    showPanel(client)
    local function titleShown(text)
        for _, region in ipairs(client.fontStrings) do
            if region:GetText() == text then return true end
        end
        return false
    end
    ok(titleShown("Lines for this character (1)"))
    client:slash("shared on")
    showPanel(client)
    ok(titleShown("Lines shared by all characters (0)"))
end)

test("the panel says when there are no lines, and picks up /fpe add on reopen", function()
    local client = NewClient():login()
    showPanel(client)
    local function emptyShown()
        for _, region in ipairs(client.fontStrings) do
            if region:GetText() == client.E.L.OPTION_CUSTOM_NONE then return region.shown end
        end
    end
    eq(emptyShown(), true)
    client:slash("add Chomp.")
    showPanel(client)
    eq(emptyShown(), false)
    eq(#shownRows(client), 1)
    client:slash("remove 1")
    showPanel(client)
    eq(emptyShown(), true)
    eq(#shownRows(client), 0)
end)

test("the panel lists the locale's own placeholders", function()
    eq(NewClient():login().E.PlaceholderList(), "{pet}, {food}, {he}")
    local german = NewClient({ locale = "deDE" }):login().E.PlaceholderList()
    ok(german:find("{er}", 1, true), german)
    ok(not german:find("{he}", 1, true), german)
end)
