local _, E = ...

-- /fpe and its subcommands. Commands: one function per subcommand, named
-- after it (lower case) and called with what was typed after it; the slash
-- handler only splits the message and looks the subcommand up, the same way
-- the event frame in FeedPetEmotes.lua dispatches events. Anything it does not
-- know shows the status line with the list of commands. Settings are read
-- from E.db, which exists once the addon has loaded (before anyone can type).

local L, Print = E.L, E.Print

---The first word of what was typed after the subcommand, lower case.
---@param rest string
---@return string
local function firstWord(rest)
    return rest:lower():match("^%S*") or ""
end

---"on" -> true, "off" -> false, anything else nil.
---@param rest string
---@return boolean?
local function onOff(rest)
    local word = firstWord(rest)
    if word == "on" then return true end
    if word == "off" then return false end
    return nil
end

local function status()
    if not E.isHunter then Print(L.NOT_HUNTER) end
    Print(E.Format("STATUS", E.db.enabled and L.STATUS_ON or L.STATUS_OFF))
end

---@type table<string, fun(rest: string)>
local Commands = {}

function Commands.on()
    E.db.enabled = true
    Print(L.EMOTES_ON)
end

function Commands.off()
    E.db.enabled = false
    Print(L.EMOTES_OFF)
end

---/fpe name on|off
function Commands.name(rest)
    local on = onOff(rest)
    if on == nil then return status() end
    E.db.petName = on
    Print(on and L.PET_NAME_ON or L.PET_NAME_OFF)
end

---/fpe add <line>: rest keeps the case it was typed in.
function Commands.add(rest)
    local added, result = E.AddCustomLine(rest)
    Print(added and E.Format("CUSTOM_ADDED", #E.CustomLines(), result) or result)
end

---/fpe list: the player's own lines, numbered for /fpe remove.
function Commands.list()
    local lines = E.CustomLines()
    if #lines == 0 then
        Print(L.CUSTOM_NONE)
        return
    end
    Print(E.Format("CUSTOM_LIST", #lines))
    for i, line in ipairs(lines) do
        Print(i .. ". " .. line)
    end
end

---/fpe remove <number>
function Commands.remove(rest)
    local word = firstWord(rest)
    local line = E.RemoveCustomLine(tonumber(word))
    Print(line and E.Format("CUSTOM_REMOVED", line) or E.Format("CUSTOM_NO_SUCH", word))
end

---/fpe fallback on|off: a built-in line, or none, when an own line is
---wanted but none fits.
function Commands.fallback(rest)
    local on = onOff(rest)
    if on == nil then return status() end
    E.db.customFallback = on
    Print(on and L.FALLBACK_ON or L.FALLBACK_OFF)
end

---/fpe shared on|off: the account-wide lines or this character's own.
function Commands.shared(rest)
    local on = onOff(rest)
    if on == nil then return status() end
    E.db.sharedLines = on
    Print(E.Format(on and "SHARED_ON" or "SHARED_OFF", #E.CustomLines()))
end

---/fpe chance <0-100>: the share of emotes that take an own line; 0 lets
---every line count the same.
function Commands.chance(rest)
    local percent = tonumber(firstWord(rest):match("^(%d+)%%?$"))
    if not percent or percent > 100 then
        Print(L.CHANCE_BAD)
        return
    end
    E.db.customChance = percent
    Print(percent == 0 and L.CHANCE_EVEN or E.Format("CHANCE_SET", percent))
end

---Local preview only; nothing is sent to chat.
function Commands.test()
    local text = E.BuildEmote(12037)
    Print(text and ("|cffff8040" .. (UnitName("player") or L.YOU) .. " " .. text .. "|r") or L.NO_PET)
end

function Commands.config()
    E.OpenOptions()
end
Commands.options = Commands.config

function Commands.selftest()
    E.SelfTest()
end

function Commands.debug()
    E.db.debug = not E.db.debug
    Print("Debug " .. (E.db.debug and "on." or "off."))
end

SLASH_FEEDPETEMOTES1 = "/fpe"
SLASH_FEEDPETEMOTES2 = "/feedpetemotes"
SlashCmdList.FEEDPETEMOTES = function(message)
    local name, rest = (message or ""):match("^%s*(%S*)%s*(.-)%s*$")
    local command = Commands[(name or ""):lower()]
    if command then
        command(rest or "")
    else
        status()
    end
end
