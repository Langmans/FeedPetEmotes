-- Locale selection, the enUS fallback chain and the shape of every locale file.

local ALL_LOCALES = { "enUS", "deDE", "esES", "esMX", "frFR", "koKR", "ruRU" }

-- The 17 families tameable on Forever.
local FOREVER_FAMILIES = {
    "WOLF",
    "CAT",
    "SPIDER",
    "BEAR",
    "BOAR",
    "CROCOLISK",
    "CARRION_BIRD",
    "CRAB",
    "GORILLA",
    "RAPTOR",
    "TALLSTRIDER",
    "SCORPID",
    "TURTLE",
    "BAT",
    "HYENA",
    "BIRD_OF_PREY",
    "WIND_SERPENT",
}

local function countFormats(text)
    local _, n = text:gsub("%%s", "")
    return n
end

test("an unknown client locale falls back to enUS", function()
    local E = NewClient({ locale = "zhCN" }).E
    eq(E.LocaleCode, "enUS")
    eq(E.Format("FEED_NO_FOOD", "Fluffy"), "feeds Fluffy. ")
    eq(E.Emotes, E.Locales.enUS.emotes)
end)

test("a translated string comes from the client's locale", function()
    local E = NewClient({ locale = "deDE" }).E
    eq(E.LocaleCode, "deDE")
    eq(E.Format("FEED", "Fluffy", "Zähes Dörrfleisch"), "füttert Fluffy mit Zähes Dörrfleisch. ")
end)

test("an untranslated string falls back to enUS", function()
    local E = NewClient({ locale = "deDE" }).E
    eq(E.L.CHAT_PREFIX, "Feed Pet Emotes:")
end)

test("a key missing from enUS returns the key instead of looping", function()
    eq(NewClient({ locale = "enUS" }).E.L.NO_SUCH_KEY, "NO_SUCH_KEY")
    eq(NewClient({ locale = "frFR" }).E.L.NO_SUCH_KEY, "NO_SUCH_KEY")
end)

test("English picks a or an from the food name", function()
    local E = NewClient().E
    eq(E.Format("FEED", "Fluffy", "Rockscale Cod"), "feeds Fluffy a Rockscale Cod. ")
    eq(E.Format("FEED", "Fluffy", "Apple"), "feeds Fluffy an Apple. ")
    eq(E.Format("FEED", "Fluffy", "egg"), "feeds Fluffy an egg. ")
end)

test("English says some for uncounted food and plurals, going by the head noun", function()
    local E = NewClient().E
    local cases = {
        ["Mystery Meat"] = "some",
        ["Tough Jerky"] = "some",
        ["Alterac Swiss"] = "some",
        ["Delicious Cave Mold"] = "some",
        ["Deep Fried Plantains"] = "some",
        ["Bread with Butter"] = "some",
        ["Haunch of Meat"] = "a",
        ["Tough Hunk of Bread"] = "a",
        ["Moon Harvest Pumpkin"] = "a",
        ["Spongy Morel"] = "a",
        ["Deeprun Rat Kabob"] = "a",
        ["Raw Rainbow Fin Albacore"] = "a",
        ["Tel'Abim Banana"] = "a",
        ["Glass"] = "a",
        ["Octopus"] = "an",
    }
    for name, expected in pairs(cases) do
        eq(E.Format("ARTICLE", name), expected, name)
    end
end)

test("English takes the article from the name inside an item link", function()
    local E = NewClient().E
    local apple = "|cffffffff|Hitem:4536::::::::60:::::|h[Apple]|h|r"
    local jerky = "|cffffffff|Hitem:117::::::::60:::::|h[Tough Jerky]|h|r"
    eq(E.Format("FEED", "Fluffy", apple), "feeds Fluffy an " .. apple .. ". ")
    eq(E.Format("FEED", "Fluffy", jerky), "feeds Fluffy some " .. jerky .. ". ")
end)

test("esMX uses the esES file", function()
    local E = NewClient({ locale = "esMX" }).E
    eq(E.LocaleCode, "esMX")
    eq(E.Locales.esMX, E.Locales.esES)
    eq(E.Format("FEED_NO_FOOD", "Fluffy"), "alimenta a Fluffy. ")
end)

