---@meta
-- Editor-only types for the addon's own tables: the saved settings and the
-- locale data in Locales\*.lua. Not listed in the .toc, so the game never
-- loads this file.

---The per-character settings, E.db (FeedPetEmotesDBPC). The boolean and
---number fields fall back to Core.lua's DEFAULTS through a metatable, so they
---always read as a value.
---@class FeedPetEmotesSettings
---@field enabled boolean emotes on or off (/fpe on, /fpe off)
---@field petName boolean the pet's name instead of he or she (/fpe name)
---@field debug boolean trace the feeding path in chat (/fpe debug)
---@field sharedLines boolean use the account-wide own lines (/fpe shared)
---@field customChance number a whole percentage 0-100 (/fpe chance)
---@field customFallback boolean a built-in line when no own line fits (/fpe fallback)
---@field customLines string[] this character's own lines
---@field petSex table<number, number> pet number -> 2 (male) or 3 (female)
---@field customOnly boolean? replaced by customChance 100; dropped on load

---The account-wide settings, E.accountDB (FeedPetEmotesDB).
---@class FeedPetEmotesAccountSettings
---@field customLines string[] the own lines shared by every character with sharedLines on

---One pronoun placeholder ({he}, {his}, ...) in one language.
---@class FeedPetEmotesPronoun
---@field male string
---@field female string
---@field unknown? string|fun(name: string): string a format with %s for the pet's name, or a function of it; the name alone when absent

---The built-in emote lines of one language, by what they apply to.
---@class FeedPetEmotesLines
---@field any string[] every feeding
---@field openings? string[] sentences that take FEED's place now and then; {food} is the item link, {a} its article
---@field whole? string[] whole emotes with no FEED or line, used when the food is known
---@field wholeFamily? table<number, string[]> pet family ID -> whole emotes for that family
---@field male string[]
---@field female string[]
---@field food table<string, string[]> food group (E.FoodGroups) -> lines
---@field foodType? table<string, string[]> food type (E.FoodTypes) -> lines
---@field family table<number, string[]> pet family ID -> lines

---One entry of E.Locales, from a file in Locales\.
---@class FeedPetEmotesLocale
---@field strings table<string, string> a value can also be a fun(...): string, read through E.Format
---@field pronouns? table<string, FeedPetEmotesPronoun>
---@field emotes? FeedPetEmotesLines
