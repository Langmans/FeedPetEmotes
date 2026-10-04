-- Which lines E.EmotePool offers for a given pet and food.

local function poolFor(client, itemID)
    client:login()
    return client.E.EmotePool(itemID)
end

test("a male cat eating Mystery Meat gets any, male, mystery and cat lines", function()
    local client = NewClient()
    local enUS = client.E.Locales.enUS.emotes
    local pool = poolFor(client, 12037)
    eq(#pool, #enUS.any + #enUS.male + #enUS.food.mystery + #enUS.family[client.E.Family.CAT])
    contains(pool, "Good boy!")
    contains(pool, "Tastes like... spider?")
    contains(pool, "Nice kitty!")
end)

test("a female pet gets the female lines, not the male ones", function()
    local client = NewClient()
    client.pet.sex = 3
    local pool = poolFor(client, nil)
    contains(pool, "Good girl!")
    for _, line in ipairs(pool) do
        ok(line ~= "Good boy!", "male line offered to a female pet")
    end
end)

test("a pet of unknown sex gets neither gendered list", function()
    local client = NewClient()
    client.pet.sex = 1
    client.pet.familyID = 999
    local enUS = client.E.Locales.enUS.emotes
    eq(#poolFor(client, nil), #enUS.any)
end)

test("a food without a group adds nothing", function()
    local client = NewClient()
    client.pet.familyID = 999
    local enUS = client.E.Locales.enUS.emotes
    eq(#poolFor(client, 4536), #enUS.any + #enUS.male)
end)

test("every mushroom maps to the fungus lines", function()
    local client = NewClient()
    client:login()
    for _, itemID in ipairs({ 4604, 4605, 4606, 4607, 4608, 8948 }) do
        contains(client.E.EmotePool(itemID), "Trippy...", "item " .. itemID)
    end
end)

test("a secret family ID adds no family lines", function()
    local client = NewClient()
    client.secret[2] = true
    local pool = poolFor(client, nil)
    for _, line in ipairs(pool) do
        ok(line ~= "Nice kitty!", "family line from a secret family ID")
    end
end)

test("a family without lines adds nothing and does not error", function()
    local client = NewClient()
    client.pet.familyID = 46 -- Spirit Beast: not tameable on Forever
    local enUS = client.E.Locales.enUS.emotes
    eq(#poolFor(client, nil), #enUS.any + #enUS.male)
end)

test("a German client offers German lines, matched on the same family ID", function()
    local client = NewClient({ locale = "deDE" })
    client.pet.family = "Schildkröte"
    client.pet.familyID = client.E.Family.TURTLE
    local pool = poolFor(client, nil)
    contains(pool, "Immer mit der Ruhe.")
    contains(pool, "Guter Junge!")
end)

test("a locale missing a list never mixes in English", function()
    local client = NewClient({ locale = "esES" })
    client.pet.familyID = client.E.Family.SPIDER -- esES has no spider lines
    local pool = poolFor(client, 12037)
    for _, line in ipairs(pool) do
        ok(not line:find("spider", 1, true) and not line:find("Good boy", 1, true), "English line: " .. line)
    end
end)
