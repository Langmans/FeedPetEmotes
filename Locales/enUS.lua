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

        CHAT_PREFIX = "Feed Pet Emotes:",
        EMOTES_ON = "Emotes on.",
        EMOTES_OFF = "Emotes off.",
        STATUS = "Emotes are %s. Commands: /fpe config (options panel), /fpe on, /fpe off, "
            .. "/fpe name on, /fpe name off, /fpe add [conditions] <line>, /fpe list, /fpe remove <number>, "
            .. "/fpe chance <0-100>, /fpe fallback on, /fpe fallback off, /fpe shared on, /fpe shared off, /fpe test (local preview), /fpe selftest, /fpe debug.",
        NOT_HUNTER = "Not a hunter: emotes are idle on this character.",
        STATUS_ON = "on",
        STATUS_OFF = "off",
        NO_PET = "Summon your pet first.",
        YOU = "You",
        PET_NAME_ON = "Emotes name your pet instead of saying he or she.",
        PET_NAME_OFF = "Emotes say he or she when your pet's sex is known, its name otherwise.",

        -- Your own lines (CustomLines.lua; /fpe add, list, remove, chance, fallback, shared).
        CUSTOM_ADDED = "Line %d added: %s",
        CUSTOM_REMOVED = "Line removed: %s",
        CUSTOM_NO_SUCH = "There is no line %s; /fpe list shows the numbers.",
        CUSTOM_NONE = "You have no lines of your own yet. Add one with /fpe add <line>.",
        CUSTOM_LIST = "Your lines (%d):",
        CHANCE_SET = "%d%% of your emotes now want one of your own lines.",
        CHANCE_EVEN = "Your own lines now count like the built-in ones: every fitting line has the same chance.",
        CHANCE_BAD = "Give a number from 0 to 100, e.g. /fpe chance 50. 0 lets every line count the same, "
            .. "100 uses only your own lines.",
        FALLBACK_ON = "When none of your lines fits, a built-in line is used.",
        FALLBACK_OFF = "When none of your lines fits, the emote only says who was fed what.",
        SHARED_ON = "This character now uses the lines shared by all your characters (%d).",
        SHARED_OFF = "This character now uses its own lines (%d).",
        CUSTOM_EMPTY = "Type the line after /fpe add, e.g. /fpe add {pet} wolfs it down.",
        CUSTOM_TOO_LONG = "That line is too long for an emote: at most %d bytes (letters outside A-Z count double).",
        CUSTOM_BAR = "A line cannot contain the | character.",
        CUSTOM_DUPLICATE = "You already have that line.",
        CUSTOM_UNKNOWN_CONDITION = "Unknown condition [%s]. Conditions: %s.",

        -- The options panel (Options.lua).
        OPTIONS_TITLE = "Feed Pet Emotes",
        OPTION_ENABLED = "Send emotes",
        OPTION_ENABLED_NOTE = "Send an /emote every time you feed your pet. Same as /fpe on and /fpe off.",
        OPTION_PET_NAME = "Always use the pet's name",
        OPTION_PET_NAME_NOTE = "Name the pet instead of saying he or she. Same as /fpe name on and off.",
        OPTION_DEBUG = "Debug trace",
        OPTION_DEBUG_NOTE = "Print in chat what the addon sees while you feed. Same as /fpe debug.",
        OPTION_CUSTOM_TITLE = "Your own lines",
        -- %s is the list of placeholders, e.g. "{pet}, {food}, {he}".
        OPTION_CUSTOM_NOTE = "Picked at random like the built-in lines. Placeholders: %s. "
            .. "Same as /fpe add, /fpe list and /fpe remove.",
        -- %s is OPTION_CHANCE_EVEN or a percentage like "35%".
        OPTION_CHANCE = "Chance of an own line: %s",
        OPTION_CHANCE_EVEN = "even",
        OPTION_CHANCE_NOTE = "Even: every fitting line, yours or built-in, has the same chance. Otherwise this "
            .. "share of emotes wants one of your lines; 100% means only yours. Same as /fpe chance.",
        OPTION_FALLBACK = "Use a built-in line when none of mine fits",
        OPTION_FALLBACK_NOTE = "Unticked, such an emote only says who was fed what. "
            .. "Same as /fpe fallback on and off.",
        OPTION_SHARED_LINES = "Share my lines with all characters",
        OPTION_SHARED_LINES_NOTE = "Use one list for every character that ticks this; unticked, this "
            .. "character keeps its own. Same as /fpe shared on and off.",
        -- Above the list; %d is the number of lines in it.
        OPTION_LIST_OWN = "Lines for this character (%d)",
        OPTION_LIST_SHARED = "Lines shared by all characters (%d)",
        OPTION_NEW_LINE = "New line",
        OPTION_EDIT_LINE = "Edit line %d",
        OPTION_CUSTOM_SAVE = "Save",
        OPTION_CUSTOM_CANCEL = "Cancel",
        OPTION_CUSTOM_EDIT = "Edit",
        OPTION_COND_TITLE = "Only when",
        OPTION_COND_NOTE = "Nothing ticked: always. Several ticks in one row: any of them. "
            .. "Ticks in several rows: each row must match.",
        OPTION_COND_GROUP_SEX = "Pet",
        OPTION_COND_GROUP_FOODTYPE = "Food",
        OPTION_COND_GROUP_FAMILY = "Family",
        -- Condition names; the tag itself (e.g. [bird_of_prey]) stays English.
        OPTION_COND_MALE = "Male",
        OPTION_COND_FEMALE = "Female",
        OPTION_COND_BREAD = "Bread",
        OPTION_COND_MEAT = "Meat",
        OPTION_COND_FISH = "Fish",
        OPTION_COND_CHEESE = "Cheese",
        OPTION_COND_FRUIT = "Fruit",
        OPTION_COND_FUNGUS = "Mushrooms",
        OPTION_COND_WOLF = "Wolf",
        OPTION_COND_CAT = "Cat",
        OPTION_COND_SPIDER = "Spider",
        OPTION_COND_BEAR = "Bear",
        OPTION_COND_BOAR = "Boar",
        OPTION_COND_CROCOLISK = "Crocolisk",
        OPTION_COND_CARRION_BIRD = "Carrion Bird",
        OPTION_COND_CRAB = "Crab",
        OPTION_COND_GORILLA = "Gorilla",
        OPTION_COND_RAPTOR = "Raptor",
        OPTION_COND_TALLSTRIDER = "Tallstrider",
        OPTION_COND_SCORPID = "Scorpid",
        OPTION_COND_TURTLE = "Turtle",
        OPTION_COND_BAT = "Bat",
        OPTION_COND_HYENA = "Hyena",
        OPTION_COND_BIRD_OF_PREY = "Bird of Prey",
        OPTION_COND_WIND_SERPENT = "Wind Serpent",
        OPTION_CUSTOM_ADD = "Add",
        OPTION_CUSTOM_REMOVE = "Remove",
        OPTION_CUSTOM_NONE = "No lines yet: type one above and press Enter or Add.",
    },

    -- Placeholders for emote lines: {he} becomes he or she from the pet's sex,
    -- or the pet's name when that is unknown (see E.FillPlaceholders).
    pronouns = {
        he = { male = "he", female = "she" },
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
        },
        -- Per food type (see E.FoodTypes). Only "Trippy..." is Feed-O-Matic's.
        foodType = {
            bread = { "Carbs! Glorious carbs!", "Fresh from the oven.", "Who needs meat when there's bread?" },
            meat = {
                "Nothing beats a good chunk of meat.",
                "Carnivore approved!",
                "Medium rare, just how you like it.",
            },
            fish = { "Fresh from the docks!", "Something smells fishy...", "Hold the tartar sauce." },
            cheese = { "Say cheese!", "Cheese for the beast!", "A little smelly, just how {he} likes it." },
            fruit = { "An apple a day keeps the vet away!", "Getting those vitamins in.", "Healthy choice!" },
            fungus = { "Trippy...", "Are you sure those are the edible ones?", "Fun guy, eating fungi." },
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
            [F.CROCOLISK] = { "Crikey, {he} snapped that up fast!", "Snap snap!", "Mind the teeth!" },
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
            [F.CRAB] = { "Snip snap!", "Does {he} eat sideways too?", "Pinch, pinch, gone!" },
            [F.GORILLA] = { "Who's a good ape?", "No bananas? Fine, this will do.", "Ook ook!" },
            [F.SCORPID] = { "Watch that stinger!", "Good... thing?", "Pinch and sting, what a combo!" },
            [F.TURTLE] = { "Slow and steady eats the snack.", "Take your time. Really.", "Shell yeah!" },
        },
    },
}
