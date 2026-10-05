local _, E = ...

-- /fpe selftest: what the client reports to the addon, for bug reports.
-- English on purpose: the output is meant to be pasted into an issue.

local Print, Public = E.Print, E.Public

---Prints the client, settings, pet and the last food and cast the tracker saw.
function E.SelfTest()
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
    Print(
        string.format(
            "Own lines: %d (%s).",
            #db.customLines,
            db.customOnly and "used instead of the built-in lines" or "mixed with the built-in lines"
        )
    )

    if not UnitExists("pet") then
        Print("No pet out; summon one and run /fpe selftest again.")
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
        Print("No food picked since login; feed your pet once and run /fpe selftest again.")
    end
    if tracker.seenCastTime then
        Print(string.format("Last Feed Pet cast seen %.0fs ago.", GetTime() - tracker.seenCastTime))
    else
        Print("No Feed Pet cast seen since login.")
    end
end
