local _, E = ...

-- Shared helpers and the saved settings. Loaded after Locale.lua (E.Print
-- needs E.L) and before every module that uses them.
--
-- Globals this file writes: FeedPetEmotesDB and FeedPetEmotesDBPC, the
-- SavedVariables from the .toc. The WoW Lua LS only knows them when it reads
-- the .toc, so .wowluarc.json lists them under globals.write as well.

E.FEED_PET_SPELL = 6991

-- Set on ADDON_LOADED (E.LoadSettings, FeedPetEmotes.lua). Declared here so
-- the language server knows their types in every file: a field first
-- assigned inside a function is untyped to it.
---@type FeedPetEmotesSettings
E.db = nil
---@type FeedPetEmotesAccountSettings
E.accountDB = nil
---Whether this character is a hunter, the only class with a pet to feed.
---@type boolean
E.isHunter = false

---False for a secret value (Forever hides some values in combat), true
---otherwise, including on clients without secret values.
---@param value string|number|boolean|table|nil
---@return boolean
function E.Public(value)
    return not issecretvalue or not issecretvalue(value)
end

---@param message string
function E.Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffcc66" .. E.L.CHAT_PREFIX .. "|r " .. message)
end

---/fpe debug traces the feeding path in chat; the setting is saved per character.
---@param message string
function E.Debug(message)
    if E.db and E.db.debug then E.Print("|cff88ccff[debug]|r " .. message) end
end

---The function that sends a chat message on this client, and its name for
---/fpe selftest; nil and "missing" when there is none.
---@return function?
---@return string
function E.SendFunction()
    if C_ChatInfo and C_ChatInfo.SendChatMessage then
        return C_ChatInfo.SendChatMessage, "C_ChatInfo.SendChatMessage"
    end
    if SendChatMessage then return SendChatMessage, "SendChatMessage" end
    return nil, "missing"
end

-- Saved per character. The saved file keeps only what the player changed:
-- E.db reads a missing value from here through a metatable, and
-- E.StripDefaults removes values equal to their default at logout. A default
-- changed in a later version so reaches everyone who never changed it.
local DEFAULTS = {
    enabled = true, -- /fpe on|off
    petName = false, -- /fpe name on|off
    debug = false, -- /fpe debug
    sharedLines = false, -- /fpe shared on|off
    customChance = 0, -- /fpe chance <0-100>; 0: every line counts the same
    customFallback = true, -- /fpe fallback on|off
}

---A value as the client reads it back from a SavedVariables file, before the
---addon has checked it: anything a player or an older version may have left
---there. One level of table is spelled out, as deep as the checks below look.
---@alias SavedValue string|number|boolean|table<string|number|boolean, string|number|boolean|table>

---A list of own lines (CustomLines.lua) as saved: only its strings are kept.
---@param saved SavedValue?
---@return string[]
local function cleanLines(saved)
    local lines = {}
    if type(saved) == "table" then
        for _, line in ipairs(saved) do
            if type(line) == "string" then lines[#lines + 1] = line end
        end
    end
    return lines
end

---The per-pet sex choices as saved (/fpe sex): pet number -> 2 (male) or 3
---(female). Anything else is dropped; a pet without a choice has no entry.
---@param saved SavedValue?
---@return table<number, number>
local function cleanPetSex(saved)
    local choices = {}
    if type(saved) == "table" then
        for petNumber, sex in pairs(saved) do
            if type(petNumber) == "number" and (sex == 2 or sex == 3) then choices[petNumber] = sex end
        end
    end
    return choices
end

---The summoned pet's number, the same value as C_StableInfo's
---PetInfo.petNumber: the low 32 bits of the GUID's last field (the spawn UID;
---its high bits are a summon counter). It stays the same through resummons,
---relogs, stable swaps and renames, so per-pet settings are keyed on it; see
---docs/pet-id.md. Nil without a pet or when the GUID is secret.
---@return number?
function E.PetNumber()
    local guid = UnitGUID("pet")
    if not guid or not E.Public(guid) then return nil end
    local spawnUID = guid:match("^Pet%-.-%-(%x+)$")
    return spawnUID and tonumber(spawnUID:sub(-8), 16) or nil
