-- CharacterDatabase.lua
-- Sistema de base de datos para personajes usando DataStore

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local CharacterTypes = require(ReplicatedStorage.SharedModules.CharacterTypes)
local Utilities = require(ReplicatedStorage.SharedModules.Utilities)

local CharacterDatabase = {}

-- DataStores con configuración de backup
local CURRENT_VERSION = "v2"
local PlayerDataStore = DataStoreService:GetDataStore("PlayerData_" .. CURRENT_VERSION)
local CharacterDataStore = DataStoreService:GetDataStore("CharacterData_" .. CURRENT_VERSION)
local GlobalStatsStore = DataStoreService:GetDataStore("GlobalStats_" .. CURRENT_VERSION)

-- DataStores de backup
local PlayerBackupStore = DataStoreService:GetDataStore("PlayerBackup_" .. CURRENT_VERSION)
local CharacterBackupStore = DataStoreService:GetDataStore("CharacterBackup_" .. CURRENT_VERSION)

-- Configuración de reintentos
local MAX_RETRIES = 3
local RETRY_DELAY = 1

-- Cache en memoria para datos frecuentemente accedidos
local playerDataCache = {}
local characterCache = {}

-- Estadísticas de operaciones
local stats = {
    saveAttempts = 0,
    saveSuccesses = 0,
    loadAttempts = 0,
    loadSuccesses = 0,
    backupUses = 0
}

-- Función de reintento con exponential backoff
local function retryOperation(operation, maxRetries, delay, operationName)
    for attempt = 1, maxRetries do
        local success, result = pcall(operation)
        
        if success then
            stats.saveSuccesses = stats.saveSuccesses + 1
            return true, result
        else
            warn(string.format("%s falló en intento %d/%d: %s", operationName, attempt, maxRetries, tostring(result)))
            
            if attempt < maxRetries then
                wait(delay * (2 ^ (attempt - 1))) -- Exponential backoff
            end
        end
        
        stats.saveAttempts = stats.saveAttempts + 1
    end
    
    return false, "Operación falló después de " .. maxRetries .. " intentos"
end

-- Guardar datos de jugador con backup automático
function CharacterDatabase.SavePlayerData(playerId, playerData)
    local playerIdStr = tostring(playerId)
    
    -- Validar datos antes de guardar
    if not playerData or type(playerData) ~= "table" then
        warn("Datos de jugador inválidos para ID " .. playerIdStr)
        return false, "Datos inválidos"
    end
    
    -- Agregar timestamp y versión
    playerData.lastSaved = os.time()
    playerData.version = CURRENT_VERSION
    playerData.saveCount = (playerData.saveCount or 0) + 1
    
    -- Intentar guardar en DataStore principal
    local success, error = retryOperation(function()
        PlayerDataStore:SetAsync(playerIdStr, playerData)
    end, MAX_RETRIES, RETRY_DELAY, "SavePlayerData")
    
    if success then
        -- Guardar backup si el guardado principal fue exitoso
        spawn(function()
            retryOperation(function()
                PlayerBackupStore:SetAsync(playerIdStr, playerData)
            end, 2, 0.5, "SavePlayerDataBackup")
        end)
        
        -- Actualizar cache
        playerDataCache[playerId] = Utilities.DeepCopy(playerData)
        return true, nil
    else
        warn("Error crítico guardando datos del jugador " .. playerIdStr .. ": " .. tostring(error))
        return false, error
    end
end

-- Cargar datos de jugador con sistema de backup
function CharacterDatabase.LoadPlayerData(playerId)
    local playerIdStr = tostring(playerId)
    stats.loadAttempts = stats.loadAttempts + 1
    
    -- Primero verificar cache
    if playerDataCache[playerId] then
        return playerDataCache[playerId]
    end
    
    -- Intentar cargar del DataStore principal
    local success, playerData = retryOperation(function()
        return PlayerDataStore:GetAsync(playerIdStr)
    end, MAX_RETRIES, RETRY_DELAY, "LoadPlayerData")
    
    -- Si el principal falla, intentar desde backup
    if not success or not playerData then
        warn("Carga principal falló para jugador " .. playerIdStr .. ", intentando backup...")
        stats.backupUses = stats.backupUses + 1
        
        local backupSuccess, backupData = retryOperation(function()
            return PlayerBackupStore:GetAsync(playerIdStr)
        end, 2, 0.5, "LoadPlayerDataBackup")
        
        if backupSuccess and backupData then
            playerData = backupData
            warn("Datos recuperados desde backup para jugador " .. playerIdStr)
            
            -- Intentar restaurar en el DataStore principal
            spawn(function()
                CharacterDatabase.SavePlayerData(playerId, playerData)
            end)
        end
    end
    
    -- Si tenemos datos, verificar versión y migrar si es necesario
    if playerData then
        playerData = CharacterDatabase.MigratePlayerData(playerData)
        playerDataCache[playerId] = playerData
        stats.loadSuccesses = stats.loadSuccesses + 1
        return playerData
    else
        -- Crear datos default para nuevo jugador
        local player = Players:GetPlayerByUserId(playerId)
        if not player then
            warn("No se pudo obtener información del jugador " .. playerIdStr)
            return nil
        end
        
        local defaultData = CharacterTypes.CreatePlayer({
            id = playerIdStr,
            username = player.Name
        })
        
        local saveSuccess = CharacterDatabase.SavePlayerData(playerId, defaultData)
        if saveSuccess then
            return defaultData
        else
            warn("Error crítico: no se pudieron crear datos por defecto para " .. playerIdStr)
            return nil
        end
    end
