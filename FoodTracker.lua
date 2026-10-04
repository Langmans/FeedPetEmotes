local _, E = ...

-- Which food a Feed Pet cast used. The food is seen in one of three ways, and
-- the cast then claims it (Claim), in this order of priority:
-- - targeted: Feed Pet is cast first and waits for an item; clicking food in a
--   bag or a secure target-bag/target-slot button (Feed Pet: Forever) ends up
--   in C_Container.UseContainerItem (OnTargeted, from a hook).
-- - cursor: the food is picked up (dragged, or clicked in a bag) and dropped on
--   the pet or its frame. Where it is dropped may involve no Lua at all, so the
--   cursor is watched instead: the item last on it, let go of shortly before the
--   cast, is the food (OnCursorChanged).
-- - eaten: some bag buttons hand a targeted click to the client without any
--   Lua call (seen with Feed Pet cast from the spellbook and EllesmereUIBags).
--   What remains is the food leaving the bags: item counts are kept per
--   BAG_UPDATE_DELAYED, and the item whose count dropped is the food
--   (OnBagsUpdated). The bags may update just before or just after the cast is
--   reported, so a cast with no other sign waits up to EATEN_WINDOW for them
--   (WaitForBags).
--
-- The one tracker lives in E.FoodTracker; all of its state is on it.

local Debug, Public = E.Debug, E.Public

-- How long after an item is picked (or let go of) a cast may still claim it.
local FOOD_WINDOW = 3
-- How long an item that left the bags counts as eaten, before or after the cast.
local EATEN_WINDOW = 1

---@class FoodTracker
---@field targetedFood number?
---@field targetedAt number?
---@field cursorFood number?
---@field cursorReleasedAt number?
---@field bagCounts table<number, number>?
---@field eatenFood number?
---@field eatenAt number?
---@field onEaten fun(itemID: number?)?
---@field seenFood number?
---@field seenFoodTime number?
---@field seenCastTime number?
local Tracker = {
    -- targeted
    targetedFood = nil,
    targetedAt = nil,
    -- cursor
    cursorFood = nil,
    cursorReleasedAt = nil, -- nil while the item is still on the cursor
    -- eaten
    bagCounts = nil, -- itemID -> count in the bags, as of the last bag update
    eatenFood = nil,
    eatenAt = nil,
    onEaten = nil, -- callback of a cast waiting for the bags
    -- For /fpfe selftest: what was last seen.
    seenFood = nil,
    seenFoodTime = nil,
    seenCastTime = nil,
}
E.FoodTracker = Tracker

---Item counts over all carried bags; items with a secret ID or count are left out.
---@return table<number, number>
local function countBags()
    local counts = {}
    for bag = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS or NUM_BAG_SLOTS or 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local item = C_Container.GetContainerItemInfo(bag, slot)
            if item and Public(item.itemID) and Public(item.stackCount) then
                counts[item.itemID] = (counts[item.itemID] or 0) + item.stackCount
            end
        end
    end
    return counts
end

---A bag item was used; it is the food only while a spell waits for an item target.
---@param bag number
---@param slot number
function Tracker:OnTargeted(bag, slot)
    if not (SpellIsTargeting and SpellIsTargeting()) then return end
    local item = C_Container.GetContainerItemInfo(bag, slot)
    if item and Public(item.itemID) then
        self.targetedFood, self.targetedAt = item.itemID, GetTime()
        self.seenFood, self.seenFoodTime = self.targetedFood, self.targetedAt
        Debug(string.format("food picked: item %d (bag %s, slot %s)", item.itemID, bag, slot))
    else
        Debug("food picked, but its item ID is unavailable")
    end
end

---Remember the item while it is held on the cursor, and when it was let go.
function Tracker:OnCursorChanged()
    local kind, itemID = GetCursorInfo()
    if kind == "item" then
        -- For an item, GetCursorInfo's second return is always the item ID.
        ---@cast itemID number
        if Public(itemID) then
            self.cursorFood, self.cursorReleasedAt = itemID, nil
            Debug("item on cursor: item " .. itemID)
        else
            self.cursorFood = nil
            Debug("item on cursor, but its item ID is unavailable")
        end
    elseif self.cursorFood and not self.cursorReleasedAt then
        self.cursorReleasedAt = GetTime()
        Debug("cursor released: item " .. self.cursorFood)
    end
end

---Compare the bags with the previous count; a waiting cast takes the item
---that went down.
function Tracker:OnBagsUpdated()
    local counts = countBags()
    for itemID, before in pairs(self.bagCounts or {}) do
        if (counts[itemID] or 0) < before then
            self.eatenFood, self.eatenAt = itemID, GetTime()
            Debug("item gone from bags: item " .. itemID)
        end
    end
    self.bagCounts = counts
    if self.onEaten and self.eatenFood then
        local onEaten, itemID = self.onEaten, self.eatenFood
        self.onEaten, self.eatenFood = nil, nil
        self.seenFood, self.seenFoodTime = itemID, GetTime()
        Debug("food eaten: item " .. itemID)
        onEaten(itemID)
    end
end

---The food this Feed Pet cast used, if it can be told; forgets it either way.
---@return number? itemID
---@return string? how "targeted", "cursor" or "eaten"
function Tracker:Claim()
    local now, itemID, how = GetTime(), nil, nil
    self.seenCastTime = now
    if self.targetedFood and now - self.targetedAt <= FOOD_WINDOW then
        itemID, how = self.targetedFood, "targeted"
    elseif self.cursorFood and (not self.cursorReleasedAt or now - self.cursorReleasedAt <= FOOD_WINDOW) then
        itemID, how = self.cursorFood, "cursor"
    elseif self.eatenFood and now - self.eatenAt <= EATEN_WINDOW then
        itemID, how = self.eatenFood, "eaten"
    end
    self.targetedFood, self.cursorFood, self.eatenFood = nil, nil, nil
    if itemID then
        self.seenFood, self.seenFoodTime = itemID, now
    end
    return itemID, how
end

---No other sign of the food: wait for the bags. onFood is called exactly once,
---with the item that left the bags, or with nil after EATEN_WINDOW.
---@param onFood fun(itemID: number?)
function Tracker:WaitForBags(onFood)
    Debug("Feed Pet cast seen; food unknown, waiting for the bags")
    self.onEaten = onFood
    C_Timer.After(EATEN_WINDOW, function()
        if self.onEaten ~= onFood then return end
        self.onEaten = nil
        Debug("no food left the bags; sending without it")
        onFood(nil)
    end)
end
