-- The options panel: registration with the game's settings, /fpe config, and
-- the checkboxes reading and writing the saved settings.

---The panel's checkboxes in the order they appear: enabled, petName, debug,
---customOnly, sharedLines.
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

test("showing the panel fills the checkboxes from the saved settings", function()
    local client = NewClient({
        savedDB = { enabled = false, petName = true, debug = true, customOnly = true, sharedLines = true },
    }):login()
    local boxes = checkboxes(client)
    eq(#boxes, 5)
    show(client)
    eq(boxes[1]:GetChecked(), nil)
    eq(boxes[2]:GetChecked(), 1)
    eq(boxes[3]:GetChecked(), 1)
    eq(boxes[4]:GetChecked(), 1)
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
    click(boxes[4], true)
    click(boxes[5], true)
    eq(Saved().enabled, false)
    eq(Saved().petName, true)
    eq(Saved().debug, true)
    eq(Saved().customOnly, true)
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
