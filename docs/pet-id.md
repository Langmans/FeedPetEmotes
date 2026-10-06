# Identifying a hunter pet

Which value identifies one specific hunter pet across summons, relogs, stable
swaps and renames, so per-pet settings (such as a chosen sex) can be stored
against it. Measured on WoW: Forever 1.60.1 with the private DevProbes addon
(two pets: a Boar and a Cat, one renamed).

## Use `petNumber`

`C_StableInfo.GetActivePetList()` and `C_StableInfo.GetStabledPetList()`
return a `PetInfo` table per pet. Its `petNumber` is the key:

```lua
for _, pet in ipairs(C_StableInfo.GetActivePetList()) do
	-- pet.petNumber, pet.slotID, pet.name, pet.familyName,
	-- pet.creatureID, pet.displayID, pet.level, ...
end
```

- Both lists work anywhere, not only at a stable master
  (`C_StableInfo.IsAtStableMaster()` false), and already at
  `PLAYER_ENTERING_WORLD`.
- `petNumber` stays the same through dismiss/resummon, `/reload`, relog,
  moving the pet into the stable and back, and a rename.
- A newly tamed pet gets a fresh number from a server-wide counter (a new tame
  came out about 259,000 above the previous pet), not "last number + 1" per
  character. Numbers are unique per realm, so per-character storage
  (`FeedPetEmotesDBPC`) is safe.

## The summoned pet's number

The low 32 bits of `UnitGUID("pet")` equal `PetInfo.petNumber`, so the
currently summoned pet can be matched without the stable lists:

```lua
-- Pet-0-<server>-<instance>-<zone>-<npcID>-<spawnUID>
local spawnUID = select(7, strsplit("-", UnitGUID("pet")))
local petNumber = tonumber(spawnUID:sub(-8), 16)
```

The high bits of `spawnUID` are a summon counter (01, 02, 03, ...). The rest
of the GUID is not stable: the server/instance/zone part and the counter
differ between sessions, so the full GUID is useless as a key.

## Values that are not keys

| Value | Why not |
| --- | --- |
| Full `UnitGUID("pet")` | Changes per summon (counter) and per session (server/zone part). |
| GUID npcID field | Always `165189`, a generic hunter-pet template, not the tamed beast. |
| `PetInfo.slotID` | A position: swapping active and stabled pets swaps their slots. |
| Pet name | Changes on rename; two pets may share one; is `"Unknown"` at `PLAYER_ENTERING_WORLD` until `UNIT_NAME_UPDATE` arrives. |
| `PetInfo.creatureID` | The tamed beast's NPC ID (e.g. 1984 Young Thistle Boar); shared by every pet tamed from that NPC. |
| `PetInfo.displayID` | The skin; shared by every pet with that look. |

## Display ID

`PetInfo.displayID` is the pet's skin (creature display info ID).
`C_PlayerInfo.GetPetStableCreatureDisplayInfoID(slotID)` returns the same
value; its index is the `slotID`, so it follows the slot, not the pet.

A `PlayerModel` frame cannot provide it: after `SetUnit("pet")` the model loads
(`GetModelFileID()` gives the mesh, once the frame is shown) but
`GetDisplayInfo()` stays 0. A hidden model frame does not load at all.
