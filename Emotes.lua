local _, E = ...

-- Emote lines taken from Fizzwidget Feed-O-Matic (github.com/fizzwidget/feed-o-matic).
-- One line is picked at random from every list that applies to the current
-- feeding: "any", the pet's gender, the food's group and the pet's family.
--
-- Food and family keys are locale-independent, so each locale only supplies
-- the lines. A locale without a table here gets the enUS lines; a locale
-- that lacks one list simply has fewer lines to pick from, it never mixes in
-- English.

-- Item ID -> food group used as key in each locale's `food` table.
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

-- CreatureFamily IDs, the second return of UnitCreatureFamily("pet").
-- Source: the CreatureFamily DB2 table (wago.tools/db2/CreatureFamily).
local WOLF, CAT, SPIDER, BOAR, CROCOLISK, RAPTOR = 1, 2, 3, 5, 6, 11
local HYENA, CHIMAERA, DEVILSAUR, CORE_HOUND = 25, 38, 39, 45

local emotes = {}

emotes.enUS = {
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
        [BOAR] = { "Good piggy!" },
        [CAT] = { "Nice kitty!" },
        [HYENA] = { "Good dog!" },
        [WOLF] = { "Good dog!" },
        [SPIDER] = { "Do you really have to wrap it up before eating it?" },
        [RAPTOR] = { "Down, dino!" },
        [DEVILSAUR] = { "Down, dino!" },
        [CROCOLISK] = { "Crikey, it snapped that up fast!" },
        [CORE_HOUND] = {
            "What a good little puppy!",
            "Aww, they're sharing.",
            "Hey, don't fight over it!",
        },
        [CHIMAERA] = { "Hey, don't fight over it!" },
    },
}

emotes.esES = {
    any = {
        "¡Ñam!",
        "Mmm, está rico.",
        "¡Ehh! ¡Cuidado con mis dedos!",
        "Om nom nom nom...",
        "¡Un mordisco y listo!",
        "Mmm, delicioso.",
        "¡Gurps!",
    },
    male = { "¡Buen chico!" },
    female = { "¡Buena chica!" },
    food = {
        zesty = { "¡Mmm, sabrosa!" },
        mystery = {
            "Sabe a pollo.",
            "¡Sabe a zancudo!",
            "Sabe a gnomo viejo.",
            "Sabe a... ¿araña?",
        },
        chili = { "¡Guau, picante!" },
        watermelon = { "¡Vaya bocaza!" },
    },
    family = {
        [BOAR] = { "¡Buen cerdito!" },
        [CAT] = { "¡Buen gatito!" },
        [HYENA] = { "¡Buen perro!" },
        [WOLF] = { "¡Buen perro!" },
        [RAPTOR] = { "¡Abajo, dino!" },
        [DEVILSAUR] = { "¡Abajo, dino!" },
        [CORE_HOUND] = { "¡Qué chiquitín más bueno!" },
    },
}
emotes.esMX = emotes.esES

emotes.frFR = {
    any = {
        "Miam!",
        "Mmm, bonne bouffe.",
        "Hey! attention à mes doigts!",
        "Hum gloup gloup gloup gloup...",
        "Encore une bouchée et ca ira!",
        "Mmm, délicieux.",
        "Burp!",
        "Oui, un peu plus de place dans le sac!",
    },
    male = { "Bon garçon!", "Attrape garçon!", "Pas plus monsieur le goinfre!" },
    female = { "Bonne fille!", "Attrape ma fille!", "Pas plus madame la goinfre!" },
    food = {
        zesty = { "Mmm, du crabe!" },
        mystery = {
            "Ca a un gout de poulet.",
            "Ca a un gout bouillie pour bébé!",
            "Ca a un gout de vieux gnome!",
            "Ca a un gout d'... araignée?",
        },
        chili = { "La vache, c'est épicé!" },
        watermelon = { "Quelle grande bouche!" },
        cherryPie = { "C'est si bon, ca en ferait hurler un muet." },
        crunchy = { "Crrrrrr!" },
        minnow = { "On dirait de la friture, T'as pas un plus gros poisson?" },
    },
    family = {
        [BOAR] = { "Bon cochon!" },
        [CAT] = { "Bon minou!" },
        [HYENA] = { "Bon chien!" },
        [WOLF] = { "Bon chien!" },
        [SPIDER] = { "Tu veux vraiment le recouvrir de bave avant de manger ça ?" },
        [RAPTOR] = { "Baisse toi, dino!" },
        [DEVILSAUR] = { "Baisse toi, dino!" },
        [CROCOLISK] = { "Mange pas si vite satané croco!" },
        [CORE_HOUND] = {
            "C'est une bonne petite bête ça !",
            "Ho, faut savoir partager.",
            "Hey, combats pas sans ça!",
        },
        [CHIMAERA] = { "Hey, combats pas sans ça!" },
    },
}

