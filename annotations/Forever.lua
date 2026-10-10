---@meta
-- Editor-only type stubs for WoW: Forever (1.60.x) pet APIs that the language
-- server knows only as an untyped C_PetInfo table. Not listed in the .toc, so
-- the game never loads this file.
--
-- Forever moved the Classic globals GetPetHappiness/GetPetFoodTypes into
-- C_PetInfo. The signatures follow Blizzard_APIDocumentationGenerated/
-- PetInfoDocumentation.lua from the client's `exportInterfaceFiles code`.

---Happiness of the current hunter pet: 1 = unhappy, 2 = content, 3 = happy.
---Can be a secret value; check with issecretvalue before comparing.
---@return number? happiness
---@return number? damagePercentage
---@return number? loyaltyRate
function C_PetInfo.GetPetHappiness() end

---Whether the current pet's diet accepts this item.
---@param itemID number
---@return boolean canEat
function C_PetInfo.CanPetEatItem(itemID) end

---Localized diet names of the current pet ("Meat", "Fish", ...).
---@return string[] diet
function C_PetInfo.GetPetFoodTypes() end
