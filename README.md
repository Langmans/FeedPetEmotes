# Feed Pet: Forever Emotes

Sends a random `/emote` every time you feed your hunter pet, the way Fizzwidget
Feed-O-Matic did in 2006:

> Langmans feeds Fluffy a Mystery Meat. Tastes like well-aged gnome.

A companion to Gideon's Feed Pet: Forever, but it works with any way of feeding
(that addon's button, a macro, or clicking food by hand). It does not feed
anything itself. The folder name differs from `FeedPetForever` on purpose, so
both addons can be installed side by side.

## How it works

- `C_Container.UseContainerItem` is hooked; when a spell is waiting for an item
  target at that moment, the item is remembered as the food.
- When `UNIT_SPELLCAST_SUCCEEDED` reports Feed Pet (6991) for the player, a line
  is picked from the locale's emote lists that match: every pet, the pet's
  gender, the food's group (looked up by item ID), and the pet's family. If the
  food is not known the emote just says "feeds <pet>.".
- Pet families are matched on the CreatureFamily ID (second return of
  `UnitCreatureFamily`), which is the same on every client language.

## Localization

One file per locale in `Locales\`: enUS, deDE, esES (also used for esMX),
frFR, koKR and ruRU. Each holds that locale's `strings` (the feed sentence and
the chat messages) and `emotes`.

- `Data.lua` loads first and holds what all locales share: the food groups
  (item ID → group) and the CreatureFamily IDs as `E.Family`.
- `Locale.lua` loads after the locale files and picks the client's locale.
  `E.L` falls back to enUS through a metatable, so a locale lists only what it
  translates. A value can be a function when `string.format` is not enough (the
  English "a"/"an").
- A locale without emotes uses the enUS lines; a locale that lacks one list
  never mixes in English, it just has fewer lines.
- Lines come from Feed-O-Matic, except deDE and the ten families it never had
  (Bear, Bird of Prey, Tallstrider, Carrion Bird, Wind Serpent, Bat, Crab,
  Gorilla, Scorpid, Turtle), which were written for this addon.

To add a locale: copy `Locales\enUS.lua`, change the key in `E.Locales`, drop
the strings that stay English, and list the file in the `.toc` before
`Locale.lua`.

## Commands

- `/fpfe on` / `/fpfe off` — toggle emotes (saved per character)
- `/fpfe test` — local preview in your chat frame; nothing is sent

## Credits

Emote lines come from [Fizzwidget Feed-O-Matic](https://github.com/fizzwidget/feed-o-matic)
by Gazmik Fizzwidget.

## Install

The folder is linked into the WoW: Forever beta client:

```
C:\Games\Blizzard\World of Warcraft\_classic_beta_\Interface\AddOns\FeedPetForeverEmotes
  -> %USERPROFILE%\Documents\My Games\WoW AddOns\FeedPetForeverEmotes
```

It is a directory junction rather than a symlink, since creating a symlink on
this machine needs administrator rights:

```
mklink /J "<beta>\Interface\AddOns\FeedPetForeverEmotes" "<this folder>"
```
