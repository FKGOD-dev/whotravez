-- BattleManager.lua
-- Sistema de combate automático basado en estadísticas

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CharacterTypes = require(ReplicatedStorage.SharedModules.CharacterTypes)
local GameConfig = require(ReplicatedStorage.SharedModules.GameConfig)
local Utilities = require(ReplicatedStorage.SharedModules.Utilities)
local CharacterDatabase = require(script.Parent.Parent.CharacterSystem.CharacterDatabase)

local BattleManager = {}

-- Eventos
local eventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local BattleStarted = eventsFolder:WaitForChild("BattleStarted")
local BattleUpdate = eventsFolder:WaitForChild("BattleUpdate")
local BattleEnded = eventsFolder:WaitForChild("BattleEnded")
local ExperienceGained = eventsFolder:WaitForChild("ExperienceGained")

-- Calcular HP máximo de un personaje
function BattleManager.CalculateMaxHP(character)
    local baseHP = 100
    local levelBonus = character.level * 20
    local resistanceBonus = character.attributes.resistance * 2
    local rarityBonus = character.rarity * 30
    
    return baseHP + levelBonus + resistanceBonus + rarityBonus
end

-- Calcular daño de ataque
function BattleManager.CalculateDamage(attacker, defender)
    local baseDamage = attacker.attributes.strength * GameConfig.Combat.BaseDamageMultiplier
    local levelBonus = attacker.level * 2
    local rarityBonus = attacker.rarity * 5
    
    -- Bonus por estilo de combate
    local styleBonus = 1.0
    if attacker.personality.combatStyle == CharacterTypes.CombatStyle.AGGRESSIVE then
        styleBonus = 1.3
    elseif attacker.personality.combatStyle == CharacterTypes.CombatStyle.TACTICAL then
        styleBonus = 1.1
    end
    
    local totalDamage = (baseDamage + levelBonus + rarityBonus) * styleBonus
    
    -- Calcular defensa
    local defense = defender.attributes.resistance * GameConfig.Combat.DefenseReduction
    local finalDamage = math.max(1, totalDamage - defense)
    
    -- Crítico
    local critChance = GameConfig.Combat.CriticalChance + (attacker.attributes.luck * 0.01)
    if math.random() < critChance then
        finalDamage = finalDamage * GameConfig.Combat.CriticalMultiplier
        return math.floor(finalDamage), true
    end
    
    return math.floor(finalDamage), false
end

-- Calcular orden de turnos
function BattleManager.CalculateTurnOrder(team1, team2)
    local allCharacters = {}
    
    for _, char in ipairs(team1) do
        table.insert(allCharacters, {character = char, team = 1})
    end
    
    for _, char in ipairs(team2) do
        table.insert(allCharacters, {character = char, team = 2})
    end
    
    -- Ordenar por velocidad
    table.sort(allCharacters, function(a, b)
        local speedA = a.character.attributes.speed + math.random(-5, 5)
        local speedB = b.character.attributes.speed + math.random(-5, 5)
        return speedA > speedB
    end)
    
    return allCharacters
end

-- Seleccionar objetivo automáticamente
function BattleManager.SelectTarget(attacker, enemyTeam, battleState)
    local validTargets = {}
    
    for i, enemy in ipairs(enemyTeam) do
        if battleState.hp[enemy.id] > 0 then
            table.insert(validTargets, {character = enemy, index = i})
        end
    end
    
    if #validTargets == 0 then
        return nil
    end
    
    -- IA simple: atacar al más débil o al más fuerte según personalidad
    local target
    if attacker.personality.combatStyle == CharacterTypes.CombatStyle.TACTICAL then
        -- Atacar al más débil
        target = validTargets[1]
        for _, t in ipairs(validTargets) do
            if battleState.hp[t.character.id] < battleState.hp[target.character.id] then
                target = t
            end
        end
    else
        -- Atacar aleatoriamente o al más fuerte
        if attacker.personality.combatStyle == CharacterTypes.CombatStyle.AGGRESSIVE then
            target = validTargets[1]
            for _, t in ipairs(validTargets) do
                if battleState.hp[t.character.id] > battleState.hp[target.character.id] then
                    target = t
                end
            end
        else
            target = Utilities.RandomChoice(validTargets)
        end
    end
    
    return target
