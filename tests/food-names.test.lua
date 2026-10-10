-- The English article ("a", "an" or "some") for every food and meat item on
-- Wowhead's Forever lists, kept in tests/data/forever-food.lua (refreshed
-- with `node tests/fetch-food.mjs`; its article column is reviewed by hand).

local FOODS = assert(loadfile(ROOT .. "/tests/data/forever-food.lua"))()

test("the food list is there", function()
    ok(#FOODS > 300, "only " .. #FOODS .. " items")
end)

test("every Forever food name gets the article the list expects", function()
    local E = NewClient().E
    local wrong = {}
    for _, row in ipairs(FOODS) do
        local id, name, expected = row[1], row[2], row[4]
        local article = E.Format("ARTICLE", name)
        if article ~= expected then
            wrong[#wrong + 1] = string.format("%s %s (%d), expected %s", article, name, id, expected)
        end
    end
    eq(#wrong, 0, table.concat(wrong, "; "))
end)
