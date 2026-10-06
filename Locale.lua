local _, E = ...

-- Picks the client's locale from E.Locales (filled by Locales\*.lua).
--
-- E.L: strings. A locale lists only what it translates; every other key falls
-- back to enUS through a metatable. A key missing from enUS as well returns
-- the key itself, so a typo shows up in game instead of erroring on a nil
-- concatenation. A value may be a function when plain string.format is not
-- enough (the English "a"/"an" article); E.Format handles both.
--
-- E.Emotes: the emote lines. One line is picked at random from every list
-- that applies to the current feeding: "any", the pet's gender, the food's
-- group and the pet's family. A locale without emotes gets the enUS lines; a
-- locale that lacks one list simply has fewer lines to pick from, it never
-- mixes in English.

local enUS = E.Locales.enUS
local current = E.Locales[GetLocale()] or enUS
E.LocaleCode = E.Locales[GetLocale()] and GetLocale() or "enUS"

setmetatable(enUS.strings, {
    ---@param _ table<string, string>
    ---@param key string
    ---@return string
    __index = function(_, key)
        return key
    end,
})
-- enUS must not get itself as __index: the lookup would chain forever.
if current ~= enUS then setmetatable(current.strings, { __index = enUS.strings }) end

---@type table<string, string>
E.L = current.strings
---@type FeedPetEmotesLines
E.Emotes = current.emotes or enUS.emotes
-- Pronoun placeholders go with the emote lines they appear in, never through
-- the enUS fallback: an English "he" in a German line would be wrong, the
-- pet's name is not.
---@type table<string, FeedPetEmotesPronoun>
E.Pronouns = current.emotes and current.pronouns or not current.emotes and enUS.pronouns or {}

---Formats a locale entry that is either a format string or a function.
---@param key string
---@param ... string|number the values for the format's %s and %d
---@return string
function E.Format(key, ...)
    -- Never nil: the metatables end in a function that returns the key.
    ---@type string|fun(...): string
    local value = E.L[key]
    if type(value) == "function" then return value(...) end
    return string.format(value, ...)
end
