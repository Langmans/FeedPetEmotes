local _, E = ...

-- The player's own emote lines, saved per character in E.db.customLines and
-- managed with /fpe add|list|remove or the options panel. E.EmotePool puts them
-- in the pool next to the built-in lines, or instead of them with
-- E.db.customOnly. They take the same placeholders as the built-in lines,
-- plus {food} (see E.FillPlaceholders).

-- An emote is at most 255 bytes, and "feeds <pet> a <item link>. " in front
-- of the line can take about 100 of them.
E.CUSTOM_LINE_MAX = 150

---Trims and checks a line, then saves it at the end of the list.
---@param text string?
---@return boolean added
---@return string result the saved line, or why it was refused, ready to show
function E.AddCustomLine(text)
    local line = (text or ""):match("^%s*(.-)%s*$") or ""
    if line == "" then return false, E.L.CUSTOM_EMPTY end
    if #line > E.CUSTOM_LINE_MAX then return false, E.Format("CUSTOM_TOO_LONG", E.CUSTOM_LINE_MAX) end
    -- | starts an escape sequence in chat; a stray one can break the message.
    if line:find("|", 1, true) then return false, E.L.CUSTOM_BAR end
    local lines = E.db.customLines
    for _, existing in ipairs(lines) do
        if existing == line then return false, E.L.CUSTOM_DUPLICATE end
    end
    lines[#lines + 1] = line
    return true, line
end

---Removes the line at a position in the list.
---@param index number?
---@return string? line the removed line, or nil when there is none at index
function E.RemoveCustomLine(index)
    local lines = E.db.customLines
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
