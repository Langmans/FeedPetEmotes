local _, E = ...

-- Locale-independent keys shared by the files in Locales\. Each of those
-- files adds one entry to E.Locales; Locale.lua then picks the client's one.

E.Locales = {}

-- Item ID -> food group used as key in each locale's `emotes.food` table.
E.FoodGroups = {
    [7974] = "zesty", -- Zesty Clam Meat
    [12037] = "mystery", -- Mystery Meat
    [44072] = "mystery", -- Roasted Mystery Beast
    [59232] = "mystery", -- Unidentifiable Meat Dish
    [12217] = "chili", -- Dragonbreath Chili
    [4538] = "watermelon", -- Snapvine Watermelon
    [8950] = "cherryPie", -- Homemade Cherry Pie
    [27659] = "warpBurger", -- Warp Burger
    [41808] = "crunchy", -- Bonescale Snapper
    [41814] = "minnow", -- Glassfin Minnow
    [43647] = "minnow", -- Shimmering Minnow
    -- Mushrooms; Feed-O-Matic keyed these on the whole fungus diet.
    [4604] = "fungus", -- Forest Mushroom Cap
    [4605] = "fungus", -- Red-speckled Mushroom
    [4606] = "fungus", -- Spongy Morel
    [4607] = "fungus", -- Delicious Cave Mold
    [4608] = "fungus", -- Raw Black Truffle
    [8948] = "fungus", -- Dried King Bolete
}

-- CreatureFamily IDs, the second return of UnitCreatureFamily("pet"); the
-- same on every client language, unlike the family name.
-- Source: the CreatureFamily DB2 table (wago.tools/db2/CreatureFamily).
E.Family = {
    -- The 17 families tameable on Forever (Wowhead, forever/hunter-pets).
    WOLF = 1,
    CAT = 2,
    SPIDER = 3,
    BEAR = 4,
    BOAR = 5,
    CROCOLISK = 6,
    CARRION_BIRD = 7,
    CRAB = 8,
    GORILLA = 9,
    RAPTOR = 11,
    TALLSTRIDER = 12,
    SCORPID = 20,
    TURTLE = 21,
    BAT = 24,
    HYENA = 25,
    BIRD_OF_PREY = 26, -- "Owl" before Forever renamed it
    WIND_SERPENT = 27,
    -- Wrath exotics, kept from Feed-O-Matic for later Classic flavors.
    CHIMAERA = 38,
    DEVILSAUR = 39,
    CORE_HOUND = 45,
}
