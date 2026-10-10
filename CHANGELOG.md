# Changelog

## 1.2.0 - 2026-10-10

- Fixed: feeding could give an "AddOn tried to call the protected function"
  error instead of an emote. WoW: Forever only lets an addon send chat as
  part of a key press or click, so the emote now goes out on your next key
  press (moving counts) or click after the feeding, and is skipped if none
  comes within ten seconds. It is also skipped while the game blocks addon
  chat altogether (in combat, for instance); `/fpe debug` says why, and
  `/fpe selftest` shows whether chat is locked.
- Optional support for the MessageQueue addon: when it is installed, it
  holds the emote until your next input of any kind (any click, the mouse
  wheel, a gamepad, or a key from its AutoHotkey helper).
- The options panel has a "Your pet's sex" section: male, female or from the
  game for the summoned pet, the same choice as `/fpe sex`.
- The sex chosen for a pet you have since released is forgotten at the next
  login.
- More variety in English and German: instead of always "feeds Fluffy ...",
  the emote often starts differently ("tosses Fluffy a ...", "bribes Fluffy
  with a ..."), and some emotes are a small scene of their own ("turns around
  for one second. The Mystery Meat is gone, and Fluffy looks very
  innocent."), including two per pet family ("puts some Mystery Meat on the
  table. Fluffy knocks it off, then eats it off the floor.").
- English says "some" for food you do not count and plurals: "feeds Fluffy
  some Mystery Meat", "some Alterac Swiss", "some Deep Fried Plantains",
  while "a Haunch of Meat" keeps its "a".

## 1.1.1 - 2026-10-07

- Fixed: the options panel showed none of your settings (boxes unticked, the
  chance slider without title or position) when it was opened right after
  another addon's options panel.

## 1.1.0 - 2026-10-06

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
- `/fpe sex male|female|auto` tells the addon your pet's sex, which WoW:
  Forever does not report for hunter pets, so the he/she lines and pronouns
  work. Each pet keeps its own choice through renames, relogs and stable
  swaps.
- New placeholder `{boy}` for boy or girl ("Good {boy}!"), with its own word
  in every language (`{Junge}`, `{chico}`, `{garçon}`, `{мальчик}`, `{소년}`).
  New lines for every pet use it, such as "Who's a good {boy}?"; without a
  known sex they name the pet ("Who's a good Fluffy?").
- New placeholder `{his}` for his or her ("Fluffy's" when the sex is not
  known); German `{sein}`, Korean `{그의}`. With a few new lines, such as
  "Hey, those are my fingers, not {his} dessert!".
- Many more built-in lines in English and German: 20 for every pet and 10
  for each of the 17 pet families, so each pet has about 30 to pick from.
- The options panel scrolls.
- The options panel shows the version, author and license, and the
  website in a box you can copy it from.
- Settings you never changed follow the addon's defaults, also when a later
  version changes one: only the settings you changed are saved.
- On characters that are not hunters the addon stays idle: it no longer
  watches your cursor and bags there. `/fpe` says so, and the settings can
  still be changed.

## 1.0.0 - 2026-10-05

First release, for WoW: Forever.

- Sends a random `/emote` naming the food whenever you feed your hunter pet,
  however you feed it.
- Lines for every pet, for each kind of food and for all 17 tameable pet
  families; "he" or "she" when the game tells the pet's sex.
- Emote lines in English, German, Spanish, French, Korean and Russian.
- Options panel (`/fpe config`): turn emotes off, or always use the pet's
  name.
