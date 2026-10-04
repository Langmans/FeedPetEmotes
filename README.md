# Feed Pet Emotes

Sends a random `/emote` every time you feed your hunter pet, the way Fizzwidget
Feed-O-Matic did in 2006:

> Langmans feeds Fluffy a Mystery Meat. Tastes like well-aged gnome.

A companion to Gideon's Feed Pet: Forever, but it works with any way of feeding
(that addon's button, a macro, or clicking food by hand). It does not feed
anything itself. The folder name differs from `FeedPetForever` on purpose, so
both addons can be installed side by side.

## Files

In `.toc` order; all share the addon namespace `E`.

- `Data.lua` — food groups, food types and pet family IDs.
- `Locales\*.lua` — one file per locale: strings, pronouns and emote lines.
- `Locale.lua` — picks the client's locale; `E.L`, `E.Emotes`, `E.Format`.
- `Core.lua` — helpers (`E.Public`, `E.Print`, `E.Debug`, `E.SendFunction`)
  and the saved settings (`E.LoadSettings`, `E.db`).
- `Emote.lua` — the emote text: `E.EmotePool`, `E.FillPlaceholders`,
  `E.BuildEmote`. No state.
- `FoodTracker.lua` — `E.FoodTracker`, the one object with state: which food
  a Feed Pet cast used (see below).
- `Commands.lua` — `/fpe` and the selftest.
- `FeedPetEmotes.lua` — wiring: the event frame (one method per event)
  and the `UseContainerItem` hook feed the tracker; a cast sends the emote.

## How it works

- The food is seen in one of three ways, in this order of priority:
  - **targeted**: `C_Container.UseContainerItem` is hooked; when Feed Pet is
    waiting for an item target at that moment, the item is the food. In the
    Classic UI source both a bag click on a targeting spell and a secure
    button's `target-bag`/`target-slot` go through that function. On Forever
    the hook does not fire for either (its UI code is not public; it calls
    something else or holds its own reference to the function), so there the
    eaten route below does the work. The hook stays for clients where it
    does fire: there it is the quickest route, with no wait for the bags.
  - **cursor**: `CURSOR_CHANGED` is watched; an item picked up (dragged, or
    clicked in a bag) and let go of shortly before the cast is the food. Where
    it is dropped may involve no Lua at all, so the cursor is the only witness.
  - **eaten**: item counts in the bags are kept per `BAG_UPDATE_DELAYED`; the
    item whose count dropped is the food. This catches every route that hands
    the item to the client without a Lua call the addon can see: on Forever,
    the Feed Pet: Forever button and Feed Pet cast from the spellbook followed
    by a click in the bags (EllesmereUIBags). The bags may update just after the cast
    is reported, so a cast with no other sign of its food waits up to a second
    for them, then sends with or without the food.
- When `UNIT_SPELLCAST_SUCCEEDED` reports Feed Pet (6991) for the player, the
  emote names the food as an item link, then a line is picked from the
  locale's emote lists that match: every pet, the pet's gender, the food's own
  group and its type (both looked up by item ID), and the pet's family. If the
  food is not known the emote just says "feeds <pet>.".
- Pet families are matched on the CreatureFamily ID (second return of
  `UnitCreatureFamily`), which is the same on every client language.

## Localization

One file per locale in `Locales\`: enUS, deDE, esES (also used for esMX),
frFR, koKR and ruRU. Each holds that locale's `strings` (the feed sentence and
the chat messages) and `emotes`.

- `Data.lua` loads first and holds what all locales share: the food groups
  (item ID → a joke about that one food), the food types (item ID → bread,
  meat, fish, cheese, fruit or fungus, for vendor food on Forever) and the
  CreatureFamily IDs as `E.Family`. The client cannot tell an item's food
  type, so `E.FoodTypes` is a hand-made list from Wowhead's Forever vendor
  food, classified by name.
- `Locale.lua` loads after the locale files and picks the client's locale.
  `E.L` falls back to enUS through a metatable, so a locale lists only what it
  translates. A value can be a function when `string.format` is not enough (the
  English "a"/"an").
- A locale without emotes uses the enUS lines; a locale that lacks one list
  never mixes in English, it just has fewer lines.
- Placeholders in emote lines (`E.FillPlaceholders`):
  - `{pet}` is always the pet's name.
  - Any other `{token}` is a pronoun from the locale's own `pronouns` table,
    e.g. enUS `{he}` → he/she, deDE `{er}` → er/sie, frFR `{Il}` → Il/Elle.
    It follows `UnitSex("pet")` (2 male, 3 female). When the sex is unknown
    (1, or a secret value), with `/fpe name on`, or for a token the locale
    does not define, it becomes the pet's name: "A little smelly, just how
    Kaldor likes it." Pronouns never fall back to enUS, so a German line never
    gets an English "he".
  - A test rejects any token that is neither `{pet}` nor in that locale's
    `pronouns`.
- Lines come from Feed-O-Matic where it had them; the rest was written for
  this addon: all of deDE, the food-type lines, the ten families Feed-O-Matic
  never had (Bear, Bird of Prey, Tallstrider, Carrion Bird, Wind Serpent, Bat,
  Crab, Gorilla, Scorpid, Turtle), and the extra lines that give every family
  at least three per locale.

To add a locale: copy `Locales\enUS.lua`, change the key in `E.Locales`, drop
the strings that stay English, and list the file in the `.toc` before
`Locale.lua`.

## Commands

- `/fpe on` / `/fpe off` — toggle emotes (saved per character)
- `/fpe name on` / `/fpe name off` — always name the pet instead of saying
  he or she (saved per character)
- `/fpe test` — local preview in your chat frame; nothing is sent
- `/fpe selftest` — prints what the client reports: build and locale, the
  chat send function, whether Feed Pet is known, the pet's family ID and sex,
  and the last food and cast the addon saw. Sends nothing; meant to be pasted
  into a bug report, so it is always English.
- `/fpe debug` — toggles a trace of the feeding path in chat (food picked,
  cast seen, why an emote was or was not sent). Saved per character, so it
  stays on across reloads until switched off.

## Development

Needs Node.js. `npm install` once, then:

- `npm test` — runs `tests/*.test.lua` against a simulated WoW client
  (`tests/wow.lua`) in fengari, a Lua VM in JavaScript, and prints line
  coverage per file; `coverage/lcov.info` is written for editor plugins.
  `npm test feeding` runs only the files whose name contains `feeding`.
- `npm run lint` — StyLua formatting check, then WoW Lua LS diagnostics
  (taken from its VS Code extension; skipped if that is not installed).
- `npm run format` — formats all Lua with StyLua.
- `npm run check` — lint, then tests.

fengari is Lua 5.3 and WoW runs 5.1; the addon sticks to the shared subset and
WoW Lua LS flags WoW-incompatible API use. What the simulation cannot show —
whether Forever lets an addon send the emote, what `UnitCreatureFamily`
really returns — is what `/fpe selftest` is for.

Coverage counts the first line of each statement as found by luaparse, with
two adjustments for how Lua reports lines: a function counts on its closing
`end` (where the closure is created), and `local a, b` without values does not
count (it has no instruction of its own).

## Credits

Emote lines come from [Fizzwidget Feed-O-Matic](https://github.com/fizzwidget/feed-o-matic)
by Gazmik Fizzwidget.

## Install

The folder is linked into the WoW: Forever beta client:

```
C:\Games\Blizzard\World of Warcraft\_classic_beta_\Interface\AddOns\FeedPetEmotes
  -> %USERPROFILE%\Documents\My Games\WoW AddOns\FeedPetEmotes
```

It is a directory junction rather than a symlink, since creating a symlink on
this machine needs administrator rights:

```
mklink /J "<beta>\Interface\AddOns\FeedPetEmotes" "<this folder>"
```
