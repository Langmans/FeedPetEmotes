# Changelog

## Unreleased

- Your own emote lines: add them with `/fpe add <line>` or in the options
  panel, see them with `/fpe list`, remove them with `/fpe remove <number>`
  or the panel's Remove button. They are saved per character.
- Own lines take the same placeholders as the built-in ones (`{pet}`, and
  `{he}` for he/she), plus `{food}` for the food's name.
- "Only use my own lines" (`/fpe only on|off`) leaves the built-in lines out
  while you have lines of your own.

## 1.0.0 - 2026-10-05

First release, for WoW: Forever.

- Sends a random `/emote` naming the food whenever you feed your hunter pet,
  however you feed it.
- Lines for every pet, for each kind of food and for all 17 tameable pet
  families; "he" or "she" when the game tells the pet's sex.
- Emote lines in English, German, Spanish, French, Korean and Russian.
- Options panel (`/fpe config`): turn emotes off, or always use the pet's
  name.
