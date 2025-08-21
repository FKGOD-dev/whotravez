-- TrainingSystem.lua
-- Sistema de entrenamiento para mejorar atributos de personajes

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CharacterTypes = require(ReplicatedStorage.SharedModules.CharacterTypes)
local GameConfig = require(ReplicatedStorage.SharedModules.GameConfig)
local Utilities = require(ReplicatedStorage.SharedModules.Utilities)
local CharacterDatabase = require(script.Parent.Parent.CharacterSystem.CharacterDatabase)

local TrainingSystem = {}

-- Eventos
local eventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local CharacterUpdated = eventsFolder:WaitForChild("CharacterUpdated")

-- Tipos de entrenamiento disponibles
local TrainingTypes = {
    STRENGTH = {
        name = "Entrenamiento de Fuerza",
        description = "Mejora la fuerza del personaje",
        targetStat = "strength",
        cost = 100,
        duration = 1800, -- 30 minutos
        gainRange = {2, 5}
    },
    INTELLIGENCE = {
        name = "Estudio Intensivo",
        description = "Mejora la inteligencia del personaje",
        targetStat = "intelligence", 
        cost = 100,
        duration = 1800,
        gainRange = {2, 5}
    },
    SPEED = {
        name = "Entrenamiento de Velocidad",
        description = "Mejora la velocidad del personaje",
        targetStat = "speed",
        cost = 100,
        duration = 1800,
        gainRange = {2, 5}
    },
    RESISTANCE = {
        name = "Entrenamiento de Resistencia",
        description = "Mejora la resistencia del personaje",
        targetStat = "resistance",
        cost = 100,
        duration = 1800,
        gainRange = {2, 5}
    },
    CHARM = {
        name = "Entrenamiento de Carisma",
        description = "Mejora el carisma del personaje",
        targetStat = "charm",
        cost = 100,
        duration = 1800,
        gainRange = {2, 5}
    },
    LUCK = {
        name = "Meditación de la Suerte",
        description = "Mejora la suerte del personaje",
        targetStat = "luck",
        cost = 150, -- Más costoso porque la suerte es valiosa
        duration = 2700, -- 45 minutos
        gainRange = {1, 3}
    },
    BALANCED = {
        name = "Entrenamiento Equilibrado",
        description = "Mejora todos los atributos ligeramente",
        targetStat = "all",
        cost = 300,
        duration = 3600, -- 1 hora
        gainRange = {1, 2}
    }
}

-- Verificar si un personaje puede entrenar
function TrainingSystem.CanCharacterTrain(characterId, playerId)
    local character = CharacterDatabase.LoadCharacter(characterId)
    if not character then
        return false, "Personaje no encontrado"
    end
    
    if character.ownerId ~= tostring(playerId) then
        return false, "No eres dueño de este personaje"
    end
    
    -- Verificar si ya está entrenando
    if character.trainingState and character.trainingState.inProgress then
        local currentTime = os.time()
        if currentTime < character.trainingState.endTime then
            return false, "El personaje ya está entrenando"
        end
    end
    
    -- Verificar límite diario
    local today = math.floor(os.time() / (24 * 60 * 60))
    local trainingHistory = character.trainingHistory or {}
    local todayTrainings = trainingHistory[today] or 0
    
    if todayTrainings >= GameConfig.Training.MaxTrainingsPerDay then
        return false, "Límite diario de entrenamientos alcanzado"
    end
    
    return true, nil
end

-- Iniciar entrenamiento
function TrainingSystem.StartTraining(characterId, playerId, trainingType)
    local canTrain, error = TrainingSystem.CanCharacterTrain(characterId, playerId)
    if not canTrain then
        return false, error
    end
    
    local training = TrainingTypes[trainingType]
    if not training then
        return false, "Tipo de entrenamiento inválido"
    end
    
    -- Verificar que el jugador tenga suficientes monedas
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    if playerData.currency.coins < training.cost then
        return false, "No tienes suficientes monedas"
    end
    
    local character = CharacterDatabase.LoadCharacter(characterId)
    local currentTime = os.time()
    
    -- Configurar estado de entrenamiento
    character.trainingState = {
        inProgress = true,
        trainingType = trainingType,
        startTime = currentTime,
        endTime = currentTime + training.duration,
        cost = training.cost
    }
    
    -- Deducir costo
    CharacterDatabase.UpdatePlayerCurrency(playerId, {coins = -training.cost})
    
    -- Guardar personaje
    CharacterDatabase.SaveCharacter(character)
    
    -- Actualizar historial de entrenamientos
    local today = math.floor(currentTime / (24 * 60 * 60))
    local trainingHistory = character.trainingHistory or {}
    trainingHistory[today] = (trainingHistory[today] or 0) + 1
    character.trainingHistory = trainingHistory
    
    CharacterDatabase.SaveCharacter(character)
    
    return true, {
        endTime = character.trainingState.endTime,
        duration = training.duration
    }
end

