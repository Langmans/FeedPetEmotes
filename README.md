# Feed Pet Emotes

Sends a random `/emote` every time you feed your hunter pet, the way
[Fizzwidget Feed-O-Matic](https://github.com/fizzwidget/feed-o-matic) did in
2008:

> Langmans feeds Fluffy a Mystery Meat. Tastes like well-aged gnome.

It works with any way of feeding: Gideon's Feed Pet: Forever button, a macro,
casting Feed Pet from the spellbook and clicking food, or dragging food onto
your pet. It does not feed anything itself, so it is a companion to Feed Pet:
Forever rather than a replacement, and both can be installed side by side.

## What it says

- The emote names the food your pet ate (as a clickable item link) and adds a
  random line.
- Lines fit the situation: some for every pet, some for the kind of food
  (bread, meat, fish, cheese, fruit, mushrooms, and a few special foods), and
  three or more for each of the 17 pet families you can tame, from "Nice
  kitty!" to "Clever girl...".
- Lines that talk about your pet say "he" or "she" when the game tells the
  pet's sex, and use the pet's name otherwise.
- You can add lines of your own, mixed in with the built-in ones or used
  instead of them (see [Your own lines](#your-own-lines)).

## Install

With an addon manager: install Feed Pet Emotes from
[CurseForge](https://www.curseforge.com/wow/addons/feedpetemotes) through the
CurseForge app (or any manager that reads CurseForge).

By hand:

1. Download the zip from
   [CurseForge](https://www.curseforge.com/wow/addons/feedpetemotes) or from
   [GitHub releases](https://github.com/Langmans/FeedPetEmotes/releases).
2. Unzip it into your WoW client's `Interface\AddOns`, so that you get
   `Interface\AddOns\FeedPetEmotes`.
3. Restart the game, or `/reload` if it was running, and check that "Feed Pet
   Emotes" is enabled in the AddOns list on the character screen.

Made for WoW: Forever (1.60).

## Settings

Open the options panel with `/fpe config`, or through Esc > Options > AddOns >
Feed Pet Emotes. All settings are saved per character; only your own lines
can be shared by all characters on the account.

- **Send emotes**: switch the emotes on or off.
- **Always use the pet's name**: name the pet instead of saying he or she.
- **Debug trace**: print in chat what the addon sees while you feed (see
  [Reporting a problem](#reporting-a-problem)).
- **Your own lines**: add, edit and remove lines of your own, **Chance of an
  own line**, **Use a built-in line when none of mine fits** and **Share my
  lines with all characters** (see below).

The same settings, and a few extras, are available as chat commands
(`/feedpetemotes` works too):

- `/fpe` shows whether emotes are on, plus the list of commands.
- `/fpe config` (or `/fpe options`) opens the options panel.
- `/fpe on` and `/fpe off` switch the emotes on or off.
- `/fpe name on` and `/fpe name off` switch "always use the pet's name".
- `/fpe add <line>`, `/fpe list`, `/fpe remove <number>`,
  `/fpe chance <0-100>`, `/fpe fallback on|off` and `/fpe shared on|off`
  manage your own lines (see below).
- `/fpe test` shows an example emote in your own chat window only; nothing
  is sent.
- `/fpe selftest` prints what your game client reports to the addon.
- `/fpe debug` switches the debug trace on or off.

## Your own lines

Your own lines come after "feeds Fluffy a Mystery Meat." just like the
built-in ones.

Each character has its own list. Tick **Share my lines with all characters**
(or `/fpe shared on`) to use one list shared by every character on the
account that ticks it, e.g. all your hunters. The two lists stay apart:
switching only chooses which one the character uses, and add, list and
remove work on that one.

    /fpe add {pet} wolfs down the {food} before {he} even sniffs it.
    /fpe list
    /fpe remove 1

- `{pet}` becomes your pet's name and `{food}` the food's name. A line with
  `{food}` is skipped when the addon cannot tell which food was eaten.
- `{he}` becomes he or she when the game tells the pet's sex, the pet's name
  otherwise (and always with "Always use the pet's name"). In other languages
  the word differs, e.g. `{er}` in German; the options panel lists the ones
  for your language.
- Placeholders must be typed exactly as listed (`{Pet}` is not `{pet}`);
  anything else in braces becomes the pet's name.
- A line can be at most 150 bytes (letters outside A–Z take two or more), so
  the whole emote fits in a chat message, and cannot contain `|`.

### How often your lines come up

Every line that fits a feeding, yours or built-in, has the same chance by
default. With a handful of own lines among the 15–20 built-in ones that fit
a typical feeding, yours come up now and then.

`/fpe chance 50` (or the **Chance of an own line** slider in the panel) makes
half of the emotes want one of your lines; the other half use a built-in
line. `/fpe chance 100` uses only your lines. `/fpe chance 0` goes back to
every line counting the same.

When an emote wants one of your lines but none fits (say all of them are
`[wolf]` lines and you are feeding your cat), it uses a built-in line. Untick
**Use a built-in line when none of mine fits** (or `/fpe fallback off`) and it
says only "feeds Fluffy a Mystery Meat." instead.

### Conditions

A line can be limited to some pets or foods, the same way the built-in lines
are. In the options panel, tick the boxes under **Only when** before you add
the line (or press **Edit** on a line to change them). In chat, put the
conditions in brackets in front:

    /fpe add [cat] Who's a pretty kitty?
    /fpe add [cat,wolf] Good hunter!
    /fpe add [cat,fish] A cat with a fish. How original.

- Nothing ticked, or no brackets: the line is always used.
- Several in one group (Pet, Food, Family): any of them will do. `[cat,wolf]`
  is a cat or a wolf.
- Several groups: each must match. `[cat,fish]` is a cat eating fish.
- Pet: `male`, `female` (only when the game tells the pet's sex).
- Food: `bread`, `meat`, `fish`, `cheese`, `fruit`, `fungus` (the vendor food
  the addon knows; other food matches none of them).
- Family: `wolf`, `cat`, `spider`, `bear`, `boar`, `crocolisk`,
  `carrion_bird`, `crab`, `gorilla`, `raptor`, `tallstrider`, `scorpid`,
  `turtle`, `bat`, `hyena`, `bird_of_prey`, `wind_serpent`.
- The names in brackets are English on every client language; the panel shows
  them in yours.

## Languages

The emotes follow your game's language: English, German, French, Spanish,
Korean and Russian. Other languages get English. The chat messages of the
addon itself are English for now.

## Reporting a problem

If an emote does not appear, or names the wrong food:

1. Summon your pet and type `/fpe debug`.
2. Feed your pet the way that goes wrong.
3. Type `/fpe selftest`.
4. Copy the chat lines into an
   [issue on GitHub](https://github.com/Langmans/FeedPetEmotes/issues).

## Credits

Most emote lines come from [Fizzwidget Feed-O-Matic](https://github.com/fizzwidget/feed-o-matic)
by Gazmik Fizzwidget, including its community translations. The rest were
written for this addon.

## License

MIT, see [LICENSE](https://github.com/Langmans/FeedPetEmotes/blob/main/LICENSE).
The emote lines from Feed-O-Matic are not covered by it; they remain the work
of their authors (see
[NOTICE](https://github.com/Langmans/FeedPetEmotes/blob/main/NOTICE)).

---

## Technical documentation

The rest of this file is for people who want to change the addon.

### Files

In `.toc` order; all share the addon namespace `E`.

- `Data.lua` — food groups, food types and pet family IDs.
- `Locales\*.lua` — one file per locale: strings, pronouns and emote lines.
- `Locale.lua` — picks the client's locale; `E.L`, `E.Emotes`, `E.Format`.
- `Core.lua` — helpers (`E.Public`, `E.Print`, `E.Debug`, `E.SendFunction`)
  and the saved settings (`E.LoadSettings`, `E.db`).
- `CustomLines.lua` — the player's own lines and their conditions:
  `E.Conditions` (tag, group, value), `E.ParseCustomLine`,
  `E.FormatCustomLine`, `E.ConditionsHold`, `E.AddCustomLine` and
  `E.ReplaceCustomLine` (trim, check, put the conditions in a fixed order),
  `E.RemoveCustomLine`, `E.PlaceholderList`. Shared by `/fpe` and the options
  panel.
- `Emote.lua` — the emote text: `E.LinePools` (own and built-in lines that
  fit), `E.EmotePool` (the two together), `E.PickLine` (applies the chance),
  `E.FillPlaceholders`, `E.BuildEmote`. No state.
- `FoodTracker.lua` — `E.FoodTracker`, the one object with state: which food
  a Feed Pet cast used (see below).
- `Options.lua` — the options panel in the game's settings (`E.OpenOptions`):
  one scroll frame holding the settings, the line editor with its condition
  checkboxes, and the list of lines.
- `SelfTest.lua` — `/fpe selftest` (`E.SelfTest`).
- `Commands.lua` — `/fpe`: one function per subcommand in a `Commands`
  table, looked up by the slash handler like the event frame looks up its
  event methods; anything unknown shows the status line.
- `FeedPetEmotes.lua` — wiring: the event frame (one method per event)
  and the `UseContainerItem` hook feed the tracker; a cast sends the emote.

The settings are saved per character in `FeedPetEmotesDBPC`: `enabled`,
`petName`, `debug`, `customFallback` and `sharedLines`, all booleans,
`customChance`, a whole percentage (0 = every line counts the same), and
`customLines`, a list of strings. The account-wide `FeedPetEmotesDB` holds
only `customLines`, the shared list; `E.CustomLines()` returns the list a
character uses (shared with `sharedLines`, its own otherwise). A missing or
broken value gets its default on load; entries in `customLines` that are not
strings are dropped. A line is saved as one string, its conditions first:
`"[fish,cat] Nice fish, kitty."`.

### How it works

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
    by a click in the bags of a bag addon. The bags may update just after the cast
    is reported, so a cast with no other sign of its food waits up to a second
    for them, then sends with or without the food.
- When `UNIT_SPELLCAST_SUCCEEDED` reports Feed Pet (6991) for the player, the
  emote names the food as an item link, then a line is picked from the
  locale's emote lists that match: every pet, the pet's gender, the food's own
  group and its type (both looked up by item ID), and the pet's family. The
  player's own lines whose conditions hold are matched by the same three keys
  (sex, food type, family ID). With `customChance` 0 they join that pool.
  Above 0, a roll of 1–100 picks the kind first (own when at or under the
  chance), then a line within it; when an own line is wanted and none fits,
  `customFallback` picks a built-in line, or no line at all (the emote is
  then just the "feeds ..." sentence). A saved line with a tag the addon
  does not know is skipped. If the food is not known the emote just says
  "feeds <pet>.", and own lines with `{food}` are left out.
- Pet families are matched on the CreatureFamily ID (second return of
  `UnitCreatureFamily`), which is the same on every client language.
- `/fpe selftest` prints build, locale, the chat send function, whether Feed
  Pet is known, the pet's family ID and sex, and the last food and cast the
  addon saw. It is always English, since it is meant for bug reports.

### Localization

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
  - `{food}` is the food's plain name (not the link, which is already in
    the sentence in front). Only the player's own lines use it.
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

### Development

Needs Node.js. `npm install` once, then:

- `npm test` — runs `tests/*.test.lua` against a simulated WoW client
  (`tests/wow.lua`) in fengari, a Lua VM in JavaScript, and prints line
  coverage per file; `coverage/lcov.info` is written for editor plugins.
  `npm test feeding` runs only the files whose name contains `feeding`.
- `npm run lint` — StyLua formatting check, then WoW Lua LS diagnostics
  (taken from its VS Code extension; skipped if that is not installed).
- `npm run format` — formats all Lua with StyLua.
- `npm run check` — lint, then tests.

Releases: pushing a tag runs `.github/workflows/release.yml`, which runs
`npm run check` and then BigWigsMods/packager. The packager builds the zip
(leaving out what `.pkgmeta` lists), uploads it to the CurseForge project in
`## X-Curse-Project-ID` using the `CF_API_KEY` repository secret, and attaches
it to a GitHub release. The release notes are the `CHANGELOG.md` in the
repository, so add a section there (and set `## Version:` in the `.toc`)
before tagging.

fengari is Lua 5.3 and WoW runs 5.1; the addon sticks to the shared subset and
WoW Lua LS flags WoW-incompatible API use. What the simulation cannot show —
whether Forever lets an addon send the emote, what `UnitCreatureFamily`
really returns — is what `/fpe selftest` is for.

Coverage counts the first line of each statement as found by luaparse, with
two adjustments for how Lua reports lines: a function counts on its closing
`end` (where the closure is created), and `local a, b` without values does not
count (it has no instruction of its own).
