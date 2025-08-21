-- ServerMain.lua
-- Script principal del servidor que inicializa todos los sistemas

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Requerir todos los módulos del sistema
local CharacterGenerator = require(script.Parent.CharacterSystem.CharacterGenerator)
local CharacterDatabase = require(script.Parent.CharacterSystem.CharacterDatabase)
local CharacterAging = require(script.Parent.CharacterSystem.CharacterAging)
local GachaCore = require(script.Parent.GachaSystem.GachaCore)
local TicketManager = require(script.Parent.GachaSystem.TicketManager)
local BattleManager = require(script.Parent.CombatSystem.BattleManager)
local TrainingSystem = require(script.Parent.CombatSystem.TrainingSystem)
local PurchaseHandler = require(script.Parent.MonetizationSystem.PurchaseHandler)
local SkinManager = require(script.Parent.MonetizationSystem.SkinManager)
local SecuritySystem = require(script.Parent.SecuritySystem)

-- Obtener eventos remotos
local eventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")

-- === EVENTOS DE GACHA ===
local pullGacha = eventsFolder:WaitForChild("PullGacha")
local getPlayerCurrency = eventsFolder:WaitForChild("GetPlayerCurrency")
local getGachaRates = eventsFolder:WaitForChild("GetGachaRates")
local buyTickets = eventsFolder:WaitForChild("BuyTickets")

-- === EVENTOS DE PERSONAJES ===
local getPlayerCharacters = eventsFolder:WaitForChild("GetPlayerCharacters")
local trainCharacter = eventsFolder:WaitForChild("TrainCharacter")
local releaseCharacter = eventsFolder:WaitForChild("ReleaseCharacter")
local breedCharacters = eventsFolder:WaitForChild("BreedCharacters")
local getCharacterDetails = eventsFolder:WaitForChild("GetCharacterDetails")

-- === EVENTOS DE COMBATE ===
local startBattle = eventsFolder:WaitForChild("StartBattle")
local getBattleHistory = eventsFolder:WaitForChild("GetBattleHistory")
local getArenaOpponents = eventsFolder:WaitForChild("GetArenaOpponents")
local setDefenseTeam = eventsFolder:WaitForChild("SetDefenseTeam")

-- === EVENTOS DE NOTIFICACIÓN ===
local currencyUpdated = eventsFolder:WaitForChild("CurrencyUpdated")
local gachaPullResult = eventsFolder:WaitForChild("GachaPullResult")
local characterUpdated = eventsFolder:WaitForChild("CharacterUpdated")

print("🎮 Iniciando Waifu & Husbando Collection Game...")

-- === HANDLERS DE GACHA ===
pullGacha.OnServerInvoke = function(player, ticketType, count)
    local playerId = player.UserId
    
    -- Validación de seguridad
    local authorized, reason = SecuritySystem.IsPlayerAuthorized(playerId, "PullGacha", {
        ticketType = ticketType,
        count = count
    })
    
    if not authorized then
        warn("PullGacha bloqueado para " .. player.Name .. ": " .. reason)
        return nil, "Acción no autorizada: " .. reason
    end
    
    -- Validar parámetros de entrada
    if not ticketType or type(ticketType) ~= "string" then
        SecuritySystem.AddViolation(playerId, "INVALID_PARAMETER", {action = "PullGacha", param = "ticketType"})
        return nil, "Tipo de ticket inválido"
    end
    
    if count and (type(count) ~= "number" or count < 1 or count > 10) then
        SecuritySystem.AddViolation(playerId, "INVALID_PARAMETER", {action = "PullGacha", param = "count"})
        return nil, "Cantidad inválida"
    end
    
    if count and count > 1 then
        -- Multi-pull
        local results, error = GachaCore.PerformMultiPull(playerId, ticketType, count)
        if results then
            -- Notificar resultados uno por uno
            for _, result in ipairs(results) do
                gachaPullResult:FireClient(player, result)
                wait(0.5) -- Pausa entre resultados
            end
            
            -- Actualizar moneda
            local newCurrency = CharacterDatabase.LoadPlayerData(playerId).currency
            currencyUpdated:FireClient(player, newCurrency)
            
            return results
        else
            return nil, error
        end
    else
        -- Single pull
        local result, error = GachaCore.PerformSinglePull(playerId, ticketType)
        if result then
            gachaPullResult:FireClient(player, result)
            
            -- Actualizar moneda
            local newCurrency = CharacterDatabase.LoadPlayerData(playerId).currency
            currencyUpdated:FireClient(player, newCurrency)
            
            return result
        else
            return nil, error
        end
    end
