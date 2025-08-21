-- CombatEvents.lua
-- Eventos remotos para el sistema de combate

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Obtener carpeta de eventos
local eventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")

-- Eventos para Combate
local CombatEvents = {}

-- Remote Functions
CombatEvents.StartBattle = Instance.new("RemoteFunction")
CombatEvents.StartBattle.Name = "StartBattle"
CombatEvents.StartBattle.Parent = eventsFolder

CombatEvents.GetBattleHistory = Instance.new("RemoteFunction")
CombatEvents.GetBattleHistory.Name = "GetBattleHistory"
CombatEvents.GetBattleHistory.Parent = eventsFolder

CombatEvents.GetArenaOpponents = Instance.new("RemoteFunction")
CombatEvents.GetArenaOpponents.Name = "GetArenaOpponents"
CombatEvents.GetArenaOpponents.Parent = eventsFolder

CombatEvents.SetDefenseTeam = Instance.new("RemoteFunction")
CombatEvents.SetDefenseTeam.Name = "SetDefenseTeam"
CombatEvents.SetDefenseTeam.Parent = eventsFolder

-- Remote Events
CombatEvents.BattleStarted = Instance.new("RemoteEvent")
CombatEvents.BattleStarted.Name = "BattleStarted"
CombatEvents.BattleStarted.Parent = eventsFolder

CombatEvents.BattleUpdate = Instance.new("RemoteEvent")
CombatEvents.BattleUpdate.Name = "BattleUpdate"
CombatEvents.BattleUpdate.Parent = eventsFolder

CombatEvents.BattleEnded = Instance.new("RemoteEvent")
CombatEvents.BattleEnded.Name = "BattleEnded"
CombatEvents.BattleEnded.Parent = eventsFolder

CombatEvents.ExperienceGained = Instance.new("RemoteEvent")
CombatEvents.ExperienceGained.Name = "ExperienceGained"
CombatEvents.ExperienceGained.Parent = eventsFolder

return CombatEvents