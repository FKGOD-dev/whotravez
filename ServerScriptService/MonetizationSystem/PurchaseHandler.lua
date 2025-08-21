-- PurchaseHandler.lua
-- Sistema de compras y monetización con Robux

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local CharacterTypes = require(ReplicatedStorage.SharedModules.CharacterTypes)
local GameConfig = require(ReplicatedStorage.SharedModules.GameConfig)
local CharacterDatabase = require(script.Parent.Parent.CharacterSystem.CharacterDatabase)

local PurchaseHandler = {}

-- IDs de productos en el Marketplace de Roblox (estos serían los IDs reales)
local ProductIDs = {
    -- Moneda Premium
    PREMIUM_CURRENCY_100 = 123456789,   -- 100 monedas premium por 25 Robux
    PREMIUM_CURRENCY_500 = 123456790,   -- 500 monedas premium por 100 Robux  
    PREMIUM_CURRENCY_1000 = 123456791,  -- 1000 monedas premium por 180 Robux
    PREMIUM_CURRENCY_2500 = 123456792,  -- 2500 monedas premium por 400 Robux
    
    -- Slots de personajes
    CHARACTER_SLOT_5 = 123456793,       -- 5 slots adicionales por 50 Robux
    CHARACTER_SLOT_10 = 123456794,      -- 10 slots adicionales por 80 Robux
    CHARACTER_SLOT_25 = 123456795,      -- 25 slots adicionales por 150 Robux
    
    -- Pases de cría
    BREEDING_PASS_1 = 123456796,        -- 1 pase de cría por 75 Robux
    BREEDING_PASS_5 = 123456797,        -- 5 pases de cría por 300 Robux
    BREEDING_PASS_10 = 123456798,       -- 10 pases de cría por 500 Robux
    
    -- Paquetes especiales
    STARTER_PACK = 123456799,           -- Pack inicial con monedas y slots
    VIP_PACK = 123456800,               -- Pack VIP con muchos beneficios
    GACHA_TICKETS_10 = 123456801,       -- 10 tickets premium de gacha
    
    -- Boost temporales
    DOUBLE_EXP_24H = 123456802,         -- Doble experiencia por 24 horas
    DOUBLE_TRAINING_24H = 123456803,    -- Entrenamiento instantáneo por 24 horas
    LUCKY_BOOST_24H = 123456804,        -- Aumenta probabilidades de gacha por 24h
}

