local _, E = ...

-- Sending the emote. Forever only lets an addon send chat from inside a
-- hardware event (a key press or a mouse click); a send from an event handler
-- or a timer is blocked with ADDON_ACTION_BLOCKED. The emote is built when
-- the Feed Pet cast succeeds, which is a server event, so it is held here and
-- sent on the player's next key press (any key, movement included) or click
-- in the game world. One that waits longer than MAX_WAIT seconds is dropped:
-- by then it would no longer read as a reaction to the feeding. So is one
-- whose moment comes while the client locks addon chat (combat and the like).
--
-- Key presses come from a hidden-until-needed frame that takes keyboard input
-- and passes every key on (SetPropagateKeyboardInput), so it never eats a
-- key; it is only shown while an emote waits. Clicks come from a hook on the
-- game world's OnMouseDown.
--
-- With the MessageQueue addon loaded (an optional dependency), the emote is
-- handed to MessageQueue.Enqueue instead, and the key frame stays hidden.
-- MessageQueue catches more kinds of input (any click, the mouse wheel, a
-- gamepad, or a key sent by its AutoHotkey helper) with a screen-wide frame
-- that swallows mouse input while something waits; that is its own design.
-- Its MessageQueue.SendChatMessage only queues SAY, YELL and CHANNEL and
-- would send an EMOTE at once (and be blocked), hence Enqueue with Flush.
-- MessageQueue keeps the entry until its next hardware event even after
-- MAX_WAIT; Flush then finds nothing to send.

local Debug = E.Debug

local MAX_WAIT = 10

---@class FeedPetEmotesSender
---@field text string? the emote waiting to be sent
---@field queuedAt number? GetTime() when it was queued
local Sender = {}
E.Sender = Sender

local keys = CreateFrame("Frame", nil, UIParent)
keys:Hide()
keys:EnableKeyboard(true)

-- SetPropagateKeyboardInput is restricted in combat. After a /reload in
-- combat it is set once combat ends; until then the frame stays hidden (a
-- shown one would swallow every key) and only clicks send the emote.
local propagating = false
local function propagate()
    keys:SetPropagateKeyboardInput(true)
    propagating = true
end
function keys:PLAYER_REGEN_ENABLED()
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    propagate()
end
---@param self Frame
---@param event string
local function onEvent(self, event)
    self[event](self)
end
keys:SetScript("OnEvent", onEvent)
if InCombatLockdown() then
    keys:RegisterEvent("PLAYER_REGEN_ENABLED")
else
    propagate()
end

---Sends the waiting emote, if any; called inside a hardware event.
---@param how string what the player did, for the debug trace
function Sender:Flush(how)
    local text, queuedAt = self.text, self.queuedAt
    self.text, self.queuedAt = nil, nil
    keys:Hide()
    if not text or not queuedAt then return end
    if GetTime() - queuedAt > MAX_WAIT then
        Debug("no emote: no key press or click within " .. MAX_WAIT .. "s")
        return
    end
    -- An emote that arrives after the fight would be out of place, so it is
    -- dropped rather than kept for later.
    if E.ChatLocked() then
        Debug("no emote: the client blocks addon chat right now (chat messaging lockdown)")
        return
    end
    local sendChat, sendName = E.SendFunction()
    if not sendChat then
        Debug("no emote: no chat send function")
        return
    end
    Debug("sending on " .. how .. " via " .. sendName)
    sendChat(text, "EMOTE")
end

---MessageQueue's Enqueue when that addon is loaded, else nil.
---@return fun(f: fun())?
local function messageQueue()
    return MessageQueue and MessageQueue.Enqueue
end

---Holds `text` until the next key press or click; a newer emote replaces one
---still waiting.
---@param text string
function Sender:Queue(text)
    local queuedAt = GetTime()
    self.text, self.queuedAt = text, queuedAt
    local enqueue = messageQueue()
    if enqueue then
        enqueue(function()
            self:Flush("MessageQueue")
        end)
        Debug("emote ready; MessageQueue sends it on your next input")
    else
        if propagating then keys:Show() end
        Debug("emote ready; it is sent on your next key press or click")
    end
    -- Expiry without a key press: hide the frame again so it does not stay
    -- in the keyboard chain.
    C_Timer.After(MAX_WAIT + 0.5, function()
        if self.queuedAt == queuedAt then self:Flush("timeout") end
    end)
end

---@param _ Frame
---@param key string
local function onKeyDown(_, key)
    Sender:Flush("key " .. key)
end
keys:SetScript("OnKeyDown", onKeyDown)

local function onWorldClick()
    if Sender.text then Sender:Flush("click") end
end
WorldFrame:HookScript("OnMouseDown", onWorldClick)
