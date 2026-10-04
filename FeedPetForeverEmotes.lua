local addonName, E = ...
local L = E.L

local FEED_PET_SPELL = 6991
-- How long after an item is picked (or let go of) the Feed Pet cast may still
-- claim it as the food.
local FOOD_WINDOW = 3
-- How long an item that left the bags counts as eaten, before or after the cast.
local EATEN_WINDOW = 1

-- The food is seen in one of three ways, and the cast event then claims it:
-- - targeted: Feed Pet is cast first and waits for an item; clicking food in a
--   bag or a secure target-bag/target-slot button (Feed Pet: Forever) ends up
--   in C_Container.UseContainerItem.
-- - on the cursor: the food is picked up (dragged, or clicked in a bag) and
--   dropped on the pet or its frame. Where it is dropped may involve no Lua at
--   all, so CURSOR_CHANGED is watched instead: the item that was last on the
--   cursor, let go of shortly before the cast, is the food.
-- - eaten: some bag buttons hand a targeted click to the client without any
--   Lua call (seen with Feed Pet cast from the spellbook and EllesmereUIBags).
--   What remains is the food leaving the bags: item counts are kept per
--   BAG_UPDATE_DELAYED, and the item whose count dropped is the food. The
--   bags may update just before or just after the cast is reported, so a cast
--   with no other food known waits up to EATEN_WINDOW for them.
-- The order is also the priority: targeted, cursor, eaten.
local lastFood, lastFoodTime
local cursorFood, cursorReleasedAt
local bagCounts -- itemID -> count in the bags, as of the last BAG_UPDATE_DELAYED
local eatenFood, eatenAt
local waitingCast -- true while a Feed Pet cast waits for the bags
-- Only for /fpfe selftest: what the hook and the cast event last saw.
local seenFood, seenFoodTime, seenCastTime

local function public(value)
    return not issecretvalue or not issecretvalue(value)
end

local function print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffcc66" .. L.CHAT_PREFIX .. "|r " .. message)
end

-- /fpfe debug traces the feeding path in chat; the setting is saved per character.
local function debug(message)
    if FeedPetForeverEmotesDBPC and FeedPetForeverEmotesDBPC.debug then print("|cff88ccff[debug]|r " .. message) end
end

