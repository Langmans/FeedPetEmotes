local _, E = ...
local F = E.Family

-- The fallback locale: every other locale falls back to these strings, and a
-- locale without emotes uses these lines (see Locale.lua).
-- Emote lines from Feed-O-Matic unless marked otherwise.

-- Head nouns that take "some": food you do not count (meat, bread, cheese
-- names, dishes from a pot). Plurals ("Deep Fried Plantains") take it as
-- well. Taken from the food names on Wowhead's Forever food list
-- (wowhead.com/forever/items/consumables/food-and-drinks) and Data.lua; raw
-- meat and fish are trade goods there, and their names end in Meat or a
-- countable fish.
local UNCOUNTED = {
    -- meat
    meat = true,
    jerky = true,
    boar = true,
    brisket = true,
    venison = true,
    -- bread
    bread = true,
    cornbread = true,
    butter = true,
    -- cheese
    cheddar = true,
    skycheddar = true,
    brie = true,
    bleu = true,
    swiss = true,
    sharp = true,
    mild = true,
    -- from a pot or a bowl
    stew = true,
    soup = true,
    chowder = true,
    gumbo = true,
    goulash = true,
    broth = true,
    bisque = true,
    chili = true,
    linguine = true,
    salad = true,
    kimchi = true,
    jam = true,
    -- the rest
    mold = true,
    sludge = true,
    fruit = true,
    taffy = true,
    cream = true,
    feed = true,
}

