-- GachaCore.lua
-- Sistema principal de Gacha con probabilidades y pity system

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CharacterTypes = require(ReplicatedStorage.SharedModules.CharacterTypes)
local GameConfig = require(ReplicatedStorage.SharedModules.GameConfig)
local Utilities = require(ReplicatedStorage.SharedModules.Utilities)
local CharacterGenerator = require(script.Parent.Parent.CharacterSystem.CharacterGenerator)
local CharacterDatabase = require(script.Parent.Parent.CharacterSystem.CharacterDatabase)

local GachaCore = {}

-- Pity system: después de X pulls sin rareza alta, garantizar una
local PITY_THRESHOLDS = {
    [CharacterTypes.Rarity.RARE] = 15,     -- Garantizar RARE cada 15 pulls
    [CharacterTypes.Rarity.EPIC] = 50,     -- Garantizar EPIC cada 50 pulls  
    [CharacterTypes.Rarity.LEGENDARY] = 100, -- Garantizar LEGENDARY cada 100 pulls
    [CharacterTypes.Rarity.MYTHIC] = 500   -- Garantizar MYTHIC cada 500 pulls
}

-- Eventos remotos
local eventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local GachaPullResult = eventsFolder:WaitForChild("GachaPullResult")
local CurrencyUpdated = eventsFolder:WaitForChild("CurrencyUpdated")

-- Obtener probabilidades ajustadas por pity system
function GachaCore.GetAdjustedProbabilities(playerId)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    local baseProbabilities = Utilities.DeepCopy(GameConfig.GachaProbabilities)
    
    -- Verificar pity counters
    local pityCounters = playerData.pityCounters or {}
    
    -- Ajustar probabilidades basado en pity
    for rarity, threshold in pairs(PITY_THRESHOLDS) do
        local counter = pityCounters[rarity] or 0
        
        if counter >= threshold then
            -- Garantizar esta rareza
            for r = 1, 6 do
                baseProbabilities[r] = 0
            end
            baseProbabilities[rarity] = 1.0
            break
        elseif counter >= threshold * 0.8 then
            -- Aumentar probabilidades cerca del pity
            local boost = (counter - threshold * 0.8) / (threshold * 0.2)
            baseProbabilities[rarity] = baseProbabilities[rarity] + (boost * 0.1)
        end
    end
    
    -- Normalizar probabilidades para que sumen 1.0
    local total = 0
    for _, prob in pairs(baseProbabilities) do
        total = total + prob
    end
    
    for rarity, prob in pairs(baseProbabilities) do
        baseProbabilities[rarity] = prob / total
    end
    
    return baseProbabilities
end

-- Actualizar contadores de pity
function GachaCore.UpdatePityCounters(playerId, pulledRarity)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    
    if not playerData.pityCounters then
        playerData.pityCounters = {}
    end
    
    -- Incrementar todos los contadores
    for rarity, _ in pairs(PITY_THRESHOLDS) do
        playerData.pityCounters[rarity] = (playerData.pityCounters[rarity] or 0) + 1
    end
    
    -- Resetear contadores para rarezas obtenidas y superiores
    for rarity = pulledRarity, CharacterTypes.Rarity.MYTHIC do
        if PITY_THRESHOLDS[rarity] then
            playerData.pityCounters[rarity] = 0
        end
    end
    
    CharacterDatabase.SavePlayerData(playerId, playerData)
end

-- Realizar un pull individual
function GachaCore.PerformSinglePull(playerId, ticketType)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    if not playerData then
        return nil, "Error cargando datos del jugador"
    end
    
    -- Verificar costo y moneda
    local cost = GameConfig.Prices.GachaPull[ticketType] or 0
    
    if ticketType == CharacterTypes.TicketType.FREE then
        if playerData.currency.freeTickets <= 0 then
            return nil, "No tienes tickets gratuitos"
        end
    elseif ticketType == CharacterTypes.TicketType.PREMIUM then
        if playerData.currency.premiumCurrency < cost then
            return nil, "No tienes suficiente moneda premium"
        end
    end
    
    -- Verificar espacio en inventario
    if #playerData.characters >= playerData.inventory.maxCharacterSlots then
        return nil, "Inventario lleno"
    end
    
    -- Obtener rareza con probabilidades ajustadas
    local adjustedProbs = GachaCore.GetAdjustedProbabilities(playerId)
    local rarity = Utilities.GetRarityFromProbabilities(adjustedProbs)
    
    -- Generar personaje
    local character = CharacterGenerator.GenerateCharacter(rarity, playerId)
    if not character then
        return nil, "Error generando personaje"
    end
    
    -- Verificar si es un personaje nuevo para el jugador
    local isNew = true
    local existingCharacters = CharacterDatabase.GetPlayerCharacters(playerId)
    for _, existingChar in ipairs(existingCharacters) do
        if existingChar.name == character.name and existingChar.series == character.series then
            isNew = false
            break
        end
    end
    
    -- Agregar personaje al jugador
    local success, error = CharacterDatabase.AddCharacterToPlayer(playerId, character)
    if not success then
        return nil, error
    end
    
    -- Deducir costo
    local currencyChanges = {}
    if ticketType == CharacterTypes.TicketType.FREE then
        currencyChanges.freeTickets = -1
    elseif ticketType == CharacterTypes.TicketType.PREMIUM then
        currencyChanges.premiumCurrency = -cost
    end
    
    CharacterDatabase.UpdatePlayerCurrency(playerId, currencyChanges)
    
    -- Actualizar estadísticas
    CharacterDatabase.UpdatePlayerStats(playerId, {
        totalPulls = 1
    })
    
    if rarity >= CharacterTypes.Rarity.EPIC then
        CharacterDatabase.UpdateGlobalStats({
            rareCharacters = 1
        })
    end
    
    -- Actualizar pity counters
    GachaCore.UpdatePityCounters(playerId, rarity)
    
    -- Crear resultado
    local result = {
        character = character,
        isNew = isNew,
        rarityPull = rarity,
        ticketType = ticketType,
        cost = cost,
        timestamp = os.time()
    }
    
    return result, nil
