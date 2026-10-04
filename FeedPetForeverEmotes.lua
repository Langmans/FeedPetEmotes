local addonName, E = ...
local L = E.L

local FEED_PET_SPELL = 6991
-- How long after an item is picked the Feed Pet cast may still claim it as the food.
local FOOD_WINDOW = 3

local lastFood, lastFoodTime
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
    local foodName = itemID and C_Item.GetItemInfo(itemID)
    local text = foodName and E.Format("FEED", pet, foodName) or E.Format("FEED_NO_FOOD", pet)
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

-- Feed Pet asks for an item; both clicking food in a bag and a secure button's
-- target-bag/target-slot end up in C_Container.UseContainerItem while the spell
-- is waiting for its target. That is the only place the chosen food is visible.
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
    seenCastTime = GetTime()
    local itemID = lastFood and GetTime() - lastFoodTime <= FOOD_WINDOW and lastFood or nil
    lastFood = nil
    debug("Feed Pet cast seen; food " .. (itemID and ("item " .. itemID) or "unknown"))
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
