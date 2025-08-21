-- ShopEvents.lua
-- Crear eventos remotos para el sistema de tienda

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Crear carpeta de eventos si no existe
local eventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not eventsFolder then
    eventsFolder = Instance.new("Folder")
    eventsFolder.Name = "RemoteEvents"
    eventsFolder.Parent = ReplicatedStorage
end

-- === EVENTOS DE TIENDA Y MARKETPLACE ===

-- Prompts de compra con Robux
local promptPurchase = Instance.new("RemoteFunction")
promptPurchase.Name = "PromptPurchase"
promptPurchase.Parent = eventsFolder

-- Comprar items con moneda del juego
local buyGameItem = Instance.new("RemoteFunction")
buyGameItem.Name = "BuyGameItem"
buyGameItem.Parent = eventsFolder

-- Obtener historial de compras
local getPurchaseHistory = Instance.new("RemoteFunction")
getPurchaseHistory.Name = "GetPurchaseHistory"
getPurchaseHistory.Parent = eventsFolder

-- Obtener boosts activos
local getActiveBoosts = Instance.new("RemoteFunction")
getActiveBoosts.Name = "GetActiveBoosts"
getActiveBoosts.Parent = eventsFolder

-- Obtener pases activos
local getActivePasses = Instance.new("RemoteFunction")
getActivePasses.Name = "GetActivePasses"
getActivePasses.Parent = eventsFolder

-- Evento para notificar compra exitosa (servidor -> cliente)
local purchaseSuccess = Instance.new("RemoteEvent")
purchaseSuccess.Name = "PurchaseSuccess"
purchaseSuccess.Parent = eventsFolder

-- Evento para notificar cambios en boosts (servidor -> cliente)
local boostsUpdated = Instance.new("RemoteEvent")
boostsUpdated.Name = "BoostsUpdated" 
boostsUpdated.Parent = eventsFolder

-- Evento para notificar cambios en pases (servidor -> cliente)
local passesUpdated = Instance.new("RemoteEvent")
passesUpdated.Name = "PassesUpdated"
passesUpdated.Parent = eventsFolder

print("Shop events created successfully")