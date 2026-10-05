local _, E = ...

-- /fpe and its subcommands, including the selftest. Settings are read from
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

---/fpe list: the player's own lines, numbered for /fpe remove.
local function listCustomLines()
    local lines = E.db.customLines
    if #lines == 0 then
        Print(L.CUSTOM_NONE)
        return
    end
    Print(E.Format("CUSTOM_LIST", #lines, E.db.customOnly and L.CUSTOM_LIST_ONLY or L.CUSTOM_LIST_MIXED))
    for i, line in ipairs(lines) do
        Print(i .. ". " .. line)
    end
end

SLASH_FEEDPETEMOTES1 = "/fpe"
SLASH_FEEDPETEMOTES2 = "/feedpetemotes"
SlashCmdList.FEEDPETEMOTES = function(message)
    local db = E.db
    -- rest keeps its case: it is the line for /fpe add.
    local cmd, rest = (message or ""):match("^%s*(%S*)%s*(.-)%s*$")
    cmd = (cmd or ""):lower()
    rest = rest or ""
    local arg = rest:lower():match("^%S*")
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
    elseif cmd == "add" then
        local added, result = E.AddCustomLine(rest)
        Print(added and E.Format("CUSTOM_ADDED", #db.customLines, result) or result)
    elseif cmd == "list" then
        listCustomLines()
    elseif cmd == "remove" then
        local index = tonumber(arg)
        local line = E.RemoveCustomLine(index)
        Print(line and E.Format("CUSTOM_REMOVED", line) or E.Format("CUSTOM_NO_SUCH", arg))
    elseif cmd == "only" and (arg == "on" or arg == "off") then
        db.customOnly = arg == "on"
        Print(db.customOnly and L.CUSTOM_ONLY_ON or L.CUSTOM_ONLY_OFF)
    elseif cmd == "config" or cmd == "options" then
        E.OpenOptions()
    elseif cmd == "selftest" then
        selftest()
    elseif cmd == "debug" then
        db.debug = not db.debug
        Print("Debug " .. (db.debug and "on." or "off."))
    else
        Print(E.Format("STATUS", db.enabled and L.STATUS_ON or L.STATUS_OFF))
    end
end
