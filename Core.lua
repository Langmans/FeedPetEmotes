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

---/fpfe debug traces the feeding path in chat; the setting is saved per character.
---@param message string
function E.Debug(message)
    if E.db and E.db.debug then E.Print("|cff88ccff[debug]|r " .. message) end
end

---The function that sends a chat message on this client, and its name for
---/fpfe selftest; nil and "missing" when there is none.
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
    enabled = true, -- /fpfe on|off
    petName = false, -- /fpfe name on|off
    debug = false, -- /fpfe debug
}

---Creates or repairs the saved settings (FeedPetForeverEmotesDBPC, declared in
---the .toc) and makes them E.db. Called on ADDON_LOADED, when the client has
---filled in the saved table.
function E.LoadSettings()
    if type(FeedPetForeverEmotesDBPC) ~= "table" then FeedPetForeverEmotesDBPC = {} end
    for key, default in pairs(DEFAULTS) do
        if type(FeedPetForeverEmotesDBPC[key]) ~= type(default) then FeedPetForeverEmotesDBPC[key] = default end
    end
    E.db = FeedPetForeverEmotesDBPC
end