---"a", "an" or "some" for a food's plain name. The head noun decides: the
---word before "of" or "with" ("Haunch of Meat" -> Haunch, "Bread with
---Butter" -> Bread), else the last word. Uncounted food and plurals take
---"some"; otherwise the first letter picks "a" or "an".
---@param name string
---@return string
local function article(name)
    local head = (name:match("^(.-) of ") or name:match("^(.-) with ") or name):match("(%S+)$") or name
    head = head:lower()
    if UNCOUNTED[head] or (head:match("s$") and not head:match("[su]s$")) then return "some" end
    return name:match("^[AEIOUaeiou]") and "an" or "a"
end

E.Locales.enUS = {
    strings = {
        -- The /emote text in front of the random line; one of the openings
        -- below takes its place now and then.
        ---@param pet string
        ---@param food string
        ---@return string
        FEED = function(pet, food)
            -- food is an item link or a plain name; the article follows the name.
            return string.format("feeds %s %s %s. ", pet, article(food:match("|h%[(.-)%]|h") or food), food)
        end,
        -- {a} in the openings and whole sentences.
        ARTICLE = article,
        FEED_NO_FOOD = "feeds %s. ",

        CHAT_PREFIX = "Feed Pet Emotes:",
        EMOTES_ON = "Emotes on.",
        EMOTES_OFF = "Emotes off.",
        STATUS = "Emotes are %s. Commands: /fpe config (options panel), /fpe on, /fpe off, "
            .. "/fpe name on, /fpe name off, /fpe sex male|female|auto, /fpe add [conditions] <line>, /fpe list, /fpe remove <number>, "
            .. "/fpe chance <0-100>, /fpe fallback on, /fpe fallback off, /fpe shared on, /fpe shared off, /fpe test (local preview), /fpe selftest, /fpe debug.",
        NOT_HUNTER = "Not a hunter: emotes are idle on this character.",
        STATUS_ON = "on",
        STATUS_OFF = "off",
        NO_PET = "Summon your pet first.",
        OPTIONS_AFTER_COMBAT = "In combat: the options open when combat ends.",
        YOU = "You",
        PET_NAME_ON = "Emotes name your pet instead of saying he or she.",
        PET_NAME_OFF = "Emotes say he or she when your pet's sex is known, its name otherwise.",
        -- /fpe sex: a choice per pet, kept through renames and stable swaps.
        SEX_SET = "%s is now %s.",
        SEX_AUTO = "%s's sex is now whatever the game reports (usually unknown).",
        SEX_MALE = "male",
        SEX_FEMALE = "female",
        SEX_BAD = "Summon the pet and type /fpe sex male, /fpe sex female or /fpe sex auto.",
        YOUR_PET = "Your pet",

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
        OPTION_PET_SEX_TITLE = "Your pet's sex",
        OPTION_PET_SEX_NOTE = "Picks he or she and the lines for males or females. The game does not tell a "
            .. "hunter pet's sex, so you choose it per pet. Same as /fpe sex.",
        -- %s is the summoned pet's name.
        OPTION_PET_SEX_FOR = "For %s:",
        OPTION_PET_SEX_NONE = "Summon your pet to choose its sex.",
        OPTION_PET_SEX_GAME = "From the game",
        -- Version, author and license from the .toc.
        OPTION_ABOUT = "Version %s by %s, %s license.",
        OPTION_WEBSITE = "Website (Ctrl+C to copy):",
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
    -- {boy} boy or girl ("Good {boy}!"), each the pet's name when the sex is
    -- unknown; {his} his or her, "Fluffy's" when it is unknown (`unknown`, see
    -- E.FillPlaceholders).
    pronouns = {
        he = { male = "he", female = "she" },
        boy = { male = "boy", female = "girl" },
        his = { male = "his", female = "her", unknown = "%s's" },
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
            "Who's a good {boy}?",
            "That's my {boy}!",
            "Straight down the hatch and into {his} belly.",
            "Hey, those are my fingers, not {his} dessert!",
            "Clean plate club!",
            "Chew, don't inhale!",
            "No, you can't have seconds. ...Fine.",
            "Don't tell the other hunters I spoil you.",
            "And that's why my bags are always empty.",
            "That one comes out of your loot share.",
            "Another satisfied customer.",
            "Loyalty: bought and paid for.",
        },
        -- Openings and whole sentences were written for this addon. An opening
        -- takes FEED's place: {a} {food} is the article and the item link.
        -- Each ends with the pet having its food, so any line can follow.
        openings = {
            "tosses {pet} {a} {food}.",
            "drops {a} {food} into {pet}'s bowl.",
            "hands {pet} {a} {food}.",
            "lets {pet} snatch {a} {food} right out of the bag.",
            "slips {pet} {a} {food} when nobody is looking.",
            "throws {a} {food} in the air, and {pet} catches it.",
            "rewards {pet} with {a} {food}.",
            "feeds {pet} {a} {food} by hand.",
            "puts down {a} {food}, and {pet} pounces on it.",
            "offers {pet} {a} {food} with a little bow.",
            "serves {pet} {a} {food}, fresh from the bag.",
            "bribes {pet} with {a} {food}.",
            "treats {pet} to {a} {food}.",
            "waves {a} {food} under {pet}'s nose, just long enough for a grab.",
            "gives {pet} {a} {food} as a well-earned snack.",
        },
        -- A whole emote on its own, no FEED and no line after it.
        whole = {
            "and {pet} have a staring contest over {a} {food}. {pet} wins.",
            "tries to share {a} {food} with {pet}. {pet} does not believe in sharing.",
            "turns around for one second. The {food} is gone, and {pet} looks very innocent.",
            "holds out {a} {food}. {pet} takes it, and most of the glove.",
            "asks {pet} to sit for {a} {food}. {pet} skips straight to the eating part.",
            "drops {a} {food}. It never touches the ground: {pet} is faster.",
            "gives {pet} {a} {food} and gets a look that says: that's it?",
            "hides {a} {food} in a pocket. {pet} finds it in two seconds.",
            "counts to three before giving {pet} {a} {food}. {pet} counts faster.",
            "cuts {a} {food} into neat little bites. {pet} swallows it whole.",
            "watches {pet} wolf down {a} {food} before {he} even sniffs it.",
        },
        -- Whole emotes for one family, mixed in with the ones above.
        wholeFamily = {
            [F.WOLF] = {
                "throws {a} {food} like a stick. {pet} fetches it straight into {his} belly.",
                "says 'sit' and holds up {a} {food}. {pet} sits, howls once, and the {food} is gone.",
            },
            [F.CAT] = {
                "puts {a} {food} on the table. {pet} knocks it off, then eats it off the floor.",
                "offers {pet} {a} {food}. {pet} sniffs it, walks away, and eats it once nobody is looking.",
            },
            [F.SPIDER] = {
                "drops {a} {food} near {pet}. A moment later it is neatly wrapped in silk.",
                "tosses {a} {food} into the web. {pet} wraps it up for later. Later is now.",
            },
            [F.BEAR] = {
                "opens the bag for {a} {food}. {pet} helps by sticking {his} whole head in.",
                "hands {pet} {a} {food}. {pet} looks for the honey first, then eats it anyway.",
            },
            [F.BOAR] = {
                "hides {a} {food} under a pile of leaves. {pet} snouts it out in two snorts.",
                "sets down {a} {food}. {pet} charges it at full speed. The {food} loses.",
            },
            [F.CROCOLISK] = {
                "holds {a} {food} over the water on a stick. Snap. The {food} is gone, and so is half the stick.",
                "tosses {a} {food} to {pet}, who swallows it and lies very still, waiting for more.",
            },
            [F.CARRION_BIRD] = {
                "leaves {a} {food} out in the sun for a while, just the way {pet} likes it.",
                "puts down {a} {food}. {pet} circles it three times before landing on it.",
            },
            [F.CRAB] = {
                "holds out {a} {food}. {pet} takes it with one claw and pinches the hand with the other.",
                "drops {a} {food} on the sand. {pet} scuttles over sideways and snips it to bits.",
            },
            [F.GORILLA] = {
                "hands {pet} {a} {food}. {pet} beats {his} chest, then eats it very politely.",
                "peels {a} {food} for {pet}. {pet} eats the peel too.",
            },
            [F.RAPTOR] = {
                "holds out {a} {food}. {pet} takes it, then checks whether the hand is next.",
                "tosses {a} {food} to {pet}, who snaps it out of the air. Clever {boy}.",
            },
            [F.TALLSTRIDER] = {
                "holds {a} {food} up high. {pet} does not even need to stretch.",
                "puts {a} {food} on the ground. {pet} pecks at it until it is gone, staring at nothing.",
            },
            [F.SCORPID] = {
                "puts down {a} {food}. {pet} stings it first, just to be sure.",
                "offers {pet} {a} {food} from a very safe distance.",
            },
            [F.TURTLE] = {
                "puts {a} {food} in front of {pet}. {pet} gets there eventually.",
                "waits while {pet} eats {a} {food}. And waits. And waits.",
            },
            [F.BAT] = {
                "throws {a} {food} into the air. {pet} catches it upside down.",
                "feeds {pet} {a} {food} at midnight, the only proper mealtime for a bat.",
            },
            [F.HYENA] = {
                "drops {a} {food}. {pet} laughs at it, then eats it.",
                "hands {pet} {a} {food}. {pet} giggles all the way through it.",
            },
            [F.BIRD_OF_PREY] = {
                "holds up a gloved hand with {a} {food}. {pet} swoops down and takes it in one pass.",
                "tosses {a} {food} high. {pet} is a feathered blur, and the {food} is gone.",
            },
            [F.WIND_SERPENT] = {
                "throws {a} {food} into the wind. {pet} catches it with a crackle of lightning.",
                "holds out {a} {food}. {pet} coils around the arm and takes it gently.",
            },
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
            [F.BOAR] = {
                "Good piggy!",
                "Oink oink, nom nom.",
                "Truffle hunter on duty!",
                "That's going straight to {his} hips.",
                "Snort snort!",
                "Who needs a trough when you have me?",
                "Charge! ...at the snack, apparently.",
                "Bacon? Never heard of it.",
                "Mud bath after dinner, as usual.",
                "Tusks first, manners never.",
            },
            [F.CAT] = {
                "Nice kitty!",
                "Purr-fect!",
                "Who's a pretty kitty?",
                "Don't knock it off the table this time.",
                "Purring at full volume.",
                "Now ignore me like a proper cat.",
                "Cats don't have owners. They have staff.",
                "Nine lives, ten snacks.",
                "Comes when called? Only at dinner.",
                "Meow-velous!",
            },
            [F.HYENA] = {
                "Good dog!",
                "Stop laughing and eat!",
                "Who's laughing now?",
                "Hee hee hee... crunch.",
                "What's so funny about lunch?",
                "Laughing all the way to the bowl.",
                "Scavenger turned gourmet.",
                "Even the leftovers are giggling.",
                "No joke, that was fast.",
                "Giggles and gobbles.",
            },
            [F.WOLF] = {
                "Good dog!",
                "Who's a good wolf?",
                "Awoooo!",
                "Wolfed it down, naturally.",
                "Pack leader eats first. That's me, by the way.",
                "Howl if you want more!",
                "No sheep were harmed. Probably.",
                "The big bad wolf gets a snack.",
                "Fetch is after dinner.",
                "Lone wolf, full belly.",
            },
            [F.SPIDER] = {
                "Do you really have to wrap it up before eating it?",
                "Eight legs, one appetite.",
                "Don't get web on my fingers!",
                "Eight eyes, all on my bag.",
                "Silk-wrapped for freshness.",
                "Please don't save the rest on the ceiling.",
                "Itsy bitsy, hungry as anything.",
                "I'm not screaming, you're screaming.",
                "Web-to-table dining.",
                "Who's a good... arachnid?",
            },
            [F.RAPTOR] = {
                "Down, dino!",
                "Clever girl...",
                "Easy, killer!",
                "Still faster than me, even while eating.",
                "That's the sound of a happy predator.",
                "Rawr means thank you, right?",
                "Don't look at me like I'm dessert.",
                "Pack hunter, solo eater.",
                "Life finds a way. To the snack.",
                "Don't eat the quest giver, please.",
            },
            [F.DEVILSAUR] = {
                "Down, dino!",
                "Big bites for a big dino!",
                "Don't eat me next!",
                "That's a toothpick for you, isn't it?",
                "The ground shook. Lunch is served.",
                "Tiny arms, huge appetite.",
                "Un'Goro's finest, fed by hand.",
                "Please don't stomp the vendor.",
                "One bite. One whole stack.",
                "Mind the hunter, big one.",
            },
            [F.CROCOLISK] = {
                "Crikey, {he} snapped that up fast!",
                "Snap snap!",
                "Mind the teeth!",
                "See you later, alligator!",
                "A death roll for a ration? Bit much.",
                "Are those crocodile tears of joy?",
                "Lurking pays off.",
                "Now back in the swamp you go.",
                "Smile! ...no, close it again.",
                "Chomp!",
            },
            [F.CORE_HOUND] = {
                "What a good little puppy!",
                "Aww, they're sharing.",
                "Hey, don't fight over it!",
                "Two heads, one bowl, zero patience.",
                "Hot food? Everything's hot to you.",
                "Don't breathe fire on the bag, please.",
                "Molten Core's goodest pup.",
                "Left head ate it. Right head is sulking.",
                "Is it still warm, or is that you?",
                "Lava-proof appetite.",
            },
            [F.CHIMAERA] = {
                "Hey, don't fight over it!",
                "Two heads, twice the appetite.",
                "Share nicely, both of you.",
                "Left head: yum. Right head: also yum.",
                "One body, two opinions.",
                "Who gets the last bite? Fight later.",
                "Double the chewing, double the drool.",
                "Two heads are better than one at dinner.",
                "Don't spit lightning at the food.",
                "Winterspring's finest, twice over.",
            },
            [F.BEAR] = {
                "Who's a big fuzzy bear? You are!",
                "Save some for hibernation!",
                "Bear-ly a snack!",
                "Straight into {his} winter fat.",
                "Bear hug for the hunter?",
                "Honey next time, promise.",
                "Don't hibernate on me now.",
                "Grrrr... crunch.",
                "Unbearably cute.",
                "Fuzzy, hungry, perfect.",
            },
            [F.BIRD_OF_PREY] = {
                "Who's a good bird?",
                "Swallowed whole!",
                "Keen eyes, empty belly. Not anymore!",
                "Talons off the bag!",
                "Owl be right back with more.",
                "Hoo's hungry? Hoo indeed.",
                "Swoop, grab, gone.",
                "Eyes like a hawk, manners like a pigeon.",
                "Don't drop it from a height this time.",
                "Feathered and fed.",
            },
            [F.TALLSTRIDER] = {
                "Good birdie!",
                "All neck and no manners!",
                "Peck peck peck!",
                "Watch it travel all the way down.",
                "Kick back and enjoy.",
                "Mulgore's finest strider.",
                "Don't peck the hunter.",
                "Long neck, short attention span.",
                "Legs for days, appetite for weeks.",
                "Strut to the bowl!",
            },
            [F.CARRION_BIRD] = {
                "Fresh, for a change!",
                "Not dead enough for you?",
                "A vulture with standards!",
                "No need to circle, it's right here.",
                "Patience pays off.",
                "Freshly not-dead.",
                "Waiting for me to drop? Not today.",
                "Picky eater, for a vulture.",
                "Dinner without the waiting.",
                "Scrap, scrap, gulp.",
            },
            [F.WIND_SERPENT] = {
                "Zap! Gone!",
                "Don't shock the hand that feeds you!",
                "Slurped right up!",
                "Feeding a sky noodle.",
                "Static cling on the snack.",
                "Coiled up and happy.",
                "Shocking appetite!",
                "Lightning fast.",
                "Don't wrap around me after dinner.",
                "Hiss and sparkle.",
            },
            [F.BAT] = {
                "Good little screecher!",
                "At least it's not blood.",
                "Eat up, little night flyer.",
                "Upside down is no way to eat.",
                "Echolocated: snack.",
                "Please don't screech at me.",
                "Night flyer, day snacker.",
                "Batty for food.",
                "Hang in there, more's coming.",
                "Squeak!",
            },
            [F.CRAB] = {
                "Snip snap!",
                "Does {he} eat sideways too?",
                "Pinch, pinch, gone!",
                "Feeling crabby? Not anymore.",
                "Shell out the snacks!",
                "Claws are not cutlery.",
                "Pinch me, I'm feeding a crab.",
                "Bubble bubble, munch munch.",
                "Scuttle to the bowl!",
                "Snappy service.",
            },
            [F.GORILLA] = {
                "Who's a good ape?",
                "No bananas? Fine, this will do.",
                "Ook ook!",
                "Chest-thumpingly good!",
                "Monkey business at dinner.",
                "Ape-solutely delicious.",
                "Don't throw it at me.",
                "King of the jungle? Close enough.",
                "Knuckle-walking to the bowl.",
                "Stranglethorn's finest table manners. So, none.",
            },
            [F.SCORPID] = {
                "Watch that stinger!",
                "Good... thing?",
                "Pinch and sting, what a combo!",
                "Tail up means happy, right?",
                "Sting-free feeding, please.",
                "Desert dining at its finest.",
                "Pincers, stinger, appetite.",
                "Don't sting the vendor.",
                "Crunchy outside, angry inside.",
                "Click click, nom.",
            },
            [F.TURTLE] = {
                "Slow and steady eats the snack.",
                "Take your time. Really.",
                "Shell yeah!",
                "This may take a while.",
                "Back in your shell, dinner's done.",
                "Hard shell, soft spot for snacks.",
                "Turtle-y awesome.",
                "Was that a bite or a nap?",
                "Fast food? Not here.",
                "Eats slow, eats everything.",
            },
        },
    },
}