end

getPlayerCurrency.OnServerInvoke = function(player)
    local playerId = player.UserId
    
    -- Validación de seguridad
    local authorized, reason = SecuritySystem.IsPlayerAuthorized(playerId, "GetPlayerCurrency")
    if not authorized then
        return {freeTickets = 0, premiumCurrency = 0, coins = 0}
    end
    
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    return playerData and playerData.currency or {freeTickets = 0, premiumCurrency = 0, coins = 0}
end

getGachaRates.OnServerInvoke = function(player)
    return GachaCore.GetAdjustedProbabilities(player.UserId)
end

buyTickets.OnServerInvoke = function(player, ticketType, quantity)
    local playerId = player.UserId
    
    -- Validación de seguridad
    local authorized, reason = SecuritySystem.IsPlayerAuthorized(playerId, "BuyTickets", {
        ticketType = ticketType,
        quantity = quantity
    })
    
    if not authorized then
        warn("BuyTickets bloqueado para " .. player.Name .. ": " .. reason)
        return false, "Acción no autorizada: " .. reason
    end
    
    -- Validar parámetros
    if not ticketType or (ticketType ~= "FREE" and ticketType ~= "PREMIUM") then
        SecuritySystem.AddViolation(playerId, "INVALID_PARAMETER", {action = "BuyTickets", param = "ticketType"})
        return false, "Tipo de ticket inválido"
    end
    
    if not quantity or type(quantity) ~= "number" or quantity < 1 or quantity > 1000 then
        SecuritySystem.AddViolation(playerId, "INVALID_PARAMETER", {action = "BuyTickets", param = "quantity"})
        return false, "Cantidad inválida"
    end
    
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    if not playerData then
        return false, "Datos del jugador no encontrados"
    end
    
    -- Calcular costo
    local costPerTicket = ticketType == "FREE" and 100 or 50 -- 100 monedas por ticket gratis, 50 por premium
    local totalCost = costPerTicket * quantity
    
    -- Verificar si tiene suficientes monedas
    if playerData.currency.coins < totalCost then
        return false, "Monedas insuficientes"
    end
    
    -- Realizar la compra
    local success = CharacterDatabase.UpdatePlayerCurrency(playerId, {
        coins = -totalCost,
        freeTickets = ticketType == "FREE" and quantity or 0,
        premiumTickets = ticketType == "PREMIUM" and quantity or 0
    })
    
    if success then
        -- Actualizar moneda en el cliente
        local newCurrency = CharacterDatabase.LoadPlayerData(playerId).currency
        currencyUpdated:FireClient(player, newCurrency)
        
        return true, nil
    else
        return false, "Error al procesar la compra"
    end
end

-- === HANDLERS DE PERSONAJES ===
getPlayerCharacters.OnServerInvoke = function(player)
    local playerId = player.UserId
    
    -- Validación de seguridad
    local authorized, reason = SecuritySystem.IsPlayerAuthorized(playerId, "GetPlayerCharacters")
    if not authorized then
        warn("GetPlayerCharacters bloqueado para " .. player.Name .. ": " .. reason)
        return {}
    end
    
    return CharacterDatabase.GetPlayerCharacters(playerId)
end

