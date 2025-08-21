-- CharacterEvents.lua
-- Eventos remotos para el sistema de personajes

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Crear carpeta de eventos si no existe
local eventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not eventsFolder then
    eventsFolder = Instance.new("Folder")
    eventsFolder.Name = "RemoteEvents"
    eventsFolder.Parent = ReplicatedStorage
end

-- Eventos para personajes
local CharacterEvents = {}

-- Remote Events
CharacterEvents.GetPlayerCharacters = Instance.new("RemoteFunction")
CharacterEvents.GetPlayerCharacters.Name = "GetPlayerCharacters"
CharacterEvents.GetPlayerCharacters.Parent = eventsFolder

CharacterEvents.TrainCharacter = Instance.new("RemoteFunction")
CharacterEvents.TrainCharacter.Name = "TrainCharacter"
CharacterEvents.TrainCharacter.Parent = eventsFolder

CharacterEvents.ReleaseCharacter = Instance.new("RemoteFunction")
CharacterEvents.ReleaseCharacter.Name = "ReleaseCharacter"
CharacterEvents.ReleaseCharacter.Parent = eventsFolder

CharacterEvents.BreedCharacters = Instance.new("RemoteFunction")
CharacterEvents.BreedCharacters.Name = "BreedCharacters"
CharacterEvents.BreedCharacters.Parent = eventsFolder

CharacterEvents.GetCharacterDetails = Instance.new("RemoteFunction")
CharacterEvents.GetCharacterDetails.Name = "GetCharacterDetails"
CharacterEvents.GetCharacterDetails.Parent = eventsFolder

-- Remote Events (one-way)
CharacterEvents.CharacterUpdated = Instance.new("RemoteEvent")
CharacterEvents.CharacterUpdated.Name = "CharacterUpdated"
CharacterEvents.CharacterUpdated.Parent = eventsFolder

CharacterEvents.CharacterLevelUp = Instance.new("RemoteEvent")
CharacterEvents.CharacterLevelUp.Name = "CharacterLevelUp"
CharacterEvents.CharacterLevelUp.Parent = eventsFolder

CharacterEvents.CharacterAged = Instance.new("RemoteEvent")
CharacterEvents.CharacterAged.Name = "CharacterAged"
CharacterEvents.CharacterAged.Parent = eventsFolder

return CharacterEvents