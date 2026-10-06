local _, E = ...

-- Building the emote text: which lines apply, the placeholders in a line, and
-- the sentence in front. No state of its own; it reads the pet, the item, the
-- locale's tables and the player's own lines.

---Adds the lines of `list`, if there is one, to the end of `pool`.
---@param pool string[]
---@param list string[]?
local function append(pool, list)
    if type(list) ~= "table" then return end
    for _, line in ipairs(list) do
        pool[#pool + 1] = line
    end
end

---The summoned pet's sex: 2 male, 3 female, nil when unknown. The player's
---choice for this pet (/fpe sex, saved under its pet number) comes first;
---without one, what the game reports (UnitSex: 1 unknown, which is what
---WoW: Forever gives for hunter pets, or a secret value counts as nil).
---@return number?
function E.PetSex()
    local petNumber = E.PetNumber()
    local chosen = petNumber and E.db.petSex[petNumber]
    if chosen then return chosen end
    local sex = UnitSex("pet")
    if not E.Public(sex) then return nil end
    return (sex == 2 or sex == 3) and sex or nil
end

---What the lists are chosen by for one feeding: the pet's sex (2 male, 3
---female), the food's type and the pet's family ID, each nil when unknown
---or secret. The family ID is the same on every client language; the name
---is not.
---@param itemID number?
---@return {sex: number?, foodType: string?, family: number?}
local function situationOf(itemID)
    local _, familyID = UnitCreatureFamily("pet")
    return {
        sex = E.PetSex(),
        foodType = itemID and E.FoodTypes[itemID] or nil,
        family = familyID and E.Public(familyID) and familyID or nil,
    }
end

---The lines that apply to feeding the current pet this item, in two lists:
---the player's own lines whose conditions hold (without their conditions),
---and the built-in ones. A line with {food} needs the food's name.
---@param itemID number?
---@param foodName string? the food's name, nil when it is not known
---@return string[] own
---@return string[] builtIn
function E.LinePools(itemID, foodName)
    local emotes, own, builtIn = E.Emotes, {}, {}
    local situation = situationOf(itemID)
    for _, line in ipairs(E.CustomLines()) do
        -- A saved line with a tag this version does not know is skipped.
        local tags, text = E.ParseCustomLine(line)
        if tags and E.ConditionsHold(tags, situation) and (foodName or not text:find("{food}", 1, true)) then
            own[#own + 1] = text
        end
    end
    append(builtIn, emotes.any)
    if situation.sex == 2 then
        append(builtIn, emotes.male)
    elseif situation.sex == 3 then
        append(builtIn, emotes.female)
    end
    local group = itemID and E.FoodGroups[itemID]
    if group then append(builtIn, emotes.food[group]) end
    if situation.foodType and emotes.foodType then append(builtIn, emotes.foodType[situation.foodType]) end
    if situation.family then append(builtIn, emotes.family[situation.family]) end
    return own, builtIn
end

---Every line that fits, own and built-in together: what an even chance
---(E.db.customChance 0) picks from.
---@param itemID number?
---@param foodName string?
---@return string[]
function E.EmotePool(itemID, foodName)
    local own, builtIn = E.LinePools(itemID, foodName)
    append(own, builtIn)
    return own
end

---Picks the line for one emote, or nil for none.
---Chance 0: every fitting line, own or built-in, counts the same.
---Above 0: a roll of 1-100 at or under the chance wants an own line, above it
---a built-in one (100 means own lines only). When an own line is wanted but
---none fits, E.db.customFallback decides: a built-in line, or no line at all
---(the emote then only says who was fed what).
---@param itemID number?
---@param foodName string?
---@return string?
function E.PickLine(itemID, foodName)
    local chance = E.db.customChance
    local own, builtIn = E.LinePools(itemID, foodName)
    local pool
    if chance == 0 then
        pool = E.EmotePool(itemID, foodName)
    elseif math.random(100) <= chance then
        pool = (#own > 0 or not E.db.customFallback) and own or builtIn
    else
        -- A locale always has built-in lines; own ones stand in if it ever has none.
        pool = #builtIn > 0 and builtIn or own
    end
    if #pool == 0 then return nil end
    return pool[math.random(#pool)]
end

---"male", "female", or nil when the pet's sex is unknown or the player asked
---for the pet's name instead (/fpe name on).
---@return "male"|"female"|nil
local function pronounSex()
    if E.db.petName then return nil end
    local sex = E.PetSex()
    return sex == 2 and "male" or sex == 3 and "female" or nil
end

---Replaces the placeholders in an emote line.
---{pet} is always the pet's name, {food} the food's plain name (E.EmotePool
---only offers such a line when the food is known). Any other {token} is one
---of the locale's pronouns (E.Pronouns, e.g. {he} -> he/she); without a known
---sex, or for a token the locale does not define, it becomes the pet's name,
---which reads right in every language. A pronoun whose name form differs
---(a possessive: {his} -> "Fluffy's") gives it as `unknown`: a format with
---%s for the name, or a function of the name when one format is not enough
---(German "Fluffys" but "Boris'"). Function replacements, so a % in a name
---is never read as a capture reference.
---@param line string
---@param pet string
---@param food string?
---@return string
function E.FillPlaceholders(line, pet, food)
    local sex = pronounSex()
    ---What one {token} becomes.
    ---@param token string
    ---@return string
    local function replace(token)
        if token == "food" and food then return food end
        local words = token ~= "pet" and E.Pronouns[token]
        if not words then return pet end
        if sex then return words[sex] end
        local unknown = words.unknown
        if type(unknown) == "string" then return string.format(unknown, pet) end
        return unknown and unknown(pet) or pet
    end
    local filled = line:gsub("{([^}]+)}", replace)
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
    local line = E.PickLine(itemID, name)
    -- No line: the sentence alone, without the space the FEED strings end in.
    if not line then return (text:gsub("%s+$", "")) end
    return text .. E.FillPlaceholders(line, pet, name)
end