trainCharacter.OnServerInvoke = function(player, characterId, trainingType)
    local playerId = player.UserId
    
    -- Validación de seguridad
    local authorized, reason = SecuritySystem.IsPlayerAuthorized(playerId, "TrainCharacter")
    if not authorized then
        return false, "Acción no autorizada: " .. reason
    end
    
    -- Validar parámetros
    if not characterId or type(characterId) ~= "string" then
        SecuritySystem.AddViolation(playerId, "INVALID_PARAMETER", {action = "TrainCharacter", param = "characterId"})
        return false, "ID de personaje inválido"
    end
    
    if not trainingType or type(trainingType) ~= "string" then
        SecuritySystem.AddViolation(playerId, "INVALID_PARAMETER", {action = "TrainCharacter", param = "trainingType"})
        return false, "Tipo de entrenamiento inválido"
    end
    
    -- Verificar que el personaje pertenece al jugador
    local character = CharacterDatabase.LoadCharacter(characterId)
    if not character or character.ownerId ~= tostring(playerId) then
        SecuritySystem.AddViolation(playerId, "OWNERSHIP_VIOLATION", {
            action = "TrainCharacter",
            characterId = characterId
        })
        return false, "No tienes permiso para entrenar este personaje"
    end
    
    -- Verificar si ya está completando entrenamiento
    local status = TrainingSystem.GetTrainingStatus(characterId)
    if status and status.completed then
        return TrainingSystem.CompleteTraining(characterId, playerId)
    else
        return TrainingSystem.StartTraining(characterId, playerId, trainingType)
    end
end

releaseCharacter.OnServerInvoke = function(player, characterId)
    if not characterId then
        return false, "ID de personaje requerido"
    end
    
    local success, error = CharacterDatabase.RemoveCharacterFromPlayer(player.UserId, characterId)
    if success then
        -- Dar algunas monedas como compensación
        CharacterDatabase.UpdatePlayerCurrency(player.UserId, {coins = 50})
        
        local newCurrency = CharacterDatabase.LoadPlayerData(player.UserId).currency
        currencyUpdated:FireClient(player, newCurrency)
    end
    
    return success, error
end

breedCharacters.OnServerInvoke = function(player, parent1Id, parent2Id)
    if not parent1Id or not parent2Id then
        return false, "Se necesitan dos personajes padre"
    end
    
    local parent1 = CharacterDatabase.LoadCharacter(parent1Id)
    local parent2 = CharacterDatabase.LoadCharacter(parent2Id)
    
    if not parent1 or not parent2 then
        return false, "Personajes no encontrados"
    end
    
    -- Verificar que el jugador tiene un pase de cría
    local playerData = CharacterDatabase.LoadPlayerData(player.UserId)
    if playerData.inventory.breedingPasses <= 0 then
        return false, "No tienes pases de cría"
    end
    
    -- Verificar espacio en inventario
    if #playerData.characters >= playerData.inventory.maxCharacterSlots then
        return false, "Inventario lleno"
    end
    
    local child, error = CharacterGenerator.BreedCharacters(parent1, parent2, player.UserId)
    if child then
        -- Consumir pase de cría
        playerData.inventory.breedingPasses = playerData.inventory.breedingPasses - 1
        CharacterDatabase.SavePlayerData(player.UserId, playerData)
        
        -- Agregar hijo al jugador
        local success, addError = CharacterDatabase.AddCharacterToPlayer(player.UserId, child)
        if success then
            return child, nil
        else
            return false, addError
        end
    else
        return false, error
    end
end

getCharacterDetails.OnServerInvoke = function(player, characterId)
    local character = CharacterDatabase.LoadCharacter(characterId)
    if not character or character.ownerId ~= tostring(player.UserId) then
        return nil
    end
    
    -- Agregar información adicional
    local details = {
        character = character,
        trainingStatus = TrainingSystem.GetTrainingStatus(characterId),
        agingInfo = CharacterAging.GetAgingInfo(character),
        combatPower = require(ReplicatedStorage.SharedModules.Utilities).CalculateCombatPower(character),
        equippedSkins = SkinManager.GetCharacterVisualEffects(character)
    }
    
    return details
