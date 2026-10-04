local addonName, E = ...

-- Wiring: the events and the hook feed E.FoodTracker, and a Feed Pet cast
-- turns the food it claims into an emote. How food is recognised lives in
-- FoodTracker.lua, how the text is built in Emote.lua, /fpfe in Commands.lua.

local Debug, Public, Tracker = E.Debug, E.Public, E.FoodTracker

---Sends the emote for one feeding, unless emotes are off.
---@param itemID number?
local function sendEmote(itemID)
    if not E.db.enabled then return end
    local text = E.BuildEmote(itemID)
    if not text then
        Debug("no emote: the pet's name is unavailable")
        return
    end
    local sendChat, how = E.SendFunction()
    if not sendChat then
        Debug("no emote: no chat send function")
        return
    end
    Debug("sending via " .. how)
    sendChat(text, "EMOTE")
end

-- Targeted food: clicking food while Feed Pet waits for its target.
hooksecurefunc(C_Container, "UseContainerItem", function(bag, slot)
    Tracker:OnTargeted(bag, slot)
end)

-- Events: one method per event on this frame, named after the event and called
-- with the event's own arguments. Only ADDON_LOADED is registered up front; it
-- registers the rest once the saved settings are there.
local frame = CreateFrame("Frame")

function frame:ADDON_LOADED(name)
    if name ~= addonName then return end
    self:UnregisterEvent("ADDON_LOADED")
    E.LoadSettings()
    self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
    self:RegisterEvent("CURSOR_CHANGED")
    self:RegisterEvent("BAG_UPDATE_DELAYED")
end

function frame:CURSOR_CHANGED()
    Tracker:OnCursorChanged()
end

function frame:BAG_UPDATE_DELAYED()
    Tracker:OnBagsUpdated()
end

function frame:UNIT_SPELLCAST_SUCCEEDED(_, _, spellID)
    if not Public(spellID) or spellID ~= E.FEED_PET_SPELL then return end
    local itemID, source = Tracker:Claim()
    if not itemID then
        Tracker:WaitForBags(sendEmote)
        return
    end
    Debug("Feed Pet cast seen; food item " .. itemID .. " (" .. source .. ")")
    sendEmote(itemID)
end

frame:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)
frame:RegisterEvent("ADDON_LOADED")
