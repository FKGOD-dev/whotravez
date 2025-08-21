-- CharacterDatabase.lua
-- Sistema de base de datos para personajes usando DataStore

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local CharacterTypes = require(ReplicatedStorage.SharedModules.CharacterTypes)
local Utilities = require(ReplicatedStorage.SharedModules.Utilities)

local CharacterDatabase = {}

-- DataStores
local PlayerDataStore = DataStoreService:GetDataStore("PlayerData_v1")
local CharacterDataStore = DataStoreService:GetDataStore("CharacterData_v1")
local GlobalStatsStore = DataStoreService:GetDataStore("GlobalStats_v1")

-- Cache en memoria para datos frecuentemente accedidos
local playerDataCache = {}
local characterCache = {}

-- Guardar datos de jugador
function CharacterDatabase.SavePlayerData(playerId, playerData)
    local success, error = pcall(function()
        PlayerDataStore:SetAsync(tostring(playerId), playerData)
    end)
    
    if success then
        playerDataCache[playerId] = Utilities.DeepCopy(playerData)
        return true
    else
        warn("Error guardando datos del jugador " .. playerId .. ": " .. tostring(error))
        return false
    end
end

-- Cargar datos de jugador
function CharacterDatabase.LoadPlayerData(playerId)
    -- Primero verificar cache
    if playerDataCache[playerId] then
        return playerDataCache[playerId]
    end
    
    local success, playerData = pcall(function()
        return PlayerDataStore:GetAsync(tostring(playerId))
    end)
    
    if success and playerData then
        playerDataCache[playerId] = playerData
        return playerData
    else
        -- Crear datos default para nuevo jugador
        local defaultData = CharacterTypes.CreatePlayer({
            id = tostring(playerId),
            username = Players:GetPlayerByUserId(playerId).Name
        })
        
        CharacterDatabase.SavePlayerData(playerId, defaultData)
        return defaultData
    end
end

-- Guardar personaje individual
function CharacterDatabase.SaveCharacter(character)
    if not Utilities.ValidateCharacter(character) then
        warn("Personaje inválido, no se puede guardar")
        return false
    end
    
    local success, error = pcall(function()
        CharacterDataStore:SetAsync(character.id, character)
    end)
    
    if success then
        characterCache[character.id] = Utilities.DeepCopy(character)
        return true
    else
        warn("Error guardando personaje " .. character.id .. ": " .. tostring(error))
        return false
    end
end

-- Cargar personaje individual
function CharacterDatabase.LoadCharacter(characterId)
    -- Verificar cache primero
    if characterCache[characterId] then
        return characterCache[characterId]
    end
    
    local success, character = pcall(function()
        return CharacterDataStore:GetAsync(characterId)
    end)
    
    if success and character then
        characterCache[characterId] = character
        return character
    else
        return nil
    end
end

-- Obtener todos los personajes de un jugador
function CharacterDatabase.GetPlayerCharacters(playerId)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    if not playerData or not playerData.characters then
        return {}
    end
    
    local characters = {}
    for _, characterId in ipairs(playerData.characters) do
        local character = CharacterDatabase.LoadCharacter(characterId)
        if character then
            table.insert(characters, character)
        end
    end
    
    return characters
end

-- Agregar personaje a la colección de un jugador
function CharacterDatabase.AddCharacterToPlayer(playerId, character)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    if not playerData then
        return false, "No se pudieron cargar los datos del jugador"
    end
    
    -- Verificar slots disponibles
    if #playerData.characters >= playerData.inventory.maxCharacterSlots then
        return false, "No hay slots disponibles"
    end
    
    -- Guardar el personaje
    character.ownerId = tostring(playerId)
    local saved = CharacterDatabase.SaveCharacter(character)
    if not saved then
        return false, "Error guardando el personaje"
    end
    
    -- Agregar ID a la lista del jugador
    table.insert(playerData.characters, character.id)
    
    -- Actualizar estadísticas
    playerData.stats.totalCharacters = #playerData.characters
    
    -- Guardar datos actualizados del jugador
    local playerSaved = CharacterDatabase.SavePlayerData(playerId, playerData)
    if not playerSaved then
        return false, "Error actualizando datos del jugador"
    end
    
    return true, nil
