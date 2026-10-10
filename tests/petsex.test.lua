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

-- Pruning: a choice for a pet in neither stable list goes on login.

local OTHER_PET = 3242513 -- 0x317A11

test("login drops the choices of pets in neither stable list", function()
    local client = NewClient({ savedDB = { petSex = { [PET_NUMBER] = 3, [OTHER_PET] = 2, [77] = 3 } } })
    client.stable.stabled = { OTHER_PET }
    client:login()
    eq(Saved().petSex[PET_NUMBER], 3)
    eq(Saved().petSex[OTHER_PET], 2)
    eq(Saved().petSex[77], nil)
end)

test("nothing is dropped with empty stable lists, a secret pet number or no C_StableInfo", function()
    local saved = function()
        return { petSex = { [PET_NUMBER] = 3, [77] = 3 } }
    end
    local client = NewClient({ savedDB = saved() })
    client.stable.active = {}
    client:login()
    eq(Saved().petSex[77], 3)

    client = NewClient({ savedDB = saved() })
    client.stable.stabled = { 88 }
    client.secret[88] = true
    client:login()
    eq(Saved().petSex[77], 3)

    NewClient({ savedDB = saved(), noStableInfo = true }):login()
    eq(Saved().petSex[77], 3)
end)

test("a non-hunter's saved choices are left alone", function()
    NewClient({ class = "MAGE", savedDB = { petSex = { [77] = 3 } } }):login()
    eq(Saved().petSex[77], 3)
end)

-- The options panel's "Your pet's sex" section.

---The three sex boxes in order: male, female, from the game.
local function sexBoxes(client)
    local boxes = {}
    for _, frame in ipairs(client.frames) do
        if frame.sexChoice ~= nil then boxes[#boxes + 1] = frame end
    end
    return boxes
end

local function showPanel(client)
    client.optionsPanel.scripts.OnShow(client.optionsPanel)
end

local function panelShows(client, text)
    for _, region in ipairs(client.fontStrings) do
        if region:GetText() == text then return true end
    end
    return false
end

local function ticked(client)
    local states = {}
    for i, box in ipairs(sexBoxes(client)) do
        states[i] = box:GetChecked() and "x" or "-"
    end
    return table.concat(states)
end

test("the panel ticks the summoned pet's choice, or 'from the game'", function()
    local client = NewClient():login()
    eq(#sexBoxes(client), 3)
    showPanel(client)
    ok(panelShows(client, "For Fluffy:"))
    eq(ticked(client), "--x")
    client:slash("sex female")
    showPanel(client)
    eq(ticked(client), "-x-")
end)

test("a tick in the panel saves the choice like /fpe sex", function()
    local client = NewClient():login()
    showPanel(client)
    local boxes = sexBoxes(client)
    boxes[1]:SetChecked(true)
    boxes[1].scripts.OnClick(boxes[1])
    eq(Saved().petSex[PET_NUMBER], 2)
    eq(ticked(client), "x--")
    -- Clicking the ticked box again keeps it ticked.
    boxes[1]:SetChecked(false)
    boxes[1].scripts.OnClick(boxes[1])
    eq(ticked(client), "x--")
    boxes[3]:SetChecked(true)
    boxes[3].scripts.OnClick(boxes[3])
    eq(Saved().petSex[PET_NUMBER], nil)
    eq(ticked(client), "--x")
end)

test("without a pet the panel hides the ticks and asks for one", function()
    local client = NewClient():login()
    client.pet = nil
    showPanel(client)
    ok(panelShows(client, "Summon your pet to choose its sex."))
    for _, box in ipairs(sexBoxes(client)) do
        eq(box:IsShown(), false)
    end
end)

test("a summon or dismiss while the panel is open refills the section", function()
    local client = NewClient():login()
    showPanel(client)
    client.pet = nil
    client:fire("UNIT_PET", "player")
    ok(panelShows(client, "Summon your pet to choose its sex."))
    -- A closed panel waits for its next OnShow.
    client.optionsPanel:Hide()
    client.pet = { name = "Kaldor", sex = 1, guid = "Pet-0-1-1-1-165189-0100317A11" }
    client:fire("UNIT_PET", "player")
    ok(not panelShows(client, "For Kaldor:"))
    client.optionsPanel:Show()
    client:fire("UNIT_PET", "player")
    ok(panelShows(client, "For Kaldor:"))
    eq(sexBoxes(client)[1]:IsShown(), true)
end)

test("/fpe selftest shows the pet number and where the sex comes from", function()
    local client = NewClient():login()
    client:slash("selftest")
    ok(client:printedContains("Pet number 3069428; sex used: 2 (from the game)."))
    client:slash("sex female")
    client:slash("selftest")
    ok(client:printedContains("Pet number 3069428; sex used: 3 (chosen with /fpe sex)."))
end)
