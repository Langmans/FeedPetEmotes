-- Pronoun placeholders: {he} and friends follow UnitSex, fall back to the pet's
-- name when the sex is unknown, and /fpe name forces the name.

local function sentLine(client)
    client:castSucceeded()
    return client:lastSent().text:match("^feeds Fluffy%. (.*)$") or client:lastSent().text
end

local function onlyLine(client, line)
    client.pet.familyID = 999
    client.E.Emotes.any = { line }
    client.E.Emotes.male = {}
    client.E.Emotes.female = {}
end

test("{he} becomes he for a male pet and she for a female pet", function()
    local client = NewClient():login()
    onlyLine(client, "Just how {he} likes it.")
    client.pet.sex = 2
    eq(sentLine(client), "Just how he likes it.")
    client.pet.sex = 3
    eq(sentLine(client), "Just how she likes it.")
end)

test("{boy} becomes boy or girl, the pet's name when the sex is unknown", function()
    local client = NewClient():login()
    onlyLine(client, "Good {boy}!")
    client.pet.sex = 2
    eq(sentLine(client), "Good boy!")
    client.pet.sex = 3
    eq(sentLine(client), "Good girl!")
    client.pet.sex = 1
    eq(sentLine(client), "Good Fluffy!")
    client:slash("sex female")
    eq(sentLine(client), "Good girl!")
    client:slash("name on")
    eq(sentLine(client), "Good Fluffy!")
end)

test("{boy} works in own lines and in every locale under its own word", function()
    local client = NewClient():login()
    client:slash("chance 100")
    client:slash("add Who's a good {boy}?")
    client.pet.sex = 3
    client:castSucceeded()
    eq(client:lastSent().text, "feeds Fluffy. Who's a good girl?")
    local words = { deDE = "Junge", esES = "chico", frFR = "garçon", ruRU = "мальчик", koKR = "소년" }
    for code, token in pairs(words) do
        local locale = client.E.Locales[code]
        ok(locale.pronouns and locale.pronouns[token], code .. " {" .. token .. "}")
    end
    local german = NewClient({ locale = "deDE" }):login()
    onlyLine(german, "Was für ein {Junge}!")
    german.pet.sex = 3
    german:castSucceeded()
    eq(german:lastSent().text, "füttert Fluffy. Was für ein Mädchen!")
end)

test("{his} becomes his or her, the pet's name with 's when the sex is unknown", function()
    local client = NewClient():login()
    onlyLine(client, "Not {his} dessert!")
    client.pet.sex = 2
    eq(sentLine(client), "Not his dessert!")
    client.pet.sex = 3
    eq(sentLine(client), "Not her dessert!")
    client.pet.sex = 1
    eq(sentLine(client), "Not Fluffy's dessert!")
    client.pet.sex = 2
    client:slash("name on")
    eq(sentLine(client), "Not Fluffy's dessert!")
end)

test("a % in the pet's name survives the possessive form", function()
    local client = NewClient():login()
    onlyLine(client, "Not {his} dessert!")
    client.pet.sex = 1
    client.pet.name = "100%"
    client:castSucceeded()
    eq(client:lastSent().text, "feeds 100%. Not 100%'s dessert!")
end)

test("German {sein}: Fluffys, but Boris' and Strauß'", function()
    local client = NewClient({ locale = "deDE" }):login()
    onlyLine(client, "Nicht {sein} Nachtisch!")
    client.pet.sex = 3
    client:castSucceeded()
    eq(client:lastSent().text, "füttert Fluffy. Nicht ihr Nachtisch!")
    client.pet.sex = 1
    client:castSucceeded()
    eq(client:lastSent().text, "füttert Fluffy. Nicht Fluffys Nachtisch!")
    for name, possessive in pairs({ Boris = "Boris'", ["Strauß"] = "Strauß'", Max = "Max'" }) do
        client.pet.name = name
        client:castSucceeded()
        eq(client:lastSent().text, "füttert " .. name .. ". Nicht " .. possessive .. " Nachtisch!")
    end
end)

test("a pet of unknown sex is named instead", function()
    local client = NewClient():login()
    onlyLine(client, "Just how {he} likes it.")
    client.pet.sex = 1
    eq(sentLine(client), "Just how Fluffy likes it.")
end)

test("a secret sex is treated as unknown", function()
    local client = NewClient():login()
    onlyLine(client, "Just how {he} likes it.")
    client.secret[2] = true
    eq(sentLine(client), "Just how Fluffy likes it.")
end)

test("/fpe name on always names the pet; off goes back to pronouns", function()
    local client = NewClient():login()
    onlyLine(client, "Just how {he} likes it.")
    client:slash("name on")
    eq(Saved().petName, true)
    eq(sentLine(client), "Just how Fluffy likes it.")
    client:slash("name off")
    eq(sentLine(client), "Just how he likes it.")
end)

test("a broken pet-name setting is repaired", function()
    NewClient({ savedDB = { enabled = true, petName = "yes" } }):login()
    eq(Saved().petName, false)
end)

test("a locale's own pronoun words are used", function()
    local client = NewClient({ locale = "deDE" }):login()
    onlyLine(client, "Frisst {er} auch seitwärts?")
    client.pet.sex = 3
    client:castSucceeded()
    eq(client:lastSent().text, "füttert Fluffy. Frisst sie auch seitwärts?")
end)

test("a pronoun another locale defines is never borrowed from English", function()
    local client = NewClient({ locale = "deDE" }):login()
    onlyLine(client, "Wie {he} es mag.")
    client:castSucceeded()
    eq(client:lastSent().text, "füttert Fluffy. Wie Fluffy es mag.")
end)

test("every locale's lines use only {pet} and that locale's own pronouns", function()
    local E = NewClient().E
    local bad = {}
    local function scan(value, allowed, where)
        if type(value) == "table" then
            for key, inner in pairs(value) do
                scan(inner, allowed, where .. "." .. tostring(key))
            end
        elseif type(value) == "string" then
            for token in value:gmatch("{([^}]*)}") do
                if token ~= "pet" and not allowed[token] then bad[#bad + 1] = where .. ": {" .. token .. "}" end
            end
        end
    end
    for code, locale in pairs(E.Locales) do
        scan(locale.emotes, locale.pronouns or {}, code)
    end
    table.sort(bad)
    eq(#bad, 0, table.concat(bad, ", "))
end)

test("every pronoun has a male and a female word", function()
    local E = NewClient().E
    for code, locale in pairs(E.Locales) do
        for token, words in pairs(locale.pronouns or {}) do
            ok(type(words.male) == "string" and type(words.female) == "string", code .. " {" .. token .. "}")
            local unknown = words.unknown
            if type(unknown) == "function" then unknown = unknown("Fluffy") end
            ok(
                unknown == nil
                    or (type(unknown) == "string" and unknown:find("Fluffy", 1, true) or unknown:find("%s", 1, true)),
                code .. " {" .. token .. "} unknown"
            )
        end
    end
end)

test("/fpe selftest says how pronouns are chosen", function()
    local client = NewClient():login()
    client:slash("selftest")
    ok(client:printedContains("Pronouns: from the pet's sex"))
    client:slash("name on")
    client:slash("selftest")
    ok(client:printedContains("Pronouns: always the pet's name"))
end)
