local _, E = ...

-- /fpfe and its subcommands, including the selftest. Settings are read from
-- E.db, which exists once the addon has loaded (before anyone can type).

local L, Print, Public = E.L, E.Print, E.Public

-- Diagnostics are English on purpose: they are meant to be pasted into a bug report.
local function selftest()
    local db, tracker = E.db, E.FoodTracker
    local version, build, _, interface = GetBuildInfo()
    Print(
        string.format(
            "Client %s (%s), interface %s, locale %s, using %s.",
            version,
            build,
            interface,
            GetLocale(),
            E.LocaleCode
        )
    )
    local _, how = E.SendFunction()
    Print(
        string.format(
            "Emotes %s; send function: %s; secret values: %s.",
            db.enabled and "on" or "off",
            how,
            issecretvalue and "yes" or "no"
        )
    )
    local isKnown = C_SpellBook and C_SpellBook.IsSpellKnown or IsSpellKnown
    Print("Feed Pet known: " .. (isKnown and tostring(isKnown(E.FEED_PET_SPELL)) or "cannot check"))
    Print("Pronouns: " .. (db.petName and "always the pet's name" or "from the pet's sex, else its name") .. ".")

    if not UnitExists("pet") then
        Print("No pet out; summon one and run /fpfe selftest again.")
    else
        local name = UnitName("pet")
        local family, familyID = UnitCreatureFamily("pet")
        local function show(value)
            if not Public(value) then return "<secret>" end
            return tostring(value)
        end
        Print(
            string.format(
                "Pet %s: family %s, id %s, sex %s.",
                show(name),
                show(family),
                show(familyID),
                show(UnitSex("pet"))
            )
        )
        local familyLines = Public(familyID) and E.Emotes.family[familyID]
        Print(
            string.format(
                "Family lines: %d; lines without food: %d.",
                familyLines and #familyLines or 0,
                #E.EmotePool(nil)
            )
        )
    end

    if tracker.seenFood then
        local foodName = C_Item.GetItemInfo(tracker.seenFood)
        Print(
            string.format(
                "Last food picked: item %d (%s), %.0fs ago.",
                tracker.seenFood,
                foodName or "?",
                GetTime() - tracker.seenFoodTime
            )
        )
    else
        Print("No food picked since login; feed your pet once and run /fpfe selftest again.")
    end
    if tracker.seenCastTime then
        Print(string.format("Last Feed Pet cast seen %.0fs ago.", GetTime() - tracker.seenCastTime))
    else
        Print("No Feed Pet cast seen since login.")
    end
end

SLASH_FEEDPETFOREVEREMOTES1 = "/fpfe"
SLASH_FEEDPETFOREVEREMOTES2 = "/feedpetforeveremotes"
SlashCmdList.FEEDPETFOREVEREMOTES = function(message)
    local db = E.db
    local cmd, arg = (message or ""):lower():match("^%s*(%S*)%s*(%S*)")
    cmd, arg = cmd or "", arg or ""
    if cmd == "on" or cmd == "off" then
        db.enabled = cmd == "on"
        Print(db.enabled and L.EMOTES_ON or L.EMOTES_OFF)
    elseif cmd == "test" then
        -- Local preview only; nothing is sent to chat.
        local text = E.BuildEmote(12037)
        Print(text and ("|cffff8040" .. (UnitName("player") or L.YOU) .. " " .. text .. "|r") or L.NO_PET)
    elseif cmd == "name" and (arg == "on" or arg == "off") then
        db.petName = arg == "on"
        Print(db.petName and L.PET_NAME_ON or L.PET_NAME_OFF)
    elseif cmd == "selftest" then
        selftest()
    elseif cmd == "debug" then
        db.debug = not db.debug
        Print("Debug " .. (db.debug and "on." or "off."))
    else
        Print(E.Format("STATUS", db.enabled and L.STATUS_ON or L.STATUS_OFF))
    end
end
