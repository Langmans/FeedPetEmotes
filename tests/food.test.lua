-- Food types: which vendor food belongs to which type, and that the type's
-- lines reach the emote pool.

local FOOD_TYPES = { "bread", "meat", "fish", "cheese", "fruit", "fungus" }

-- Food sold by vendors on Forever (Wowhead, forever/items/consumables/
-- food-and-drinks, "Sold by a vendor"), classified by name. Holiday, faire and
-- unclear items (Hard Boiled Eggs, Nutritious Slime Sludge) are left out.
local VENDOR_FOOD = {
    bread = { 4540, 4541, 4542, 4544, 4601, 8950, 252026, 278119 },
    meat = { 117, 2287, 3770, 3771, 4599, 8952, 11444, 17119, 252029, 278121 },
    fish = { 787, 4592, 4593, 4594, 8957, 21552 },
    cheese = { 414, 422, 1707, 2070, 3927, 8932, 252030 },
    fruit = { 4536, 4537, 4538, 4539, 4602, 8953, 13810, 252032 },
    fungus = { 4604, 4605, 4606, 4607, 4608, 8948 },
}

test("every vendor food has its type", function()
    local E = NewClient().E
    for foodType, items in pairs(VENDOR_FOOD) do
        for _, itemID in ipairs(items) do
            eq(E.FoodTypes[itemID], foodType, "item " .. itemID)
        end
    end
end)

test("every food type in the data is one of the six", function()
    local E = NewClient().E
    local known = {}
    for _, foodType in ipairs(FOOD_TYPES) do
        known[foodType] = true
    end
    for itemID, foodType in pairs(E.FoodTypes) do
        ok(known[foodType], "item " .. itemID .. " has unknown type " .. tostring(foodType))
    end
end)

test("every locale has at least two lines for every food type", function()
    local E = NewClient().E
    local short = {}
    for _, code in ipairs({ "enUS", "deDE", "esES", "frFR", "koKR", "ruRU" }) do
        local lists = E.Locales[code].emotes.foodType or {}
        for _, foodType in ipairs(FOOD_TYPES) do
            local count = lists[foodType] and #lists[foodType] or 0
            if count < 2 then short[#short + 1] = code .. " " .. foodType .. " (" .. count .. ")" end
        end
    end
    table.sort(short)
    eq(#short, 0, "too few food-type lines: " .. table.concat(short, ", "))
end)

test("vendor bread gets the bread lines", function()
    local client = NewClient():login()
    client.pet.familyID = 999
    local enUS = client.E.Locales.enUS.emotes
    local pool = client.E.EmotePool(4540)
    eq(#pool, #enUS.any + #enUS.male + #enUS.foodType.bread)
    contains(pool, enUS.foodType.bread[1])
end)

test("a food with its own lines also gets its type's lines", function()
    local client = NewClient():login()
    local enUS = client.E.Locales.enUS.emotes
    local pool = client.E.EmotePool(4538)
    contains(pool, "What a big mouth!")
    contains(pool, enUS.foodType.fruit[1])
end)

test("a German client gets German food-type lines", function()
    local client = NewClient({ locale = "deDE" }):login()
    local deDE = client.E.Locales.deDE.emotes
    contains(client.E.EmotePool(117), deDE.foodType.meat[1])
end)

test("feeding vendor bread can send a bread line", function()
    local client = NewClient():login()
    client.pet.familyID = 999
    local enUS = client.E.Locales.enUS.emotes
    local seen = {}
    for _ = 1, 200 do
        client:feed(4540)
        local line = client:lastSent().text:match("%. (.*)$")
        seen[line] = true
    end
    local any = false
    for _, line in ipairs(enUS.foodType.bread) do
        any = any or seen[line]
    end
    ok(any, "no bread line in 200 feeds")
end)
