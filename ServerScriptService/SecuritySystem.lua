-- SecuritySystem.lua
-- Sistema de seguridad completo para prevenir exploits y validar acciones

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage.SharedModules.GameConfig)
local Utilities = require(ReplicatedStorage.SharedModules.Utilities)

local SecuritySystem = {}

-- ======================== CONFIGURACIÓN ========================

-- Límites de rate limiting (requests por minuto)
local RATE_LIMITS = {
    PullGacha = 60,           -- Max 60 pulls por minuto
    TrainCharacter = 30,      -- Max 30 entrenamientos por minuto
    StartBattle = 20,         -- Max 20 batallas por minuto
    BuyTickets = 10,          -- Max 10 compras por minuto
    GetPlayerCurrency = 120,  -- Max 120 consultas por minuto
    GetPlayerCharacters = 60  -- Max 60 consultas por minuto
}

-- Límites de recursos por jugador
local RESOURCE_LIMITS = {
    maxCharacters = 200,       -- Max personajes por jugador
    maxCurrency = 999999999,   -- Max moneda por tipo
    maxLevel = 100,            -- Max nivel de personaje
    maxAge = 30,               -- Max edad de personaje
    maxTrainingsPerDay = 50    -- Max entrenamientos por día
}

-- Configuración de detección de comportamiento sospechoso
local ANOMALY_THRESHOLDS = {
    rapidRequests = 10,        -- Más de 10 requests en 1 segundo
    impossibleProgression = 50, -- Más de 50 niveles en 1 hora
    suspiciousCurrency = 1000000, -- Ganancia de más de 1M monedas en 1 hora
    rapidCharacterAcquisition = 20 -- Más de 20 personajes nuevos en 1 hora
}

-- ======================== TRACKING DE JUGADORES ========================

local playerSecurity = {}

-- Estructura de datos de seguridad por jugador
local function initializePlayerSecurity(playerId)
    playerSecurity[playerId] = {
        requestHistory = {},
        rateLimits = {},
        anomalyFlags = {},
        lastRequestTime = {},
        sessionStats = {
            joinTime = os.time(),
            totalRequests = 0,
            flaggedRequests = 0,
            currencyGained = 0,
            charactersGained = 0,
            levelsGained = 0
        },
        violations = {},
        trustScore = 100,
        isUnderReview = false
    }
end

-- ======================== RATE LIMITING ========================

-- Verificar y actualizar límites de rate
function SecuritySystem.CheckRateLimit(playerId, action)
    local playerSec = playerSecurity[playerId]
    if not playerSec then
        initializePlayerSecurity(playerId)
        playerSec = playerSecurity[playerId]
    end
    
    local currentTime = os.time()
    local limit = RATE_LIMITS[action]
    if not limit then
        return true -- No hay límite definido para esta acción
    end
    
    -- Limpiar requests antiguos (más de 60 segundos)
    local requests = playerSec.rateLimits[action] or {}
    local filteredRequests = {}
    
    for _, timestamp in ipairs(requests) do
        if currentTime - timestamp < 60 then
            table.insert(filteredRequests, timestamp)
        end
    end
    
    -- Verificar si excede el límite
    if #filteredRequests >= limit then
        SecuritySystem.AddViolation(playerId, "RATE_LIMIT", {
            action = action,
            currentCount = #filteredRequests,
            limit = limit
        })
        return false
    end
    
    -- Agregar la nueva request
    table.insert(filteredRequests, currentTime)
    playerSec.rateLimits[action] = filteredRequests
    playerSec.sessionStats.totalRequests = playerSec.sessionStats.totalRequests + 1
    
    return true
end

-- ======================== VALIDACIÓN DE DATOS ========================

-- Validar datos de moneda
function SecuritySystem.ValidateCurrencyData(playerId, currencyChanges)
    local issues = {}
    
    for currencyType, amount in pairs(currencyChanges) do
        -- Verificar tipos válidos de moneda
        local validTypes = {"coins", "freeTickets", "premiumCurrency"}
        local isValid = false
        
        for _, validType in ipairs(validTypes) do
            if currencyType == validType then
                isValid = true
                break
            end
        end
        
        if not isValid then
            table.insert(issues, "Tipo de moneda inválido: " .. tostring(currencyType))
        end
        
        -- Verificar límites
        if type(amount) ~= "number" or amount < 0 then
            table.insert(issues, "Cantidad inválida para " .. currencyType .. ": " .. tostring(amount))
        end
        
        if amount > RESOURCE_LIMITS.maxCurrency then
            table.insert(issues, "Cantidad excede límite para " .. currencyType .. ": " .. tostring(amount))
        end
    end
    
    if #issues > 0 then
        SecuritySystem.AddViolation(playerId, "INVALID_CURRENCY", {
            issues = issues,
            data = currencyChanges
        })
        return false, issues
    end
    
    return true, {}