end

---The summoned pet's name for the addon's own messages and panel, "Your pet"
---when there is none or it is secret.
---@return string
function E.PetDisplayName()
    local pet = UnitName("pet")
    if not pet or not E.Public(pet) then return E.L.YOUR_PET end
    return pet
end

---Saves the player's choice of sex for the summoned pet (/fpe sex, the
---options panel): 2 male, 3 female, or false to drop the choice so the
---game's value counts again. Returns the pet number it was saved under, or
---nil when there is no pet to save it for.
---@param sex number|false
---@return number?
function E.ChoosePetSex(sex)
    local petNumber = E.PetNumber()
    if not petNumber then return nil end
    local db = E.db
    db.petSex[petNumber] = sex or nil
    return petNumber
end

---Drops the sex choices of pets this hunter no longer has: a released pet's
---number is in neither of C_StableInfo's lists (both work away from a stable
---master and at PLAYER_ENTERING_WORLD; see docs/pet-id.md). Nothing is
---dropped when both lists are empty, as they could be before the client has
---the pets, when a pet number is secret, or on a client without these lists.
function E.PrunePetSex()
    -- Forever has both lists; Classic Era and Classic do not.
    local getActive = C_StableInfo and C_StableInfo.GetActivePetList
    local getStabled = C_StableInfo and C_StableInfo.GetStabledPetList
    if not (getActive and getStabled) then return end
    ---@type table<number, true>
    local owned = {}
    local any = false
    for _, list in ipairs({ getActive(), getStabled() }) do
        for _, pet in ipairs(list) do
            if not E.Public(pet.petNumber) then return end
            owned[pet.petNumber] = true
            any = true
        end
    end
    if not any then return end
    local db = E.db
    for petNumber in pairs(db.petSex) do
        if not owned[petNumber] then db.petSex[petNumber] = nil end
    end
end

---Creates or repairs the saved settings and makes them E.db (per character,
---FeedPetEmotesDBPC) and E.accountDB (account-wide, FeedPetEmotesDB); both
---names are declared in the .toc. The account table only holds the own lines
---shared by every character that ticks sharedLines. Called on ADDON_LOADED,
---when the client has filled in the saved tables.
function E.LoadSettings()
    if type(FeedPetEmotesDBPC) ~= "table" then FeedPetEmotesDBPC = {} end
    ---@type FeedPetEmotesSettings
    local db = FeedPetEmotesDBPC
    -- customOnly (own lines only) is now a chance of 100%.
    if db.customOnly == true and db.customChance == nil then db.customChance = 100 end
    db.customOnly = nil
    -- A broken value is dropped, so the default shows through.
    for key, default in pairs(DEFAULTS) do
        if db[key] ~= nil and type(db[key]) ~= type(default) then db[key] = nil end
    end
    setmetatable(db, { __index = DEFAULTS })
    db.customLines = cleanLines(db.customLines)
    db.petSex = cleanPetSex(db.petSex)
    -- A whole percentage; anything else is put back to the nearest one.
    db.customChance = math.max(0, math.min(100, math.floor(db.customChance + 0.5)))
    E.db = db

    if type(FeedPetEmotesDB) ~= "table" then FeedPetEmotesDB = {} end
    ---@type FeedPetEmotesAccountSettings
    local accountDB = FeedPetEmotesDB
    accountDB.customLines = cleanLines(accountDB.customLines)
    E.accountDB = accountDB
end

---Removes the settings that equal their default, so the saved file keeps
---only what the player changed. Called on PLAYER_LOGOUT, just before the
---client writes the file; E.db keeps working through its metatable.
function E.StripDefaults()
    for key, default in pairs(DEFAULTS) do
        if rawget(E.db, key) == default then E.db[key] = nil end
    end
end

---The own lines this character uses: the account-wide list with sharedLines
---on, its own list otherwise. Each list is kept when the other is in use.
---@return string[]
function E.CustomLines()
    return E.db.sharedLines and E.accountDB.customLines or E.db.customLines
end
