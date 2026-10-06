local _, E = ...

-- The player's own emote lines, managed with /fpe add|list|remove or the
-- options panel. They live in the list E.CustomLines() returns: this
-- character's own, or the account-wide one with E.db.sharedLines. The ones
-- whose conditions hold compete with the built-in lines as E.PickLine
-- decides (E.db.customChance, E.db.customFallback). They take the same
-- placeholders as the built-in lines, plus {food} (see E.FillPlaceholders).
--
-- A line is saved as one string. It may start with conditions in brackets,
-- "[cat,wolf,fish] Good hunter!": the same keys the built-in lists use (sex,
-- food type, pet family), as English tags on every client language. Tags of
-- one group match if any of them holds (cat or wolf); every group named must
-- match (and fish). No brackets: the line always applies.

-- An emote is at most 255 bytes, and "feeds <pet> a <item link>. " in front
-- of the line can take about 100 of them. Conditions are not sent, so they
-- do not count.
E.CUSTOM_LINE_MAX = 150

---@class Condition
---@field tag string what is typed between the brackets
---@field group "sex"|"foodType"|"family"
---@field value number|string what the situation must hold for that group: a sex or family ID, a food type

---Every condition, in the order a saved line lists them: sex, food type, family.
---@type Condition[]
E.Conditions = {
    { tag = "male", group = "sex", value = 2 },
    { tag = "female", group = "sex", value = 3 },
}
-- The food types E.FoodTypes uses, in the order the panel shows them.
for _, foodType in ipairs({ "bread", "meat", "fish", "cheese", "fruit", "fungus" }) do
    E.Conditions[#E.Conditions + 1] = { tag = foodType, group = "foodType", value = foodType }
end
-- The families by ID; the panel sorts them again, by name.
---@type {tag: string, group: "family", value: number}[]
local families = {}
for name, id in pairs(E.Family) do
    families[#families + 1] = { tag = name:lower(), group = "family", value = id }
end
---@param a {value: number}
---@param b {value: number}
---@return boolean
local function byID(a, b)
    return a.value < b.value
end
table.sort(families, byID)
for _, condition in ipairs(families) do
    E.Conditions[#E.Conditions + 1] = condition
end

---Tag -> its condition.
---@type table<string, Condition>
E.ConditionByTag = {}
for _, condition in ipairs(E.Conditions) do
    E.ConditionByTag[condition.tag] = condition
end

---Every tag, for the message about an unknown one.
---@return string
local function allTags()
    local tags = {}
    for _, condition in ipairs(E.Conditions) do
        tags[#tags + 1] = condition.tag
    end
    return table.concat(tags, ", ")
end

---Splits a saved or typed line into its conditions and its text.
---@param line string
---@return table<string, true>? tags the condition tags, empty for none; nil when one is unknown
---@return string text the line without its conditions; the unknown tag when tags is nil
function E.ParseCustomLine(line)
    local list, text = line:match("^%[([^%]]*)%]%s*(.*)$")
    if not list then return {}, line end
    local tags = {}
    for word in list:gmatch("[^,%s]+") do
        word = word:lower()
        if not E.ConditionByTag[word] then return nil, word end
        tags[word] = true
    end
    return tags, text
end

---A line as it is saved: its conditions in a fixed order, then the text.
---@param tags table<string, true>
---@param text string
---@return string
function E.FormatCustomLine(tags, text)
    local list = {}
    for _, condition in ipairs(E.Conditions) do
        if tags[condition.tag] then list[#list + 1] = condition.tag end
    end
    if #list == 0 then return text end
    return "[" .. table.concat(list, ",") .. "] " .. text
end

---Whether a line's conditions hold for one feeding.
---@param tags table<string, true>
---@param situation {sex: number?, foodType: string?, family: number?}
---@return boolean
function E.ConditionsHold(tags, situation)
    local named, met = {}, {}
    for tag in pairs(tags) do
        local condition = E.ConditionByTag[tag]
        named[condition.group] = true
        if situation[condition.group] == condition.value then met[condition.group] = true end
    end
    for group in pairs(named) do
        if not met[group] then return false end
    end
    return true
end

---The panel's name for a condition; the tag itself when the locale has none.
---@param tag string
---@return string
function E.ConditionLabel(tag)
    local key = "OPTION_COND_" .. tag:upper()
    local label = E.L[key]
    return label ~= key and label or tag
end

---Trims and checks a line, merges in extra conditions, and returns it as
---it is saved. skip is the index of the line being replaced, which may
---equal the result.
---@param text string?
---@param extraTags table<string, true>?
---@param skip number?
---@return boolean ok
---@return string result the line to save, or why it was refused, ready to show
local function prepare(text, extraTags, skip)
    local tags, body = E.ParseCustomLine((text or ""):match("^%s*(.-)%s*$") or "")
    if not tags then return false, E.Format("CUSTOM_UNKNOWN_CONDITION", body, allTags()) end
    for tag in pairs(extraTags or {}) do
        tags[tag] = true
    end
    if body == "" then return false, E.L.CUSTOM_EMPTY end
    if #body > E.CUSTOM_LINE_MAX then return false, E.Format("CUSTOM_TOO_LONG", E.CUSTOM_LINE_MAX) end
    -- | starts an escape sequence in chat; a stray one can break the message.
    if body:find("|", 1, true) then return false, E.L.CUSTOM_BAR end
    local line = E.FormatCustomLine(tags, body)
    for index, existing in ipairs(E.CustomLines()) do
        if existing == line and index ~= skip then return false, E.L.CUSTOM_DUPLICATE end
    end
    return true, line
end

---Checks a line, then saves it at the end of the list.
---@param text string? may start with [conditions]
---@param extraTags table<string, true>? conditions ticked in the panel
---@return boolean added
---@return string result the saved line, or why it was refused, ready to show
function E.AddCustomLine(text, extraTags)
    local ok, result = prepare(text, extraTags)
    if ok then
        local lines = E.CustomLines()
        lines[#lines + 1] = result
    end
    return ok, result
end

---Checks a line, then saves it in place of the one at index.
---@param index number
---@param text string?
---@param extraTags table<string, true>?
---@return boolean replaced
---@return string result the saved line, or why it was refused, ready to show
function E.ReplaceCustomLine(index, text, extraTags)
    local lines = E.CustomLines()
    if not lines[index] then return false, E.Format("CUSTOM_NO_SUCH", index) end
    local ok, result = prepare(text, extraTags, index)
    if ok then lines[index] = result end
    return ok, result
end

---Removes the line at a position in the list.
---@param index number?
---@return string? line the removed line, or nil when there is none at index
function E.RemoveCustomLine(index)
    local lines = E.CustomLines()
    if not index or not lines[index] then return nil end
    return table.remove(lines, index)
end

---The placeholders a custom line can use on this locale, e.g. "{pet}, {food}, {he}".
---@return string
function E.PlaceholderList()
    local tokens = {}
    for token in pairs(E.Pronouns) do
        tokens[#tokens + 1] = "{" .. token .. "}"
    end
    table.sort(tokens)
    table.insert(tokens, 1, "{food}")
    table.insert(tokens, 1, "{pet}")
    return table.concat(tokens, ", ")
end