-- Definición de productos y sus recompensas
local Products = {
    [ProductIDs.PREMIUM_CURRENCY_100] = {
        name = "100 Monedas Premium",
        reward = {premiumCurrency = 100},
        price = 25
    },
    [ProductIDs.PREMIUM_CURRENCY_500] = {
        name = "500 Monedas Premium",
        reward = {premiumCurrency = 500},
        price = 100,
        bonus = true -- 20% bonus
    },
    [ProductIDs.PREMIUM_CURRENCY_1000] = {
        name = "1000 Monedas Premium",
        reward = {premiumCurrency = 1000},
        price = 180,
        bonus = true -- 28% bonus
    },
    [ProductIDs.PREMIUM_CURRENCY_2500] = {
        name = "2500 Monedas Premium",
        reward = {premiumCurrency = 2500},
        price = 400,
        bonus = true -- 36% bonus
    },
    
    [ProductIDs.CHARACTER_SLOT_5] = {
        name = "5 Slots de Personajes",
        reward = {characterSlots = 5},
        price = 50
    },
    [ProductIDs.CHARACTER_SLOT_10] = {
        name = "10 Slots de Personajes", 
        reward = {characterSlots = 10},
        price = 80,
        bonus = true
    },
    [ProductIDs.CHARACTER_SLOT_25] = {
        name = "25 Slots de Personajes",
        reward = {characterSlots = 25},
        price = 150,
        bonus = true
    },
    
    [ProductIDs.BREEDING_PASS_1] = {
        name = "Pase de Cría",
        reward = {breedingPasses = 1},
        price = 75
    },
    [ProductIDs.BREEDING_PASS_5] = {
        name = "5 Pases de Cría",
        reward = {breedingPasses = 5},
        price = 300,
        bonus = true
    },
    [ProductIDs.BREEDING_PASS_10] = {
        name = "10 Pases de Cría",
        reward = {breedingPasses = 10},
        price = 500,
        bonus = true
    },
    
    [ProductIDs.STARTER_PACK] = {
        name = "Pack Inicial",
        reward = {
            premiumCurrency = 200,
            characterSlots = 10,
            breedingPasses = 1,
            freeTickets = 10
        },
        price = 99,
        oneTimeOnly = true
    },
    
    [ProductIDs.VIP_PACK] = {
        name = "Pack VIP",
        reward = {
            premiumCurrency = 1000,
            characterSlots = 50,
            breedingPasses = 10,
            freeTickets = 50,
            vipStatus = true
        },
        price = 499,
        oneTimeOnly = true
    },
    
    [ProductIDs.GACHA_TICKETS_10] = {
        name = "10 Tickets Premium de Gacha",
        reward = {premiumGachaTickets = 10},
        price = 200
    },
    
    [ProductIDs.DOUBLE_EXP_24H] = {
        name = "Doble Experiencia 24h",
        reward = {boost = {type = "exp", duration = 86400}}, -- 24 horas en segundos
        price = 50
    },
    
    [ProductIDs.DOUBLE_TRAINING_24H] = {
        name = "Entrenamiento Instantáneo 24h",
        reward = {boost = {type = "training", duration = 86400}},
        price = 75
    },
    
    [ProductIDs.LUCKY_BOOST_24H] = {
        name = "Boost de Suerte 24h",
        reward = {boost = {type = "luck", duration = 86400}},
        price = 100
    }
}

-- Manejar compra exitosa
function PurchaseHandler.ProcessPurchase(receipt)
    local player = Players:GetPlayerByUserId(receipt.PlayerId)
    if not player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
    
    local productId = receipt.ProductId
    local product = Products[productId]
    
    if not product then
        warn("Producto desconocido: " .. productId)
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
    
    -- Verificar compras de una sola vez
    if product.oneTimeOnly then
        local playerData = CharacterDatabase.LoadPlayerData(receipt.PlayerId)
        local purchaseHistory = playerData.purchaseHistory or {}
        
        if purchaseHistory[productId] then
            return Enum.ProductPurchaseDecision.PurchaseGranted -- Ya comprado, pero confirmar
        end
    end
    
    -- Aplicar recompensas
    local success = PurchaseHandler.GrantRewards(receipt.PlayerId, product.reward, productId)
    
    if success then
        -- Registrar compra
        PurchaseHandler.RecordPurchase(receipt.PlayerId, productId, product)
        
        -- Actualizar estadísticas
        CharacterDatabase.UpdatePlayerStats(receipt.PlayerId, {
            totalSpent = product.price
        })
        
        return Enum.ProductPurchaseDecision.PurchaseGranted
    else
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
end

-- Otorgar recompensas al jugador
function PurchaseHandler.GrantRewards(playerId, rewards, productId)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    if not playerData then
        return false
    end
    
    -- Aplicar recompensas de moneda
    local currencyChanges = {}
    if rewards.premiumCurrency then
        currencyChanges.premiumCurrency = rewards.premiumCurrency
    end
    if rewards.freeTickets then
        currencyChanges.freeTickets = rewards.freeTickets
    end
    if rewards.coins then
        currencyChanges.coins = rewards.coins
    end
    
    if next(currencyChanges) then
        CharacterDatabase.UpdatePlayerCurrency(playerId, currencyChanges)
    end
    
    -- Aplicar recompensas de inventario
    local inventoryChanges = false
    if rewards.characterSlots then
        playerData.inventory.maxCharacterSlots = playerData.inventory.maxCharacterSlots + rewards.characterSlots
        inventoryChanges = true
    end
    if rewards.breedingPasses then
        playerData.inventory.breedingPasses = playerData.inventory.breedingPasses + rewards.breedingPasses
        inventoryChanges = true
    end
    
    -- Aplicar boosts temporales
    if rewards.boost then
        local currentTime = os.time()
        if not playerData.activeBoosts then
            playerData.activeBoosts = {}
        end
        
        playerData.activeBoosts[rewards.boost.type] = {
            endTime = currentTime + rewards.boost.duration,
            startTime = currentTime
        }
        inventoryChanges = true
    end
    
    -- Aplicar status VIP
    if rewards.vipStatus then
        playerData.isVIP = true
        playerData.vipSince = os.time()
        inventoryChanges = true
    end
    
    if inventoryChanges then
        CharacterDatabase.SavePlayerData(playerId, playerData)
    end
    
    return true
