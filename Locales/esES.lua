local _, E = ...
local F = E.Family

-- Spanish, for both esES and esMX. Feed sentence and emote lines from
-- Feed-O-Matic, except the families it never covered (Bear onwards).
E.Locales.esES = {
    strings = {
        FEED = "alimenta a %s con %s. ",
        FEED_NO_FOOD = "alimenta a %s. ",
    },

    emotes = {
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
            [F.BOAR] = { "¡Buen cerdito!" },
            [F.CAT] = { "¡Buen gatito!" },
            [F.HYENA] = { "¡Buen perro!" },
            [F.WOLF] = { "¡Buen perro!" },
            [F.RAPTOR] = { "¡Abajo, dino!" },
            [F.DEVILSAUR] = { "¡Abajo, dino!" },
            [F.CORE_HOUND] = { "¡Qué chiquitín más bueno!" },
            [F.BEAR] = { "¿Quién es un osito peludo? ¡Tú!", "¡Guarda algo para hibernar!" },
            [F.BIRD_OF_PREY] = { "¿Quién es un buen pájaro?", "¡Tragado de un bocado!" },
            [F.TALLSTRIDER] = { "¡Buen pajarito!", "¡Todo cuello y nada de modales!" },
            [F.CARRION_BIRD] = { "¡Fresco, para variar!", "¿No está lo bastante muerto para ti?" },
            [F.WIND_SERPENT] = { "¡Zas! ¡Desaparecido!", "¡No electrocutes la mano que te da de comer!" },
            [F.BAT] = { "¡Buen murcielaguito!", "Al menos no es sangre." },
            [F.CRAB] = { "¡Chas, chas!", "¿También come de lado?" },
            [F.GORILLA] = { "¿Quién es un buen gorila?", "¿No hay plátanos? Bueno, esto servirá." },
            [F.SCORPID] = { "¡Cuidado con el aguijón!", "¿Buen... bicho?" },
            [F.TURTLE] = { "Despacito y con buena letra.", "Tómate tu tiempo. En serio." },
        },
    },
}
E.Locales.esMX = E.Locales.esES
