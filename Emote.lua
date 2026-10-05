local _, E = ...

-- Building the emote text: which lines apply, the placeholders in a line, and
-- the sentence in front. No state of its own; it reads the pet, the item, the
-- locale's tables and the player's own lines.

local function append(pool, list)
    if type(list) ~= "table" then return end
    for _, line in ipairs(list) do
        pool[#pool + 1] = line
    end
end

---What the lists are chosen by for one feeding: the pet's sex (2 male, 3
---female), the food's type and the pet's family ID, each nil when unknown
---or secret. The family ID is the same on every client language; the name
---is not.
---@param itemID number?
---@return {sex: number?, foodType: string?, family: number?}
local function situationOf(itemID)
    local sex = UnitSex("pet")
    local _, familyID = UnitCreatureFamily("pet")
    return {
        sex = sex and E.Public(sex) and sex or nil,
        foodType = itemID and E.FoodTypes[itemID] or nil,
        family = familyID and E.Public(familyID) and familyID or nil,
    }
end

---Every emote line that applies to feeding the current pet this item: the
---player's own lines whose conditions hold (without their conditions), then
---the built-in ones. A line with {food} needs the food's name. With "only my
---own lines" on, the built-in lines are left out, unless no own line applies.
---@param itemID number?
---@param foodName string? the food's name, nil when it is not known
---@return string[]
function E.EmotePool(itemID, foodName)
    local emotes, pool = E.Emotes, {}
    local situation = situationOf(itemID)
    for _, line in ipairs(E.CustomLines()) do
        -- A saved line with a tag this version does not know is skipped.
        local tags, text = E.ParseCustomLine(line)
        if tags and E.ConditionsHold(tags, situation) and (foodName or not text:find("{food}", 1, true)) then
            pool[#pool + 1] = text
        end
    end
    if E.db.customOnly and #pool > 0 then return pool end
    append(pool, emotes.any)
    if situation.sex == 2 then
        append(pool, emotes.male)
    elseif situation.sex == 3 then
        append(pool, emotes.female)
    end
    local group = itemID and E.FoodGroups[itemID]
    if group then append(pool, emotes.food[group]) end
    if situation.foodType and emotes.foodType then append(pool, emotes.foodType[situation.foodType]) end
    if situation.family then append(pool, emotes.family[situation.family]) end
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
---{pet} is always the pet's name, {food} the food's plain name (E.EmotePool
---only offers such a line when the food is known). Any other {token} is one
---of the locale's pronouns (E.Pronouns, e.g. {he} -> he/she); without a known
---sex, or for a token the locale does not define, it becomes the pet's name,
---which reads right in every language. Function replacements, so a % in a
---name is never read as a capture reference.
---@param line string
---@param pet string
---@param food string?
---@return string
function E.FillPlaceholders(line, pet, food)
    local sex = pronounSex()
    local filled = line:gsub("{([^}]+)}", function(token)
        if token == "food" and food then return food end
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
    local name, link
    if itemID then
        name, link = C_Item.GetItemInfo(itemID)
    end
    local food = link or name
    local text = food and E.Format("FEED", pet, food) or E.Format("FEED_NO_FOOD", pet)
    local pool = E.EmotePool(itemID, name)
    return text .. E.FillPlaceholders(pool[math.random(#pool)], pet, name)
end
