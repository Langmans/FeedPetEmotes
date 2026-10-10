-- When the emote is sent (Sender.lua): Forever only lets an addon send chat
-- inside a hardware event, so the emote built at the Feed Pet cast waits for
-- the next key press or click in the game world, for at most ten seconds.

test("the emote waits for a key press and is sent inside it", function()
    local client = NewClient():login()
    client:feed(12037)
    client:advance(3)
    eq(#client.sent, 0, "nothing sent from the cast event or a timer")
    client:pressKey("W")
    eq(#client.sent, 1)
    eq(client.sent[1].kind, "EMOTE")
    client:pressKey("W")
    eq(#client.sent, 1, "a second key press sends nothing more")
end)

test("a click in the game world sends it as well", function()
    local client = NewClient():login()
    client:feed(12037)
    client:clickWorld()
    eq(#client.sent, 1)
    client:clickWorld()
    eq(#client.sent, 1)
end)

test("the key frame is shown only while an emote waits", function()
    local client = NewClient():login()
    local keys
    for _, frame in ipairs(client.frames) do
        if frame.scripts.OnKeyDown then keys = frame end
    end
    eq(keys:IsShown(), false)
    client:feed(12037)
    eq(keys:IsShown(), true)
    client:pressKey()
    eq(keys:IsShown(), false)
end)

test("loaded in combat, keys are not watched until combat ends; clicks still send", function()
    local client = NewClient({ inCombat = true }):login()
    local keys
    for _, frame in ipairs(client.frames) do
        if frame.scripts.OnKeyDown then keys = frame end
    end
    client:feed(12037)
    eq(keys:IsShown(), false, "a shown frame without propagation would swallow keys")
    client:clickWorld()
    eq(#client.sent, 1)
    client.inCombat = false
    client:fire("PLAYER_REGEN_ENABLED")
    client:feed(12037)
    eq(keys:IsShown(), true)
    client:pressKey()
    eq(#client.sent, 2)
end)

test("an emote not sent within ten seconds is dropped", function()
    local client = NewClient():login()
    client:slash("debug")
    client:feed(12037)
    client:advance(11)
    client:pressKey()
    eq(#client.sent, 0)
    ok(client:printedContains("no emote: no key press or click within 10s"))
end)

test("a key press just before the timeout still sends", function()
    local client = NewClient():login()
    client:feed(12037)
    client:advance(9.5)
    client:pressKey()
    eq(#client.sent, 1)
end)

test("a newer feeding replaces an emote still waiting", function()
    local client = NewClient():login()
    client.pet.familyID = 999
    client.E.Emotes.male, client.E.Emotes.food = {}, {}
    client.E.Emotes.any = { "First." }
    client:feed(12037)
    client.E.Emotes.any = { "Second." }
    client:advance(2)
    client:feed(12037)
    client:advance(9)
    client:pressKey()
    eq(#client.sent, 1)
    ok(client.sent[1].text:find("Second%.$"), client.sent[1].text)
end)

test("with MessageQueue loaded the emote goes through its queue", function()
    local client = NewClient({ messageQueue = true }):login()
    client:slash("debug")
    local keys
    for _, frame in ipairs(client.frames) do
        if frame.scripts.OnKeyDown then keys = frame end
    end
    client:feed(12037)
    eq(#client.messageQueue, 1)
    eq(keys:IsShown(), false, "MessageQueue watches the input, not the key frame")
    ok(client:printedContains("MessageQueue sends it on your next input"))
    client:runMessageQueue()
    eq(#client.sent, 1)
    eq(client.sent[1].kind, "EMOTE")
    ok(client:printedContains("sending on MessageQueue via C_ChatInfo.SendChatMessage"))
end)

test("with MessageQueue, a late run after the timeout sends nothing", function()
    local client = NewClient({ messageQueue = true }):login()
    client:feed(12037)
    client:advance(11)
    client:runMessageQueue()
    eq(#client.sent, 0)
end)

test("with MessageQueue, two feedings send only the newer emote", function()
    local client = NewClient({ messageQueue = true }):login()
    client:feed(12037)
    client:feed(117)
    client:runMessageQueue()
    eq(#client.sent, 1)
    ok(client.sent[1].text:find(ItemLink(117), 1, true), client.sent[1].text)
end)

test("chat locked at the key press drops the emote without trying", function()
    local client = NewClient():login()
    client:slash("debug")
    client:feed(12037)
    client.chatLocked = true
    client:pressKey()
    eq(#client.sent, 0)
    eq(client.blocked, nil)
    ok(client:printedContains("no emote: the client blocks addon chat right now"))
end)
