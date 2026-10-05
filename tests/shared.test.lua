-- Own lines shared by the account (FeedPetEmotesDB) versus this character's
-- own (FeedPetEmotesDBPC), chosen per character with /fpe shared or the panel.

test("a new account gets an empty shared list; a character starts unshared", function()
    NewClient():login()
    eq(#SavedAccount().customLines, 0)
    eq(Saved().sharedLines, false)
end)

test("a broken shared list is repaired; entries that are not text are dropped", function()
    NewClient({ savedAccountDB = { customLines = { "Keep me.", false } } }):login()
    eq(#SavedAccount().customLines, 1)
    NewClient({ savedAccountDB = "nope" }):login()
    eq(#SavedAccount().customLines, 0)
end)

test("with shared on, add and remove change the account's list, not the character's", function()
    local client = NewClient():login()
    client:slash("add Mine.")
    client:slash("shared on")
    ok(client:printedContains("lines shared by all your characters (0)"))
    client:slash("add Ours.")
    client:slash("add Also ours.")
    client:slash("remove 1")
    eq(table.concat(SavedAccount().customLines, "|"), "Also ours.")
    eq(table.concat(Saved().customLines, "|"), "Mine.")
end)

test("switching back to unshared uses the character's own list again", function()
    local client = NewClient():login()
    client:slash("add Mine.")
    client:slash("shared on")
    client:slash("add Ours.")
    client:slash("chance 100")
    client:slash("shared off")
    ok(client:printedContains("uses its own lines (1)"))
    client:castSucceeded()
    eq(client:lastSent().text, "feeds Fluffy. Mine.")
end)

test("a second character that shares sees the first one's lines", function()
    local first = NewClient():login()
    first:slash("shared on")
    first:slash("add Ours.")
    local account = SavedAccount()
    local second = NewClient({ savedAccountDB = account, savedDB = { sharedLines = true, customChance = 100 } })
    second:login()
    second:castSucceeded()
    eq(second:lastSent().text, "feeds Fluffy. Ours.")
    local loner = NewClient({ savedAccountDB = account, savedDB = { customChance = 100 } }):login()
    loner:castSucceeded()
    ok(loner:lastSent().text ~= "feeds Fluffy. Ours.", "an unshared character ignores the shared lines")
end)

test("/fpe shared without on or off changes nothing", function()
    local client = NewClient():login()
    client:slash("shared maybe")
    eq(Saved().sharedLines, false)
    ok(client:printedContains("Emotes are on. Commands:"))
end)

test("ticking shared in the panel switches the list it shows", function()
    local client = NewClient():login()
    client:slash("add Mine.")
    client:slash("shared on")
    client:slash("add Ours.")
    client:slash("shared off")
    client.optionsPanel.scripts.OnShow(client.optionsPanel)
    local box
    for _, frame in ipairs(client.frames) do
        if frame.kind == "CheckButton" and frame.Text:GetText() == "Share my lines with all characters" then
            box = frame
        end
    end
    local function rowShown(text)
        for _, region in ipairs(client.fontStrings) do
            if region:GetText() == text and region.shown then return true end
        end
        return false
    end
    ok(rowShown("1. Mine."))
    box:SetChecked(true)
    box.scripts.OnClick(box)
    eq(Saved().sharedLines, true)
    ok(rowShown("1. Ours."))
end)

test("/fpe selftest says which list is in use", function()
    local client = NewClient():login()
    client:slash("selftest")
    ok(client:printedContains("Own lines: 0, this character's"))
    client:slash("shared on")
    client:slash("selftest")
    ok(client:printedContains("Own lines: 0, shared by the account"))
end)
