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
        },
        foodType = {
            bread = {
                "Kohlenhydrate! Herrliche Kohlenhydrate!",
                "Frisch aus dem Ofen.",
                "Wer braucht Fleisch, wenn es Brot gibt?",
            },
            meat = {
                "Nichts geht über ein gutes Stück Fleisch.",
                "Fleischfresser-geprüft!",
                "Medium, genau wie du es magst.",
            },
            fish = { "Frisch vom Hafen!", "Hier riecht's irgendwie fischig...", "Ohne Remoulade, bitte." },
            cheese = {
                "Käse für die Bestie!",
                "Ein bisschen stinkig, genau wie es sein soll.",
                "Bitte lächeln: Käse!",
            },
            fruit = { "Ein Apfel am Tag, und der Tierarzt bleibt weg!", "Schön Vitamine tanken.", "Gesunde Wahl!" },
            fungus = { "Abgefahren...", "Bist du sicher, dass die essbar sind?", "Pilze? Na, wenn's schmeckt." },
        },
        family = {
            [F.BOAR] = { "Braves Schweinchen!", "Grunz grunz, mampf mampf.", "Trüffelschwein im Einsatz!" },
            [F.CAT] = { "Feine Mieze!", "Schnurr-fekt!", "Wer ist eine hübsche Mieze?" },
            [F.HYENA] = { "Guter Hund!", "Hör auf zu lachen und friss!", "Wer lacht jetzt?" },
            [F.WOLF] = { "Guter Hund!", "Wer ist ein braver Wolf?", "Auuuuu!" },
            [F.SPIDER] = {
                "Musst du das wirklich erst einwickeln, bevor du es frisst?",
                "Acht Beine, ein Hunger.",
                "Keine Spinnweben an meine Finger!",
            },
            [F.RAPTOR] = { "Platz, Dino!", "Kluges Mädchen...", "Ganz ruhig, Killer!" },
            [F.DEVILSAUR] = {
                "Platz, Dino!",
                "Große Happen für einen großen Dino!",
                "Friss mich nicht als Nächstes!",
            },
            [F.CROCOLISK] = { "Mann, das war aber schnell weggeschnappt!", "Schnapp, schnapp!", "Vorsicht, Zähne!" },
            [F.CORE_HOUND] = {
                "Was für ein braves Hündchen!",
                "Ach, die teilen sich das.",
                "He, streitet euch nicht darum!",
            },
            [F.CHIMAERA] = {
                "He, streitet euch nicht darum!",
                "Zwei Köpfe, doppelter Hunger.",
                "Teilt schön, ihr beiden.",
            },
            [F.BEAR] = {
                "Wer ist ein großer flauschiger Bär? Du!",
                "Heb dir was für den Winterschlaf auf!",
                "Was für ein Bärenhunger!",
            },
            [F.BIRD_OF_PREY] = {
                "Wer ist ein braver Vogel?",
                "Mit einem Happs verschlungen!",
                "Scharfe Augen, leerer Magen. Jetzt nicht mehr!",
            },
            [F.TALLSTRIDER] = { "Braves Vögelchen!", "Nur Hals und keine Manieren!", "Pick, pick, pick!" },
            [F.CARRION_BIRD] = {
                "Ausnahmsweise mal frisch!",
                "Noch nicht tot genug für dich?",
                "Ein Geier mit Ansprüchen!",
            },
            [F.WIND_SERPENT] = {
                "Zack! Weg!",
                "Nicht die Hand schocken, die dich füttert!",
                "Einfach weggeschlürft!",
            },
            [F.BAT] = { "Braver kleiner Kreischer!", "Immerhin kein Blut.", "Iss schön, kleiner Nachtflieger." },
            [F.CRAB] = { "Schnipp, schnapp!", "Frisst der auch seitwärts?", "Zwick, zwick, weg!" },
            [F.GORILLA] = { "Wer ist ein braver Affe?", "Keine Bananen? Na gut, das geht auch.", "Uh uh ah ah!" },
            [F.SCORPID] = { "Vorsicht mit dem Stachel!", "Gutes... Ding?", "Zwicken und stechen, was für eine Kombi!" },
            [F.TURTLE] = { "Immer mit der Ruhe.", "Lass dir Zeit. Wirklich.", "Panzerstark!" },
        },
    },
}
