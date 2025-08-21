-- CharacterGenerator.lua
-- Sistema de generación procedural de personajes únicos

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CharacterTypes = require(ReplicatedStorage.SharedModules.CharacterTypes)
local GameConfig = require(ReplicatedStorage.SharedModules.GameConfig)
local Utilities = require(ReplicatedStorage.SharedModules.Utilities)

local CharacterGenerator = {}

-- Inicializar generador de números aleatorios
math.randomseed(tick())

-- Generar atributos basados en rareza
function CharacterGenerator.GenerateAttributes(rarity)
    local baseStats = {10, 15, 20, 30, 45, 65} -- Stats base por rareza
    local variation = {5, 8, 12, 18, 25, 35}   -- Variación permitida
    
    local base = baseStats[rarity] or 10
    local var = variation[rarity] or 5
    
    local attributes = {}
    local statNames = {"strength", "intelligence", "speed", "resistance", "charm", "luck"}
    
    for _, statName in ipairs(statNames) do
        -- Generar stat con distribución normal
        local value = Utilities.RandomNormal(base, var * 0.3)
        value = Utilities.Clamp(math.floor(value), base - var, base + var)
        attributes[statName] = value
    end
    
    -- Asegurar que al menos un stat sea alto para personajes raros
    if rarity >= 4 then
        local randomStat = Utilities.RandomChoice(statNames)
        attributes[randomStat] = math.max(attributes[randomStat], base + math.floor(var * 0.7))
    end
    
    return attributes
end

-- Generar personalidad basada en rareza
function CharacterGenerator.GeneratePersonality(rarity)
    local availableTraits = GameConfig.PersonalityByRarity[rarity] or GameConfig.PersonalityByRarity[1]
    local numTraits = math.min(rarity, 3) -- Máximo 3 traits
    
    local traits = {}
    local shuffledTraits = Utilities.Shuffle(availableTraits)
    
    for i = 1, numTraits do
        if shuffledTraits[i] then
            table.insert(traits, shuffledTraits[i])
        end
    end
    
    local combatStyles = {"AGGRESSIVE", "DEFENSIVE", "BALANCED", "SUPPORT", "TACTICAL"}
    local combatStyle = Utilities.RandomChoice(combatStyles)
    
    -- Personalidades raras tienen stats más extremos
    local statRange = rarity >= 3 and {20, 80} or {30, 70}
    
    return CharacterTypes.CreatePersonality({
        traits = traits,
        combatStyle = combatStyle,
        loyaltyLevel = math.random(statRange[1], statRange[2]),
        sociability = math.random(statRange[1], statRange[2]),
        stubbornness = math.random(statRange[1], statRange[2])
    })
end