end

-- Simular batalla completa
function BattleManager.SimulateBattle(team1, team2, playerId)
    -- Inicializar estado de batalla
    local battleState = {
        turn = 0,
        hp = {},
        maxHp = {},
        team1 = team1,
        team2 = team2,
        log = {}
    }
    
    -- Calcular HP inicial
    for _, char in ipairs(team1) do
        battleState.maxHp[char.id] = BattleManager.CalculateMaxHP(char)
        battleState.hp[char.id] = battleState.maxHp[char.id]
    end
    
    for _, char in ipairs(team2) do
        battleState.maxHp[char.id] = BattleManager.CalculateMaxHP(char)
        battleState.hp[char.id] = battleState.maxHp[char.id]
    end
    
    -- Obtener orden de turnos
    local turnOrder = BattleManager.CalculateTurnOrder(team1, team2)
    
    -- Notificar inicio de batalla
    local player = Players:GetPlayerByUserId(playerId)
    if player then
        BattleStarted:FireClient(player, {
            team1 = team1,
            team2 = team2,
            initialState = battleState
        })
    end
    
    -- Simular batalla turno por turno
    local maxTurns = 50 -- Prevenir batallas infinitas
    
    while battleState.turn < maxTurns do
        battleState.turn = battleState.turn + 1
        
        -- Verificar condiciones de victoria
        local team1Alive = 0
        local team2Alive = 0
        
        for _, char in ipairs(team1) do
            if battleState.hp[char.id] > 0 then
                team1Alive = team1Alive + 1
            end
        end
        
        for _, char in ipairs(team2) do
            if battleState.hp[char.id] > 0 then
                team2Alive = team2Alive + 1
            end
        end
        
        if team1Alive == 0 or team2Alive == 0 then
            break
        end
        
        -- Procesar turnos
        for _, participant in ipairs(turnOrder) do
            if battleState.hp[participant.character.id] <= 0 then
                goto continue -- Personaje muerto, saltar turno
            end
            
            local attacker = participant.character
            local attackerTeam = participant.team
            local enemyTeam = attackerTeam == 1 and team2 or team1
            
            -- Seleccionar objetivo
            local target = BattleManager.SelectTarget(attacker, enemyTeam, battleState)
            if not target then
                goto continue
            end
            
            -- Calcular daño
            local damage, isCritical = BattleManager.CalculateDamage(attacker, target.character)
            battleState.hp[target.character.id] = math.max(0, battleState.hp[target.character.id] - damage)
            
            -- Registrar evento
            local event = {
                turn = battleState.turn,
                attacker = attacker.name,
                attackerId = attacker.id,
                defender = target.character.name,
                defenderId = target.character.id,
                damage = damage,
                isCritical = isCritical,
                remainingHp = battleState.hp[target.character.id]
            }
            
            table.insert(battleState.log, event)
            
            -- Notificar actualización
            if player then
                BattleUpdate:FireClient(player, event)
            end
            
            wait(0.5) -- Pausa para visualización
            
            ::continue::
        end
    end
    
    -- Determinar ganador
    local team1Alive = 0
    local team2Alive = 0
    
    for _, char in ipairs(team1) do
        if battleState.hp[char.id] > 0 then
            team1Alive = team1Alive + 1
        end
    end
    
    for _, char in ipairs(team2) do
        if battleState.hp[char.id] > 0 then
            team2Alive = team2Alive + 1
        end
    end
    
    local winner = nil
    local loser = nil
    
    if team1Alive > team2Alive then
        winner = 1
    elseif team2Alive > team1Alive then
        winner = 2
    else
        winner = 0 -- Empate
    end
    
    -- Calcular recompensas
    local experienceGained = 0
    local rewards = {}
    
    if winner == 1 then
        experienceGained = GameConfig.Experience.CombatExpBase
        table.insert(rewards, {
            type = CharacterTypes.RewardType.EXPERIENCE,
            amount = experienceGained
        })
        table.insert(rewards, {
            type = CharacterTypes.RewardType.COINS,
            amount = 50
        })
        
        -- Actualizar estadísticas del jugador
        CharacterDatabase.UpdatePlayerStats(playerId, {battlesWon = 1})
    else
        experienceGained = math.floor(GameConfig.Experience.CombatExpBase * 0.3)
        table.insert(rewards, {
            type = CharacterTypes.RewardType.EXPERIENCE,
            amount = experienceGained
        })
        
        CharacterDatabase.UpdatePlayerStats(playerId, {battlesLost = 1})
    end
    
    -- Aplicar experiencia a personajes del equipo 1 (jugador)
    for _, char in ipairs(team1) do
        char.experience = char.experience + experienceGained
        
        -- Verificar subida de nivel
        if Utilities.CanLevelUp(char, GameConfig.Experience) then
            char.level = char.level + 1
            char.experience = char.experience - Utilities.GetExpForNextLevel(char.level - 1, GameConfig.Experience)
            
            -- Bonus por subir de nivel
            for statName, _ in pairs(char.attributes) do
                char.attributes[statName] = char.attributes[statName] + math.random(1, 3)
            end
            
            CharacterDatabase.SaveCharacter(char)
            
            if player then
                ExperienceGained:FireClient(player, {
                    characterId = char.id,
                    levelUp = true,
                    newLevel = char.level
                })
            end
        else
            CharacterDatabase.SaveCharacter(char)
        end
    end
    
    -- Crear resultado final
    local result = {
        winner = winner,
        battleLog = battleState.log,
        experienceGained = experienceGained,
        rewards = rewards,
        finalState = battleState
    }
    
    -- Notificar fin de batalla
    if player then
        BattleEnded:FireClient(player, result)
    end
    
    return result
