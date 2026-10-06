local addonName, E = ...

-- The options panel in the game's settings (Esc > Options > AddOns, or
-- /fpe config). From top to bottom:
--   - the version, author and license from the .toc, and the website in a
--     box to copy it from (a link in the game cannot open a browser);
--   - checkboxes for the same settings as /fpe on|off, /fpe name, /fpe debug;
--   - "Your own lines": the /fpe chance slider, the /fpe fallback and
--     /fpe shared checkboxes, an editor
--     (a text box, the conditions as checkboxes, Add or Save and Cancel), and
--     the list of lines, each with an Edit button and a red X that removes it.
-- Everything is filled from E.db every time the panel is shown, so a change
-- made with /fpe in the meantime shows up; a click writes straight to E.db.
-- The whole panel scrolls: the conditions and a long list do not fit the
-- settings window otherwise. Registered through the Settings API, which every
-- targeted flavor (Forever, Classic Era, Classic) has.

local L = E.L

local panel = CreateFrame("Frame")
E.OptionsPanel = panel

-- Everything is laid out on `content`, the scroll child. Its height is set in
-- refresh(): the fixed part (CONTENT_BASE, measured from the layout below)
-- plus one ROW_HEIGHT per line. Its width follows the scroll frame, whose
-- size the settings window decides; CONTENT_WIDTH only holds until then.
-- Notes and list rows are anchored to its right edge (toRightEdge), so they
-- wrap or end there instead of running past what the scroll frame shows.
-- UIPanelScrollFrameTemplate puts its scroll bar just outside the frame's
-- right edge, hence the room on the right.
local CONTENT_WIDTH, CONTENT_BASE, ROW_HEIGHT = 600, 880, 24
local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", 0, -4)
scroll:SetPoint("BOTTOMRIGHT", -28, 4)
local content = CreateFrame("Frame", nil, scroll)
content:SetSize(CONTENT_WIDTH, CONTENT_BASE)
scroll:SetScrollChild(content)
---@param _ ScrollFrame
---@param width number
local function fitContent(_, width)
    content:SetWidth(width)
end
scroll:SetScript("OnSizeChanged", fitContent)

-- The template's scroll bar has buttons and a thumb but no track; a dark
-- strip behind it shows where the thumb can go.
local scrollBar = scroll.ScrollBar
if scrollBar then
    local track = scrollBar:CreateTexture(nil, "BACKGROUND")
    track:SetAllPoints()
    track:SetColorTexture(0, 0, 0, 0.4)
end

---Stretches a text anchored at its top left to `inset` pixels from the
---content's right edge: a note wraps there, a list row is cut off there.
---@param fontString FontString
---@param inset number
local function toRightEdge(fontString, inset)
    fontString:SetPoint("RIGHT", content, "RIGHT", -inset, 0)
    fontString:SetJustifyH("LEFT")
end

local title = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -12)
title:SetText(L.OPTIONS_TITLE)
title.isHeading = true

-- About. C_AddOns has GetAddOnMetadata on newer clients, the global on older ones.
local GetMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
---@param key string a .toc field, e.g. "Version"
---@return string
local function metadata(key)
    return GetMetadata(addonName, key) or "?"
end
local about = content:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
about:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
about:SetText(E.Format("OPTION_ABOUT", metadata("Version"), metadata("Author"), metadata("X-License")))
local websiteLabel = content:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
websiteLabel:SetPoint("TOPLEFT", about, "BOTTOMLEFT", 0, -12)
websiteLabel:SetText(L.OPTION_WEBSITE)
websiteLabel.isHeading = true
local URL = metadata("X-Website")
local website = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
-- InputBoxTemplate draws its border outside the box; the extra x keeps it clear.
website:SetPoint("LEFT", websiteLabel, "RIGHT", 12, 0)
website:SetSize(340, 20)
website:SetAutoFocus(false)
website:SetFontObject("GameFontHighlightSmall")
website:SetText(URL)
website:SetCursorPosition(0)
-- Edit box handlers, as named functions: the language server gives an
-- EditBox's script handlers no parameter types of their own.

---@param self EditBox
local function unfocus(self)
    self:ClearFocus()
end

