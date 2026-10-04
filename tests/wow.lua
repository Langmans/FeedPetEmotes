-- A simulated WoW client: just the API this addon touches, with every value a
-- test may want to vary exposed on the client object. NewClient() resets all
-- globals and loads the addon files in .toc order into a fresh namespace, so
-- tests never share state.

local FEED_PET_SPELL = 6991

-- Item names the simulated client knows; anything else is uncached (nil).
local ITEM_NAMES = {
    [12037] = "Mystery Meat",
    [4538] = "Snapvine Watermelon",
    [4608] = "Raw Black Truffle",
    [4536] = "Shiny Red Apple",
    [117] = "Tough Jerky",
    [4540] = "Tough Hunk of Bread",
}

---The chat link the client builds for an item, as C_Item.GetItemInfo's second return.
---@param itemID number
---@return string
function ItemLink(itemID)
    return string.format("|cffffffff|Hitem:%d::::::::60:::::|h[%s]|h|r", itemID, ITEM_NAMES[itemID])
end

---@class TestClient
---@field E table the addon namespace
---@field sent {text: string, kind: string}[] chat messages sent by the addon
---@field printed string[] lines the addon printed to the chat frame
---@field pet {name: any, sex: number?, family: any, familyID: any}?
---@field time number
---@field targeting boolean whether a spell is waiting for an item target
---@field secret table<any, boolean> values issecretvalue reports as secret

