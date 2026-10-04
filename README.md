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
  is picked from the lists in `Emotes.lua` that match: every pet, the pet's
  gender, the food's item ID, and the pet's family. If the food is not known the
  emote just says "feeds <pet>.".
- Pet family lines are keyed on the English family name, so they only show on
  an English client.

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