end

-- Registrar compra en el historial
function PurchaseHandler.RecordPurchase(playerId, productId, product)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    
    if not playerData.purchaseHistory then
        playerData.purchaseHistory = {}
    end
    
    playerData.purchaseHistory[productId] = {
        timestamp = os.time(),
        price = product.price,
        name = product.name
    }
    
    CharacterDatabase.SavePlayerData(playerId, playerData)
end

-- Verificar si un boost está activo
function PurchaseHandler.IsBoostActive(playerId, boostType)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    if not playerData.activeBoosts then
        return false
    end
    
    local boost = playerData.activeBoosts[boostType]
    if not boost then
        return false
    end
    
    return os.time() < boost.endTime
end

-- Obtener multiplicador de boost
function PurchaseHandler.GetBoostMultiplier(playerId, boostType)
    if PurchaseHandler.IsBoostActive(playerId, boostType) then
        return 2.0 -- Doble
    end
    return 1.0
end

-- Obtener tiempo restante de boost
function PurchaseHandler.GetBoostTimeRemaining(playerId, boostType)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    if not playerData.activeBoosts then
        return 0
    end
    
    local boost = playerData.activeBoosts[boostType]
    if not boost then
        return 0
    end
    
    local remaining = boost.endTime - os.time()
    return math.max(0, remaining)
end

-- Obtener información de todos los productos disponibles
function PurchaseHandler.GetAvailableProducts(playerId)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    local purchaseHistory = playerData.purchaseHistory or {}
    
    local availableProducts = {}
    
    for productId, product in pairs(Products) do
        local canPurchase = true
        
        -- Verificar productos de una sola vez
        if product.oneTimeOnly and purchaseHistory[productId] then
            canPurchase = false
        end
        
        table.insert(availableProducts, {
            id = productId,
            name = product.name,
            price = product.price,
            reward = product.reward,
            canPurchase = canPurchase,
            oneTimeOnly = product.oneTimeOnly,
            bonus = product.bonus
        })
    end
    
    return availableProducts
end

-- Verificar status VIP
function PurchaseHandler.IsVIP(playerId)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    return playerData.isVIP == true
end

-- Beneficios VIP automáticos
function PurchaseHandler.ApplyVIPBenefits(playerId)
    if not PurchaseHandler.IsVIP(playerId) then
        return false
    end
    
    -- Los jugadores VIP obtienen beneficios pasivos:
    -- - Doble experiencia permanente
    -- - Entrenamiento 50% más rápido
    -- - +1 ticket gratuito por día
    -- - Acceso a gacha VIP exclusivo
    
    return true
end

-- Configurar el callback de MarketplaceService
MarketplaceService.ProcessReceipt = PurchaseHandler.ProcessPurchase

-- Limpiar boosts expirados periódicamente
spawn(function()
    while true do
        wait(3600) -- Cada hora
        
        for _, player in ipairs(Players:GetPlayers()) do
            local playerData = CharacterDatabase.LoadPlayerData(player.UserId)
            if playerData.activeBoosts then
                local currentTime = os.time()
                local changed = false
                
                for boostType, boost in pairs(playerData.activeBoosts) do
                    if currentTime >= boost.endTime then
                        playerData.activeBoosts[boostType] = nil
                        changed = true
                    end
                end
                
                if changed then
                    CharacterDatabase.SavePlayerData(player.UserId, playerData)
                end
            end
        end
    end
end)

return PurchaseHandler