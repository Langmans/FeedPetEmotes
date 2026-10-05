-- The /fpe dispatch: subcommand lookup, the status line as fallback, and
-- on/off arguments. What each command does is tested with its feature.

test("/fpe alone, and an unknown subcommand, show the status line", function()
    local client = NewClient():login()
    client:slash("")
    ok(client:printedContains("Emotes are on. Commands:"))
    client.printed = {}
    client:slash("dance")
    ok(client:printedContains("Emotes are on. Commands:"))
end)

test("/feedpetemotes and /fpe are the same command", function()
    NewClient():login()
    eq(SLASH_FEEDPETEMOTES1, "/fpe")
    eq(SLASH_FEEDPETEMOTES2, "/feedpetemotes")
end)

test("subcommands and on/off ignore case and extra spaces", function()
    local client = NewClient():login()
    client:slash("  OFF  ")
    eq(Saved().enabled, false)
    client:slash("Name   ON")
    eq(Saved().petName, true)
end)

test("an on/off command without on or off changes nothing and shows the status", function()
    local client = NewClient():login()
    client:slash("name maybe")
    client:slash("only")
    eq(Saved().petName, false)
    eq(Saved().customOnly, false)
    ok(client:printedContains("Emotes are on. Commands:"))
end)
