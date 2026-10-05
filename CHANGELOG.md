# Changelog

## Unreleased

- Your own emote lines: add them with `/fpe add <line>` or in the options
  panel, see them with `/fpe list`, remove them with `/fpe remove <number>`
  or the X next to a line in the panel's scrollable list. Each character has its own list, or ticks
  "Share my lines with all characters" (`/fpe shared on|off`) to use one
  list for all your characters.
- Own lines take the same placeholders as the built-in ones (`{pet}`, and
  `{he}` for he/she), plus `{food}` for the food's name.
- Conditions on your own lines: only for some pet families, foods or sexes,
  ticked in the panel or typed in brackets (`/fpe add [cat,fish] ...`).
  Lines can be edited in the panel.
- How often your own lines come up: by default every fitting line counts the
  same; `/fpe chance <0-100>` or the panel's slider sets a fixed share of
  emotes that want one of your lines, up to 100% for your lines only.
- When an own line is wanted but none fits, a built-in line is used; untick
  "Use a built-in line when none of mine fits" (`/fpe fallback off`) to send
  just "feeds Fluffy a Mystery Meat." instead.
- The options panel scrolls.

## 1.0.0 - 2026-10-05

First release, for WoW: Forever.

- Sends a random `/emote` naming the food whenever you feed your hunter pet,
  however you feed it.
- Lines for every pet, for each kind of food and for all 17 tameable pet
  families; "he" or "she" when the game tells the pet's sex.
- Emote lines in English, German, Spanish, French, Korean and Russian.
- Options panel (`/fpe config`): turn emotes off, or always use the pet's
  name.
