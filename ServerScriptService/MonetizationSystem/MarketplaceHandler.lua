-- MarketplaceHandler.lua
-- Sistema completo de MarketplaceService para compras con Robux

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterDatabase = require(script.Parent.Parent.CharacterSystem.CharacterDatabase)

local MarketplaceHandler = {}

-- Productos reales que deben estar configurados en Roblox Developer Console
local Products = {
    -- Packs de Moneda Premium
    [1234567890] = {type = "premium_pack", premium = 500, tickets = 10, coins = 5000, name = "Starter Pack"},
    [1234567891] = {type = "premium_pack", premium = 2000, tickets = 50, coins = 25000, name = "Mega Pack"},
    [1234567892] = {type = "premium_pack", premium = 5000, tickets = 150, coins = 75000, name = "Ultimate Pack"},
    
    -- Items Especiales
    [2345678901] = {type = "boost", effect = "xp_double", duration = 3600, name = "Boost XP x2 (1h)"},
    [2345678902] = {type = "boost", effect = "luck_boost", duration = 7200, name = "Luck Boost (2h)"},
    [2345678903] = {type = "feature", effect = "auto_training", duration = 86400, name = "Auto-Training (24h)"},
    
    -- Skins y Cosméticos
    [3456789012] = {type = "cosmetic", item = "golden_aura", permanent = true, name = "Aura Dorada"},
    [3456789013] = {type = "cosmetic", item = "epic_frame", permanent = true, name = "Marco Épico"},
    [3456789014] = {type = "cosmetic", item = "mystic_effect", permanent = true, name = "Efecto Místico"},
    
    -- Pases Premium
    [4567890123] = {type = "pass", pass_type = "monthly", duration = 30 * 24 * 3600, name = "Pase Mensual"},
    [4567890124] = {type = "pass", pass_type = "battle_pass", season = 1, name = "Pase de Batalla S1"}
}

-- Historial de compras para prevenir duplicados
local purchaseHistory = {}

-- Función para manejar compras exitosas
local function onPurchaseFinished(receiptInfo)
    local playerId = receiptInfo.PlayerId
    local productId = receiptInfo.ProductId
    local purchaseId = receiptInfo.PurchaseId
    
    -- Verificar si ya procesamos esta compra
    if purchaseHistory[purchaseId] then
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end
    
    local product = Products[productId]
    if not product then
        warn("Producto desconocido:", productId)
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
    
    local player = Players:GetPlayerByUserId(playerId)
    if not player then
        -- El jugador se desconectó, intentar más tarde
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
    
    -- Procesar la compra según el tipo de producto
    local success = false
    
    if product.type == "premium_pack" then
        success = MarketplaceHandler.GrantPremiumPack(playerId, product)
    elseif product.type == "boost" then
        success = MarketplaceHandler.GrantBoost(playerId, product)
    elseif product.type == "cosmetic" then
        success = MarketplaceHandler.GrantCosmetic(playerId, product)
    elseif product.type == "pass" then
        success = MarketplaceHandler.GrantPass(playerId, product)
    end
    
    if success then
        -- Registrar compra exitosa
        purchaseHistory[purchaseId] = {
            playerId = playerId,
            productId = productId,
            timestamp = os.time(),
            product = product
        }
        
        -- Agregar al historial del jugador
        MarketplaceHandler.AddToPurchaseHistory(playerId, product, receiptInfo)
        
        -- Notificar al cliente sobre la compra exitosa
        local purchaseSuccess = ReplicatedStorage.RemoteEvents:FindFirstChild("PurchaseSuccess")
        if purchaseSuccess and player then
            purchaseSuccess:FireClient(player, product)
        end
        
        print(string.format("Compra exitosa - Jugador: %s, Producto: %s (%d)", 
            player.Name, product.name, productId))
        
        return Enum.ProductPurchaseDecision.PurchaseGranted
    else
        warn(string.format("Error procesando compra - Jugador: %d, Producto: %d", playerId, productId))
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
end

-- Otorgar pack de moneda premium
function MarketplaceHandler.GrantPremiumPack(playerId, product)
    local success = CharacterDatabase.UpdatePlayerCurrency(playerId, {
        coins = product.coins or 0,
        tickets = product.tickets or 0,
        premiumCurrency = product.premium or 0
    })
    
    if success then
        print(string.format("Premium pack otorgado: +%d monedas, +%d tickets, +%d premium", 
            product.coins or 0, product.tickets or 0, product.premium or 0))
        return true
    end
    
    return false