end

-- Buscar oponentes de IA
function BattleManager.GenerateAIOpponents(playerLevel, count)
    local opponents = {}
    
    for i = 1, count do
        -- Generar IA con nivel similar al jugador
        local aiLevel = math.max(1, playerLevel + math.random(-2, 2))
        local aiRarity = math.random(1, 3) -- IA con rarezas más bajas
        
        local aiCharacter = require(script.Parent.Parent.CharacterSystem.CharacterGenerator).GenerateCharacter(aiRarity)
        aiCharacter.level = aiLevel
        aiCharacter.ownerId = "AI"
        
        -- Ajustar stats basado en nivel
        for statName, baseValue in pairs(aiCharacter.attributes) do
            aiCharacter.attributes[statName] = baseValue + (aiLevel - 1) * 2
        end
        
        table.insert(opponents, aiCharacter)
    end
    
    return opponents
end

-- Iniciar batalla PvE
function BattleManager.StartPvEBattle(playerId, playerTeam, difficultyLevel)
    if not playerTeam or #playerTeam == 0 then
        return nil, "Equipo vacío"
    end
    
    -- Verificar que los personajes pertenecen al jugador
    for _, char in ipairs(playerTeam) do
        if char.ownerId ~= tostring(playerId) then
            return nil, "Personaje no válido"
        end
    end
    
    -- Generar equipo enemigo
    local avgLevel = 0
    for _, char in ipairs(playerTeam) do
        avgLevel = avgLevel + char.level
    end
    avgLevel = math.floor(avgLevel / #playerTeam)
    
    local enemyTeam = BattleManager.GenerateAIOpponents(avgLevel + difficultyLevel, #playerTeam)
    
    -- Simular batalla
    local result = BattleManager.SimulateBattle(playerTeam, enemyTeam, playerId)
    
    return result, nil
end

return BattleManager