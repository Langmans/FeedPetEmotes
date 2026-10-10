-- Openings (emotes.openings) that take FEED's place now and then, and whole
-- sentences (emotes.whole) that stand alone. NewClient({ variety = true })
-- keeps the locale's own lists; tests that need one outcome set small lists
-- and fix math.random.

---Runs fn with math.random(n) always returning `pick(n)`.
local function withRandom(pick, fn)
    local original = math.random
    math.random = function(n)
        return pick(n)
    end
    local ok, err = pcall(fn)
    math.random = original
    if not ok then error(err, 0) end
end

local function first()
    return 1
end

local function last(n)
    return n
end

---A client whose pet and lists leave one line and the given openings and
---whole sentences.
local function clientWith(openings, whole, line)
    local client = NewClient({ variety = true }):login()
    local emotes = client.E.Emotes
    client.pet.familyID = 999
    emotes.any, emotes.male, emotes.female = { line }, {}, {}
    emotes.food, emotes.foodType = {}, {}
    emotes.openings, emotes.whole, emotes.wholeFamily = openings, whole, {}
    return client
end

test("a family's whole sentences join for that family only", function()
    local client = clientWith({}, {}, "Yum!")
    local F = client.E.Family
    client.E.Emotes.wholeFamily = { [F.CAT] = { "puts {a} {food} on the table. {pet} knocks it off." } }
    eq(#client.E.EmotePool(12037, "Mystery Meat"), 1, "not for another family")
    client.pet.familyID = F.CAT
    contains(client.E.EmotePool(12037, "Mystery Meat"), "puts {a} {food} on the table. {pet} knocks it off.")
    for _, line in ipairs(client.E.EmotePool(nil)) do
        ok(line:sub(1, 4) ~= "puts", "not without a known food")
    end
    client.E.Emotes.any, client.E.Emotes.family = {}, {}
    withRandom(first, function()
        client:feed(12037)
        eq(client:lastSent().text, "puts a " .. ItemLink(12037) .. " on the table. Fluffy knocks it off.")
    end)
end)

test("an opening takes FEED's place, with the article and the item link", function()
    local client = clientWith({ "tosses {pet} {a} {food}." }, {}, "Yum!")
    withRandom(first, function()
        client:feed(12037)
        eq(client:lastSent().text, "tosses Fluffy a " .. ItemLink(12037) .. ". Yum!")
    end)
    eq(client.E.Format("ARTICLE", "Apple"), "an")
end)

test("FEED counts as one of the openings", function()
    local client = clientWith({ "tosses {pet} {a} {food}." }, {}, "Yum!")
    withRandom(last, function()
        client:feed(12037)
        eq(client:lastSent().text, "feeds Fluffy a " .. ItemLink(12037) .. ". Yum!")
    end)
end)

test("an opening takes the pronouns and stands alone without a line", function()
    local client = clientWith({ "rewards {pet} with {a} {food}, {his} favourite." }, {}, "Mine.")
    client.E.Emotes.any = {}
    client:slash("fallback off")
    client:slash("chance 100")
    withRandom(first, function()
        client:feed(12037)
        eq(client:lastSent().text, "rewards Fluffy with a " .. ItemLink(12037) .. ", his favourite.")
    end)
end)

test("without a known food the sentence is always FEED_NO_FOOD", function()
    local client = clientWith({ "tosses {pet} {a} {food}." }, { "and {pet} share {a} {food}." }, "Yum!")
    withRandom(first, function()
        client:castSucceeded()
        eq(client:lastSent().text, "feeds Fluffy. Yum!")
    end)
end)

test("a whole sentence stands alone, with the item link", function()
    local client = clientWith(
        { "tosses {pet} {a} {food}." },
        { "and {pet} have a staring contest over {a} {food}. {pet} wins." }
    )
    withRandom(first, function()
        client:feed(12037)
        eq(client:lastSent().text, "and Fluffy have a staring contest over a " .. ItemLink(12037) .. ". Fluffy wins.")
    end)
end)

test("whole sentences join the built-in lines only when the food is known", function()
    local client = clientWith({}, { "and {pet} share {a} {food}." }, "Yum!")
    contains(client.E.EmotePool(12037, "Mystery Meat"), "and {pet} share {a} {food}.")
    eq(#client.E.EmotePool(nil), 1)
end)

test("whole sentences are built-in: own lines only never picks one", function()
    local client = clientWith({}, { "and {pet} share {a} {food}." }, "Yum!")
    client:slash("add Mine.")
    client:slash("chance 100")
    withRandom(first, function()
        client:feed(12037)
        eq(client:lastSent().text, "feeds Fluffy a " .. ItemLink(12037) .. ". Mine.")
    end)
end)

test("a locale without openings always uses FEED", function()
    local client = NewClient({ locale = "frFR", variety = true }):login()
    eq(client.E.Emotes.openings, nil)
    client.pet.familyID = 999
    withRandom(last, function()
        client:feed(12037)
        startsWith(client:lastSent().text, "donne à Fluffy à manger")
    end)
end)

test("enUS and deDE openings and whole sentences fill every placeholder", function()
    for _, code in ipairs({ "enUS", "deDE" }) do
        for _, sex in ipairs({ 1, 2, 3 }) do
            local client = NewClient({ locale = code, variety = true }):login()
            client.pet.sex = sex
            local emotes = client.E.Emotes
            ok(#emotes.openings >= 10, code .. " openings")
            ok(#emotes.whole >= 10, code .. " whole")
            local lists = { emotes.openings, emotes.whole }
            for name, id in pairs(client.E.Family) do
                if not client.E.ExoticFamily[id] then
                    local list = emotes.wholeFamily[id]
                    ok(list and #list >= 2, code .. " whole lines for " .. name)
                    lists[#lists + 1] = list
                end
            end
            for _, list in ipairs(lists) do
                local seen = {}
                for _, line in ipairs(list) do
                    ok(not seen[line], code .. " twice: " .. line)
                    seen[line] = true
                    ok(line:find("{food}", 1, true), code .. " without {food}: " .. line)
                    local filled = client.E.FillPlaceholders(line, "Fluffy", ItemLink(12037), "a")
                    ok(not filled:find("[{}]"), code .. " left a placeholder: " .. filled)
                    ok(filled:find("[.!?]$"), code .. " does not end a sentence: " .. filled)
                end
            end
        end
    end
end)