end

-- === HANDLERS DE COMBATE ===
startBattle.OnServerInvoke = function(player, playerTeam, difficultyLevel)
    if not playerTeam or #playerTeam == 0 then
        return false, "Equipo vacío"
    end
    
    difficultyLevel = difficultyLevel or 0
    
    return BattleManager.StartPvEBattle(player.UserId, playerTeam, difficultyLevel)
end

getBattleHistory.OnServerInvoke = function(player)
    local playerData = CharacterDatabase.LoadPlayerData(player.UserId)
    return playerData.battleHistory or {}
end

getArenaOpponents.OnServerInvoke = function(player, count)
    count = count or 5
    local playerData = CharacterDatabase.LoadPlayerData(player.UserId)
    
    -- Calcular nivel promedio del jugador
    local avgLevel = 1
    if #playerData.characters > 0 then
        local totalLevel = 0
        for _, characterId in ipairs(playerData.characters) do
            local character = CharacterDatabase.LoadCharacter(characterId)
            if character then
                totalLevel = totalLevel + character.level
            end
        end
        avgLevel = math.floor(totalLevel / #playerData.characters)
    end
    
    return BattleManager.GenerateAIOpponents(avgLevel, count)
end

setDefenseTeam.OnServerInvoke = function(player, teamCharacterIds)
    local playerId = player.UserId
    
    -- Validación de seguridad
    local authorized, reason = SecuritySystem.IsPlayerAuthorized(playerId, "SetDefenseTeam")
    if not authorized then
        warn("SetDefenseTeam bloqueado para " .. player.Name .. ": " .. reason)
        return false, "Acción no autorizada: " .. reason
    end
    
    -- Validar parámetros
    if not teamCharacterIds or type(teamCharacterIds) ~= "table" then
        SecuritySystem.AddViolation(playerId, "INVALID_PARAMETER", {action = "SetDefenseTeam", param = "teamCharacterIds"})
        return false, "Lista de personajes inválida"
    end
    
    if #teamCharacterIds > 5 then
        SecuritySystem.AddViolation(playerId, "INVALID_PARAMETER", {action = "SetDefenseTeam", param = "teamSize"})
        return false, "El equipo no puede tener más de 5 personajes"
    end
    
    -- Verificar que todos los personajes pertenecen al jugador
    local validCharacters = {}
    for _, characterId in ipairs(teamCharacterIds) do
        if type(characterId) ~= "string" then
            SecuritySystem.AddViolation(playerId, "INVALID_PARAMETER", {action = "SetDefenseTeam", param = "characterId"})
            return false, "ID de personaje inválido"
        end
        
        local character = CharacterDatabase.LoadCharacter(characterId)
        if not character or character.ownerId ~= tostring(playerId) then
            SecuritySystem.AddViolation(playerId, "OWNERSHIP_VIOLATION", {
                action = "SetDefenseTeam",
                characterId = characterId
            })
            return false, "Uno o más personajes no te pertenecen"
        end
        
        table.insert(validCharacters, character)
    end
    
    -- Guardar equipo de defensa
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    if not playerData then
        return false, "Datos del jugador no encontrados"
    end
    
    playerData.defenseTeam = teamCharacterIds
    local success = CharacterDatabase.SavePlayerData(playerId, playerData)
    
    if success then
        print("✅ Equipo de defensa actualizado para " .. player.Name .. " con " .. #teamCharacterIds .. " personajes")
        return true, nil
    else
        return false, "Error al guardar el equipo de defensa"
    end
end

-- === EVENTOS DE CONEXIÓN DE JUGADORES ===
Players.PlayerAdded:Connect(function(player)
    print("👤 Jugador conectado: " .. player.Name)
    
    -- Inicializar datos del jugador si es nuevo
    local playerData = CharacterDatabase.LoadPlayerData(player.UserId)
    
    -- Dar personaje inicial gratuito si es nuevo jugador
    if #playerData.characters == 0 then
        print("🎁 Nuevo jugador detectado, dando personaje inicial...")
        
        local starterCharacter = CharacterGenerator.GenerateCharacter(2, player.UserId) -- Rareza UNCOMMON
        local success, error = CharacterDatabase.AddCharacterToPlayer(player.UserId, starterCharacter)
        
        if success then
            print("✅ Personaje inicial otorgado: " .. starterCharacter.name)
        else
            warn("❌ Error otorgando personaje inicial: " .. tostring(error))
        end
    end
    
    -- Verificar recompensas diarias
    spawn(function()
        wait(3) -- Esperar a que el cliente se inicialice
        TicketManager.AddHourlyTickets(player.UserId)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    print("👋 Jugador desconectado: " .. player.Name)
    -- Los datos se guardan automáticamente en CharacterDatabase
end)

-- === SISTEMA DE MANTENIMIENTO ===
spawn(function()
    while true do
        wait(1800) -- 30 minutos
        
        print("🔧 Ejecutando mantenimiento del servidor...")
        
        -- Limpiar cache
        CharacterDatabase.ClearCache()
        
        -- Verificar entrenamientos completados
        for _, player in ipairs(Players:GetPlayers()) do
            local characters = CharacterDatabase.GetPlayerCharacters(player.UserId)
            for _, character in ipairs(characters) do
                local status = TrainingSystem.GetTrainingStatus(character.id)
                if status and status.completed then
                    -- Notificar que el entrenamiento está listo
                    -- (puedes agregar un evento remoto para esto)
                end
            end
        end
        
        print("✅ Mantenimiento completado")
    end
end)

-- === COMANDOS DE ADMINISTRADOR ===
game.Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(message)
        if player.Name == "TuNombreDeAdmin" then -- Cambiar por tu nombre
            local args = string.split(message, " ")
            local command = args[1]:lower()
            
            if command == "/givecurrency" and args[2] and args[3] then
                local targetPlayer = Players:FindFirstChild(args[2])
                local amount = tonumber(args[3])
                
                if targetPlayer and amount then
                    CharacterDatabase.UpdatePlayerCurrency(targetPlayer.UserId, {
                        premiumCurrency = amount,
                        freeTickets = amount,
                        coins = amount * 10
                    })
                    
                    local newCurrency = CharacterDatabase.LoadPlayerData(targetPlayer.UserId).currency
                    currencyUpdated:FireClient(targetPlayer, newCurrency)
                    
                    print("💰 Moneda otorgada a " .. targetPlayer.Name)
                end
            elseif command == "/givecharacter" and args[2] and args[3] then
                local targetPlayer = Players:FindFirstChild(args[2])
                local rarity = tonumber(args[3])
                
                if targetPlayer and rarity and rarity >= 1 and rarity <= 6 then
                    local character = CharacterGenerator.GenerateCharacter(rarity, targetPlayer.UserId)
                    CharacterDatabase.AddCharacterToPlayer(targetPlayer.UserId, character)
                    
                    print("👥 Personaje rareza " .. rarity .. " otorgado a " .. targetPlayer.Name)
                end
            end
        end
    end)
end)

print("🚀 Waifu & Husbando Collection Game iniciado correctamente!")
print("📊 Sistemas activos:")
print("  - ✅ Generación de personajes")
print("  - ✅ Sistema Gacha")
print("  - ✅ Combate automático")
print("  - ✅ Entrenamiento")
print("  - ✅ Envejecimiento")
print("  - ✅ Monetización")
print("  - ✅ Base de datos")
print("💡 ¡Listo para jugar!")