-- Init.lua
-- Crea todos los RemoteEvents y RemoteFunctions necesarios

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Carpeta para eventos
local remoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteEventsFolder then
    remoteEventsFolder = Instance.new("Folder")
    remoteEventsFolder.Name = "RemoteEvents"
    remoteEventsFolder.Parent = ReplicatedStorage
end

local RemoteEvents = {}

-- === GACHA EVENTS ===
-- RemoteFunctions (cliente solicita respuesta del servidor)
RemoteEvents.PullGacha = Instance.new("RemoteFunction")
RemoteEvents.PullGacha.Name = "PullGacha"
RemoteEvents.PullGacha.Parent = remoteEventsFolder

RemoteEvents.GetPlayerCurrency = Instance.new("RemoteFunction")
RemoteEvents.GetPlayerCurrency.Name = "GetPlayerCurrency"
RemoteEvents.GetPlayerCurrency.Parent = remoteEventsFolder

RemoteEvents.GetGachaRates = Instance.new("RemoteFunction")
RemoteEvents.GetGachaRates.Name = "GetGachaRates"
RemoteEvents.GetGachaRates.Parent = remoteEventsFolder

RemoteEvents.BuyTickets = Instance.new("RemoteFunction")
RemoteEvents.BuyTickets.Name = "BuyTickets"
RemoteEvents.BuyTickets.Parent = remoteEventsFolder

-- === CHARACTER EVENTS ===
RemoteEvents.GetPlayerCharacters = Instance.new("RemoteFunction")
RemoteEvents.GetPlayerCharacters.Name = "GetPlayerCharacters"
RemoteEvents.GetPlayerCharacters.Parent = remoteEventsFolder

RemoteEvents.TrainCharacter = Instance.new("RemoteFunction")
RemoteEvents.TrainCharacter.Name = "TrainCharacter"
RemoteEvents.TrainCharacter.Parent = remoteEventsFolder

RemoteEvents.ReleaseCharacter = Instance.new("RemoteFunction")
RemoteEvents.ReleaseCharacter.Name = "ReleaseCharacter"
RemoteEvents.ReleaseCharacter.Parent = remoteEventsFolder

RemoteEvents.BreedCharacters = Instance.new("RemoteFunction")
RemoteEvents.BreedCharacters.Name = "BreedCharacters"
RemoteEvents.BreedCharacters.Parent = remoteEventsFolder

RemoteEvents.GetCharacterDetails = Instance.new("RemoteFunction")
RemoteEvents.GetCharacterDetails.Name = "GetCharacterDetails"
RemoteEvents.GetCharacterDetails.Parent = remoteEventsFolder

-- === COMBAT EVENTS ===
RemoteEvents.StartBattle = Instance.new("RemoteFunction")
RemoteEvents.StartBattle.Name = "StartBattle"
RemoteEvents.StartBattle.Parent = remoteEventsFolder

RemoteEvents.GetBattleHistory = Instance.new("RemoteFunction")
RemoteEvents.GetBattleHistory.Name = "GetBattleHistory"
RemoteEvents.GetBattleHistory.Parent = remoteEventsFolder

RemoteEvents.GetArenaOpponents = Instance.new("RemoteFunction")
RemoteEvents.GetArenaOpponents.Name = "GetArenaOpponents"
RemoteEvents.GetArenaOpponents.Parent = remoteEventsFolder

RemoteEvents.SetDefenseTeam = Instance.new("RemoteFunction")
RemoteEvents.SetDefenseTeam.Name = "SetDefenseTeam"
RemoteEvents.SetDefenseTeam.Parent = remoteEventsFolder

-- === NOTIFICATION EVENTS ===
-- RemoteEvents (servidor envía notificaciones al cliente)
RemoteEvents.CurrencyUpdated = Instance.new("RemoteEvent")
RemoteEvents.CurrencyUpdated.Name = "CurrencyUpdated"
RemoteEvents.CurrencyUpdated.Parent = remoteEventsFolder

RemoteEvents.GachaPullResult = Instance.new("RemoteEvent")
RemoteEvents.GachaPullResult.Name = "GachaPullResult"
RemoteEvents.GachaPullResult.Parent = remoteEventsFolder

RemoteEvents.CharacterUpdated = Instance.new("RemoteEvent")
RemoteEvents.CharacterUpdated.Name = "CharacterUpdated"
RemoteEvents.CharacterUpdated.Parent = remoteEventsFolder

RemoteEvents.TrainingCompleted = Instance.new("RemoteEvent")
RemoteEvents.TrainingCompleted.Name = "TrainingCompleted"
RemoteEvents.TrainingCompleted.Parent = remoteEventsFolder

RemoteEvents.DailyRewardClaimed = Instance.new("RemoteEvent")
RemoteEvents.DailyRewardClaimed.Name = "DailyRewardClaimed"
RemoteEvents.DailyRewardClaimed.Parent = remoteEventsFolder

RemoteEvents.BattleResult = Instance.new("RemoteEvent")
RemoteEvents.BattleResult.Name = "BattleResult"
RemoteEvents.BattleResult.Parent = remoteEventsFolder

return RemoteEvents