local _, E = ...
local F = E.Family

-- The fallback locale: every other locale falls back to these strings, and a
-- locale without emotes uses these lines (see Locale.lua).
-- Emote lines from Feed-O-Matic unless marked otherwise.
E.Locales.enUS = {
    strings = {
        -- The /emote text in front of the random line.
        FEED = function(pet, food)
            -- food is an item link or a plain name; the article follows the name.
            local name = food:match("|h%[(.-)%]|h") or food
            local article = name:match("^[AEIOUaeiou]") and "an" or "a"
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
        -- Feed-O-Matic had one line for most of the first ten families (three
        -- for Core Hound) and none for Bear onwards; the rest was written for
        -- this addon.
        family = {
            [F.BOAR] = { "Good piggy!", "Oink oink, nom nom.", "Truffle hunter on duty!" },
            [F.CAT] = { "Nice kitty!", "Purr-fect!", "Who's a pretty kitty?" },
            [F.HYENA] = { "Good dog!", "Stop laughing and eat!", "Who's laughing now?" },
            [F.WOLF] = { "Good dog!", "Who's a good wolf?", "Awoooo!" },
            [F.SPIDER] = {
                "Do you really have to wrap it up before eating it?",
                "Eight legs, one appetite.",
                "Don't get web on my fingers!",
            },
            [F.RAPTOR] = { "Down, dino!", "Clever girl...", "Easy, killer!" },
            [F.DEVILSAUR] = { "Down, dino!", "Big bites for a big dino!", "Don't eat me next!" },
            [F.CROCOLISK] = { "Crikey, it snapped that up fast!", "Snap snap!", "Mind the teeth!" },
            [F.CORE_HOUND] = {
                "What a good little puppy!",
                "Aww, they're sharing.",
                "Hey, don't fight over it!",
            },
            [F.CHIMAERA] = {
                "Hey, don't fight over it!",
                "Two heads, twice the appetite.",
                "Share nicely, both of you.",
            },
            [F.BEAR] = { "Who's a big fuzzy bear? You are!", "Save some for hibernation!", "Bear-ly a snack!" },
            [F.BIRD_OF_PREY] = { "Who's a good bird?", "Swallowed whole!", "Keen eyes, empty belly. Not anymore!" },
            [F.TALLSTRIDER] = { "Good birdie!", "All neck and no manners!", "Peck peck peck!" },
            [F.CARRION_BIRD] = { "Fresh, for a change!", "Not dead enough for you?", "A vulture with standards!" },
            [F.WIND_SERPENT] = { "Zap! Gone!", "Don't shock the hand that feeds you!", "Slurped right up!" },
            [F.BAT] = { "Good little screecher!", "At least it's not blood.", "Eat up, little night flyer." },
            [F.CRAB] = { "Snip snap!", "Does it eat sideways too?", "Pinch, pinch, gone!" },
            [F.GORILLA] = { "Who's a good ape?", "No bananas? Fine, this will do.", "Ook ook!" },
            [F.SCORPID] = { "Watch that stinger!", "Good... thing?", "Pinch and sting, what a combo!" },
            [F.TURTLE] = { "Slow and steady eats the snack.", "Take your time. Really.", "Shell yeah!" },
        },
    },
}