-- Read-only: whatever is typed is put back, and a click selects it all for Ctrl+C.
---@param self EditBox
---@param userInput boolean
local function restoreURL(self, userInput)
    if not userInput then return end
    self:SetText(URL)
    self:HighlightText()
end
---@param self EditBox
local function selectAll(self)
    self:HighlightText()
end
---@param self EditBox
local function selectNone(self)
    self:HighlightText(0, 0)
end
website:SetScript("OnTextChanged", restoreURL)
website:SetScript("OnEditFocusGained", selectAll)
website:SetScript("OnEditFocusLost", selectNone)
website:SetScript("OnEscapePressed", unfocus)
website:SetScript("OnEnterPressed", unfocus)
E.WebsiteBox = website

---A checkbox of this panel, with the fields it adds.
---@class FeedPetEmotesCheckbox: UICheckButtonTemplate
---@field text FontString? the label on older clients; Text on newer ones
---@field settingKey string? the E.db field it shows (addCheckbox)
---@field conditionTag string? the condition it ticks (addConditionGroup)

---Setting key -> its checkbox.
---@type table<string, FeedPetEmotesCheckbox>
local checkboxes = {}
local below = websiteLabel

---A checkbox for one boolean setting, with a line of explanation under it.
---@param key string the E.db field
---@param label string
---@param description string
---@param onChange fun()? called after a click has saved the setting
local function addCheckbox(key, label, description, onChange)
    ---@type FeedPetEmotesCheckbox
    local box = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    -- The box has a few pixels of padding; under a heading it moves left to line up.
    box:SetPoint("TOPLEFT", below, "BOTTOMLEFT", below.isHeading and -2 or 0, -16)
    -- The label's parentKey is Text on newer clients, text on older ones.
    local text = box.Text or box.text
    text:SetFontObject("GameFontHighlight")
    text:SetText(label)
    local note = content:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    note:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 0, -2)
    toRightEdge(note, 16)
    note:SetText(description)
    box:SetScript("OnClick", function()
        -- GetChecked returns 1/nil on some clients; the saved value must be a boolean.
        E.db[key] = box:GetChecked() and true or false
        if onChange then onChange() end
    end)
    box.settingKey = key
    checkboxes[key] = box
    below = box
end

---A heading in the panel's own gold, `gap` pixels under what came before.
---@param text string
---@param font string
---@param gap number
---@return FontString
local function addHeading(text, font, gap)
    local heading = content:CreateFontString(nil, "ARTWORK", font)
    heading:SetPoint("TOPLEFT", below, "BOTTOMLEFT", below.isHeading and 0 or 2, -gap)
    heading:SetText(text)
    heading.isHeading = true
    below = heading
    return heading
end

addCheckbox("enabled", L.OPTION_ENABLED, L.OPTION_ENABLED_NOTE)
addCheckbox("petName", L.OPTION_PET_NAME, L.OPTION_PET_NAME_NOTE)
addCheckbox("debug", L.OPTION_DEBUG, L.OPTION_DEBUG_NOTE)

-- Your own lines.

---Redraws the list; defined below, used by the checkboxes and buttons.
local refresh
---Puts a line in the editor (or empties it); defined below.
local edit

addHeading(L.OPTION_CUSTOM_TITLE, "GameFontNormalLarge", 32)
local customNote = content:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
customNote:SetPoint("TOPLEFT", below, "BOTTOMLEFT", 0, -4)
toRightEdge(customNote, 16)
customNote:SetText(E.Format("OPTION_CUSTOM_NOTE", E.PlaceholderList()))
customNote.isHeading = true
below = customNote
-- How often an own line is picked (/fpe chance): 0 ("even") lets every line
-- count the same, 5-100 is a percentage. OptionsSliderTemplate's labels have
-- parentKeys on newer clients and only global names ($parentText, ...) on
-- older ones, hence the global name.
local SLIDER_NAME = "FeedPetEmotesChanceSlider"
local slider = CreateFrame("Slider", SLIDER_NAME, content, "OptionsSliderTemplate")
slider:SetPoint("TOPLEFT", below, "BOTTOMLEFT", 6, -36)
slider:SetWidth(300)
slider:SetMinMaxValues(0, 100)
slider:SetValueStep(5)
if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end
---@type FontString
local sliderText = slider.Text or _G[SLIDER_NAME .. "Text"]
---@type FontString
local sliderLow = slider.Low or _G[SLIDER_NAME .. "Low"]
---@type FontString
local sliderHigh = slider.High or _G[SLIDER_NAME .. "High"]
sliderLow:SetText(L.OPTION_CHANCE_EVEN)
sliderHigh:SetText("100%")

