-- TicketManager.lua
-- Gestión de tickets gratuitos, recompensas diarias y eventos

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CharacterTypes = require(ReplicatedStorage.SharedModules.CharacterTypes)
local GameConfig = require(ReplicatedStorage.SharedModules.GameConfig)
local CharacterDatabase = require(script.Parent.Parent.CharacterSystem.CharacterDatabase)

local TicketManager = {}

-- Eventos
local eventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local CurrencyUpdated = eventsFolder:WaitForChild("CurrencyUpdated")
local DailyRewardClaimed = eventsFolder:WaitForChild("DailyRewardClaimed")

-- Verificar si el jugador puede reclamar recompensas diarias
function TicketManager.CanClaimDailyReward(playerId)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    if not playerData then return false end
    
    local lastClaim = playerData.lastDailyReward or 0
    local currentTime = os.time()
    local dayInSeconds = 24 * 60 * 60
    
    return (currentTime - lastClaim) >= dayInSeconds
end

-- Obtener día consecutivo de login
function TicketManager.GetLoginStreak(playerId)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    if not playerData then return 1 end
    
    local lastLogin = playerData.lastLogin or 0
    local currentTime = os.time()
    local dayInSeconds = 24 * 60 * 60
    
    local daysSinceLastLogin = math.floor((currentTime - lastLogin) / dayInSeconds)
    
    if daysSinceLastLogin <= 1 then
        -- Login consecutivo
        return (playerData.loginStreak or 0) + 1
    else
        -- Se rompió la racha
        return 1
    end
end

-- Reclamar recompensa diaria
function TicketManager.ClaimDailyReward(playerId)
    if not TicketManager.CanClaimDailyReward(playerId) then
        return false, "Ya reclamaste la recompensa diaria"
    end
    
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    local loginStreak = TicketManager.GetLoginStreak(playerId)
    
    -- Obtener recompensa basada en el día de la racha
    local dayKey = "Day" .. math.min(loginStreak, 7)
    local reward = GameConfig.FreeCurrency.LoginBonus[dayKey] or GameConfig.FreeCurrency.LoginBonus.Day1
    
    -- Aplicar recompensas
    local currencyChanges = {}
    if reward.freeTickets then
        currencyChanges.freeTickets = reward.freeTickets
    end
    if reward.coins then
        currencyChanges.coins = reward.coins
    end
    if reward.premiumCurrency then
        currencyChanges.premiumCurrency = reward.premiumCurrency
    end
    
    local success = CharacterDatabase.UpdatePlayerCurrency(playerId, currencyChanges)
    if not success then
        return false, "Error aplicando recompensas"
    end
    
    -- Actualizar datos de login
    playerData.lastDailyReward = os.time()
    playerData.lastLogin = os.time()
    playerData.loginStreak = loginStreak
    
    CharacterDatabase.SavePlayerData(playerId, playerData)
    
    -- Notificar al cliente
    local player = Players:GetPlayerByUserId(playerId)
    if player then
        DailyRewardClaimed:FireClient(player, {
            day = loginStreak,
            reward = reward,
            newCurrency = CharacterDatabase.LoadPlayerData(playerId).currency
        })
    end
    
    return true, {day = loginStreak, reward = reward}
end

-- Agregar tickets gratuitos por tiempo (cada X horas)
function TicketManager.AddHourlyTickets(playerId)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    if not playerData then return false end
    
    local lastHourlyReward = playerData.lastHourlyReward or 0
    local currentTime = os.time()
    local hourInSeconds = 60 * 60
    
    local hoursElapsed = math.floor((currentTime - lastHourlyReward) / hourInSeconds)
    
    if hoursElapsed >= 1 then
        local ticketsToAdd = math.min(hoursElapsed, 12) -- Máximo 12 tickets por día sin jugar
        
        local currencyChanges = {
            freeTickets = ticketsToAdd
        }
        
        local success = CharacterDatabase.UpdatePlayerCurrency(playerId, currencyChanges)
        if success then
            playerData.lastHourlyReward = currentTime
            CharacterDatabase.SavePlayerData(playerId, playerData)
            
            -- Notificar al cliente
            local player = Players:GetPlayerByUserId(playerId)
            if player then
                CurrencyUpdated:FireClient(player, CharacterDatabase.LoadPlayerData(playerId).currency)
            end
            
            return true, ticketsToAdd
        end
    end
    
    return false, 0
end