emotes.koKR = {
    any = {
        "얌얌!",
        "음~, 맛나네요.",
        "손가락 핥지마!",
        "이 보잘 것 없는 먹이로 얼마나 버틸성 싶으냐!",
        "내것도 좀 남겨놔라!",
        "먹어봐라, 이 집은 이게 죽여준다.",
        "꺼억~!",
        "어예~, 가방 한칸 빈다!",
    },
    male = { "잘했어!", "남기지마 시키야!", "이 보잘 것 없는 먹이로 얼마나 버틸성 싶으냐!" },
    female = { "잘했어!", "착하네!", "이 보잘 것 없는 먹이로 얼마나 버틸성 싶으냐!" },
    food = {
        zesty = { "톡 쏘는군요!" },
        mystery = {
            "닭고기 같기도 하고...",
            "타조 맛이지?!",
            "늙은 노움 맛 날거야.",
            "음..맛이...거미같나?",
        },
        chili = { "와우! 화끈하구나!" },
        watermelon = { "입 크게 벌려!" },
        cherryPie = { "사나이 울리는 체리파이." },
        warpBurger = { "다음엔 가오리 튀김으로?" },
        crunchy = { "아삭아삭하네!" },
        minnow = { "좀 더 큰걸로 줘?" },
        fungus = { "몽롱하네요..." },
    },
    family = {
        [BOAR] = { "잘했어 뚱띠!" },
        [CAT] = { "착하다 야옹이!" },
        [HYENA] = { "잘먹네, 우리 메리해피도꾸워리쫑!" },
        [WOLF] = { "잘먹네, 우리 메리해피도꾸워리쫑!" },
        [SPIDER] = { "먹기전에 꼭 거미줄로 감아야 되?" },
        [RAPTOR] = { "맛있냐!" },
        [DEVILSAUR] = { "맛있냐!" },
        [CROCOLISK] = { "깨물어! 깨물어!" },
        [CORE_HOUND] = {
            "착하네, 우리 메리해피도꾸워리쫑!",
            "머리가 둘이라고 반씩 노나 먹냐.",
            "먹이 갖고 싸우지 마라!",
        },
        [CHIMAERA] = { "그만 날고 얼른 먹어!" },
    },
}

emotes.ruRU = {
    any = {
        "О да!",
        "Ммм, хороша з....а.",
        "Эээ! Осторожно, пальцы!",
        "Ам ням ням ням...",
        "Прогладил всё, сразу, не разжевывая!",
        "Ммм, восхитительно.",
        "Отрыгивает!",
        "Чумааа!",
    },
    male = { "Хороший мальчик!", "Ах ты май малыш!", "Молодчина!" },
    female = { "Хорошая девочка!", "Ух ты мая малышка!", "Умница!" },
    food = {
        zesty = { "Ммм, Острое!" },
        mystery = {
            "На вкус как курица.",
            "На вкус как долгоног!",
            "На вкус как гном переросток.",
            "На вкус как... паук?",
        },
        chili = { "Уф, и в правду Дыхание дракона!" },
        watermelon = { "Какой большой рот!" },
        cherryPie = { "На вкус не плохо, вот бы начинки побольше." },
        warpBurger = { "А что насчет запеченых Скатов Пустоты?" },
        crunchy = { "Хрущащий!" },
        minnow = { "Может есть рыбешка побольше?" },
        fungus = { "Странный вкус..." },
    },
    family = {
        [BOAR] = { "Хорошая свинка!" },
        [CAT] = { "Славная киска!" },
        [HYENA] = { "Хороший пёсик!" },
        [WOLF] = { "Хороший пёсик!" },
        [SPIDER] = { "Ты серьёзна бедешь окутывать это перед едой?" },
        [RAPTOR] = { "Пригнись, дино!" },
        [DEVILSAUR] = { "Пригнись, дино!" },
        [CROCOLISK] = { "Ну надо же, как быстро слопал!" },
        [CORE_HOUND] = {
            "Хороший маленький щеночек!",
            "Да, вот значит как они делятся.",
            "Эй вы оба, не деритесь!",
        },
        [CHIMAERA] = { "Эй вы оба, не деритесь!" },
    },
}

E.Emotes = emotes[GetLocale()] or emotes.enUS
