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
    Print(added and E.Format("CUSTOM_ADDED", #E.db.customLines, result) or result)
end

---/fpe list: the player's own lines, numbered for /fpe remove.
function Commands.list()
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

---/fpe remove <number>
function Commands.remove(rest)
    local word = firstWord(rest)
    local line = E.RemoveCustomLine(tonumber(word))
    Print(line and E.Format("CUSTOM_REMOVED", line) or E.Format("CUSTOM_NO_SUCH", word))
end

---/fpe only on|off
function Commands.only(rest)
    local on = onOff(rest)
    if on == nil then return status() end
    E.db.customOnly = on
    Print(on and L.CUSTOM_ONLY_ON or L.CUSTOM_ONLY_OFF)
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
