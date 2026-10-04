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
            [F.BOAR] = { "¡Buen cerdito!", "Oinc oinc, ñam ñam.", "¡Buscador de trufas de servicio!" },
            [F.CAT] = { "¡Buen gatito!", "¡Miau-ravilloso!", "¿Quién es el gatito más bonito?" },
            [F.HYENA] = { "¡Buen perro!", "¡Deja de reírte y come!", "¿Quién se ríe ahora?" },
            [F.WOLF] = { "¡Buen perro!", "¿Quién es un buen lobo?", "¡Auuuuu!" },
            [F.SPIDER] = {
                "¿De verdad tienes que envolverlo antes de comértelo?",
                "Ocho patas, un solo apetito.",
                "¡Nada de telarañas en mis dedos!",
            },
            [F.RAPTOR] = { "¡Abajo, dino!", "Chica lista...", "¡Tranquilo, asesino!" },
            [F.DEVILSAUR] = {
                "¡Abajo, dino!",
                "¡Grandes bocados para un gran dino!",
                "¡No me comas a mí después!",
            },
            [F.CROCOLISK] = { "¡Caramba, qué rápido lo ha atrapado!", "¡Ñac, ñac!", "¡Cuidado con los dientes!" },
            [F.CORE_HOUND] = {
                "¡Qué chiquitín más bueno!",
                "Ay, lo están compartiendo.",
                "¡Eh, no os peleéis por eso!",
            },
            [F.CHIMAERA] = {
                "¡Eh, no os peleéis por eso!",
                "Dos cabezas, el doble de apetito.",
                "Compartid bien, las dos.",
            },
            [F.BEAR] = {
                "¿Quién es un osito peludo? ¡Tú!",
                "¡Guarda algo para hibernar!",
                "¡Qué hambre de oso!",
            },
            [F.BIRD_OF_PREY] = {
                "¿Quién es un buen pájaro?",
                "¡Tragado de un bocado!",
                "Vista aguda, estómago vacío. ¡Ya no!",
            },
            [F.TALLSTRIDER] = { "¡Buen pajarito!", "¡Todo cuello y nada de modales!", "¡Pic, pic, pic!" },
            [F.CARRION_BIRD] = {
                "¡Fresco, para variar!",
                "¿No está lo bastante muerto para ti?",
                "¡Un carroñero con estilo!",
            },
            [F.WIND_SERPENT] = {
                "¡Zas! ¡Desaparecido!",
                "¡No electrocutes la mano que te da de comer!",
                "¡Sorbido de un trago!",
            },
            [F.BAT] = { "¡Buen murcielaguito!", "Al menos no es sangre.", "Come bien, pequeño volador nocturno." },
            [F.CRAB] = { "¡Chas, chas!", "¿También come de lado?", "¡Pinza, pinza, y fuera!" },
            [F.GORILLA] = {
                "¿Quién es un buen gorila?",
                "¿No hay plátanos? Bueno, esto servirá.",
                "¡Uh uh ah ah!",
            },
            [F.SCORPID] = { "¡Cuidado con el aguijón!", "¿Buen... bicho?", "Pinzar y picar, ¡qué combo!" },
            [F.TURTLE] = { "Despacito y con buena letra.", "Tómate tu tiempo. En serio.", "Sin prisa pero sin pausa." },
        },
    },
}
E.Locales.esMX = E.Locales.esES