end

-- Validar datos de personaje
function SecuritySystem.ValidateCharacterData(character, playerId)
    local issues = {}
    
    -- Verificar campos requeridos
    local requiredFields = {"id", "name", "rarity", "level", "age", "ownerId"}
    for _, field in ipairs(requiredFields) do
        if not character[field] then
            table.insert(issues, "Campo faltante: " .. field)
        end
    end
    
    -- Verificar que el jugador sea el propietario
    if character.ownerId ~= tostring(playerId) then
        table.insert(issues, "Jugador no es propietario del personaje")
        SecuritySystem.AddViolation(playerId, "OWNERSHIP_VIOLATION", {
            characterId = character.id,
            actualOwner = character.ownerId,
            claimedOwner = tostring(playerId)
        })
    end
    
    -- Verificar límites de stats
    if character.level and (character.level < 1 or character.level > RESOURCE_LIMITS.maxLevel) then
        table.insert(issues, "Nivel inválido: " .. tostring(character.level))
    end
    
    if character.age and (character.age < 16 or character.age > RESOURCE_LIMITS.maxAge) then
        table.insert(issues, "Edad inválida: " .. tostring(character.age))
    end
    
    if character.rarity and (character.rarity < 1 or character.rarity > 6) then
        table.insert(issues, "Rareza inválida: " .. tostring(character.rarity))
    end
    
    -- Verificar estadísticas razonables
    if character.stats then
        for statName, value in pairs(character.stats) do
            if type(value) ~= "number" or value < 1 or value > 9999 then
                table.insert(issues, "Estadística inválida " .. statName .. ": " .. tostring(value))
            end
        end
    end
    
    if #issues > 0 then
        SecuritySystem.AddViolation(playerId, "INVALID_CHARACTER", {
            issues = issues,
            characterId = character.id
        })
        return false, issues
    end
    
    return true, {}
end

-- ======================== DETECCIÓN DE ANOMALÍAS ========================

-- Detectar requests sospechosamente rápidas
function SecuritySystem.DetectRapidRequests(playerId)
    local playerSec = playerSecurity[playerId]
    if not playerSec then return false end
    
    local currentTime = os.time()
    local recentRequests = 0
    
    -- Contar requests en el último segundo
    for action, timestamps in pairs(playerSec.rateLimits) do
        for _, timestamp in ipairs(timestamps) do
            if currentTime - timestamp < 1 then
                recentRequests = recentRequests + 1
            end
        end
    end
    
    if recentRequests > ANOMALY_THRESHOLDS.rapidRequests then
        SecuritySystem.AddViolation(playerId, "RAPID_REQUESTS", {
            requestsPerSecond = recentRequests,
            threshold = ANOMALY_THRESHOLDS.rapidRequests
        })
        return true
    end
    
    return false
end

-- Detectar progresión imposible
function SecuritySystem.DetectImpossibleProgression(playerId, levelGain)
    local playerSec = playerSecurity[playerId]
    if not playerSec then return false end
    
    playerSec.sessionStats.levelsGained = playerSec.sessionStats.levelsGained + levelGain
    
    local sessionDuration = os.time() - playerSec.sessionStats.joinTime
    local hourlyRate = (playerSec.sessionStats.levelsGained / math.max(sessionDuration, 1)) * 3600
    
    if hourlyRate > ANOMALY_THRESHOLDS.impossibleProgression then
        SecuritySystem.AddViolation(playerId, "IMPOSSIBLE_PROGRESSION", {
            levelsPerHour = hourlyRate,
            threshold = ANOMALY_THRESHOLDS.impossibleProgression,
            totalGain = playerSec.sessionStats.levelsGained
        })
        return true
    end
    
    return false
end

-- ======================== SISTEMA DE VIOLACIONES ========================

-- Agregar violación de seguridad
function SecuritySystem.AddViolation(playerId, violationType, data)
    local playerSec = playerSecurity[playerId]
    if not playerSec then
        initializePlayerSecurity(playerId)
        playerSec = playerSecurity[playerId]
    end
    
    local violation = {
        type = violationType,
        timestamp = os.time(),
        data = data,
        severity = SecuritySystem.GetViolationSeverity(violationType)
    }
    
    table.insert(playerSec.violations, violation)
    playerSec.sessionStats.flaggedRequests = playerSec.sessionStats.flaggedRequests + 1
    
    -- Reducir trust score
    playerSec.trustScore = math.max(0, playerSec.trustScore - violation.severity)
    
    -- Log de la violación
    local player = Players:GetPlayerByUserId(playerId)
    local playerName = player and player.Name or "Unknown"
    
    warn(string.format(
        "[SECURITY] Violación %s detectada para %s (%d): %s",
        violationType,
        playerName,
        playerId,
        tostring(data)
    ))
    
    -- Acciones automáticas basadas en severidad
    if violation.severity >= 50 then
        SecuritySystem.FlagPlayerForReview(playerId, violationType)
    end
    
    if playerSec.trustScore <= 20 then
        SecuritySystem.RestrictPlayer(playerId, "LOW_TRUST")
    end
