local _, E = ...

-- Building the emote text: which lines apply, the placeholders in a line, and
-- the sentence in front. No state of its own; it reads the pet, the item and
-- the locale's tables.

local function append(pool, list)
    if type(list) ~= "table" then return end
    for _, line in ipairs(list) do
        pool[#pool + 1] = line
    end
end

---Every emote line that applies to feeding the current pet this item.
---@param itemID number?
---@return string[]
function E.EmotePool(itemID)
    local emotes, pool = E.Emotes, {}
    append(pool, emotes.any)
    local sex = UnitSex("pet")
    if sex == 2 then
        append(pool, emotes.male)
    elseif sex == 3 then
        append(pool, emotes.female)
    end
    local group = itemID and E.FoodGroups[itemID]
    if group then append(pool, emotes.food[group]) end
    local foodType = itemID and E.FoodTypes[itemID]
    if foodType and emotes.foodType then append(pool, emotes.foodType[foodType]) end
    -- The family ID is the same on every client language; the name is not.
    local _, familyID = UnitCreatureFamily("pet")
    if familyID and E.Public(familyID) then append(pool, emotes.family[familyID]) end
    return pool
end

---"male", "female", or nil when the pet's sex is unknown or the player asked
---for the pet's name instead (/fpe name on).
---@return string?
local function pronounSex()
    if E.db.petName then return nil end
    local sex = UnitSex("pet")
    if not E.Public(sex) then return nil end
    return sex == 2 and "male" or sex == 3 and "female" or nil
end

---Replaces the placeholders in an emote line.
---{pet} is always the pet's name. Any other {token} is one of the locale's
---pronouns (E.Pronouns, e.g. {he} -> he/she); without a known sex, or for a
---token the locale does not define, it becomes the pet's name, which reads
---right in every language. Function replacements, so a % in the name is
---never read as a capture reference.
---@param line string
---@param pet string
---@return string
function E.FillPlaceholders(line, pet)
    local sex = pronounSex()
    local filled = line:gsub("{([^}]+)}", function(token)
        local words = token ~= "pet" and sex and E.Pronouns[token]
        return words and words[sex] or pet
    end)
    return filled
end

---The full /emote text, or nil when the pet's name is unavailable.
---@param itemID number?
---@return string?
function E.BuildEmote(itemID)
    local pet = UnitName("pet")
    if not pet or not E.Public(pet) then return end
    -- The chat link, so readers can click the food; the plain name if there is none.
    local food, link
    if itemID then
        food, link = C_Item.GetItemInfo(itemID)
    end
    food = link or food
    local text = food and E.Format("FEED", pet, food) or E.Format("FEED_NO_FOOD", pet)
    local pool = E.EmotePool(itemID)
    return text .. E.FillPlaceholders(pool[math.random(#pool)], pet)
end
