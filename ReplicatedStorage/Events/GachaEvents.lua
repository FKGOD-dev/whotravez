-- GachaEvents.lua
-- Eventos remotos para el sistema Gacha

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Obtener carpeta de eventos
local eventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")

-- Eventos para Gacha
local GachaEvents = {}

-- Remote Functions (solicitan respuesta)
GachaEvents.PullGacha = Instance.new("RemoteFunction")
GachaEvents.PullGacha.Name = "PullGacha"
GachaEvents.PullGacha.Parent = eventsFolder

GachaEvents.GetPlayerCurrency = Instance.new("RemoteFunction")
GachaEvents.GetPlayerCurrency.Name = "GetPlayerCurrency"
GachaEvents.GetPlayerCurrency.Parent = eventsFolder

GachaEvents.GetGachaRates = Instance.new("RemoteFunction")
GachaEvents.GetGachaRates.Name = "GetGachaRates"
GachaEvents.GetGachaRates.Parent = eventsFolder

GachaEvents.BuyTickets = Instance.new("RemoteFunction")
GachaEvents.BuyTickets.Name = "BuyTickets"
GachaEvents.BuyTickets.Parent = eventsFolder

-- Remote Events (notificaciones)
GachaEvents.CurrencyUpdated = Instance.new("RemoteEvent")
GachaEvents.CurrencyUpdated.Name = "CurrencyUpdated"
GachaEvents.CurrencyUpdated.Parent = eventsFolder

GachaEvents.GachaPullResult = Instance.new("RemoteEvent")
GachaEvents.GachaPullResult.Name = "GachaPullResult"
GachaEvents.GachaPullResult.Parent = eventsFolder

GachaEvents.DailyRewardClaimed = Instance.new("RemoteEvent")
GachaEvents.DailyRewardClaimed.Name = "DailyRewardClaimed"
GachaEvents.DailyRewardClaimed.Parent = eventsFolder

return GachaEvents