end

-- Obtener severidad de la violación
function SecuritySystem.GetViolationSeverity(violationType)
    local severities = {
        RATE_LIMIT = 5,
        INVALID_CURRENCY = 30,
        INVALID_CHARACTER = 25,
        OWNERSHIP_VIOLATION = 50,
        RAPID_REQUESTS = 15,
        IMPOSSIBLE_PROGRESSION = 40,
        EXPLOIT_ATTEMPT = 75
    }
    
    return severities[violationType] or 10
end

-- Marcar jugador para revisión
function SecuritySystem.FlagPlayerForReview(playerId, reason)
    local playerSec = playerSecurity[playerId]
    if not playerSec then return end
    
    playerSec.isUnderReview = true
    
    local player = Players:GetPlayerByUserId(playerId)
    if player then
        warn(string.format("[SECURITY] Jugador %s (%d) marcado para revisión: %s", 
            player.Name, playerId, reason))
    end
end

-- ======================== FUNCIONES PÚBLICAS ========================

-- Verificar si un jugador está autorizado para realizar una acción
function SecuritySystem.IsPlayerAuthorized(playerId, action, additionalData)
    -- Verificar rate limiting
    if not SecuritySystem.CheckRateLimit(playerId, action) then
        return false, "Rate limit excedido"
    end
    
    -- Detectar requests rápidas sospechosas
    if SecuritySystem.DetectRapidRequests(playerId) then
        return false, "Comportamiento sospechoso detectado"
    end
    
    -- Verificar trust score
    local playerSec = playerSecurity[playerId]
    if playerSec and playerSec.trustScore <= 10 then
        return false, "Trust score demasiado bajo"
    end
    
    -- Verificar si está bajo revisión
    if playerSec and playerSec.isUnderReview then
        return false, "Cuenta bajo revisión"
    end
    
    return true
end

-- Obtener estadísticas de seguridad de un jugador
function SecuritySystem.GetPlayerSecurityStats(playerId)
    local playerSec = playerSecurity[playerId]
    if not playerSec then
        return nil
    end
    
    return {
        trustScore = playerSec.trustScore,
        totalViolations = #playerSec.violations,
        isUnderReview = playerSec.isUnderReview,
        sessionStats = playerSec.sessionStats,
        recentViolations = SecuritySystem.GetRecentViolations(playerId, 300) -- Últimos 5 minutos
    }
end

-- Obtener violaciones recientes
function SecuritySystem.GetRecentViolations(playerId, timeWindow)
    local playerSec = playerSecurity[playerId]
    if not playerSec then return {} end
    
    local currentTime = os.time()
    local recentViolations = {}
    
    for _, violation in ipairs(playerSec.violations) do
        if currentTime - violation.timestamp < timeWindow then
            table.insert(recentViolations, violation)
        end
    end
    
    return recentViolations
end

-- Limpiar datos de jugadores desconectados
function SecuritySystem.CleanupDisconnectedPlayers()
    for playerId, _ in pairs(playerSecurity) do
        local player = Players:GetPlayerByUserId(tonumber(playerId))
        if not player then
            playerSecurity[playerId] = nil
        end
    end
end

-- ======================== EVENTOS ========================

-- Inicializar seguridad cuando un jugador se conecta
Players.PlayerAdded:Connect(function(player)
    initializePlayerSecurity(player.UserId)
    print("[SECURITY] Inicializado seguimiento para jugador:", player.Name)
end)

-- Limpiar datos cuando un jugador se desconecta
Players.PlayerRemoving:Connect(function(player)
    local playerSec = playerSecurity[player.UserId]
    if playerSec then
        -- Log estadísticas finales de la sesión
        local sessionDuration = os.time() - playerSec.sessionStats.joinTime
        print(string.format(
            "[SECURITY] Sesión finalizada para %s: %d requests, %d violaciones, trust: %d, duración: %ds",
            player.Name,
            playerSec.sessionStats.totalRequests,
            #playerSec.violations,
            playerSec.trustScore,
            sessionDuration
        ))
        
        playerSecurity[player.UserId] = nil
    end
end)

-- Limpieza periódica
spawn(function()
    while true do
        wait(300) -- 5 minutos
        SecuritySystem.CleanupDisconnectedPlayers()
    end
end)

print("✅ SecuritySystem cargado con protección contra exploits y rate limiting")

return SecuritySystem