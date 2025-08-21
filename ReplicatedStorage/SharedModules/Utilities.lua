-- Utilities.lua
-- Funciones de utilidad compartidas

local Utilities = {}

-- Generar un ID único
function Utilities.GenerateUUID()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

-- Seleccionar elemento aleatorio de una tabla
function Utilities.RandomChoice(tbl)
    if #tbl == 0 then return nil end
    return tbl[math.random(1, #tbl)]
end

-- Número aleatorio con distribución normal
function Utilities.RandomNormal(mean, std)
    local u1 = math.random()
    local u2 = math.random()
    local z0 = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
    return z0 * std + mean
end

-- Clamp valor entre min y max
function Utilities.Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

-- Mezclar tabla (algoritmo Fisher-Yates)
function Utilities.Shuffle(tbl)
    local result = {}
    for i = 1, #tbl do
        result[i] = tbl[i]
    end
    
    for i = #result, 2, -1 do
        local j = math.random(i)
        result[i], result[j] = result[j], result[i]
    end
    
    return result
end

-- Obtener rareza basada en probabilidades
function Utilities.GetRarityFromProbabilities(probabilities)
    local roll = math.random()
    local cumulative = 0
    
    for rarity, probability in pairs(probabilities) do
        cumulative = cumulative + probability
        if roll <= cumulative then
            return rarity
        end
    end
    
    return 1 -- Fallback a COMMON
end

-- Calcular poder de combate total de un personaje
function Utilities.CalculateCombatPower(character)
    local attributes = character.attributes
    local basePower = attributes.strength + attributes.intelligence + 
                     attributes.speed + attributes.resistance + 
                     attributes.charm + attributes.luck
    
    local levelBonus = character.level * 10
    local rarityBonus = character.rarity * 50
    local ageBonus = character.age * 5
    
    return basePower + levelBonus + rarityBonus + ageBonus
end

-- Formatear tiempo desde epoch
function Utilities.FormatTime(timestamp)
    local currentTime = os.time()
    local diff = currentTime - timestamp
    
    if diff < 60 then
        return "hace " .. diff .. " segundos"
    elseif diff < 3600 then
        return "hace " .. math.floor(diff / 60) .. " minutos"
    elseif diff < 86400 then
        return "hace " .. math.floor(diff / 3600) .. " horas"
    else
        return "hace " .. math.floor(diff / 86400) .. " días"
    end
end

-- Validar estructura de datos de personaje
function Utilities.ValidateCharacter(character)
    if type(character) ~= "table" then return false end
    if type(character.id) ~= "string" or character.id == "" then return false end
    if type(character.name) ~= "string" or character.name == "" then return false end
    if type(character.rarity) ~= "number" or character.rarity < 1 or character.rarity > 6 then return false end
    if type(character.attributes) ~= "table" then return false end
    
    return true
end

-- Deep copy de una tabla
function Utilities.DeepCopy(original)
    local copy
    if type(original) == 'table' then
        copy = {}
        for orig_key, orig_value in next, original, nil do
            copy[Utilities.DeepCopy(orig_key)] = Utilities.DeepCopy(orig_value)
        end
        setmetatable(copy, Utilities.DeepCopy(getmetatable(original)))
    else
        copy = original
    end
    return copy
end

-- Interpolación lineal
function Utilities.Lerp(a, b, t)
    return a + (b - a) * t
end

-- Calcular experiencia necesaria para el siguiente nivel
function Utilities.GetExpForNextLevel(level, config)
    return math.floor(config.BaseExpPerLevel * (config.ExpMultiplier ^ (level - 1)))
end

-- Verificar si un personaje puede subir de nivel
function Utilities.CanLevelUp(character, config)
    local expNeeded = Utilities.GetExpForNextLevel(character.level, config)
    return character.experience >= expNeeded and character.level < config.MaxLevel
end

return Utilities