-- Generar apariencia única
function CharacterGenerator.GenerateAppearance(rarity, gender)
    local hairColors = {
        "black", "brown", "blonde", "red", "blue", "green", "purple", "pink", "white", "silver"
    }
    local eyeColors = {
        "brown", "blue", "green", "hazel", "gray", "amber", "violet", "red", "gold", "heterochromia"
    }
    local bodyTypes = {"petite", "average", "tall", "athletic", "curvy"}
    local clothingStyles = {"casual", "formal", "school", "fantasy", "modern", "traditional"}
    
    -- Colores más raros para personajes de mayor rareza
    local hairColor = hairColors[math.random(1, math.min(#hairColors, 4 + rarity * 2))]
    local eyeColor = eyeColors[math.random(1, math.min(#eyeColors, 4 + rarity * 2))]
    
    local specialFeatures = {}
    
    -- Características especiales basadas en rareza
    if rarity >= 3 then
        local features = {"heterochromia", "cat_ears", "fox_tail", "wings", "horns", "markings"}
        local numFeatures = math.min(rarity - 2, 3)
        local shuffled = Utilities.Shuffle(features)
        
        for i = 1, numFeatures do
            if shuffled[i] then
                table.insert(specialFeatures, shuffled[i])
            end
        end
    end
    
    -- Altura basada en tipo de cuerpo y género
    local baseHeight = gender == "female" and 155 or 170
    local heightVariation = 20
    local height = baseHeight + math.random(-heightVariation, heightVariation)
    
    return CharacterTypes.CreateAppearance({
        hairColor = hairColor,
        eyeColor = eyeColor,
        height = height,
        bodyType = Utilities.RandomChoice(bodyTypes),
        clothingStyle = Utilities.RandomChoice(clothingStyles),
        specialFeatures = specialFeatures
    })
end

-- Generar nombre basado en género
function CharacterGenerator.GenerateName(gender)
    local namePool = gender == "female" and GameConfig.AnimeDatabase.FemaleNames or GameConfig.AnimeDatabase.MaleNames
    local baseName = Utilities.RandomChoice(namePool)
    
    -- 20% de chance de generar variación del nombre
    if math.random() < 0.2 then
        local suffixes = {"", "-chan", "-kun", "-sama", "-san"}
        local suffix = Utilities.RandomChoice(suffixes)
        return baseName .. suffix
    end
    
    return baseName
end

-- Generar personaje completo
function CharacterGenerator.GenerateCharacter(rarity, ownerId)
    rarity = rarity or Utilities.GetRarityFromProbabilities(GameConfig.GachaProbabilities)
    
    local gender = math.random() < 0.5 and "female" or "male"
    local name = CharacterGenerator.GenerateName(gender)
    local series = Utilities.RandomChoice(GameConfig.AnimeDatabase.Series)
    
    local character = CharacterTypes.CreateCharacter({
        id = Utilities.GenerateUUID(),
        name = name,
        series = series,
        rarity = rarity,
        attributes = CharacterGenerator.GenerateAttributes(rarity),
        personality = CharacterGenerator.GeneratePersonality(rarity),
        appearance = CharacterGenerator.GenerateAppearance(rarity, gender),
        createdAt = os.time(),
        lastUpdated = os.time(),
        age = 0,
        level = 1,
        experience = 0,
        ownerId = ownerId
    })
    
    return character
end

-- Generar múltiples personajes (para gacha multi-pull)
function CharacterGenerator.GenerateMultipleCharacters(count, ownerId, guaranteedRarity)
    local characters = {}
    
    for i = 1, count do
        local rarity = nil
        
        -- Último pull garantizado con rareza mínima
        if i == count and guaranteedRarity then
            rarity = guaranteedRarity
        end
        
        local character = CharacterGenerator.GenerateCharacter(rarity, ownerId)
        table.insert(characters, character)
    end
    
    return characters
end

-- Breeding: combinar dos personajes para crear uno nuevo
function CharacterGenerator.BreedCharacters(parent1, parent2, ownerId)
    if not parent1 or not parent2 then
        return nil, "Faltan personajes padre"
    end
    
    if parent1.ownerId ~= ownerId or parent2.ownerId ~= ownerId then
        return nil, "No eres dueño de estos personajes"
    end
    
    -- La rareza del hijo se basa en los padres
    local avgRarity = math.ceil((parent1.rarity + parent2.rarity) / 2)
    local bonusChance = (parent1.rarity + parent2.rarity) / 12 -- Bonus hasta 100%
    
    if math.random() < bonusChance then
        avgRarity = math.min(avgRarity + 1, 6)
    end
    
    -- Generar hijo con características mixtas
    local child = CharacterGenerator.GenerateCharacter(avgRarity, ownerId)
    
    -- Mezclar algunos atributos de los padres
    for statName, _ in pairs(child.attributes) do
        local parent1Stat = parent1.attributes[statName] or 10
        local parent2Stat = parent2.attributes[statName] or 10
        local average = (parent1Stat + parent2Stat) / 2
        local variation = math.random(-5, 5)
        
        child.attributes[statName] = math.max(1, math.floor(average + variation))
    end
    
    -- Heredar algunas características especiales
    if #parent1.appearance.specialFeatures > 0 or #parent2.appearance.specialFeatures > 0 then
        local allFeatures = {}
        for _, feature in ipairs(parent1.appearance.specialFeatures) do
            table.insert(allFeatures, feature)
        end
        for _, feature in ipairs(parent2.appearance.specialFeatures) do
            table.insert(allFeatures, feature)
        end
        
        if #allFeatures > 0 and math.random() < 0.7 then
            local inheritedFeature = Utilities.RandomChoice(allFeatures)
            if not table.find(child.appearance.specialFeatures, inheritedFeature) then
                table.insert(child.appearance.specialFeatures, inheritedFeature)
            end
        end
    end
    
    return child, nil
end

return CharacterGenerator