---@meta
-- Editor-only type stubs for WoW: Forever (1.60.x) APIs that the WoW API
-- extension does not know, because they exist only in the Classic/Forever
-- clients. Not listed in the .toc, so the game never loads this file.
--
-- The C_PetInfo signatures follow how Feed Pet: Forever uses them; Blizzard's
-- generated documentation for these does not exist in the public UI source.

---Happiness of the current hunter pet: 1 = unhappy, 2 = content, 3 = happy.
---Can be a secret value; check with issecretvalue before comparing.
---@return number? happiness
function C_PetInfo.GetPetHappiness() end

---Whether the current pet's diet accepts this item.
---@param itemID number
---@return boolean canEat
function C_PetInfo.CanPetEatItem(itemID) end

---Classic global: happiness plus the damage modifier and loyalty rate.
---@return number? happiness
---@return number? damagePercentage
---@return number? loyaltyRate
function GetPetHappiness() end

---Classic global: localized diet names of the current pet ("Meat", "Fish", ...).
---@return string ...
function GetPetFoodTypes() end
