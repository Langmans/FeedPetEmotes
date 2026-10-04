local _, E = ...
local F = E.Family

-- Feed-O-Matic had a German feed sentence ("füttert %s ein %s"), tidied up
-- here, but never German emote lines; these follow the English ones and use
-- the German WoW names (Weitschreiter, Netherrochen).
E.Locales.deDE = {
    strings = {
        FEED = "füttert %s mit %s. ",
        FEED_NO_FOOD = "füttert %s. ",
    },

    emotes = {
        any = {
            "Mjam!",
            "Mmh, lecker.",
            "He! Pass auf die Finger auf!",
            "Om nom nom nom...",
            "Ein Happs und weg!",
            "Mmh, köstlich.",
            "Rülps!",
            "Juhu, Platz in der Tasche!",
        },
        male = { "Guter Junge!", "Braver Junge!", "Schluss mit Herrn Griesgram!" },
        female = { "Gutes Mädchen!", "Braves Mädchen!", "Schluss mit Frau Griesgram!" },
        food = {
            zesty = { "Mmh, würzig!" },
            mystery = {
                "Schmeckt wie Hühnchen.",
                "Schmeckt nach Weitschreiter!",
                "Schmeckt nach gut abgehangenem Gnom.",
                "Schmeckt nach... Spinne?",
            },
            chili = { "Uff, ist das scharf!" },
            watermelon = { "Was für ein großes Maul!" },
            cherryPie = { "So lecker, da weint selbst ein gestandener Mann." },
            warpBurger = { "Und jetzt noch eine Portion Netherrochen-Pommes?" },
            crunchy = { "Knusprig!" },
            minnow = { "Gibt's auch größere Fische?" },
            fungus = { "Abgefahren..." },
        },
        family = {
            [F.BOAR] = { "Braves Schweinchen!" },
            [F.CAT] = { "Feine Mieze!" },
            [F.HYENA] = { "Guter Hund!" },
            [F.WOLF] = { "Guter Hund!" },
            [F.SPIDER] = { "Musst du das wirklich erst einwickeln, bevor du es frisst?" },
            [F.RAPTOR] = { "Platz, Dino!" },
            [F.DEVILSAUR] = { "Platz, Dino!" },
            [F.CROCOLISK] = { "Mann, das war aber schnell weggeschnappt!" },
            [F.CORE_HOUND] = {
                "Was für ein braves Hündchen!",
                "Ach, die teilen sich das.",
                "He, streitet euch nicht darum!",
            },
            [F.CHIMAERA] = { "He, streitet euch nicht darum!" },
            [F.BEAR] = { "Wer ist ein großer flauschiger Bär? Du!", "Heb dir was für den Winterschlaf auf!" },
            [F.BIRD_OF_PREY] = { "Wer ist ein braver Vogel?", "Mit einem Happs verschlungen!" },
            [F.TALLSTRIDER] = { "Braves Vögelchen!", "Nur Hals und keine Manieren!" },
            [F.CARRION_BIRD] = { "Ausnahmsweise mal frisch!", "Noch nicht tot genug für dich?" },
            [F.WIND_SERPENT] = { "Zack! Weg!", "Nicht die Hand schocken, die dich füttert!" },
            [F.BAT] = { "Braver kleiner Kreischer!", "Immerhin kein Blut." },
            [F.CRAB] = { "Schnipp, schnapp!", "Frisst der auch seitwärts?" },
            [F.GORILLA] = { "Wer ist ein braver Affe?", "Keine Bananen? Na gut, das geht auch." },
            [F.SCORPID] = { "Vorsicht mit dem Stachel!", "Gutes... Ding?" },
            [F.TURTLE] = { "Immer mit der Ruhe.", "Lass dir Zeit. Wirklich." },
        },
    },
}