-- Completar entrenamiento y reclamar recompensas
function TrainingSystem.CompleteTraining(characterId, playerId)
    local character = CharacterDatabase.LoadCharacter(characterId)
    if not character then
        return false, "Personaje no encontrado"
    end
    
    if character.ownerId ~= tostring(playerId) then
        return false, "No eres dueño de este personaje"
    end
    
    if not character.trainingState or not character.trainingState.inProgress then
        return false, "El personaje no está entrenando"
    end
    
    local currentTime = os.time()
    if currentTime < character.trainingState.endTime then
        return false, "El entrenamiento aún no ha terminado"
    end
    
    local trainingType = character.trainingState.trainingType
    local training = TrainingTypes[trainingType]
    
    -- Calcular mejoras
    local improvements = {}
    
    if training.targetStat == "all" then
        -- Mejorar todos los atributos
        for statName, _ in pairs(character.attributes) do
            local gain = math.random(training.gainRange[1], training.gainRange[2])
            
            -- Bonus por rareza del personaje
            local rarityBonus = math.floor(character.rarity * 0.5)
            gain = gain + rarityBonus
            
            character.attributes[statName] = character.attributes[statName] + gain
            improvements[statName] = gain
        end
    else
        -- Mejorar atributo específico
        local targetStat = training.targetStat
        local baseGain = math.random(training.gainRange[1], training.gainRange[2])
        
        -- Bonus por rareza y nivel
        local rarityBonus = character.rarity
        local levelBonus = math.floor(character.level * 0.1)
        
        local totalGain = baseGain + rarityBonus + levelBonus
        
        character.attributes[targetStat] = character.attributes[targetStat] + totalGain
        improvements[targetStat] = totalGain
        
        -- Pequeña posibilidad de mejorar un stat secundario
        if math.random() < 0.3 then
            local secondaryStats = {}
            for statName, _ in pairs(character.attributes) do
                if statName ~= targetStat then
                    table.insert(secondaryStats, statName)
                end
            end
            
            if #secondaryStats > 0 then
                local secondaryStat = Utilities.RandomChoice(secondaryStats)
                local secondaryGain = math.random(1, 2)
                character.attributes[secondaryStat] = character.attributes[secondaryStat] + secondaryGain
                improvements[secondaryStat] = secondaryGain
            end
        end
    end
    
    -- Ganar experiencia por entrenar
    local expGain = GameConfig.Experience.TrainingExpBase + (character.rarity * 5)
    character.experience = character.experience + expGain
    
    -- Verificar subida de nivel
    local leveledUp = false
    if Utilities.CanLevelUp(character, GameConfig.Experience) then
        character.level = character.level + 1
        character.experience = character.experience - Utilities.GetExpForNextLevel(character.level - 1, GameConfig.Experience)
        leveledUp = true
        
        -- Bonus adicional por subir de nivel durante entrenamiento
        for statName, _ in pairs(character.attributes) do
            character.attributes[statName] = character.attributes[statName] + 1
            improvements[statName] = (improvements[statName] or 0) + 1
        end
    end
    
    -- Limpiar estado de entrenamiento
    character.trainingState = nil
    character.lastUpdated = currentTime
    
    -- Guardar cambios
    CharacterDatabase.SaveCharacter(character)
    
    -- Notificar al cliente
    local player = Players:GetPlayerByUserId(playerId)
    if player then
        CharacterUpdated:FireClient(player, {
            character = character,
            improvements = improvements,
            leveledUp = leveledUp,
            experienceGained = expGain
        })
    end
    
    return true, {
        improvements = improvements,
        leveledUp = leveledUp,
        experienceGained = expGain,
        character = character
    }
end

-- Obtener estado de entrenamiento de un personaje
function TrainingSystem.GetTrainingStatus(characterId)
    local character = CharacterDatabase.LoadCharacter(characterId)
    if not character then
        return nil
    end
    
    if not character.trainingState or not character.trainingState.inProgress then
        return {
            inProgress = false,
            canTrain = true
        }
    end
    
    local currentTime = os.time()
    local timeRemaining = character.trainingState.endTime - currentTime
    
    if timeRemaining <= 0 then
        return {
            inProgress = false,
            canComplete = true,
            completed = true
        }
    end
    
    local training = TrainingTypes[character.trainingState.trainingType]
    
    return {
        inProgress = true,
        trainingType = character.trainingState.trainingType,
        trainingName = training.name,
        timeRemaining = timeRemaining,
        progress = 1 - (timeRemaining / training.duration),
        canComplete = false
    }
end

-- Acelerar entrenamiento (premium feature)
function TrainingSystem.BoostTraining(characterId, playerId)
    local character = CharacterDatabase.LoadCharacter(characterId)
    if not character or character.ownerId ~= tostring(playerId) then
        return false, "Personaje no válido"
    end
    
    if not character.trainingState or not character.trainingState.inProgress then
        return false, "El personaje no está entrenando"
    end
    
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    local boostCost = 50 -- Costo en moneda premium
    
    if playerData.currency.premiumCurrency < boostCost then
        return false, "No tienes suficiente moneda premium"
    end
    
    -- Completar entrenamiento instantáneamente
    character.trainingState.endTime = os.time()
    CharacterDatabase.SaveCharacter(character)
    
    -- Deducir costo
    CharacterDatabase.UpdatePlayerCurrency(playerId, {premiumCurrency = -boostCost})
    
    return true, "Entrenamiento completado instantáneamente"
end

-- Obtener tipos de entrenamiento disponibles
function TrainingSystem.GetAvailableTrainings()
    return TrainingTypes
end

-- Sistema automático para notificar entrenamientos completados
spawn(function()
    while true do
        wait(60) -- Verificar cada minuto
        
        for _, player in ipairs(Players:GetPlayers()) do
            local characters = CharacterDatabase.GetPlayerCharacters(player.UserId)
            
            for _, character in ipairs(characters) do
                if character.trainingState and character.trainingState.inProgress then
                    if os.time() >= character.trainingState.endTime then
                        -- Notificar que el entrenamiento está listo
                        -- (esto se podría hacer con un evento remoto)
                    end
                end
            end
        end
    end
end)

return TrainingSystem