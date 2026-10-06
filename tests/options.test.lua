-- The options panel: registration with the game's settings, /fpe config, and
-- the checkboxes reading and writing the saved settings.

---The panel's checkboxes in the order they appear: enabled, petName, debug,
---customFallback, sharedLines.
local function checkboxes(client)
    local boxes = {}
    for _, frame in ipairs(client.frames) do
        if frame.kind == "CheckButton" and frame.settingKey then boxes[#boxes + 1] = frame end
    end
    return boxes
end

local function show(client)
    client.optionsPanel.scripts.OnShow(client.optionsPanel)
end

local function click(box, checked)
    box:SetChecked(checked)
    box.scripts.OnClick(box)
end

test("the panel is registered under the addon's name with the Settings API", function()
    local client = NewClient():login()
    eq(client.optionsPanel, client.E.OptionsPanel)
    eq(client.optionsName, "Feed Pet Emotes")
    ok(client.optionsRegistered)
end)

test("/fpe config and /fpe options open the panel", function()
    local client = NewClient():login()
    client:slash("config")
    eq(client.optionsOpened, 1)
    client:slash("OPTIONS")
    eq(client.optionsOpened, 2)
end)

test("/fpe config in combat opens the panel once combat ends", function()
    local client = NewClient():login()
    client.inCombat = true
    client:slash("config")
    client:slash("config")
    eq(client.optionsOpened, 0)
    ok(client:printedContains("when combat ends"))
    client.inCombat = false
    client:fire("PLAYER_REGEN_ENABLED")
    eq(client.optionsOpened, 1)
    client:fire("PLAYER_REGEN_ENABLED")
    eq(client.optionsOpened, 1)
end)

test("showing the panel fills the checkboxes from the saved settings", function()
    local client = NewClient({
        savedDB = { enabled = false, petName = true, debug = true, customFallback = false, sharedLines = true },
    }):login()
    local boxes = checkboxes(client)
    eq(#boxes, 5)
    show(client)
    eq(boxes[1]:GetChecked(), nil)
    eq(boxes[2]:GetChecked(), 1)
    eq(boxes[3]:GetChecked(), 1)
    eq(boxes[4]:GetChecked(), nil)
    eq(boxes[5]:GetChecked(), 1)
end)

test("a change made with /fpe shows the next time the panel opens", function()
    local client = NewClient():login()
    show(client)
    eq(checkboxes(client)[1]:GetChecked(), 1)
    client:slash("off")
    show(client)
    eq(checkboxes(client)[1]:GetChecked(), nil)
end)

test("clicking a checkbox saves a boolean", function()
    local client = NewClient():login()
    local boxes = checkboxes(client)
    show(client)
    click(boxes[1], false)
    click(boxes[2], true)
    click(boxes[3], true)
    click(boxes[4], false)
    click(boxes[5], true)
    eq(Saved().enabled, false)
    eq(Saved().petName, true)
    eq(Saved().debug, true)
    eq(Saved().customFallback, false)
    eq(Saved().sharedLines, true)
end)

test("emotes switched off in the panel are not sent", function()
    local client = NewClient():login()
    show(client)
    click(checkboxes(client)[1], false)
    client:feed(12037)
    client:settle()
    eq(#client.sent, 0)
end)

---True when one of the panel's texts is exactly `text`.
local function shows(client, text)
    for _, region in ipairs(client.fontStrings) do
        if region:GetText() == text then return true end
    end
    return false
end

test("the panel shows the version, author and license from the .toc", function()
    local about = "Version " .. TOC_METADATA.Version .. " by Langmans, MIT license."
    ok(shows(NewClient():login(), about), "no about line")
    ok(shows(NewClient({ noAddOnsAPI = true }):login(), about), "no about line on an older client")
end)

test("the website box holds the .toc's website and puts it back when typed in", function()
    local client = NewClient():login()
    local box = client.E.WebsiteBox
    eq(box.kind, "EditBox")
    eq(box:GetText(), "https://www.curseforge.com/wow/addons/feedpetemotes")
    box:SetText("oops")
    box.scripts.OnTextChanged(box, true)
    eq(box:GetText(), "https://www.curseforge.com/wow/addons/feedpetemotes")
    -- The client's own SetText is not the player typing.
    box:SetText("set by code")
    box.scripts.OnTextChanged(box, false)
    eq(box:GetText(), "set by code")
    box.scripts.OnEditFocusGained(box)
    box.scripts.OnEditFocusLost(box)
    box.scripts.OnEscapePressed(box)
    box.scripts.OnEnterPressed(box)
end)
