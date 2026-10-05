local _, E = ...
local F = E.Family

-- The feed sentence and the first lines of most lists come from Feed-O-Matic;
-- food-type lines, the families from Bear onwards and the extra family lines
-- were written for this addon.
E.Locales.frFR = {
    strings = {
        FEED = "donne à %s à manger un(e) %s. ",
        FEED_NO_FOOD = "nourrit %s. ",

        OPTION_ENABLED = "Envoyer les emotes",
        OPTION_ENABLED_NOTE = "Envoie un /emote chaque fois que vous nourrissez votre familier. "
            .. "Comme /fpe on et /fpe off.",
        OPTION_PET_NAME = "Toujours utiliser le nom du familier",
        OPTION_PET_NAME_NOTE = "Nomme le familier au lieu de dire il ou elle. Comme /fpe name on et off.",
        OPTION_DEBUG = "Trace de débogage",
        OPTION_DEBUG_NOTE = "Affiche dans le chat ce que l'addon voit pendant que vous nourrissez. Comme /fpe debug.",
        OPTION_CUSTOM_TITLE = "Vos propres phrases",
        OPTION_CUSTOM_NOTE = "Tirées au hasard comme les phrases intégrées. Marqueurs : %s. "
            .. "Comme /fpe add, /fpe list et /fpe remove.",
        OPTION_CUSTOM_ONLY = "N'utiliser que mes propres phrases",
        OPTION_CUSTOM_ONLY_NOTE = "Laisse de côté les phrases intégrées tant que vous en avez à vous. "
            .. "Comme /fpe only on et off.",
        OPTION_SHARED_LINES = "Partager mes phrases avec tous mes personnages",
        OPTION_SHARED_LINES_NOTE = "Une seule liste pour chaque personnage qui coche cette case ; sinon, ce "
            .. "personnage garde la sienne. Comme /fpe shared on et off.",
        OPTION_LIST_OWN = "Phrases de ce personnage (%d)",
        OPTION_LIST_SHARED = "Phrases partagées par tous les personnages (%d)",
        OPTION_NEW_LINE = "Nouvelle phrase",
        OPTION_EDIT_LINE = "Modifier la phrase %d",
        OPTION_CUSTOM_SAVE = "Enregistrer",
        OPTION_CUSTOM_CANCEL = "Annuler",
        OPTION_CUSTOM_EDIT = "Modifier",
        OPTION_COND_TITLE = "Seulement si",
        OPTION_COND_NOTE = "Rien de coché : toujours. Plusieurs cases sur une ligne : l'une suffit. "
            .. "Cases sur plusieurs lignes : chaque ligne doit correspondre.",
        OPTION_COND_GROUP_SEX = "Familier",
        OPTION_COND_GROUP_FOODTYPE = "Nourriture",
        OPTION_COND_GROUP_FAMILY = "Famille",
        OPTION_COND_MALE = "Mâle",
        OPTION_COND_FEMALE = "Femelle",
        OPTION_COND_BREAD = "Pain",
        OPTION_COND_MEAT = "Viande",
        OPTION_COND_FISH = "Poisson",
        OPTION_COND_CHEESE = "Fromage",
        OPTION_COND_FRUIT = "Fruit",
        OPTION_COND_FUNGUS = "Champignons",
        OPTION_COND_WOLF = "Loup",
        OPTION_COND_CAT = "Félin",
        OPTION_COND_SPIDER = "Araignée",
        OPTION_COND_BEAR = "Ours",
        OPTION_COND_BOAR = "Sanglier",
        OPTION_COND_CROCOLISK = "Crocilisque",
        OPTION_COND_CARRION_BIRD = "Charognard",
        OPTION_COND_CRAB = "Crabe",
        OPTION_COND_GORILLA = "Gorille",
        OPTION_COND_RAPTOR = "Raptor",
        OPTION_COND_TALLSTRIDER = "Haut-trotteur",
        OPTION_COND_SCORPID = "Scorpide",
        OPTION_COND_TURTLE = "Tortue",
        OPTION_COND_BAT = "Chauve-souris",
        OPTION_COND_HYENA = "Hyène",
        OPTION_COND_BIRD_OF_PREY = "Oiseau de proie",
        OPTION_COND_WIND_SERPENT = "Serpent des vents",
        OPTION_CUSTOM_ADD = "Ajouter",
        OPTION_CUSTOM_REMOVE = "Retirer",
        OPTION_CUSTOM_NONE = "Aucune phrase : tapez-en une ci-dessus et appuyez sur Entrée ou Ajouter.",
    },

    pronouns = {
        Il = { male = "Il", female = "Elle" },
    },

    emotes = {
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
        foodType = {
            bread = {
                "Des glucides ! De glorieux glucides !",
                "Tout chaud sorti du four.",
                "Qui a besoin de viande quand il y a du pain ?",
            },
            meat = {
                "Rien ne vaut un bon morceau de viande.",
                "Approuvé par les carnivores !",
                "Saignant, comme tu l'aimes.",
            },
            fish = { "Tout droit du port !", "Ça sent le poisson par ici...", "Sans sauce tartare, merci." },
            cheese = { "Ah, le fromage !", "Du fromage pour la bête !", "Un peu fort, juste comme il faut." },
            fruit = { "Une pomme par jour éloigne le vétérinaire !", "Plein de vitamines.", "Un choix sain !" },
            fungus = {
                "Ça va le faire planer...",
                "Tu es sûr qu'ils sont comestibles ?",
                "Des champignons, quel délice.",
            },
        },
        family = {
            [F.BOAR] = { "Bon cochon!", "Groin groin, miam miam.", "Chercheur de truffes en service !" },
            [F.CAT] = { "Bon minou!", "Ronron-parfait !", "C'est qui le joli minou ?" },
            [F.HYENA] = { "Bon chien!", "Arrête de rire et mange !", "Qui rit maintenant ?" },
            [F.WOLF] = { "Bon chien!", "C'est qui le bon loup ?", "Aouuuuh !" },
            [F.SPIDER] = {
                "Tu veux vraiment le recouvrir de bave avant de manger ça ?",
                "Huit pattes, un seul appétit.",
                "Pas de toile sur mes doigts !",
            },
            [F.RAPTOR] = { "Baisse toi, dino!", "Petite maligne...", "Doucement, le tueur !" },
            [F.DEVILSAUR] = { "Baisse toi, dino!", "Grosses bouchées pour un gros dino !", "Ne me mange pas après !" },
            [F.CROCOLISK] = { "Mange pas si vite satané croco!", "Clac clac !", "Attention aux dents !" },
            [F.CORE_HOUND] = {
                "C'est une bonne petite bête ça !",
                "Ho, faut savoir partager.",
                "Hey, combats pas sans ça!",
            },
            [F.CHIMAERA] = {
                "Hey, combats pas sans ça!",
                "Deux têtes, deux fois plus d'appétit.",
                "Partagez gentiment, toutes les deux.",
            },
            [F.BEAR] = {
                "C'est qui le gros nounours ? C'est toi !",
                "Garde-en pour l'hibernation !",
                "Une faim d'ours !",
            },
            [F.BIRD_OF_PREY] = {
                "C'est qui le bon oiseau ?",
                "Avalé tout rond !",
                "L'œil vif, le ventre vide. Plus maintenant !",
            },
            [F.TALLSTRIDER] = { "Gentil zoiseau !", "Que du cou et pas de manières !", "Pic, pic, pic !" },
            [F.CARRION_BIRD] = {
                "Du frais, pour une fois !",
                "Pas assez faisandé pour toi ?",
                "Un charognard aux goûts de luxe !",
            },
            [F.WIND_SERPENT] = {
                "Zap ! Disparu !",
                "On n'électrocute pas la main qui nourrit !",
                "Aspiré d'un coup !",
            },
            [F.BAT] = {
                "Gentille petite chauve-souris !",
                "Au moins, ce n'est pas du sang.",
                "Mange bien, petite créature de la nuit.",
            },
            [F.CRAB] = { "Clic, clac !", "{Il} mange aussi de travers ?", "Pince, pince, disparu !" },
            [F.GORILLA] = { "C'est qui le bon gorille ?", "Pas de bananes ? Bon, ça ira.", "Ouh ouh ah ah !" },
            [F.SCORPID] = { "Attention au dard !", "Gentille... bestiole ?", "Pincer et piquer, quel combo !" },
            [F.TURTLE] = {
                "Rien ne sert de courir...",
                "Prends ton temps. Vraiment.",
                "Bien à l'abri sous sa carapace !",
            },
        },
    },
}
