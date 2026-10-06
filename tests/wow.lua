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
---@field optionsPanel table? the panel registered with the game's settings
---@field optionsOpened number how often the settings were opened on that panel

---@param opts {locale: string?, class: string?, savedDB: table?, savedAccountDB: table?,noChatInfo: boolean?, noChat: boolean?, noSecretValues: boolean?, noAddOnsAPI: boolean?}?
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
    -- opts.class: the class file name (HUNTER by default) with an English name.
    function UnitClass()
        local classFile = opts.class or "HUNTER"
        return classFile:sub(1, 1) .. classFile:sub(2):lower(), classFile
    end
    -- The .toc's "## Key: value" lines (handed over by run.mjs): through
    -- C_AddOns, or the global on older clients (opts.noAddOnsAPI).
    local function getMetadata(name, key)
        if name == "FeedPetEmotes" then return TOC_METADATA[key] end
    end
    if opts.noAddOnsAPI then
        C_AddOns, GetAddOnMetadata = nil, getMetadata
    else
        C_AddOns, GetAddOnMetadata = { GetAddOnMetadata = getMetadata }, nil
    end
    function UnitSex()
        return client.pet and client.pet.sex
    end
    function UnitCreatureFamily()
        if not client.pet then return nil end
        return client.pet.family, client.pet.familyID
    end
    -- client.inCombat: whether the player is in combat (protected actions blocked).
    function InCombatLockdown()
        return client.inCombat == true
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

    -- How often each API was called, for tests about the cost of a bag scan.
    client.calls = { GetContainerItemInfo = 0 }

    C_Item = {
        GetItemInfo = function(itemID)
            if not ITEM_NAMES[itemID] then return nil end
            return ITEM_NAMES[itemID], ItemLink(itemID)
        end,
        -- Carried bags only, like the real default (includeBank false).
        GetItemCount = function(itemID)
            local total = 0
            for _, item in ipairs(client.bag) do
                if item.itemID == itemID then total = total + item.count end
            end
            return total
        end,
    }
    C_Container = {
        UseContainerItem = function() end,
        GetContainerNumSlots = function(bag)
            return bag == 0 and #client.bag or 0
        end,
        GetContainerItemID = function(bag, slot)
            local item = bag == 0 and client.bag[slot]
            return item and item.itemID or nil
        end,
        -- The real API builds a new table for every call.
        GetContainerItemInfo = function(bag, slot)
            client.calls.GetContainerItemInfo = client.calls.GetContainerItemInfo + 1
            local item = bag == 0 and client.bag[slot]
            if not item then return nil end
            return { itemID = item.itemID, stackCount = item.count }
        end,
    }
    function wipe(tbl)
        for key in pairs(tbl) do
            tbl[key] = nil
        end
        return tbl
    end
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

    -- Layout calls only matter to the real UI; they do nothing here. A region
    -- keeps its text and whether it is shown, so tests can read the panel.
    local function noop() end
    local function newRegion()
        local region = { shown = true }
        for _, method in ipairs({
            "SetPoint",
            "SetAllPoints",
            "SetColorTexture",
            "SetFontObject",
            "SetSize",
            "SetHeight",
            "SetScrollChild",
            "SetJustifyH",
            "SetWordWrap",
            "SetAutoFocus",
            "SetMaxBytes",
            "ClearFocus",
            "HighlightText",
            "SetCursorPosition",
        }) do
            region[method] = noop
        end
        function region:SetWidth(width)
            self.width = width
        end
        -- Not `text`: that is the label's parentKey on older CheckButtons.
        function region:SetText(text)
            self.shownText = text
        end
        function region:GetText()
            return self.shownText
        end
        function region:Show()
            self.shown = true
        end
        function region:Hide()
            self.shown = false
        end
        function region:IsShown()
            return self.shown
        end
        return region
    end

    client.fontStrings = {}

    ---A frame records its events and scripts; a CheckButton also its checked
    ---state, and comes with the label UICheckButtonTemplate gives it.
    function CreateFrame(kind, _, parent, template)
        local frame = newRegion()
        frame.kind, frame.parent, frame.template = kind, parent, template
        frame.events, frame.unitEvents, frame.scripts = {}, {}, {}
        function frame:RegisterEvent(event)
            self.events[event] = true
        end
        function frame:UnregisterEvent(event)
            self.events[event] = nil
        end
        function frame:RegisterUnitEvent(event, unit)
            self.unitEvents[event] = unit
        end
        function frame:SetScript(script, handler)
            self.scripts[script] = handler
            if script == "OnEvent" then self.onEvent = handler end
        end
        function frame:CreateFontString()
            local region = newRegion()
            region.parent = self
            client.fontStrings[#client.fontStrings + 1] = region
            return region
        end
        function frame:CreateTexture()
            return newRegion()
        end
        -- UIPanelScrollFrameTemplate comes with its scroll bar as a parentKey.
        if template == "UIPanelScrollFrameTemplate" then frame.ScrollBar = CreateFrame("Frame", nil, frame) end
        -- Like OptionsSliderTemplate on newer clients: labels as parentKeys.
        -- SetValue reports a change through OnValueChanged, as the client does.
        if kind == "Slider" then
            frame.Text, frame.Low, frame.High = newRegion(), newRegion(), newRegion()
            frame.SetMinMaxValues, frame.SetValueStep, frame.SetObeyStepOnDrag = noop, noop, noop
            function frame:SetValue(value)
                if value == self.value then return end
                self.value = value
                if self.scripts.OnValueChanged then self.scripts.OnValueChanged(self, value) end
            end
            function frame:GetValue()
                return self.value
            end
        end
        if kind == "CheckButton" then
            frame.Text = newRegion()
            function frame:SetChecked(checked)
                self.checked = checked and true or false
            end
            -- Like the older clients: 1 or nil rather than a boolean.
            function frame:GetChecked()
                return self.checked and 1 or nil
            end
        end
        client.frames[#client.frames + 1] = frame
        return frame
    end

    -- The shared tooltip: who owns it, its text, and whether it is shown.
    GameTooltip = newRegion()
    GameTooltip.shown = false
    function GameTooltip:SetOwner(owner)
        self.owner = owner
    end

    -- The game's settings window: which panel was registered, how often it was opened.
    client.optionsOpened = 0
    local category = {
        GetID = function()
            return 42
        end,
    }
    Settings = {
        RegisterCanvasLayoutCategory = function(panel, name)
            client.optionsPanel, client.optionsName = panel, name
            return category
        end,
        RegisterAddOnCategory = function(registered)
            client.optionsRegistered = registered == category
        end,
        OpenToCategory = function(id)
            if id == 42 then client.optionsOpened = client.optionsOpened + 1 end
        end,
    }

    SlashCmdList = {}
    -- Seeded under the names the .toc declares, as the client would.
    _G[TOC_SAVED_PER_CHARACTER] = opts.savedDB
    _G[TOC_SAVED_PER_ACCOUNT] = opts.savedAccountDB

    local E = {}
    for _, file in ipairs(TOC_FILES) do
        local chunk = assert(loadfile(ROOT .. "/" .. file))
        chunk("FeedPetEmotes", E)
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
        self:fire("ADDON_LOADED", "FeedPetEmotes")
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
        SlashCmdList.FEEDPETEMOTES(message)
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

---The account-wide saved settings, under the name the .toc declares.
---@return table
function SavedAccount()
    return _G[TOC_SAVED_PER_ACCOUNT]
end

-- fengari is Lua 5.3; WoW's Lua 5.1 has a global unpack.
unpack = unpack or table.unpack