test("every locale's feed sentences take the right number of arguments", function()
    local E = NewClient().E
    for _, code in ipairs(ALL_LOCALES) do
        local strings = E.Locales[code].strings
        if type(strings.FEED) == "string" then eq(countFormats(strings.FEED), 2, code .. " FEED") end
        eq(countFormats(strings.FEED_NO_FOOD), 1, code .. " FEED_NO_FOOD")
    end
end)

test("every locale translates the options panel", function()
    local E = NewClient().E
    for _, code in ipairs(ALL_LOCALES) do
        for key in pairs(E.Locales.enUS.strings) do
            if key:match("^OPTION_") then
                local text = rawget(E.Locales[code].strings, key)
                ok(type(text) == "string" and text ~= "", code .. " " .. key)
            end
        end
    end
end)

test("the options panel uses the client's language", function()
    local client = NewClient({ locale = "deDE" }):login()
    eq(client.E.L.OPTION_ENABLED, "Emotes senden")
end)

test("every locale's emote lists hold non-empty strings under known keys", function()
    local E = NewClient().E
    local knownGroups, knownFamilies = {}, {}
    for _, group in pairs(E.FoodGroups) do
        knownGroups[group] = true
    end
    for _, id in pairs(E.Family) do
        knownFamilies[id] = true
    end
    local function checkList(list, where)
        ok(type(list) == "table" and #list > 0, where .. " is an empty list")
        for i, line in ipairs(list) do
            ok(type(line) == "string" and line ~= "", where .. "[" .. i .. "] is not a line")
        end
    end
    for _, code in ipairs(ALL_LOCALES) do
        local emotes = E.Locales[code].emotes
        checkList(emotes.any, code .. ".any")
        checkList(emotes.male, code .. ".male")
        checkList(emotes.female, code .. ".female")
        for group, list in pairs(emotes.food) do
            ok(knownGroups[group], code .. ": food group " .. tostring(group) .. " has no items")
            checkList(list, code .. ".food." .. group)
        end
        for id, list in pairs(emotes.family) do
            ok(knownFamilies[id], code .. ": family id " .. tostring(id) .. " is not in E.Family")
            checkList(list, code .. ".family." .. id)
        end
    end
end)

test("every locale has at least three lines for every family", function()
    local E = NewClient().E
    local short = {}
    for _, code in ipairs(ALL_LOCALES) do
        for name, id in pairs(E.Family) do
            local lines = E.Locales[code].emotes.family[id]
            local count = lines and #lines or 0
            if count < 3 then short[#short + 1] = code .. " " .. name .. " (" .. count .. ")" end
        end
    end
    table.sort(short)
    eq(#short, 0, "too few family lines: " .. table.concat(short, ", "))
end)

test("enUS and deDE have 20 lines for every pet and 10 per family", function()
    local E = NewClient().E
    for _, code in ipairs({ "enUS", "deDE" }) do
        local emotes = E.Locales[code].emotes
        eq(#emotes.any, 20, code .. " any")
        for name, id in pairs(E.Family) do
            eq(#emotes.family[id], 10, code .. " " .. name)
        end
    end
end)

test("no emote list holds the same line twice", function()
    local E = NewClient().E
    local twice = {}
    local function check(list, where)
        local seen = {}
        for _, line in ipairs(list) do
            if seen[line] then twice[#twice + 1] = where .. ": " .. line end
            seen[line] = true
        end
    end
    for _, code in ipairs(ALL_LOCALES) do
        local emotes = E.Locales[code].emotes
        check(emotes.any, code .. " any")
        for name, id in pairs(E.Family) do
            check(emotes.family[id] or {}, code .. " " .. name)
        end
    end
    table.sort(twice)
    eq(#twice, 0, table.concat(twice, ", "))
end)

test("E.Family holds the 17 Forever families", function()
    local E = NewClient().E
    for _, name in ipairs(FOREVER_FAMILIES) do
        ok(E.Family[name], name .. " missing from E.Family")
    end
end)
