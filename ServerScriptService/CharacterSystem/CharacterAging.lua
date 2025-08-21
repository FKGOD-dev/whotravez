-- CharacterAging.lua
-- Sistema de envejecimiento de personajes que aumenta su rareza con el tiempo

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CharacterTypes = require(ReplicatedStorage.SharedModules.CharacterTypes)
local GameConfig = require(ReplicatedStorage.SharedModules.GameConfig)
local Utilities = require(ReplicatedStorage.SharedModules.Utilities)
local CharacterDatabase = require(script.Parent.CharacterDatabase)

local CharacterAging = {}

-- Eventos para notificar cambios
local eventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local CharacterAged = eventsFolder:WaitForChild("CharacterAged")

-- Sistema de envejecimiento en tiempo real
local lastAgingCheck = os.time()

-- Calcular la edad actual de un personaje basada en el tiempo transcurrido
function CharacterAging.CalculateCurrentAge(character)
    local timeElapsed = os.time() - character.createdAt
    local hoursElapsed = timeElapsed / 3600 -- Convertir segundos a horas
    
    -- Cada 24 horas = 1 año de personaje
    local yearsElapsed = math.floor(hoursElapsed / GameConfig.Aging.AgeIntervalHours)
    return math.min(yearsElapsed, GameConfig.Aging.MaxAge)
end

-- Calcular bonus de rareza por edad
function CharacterAging.CalculateRarityBonus(character, currentAge)
    local ageBonus = currentAge * (GameConfig.Aging.RarityBonusPerAge[character.rarity] or 0.001)
    return ageBonus
end

-- Calcular bonus de atributos por edad
function CharacterAging.CalculateAttributeBonus(character, currentAge)
    local bonusPerYear = character.rarity * 2 -- Más rareza = más bonus por año
    local totalBonus = currentAge * bonusPerYear
    
    -- Distribuir el bonus entre los atributos
    local attributeBonus = {}
    local statNames = {"strength", "intelligence", "speed", "resistance", "charm", "luck"}
    
    for _, statName in ipairs(statNames) do
        -- Bonus variable por stat, algunos stats se benefician más con la edad
        local statMultiplier = 1.0
        
        if statName == "intelligence" or statName == "charm" then
            statMultiplier = 1.3 -- La inteligencia y carisma mejoran más con la edad
        elseif statName == "speed" then
            statMultiplier = 0.7 -- La velocidad disminuye ligeramente con la edad
        end
        
        attributeBonus[statName] = math.floor(totalBonus * statMultiplier / #statNames)
    end
    
    return attributeBonus
end

-- Actualizar edad y stats de un personaje
function CharacterAging.AgeCharacter(character)
    local currentAge = CharacterAging.CalculateCurrentAge(character)
    
    -- Si la edad no ha cambiado, no hay nada que hacer
    if currentAge <= character.age then
        return character, false
    end
    
    local previousAge = character.age
    character.age = currentAge
    character.lastUpdated = os.time()
    
    -- Aplicar bonus de atributos
    local attributeBonus = CharacterAging.CalculateAttributeBonus(character, currentAge - previousAge)
    
    for statName, bonus in pairs(attributeBonus) do
        if character.attributes[statName] then
            character.attributes[statName] = character.attributes[statName] + bonus
        end
    end
    
    -- Verificar si el personaje sube de rareza (muy raro)
    local rarityBonus = CharacterAging.CalculateRarityBonus(character, currentAge)
    local rarityUpChance = rarityBonus * (currentAge / GameConfig.Aging.MaxAge)
    
    local rarityIncreased = false
    if character.rarity < CharacterTypes.Rarity.MYTHIC and math.random() < rarityUpChance then
        character.rarity = character.rarity + 1
        rarityIncreased = true
    end
    
    -- Guardar cambios
    CharacterDatabase.SaveCharacter(character)
    
    return character, true, rarityIncreased
end

-- Envejecer todos los personajes de un jugador
function CharacterAging.AgePlayerCharacters(playerId)
    local characters = CharacterDatabase.GetPlayerCharacters(playerId)
    local agedCharacters = {}
    
    for _, character in ipairs(characters) do
        local updatedCharacter, aged, rarityIncreased = CharacterAging.AgeCharacter(character)
        
        if aged then
            table.insert(agedCharacters, {
                character = updatedCharacter,
                rarityIncreased = rarityIncreased
            })
        end
    end
    
    -- Notificar al cliente si hubo cambios
    if #agedCharacters > 0 then
        local player = game.Players:GetPlayerByUserId(playerId)
        if player then
            CharacterAged:FireClient(player, agedCharacters)
        end
    end
    
    return agedCharacters
end

-- Envejecer todos los personajes en el servidor (ejecutar periódicamente)
function CharacterAging.AgeAllCharacters()
    local players = game.Players:GetPlayers()
    
    for _, player in ipairs(players) do
        CharacterAging.AgePlayerCharacters(player.UserId)
        wait(0.1) -- Pequeña pausa para no sobrecargar
    end
end

-- Sistema automático de envejecimiento
spawn(function()
    while true do
        wait(3600) -- Verificar cada hora
        
        local currentTime = os.time()
        if currentTime - lastAgingCheck >= 3600 then -- Al menos 1 hora desde la última verificación
            lastAgingCheck = currentTime
            CharacterAging.AgeAllCharacters()
        end
    end
end)

-- Función para obtener información de envejecimiento de un personaje
function CharacterAging.GetAgingInfo(character)
    local currentAge = CharacterAging.CalculateCurrentAge(character)
    local timeUntilNextAge = GameConfig.Aging.AgeIntervalHours * 3600 - ((os.time() - character.createdAt) % (GameConfig.Aging.AgeIntervalHours * 3600))
    
    local rarityBonus = CharacterAging.CalculateRarityBonus(character, currentAge)
    local nextRarityChance = rarityBonus * ((currentAge + 1) / GameConfig.Aging.MaxAge)
    
    return {
        currentAge = currentAge,
        maxAge = GameConfig.Aging.MaxAge,
        timeUntilNextAge = timeUntilNextAge,
        rarityBonus = rarityBonus,
        nextRarityUpChance = nextRarityChance,
        ageProgress = currentAge / GameConfig.Aging.MaxAge
    }
end

-- Función para forzar el envejecimiento (para testing o eventos especiales)
function CharacterAging.ForceAge(characterId, yearsToAdd)
    local character = CharacterDatabase.LoadCharacter(characterId)
    if not character then
        return false, "Personaje no encontrado"
    end
    
    -- Simular el paso del tiempo
    local hoursToAdd = yearsToAdd * GameConfig.Aging.AgeIntervalHours
    local secondsToAdd = hoursToAdd * 3600
    
    character.createdAt = character.createdAt - secondsToAdd
    
    -- Aplicar envejecimiento
    local updatedCharacter, aged, rarityIncreased = CharacterAging.AgeCharacter(character)
    
    return true, {
        character = updatedCharacter,
        aged = aged,
        rarityIncreased = rarityIncreased
    }
end

-- Evento cuando un jugador se conecta - envejecer sus personajes
game.Players.PlayerAdded:Connect(function(player)
    wait(2) -- Esperar a que se carguen los datos
    CharacterAging.AgePlayerCharacters(player.UserId)
end)

return CharacterAging