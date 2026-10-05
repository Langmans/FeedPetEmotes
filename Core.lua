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
    customOnly = false, -- /fpe only on|off
}

---Creates or repairs the saved settings (FeedPetEmotesDBPC, declared in
---the .toc) and makes them E.db. Called on ADDON_LOADED, when the client has
---filled in the saved table.
function E.LoadSettings()
    if type(FeedPetEmotesDBPC) ~= "table" then FeedPetEmotesDBPC = {} end
    local db = FeedPetEmotesDBPC
    for key, default in pairs(DEFAULTS) do
        if type(db[key]) ~= type(default) then db[key] = default end
    end
    -- The player's own lines (CustomLines.lua): a list of strings; anything
    -- else in it is dropped.
    local lines = {}
    if type(db.customLines) == "table" then
        for _, line in ipairs(db.customLines) do
            if type(line) == "string" then lines[#lines + 1] = line end
        end
    end
    db.customLines = lines
    E.db = db
end
