local _, E = ...
local F = E.Family

-- The fallback locale: every other locale falls back to these strings, and a
-- locale without emotes uses these lines (see Locale.lua).
-- Emote lines from Feed-O-Matic unless marked otherwise.
E.Locales.enUS = {
    strings = {
        -- The /emote text in front of the random line.
        FEED = function(pet, food)
            local article = food:match("^[AEIOUaeiou]") and "an" or "a"
            return string.format("feeds %s %s %s. ", pet, article, food)
        end,
        FEED_NO_FOOD = "feeds %s. ",

        CHAT_PREFIX = "Feed Pet: Forever Emotes:",
        EMOTES_ON = "Emotes on.",
        EMOTES_OFF = "Emotes off.",
        STATUS = "Emotes are %s. Commands: /fpfe on, /fpfe off, /fpfe test (local preview), /fpfe selftest, /fpfe debug.",
        STATUS_ON = "on",
        STATUS_OFF = "off",
        NO_PET = "Summon your pet first.",
        YOU = "You",
    },

    emotes = {
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
        male = { "Good boy!", "Atta boy!", "No more Mister Grumpy!" },
        female = { "Good girl!", "Atta girl!", "No more Miss Grumpy!" },
        food = {
            zesty = { "Mmm, zesty!" },
            mystery = {
                "Tastes like chicken.",
                "Tastes like tallstrider!",
                "Tastes like well-aged gnome.",
                "Tastes like... spider?",
            },
            chili = { "Yow, spicy!" },
            watermelon = { "What a big mouth!" },
            cherryPie = { "Tastes so good, makes a grown man cry." },
            warpBurger = { "Now how about some Nether Ray Fries?" },
            crunchy = { "Crunchy!" },
            minnow = { "Can has bigger fish?" },
            fungus = { "Trippy..." },
        },
        family = {
            [F.BOAR] = { "Good piggy!" },
            [F.CAT] = { "Nice kitty!" },
            [F.HYENA] = { "Good dog!" },
            [F.WOLF] = { "Good dog!" },
            [F.SPIDER] = { "Do you really have to wrap it up before eating it?" },
            [F.RAPTOR] = { "Down, dino!" },
            [F.DEVILSAUR] = { "Down, dino!" },
            [F.CROCOLISK] = { "Crikey, it snapped that up fast!" },
            [F.CORE_HOUND] = {
                "What a good little puppy!",
                "Aww, they're sharing.",
                "Hey, don't fight over it!",
            },
            [F.CHIMAERA] = { "Hey, don't fight over it!" },
            -- Not in Feed-O-Matic; written for this addon.
            [F.BEAR] = { "Who's a big fuzzy bear? You are!", "Save some for hibernation!" },
            [F.BIRD_OF_PREY] = { "Who's a good bird?", "Swallowed whole!" },
            [F.TALLSTRIDER] = { "Good birdie!", "All neck and no manners!" },
            [F.CARRION_BIRD] = { "Fresh, for a change!", "Not dead enough for you?" },
            [F.WIND_SERPENT] = { "Zap! Gone!", "Don't shock the hand that feeds you!" },
            [F.BAT] = { "Good little screecher!", "At least it's not blood." },
            [F.CRAB] = { "Snip snap!", "Does it eat sideways too?" },
            [F.GORILLA] = { "Who's a good ape?", "No bananas? Fine, this will do." },
            [F.SCORPID] = { "Watch that stinger!", "Good... thing?" },
            [F.TURTLE] = { "Slow and steady eats the snack.", "Take your time. Really." },
        },
    },
}