end

-- Remover personaje de la colección de un jugador
function CharacterDatabase.RemoveCharacterFromPlayer(playerId, characterId)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    if not playerData then
        return false, "No se pudieron cargar los datos del jugador"
    end
    
    -- Encontrar y remover el personaje de la lista
    local characterIndex = nil
    for i, id in ipairs(playerData.characters) do
        if id == characterId then
            characterIndex = i
            break
        end
    end
    
    if not characterIndex then
        return false, "Personaje no encontrado en la colección"
    end
    
    -- Verificar que el personaje pertenezca al jugador
    local character = CharacterDatabase.LoadCharacter(characterId)
    if not character or character.ownerId ~= tostring(playerId) then
        return false, "No eres dueño de este personaje"
    end
    
    -- Remover de la lista
    table.remove(playerData.characters, characterIndex)
    
    -- Actualizar estadísticas
    playerData.stats.totalCharacters = #playerData.characters
    
    -- Guardar datos actualizados
    local saved = CharacterDatabase.SavePlayerData(playerId, playerData)
    if not saved then
        return false, "Error actualizando datos del jugador"
    end
    
    -- Remover del cache
    characterCache[characterId] = nil
    
    return true, nil
end

-- Actualizar moneda del jugador
function CharacterDatabase.UpdatePlayerCurrency(playerId, currencyChanges)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    if not playerData then
        return false, "No se pudieron cargar los datos del jugador"
    end
    
    -- Aplicar cambios
    for currencyType, amount in pairs(currencyChanges) do
        if playerData.currency[currencyType] then
            playerData.currency[currencyType] = math.max(0, playerData.currency[currencyType] + amount)
        end
    end
    
    return CharacterDatabase.SavePlayerData(playerId, playerData)
end

-- Actualizar estadísticas del jugador
function CharacterDatabase.UpdatePlayerStats(playerId, statChanges)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    if not playerData then
        return false
    end
    
    for statName, amount in pairs(statChanges) do
        if playerData.stats[statName] then
            playerData.stats[statName] = playerData.stats[statName] + amount
        end
    end
    
    return CharacterDatabase.SavePlayerData(playerId, playerData)
end

-- Obtener estadísticas globales
function CharacterDatabase.GetGlobalStats()
    local success, stats = pcall(function()
        return GlobalStatsStore:GetAsync("global_stats") or {
            totalPlayers = 0,
            totalCharacters = 0,
            totalPulls = 0,
            rareCharacters = 0
        }
    end)
    
    return success and stats or {}
end

-- Actualizar estadísticas globales
function CharacterDatabase.UpdateGlobalStats(statChanges)
    local stats = CharacterDatabase.GetGlobalStats()
    
    for statName, amount in pairs(statChanges) do
        if stats[statName] then
            stats[statName] = stats[statName] + amount
        end
    end
    
    pcall(function()
        GlobalStatsStore:SetAsync("global_stats", stats)
    end)
end

-- Limpiar cache (llamar periódicamente)
function CharacterDatabase.ClearCache()
    local currentTime = os.time()
    
    -- Limpiar cache de personajes no accedidos en 5 minutos
    for characterId, _ in pairs(characterCache) do
        -- Aquí podrías agregar lógica de tiempo si almacenas timestamps
        -- Por simplicidad, mantenemos todos en cache
    end
    
    -- Limpiar cache de jugadores desconectados
    for playerId, _ in pairs(playerDataCache) do
        local player = Players:GetPlayerByUserId(tonumber(playerId))
        if not player then
            playerDataCache[playerId] = nil
        end
    end
end

-- Evento de limpieza periódica
spawn(function()
    while true do
        wait(300) -- 5 minutos
        CharacterDatabase.ClearCache()
    end
end)

-- Manejar desconexión de jugadores
Players.PlayerRemoving:Connect(function(player)
    local playerId = player.UserId
    
    -- Guardar datos una última vez antes de limpiar cache
    if playerDataCache[playerId] then
        CharacterDatabase.SavePlayerData(playerId, playerDataCache[playerId])
        playerDataCache[playerId] = nil
    end
end)

return CharacterDatabase