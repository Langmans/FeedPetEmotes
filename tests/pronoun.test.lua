-- Pronoun placeholders: {he} and friends follow UnitSex, fall back to the pet's
-- name when the sex is unknown, and /fpfe name forces the name.

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

test("/fpfe name on always names the pet; off goes back to pronouns", function()
    local client = NewClient():login()
    onlyLine(client, "Just how {he} likes it.")
    client:slash("name on")
    eq(FeedPetForeverEmotesDB.petName, true)
    eq(sentLine(client), "Just how Fluffy likes it.")
    client:slash("name off")
    eq(sentLine(client), "Just how he likes it.")
end)

test("a broken pet-name setting is repaired", function()
    NewClient({ savedDB = { enabled = true, petName = "yes" } }):login()
    eq(FeedPetForeverEmotesDB.petName, false)
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
        end
    end
end)

test("/fpfe selftest says how pronouns are chosen", function()
    local client = NewClient():login()
    client:slash("selftest")
    ok(client:printedContains("Pronouns: from the pet's sex"))
    client:slash("name on")
    client:slash("selftest")
    ok(client:printedContains("Pronouns: always the pet's name"))
end)