---The slider's title for a value: "Chance of an own line: even" or "...: 35%".
---@param percent number
local function showChance(percent)
    sliderText:SetText(E.Format("OPTION_CHANCE", percent == 0 and L.OPTION_CHANCE_EVEN or percent .. "%"))
end

---@param _ Slider
---@param value number
local function onChanceChanged(_, value)
    local percent = math.floor(value + 0.5)
    -- Through a local: see Commands.lua on writing E.db fields.
    local db = E.db
    db.customChance = percent
    showChance(percent)
end
slider:SetScript("OnValueChanged", onChanceChanged)
local sliderNote = content:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
sliderNote:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -16)
toRightEdge(sliderNote, 16)
sliderNote:SetText(L.OPTION_CHANCE_NOTE)
sliderNote.isHeading = true
below = sliderNote
addCheckbox("customFallback", L.OPTION_FALLBACK, L.OPTION_FALLBACK_NOTE)

-- The list and the editor switch to the other set of lines.
addCheckbox("sharedLines", L.OPTION_SHARED_LINES, L.OPTION_SHARED_LINES_NOTE, function()
    edit(nil)
    refresh()
end)

-- The editor: "New line" or "Edit line 3", the text, and the conditions.

local editorTitle = addHeading(L.OPTION_NEW_LINE, "GameFontNormal", 28)

local input = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
-- InputBoxTemplate draws its border outside the box; the extra x keeps it in line.
input:SetPoint("TOPLEFT", editorTitle, "BOTTOMLEFT", 6, -8)
input:SetSize(400, 20)
input:SetAutoFocus(false)
-- Room for typed [conditions] in front of the longest line.
input:SetMaxBytes(E.CUSTOM_LINE_MAX + 100)

local saveButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
saveButton:SetPoint("LEFT", input, "RIGHT", 8, 0)
saveButton:SetSize(80, 22)
saveButton:SetText(L.OPTION_CUSTOM_ADD)

local cancelButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
cancelButton:SetPoint("LEFT", saveButton, "RIGHT", 4, 0)
cancelButton:SetSize(80, 22)
cancelButton:SetText(L.OPTION_CUSTOM_CANCEL)

-- Why the last line was refused, in red under the box; empty otherwise.
local problem = content:CreateFontString(nil, "ARTWORK", "GameFontRedSmall")
problem:SetPoint("TOPLEFT", input, "BOTTOMLEFT", -6, -4)
problem:SetText("")

-- The conditions: a row label per group ("Pet", "Food", "Family"), then a
-- grid of small checkboxes, COLUMNS to a row. Families are sorted by their
-- name in the client's language; the ones no hunter can tame on Forever
-- are left out.
local conditionsTitle = content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
conditionsTitle:SetPoint("TOPLEFT", problem, "BOTTOMLEFT", 0, -10)
conditionsTitle:SetText(L.OPTION_COND_TITLE)
local conditionsNote = content:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
conditionsNote:SetPoint("TOPLEFT", conditionsTitle, "BOTTOMLEFT", 0, -2)
toRightEdge(conditionsNote, 16)
conditionsNote:SetText(L.OPTION_COND_NOTE)

local COLUMNS, COLUMN_WIDTH, GRID_ROW, GRID_LEFT = 4, 122, 22, 70

---The condition checkboxes, in the order they appear.
---@type FeedPetEmotesCheckbox[]
local conditionBoxes = {}
local gridRows = 0