local function append(pool, list)
    if type(list) ~= "table" then return end
    for _, line in ipairs(list) do
        pool[#pool + 1] = line
    end
end

---Every emote line that applies to feeding the current pet this item.
---@param itemID number?
---@return string[]
function E.EmotePool(itemID)
    local emotes, pool = E.Emotes, {}
    append(pool, emotes.any)
    local sex = UnitSex("pet")
    if sex == 2 then
        append(pool, emotes.male)
    elseif sex == 3 then
        append(pool, emotes.female)
    end
    local group = itemID and E.FoodGroups[itemID]
    if group then append(pool, emotes.food[group]) end
    local foodType = itemID and E.FoodTypes[itemID]
    if foodType and emotes.foodType then append(pool, emotes.foodType[foodType]) end
    -- The family ID is the same on every client language; the name is not.
    local _, familyID = UnitCreatureFamily("pet")
    if familyID and public(familyID) then append(pool, emotes.family[familyID]) end
    return pool
end

---The full /emote text, or nil when the pet's name is unavailable.
---@param itemID number?
---@return string?
function E.BuildEmote(itemID)
    local pet = UnitName("pet")
    if not pet or not public(pet) then return end
    -- The chat link, so readers can click the food; the plain name if there is none.
    local food, link
    if itemID then
        food, link = C_Item.GetItemInfo(itemID)
    end
    food = link or food
    local text = food and E.Format("FEED", pet, food) or E.Format("FEED_NO_FOOD", pet)
    local pool = E.EmotePool(itemID)
    return text .. E.FillPlaceholders(pool[math.random(#pool)], pet)
end

---"male", "female", or nil when the pet's sex is unknown or the player asked
---for the pet's name instead (/fpfe name on).
---@return string?
local function pronounSex()
    if FeedPetForeverEmotesDBPC.petName then return nil end
    local sex = UnitSex("pet")
    if not public(sex) then return nil end
    return sex == 2 and "male" or sex == 3 and "female" or nil
end

---Replaces the placeholders in an emote line.
---{pet} is always the pet's name. Any other {token} is one of the locale's
---pronouns (E.Pronouns, e.g. {he} -> he/she); without a known sex, or for a
---token the locale does not define, it becomes the pet's name, which reads
---right in every language. Function replacements, so a % in the name is
---never read as a capture reference.
---@param line string
---@param pet string
---@return string
function E.FillPlaceholders(line, pet)
    local sex = pronounSex()
    local filled = line:gsub("{([^}]+)}", function(token)
        local words = token ~= "pet" and sex and E.Pronouns[token]
        return words and words[sex] or pet
    end)
    return filled
end

local function sendFunction()
    if C_ChatInfo and C_ChatInfo.SendChatMessage then
        return C_ChatInfo.SendChatMessage, "C_ChatInfo.SendChatMessage"
    end
    if SendChatMessage then return SendChatMessage, "SendChatMessage" end
    return nil, "missing"
end

-- Targeted food: see the comment at the top.
hooksecurefunc(C_Container, "UseContainerItem", function(bag, slot)
    if not (SpellIsTargeting and SpellIsTargeting()) then return end
    local item = C_Container.GetContainerItemInfo(bag, slot)
    if item and public(item.itemID) then
        lastFood, lastFoodTime = item.itemID, GetTime()
        seenFood, seenFoodTime = lastFood, lastFoodTime
        debug(string.format("food picked: item %d (bag %s, slot %s)", item.itemID, bag, slot))
    else
        debug("food picked, but its item ID is unavailable")
    end
end)

---Item counts over all carried bags; items with a secret ID or count are left out.
---@return table<number, number>
local function countBags()
    local counts = {}
    for bag = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS or NUM_BAG_SLOTS or 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local item = C_Container.GetContainerItemInfo(bag, slot)
            if item and public(item.itemID) and public(item.stackCount) then
                counts[item.itemID] = (counts[item.itemID] or 0) + item.stackCount
            end
        end
    end
    return counts
end

---The food this Feed Pet cast used, if it can be told; forgets it either way.
---@return number? itemID
---@return string? how "targeted", "cursor" or "eaten"
local function claimFood()
    local now, itemID, how = GetTime(), nil, nil
    if lastFood and now - lastFoodTime <= FOOD_WINDOW then
        itemID, how = lastFood, "targeted"
    elseif cursorFood and (not cursorReleasedAt or now - cursorReleasedAt <= FOOD_WINDOW) then
        itemID, how = cursorFood, "cursor"
    elseif eatenFood and now - eatenAt <= EATEN_WINDOW then
        itemID, how = eatenFood, "eaten"
    end
    lastFood, cursorFood, eatenFood = nil, nil, nil
    if itemID then
        seenFood, seenFoodTime = itemID, now
    end
    return itemID, how
end

---Sends the emote for one feeding, unless emotes are off.
---@param itemID number?
local function sendEmote(itemID)
    if not FeedPetForeverEmotesDBPC.enabled then return end
    local text = E.BuildEmote(itemID)
    if not text then
        debug("no emote: the pet's name is unavailable")
        return
    end
    local sendChat, how = sendFunction()
    if not sendChat then
        debug("no emote: no chat send function")
        return
    end
    debug("sending via " .. how)
    sendChat(text, "EMOTE")
end

-- No other sign of the food: wait for the bags, then send with or without it.
local function waitForBags()
    debug("Feed Pet cast seen; food unknown, waiting for the bags")
    waitingCast = true
    C_Timer.After(EATEN_WINDOW, function()
        if not waitingCast then return end
        waitingCast = false
        debug("no food left the bags; sending without it")
        sendEmote(nil)
    end)
end

-- Events: one method per event on this frame, named after the event and called
-- with the event's own arguments. Only ADDON_LOADED is registered up front; it
-- registers the rest once the saved settings are there.
local frame = CreateFrame("Frame")

function frame:ADDON_LOADED(name)
    if name ~= addonName then return end
    self:UnregisterEvent("ADDON_LOADED")
    if type(FeedPetForeverEmotesDBPC) ~= "table" then FeedPetForeverEmotesDBPC = {} end
    if type(FeedPetForeverEmotesDBPC.enabled) ~= "boolean" then FeedPetForeverEmotesDBPC.enabled = true end
    if type(FeedPetForeverEmotesDBPC.petName) ~= "boolean" then FeedPetForeverEmotesDBPC.petName = false end
    if type(FeedPetForeverEmotesDBPC.debug) ~= "boolean" then FeedPetForeverEmotesDBPC.debug = false end
    self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
    self:RegisterEvent("CURSOR_CHANGED")
    self:RegisterEvent("BAG_UPDATE_DELAYED")
end

-- Food on the cursor: remember the item while it is held, and when it was let go.
function frame:CURSOR_CHANGED()
    local kind, itemID = GetCursorInfo()
    if kind == "item" then
        if public(itemID) then
            cursorFood, cursorReleasedAt = itemID, nil
            debug("item on cursor: item " .. itemID)
        else
            cursorFood = nil
            debug("item on cursor, but its item ID is unavailable")
        end
    elseif cursorFood and not cursorReleasedAt then
        cursorReleasedAt = GetTime()
        debug("cursor released: item " .. cursorFood)
    end
end

-- Eaten food: compare the bags with the previous count; a waiting cast takes
-- the item that went down.
function frame:BAG_UPDATE_DELAYED()
    local counts = countBags()
    for itemID, before in pairs(bagCounts or {}) do
        if (counts[itemID] or 0) < before then
            eatenFood, eatenAt = itemID, GetTime()
            debug("item gone from bags: item " .. itemID)
        end
    end
    bagCounts = counts
    if waitingCast and eatenFood then
        waitingCast = false
        local itemID = eatenFood
        eatenFood = nil
        seenFood, seenFoodTime = itemID, GetTime()
        debug("food eaten: item " .. itemID)
        sendEmote(itemID)
    end
end

function frame:UNIT_SPELLCAST_SUCCEEDED(_, _, spellID)
    if not public(spellID) or spellID ~= FEED_PET_SPELL then return end
    seenCastTime = GetTime()
    local itemID, source = claimFood()
    if not itemID then
        waitForBags()
        return
    end
    debug("Feed Pet cast seen; food item " .. itemID .. " (" .. source .. ")")
    sendEmote(itemID)
end

frame:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)
frame:RegisterEvent("ADDON_LOADED")

-- Diagnostics are English on purpose: they are meant to be pasted into a bug report.
local function selftest()
    local version, build, _, interface = GetBuildInfo()
    print(
        string.format(
            "Client %s (%s), interface %s, locale %s, using %s.",
            version,
            build,
            interface,
            GetLocale(),
            E.LocaleCode
        )
    )
    local _, how = sendFunction()
    print(
        string.format(
            "Emotes %s; send function: %s; secret values: %s.",
            FeedPetForeverEmotesDBPC.enabled and "on" or "off",
            how,
            issecretvalue and "yes" or "no"
        )
    )
    local isKnown = C_SpellBook and C_SpellBook.IsSpellKnown or IsSpellKnown
    print("Feed Pet known: " .. (isKnown and tostring(isKnown(FEED_PET_SPELL)) or "cannot check"))
    print(
        "Pronouns: "
            .. (FeedPetForeverEmotesDBPC.petName and "always the pet's name" or "from the pet's sex, else its name")
            .. "."
    )

    if not UnitExists("pet") then
        print("No pet out; summon one and run /fpfe selftest again.")
    else
        local name = UnitName("pet")
        local family, familyID = UnitCreatureFamily("pet")
        local function show(value)
            if not public(value) then return "<secret>" end
            return tostring(value)
        end
        print(
            string.format(
                "Pet %s: family %s, id %s, sex %s.",
                show(name),
                show(family),
                show(familyID),
                show(UnitSex("pet"))
            )
        )
        local familyLines = public(familyID) and E.Emotes.family[familyID]
        print(
            string.format(
                "Family lines: %d; lines without food: %d.",
                familyLines and #familyLines or 0,
                #E.EmotePool(nil)
            )
        )
    end

    if seenFood then
        local foodName = C_Item.GetItemInfo(seenFood)
        print(
            string.format(
                "Last food picked: item %d (%s), %.0fs ago.",
                seenFood,
                foodName or "?",
                GetTime() - seenFoodTime
            )
        )
    else
        print("No food picked since login; feed your pet once and run /fpfe selftest again.")
    end
    if seenCastTime then
        print(string.format("Last Feed Pet cast seen %.0fs ago.", GetTime() - seenCastTime))
    else
        print("No Feed Pet cast seen since login.")
    end
end

SLASH_FEEDPETFOREVEREMOTES1 = "/fpfe"
SLASH_FEEDPETFOREVEREMOTES2 = "/feedpetforeveremotes"
SlashCmdList.FEEDPETFOREVEREMOTES = function(message)
    local cmd, arg = (message or ""):lower():match("^%s*(%S*)%s*(%S*)")
    cmd, arg = cmd or "", arg or ""
    if cmd == "on" or cmd == "off" then
        FeedPetForeverEmotesDBPC.enabled = cmd == "on"
        print(FeedPetForeverEmotesDBPC.enabled and L.EMOTES_ON or L.EMOTES_OFF)
    elseif cmd == "test" then
        -- Local preview only; nothing is sent to chat.
        local text = E.BuildEmote(12037)
        print(text and ("|cffff8040" .. (UnitName("player") or L.YOU) .. " " .. text .. "|r") or L.NO_PET)
    elseif cmd == "name" and (arg == "on" or arg == "off") then
        FeedPetForeverEmotesDBPC.petName = arg == "on"
        print(FeedPetForeverEmotesDBPC.petName and L.PET_NAME_ON or L.PET_NAME_OFF)
    elseif cmd == "selftest" then
        selftest()
    elseif cmd == "debug" then
        FeedPetForeverEmotesDBPC.debug = not FeedPetForeverEmotesDBPC.debug
        print("Debug " .. (FeedPetForeverEmotesDBPC.debug and "on." or "off."))
    else
        print(E.Format("STATUS", FeedPetForeverEmotesDBPC.enabled and L.STATUS_ON or L.STATUS_OFF))
    end
end
