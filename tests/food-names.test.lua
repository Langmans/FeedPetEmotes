-- The English article ("a", "an" or "some") for every item a pet can eat on
-- Forever, as far as known: Wowhead's food and meat lists in
-- tests/data/forever-food.lua (refreshed with `node tests/fetch-food.mjs`),
-- and the edible items beyond those that a DevProbes PetFoodScan run found,
-- in tests/data/forever-scan.lua. The article column of both is reviewed by
-- hand.

local LISTS = {
    ["forever-food.lua"] = assert(loadfile(ROOT .. "/tests/data/forever-food.lua"))(),
    ["forever-scan.lua"] = assert(loadfile(ROOT .. "/tests/data/forever-scan.lua"))(),
}

test("the food lists are there", function()
    ok(#LISTS["forever-food.lua"] > 300, "forever-food.lua: only " .. #LISTS["forever-food.lua"] .. " items")
    ok(#LISTS["forever-scan.lua"] > 100, "forever-scan.lua: only " .. #LISTS["forever-scan.lua"] .. " items")
end)

test("no item is in both lists", function()
    local wowhead = {}
    for _, row in ipairs(LISTS["forever-food.lua"]) do
        wowhead[row[1]] = true
    end
    for _, row in ipairs(LISTS["forever-scan.lua"]) do
        ok(not wowhead[row[1]], row[2] .. " (" .. row[1] .. ") is in both")
    end
end)

test("every Forever food name gets the article the lists expect", function()
    local E = NewClient().E
    local wrong = {}
    for file, rows in pairs(LISTS) do
        for _, row in ipairs(rows) do
            local id, name, expected = row[1], row[2], row[4]
            local article = E.Format("ARTICLE", name)
            if article ~= expected then
                wrong[#wrong + 1] = string.format("%s: %s %s (%d), expected %s", file, article, name, id, expected)
            end
        end
    end
    table.sort(wrong)
    eq(#wrong, 0, table.concat(wrong, "; "))
end)
