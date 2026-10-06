-- Only a hunter feeds a pet: on other classes the addon loads but stays idle.

local function eventFrame(client)
    for _, frame in ipairs(client.frames) do
        if frame.unitEvents.UNIT_SPELLCAST_SUCCEEDED or frame.events.CURSOR_CHANGED then return frame end
    end
end

test("a hunter watches the cursor, the bags and its casts", function()
    local client = NewClient():login()
    local frame = eventFrame(client)
    ok(frame)
    ok(frame.events.CURSOR_CHANGED)
    ok(frame.events.BAG_UPDATE_DELAYED)
    eq(frame.unitEvents.UNIT_SPELLCAST_SUCCEEDED, "player")
end)

test("another class registers no feeding events and sends nothing", function()
    local client = NewClient({ class = "MAGE" }):login()
    eq(eventFrame(client), nil)
    client:feed(12037)
    eq(#client.sent, 0)
end)

test("on another class /fpe says the emotes are idle, and still works", function()
    local client = NewClient({ class = "MAGE" }):login()
    client:slash("")
    ok(client:printedContains("Not a hunter: emotes are idle on this character."))
    ok(client:printedContains("Emotes are on. Commands:"))
    client:slash("off")
    eq(Saved().enabled, false)
end)

test("a hunter's /fpe does not mention the class", function()
    local client = NewClient():login()
    client:slash("")
    ok(not client:printedContains("Not a hunter"))
end)

test("/fpe selftest shows the class", function()
    local hunter = NewClient():login()
    hunter:slash("selftest")
    ok(hunter:printedContains("Class Hunter (HUNTER): emotes active."))
    local mage = NewClient({ class = "MAGE" }):login()
    mage:slash("selftest")
    ok(mage:printedContains("Class Mage (MAGE): emotes idle, not a hunter."))
end)