-- Recompensas por ver anuncios (simulado)
function TicketManager.ClaimAdReward(playerId, adType)
    local rewards = {
        ["video"] = {freeTickets = 1, coins = 100},
        ["banner"] = {coins = 50},
        ["rewarded"] = {freeTickets = 2, coins = 200}
    }
    
    local reward = rewards[adType]
    if not reward then
        return false, "Tipo de anuncio inválido"
    end
    
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    local lastAdReward = playerData.lastAdReward or {}
    local currentTime = os.time()
    
    -- Limitar anuncios por día
    local today = math.floor(currentTime / (24 * 60 * 60))
    local todayAds = lastAdReward[today] or 0
    
    if todayAds >= 10 then -- Máximo 10 anuncios por día
        return false, "Límite diario de anuncios alcanzado"
    end
    
    -- Aplicar recompensa
    local success = CharacterDatabase.UpdatePlayerCurrency(playerId, reward)
    if not success then
        return false, "Error aplicando recompensa"
    end
    
    -- Actualizar contador de anuncios
    lastAdReward[today] = todayAds + 1
    playerData.lastAdReward = lastAdReward
    CharacterDatabase.SavePlayerData(playerId, playerData)
    
    -- Notificar al cliente
    local player = Players:GetPlayerByUserId(playerId)
    if player then
        CurrencyUpdated:FireClient(player, CharacterDatabase.LoadPlayerData(playerId).currency)
    end
    
    return true, reward
end

-- Recompensas por completar objetivos/achievements
function TicketManager.ClaimAchievementReward(playerId, achievementId)
    local achievements = {
        ["first_pull"] = {freeTickets = 5, coins = 500},
        ["first_rare"] = {freeTickets = 3, coins = 300},
        ["collector_10"] = {freeTickets = 10, coins = 1000},
        ["collector_50"] = {freeTickets = 25, coins = 2500, premiumCurrency = 100},
        ["gacha_addict"] = {freeTickets = 50, premiumCurrency = 500},
        ["battle_winner"] = {freeTickets = 2, coins = 200}
    }
    
    local reward = achievements[achievementId]
    if not reward then
        return false, "Achievement no válido"
    end
    
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    local claimedAchievements = playerData.claimedAchievements or {}
    
    if claimedAchievements[achievementId] then
        return false, "Achievement ya reclamado"
    end
    
    -- Aplicar recompensa
    local success = CharacterDatabase.UpdatePlayerCurrency(playerId, reward)
    if not success then
        return false, "Error aplicando recompensa"
    end
    
    -- Marcar como reclamado
    claimedAchievements[achievementId] = true
    playerData.claimedAchievements = claimedAchievements
    CharacterDatabase.SavePlayerData(playerId, playerData)
    
    return true, reward
end

-- Evento especial: duplicar tickets por tiempo limitado
function TicketManager.StartDoubleTicketEvent(durationHours)
    TicketManager.doubleTicketEvent = {
        startTime = os.time(),
        endTime = os.time() + (durationHours * 3600),
        active = true
    }
    
    -- Notificar a todos los jugadores conectados
    for _, player in ipairs(Players:GetPlayers()) do
        -- Aquí notificarías del evento especial
    end
end

-- Verificar si el evento de doble ticket está activo
function TicketManager.IsDoubleTicketEventActive()
    if not TicketManager.doubleTicketEvent then return false end
    
    local currentTime = os.time()
    return TicketManager.doubleTicketEvent.active and 
           currentTime <= TicketManager.doubleTicketEvent.endTime
end

-- Obtener multiplicador de tickets actual
function TicketManager.GetTicketMultiplier()
    return TicketManager.IsDoubleTicketEventActive() and 2 or 1
end

-- Sistema automático de tickets cada hora
spawn(function()
    while true do
        wait(3600) -- 1 hora
        
        for _, player in ipairs(Players:GetPlayers()) do
            TicketManager.AddHourlyTickets(player.UserId)
        end
    end
end)

-- Cuando un jugador se conecta
Players.PlayerAdded:Connect(function(player)
    wait(2) -- Esperar a que se carguen los datos
    
    -- Verificar recompensas pendientes
    TicketManager.AddHourlyTickets(player.UserId)
    
    -- Actualizar login streak
    local playerData = CharacterDatabase.LoadPlayerData(player.UserId)
    playerData.lastLogin = os.time()
    CharacterDatabase.SavePlayerData(player.UserId, playerData)
end)

return TicketManager