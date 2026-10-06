-- The per-pet sex choice (/fpe sex): saved under the pet number from
-- UnitGUID("pet"), and used before what UnitSex reports.

local PET_NUMBER = 3069428 -- 0x2ED5F4, the default GUID's low 32 bits

local function sentLine(client)
    client:castSucceeded()
    return client:lastSent().text:match("^feeds Fluffy%. (.*)$")
end

local function onlyLine(client, line)
    client.pet.familyID = 999
    client.E.Emotes.any = { line }
    client.E.Emotes.male = {}
    client.E.Emotes.female = {}
end

test("the pet number is the low 32 bits of the GUID's last field", function()
    local client = NewClient():login()
    eq(client.E.PetNumber(), PET_NUMBER)
    -- A later summon: other server/zone part and summon counter, same pet.
    client.pet.guid = "Pet-0-4378-1-7-165189-03002ED5F4"
    eq(client.E.PetNumber(), PET_NUMBER)
end)

test("no pet, a secret GUID or a GUID of another shape give no pet number", function()
    local client = NewClient():login()
    client.secret[client.pet.guid] = true
    eq(client.E.PetNumber(), nil)
    client.pet.guid = "Creature-0-5250-0-1-1984-00002ED5F4"
    eq(client.E.PetNumber(), nil)
    client.pet = nil
    eq(client.E.PetNumber(), nil)
end)

test("/fpe sex female saves the choice under the pet number and overrides the game", function()
    local client = NewClient():login()
    onlyLine(client, "Just how {he} likes it.")
    client.pet.sex = 1
    client:slash("sex female")
    eq(Saved().petSex[PET_NUMBER], 3)
    ok(client:printedContains("Fluffy is now female."))
    eq(sentLine(client), "Just how she likes it.")
    -- Even against a sex the game does report.
    client.pet.sex = 2
    eq(sentLine(client), "Just how she likes it.")
end)

test("the choice follows the pet number, not the name or the summon", function()
    local client = NewClient():login()
    onlyLine(client, "Just how {he} likes it.")
    client.pet.sex = 1
    client:slash("sex male")
    client.pet.name = "Kaldor"
    client.pet.guid = "Pet-0-4378-1-7-165189-02002ED5F4"
    client:castSucceeded()
    eq(client:lastSent().text, "feeds Kaldor. Just how he likes it.")
    -- Another pet has no choice.
    client.pet.guid = "Pet-0-4378-1-7-165189-0100317A11"
    client:castSucceeded()
    eq(client:lastSent().text, "feeds Kaldor. Just how Kaldor likes it.")
end)

test("the chosen sex picks the gendered lists and own-line conditions", function()
    local client = NewClient():login()
    client.pet.sex = 1
    client:slash("sex female")
    contains(client.E.EmotePool(nil), "Good girl!")
    client:slash("add [female] A lady.")
    contains(client.E.EmotePool(nil), "A lady.")
end)

test("/fpe sex auto drops the choice", function()
    local client = NewClient():login()
    onlyLine(client, "Just how {he} likes it.")
    client.pet.sex = 1
    client:slash("sex male")
    client:slash("sex auto")
    eq(Saved().petSex[PET_NUMBER], nil)
    ok(client:printedContains("Fluffy's sex is now whatever the game reports"))
    eq(sentLine(client), "Just how Fluffy likes it.")
end)

test("/fpe name on still wins over a chosen sex", function()
    local client = NewClient():login()
    onlyLine(client, "Just how {he} likes it.")
    client:slash("sex female")
    client:slash("name on")
    eq(sentLine(client), "Just how Fluffy likes it.")
end)

test("/fpe sex without a pet, or with another word, saves nothing", function()
    local client = NewClient():login()
    client:slash("sex maybe")
    ok(client:printedContains("/fpe sex male, /fpe sex female or /fpe sex auto"))
    client.pet = nil
    client:slash("sex male")
    ok(client:printedContains("Summon your pet first."))
    eq(next(Saved().petSex), nil)
end)

test("/fpe gender is the same command, case and spaces ignored", function()
    local client = NewClient():login()
    client:slash("  Gender   FEMALE ")
    eq(Saved().petSex[PET_NUMBER], 3)
end)

test("a secret pet name is replaced by 'Your pet' in the reply", function()
    local client = NewClient():login()
    client.secret.Fluffy = true
    client:slash("sex male")
    ok(client:printedContains("Your pet is now male."))
end)

test("broken saved choices are dropped, valid ones kept", function()
    NewClient({ savedDB = { petSex = { [PET_NUMBER] = 3, [12] = 1, [13] = "male", pet = 2 } } }):login()
    eq(Saved().petSex[PET_NUMBER], 3)
    eq(Saved().petSex[12], nil)
    eq(Saved().petSex[13], nil)
    eq(Saved().petSex.pet, nil)
    NewClient({ savedDB = { petSex = "female" } }):login()
    eq(next(Saved().petSex), nil)
end)

test("/fpe selftest shows the pet number and where the sex comes from", function()
    local client = NewClient():login()
    client:slash("selftest")
    ok(client:printedContains("Pet number 3069428; sex used: 2 (from the game)."))
    client:slash("sex female")
    client:slash("selftest")
    ok(client:printedContains("Pet number 3069428; sex used: 3 (chosen with /fpe sex)."))
end)
