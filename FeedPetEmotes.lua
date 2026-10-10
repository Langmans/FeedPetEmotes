local addonName, E = ...

-- Wiring: the events and the hook feed E.FoodTracker, and a Feed Pet cast
-- turns the food it claims into an emote. How food is recognised lives in
-- FoodTracker.lua, how the text is built in Emote.lua, /fpe in Commands.lua.

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
---@param bag number
---@param slot number
local function onUseContainerItem(bag, slot)
    if E.isHunter then Tracker:OnTargeted(bag, slot) end
end
hooksecurefunc(C_Container, "UseContainerItem", onUseContainerItem)

-- Events: one method per event on this frame, named after the event and called
-- with the event's own arguments. Only ADDON_LOADED is registered up front; it
-- registers the rest once the saved settings are there. PLAYER_LOGOUT strips
-- the default values from them before the client saves them.
--
-- Only a hunter has a pet to feed. On any other class the addon stays loaded
-- (the addon list is account-wide, so disabling it here would disable it for
-- the hunters too) but registers nothing past PLAYER_LOGOUT: no cursor or bag
-- watching, while /fpe and the options panel keep working.
local frame = CreateFrame("Frame")

---@param name string the addon that finished loading
function frame:ADDON_LOADED(name)
    if name ~= addonName then return end
    self:UnregisterEvent("ADDON_LOADED")
    E.LoadSettings()
    self:RegisterEvent("PLAYER_LOGOUT")
    E.isHunter = select(2, UnitClass("player")) == "HUNTER"
    if not E.isHunter then return end
    self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
    self:RegisterEvent("CURSOR_CHANGED")
    self:RegisterEvent("BAG_UPDATE_DELAYED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

-- The stable lists are filled by now; a pet released since the last login
-- loses its saved sex choice here.
function frame:PLAYER_ENTERING_WORLD()
    E.PrunePetSex()
end

function frame:PLAYER_LOGOUT()
    E.StripDefaults()
end

function frame:CURSOR_CHANGED()
    Tracker:OnCursorChanged()
end

function frame:BAG_UPDATE_DELAYED()
    Tracker:OnBagsUpdated()
end

---@param unit string always "player": registered for that unit only
---@param castGUID string
---@param spellID number
function frame:UNIT_SPELLCAST_SUCCEEDED(unit, castGUID, spellID)
    if not Public(spellID) or spellID ~= E.FEED_PET_SPELL then return end
    local itemID, source = Tracker:Claim()
    if not itemID then
        Tracker:WaitForBags(sendEmote)
        return
    end
    Debug("Feed Pet cast seen; food item " .. itemID .. " (" .. source .. ")")
    sendEmote(itemID)
end

---@param self Frame
---@param event string
---@param ... any the event's own arguments
local function onEvent(self, event, ...)
    self[event](self, ...)
end
frame:SetScript("OnEvent", onEvent)
frame:RegisterEvent("ADDON_LOADED")