end

-- Migración de datos entre versiones
function CharacterDatabase.MigratePlayerData(playerData)
    if not playerData.version or playerData.version == "v1" then
        -- Migrar de v1 a v2
        print("Migrando datos de jugador de v1 a v2...")
        
        -- Agregar nuevos campos
        playerData.battleHistory = playerData.battleHistory or {}
        playerData.achievements = playerData.achievements or {}
        playerData.settings = playerData.settings or {
            notifications = true,
            autoSave = true,
            language = "es"
        }
        
        -- Migrar formato de monedas si es necesario
        if not playerData.currency.premiumCurrency then
            playerData.currency.premiumCurrency = 0
        end
        
        -- Migrar formato de inventario
        if not playerData.inventory.maxCharacterSlots then
            playerData.inventory.maxCharacterSlots = 50
        end
        
        playerData.version = "v2"
        print("Migración completada para jugador " .. tostring(playerData.id))
    end
    
    return playerData
end

-- Guardar personaje individual con backup
function CharacterDatabase.SaveCharacter(character)
    if not Utilities.ValidateCharacter(character) then
        warn("Personaje inválido, no se puede guardar")
        return false, "Personaje inválido"
    end
    
    -- Agregar timestamp
    character.lastSaved = os.time()
    character.version = CURRENT_VERSION
    
    -- Intentar guardar en DataStore principal
    local success, error = retryOperation(function()
        CharacterDataStore:SetAsync(character.id, character)
    end, MAX_RETRIES, RETRY_DELAY, "SaveCharacter")
    
    if success then
        -- Guardar backup asincrónicamente
        spawn(function()
            retryOperation(function()
                CharacterBackupStore:SetAsync(character.id, character)
            end, 2, 0.5, "SaveCharacterBackup")
        end)
        
        -- Actualizar cache
        characterCache[character.id] = Utilities.DeepCopy(character)
        return true, nil
    else
        warn("Error crítico guardando personaje " .. character.id .. ": " .. tostring(error))
        return false, error
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

-- Obtener estadísticas de rendimiento del DataStore
function CharacterDatabase.GetPerformanceStats()
    return {
        saveAttempts = stats.saveAttempts,
        saveSuccesses = stats.saveSuccesses,
        loadAttempts = stats.loadAttempts,
        loadSuccesses = stats.loadSuccesses,
        backupUses = stats.backupUses,
        saveSuccessRate = stats.saveAttempts > 0 and (stats.saveSuccesses / stats.saveAttempts * 100) or 0,
        loadSuccessRate = stats.loadAttempts > 0 and (stats.loadSuccesses / stats.loadAttempts * 100) or 0,
        cacheSizes = {
            players = 0,
            characters = 0
        }
    }
end

-- Función de emergencia para restaurar desde backup
function CharacterDatabase.EmergencyRestore(playerId)
    local playerIdStr = tostring(playerId)
    warn("Iniciando restauración de emergencia para jugador " .. playerIdStr)
    
    local success, backupData = retryOperation(function()
        return PlayerBackupStore:GetAsync(playerIdStr)
    end, MAX_RETRIES, RETRY_DELAY, "EmergencyRestore")
    
    if success and backupData then
        -- Limpiar cache
        playerDataCache[playerId] = nil
        
        -- Restaurar en DataStore principal
        local restoreSuccess = CharacterDatabase.SavePlayerData(playerId, backupData)
        
        if restoreSuccess then
            print("Restauración de emergencia exitosa para jugador " .. playerIdStr)
            return true, backupData
        else
            warn("Falló la restauración de emergencia para jugador " .. playerIdStr)
            return false, "Error restaurando datos"
        end
    else
        warn("No se encontraron datos de backup para jugador " .. playerIdStr)
        return false, "Sin datos de backup"
    end
end

-- Función para validar integridad de datos
function CharacterDatabase.ValidateDataIntegrity(playerId)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    local issues = {}
    
    if not playerData then
        table.insert(issues, "No se pudieron cargar los datos del jugador")
        return false, issues
    end
    
    -- Validar estructura básica
    local requiredFields = {"id", "username", "currency", "characters", "inventory"}
    for _, field in ipairs(requiredFields) do
        if not playerData[field] then
            table.insert(issues, "Campo faltante: " .. field)
        end
    end
    
    -- Validar monedas (no pueden ser negativas)
    if playerData.currency then
        for currencyType, amount in pairs(playerData.currency) do
            if amount < 0 then
                table.insert(issues, "Moneda negativa detectada: " .. currencyType)
            end
        end
    end
    
    -- Validar personajes
    if playerData.characters then
        for i, characterId in ipairs(playerData.characters) do
            local character = CharacterDatabase.LoadCharacter(characterId)
            if not character then
                table.insert(issues, "Personaje perdido: " .. characterId)
            elseif character.ownerId ~= tostring(playerId) then
                table.insert(issues, "Personaje con propietario incorrecto: " .. characterId)
            end
        end
    end
    
    return #issues == 0, issues
end

print("✅ CharacterDatabase v" .. CURRENT_VERSION .. " cargado con sistema de backup y migración")

return CharacterDatabase