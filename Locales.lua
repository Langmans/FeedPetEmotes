local _, E = ...

-- Strings per client locale. A locale lists only what it translates; every
-- other key falls back to enUS through a metatable. A key missing from enUS
-- as well returns the key itself, so a typo shows up in game instead of
-- erroring on a nil concatenation.
--
-- FEED and FEED_NO_FOOD form the /emote text in front of the random line. A
-- value may be a function when plain string.format is not enough (the English
-- "a"/"an" article).
local locales = {}

locales.enUS = {
    FEED = function(pet, food)
        local article = food:match("^[AEIOUaeiou]") and "an" or "a"
        return string.format("feeds %s %s %s. ", pet, article, food)
    end,
    FEED_NO_FOOD = "feeds %s. ",

    CHAT_PREFIX = "Feed Pet: Forever Emotes:",
    EMOTES_ON = "Emotes on.",
    EMOTES_OFF = "Emotes off.",
    STATUS = "Emotes are %s. Commands: /fpfe on, /fpfe off, /fpfe test (local preview).",
    STATUS_ON = "on",
    STATUS_OFF = "off",
    NO_PET = "Summon your pet first.",
    YOU = "You",
}

-- Feed lines from Feed-O-Matic's localization, with the German and Spanish
-- grammar tidied up.
locales.deDE = {
    FEED = "füttert %s mit %s. ",
    FEED_NO_FOOD = "füttert %s. ",
}

locales.frFR = {
    FEED = "donne à %s à manger un(e) %s. ",
    FEED_NO_FOOD = "nourrit %s. ",
}

locales.esES = {
    FEED = "alimenta a %s con %s. ",
    FEED_NO_FOOD = "alimenta a %s. ",
}
locales.esMX = locales.esES

locales.ruRU = {
    FEED = "кормит питомца, %s ест %s. ",
    FEED_NO_FOOD = "кормит питомца %s. ",
}

locales.koKR = {
    FEED = " %s에게 %s를 먹이며 말합니다. ",
    FEED_NO_FOOD = " %s에게 먹이를 줍니다. ",
}

setmetatable(locales.enUS, {
    __index = function(_, key)
        return key
    end,
})

local L = locales[GetLocale()] or locales.enUS
-- enUS must not get itself as __index: the lookup would chain forever.
if L ~= locales.enUS then setmetatable(L, { __index = locales.enUS }) end

E.L = L

---Formats a locale entry that is either a format string or a function.
---@param key string
---@return string
function E.Format(key, ...)
    -- Never nil: the metatables end in a function that returns the key.
    ---@type string|fun(...): string
    local value = L[key]
    if type(value) == "function" then return value(...) end
    return string.format(value, ...)
end
