local _, E = ...

-- The options panel in the game's settings (Esc > Options > AddOns, or
-- /fpe config): checkboxes for the same settings as /fpe on|off, /fpe name and
-- /fpe debug. The boxes are filled from E.db every time the panel is shown, so
-- a change made with /fpe in the meantime shows up; a click writes straight to
-- E.db. Registered through the Settings API, which every targeted flavor
-- (Forever, Classic Era, Classic) has.

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
    box:SetPoint("TOPLEFT", below, "BOTTOMLEFT", below == title and -2 or 0, -16)
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

addCheckbox("enabled", L.OPTION_ENABLED, L.OPTION_ENABLED_NOTE)
addCheckbox("petName", L.OPTION_PET_NAME, L.OPTION_PET_NAME_NOTE)
addCheckbox("debug", L.OPTION_DEBUG, L.OPTION_DEBUG_NOTE)

panel:SetScript("OnShow", function()
    for key, box in pairs(checkboxes) do
        box:SetChecked(E.db[key])
    end
end)

local category = Settings.RegisterCanvasLayoutCategory(panel, L.OPTIONS_TITLE)
Settings.RegisterAddOnCategory(category)

function E.OpenOptions()
    Settings.OpenToCategory(category:GetID())
end