---@param opts {locale: string?, savedDB: table?, noChatInfo: boolean?, noChat: boolean?, noSecretValues: boolean?}?
---@return TestClient
function NewClient(opts)
    opts = opts or {}
    local client = {
        sent = {},
        printed = {},
        pet = { name = "Fluffy", sex = 2, family = "Cat", familyID = 2 },
        time = 100,
        targeting = false,
        secret = {},
        -- Bag 0 only: slot -> { itemID, count }.
        bag = {},
        timers = {},
        frames = {},
    }

    function GetLocale()
        return opts.locale or "enUS"
    end
    function GetBuildInfo()
        return "1.60.1", "70170", "Sep 1 2026", 16001
    end
    function GetTime()
        return client.time
    end
    function UnitExists(unit)
        return unit == "pet" and client.pet ~= nil or unit == "player"
    end
    function UnitName(unit)
        if unit == "player" then return "Langmans" end
        return client.pet and client.pet.name
    end
    function UnitSex()
        return client.pet and client.pet.sex
    end
    function UnitCreatureFamily()
        if not client.pet then return nil end
        return client.pet.family, client.pet.familyID
    end
    function SpellIsTargeting()
        return client.targeting
    end
    -- client.cursorItem: the item ID held on the cursor, or nil.
    function GetCursorInfo()
        if client.cursorItem then return "item", client.cursorItem end
    end
    function IsSpellKnown(spellID)
        return spellID == FEED_PET_SPELL
    end
    C_SpellBook = nil

    if opts.noSecretValues then
        issecretvalue = nil
    else
        function issecretvalue(value)
            return client.secret[value] == true
        end
    end

    C_Item = {
        GetItemInfo = function(itemID)
            if not ITEM_NAMES[itemID] then return nil end
            return ITEM_NAMES[itemID], ItemLink(itemID)
        end,
    }
    C_Container = {
        UseContainerItem = function() end,
        GetContainerNumSlots = function(bag)
            return bag == 0 and #client.bag or 0
        end,
        GetContainerItemInfo = function(bag, slot)
            local item = bag == 0 and client.bag[slot]
            if not item then return nil end
            return { itemID = item.itemID, stackCount = item.count }
        end,
    }
    NUM_BAG_SLOTS = 4
    C_Timer = {
        After = function(seconds, callback)
            client.timers[#client.timers + 1] = { at = client.time + seconds, callback = callback }
        end,
    }

    local function capture(text, kind)
        client.sent[#client.sent + 1] = { text = text, kind = kind }
    end
    if opts.noChat then
        C_ChatInfo = nil
        SendChatMessage = nil
    elseif opts.noChatInfo then
        C_ChatInfo = nil
        SendChatMessage = capture
    else
        C_ChatInfo = { SendChatMessage = capture }
        SendChatMessage = nil
    end
    DEFAULT_CHAT_FRAME = {
        AddMessage = function(_, text)
            client.printed[#client.printed + 1] = text
        end,
    }

    function hooksecurefunc(owner, name, hook)
        local original = owner[name]
        owner[name] = function(...)
            local results = { original(...) }
            hook(...)
            return unpack(results)
        end
    end

    function CreateFrame()
        local frame = { events = {}, unitEvents = {} }
        function frame:RegisterEvent(event)
            self.events[event] = true
        end
        function frame:UnregisterEvent(event)
            self.events[event] = nil
        end
        function frame:RegisterUnitEvent(event, unit)
            self.unitEvents[event] = unit
        end
        function frame:SetScript(_, handler)
            self.onEvent = handler
        end
        client.frames[#client.frames + 1] = frame
        return frame
    end

    SlashCmdList = {}
    -- Seeded under the name the .toc declares, as the client would.
    _G[TOC_SAVED_PER_CHARACTER] = opts.savedDB

    local E = {}
    for _, file in ipairs(TOC_FILES) do
        local chunk = assert(loadfile(ROOT .. "/" .. file))
        chunk("FeedPetForeverEmotes", E)
    end
    client.E = E

    ---Delivers an event to every frame registered for it.
    function client:fire(event, ...)
        local unit = ...
        for _, frame in ipairs(self.frames) do
            local wanted = frame.events[event] or (frame.unitEvents[event] and frame.unitEvents[event] == unit)
            if wanted and frame.onEvent then frame.onEvent(frame, event, ...) end
        end
    end

    ---What the client does after the addon files ran: ADDON_LOADED for each addon.
    function client:login()
        self:fire("ADDON_LOADED", "SomeOtherAddon")
        self:fire("ADDON_LOADED", "FeedPetForeverEmotes")
        return self
    end

    ---The bag slot holding itemID, added (empty) if there is none.
    function client:slotOf(itemID)
        for slot, item in ipairs(self.bag) do
            if item.itemID == itemID then return slot end
        end
        self.bag[#self.bag + 1] = { itemID = itemID, count = 0 }
        return #self.bag
    end

    ---Puts `count` of an item in the bags; the client then reports the change.
    function client:stock(itemID, count)
        self.bag[self:slotOf(itemID)].count = count
        self:fire("BAG_UPDATE_DELAYED")
    end

    ---One of an item disappears from the bags, as when the pet eats it.
    function client:eat(itemID)
        local slot = self:slotOf(itemID)
        self.bag[slot].count = self.bag[slot].count - 1
        if self.bag[slot].count <= 0 then table.remove(self.bag, slot) end
        self:fire("BAG_UPDATE_DELAYED")
    end

    ---Moves the clock on and runs the C_Timer callbacks that came due.
    function client:advance(seconds)
        self.time = self.time + seconds
        local due = {}
        for i = #self.timers, 1, -1 do
            if self.timers[i].at <= self.time then table.insert(due, 1, table.remove(self.timers, i)) end
        end
        for _, timer in ipairs(due) do
            timer.callback()
        end
    end

    ---Picks an item from the bags, as clicking it or a secure target-bag button does.
    function client:pickItem(itemID, whileTargeting)
        local slot = self:slotOf(itemID)
        if self.bag[slot].count == 0 then self.bag[slot].count = 1 end
        self.targeting = whileTargeting ~= false
        C_Container.UseContainerItem(0, slot)
        self.targeting = false
    end

    ---Feed Pet cast from the spellbook, then food clicked in a bag whose button
    ---does not go through C_Container.UseContainerItem: the only trace is the
    ---food disappearing from the bags, before or after the cast is reported.
    function client:spellbookFeed(itemID, eatenBeforeCast)
        self:stock(itemID, 3)
        self.targeting = true
        self.targeting = false
        self.time = self.time + 0.2
        if eatenBeforeCast then self:eat(itemID) end
        self:castSucceeded()
        if not eatenBeforeCast then
            self:advance(0.1)
            self:eat(itemID)
        end
    end

    function client:castSucceeded(spellID, unit)
        self:fire("UNIT_SPELLCAST_SUCCEEDED", unit or "player", "Cast-GUID", spellID or FEED_PET_SPELL)
    end

    ---A whole Feed Pet: pick the food, then the cast succeeds `delay` seconds later.
    function client:feed(itemID, delay)
        self:pickItem(itemID)
        self.time = self.time + (delay or 0.2)
        self:castSucceeded()
    end

    ---Picks an item up onto the cursor, as dragging it out of a bag does.
    function client:pickUp(itemID)
        self.cursorItem = itemID
        self:fire("CURSOR_CHANGED", false, 1, 0, 0)
    end

    ---Empties the cursor: dropped on the pet (or its frame), or put back.
    function client:release()
        self.cursorItem = nil
        self:fire("CURSOR_CHANGED", true, 0, 1, 0)
    end

    ---Feeding by dragging food onto the pet: pick up, drop, the cast succeeds.
    function client:dragFeed(itemID, delay)
        self:pickUp(itemID)
        self.time = self.time + 1
        self:release()
        self.time = self.time + (delay or 0.1)
        self:castSucceeded()
    end

    function client:slash(message)
        SlashCmdList.FEEDPETFOREVEREMOTES(message)
    end

    ---Lets pending timers run out first: a cast with unknown food waits up to a
    ---second for the bags before it sends.
    function client:settle()
        self:advance(1.1)
    end

    function client:lastSent()
        self:settle()
        return self.sent[#self.sent]
    end

    ---True when any printed line contains `text` (plain find).
    function client:printedContains(text)
        for _, line in ipairs(self.printed) do
            if line:find(text, 1, true) then return true end
        end
        return false
    end

    return client
end

---The per-character saved settings, under the name the .toc declares.
---@return table
function Saved()
    return _G[TOC_SAVED_PER_CHARACTER]
end

-- fengari is Lua 5.3; WoW's Lua 5.1 has a global unpack.
unpack = unpack or table.unpack
