-- Conditions on own lines: "[cat,fish] text" saved and checked, the pool
-- filtering by them, and the panel's condition checkboxes and line editor.

local function poolHas(client, itemID, text)
    for _, line in ipairs(client.E.EmotePool(itemID, itemID and "Food")) do
        if line == text then return true end
    end
    return false
end

-- Saving.

test("conditions are saved lower case, in a fixed order, without duplicates", function()
    local client = NewClient():login()
    client:slash("add [ CAT , Fish,cat ]   Nice kitty, nice fish.")
    eq(Saved().customLines[1], "[fish,cat] Nice kitty, nice fish.")
    ok(client:printedContains("Line 1 added: [fish,cat] Nice kitty, nice fish."))
end)

test("empty brackets mean no conditions", function()
    local client = NewClient():login()
    client:slash("add [] Chomp.")
    eq(Saved().customLines[1], "Chomp.")
end)

test("an unknown condition is refused and the known ones are listed", function()
    local client = NewClient():login()
    client:slash("add [cat,dragon] Rawr.")
    eq(#Saved().customLines, 0)
    ok(client:printedContains("Unknown condition [dragon]. Conditions: male, female, bread,"))
    ok(client:printedContains("bird_of_prey"))
end)

test("conditions do not count towards the length limit; the text alone does", function()
    local client = NewClient():login()
    local max = client.E.CUSTOM_LINE_MAX
    client:slash("add [male,fish,bird_of_prey] " .. string.rep("x", max))
    eq(#Saved().customLines, 1)
    client:slash("add [cat] " .. string.rep("y", max + 1))
    eq(#Saved().customLines, 1)
end)

test("a line with only conditions and no text is refused", function()
    local client = NewClient():login()
    client:slash("add [cat]")
    eq(#Saved().customLines, 0)
    ok(client:printedContains("Type the line after /fpe add"))
end)

test("the same text with the same conditions, typed differently, is a duplicate", function()
    local client = NewClient():login()
    client:slash("add [cat,fish] Yum.")
    client:slash("add [FISH, CAT] Yum.")
    eq(#Saved().customLines, 1)
    client:slash("add [cat] Yum.")
    eq(#Saved().customLines, 2, "other conditions make another line")
end)

test("replacing a line checks it like adding, except against itself", function()
    local client = NewClient():login()
    local E = client.E
    client:slash("add Chomp.")
    client:slash("add Crunch.")
    eq(select(1, E.ReplaceCustomLine(1, "Chomp.", { cat = true })), true)
    eq(Saved().customLines[1], "[cat] Chomp.")
    eq(select(1, E.ReplaceCustomLine(1, "[cat] Chomp.")), true, "unchanged is fine")
    local ok2, reason = E.ReplaceCustomLine(1, "Crunch.")
    eq(ok2, false)
    eq(reason, "You already have that line.")
    local ok3, missing = E.ReplaceCustomLine(9, "Munch.")
    eq(ok3, false)
    ok(missing:find("no line 9", 1, true), missing)
end)

-- Filtering.

test("a family condition offers the line only to that family", function()
    local client = NewClient():login() -- a male cat
    client:slash("add [cat] Kitty line.")
    client:slash("add [wolf] Wolf line.")
    client:slash("add [cat,wolf] Either line.")
    ok(poolHas(client, nil, "Kitty line."))
    ok(not poolHas(client, nil, "Wolf line."))
    ok(poolHas(client, nil, "Either line."), "one of a group is enough")
    client.pet.familyID = client.E.Family.WOLF
    ok(not poolHas(client, nil, "Kitty line."))
    ok(poolHas(client, nil, "Wolf line."))
end)

test("conditions in different groups must all hold", function()
    local client = NewClient():login()
    client:slash("add [cat,fish] Cat eats fish.")
    ok(not poolHas(client, 4536, "Cat eats fish."), "an apple is no fish")
    ok(not poolHas(client, nil, "Cat eats fish."), "an unknown food is no fish")
    client:stock(787, 1) -- Slitherskin Mackerel, a fish
    ok(poolHas(client, 787, "Cat eats fish."))
    client.pet.familyID = client.E.Family.BEAR
    ok(not poolHas(client, 787, "Cat eats fish."), "a bear is no cat")
end)

test("a sex condition needs that sex; unknown or secret sex matches neither", function()
    local client = NewClient():login()
    client:slash("add [male] He line.")
    client:slash("add [female] She line.")
    ok(poolHas(client, nil, "He line."))
    ok(not poolHas(client, nil, "She line."))
    client.pet.sex = 3
    ok(poolHas(client, nil, "She line."))
    client.pet.sex = 1
    ok(not poolHas(client, nil, "He line.") and not poolHas(client, nil, "She line."))
    client.pet.sex = 2
    client.secret[2] = true
    ok(not poolHas(client, nil, "He line."))
end)

test("a secret family matches no family condition", function()
    local client = NewClient():login()
    client:slash("add [cat] Kitty line.")
    client.secret[2] = true
    ok(not poolHas(client, nil, "Kitty line."))
end)

test("the emote sends the text without its conditions", function()
    local client = NewClient():login()
    client:slash("add [cat] Nice kitty, {pet}!")
    client:slash("only on")
    client:castSucceeded()
    eq(client:lastSent().text, "feeds Fluffy. Nice kitty, Fluffy!")
end)

test("only own lines falls back to the built-in lines when none of them holds", function()
    local client = NewClient():login()
    client:slash("add [wolf] Wolf line.")
    client:slash("only on")
    local pool = client.E.EmotePool(nil)
    contains(pool, "Nice kitty!")
    for _, line in ipairs(pool) do
        ok(line ~= "Wolf line.", "a wolf line offered to a cat")
    end
end)

test("a saved line with a tag this version does not know is skipped", function()
    local client = NewClient({ savedDB = { customLines = { "[dragon] Rawr.", "Chomp." } } }):login()
    ok(not poolHas(client, nil, "Rawr."))
    ok(not poolHas(client, nil, "[dragon] Rawr."))
    ok(poolHas(client, nil, "Chomp."))
end)

-- The panel.

local function showPanel(client)
    client.optionsPanel.scripts.OnShow(client.optionsPanel)
end

local function frame(client, kind, text)
    for _, f in ipairs(client.frames) do
        if f.kind == kind and (not text or f:GetText() == text) then return f end
    end
end

local function click(f)
    f.scripts.OnClick(f)
end

---Condition checkboxes by tag, and their labels in the order shown.
local function conditionBoxes(client)
    local byTag, labels = {}, {}
    for _, f in ipairs(client.frames) do
        if f.conditionTag then
            byTag[f.conditionTag] = f
            labels[#labels + 1] = f.Text:GetText()
        end
    end
    return byTag, labels
end

local function shown(client, text)
    for _, region in ipairs(client.fontStrings) do
        if region:GetText() == text and region.shown then return true end
    end
    return false
end

test("the panel offers a checkbox per condition, families by name, no exotics", function()
    local client = NewClient():login()
    local byTag, labels = conditionBoxes(client)
    eq(#labels, 2 + 6 + 17)
    eq(table.concat(labels, ",", 1, 8), "Male,Female,Bread,Meat,Fish,Cheese,Fruit,Mushrooms")
    eq(labels[9], "Bat", "families sorted by name")
    eq(labels[#labels], "Wolf")
    ok(byTag.bird_of_prey)
    ok(not byTag.chimaera and not byTag.core_hound and not byTag.devilsaur)
end)

test("the panel sorts families by their name in the client's language", function()
    local _, labels = conditionBoxes(NewClient({ locale = "deDE" }):login())
    eq(labels[9], "Aasvogel")
end)

test("ticked conditions are saved with the line, and shown in front of it", function()
    local client = NewClient():login()
    showPanel(client)
    local boxes = conditionBoxes(client)
    boxes.cat:SetChecked(true)
    boxes.fish:SetChecked(true)
    local input = frame(client, "EditBox")
    input:SetText("Nice fish, kitty.")
    click(frame(client, "Button", "Add"))
    eq(Saved().customLines[1], "[fish,cat] Nice fish, kitty.")
    ok(shown(client, "1. |cff66bbff[Fish, Cat]|r Nice fish, kitty."))
    eq(boxes.cat:GetChecked(), nil, "the editor is emptied for the next line")
    eq(input:GetText(), "")
end)

test("conditions typed in the box count too", function()
    local client = NewClient():login()
    showPanel(client)
    conditionBoxes(client).male:SetChecked(true)
    local input = frame(client, "EditBox")
    input:SetText("[wolf] Good boy.")
    input.scripts.OnEnterPressed(input)
    eq(Saved().customLines[1], "[male,wolf] Good boy.")
end)

test("an unknown condition typed in the panel shows why it is refused", function()
    local client = NewClient():login()
    showPanel(client)
    local input = frame(client, "EditBox")
    input:SetText("[dragon] Rawr.")
    input.scripts.OnEnterPressed(input)
    eq(#Saved().customLines, 0)
    local found = false
    for _, region in ipairs(client.fontStrings) do
        local text = region:GetText()
        if text and text:find("Unknown condition [dragon]", 1, true) then found = true end
    end
    ok(found)
end)

test("Edit puts a line in the editor; Save replaces it; the editor empties", function()
    local client = NewClient():login()
    client:slash("add Chomp.")
    client:slash("add [cat] Kitty.")
    showPanel(client)
    ok(shown(client, "New line"))
    local cancel = frame(client, "Button", "Cancel")
    ok(not cancel.shown)
    local edits = {}
    for _, f in ipairs(client.frames) do
        if f.kind == "Button" and f:GetText() == "Edit" then edits[#edits + 1] = f end
    end
    click(edits[2])
    local input, boxes = frame(client, "EditBox"), conditionBoxes(client)
    eq(input:GetText(), "Kitty.")
    eq(boxes.cat:GetChecked(), 1)
    ok(shown(client, "Edit line 2"))
    ok(cancel.shown)
    local save = frame(client, "Button", "Save")
    ok(save, "the Add button says Save while editing")
    input:SetText("Kitty, kitty.")
    boxes.fish:SetChecked(true)
    click(save)
    eq(table.concat(Saved().customLines, "|"), "Chomp.|[fish,cat] Kitty, kitty.")
    ok(shown(client, "New line"))
    ok(not cancel.shown)
    eq(input:GetText(), "")
end)

test("Cancel, removing a line, and switching lists all leave the editor", function()
    local client = NewClient():login()
    client:slash("add Chomp.")
    client:slash("add Crunch.")
    showPanel(client)
    local edits = {}
    for _, f in ipairs(client.frames) do
        if f.kind == "Button" and f:GetText() == "Edit" then edits[#edits + 1] = f end
    end
    local input = frame(client, "EditBox")
    click(edits[2])
    click(frame(client, "Button", "Cancel"))
    eq(input:GetText(), "")
    eq(table.concat(Saved().customLines, "|"), "Chomp.|Crunch.")

    click(edits[2])
    local removes = {}
    for _, f in ipairs(client.frames) do
        if f.template == "UIPanelCloseButton" then removes[#removes + 1] = f end
    end
    click(removes[1])
    ok(shown(client, "New line"), "the line numbers shifted")

    click(edits[1])
    local shared
    for _, f in ipairs(client.frames) do
        if f.settingKey == "sharedLines" then shared = f end
    end
    shared:SetChecked(true)
    click(shared)
    ok(shown(client, "New line"))
    eq(input:GetText(), "")
end)

test("a saved line with an unknown tag shows and edits as it was typed", function()
    local client = NewClient({ savedDB = { customLines = { "[dragon] Rawr." } } }):login()
    showPanel(client)
    ok(shown(client, "1. [dragon] Rawr."))
    click(frame(client, "Button", "Edit"))
    eq(frame(client, "EditBox"):GetText(), "[dragon] Rawr.")
end)

test("a condition the locale has no name for is shown by its tag", function()
    local client = NewClient():login()
    eq(client.E.ConditionLabel("cat"), "Cat")
    eq(client.E.ConditionLabel("chimaera"), "chimaera")
end)