---@param group string the Condition group, also the label key's suffix
---@param conditions Condition[]
local function addConditionGroup(group, conditions)
    local top = -10 - gridRows * GRID_ROW
    local label = content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    label:SetPoint("TOPLEFT", conditionsNote, "BOTTOMLEFT", 0, top - 6)
    label:SetText(L["OPTION_COND_GROUP_" .. group:upper()])
    for i, condition in ipairs(conditions) do
        local column, row = (i - 1) % COLUMNS, math.floor((i - 1) / COLUMNS)
        ---@type FeedPetEmotesCheckbox
        local box = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
        box:SetSize(22, 22)
        box:SetPoint("TOPLEFT", conditionsNote, "BOTTOMLEFT", GRID_LEFT + column * COLUMN_WIDTH, top - row * GRID_ROW)
        local text = box.Text or box.text
        text:SetFontObject("GameFontHighlightSmall")
        text:SetText(E.ConditionLabel(condition.tag))
        box.conditionTag = condition.tag
        conditionBoxes[#conditionBoxes + 1] = box
    end
    gridRows = gridRows + math.ceil(#conditions / COLUMNS)
end

---@type table<string, Condition[]>
local conditionsByGroup = { sex = {}, foodType = {}, family = {} }
for _, condition in ipairs(E.Conditions) do
    if condition.group ~= "family" or not E.ExoticFamily[condition.value] then
        table.insert(conditionsByGroup[condition.group], condition)
    end
end
---@param a Condition
---@param b Condition
---@return boolean
local function byLabel(a, b)
    return E.ConditionLabel(a.tag) < E.ConditionLabel(b.tag)
end
table.sort(conditionsByGroup.family, byLabel)
addConditionGroup("sex", conditionsByGroup.sex)
addConditionGroup("foodType", conditionsByGroup.foodType)
addConditionGroup("family", conditionsByGroup.family)

-- Which list is shown below: this character's or the shared one, with its count.
local listTitle = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
listTitle:SetPoint("TOPLEFT", conditionsNote, "BOTTOMLEFT", 0, -20 - gridRows * GRID_ROW - 16)

local empty = content:CreateFontString(nil, "ARTWORK", "GameFontDisable")
empty:SetPoint("TOPLEFT", listTitle, "BOTTOMLEFT", 4, -8)
empty:SetText(L.OPTION_CUSTOM_NONE)

---The conditions of a saved line as the panel shows them, e.g. "Cat, Fish".
---@param tags table<string, true>
---@return string
local function conditionNames(tags)
    local names = {}
    for _, condition in ipairs(E.Conditions) do
        if tags[condition.tag] then names[#names + 1] = E.ConditionLabel(condition.tag) end
    end
    return table.concat(names, ", ")
end

---@alias FeedPetEmotesRow {text: FontString, editButton: UIPanelButtonTemplate, removeButton: UIPanelCloseButton}

---One row per line, created when first needed and reused after that.
---@type FeedPetEmotesRow[]
local rows = {}

---The row at a position, made on first use: the line with its conditions in
---blue in front, an Edit button, and a small red X that removes it (its
---tooltip says so).
---@param index number
---@return FeedPetEmotesRow
local function rowAt(index)
    if rows[index] then return rows[index] end
    local text = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    text:SetPoint("TOPLEFT", listTitle, "BOTTOMLEFT", 4, -8 - (index - 1) * ROW_HEIGHT)
    -- Room on the right for the Edit button (60), the X (22) and their gaps.
    toRightEdge(text, 106)
    -- One line per row: a long line is cut off with "..." rather than wrapped.
    text:SetWordWrap(false)
    local editButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    editButton:SetSize(60, 20)
    editButton:SetPoint("LEFT", text, "RIGHT", 6, 0)
    editButton:SetText(L.OPTION_CUSTOM_EDIT)
    editButton:SetScript("OnClick", function()
        edit(index)
    end)
    local removeButton = CreateFrame("Button", nil, content, "UIPanelCloseButton")
    removeButton:SetSize(22, 22)
    removeButton:SetPoint("LEFT", editButton, "RIGHT", 2, 0)
    removeButton:SetScript("OnClick", function()
        E.RemoveCustomLine(index)
        -- The numbers below it shift; an open edit would point at the wrong line.
        edit(nil)
        refresh()
    end)
    removeButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(removeButton, "ANCHOR_RIGHT")
        GameTooltip:SetText(L.OPTION_CUSTOM_REMOVE)
        GameTooltip:Show()
    end)
    removeButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    rows[index] = { text = text, editButton = editButton, removeButton = removeButton }
    return rows[index]
end

---Shows one row per line in use (this character's or the shared ones),
---hides the rest, and makes the scroll child tall enough for them.
function refresh()
    local lines = E.CustomLines()
    listTitle:SetText(E.Format(E.db.sharedLines and "OPTION_LIST_SHARED" or "OPTION_LIST_OWN", #lines))
    for index, line in ipairs(lines) do
        local row = rowAt(index)
        local tags, text = E.ParseCustomLine(line)
        local shown = line
        if tags and next(tags) then
            shown = "|cff66bbff[" .. conditionNames(tags) .. "]|r " .. text
        elseif tags then
            shown = text
        end
        row.text:SetText(index .. ". " .. shown)
        for _, region in pairs(row) do
            region:Show()
        end
    end
    for index = #lines + 1, #rows do
        for _, region in pairs(rows[index]) do
            region:Hide()
        end
    end
    content:SetHeight(CONTENT_BASE + #lines * ROW_HEIGHT)
    if #lines == 0 then
        empty:Show()
    else
        empty:Hide()
    end
end

---The editor's state: nil while adding, else the index of the line being edited.
---@type number?
local editing

---Fills the editor with line `index` (text and ticked conditions), or
---empties it for a new line when index is nil.
---@param index number?
function edit(index)
    local line = index and E.CustomLines()[index]
    if not line then index = nil end
    editing = index
    local tags, text = {}, ""
    if line then
        tags, text = E.ParseCustomLine(line)
        -- A saved line with a tag this version does not know: edit it as typed.
        if not tags then
            tags, text = {}, line
        end
    end
    input:SetText(text)
    for _, box in ipairs(conditionBoxes) do
        box:SetChecked(tags[box.conditionTag] or false)
    end
    editorTitle:SetText(index and E.Format("OPTION_EDIT_LINE", index) or L.OPTION_NEW_LINE)
    saveButton:SetText(index and L.OPTION_CUSTOM_SAVE or L.OPTION_CUSTOM_ADD)
    if index then
        cancelButton:Show()
    else
        cancelButton:Hide()
    end
    problem:SetText("")
end

---Adds the editor's line, or saves it over the one being edited.
local function save()
    local tags = {}
    for _, box in ipairs(conditionBoxes) do
        if box:GetChecked() then tags[box.conditionTag] = true end
    end
    local ok, result
    if editing then
        ok, result = E.ReplaceCustomLine(editing, input:GetText(), tags)
    else
        ok, result = E.AddCustomLine(input:GetText(), tags)
    end
    if ok then
        edit(nil)
        refresh()
    else
        problem:SetText(result)
    end
end

saveButton:SetScript("OnClick", save)
input:SetScript("OnEnterPressed", save)
input:SetScript("OnEscapePressed", unfocus)
cancelButton:SetScript("OnClick", function()
    edit(nil)
end)

panel:SetScript("OnShow", function()
    for key, box in pairs(checkboxes) do
        box:SetChecked(E.db[key])
    end
    local chance = E.db.customChance
    slider:SetValue(chance)
    -- SetValue only reports a change; the title must show an unchanged value too.
    showChance(chance)
    edit(nil)
    refresh()
end)

-- The language server types this Settings table only as `table`; the
-- category is a SettingsCategoryMixin in Blizzard_Settings_Shared.
---@type SettingsCategoryMixin
local category = Settings.RegisterCanvasLayoutCategory(panel, L.OPTIONS_TITLE)
Settings.RegisterAddOnCategory(category)

-- In combat the settings window is not opened from an addon: the call can be
-- blocked or taint the window. /fpe config then waits for the end of combat
-- (PLAYER_REGEN_ENABLED) and opens it once; asking again meanwhile changes
-- nothing.
local afterCombat = CreateFrame("Frame")
afterCombat:SetScript("OnEvent", function()
    afterCombat:UnregisterEvent("PLAYER_REGEN_ENABLED")
    Settings.OpenToCategory(category:GetID())
end)

function E.OpenOptions()
    if InCombatLockdown and InCombatLockdown() then
        afterCombat:RegisterEvent("PLAYER_REGEN_ENABLED")
        E.Print(L.OPTIONS_AFTER_COMBAT)
        return
    end
    Settings.OpenToCategory(category:GetID())
end