end

-- Realizar múltiples pulls (10+1 gratis, etc.)
function GachaCore.PerformMultiPull(playerId, ticketType, count)
    local results = {}
    local errors = {}
    
    count = count or 10
    
    -- Verificar que el jugador pueda hacer todos los pulls
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    local totalCost = (GameConfig.Prices.GachaPull[ticketType] or 0) * count
    
    if ticketType == CharacterTypes.TicketType.FREE then
        if playerData.currency.freeTickets < count then
            return nil, "No tienes suficientes tickets gratuitos"
        end
    elseif ticketType == CharacterTypes.TicketType.PREMIUM then
        if playerData.currency.premiumCurrency < totalCost then
            return nil, "No tienes suficiente moneda premium"
        end
    end
    
    -- Verificar espacio en inventario
    if (#playerData.characters + count) > playerData.inventory.maxCharacterSlots then
        return nil, "No tienes suficiente espacio en el inventario"
    end
    
    -- Realizar pulls individuales
    for i = 1, count do
        local result, error = GachaCore.PerformSinglePull(playerId, ticketType)
        
        if result then
            table.insert(results, result)
        else
            table.insert(errors, error)
            break -- Parar si hay error
        end
        
        wait(0.1) -- Pequeña pausa para evitar problemas de DataStore
    end
    
    -- Bonus pull gratuito para multi-pulls premium
    if ticketType == CharacterTypes.TicketType.PREMIUM and count >= 10 and #errors == 0 then
        local bonusResult, bonusError = GachaCore.PerformSinglePull(playerId, CharacterTypes.TicketType.FREE)
        if bonusResult then
            bonusResult.isBonus = true
            table.insert(results, bonusResult)
        end
    end
    
    -- Garantizar al menos un RARE en multi-pull de 10
    if count >= 10 and #results >= 10 then
        local hasRare = false
        for _, result in ipairs(results) do
            if result.character.rarity >= CharacterTypes.Rarity.RARE then
                hasRare = true
                break
            end
        end
        
        -- Si no hay RARE, convertir el último pull en RARE
        if not hasRare and #results >= 10 then
            local lastResult = results[10]
            local newCharacter = CharacterGenerator.GenerateCharacter(CharacterTypes.Rarity.RARE, playerId)
            
            -- Reemplazar el personaje anterior
            CharacterDatabase.RemoveCharacterFromPlayer(playerId, lastResult.character.id)
            CharacterDatabase.AddCharacterToPlayer(playerId, newCharacter)
            
            lastResult.character = newCharacter
            lastResult.rarityPull = CharacterTypes.Rarity.RARE
            lastResult.isGuaranteed = true
        end
    end
    
    if #errors > 0 then
        return nil, errors[1]
    end
    
    return results, nil
end

-- Obtener información de pity para un jugador
function GachaCore.GetPityInfo(playerId)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    local pityCounters = playerData.pityCounters or {}
    
    local pityInfo = {}
    for rarity, threshold in pairs(PITY_THRESHOLDS) do
        local counter = pityCounters[rarity] or 0
        pityInfo[rarity] = {
            current = counter,
            threshold = threshold,
            remaining = threshold - counter,
            progress = counter / threshold
        }
    end
    
    return pityInfo
end

-- Simular pulls para mostrar probabilidades (no consume recursos)
function GachaCore.SimulatePulls(playerId, count)
    local results = {}
    local adjustedProbs = GachaCore.GetAdjustedProbabilities(playerId)
    
    for i = 1, count do
        local rarity = Utilities.GetRarityFromProbabilities(adjustedProbs)
        table.insert(results, rarity)
    end
    
    return results
end

return GachaCore