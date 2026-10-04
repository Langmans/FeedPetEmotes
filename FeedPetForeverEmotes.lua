local addonName, E = ...
local L = E.L

local FEED_PET_SPELL = 6991
-- How long after an item is picked the Feed Pet cast may still claim it as the food.
local FOOD_WINDOW = 3

local lastFood, lastFoodTime

local function public(value)
    return not issecretvalue or not issecretvalue(value)
end

local function print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffcc66" .. L.CHAT_PREFIX .. "|r " .. message)
end

local function append(pool, list)
    if type(list) ~= "table" then return end
    for _, line in ipairs(list) do
        pool[#pool + 1] = line
    end
end

local function randomLine(itemID)
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
    -- The family ID is the same on every client language; the name is not.
    local _, familyID = UnitCreatureFamily("pet")
    if familyID and public(familyID) then append(pool, emotes.family[familyID]) end
    return pool[math.random(#pool)]
end

local function buildEmote(itemID)
    local pet = UnitName("pet")
    if not pet or not public(pet) then return end
    local foodName = itemID and C_Item.GetItemInfo(itemID)
    local text = foodName and E.Format("FEED", pet, foodName) or E.Format("FEED_NO_FOOD", pet)
    return text .. randomLine(itemID)
end

local function send(text)
    local sendChat = C_ChatInfo and C_ChatInfo.SendChatMessage or SendChatMessage
    sendChat(text, "EMOTE")
end

-- Feed Pet asks for an item; both clicking food in a bag and a secure button's
-- target-bag/target-slot end up in C_Container.UseContainerItem while the spell
-- is waiting for its target. That is the only place the chosen food is visible.
hooksecurefunc(C_Container, "UseContainerItem", function(bag, slot)
    if not (SpellIsTargeting and SpellIsTargeting()) then return end
    local item = C_Container.GetContainerItemInfo(bag, slot)
    if item and public(item.itemID) then
        lastFood, lastFoodTime = item.itemID, GetTime()
    end
end)

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, event, arg1, _, arg3)
    if event == "ADDON_LOADED" then
        if arg1 ~= addonName then return end
        frame:UnregisterEvent("ADDON_LOADED")
        if type(FeedPetForeverEmotesDB) ~= "table" then FeedPetForeverEmotesDB = {} end
        if type(FeedPetForeverEmotesDB.enabled) ~= "boolean" then FeedPetForeverEmotesDB.enabled = true end
        frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
        return
    end
    -- UNIT_SPELLCAST_SUCCEEDED: unit, castGUID, spellID
    if not public(arg3) or arg3 ~= FEED_PET_SPELL then return end
    local itemID = lastFood and GetTime() - lastFoodTime <= FOOD_WINDOW and lastFood or nil
    lastFood = nil
    if not FeedPetForeverEmotesDB.enabled then return end
    local text = buildEmote(itemID)
    if text then send(text) end
end)

SLASH_FEEDPETFOREVEREMOTES1 = "/fpfe"
SLASH_FEEDPETFOREVEREMOTES2 = "/feedpetforeveremotes"
SlashCmdList.FEEDPETFOREVEREMOTES = function(message)
    local cmd = ((message or ""):match("^%s*(%S*)") or ""):lower()
    if cmd == "on" or cmd == "off" then
        FeedPetForeverEmotesDB.enabled = cmd == "on"
        print(FeedPetForeverEmotesDB.enabled and L.EMOTES_ON or L.EMOTES_OFF)
    elseif cmd == "test" then
        -- Local preview only; nothing is sent to chat.
        local text = buildEmote(12037)
        print(text and ("|cffff8040" .. (UnitName("player") or L.YOU) .. " " .. text .. "|r") or L.NO_PET)
    else
        print(E.Format("STATUS", FeedPetForeverEmotesDB.enabled and L.STATUS_ON or L.STATUS_OFF))
    end
end