end

-- Otorgar boost temporal
function MarketplaceHandler.GrantBoost(playerId, product)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    if not playerData then return false end
    
    if not playerData.activeBoosts then
        playerData.activeBoosts = {}
    end
    
    local endTime = os.time() + (product.duration or 3600)
    playerData.activeBoosts[product.effect] = {
        endTime = endTime,
        effect = product.effect,
        active = true
    }
    
    local success = CharacterDatabase.SavePlayerData(playerId, playerData)
    if success then
        print(string.format("Boost otorgado: %s por %d segundos", product.effect, product.duration))
        return true
    end
    
    return false
end

-- Otorgar cosmético permanente
function MarketplaceHandler.GrantCosmetic(playerId, product)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    if not playerData then return false end
    
    if not playerData.cosmetics then
        playerData.cosmetics = {}
    end
    
    playerData.cosmetics[product.item] = {
        item = product.item,
        obtained = os.time(),
        equipped = false
    }
    
    local success = CharacterDatabase.SavePlayerData(playerId, playerData)
    if success then
        print(string.format("Cosmético otorgado: %s", product.item))
        return true
    end
    
    return false
end

-- Otorgar pase premium
function MarketplaceHandler.GrantPass(playerId, product)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    if not playerData then return false end
    
    if not playerData.passes then
        playerData.passes = {}
    end
    
    local endTime = os.time() + (product.duration or (30 * 24 * 3600))
    playerData.passes[product.pass_type] = {
        active = true,
        startTime = os.time(),
        endTime = endTime,
        season = product.season
    }
    
    local success = CharacterDatabase.SavePlayerData(playerId, playerData)
    if success then
        print(string.format("Pase otorgado: %s hasta %s", product.pass_type, os.date("%c", endTime)))
        return true
    end
    
    return false
end

-- Agregar compra al historial del jugador
function MarketplaceHandler.AddToPurchaseHistory(playerId, product, receiptInfo)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    if not playerData then return false end
    
    if not playerData.purchaseHistory then
        playerData.purchaseHistory = {}
    end
    
    table.insert(playerData.purchaseHistory, {
        productName = product.name,
        productId = receiptInfo.ProductId,
        purchaseId = receiptInfo.PurchaseId,
        timestamp = os.time(),
        robux = receiptInfo.CurrencySpent or 0
    })
    
    -- Mantener solo las últimas 50 compras
    if #playerData.purchaseHistory > 50 then
        table.remove(playerData.purchaseHistory, 1)
    end
    
    return CharacterDatabase.SavePlayerData(playerId, playerData)
end

-- Función para prompts de compra desde el cliente
function MarketplaceHandler.PromptPurchase(player, productId)
    if not Products[productId] then
        warn("Producto inválido:", productId)
        return false
    end
    
    pcall(function()
        MarketplaceService:PromptProductPurchase(player, productId)
    end)
    
    return true
end

-- Obtener información de producto
function MarketplaceHandler.GetProductInfo(productId)
    return Products[productId]
end

-- Verificar si el jugador tiene boosts activos
function MarketplaceHandler.GetActiveBoosts(playerId)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    if not playerData or not playerData.activeBoosts then
        return {}
    end
    
    local currentTime = os.time()
    local activeBoosts = {}
    
    for effect, boost in pairs(playerData.activeBoosts) do
        if boost.active and boost.endTime > currentTime then
            activeBoosts[effect] = boost
        end
    end
    
    return activeBoosts
end

-- Verificar si el jugador tiene pases activos
function MarketplaceHandler.GetActivePasses(playerId)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    if not playerData or not playerData.passes then
        return {}
    end
    
    local currentTime = os.time()
    local activePasses = {}
    
    for passType, pass in pairs(playerData.passes) do
        if pass.active and pass.endTime > currentTime then
            activePasses[passType] = pass
        end
    end
    
    return activePasses
end

-- Conectar el callback de procesamiento de compras
MarketplaceService.ProcessReceipt = onPurchaseFinished

return MarketplaceHandler