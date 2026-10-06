-- The whole feeding path, from picking the food to the /emote, plus the slash commands.

local function emoteLine(client, sent, prefix)
    startsWith(sent.text, prefix)
    return sent.text:sub(#prefix + 1)
end

test("feeding sends one emote naming the pet and the food", function()
    local client = NewClient():login()
    client:feed(12037)
    eq(#client.sent, 1)
    eq(client.sent[1].kind, "EMOTE")
    local line = emoteLine(client, client.sent[1], "feeds Fluffy a " .. ItemLink(12037) .. ". ")
    -- The pool holds lines with their placeholders ({boy}, {his}) unfilled.
    local filled = {}
    for i, pooled in ipairs(client.E.EmotePool(12037)) do
        filled[i] = client.E.FillPlaceholders(pooled, "Fluffy", "Mystery Meat")
    end
    contains(filled, line)
end)

test("dragging food onto the pet names the food", function()
    local client = NewClient():login()
    client:dragFeed(4536)
    eq(#client.sent, 1)
    startsWith(client.sent[1].text, "feeds Fluffy a " .. ItemLink(4536) .. ". ")
end)

test("food put back on the bags long before a cast is not named", function()
    local client = NewClient():login()
    client:dragFeed(4536, 5)
    startsWith(client:lastSent().text, "feeds Fluffy. ")
end)

test("a dragged food is used for one cast only", function()
    local client = NewClient():login()
    client:dragFeed(4536)
    client:castSucceeded()
    client:settle()
    startsWith(client.sent[2].text, "feeds Fluffy. ")
end)

test("food picked as Feed Pet's target wins over an earlier dragged item", function()
    local client = NewClient():login()
    client:pickUp(4536)
    client:release()
    client:feed(117)
    startsWith(client:lastSent().text, "feeds Fluffy a " .. ItemLink(117) .. ". ")
end)

test("a secret item ID on the cursor is ignored", function()
    local client = NewClient():login()
    client:slash("debug")
    client.secret[4536] = true
    client:dragFeed(4536)
    startsWith(client:lastSent().text, "feeds Fluffy. ")
    ok(client:printedContains("item on cursor, but its item ID is unavailable"))
    ok(client:printedContains("Feed Pet cast seen; food unknown"))
end)

test("/fpe debug and selftest show the dragged food", function()
    local client = NewClient():login()
    client:slash("debug")
    client:dragFeed(4536)
    ok(client:printedContains("item on cursor: item 4536"))
    ok(client:printedContains("cursor released: item 4536"))
    ok(client:printedContains("Feed Pet cast seen; food item 4536 (cursor)"))
    client:slash("selftest")
    ok(client:printedContains("Last food picked: item 4536 (Shiny Red Apple)"))
end)

test("{pet} in a line becomes the pet's name", function()
    local client = NewClient():login()
    client.pet.familyID = 999
    client.pet.sex = 1
    client.E.Emotes.any = { "Just how {pet} likes it, {pet}!" }
    client:castSucceeded()
    eq(client:lastSent().text, "feeds Fluffy. Just how Fluffy likes it, Fluffy!")
end)

test("food eaten from the bags right after the cast is named", function()
    local client = NewClient():login()
    client:slash("debug")
    client:spellbookFeed(4540)
    eq(#client.sent, 1, "sent as soon as the bags showed the food gone")
    startsWith(client.sent[1].text, "feeds Fluffy a " .. ItemLink(4540) .. ". ")
    ok(client:printedContains("Feed Pet cast seen; food unknown, waiting for the bags"))
    ok(client:printedContains("food eaten: item 4540"))
end)

test("food eaten from the bags just before the cast is named", function()
    local client = NewClient():login()
    client:slash("debug")
    client:spellbookFeed(4540, true)
    eq(#client.sent, 1, "sent at once")
    startsWith(client.sent[1].text, "feeds Fluffy a " .. ItemLink(4540) .. ". ")
    ok(client:printedContains("Feed Pet cast seen; food item 4540 (eaten)"))
end)

test("without food leaving the bags the emote goes after a second, without food", function()
    local client = NewClient():login()
    client:castSucceeded()
    eq(#client.sent, 0, "still waiting")
    client:advance(0.5)
    eq(#client.sent, 0, "still waiting at half a second")
    client:advance(0.6)
    eq(#client.sent, 1)
    startsWith(client.sent[1].text, "feeds Fluffy. ")
end)

test("a waiting cast sends only once", function()
    local client = NewClient():login()
    client:spellbookFeed(4540)
    client:settle()
    eq(#client.sent, 1)
end)

test("food eaten long before the cast is not named", function()
    local client = NewClient():login()
    client:stock(4540, 3)
    client:eat(4540)
    client:advance(5)
    client:castSucceeded()
    startsWith(client:lastSent().text, "feeds Fluffy. ")
end)

test("items gained or moved are not taken as eaten", function()
    local client = NewClient():login()
    client:stock(4540, 3)
    client:stock(4540, 5)
    client:castSucceeded()
    startsWith(client:lastSent().text, "feeds Fluffy. ")
end)

test("known food does not wait for the bags", function()
    local client = NewClient():login()
    client:feed(117)
    eq(#client.sent, 1)
    client:dragFeed(4536)
    eq(#client.sent, 2)
end)

test("counting the bags builds no item info tables", function()
    local client = NewClient():login()
    client:stock(4540, 3)
    client:stock(117, 2)
    client.calls.GetContainerItemInfo = 0
    client:eat(4540)
    eq(client.calls.GetContainerItemInfo, 0)
end)

test("counting the bags reuses the same two tables", function()
    local client = NewClient():login()
    local tracker = client.E.FoodTracker
    client:stock(4540, 3)
    local first = tracker.bagCounts
    client:stock(4540, 2)
    local second = tracker.bagCounts
    client:stock(4540, 1)
    ok(first ~= second, "the previous count is kept apart from the new one")
    ok(tracker.bagCounts == first, "the third scan reuses the first table")
end)

test("an eaten item with a secret item ID is ignored", function()
    local client = NewClient():login()
    client.secret[4540] = true
    client:spellbookFeed(4540)
    startsWith(client:lastSent().text, "feeds Fluffy. ")
end)

test("food picked too long before the cast is not named", function()
    local client = NewClient():login()
    client:feed(12037, 5)
    startsWith(client:lastSent().text, "feeds Fluffy. ")
end)

test("an item used while no spell is targeting is not taken as food", function()
    local client = NewClient():login()
    client:pickItem(12037, false)
    client:castSucceeded()
    startsWith(client:lastSent().text, "feeds Fluffy. ")
end)

test("the picked food is used for one cast only", function()
    local client = NewClient():login()
    client:feed(12037)
    client:castSucceeded()
    client:settle()
    startsWith(client.sent[2].text, "feeds Fluffy. ")
end)

test("an uncached food name still sends, without the name", function()
    local client = NewClient():login()
    client:feed(99999)
    startsWith(client:lastSent().text, "feeds Fluffy. ")
end)

test("other spells send nothing", function()
    local client = NewClient():login()
    client:pickItem(12037)
    client:castSucceeded(133)
    eq(#client.sent, 0)
end)

test("a cast reported for another unit sends nothing", function()
    local client = NewClient():login()
    client:pickItem(12037)
    client:castSucceeded(nil, "pet")
    eq(#client.sent, 0)
end)

test("a secret spell ID is ignored", function()
    local client = NewClient():login()
    client.secret[6991] = true
    client:feed(12037)
    eq(#client.sent, 0)
end)

test("no pet name, or a secret one, sends nothing", function()
    local client = NewClient():login()
    client.pet.name = nil
    client:feed(12037)
    client.pet.name = "Fluffy"
    client.secret.Fluffy = true
    client:feed(12037)
    eq(#client.sent, 0)
end)

test("every registered event has a handler method on its frame", function()
    local client = NewClient():login()
    local missing = {}
    for _, frame in ipairs(client.frames) do
        for event in pairs(frame.events) do
            if type(frame[event]) ~= "function" then missing[#missing + 1] = event end
        end
        for event in pairs(frame.unitEvents) do
            if type(frame[event]) ~= "function" then missing[#missing + 1] = event end
        end
    end
    table.sort(missing)
    eq(#missing, 0, "no handler for " .. table.concat(missing, ", "))
end)

test("nothing happens before the addon's own ADDON_LOADED", function()
    local client = NewClient()
    client:fire("ADDON_LOADED", "SomeOtherAddon")
    client:feed(12037)
    eq(#client.sent, 0)
end)

test("the emote uses the old SendChatMessage when C_ChatInfo is missing", function()
    local client = NewClient({ noChatInfo = true }):login()
    client:feed(12037)
    eq(#client.sent, 1)
end)

test("without any chat send function nothing is sent and debug says why", function()
    local client = NewClient({ noChat = true }):login()
    client:slash("debug")
    client:feed(12037)
    eq(#client.sent, 0)
    ok(client:printedContains("no emote: no chat send function"))
    client:slash("selftest")
    ok(client:printedContains("send function: missing"))
end)

test("a food whose item ID is secret is not named", function()
    local client = NewClient():login()
    client:slash("debug")
    client.secret[12037] = true
    client:feed(12037)
    ok(client:printedContains("food picked, but its item ID is unavailable"))
    startsWith(client:lastSent().text, "feeds Fluffy. ")
end)

test("a client without secret values works", function()
    local client = NewClient({ noSecretValues = true }):login()
    client:feed(12037)
    eq(#client.sent, 1)
end)

test("a German client sends a German emote", function()
    local client = NewClient({ locale = "deDE" }):login()
    client:feed(117)
    -- The simulated client has English item names only.
    startsWith(client:lastSent().text, "füttert Fluffy mit " .. ItemLink(117) .. ". ")
end)

test("/fpe off stops the emotes and is saved; /fpe on resumes", function()
    local client = NewClient():login()
    client:slash("off")
    eq(Saved().enabled, false)
    client:feed(12037)
    eq(#client.sent, 0)
    client:slash("ON")
    client:feed(12037)
    eq(#client.sent, 1)
end)

test("settings are saved per character as FeedPetEmotesDBPC", function()
    eq(TOC_SAVED_PER_CHARACTER, "FeedPetEmotesDBPC")
    NewClient():login()
    eq(type(FeedPetEmotesDBPC), "table")
end)

test("saved settings from a previous session are kept", function()
    local client = NewClient({ savedDB = { enabled = false } }):login()
    client:feed(12037)
    eq(#client.sent, 0)
end)

test("broken saved settings are repaired", function()
    NewClient({ savedDB = { enabled = "yes" } }):login()
    eq(Saved().enabled, true)
    eq(rawget(Saved(), "enabled"), nil)
end)

test("logging out saves only the settings that differ from their default", function()
    local client = NewClient({ savedDB = { petName = false, debug = true } }):login()
    client:slash("off")
    client:fire("PLAYER_LOGOUT")
    eq(rawget(Saved(), "enabled"), false)
    eq(rawget(Saved(), "debug"), true)
    eq(rawget(Saved(), "petName"), nil)
    eq(rawget(Saved(), "customChance"), nil)
    eq(rawget(Saved(), "customFallback"), nil)
    -- Still readable after the strip, in case anything runs after logout.
    eq(Saved().petName, false)
    eq(Saved().customFallback, true)
end)

test("logging out strips the defaults on other classes too", function()
    local client = NewClient({ class = "MAGE", savedDB = { enabled = true } }):login()
    client:fire("PLAYER_LOGOUT")
    eq(rawget(Saved(), "enabled"), nil)
end)

test("/fpe test previews locally and sends nothing", function()
    local client = NewClient():login()
    client:slash("test")
    eq(#client.sent, 0)
    ok(client:printedContains("Langmans feeds Fluffy a " .. ItemLink(12037) .. ". "), "no preview printed")
end)

test("/fpe test without a pet says so", function()
    local client = NewClient():login()
    client.pet = nil
    client:slash("test")
    ok(client:printedContains("Summon your pet first."))
end)

test("/fpe without a command prints the status", function()
    local client = NewClient():login()
    client:slash("")
    ok(client:printedContains("Emotes are on."))
end)

test("/fpe selftest reports pet, family and the feeding path without sending", function()
    local client = NewClient():login()
    client:slash("selftest")
    ok(client:printedContains("Client 1.60.1 (70170), interface 16001, locale enUS, using enUS."))
    ok(client:printedContains("send function: C_ChatInfo.SendChatMessage; secret values: yes."))
    ok(client:printedContains("Feed Pet known: true"))
    ok(client:printedContains("Pet Fluffy: family Cat, id 2, sex 2."))
    ok(client:printedContains("No food picked since login"))
    client:feed(12037)
    client.printed = {}
    client:slash("selftest")
    ok(client:printedContains("Last food picked: item 12037 (Mystery Meat)"))
    ok(client:printedContains("Last Feed Pet cast seen"))
    eq(#client.sent, 1, "only the real feed sent something")
end)

test("/fpe selftest shows secret values and a missing pet", function()
    local client = NewClient():login()
    client.secret[2] = true
    client:slash("selftest")
    ok(client:printedContains("id <secret>"))
    client.pet = nil
    client:slash("selftest")
    ok(client:printedContains("No pet out"))
end)

test("/fpe debug is saved and still on after a reload", function()
    local client = NewClient():login()
    client:slash("debug")
    eq(Saved().debug, true)
    local reloaded = NewClient({ savedDB = Saved() }):login()
    reloaded:feed(12037)
    ok(reloaded:printedContains("Feed Pet cast seen; food item 12037 (targeted)"))
    reloaded:slash("debug")
    eq(Saved().debug, false)
end)

test("a broken debug setting is repaired", function()
    NewClient({ savedDB = { enabled = true, debug = "yes" } }):login()
    eq(Saved().debug, false)
end)

test("/fpe debug traces the feeding path", function()
    local client = NewClient():login()
    client:slash("debug")
    client:feed(12037)
    ok(client:printedContains("food picked: item 12037"))
    ok(client:printedContains("Feed Pet cast seen; food item 12037 (targeted)"))
    ok(client:printedContains("sending via C_ChatInfo.SendChatMessage"))
    client:slash("debug")
    client.printed = {}
    client:feed(12037)
    eq(#client.printed, 0, "debug off prints nothing")
end)
