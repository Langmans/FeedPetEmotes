local addonName, E = ...
local L = E.L

local FEED_PET_SPELL = 6991
-- How long after an item is picked (or let go of) the Feed Pet cast may still
-- claim it as the food.
local FOOD_WINDOW = 3

-- The food is seen in one of two ways, and the cast event then claims it:
-- - targeted: Feed Pet is cast first and waits for an item; clicking food in a
--   bag or a secure target-bag/target-slot button (Feed Pet: Forever) ends up
--   in C_Container.UseContainerItem.
-- - on the cursor: the food is picked up (dragged, or clicked in a bag) and
--   dropped on the pet or its frame. Where it is dropped may involve no Lua at
--   all, so CURSOR_CHANGED is watched instead: the item that was last on the
--   cursor, let go of shortly before the cast, is the food.
-- A targeted item wins, since it is chosen while Feed Pet is already waiting.
local lastFood, lastFoodTime
local cursorFood, cursorReleasedAt
-- Only for /fpfe selftest: what the hook and the cast event last saw.
local seenFood, seenFoodTime, seenCastTime

local function public(value)
    return not issecretvalue or not issecretvalue(value)
end

local function print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffcc66" .. L.CHAT_PREFIX .. "|r " .. message)
end

-- /fpfe debug traces the feeding path in chat; off on every load.
local function debug(message)
    if E.debug then print("|cff88ccff[debug]|r " .. message) end
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
    return text .. pool[math.random(#pool)]
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

-- Food on the cursor: remember the item while it is held, and when it was let go.
local function onCursorChanged()
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

---The food this Feed Pet cast used, if it can be told; forgets it either way.
---@return number? itemID
---@return string? how "targeted" or "cursor"
local function claimFood()
    local now, itemID, how = GetTime(), nil, nil
    if lastFood and now - lastFoodTime <= FOOD_WINDOW then
        itemID, how = lastFood, "targeted"
    elseif cursorFood and (not cursorReleasedAt or now - cursorReleasedAt <= FOOD_WINDOW) then
        itemID, how = cursorFood, "cursor"
    end
    lastFood, cursorFood = nil, nil
    if itemID then
        seenFood, seenFoodTime = itemID, now
    end
    return itemID, how
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, event, arg1, _, arg3)
    if event == "ADDON_LOADED" then
        if arg1 ~= addonName then return end
        frame:UnregisterEvent("ADDON_LOADED")
        if type(FeedPetForeverEmotesDB) ~= "table" then FeedPetForeverEmotesDB = {} end
        if type(FeedPetForeverEmotesDB.enabled) ~= "boolean" then FeedPetForeverEmotesDB.enabled = true end
        frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
        frame:RegisterEvent("CURSOR_CHANGED")
        return
    end
    if event == "CURSOR_CHANGED" then
        onCursorChanged()
        return
    end
    -- UNIT_SPELLCAST_SUCCEEDED: unit, castGUID, spellID
    if not public(arg3) or arg3 ~= FEED_PET_SPELL then return end
    seenCastTime = GetTime()
    local itemID, source = claimFood()
    debug("Feed Pet cast seen; food " .. (itemID and ("item " .. itemID .. " (" .. source .. ")") or "unknown"))
    if not FeedPetForeverEmotesDB.enabled then return end
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
end)

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
            FeedPetForeverEmotesDB.enabled and "on" or "off",
            how,
            issecretvalue and "yes" or "no"
        )
    )
    local isKnown = C_SpellBook and C_SpellBook.IsSpellKnown or IsSpellKnown
    print("Feed Pet known: " .. (isKnown and tostring(isKnown(FEED_PET_SPELL)) or "cannot check"))

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
    local cmd = ((message or ""):match("^%s*(%S*)") or ""):lower()
    if cmd == "on" or cmd == "off" then
        FeedPetForeverEmotesDB.enabled = cmd == "on"
        print(FeedPetForeverEmotesDB.enabled and L.EMOTES_ON or L.EMOTES_OFF)
    elseif cmd == "test" then
        -- Local preview only; nothing is sent to chat.
        local text = E.BuildEmote(12037)
        print(text and ("|cffff8040" .. (UnitName("player") or L.YOU) .. " " .. text .. "|r") or L.NO_PET)
    elseif cmd == "selftest" then
        selftest()
    elseif cmd == "debug" then
        E.debug = not E.debug
        print("Debug " .. (E.debug and "on." or "off."))
    else
        print(E.Format("STATUS", FeedPetForeverEmotesDB.enabled and L.STATUS_ON or L.STATUS_OFF))
    end
end
