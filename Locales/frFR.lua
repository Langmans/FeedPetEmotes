local _, E = ...
local F = E.Family

-- Feed sentence and emote lines from Feed-O-Matic, except the families it
-- never covered (Bear onwards).
E.Locales.frFR = {
    strings = {
        FEED = "donne à %s à manger un(e) %s. ",
        FEED_NO_FOOD = "nourrit %s. ",
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
        family = {
            [F.BOAR] = { "Bon cochon!" },
            [F.CAT] = { "Bon minou!" },
            [F.HYENA] = { "Bon chien!" },
            [F.WOLF] = { "Bon chien!" },
            [F.SPIDER] = { "Tu veux vraiment le recouvrir de bave avant de manger ça ?" },
            [F.RAPTOR] = { "Baisse toi, dino!" },
            [F.DEVILSAUR] = { "Baisse toi, dino!" },
            [F.CROCOLISK] = { "Mange pas si vite satané croco!" },
            [F.CORE_HOUND] = {
                "C'est une bonne petite bête ça !",
                "Ho, faut savoir partager.",
                "Hey, combats pas sans ça!",
            },
            [F.CHIMAERA] = { "Hey, combats pas sans ça!" },
            [F.BEAR] = { "C'est qui le gros nounours ? C'est toi !", "Garde-en pour l'hibernation !" },
            [F.BIRD_OF_PREY] = { "C'est qui le bon oiseau ?", "Avalé tout rond !" },
            [F.TALLSTRIDER] = { "Gentil zoiseau !", "Que du cou et pas de manières !" },
            [F.CARRION_BIRD] = { "Du frais, pour une fois !", "Pas assez faisandé pour toi ?" },
            [F.WIND_SERPENT] = { "Zap ! Disparu !", "On n'électrocute pas la main qui nourrit !" },
            [F.BAT] = { "Gentille petite chauve-souris !", "Au moins, ce n'est pas du sang." },
            [F.CRAB] = { "Clic, clac !", "Il mange de travers, lui aussi ?" },
            [F.GORILLA] = { "C'est qui le bon gorille ?", "Pas de bananes ? Bon, ça ira." },
            [F.SCORPID] = { "Attention au dard !", "Gentille... bestiole ?" },
            [F.TURTLE] = { "Rien ne sert de courir...", "Prends ton temps. Vraiment." },
        },
    },
}
