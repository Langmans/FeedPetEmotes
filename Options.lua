local _, E = ...

-- The options panel in the game's settings (Esc > Options > AddOns, or
-- /fpe config): checkboxes for the same settings as /fpe on|off, /fpe name and
-- /fpe debug, then the player's own lines with a box to add one, a Remove
-- button per line and the /fpe only checkbox. Everything is filled from E.db
-- every time the panel is shown, so a change made with /fpe in the meantime
-- shows up; a click writes straight to E.db. Registered through the Settings
-- API, which every targeted flavor (Forever, Classic Era, Classic) has.

local L = E.L

local panel = CreateFrame("Frame")
E.OptionsPanel = panel

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText(L.OPTIONS_TITLE)

---Setting key -> its checkbox.
---@type table<string, table>
local checkboxes = {}
local below = title

---A checkbox for one boolean setting, with a line of explanation under it.
---@param key string the E.db field
---@param label string
---@param description string
local function addCheckbox(key, label, description)
    local box = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    -- The box has a few pixels of padding; under a heading it moves left to line up.
    box:SetPoint("TOPLEFT", below, "BOTTOMLEFT", below.isHeading and -2 or 0, -16)
    -- The label's parentKey is Text on newer clients, text on older ones.
    local text = box.Text or box.text
    text:SetFontObject("GameFontHighlight")
    text:SetText(label)
    local note = panel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    note:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 0, -2)
    note:SetText(description)
    box:SetScript("OnClick", function(self)
        -- GetChecked returns 1/nil on some clients; the saved value must be a boolean.
        E.db[key] = self:GetChecked() and true or false
    end)
    checkboxes[key] = box
    below = box
end

title.isHeading = true
addCheckbox("enabled", L.OPTION_ENABLED, L.OPTION_ENABLED_NOTE)
addCheckbox("petName", L.OPTION_PET_NAME, L.OPTION_PET_NAME_NOTE)
addCheckbox("debug", L.OPTION_DEBUG, L.OPTION_DEBUG_NOTE)

-- Your own lines.

local customTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
customTitle:SetPoint("TOPLEFT", below, "BOTTOMLEFT", 2, -32)
customTitle:SetText(L.OPTION_CUSTOM_TITLE)
customTitle.isHeading = true
local customNote = panel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
customNote:SetPoint("TOPLEFT", customTitle, "BOTTOMLEFT", 0, -4)
customNote:SetJustifyH("LEFT")
customNote:SetWidth(560)
customNote:SetText(E.Format("OPTION_CUSTOM_NOTE", E.PlaceholderList()))
below = customNote
below.isHeading = true
addCheckbox("customOnly", L.OPTION_CUSTOM_ONLY, L.OPTION_CUSTOM_ONLY_NOTE)

local input = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
-- InputBoxTemplate draws its border outside the box; the extra x keeps it in line.
input:SetPoint("TOPLEFT", below, "BOTTOMLEFT", 8, -24)
input:SetSize(460, 20)
input:SetAutoFocus(false)
input:SetMaxBytes(E.CUSTOM_LINE_MAX + 1)

local addButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
addButton:SetPoint("LEFT", input, "RIGHT", 8, 0)
addButton:SetSize(90, 22)
addButton:SetText(L.OPTION_CUSTOM_ADD)

-- Why the last line was refused, in red under the box; empty otherwise.
local problem = panel:CreateFontString(nil, "ARTWORK", "GameFontRedSmall")
problem:SetPoint("TOPLEFT", input, "BOTTOMLEFT", -6, -4)
problem:SetText("")

local empty = panel:CreateFontString(nil, "ARTWORK", "GameFontDisable")
empty:SetPoint("TOPLEFT", problem, "BOTTOMLEFT", 0, -8)
empty:SetText(L.OPTION_CUSTOM_NONE)

---One row per line, created when first needed and reused after that.
---@type {button: table, text: table}[]
local rows = {}

local refresh

---The row at a position, made on first use.
---@param index number
local function rowAt(index)
    if rows[index] then return rows[index] end
    local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    button:SetSize(80, 20)
    button:SetText(L.OPTION_CUSTOM_REMOVE)
    if index == 1 then
        button:SetPoint("TOPLEFT", problem, "BOTTOMLEFT", 0, -8)
    else
        button:SetPoint("TOPLEFT", rows[index - 1].button, "BOTTOMLEFT", 0, -4)
    end
    button:SetScript("OnClick", function()
        E.RemoveCustomLine(index)
        refresh()
    end)
    local text = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    text:SetPoint("LEFT", button, "RIGHT", 8, 0)
    text:SetWidth(480)
    text:SetJustifyH("LEFT")
    -- One line per row: a long line is cut off with "..." rather than wrapped.
    text:SetWordWrap(false)
    rows[index] = { button = button, text = text }
    return rows[index]
end

---Shows one row per saved line and hides the rest.
function refresh()
    local lines = E.db.customLines
    for index, line in ipairs(lines) do
        local row = rowAt(index)
        row.text:SetText(index .. ". " .. line)
        row.button:Show()
        row.text:Show()
    end
    for index = #lines + 1, #rows do
        rows[index].button:Hide()
        rows[index].text:Hide()
    end
    if #lines == 0 then
        empty:Show()
    else
        empty:Hide()
    end
end

local function addLine()
    local added, result = E.AddCustomLine(input:GetText())
    if added then
        input:SetText("")
        problem:SetText("")
        refresh()
    else
        problem:SetText(result)
    end
end

addButton:SetScript("OnClick", addLine)
input:SetScript("OnEnterPressed", addLine)
input:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
end)

panel:SetScript("OnShow", function()
    for key, box in pairs(checkboxes) do
        box:SetChecked(E.db[key])
    end
    problem:SetText("")
    refresh()
end)

local category = Settings.RegisterCanvasLayoutCategory(panel, L.OPTIONS_TITLE)
Settings.RegisterAddOnCategory(category)

function E.OpenOptions()
    Settings.OpenToCategory(category:GetID())
end
