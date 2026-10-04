local _, E = ...

-- Emote lines taken from Fizzwidget Feed-O-Matic (github.com/fizzwidget/feed-o-matic).
-- One line is picked at random from every list that applies to the current
-- feeding: "any", the pet's gender, the food's item ID and the pet's family.
E.Emotes = {
    any = {
        "Yum!",
        "Mmm, good stuff.",
        "Hey! Watch the fingers!",
        "Om nom nom nom...",
        "One gulp and it's gone!",
        "Mmm, delicious.",
        "Burp!",
        "Yay, bag space!",
    },

    male = {
        "Good boy!",
        "Atta boy!",
        "No more Mister Grumpy!",
    },
    female = {
        "Good girl!",
        "Atta girl!",
        "No more Miss Grumpy!",
    },

    -- Keyed by item ID.
    food = {
        [7974] = { "Mmm, zesty!" },                                  -- Zesty Clam Meat
        [12037] = "mystery",                                          -- Mystery Meat
        [44072] = "mystery",                                          -- Roasted Mystery Beast
        [59232] = "mystery",                                          -- Unidentifiable Meat Dish
        [12217] = { "Yow, spicy!" },                                  -- Dragonbreath Chili
        [4538] = { "What a big mouth!" },                             -- Snapvine Watermelon
        [8950] = { "Tastes so good, makes a grown man cry." },        -- Homemade Cherry Pie
        [27659] = { "Now how about some Nether Ray Fries?" },         -- Warp Burger
        [41808] = { "Crunchy!" },                                     -- Bonescale Snapper
        [41814] = "minnow",                                           -- Glassfin Minnow
        [43647] = "minnow",                                           -- Shimmering Minnow
        -- Mushrooms; Feed-O-Matic keyed these on the whole fungus diet.
        [4604] = "fungus",                                            -- Forest Mushroom Cap
        [4605] = "fungus",                                            -- Red-speckled Mushroom
        [4606] = "fungus",                                            -- Spongy Morel
        [4607] = "fungus",                                            -- Delicious Cave Mold
        [4608] = "fungus",                                            -- Raw Black Truffle
        [8948] = "fungus",                                            -- Dried King Bolete
    },

    -- Shared lists that several foods point at by name.
    shared = {
        mystery = {
            "Tastes like chicken.",
            "Tastes like tallstrider!",
            "Tastes like well-aged gnome.",
            "Tastes like... spider?",
        },
        minnow = { "Can has bigger fish?" },
        fungus = { "Trippy..." },
    },

    -- Keyed by UnitCreatureFamily("pet"), which is localized: English client only.
    family = {
        ["Boar"] = { "Good piggy!" },
        ["Cat"] = { "Nice kitty!" },
        ["Hyena"] = { "Good dog!" },
        ["Wolf"] = { "Good dog!" },
        ["Spider"] = { "Do you really have to wrap it up before eating it?" },
        ["Raptor"] = { "Down, dino!" },
        ["Devilsaur"] = { "Down, dino!" },
        ["Crocolisk"] = { "Crikey, it snapped that up fast!" },
        ["Core Hound"] = {
            "What a good little puppy!",
            "Aww, they're sharing.",
            "Hey, don't fight over it!",
        },
        ["Chimaera"] = { "Hey, don't fight over it!" },
    },
}
