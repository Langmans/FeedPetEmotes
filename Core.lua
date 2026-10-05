local _, E = ...

-- Shared helpers and the saved settings. Loaded after Locale.lua (E.Print
-- needs E.L) and before every module that uses them.

E.FEED_PET_SPELL = 6991

---False for a secret value (Forever hides some values in combat), true
---otherwise, including on clients without secret values.
---@param value any
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

-- Saved per character; a missing or broken value gets its default.
local DEFAULTS = {
    enabled = true, -- /fpe on|off
    petName = false, -- /fpe name on|off
    debug = false, -- /fpe debug
    sharedLines = false, -- /fpe shared on|off
    customChance = 0, -- /fpe chance <0-100>; 0: every line counts the same
    customFallback = true, -- /fpe fallback on|off
}

---A list of own lines (CustomLines.lua) as saved: only its strings are kept.
---@param saved any
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

---Creates or repairs the saved settings and makes them E.db (per character,
---FeedPetEmotesDBPC) and E.accountDB (account-wide, FeedPetEmotesDB); both
---names are declared in the .toc. The account table only holds the own lines
---shared by every character that ticks sharedLines. Called on ADDON_LOADED,
---when the client has filled in the saved tables.
function E.LoadSettings()
    if type(FeedPetEmotesDBPC) ~= "table" then FeedPetEmotesDBPC = {} end
    local db = FeedPetEmotesDBPC
    -- customOnly (own lines only) is now a chance of 100%.
    if db.customOnly == true and db.customChance == nil then db.customChance = 100 end
    db.customOnly = nil
    for key, default in pairs(DEFAULTS) do
        if type(db[key]) ~= type(default) then db[key] = default end
    end
    db.customLines = cleanLines(db.customLines)
    -- A whole percentage; anything else is put back to the nearest one.
    db.customChance = math.max(0, math.min(100, math.floor(db.customChance + 0.5)))
    E.db = db

    if type(FeedPetEmotesDB) ~= "table" then FeedPetEmotesDB = {} end
    FeedPetEmotesDB.customLines = cleanLines(FeedPetEmotesDB.customLines)
    E.accountDB = FeedPetEmotesDB
end

---The own lines this character uses: the account-wide list with sharedLines
---on, its own list otherwise. Each list is kept when the other is in use.
---@return string[]
function E.CustomLines()
    return E.db.sharedLines and E.accountDB.customLines or E.db.customLines
end
