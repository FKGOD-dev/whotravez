-- SkinManager.lua
-- Sistema de skins cosméticas para personajes

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CharacterTypes = require(ReplicatedStorage.SharedModules.CharacterTypes)
local GameConfig = require(ReplicatedStorage.SharedModules.GameConfig)
local Utilities = require(ReplicatedStorage.SharedModules.Utilities)
local CharacterDatabase = require(script.Parent.Parent.CharacterSystem.CharacterDatabase)

local SkinManager = {}

-- Catálogo de skins disponibles
local SkinCatalog = {
    -- Skins de temporada
    ["summer_beach"] = {
        id = "summer_beach",
        name = "Traje de Playa de Verano",
        description = "Un colorido traje de baño perfecto para el verano",
        rarity = CharacterTypes.Rarity.UNCOMMON,
        price = 150,
        category = "seasonal",
        applicableRarities = {1, 2, 3}, -- Solo para personajes comunes-raros
        visualEffects = {"beach_particles", "water_sparkles"},
        seasonal = true,
        season = "summer"
    },
    
    ["winter_coat"] = {
        id = "winter_coat",
        name = "Abrigo de Invierno Elegante",
        description = "Un elegante abrigo para el frío invierno",
        rarity = CharacterTypes.Rarity.RARE,
        price = 300,
        category = "seasonal",
        applicableRarities = {1, 2, 3, 4},
        visualEffects = {"snow_particles", "warm_glow"},
        seasonal = true,
        season = "winter"
    },
    
    -- Skins temáticas de anime
    ["magical_girl"] = {
        id = "magical_girl",
        name = "Uniforme de Chica Mágica",
        description = "Un deslumbrante uniforme de chica mágica con efectos estelares",
        rarity = CharacterTypes.Rarity.EPIC,
        price = 750,
        category = "magical",
        applicableRarities = {3, 4, 5}, -- Solo para personajes raros+
        visualEffects = {"star_trail", "magical_sparkles", "color_shift"},
        genderRestriction = "female"
    },
    
    ["ninja_outfit"] = {
        id = "ninja_outfit", 
        name = "Atuendo de Ninja Sombra",
        description = "Un traje ninja sigiloso con efectos de sombra",
        rarity = CharacterTypes.Rarity.EPIC,
        price = 750,
        category = "combat",
        applicableRarities = {3, 4, 5},
        visualEffects = {"shadow_trail", "smoke_effect"},
        combatBonus = {speed = 2} -- Bonus cosmético a las stats
    },
    
    ["royal_dress"] = {
        id = "royal_dress",
        name = "Vestido Real",
        description = "Un majestuoso vestido digno de la realeza",
        rarity = CharacterTypes.Rarity.LEGENDARY,
        price = 1500,
        category = "royal",
        applicableRarities = {4, 5, 6}, -- Solo épicos+
        visualEffects = {"golden_aura", "crown_sparkles", "royal_particles"},
        genderRestriction = "female",
        prestigeRequirement = 5 -- Requiere nivel de prestigio
    },
    
    ["demon_lord"] = {
        id = "demon_lord",
        name = "Armadura del Señor Demonio",
        description = "Una intimidante armadura con poder demoníaco",
        rarity = CharacterTypes.Rarity.LEGENDARY,
        price = 1500,
        category = "dark",
        applicableRarities = {4, 5, 6},
        visualEffects = {"dark_aura", "red_flames", "demon_wings"},
        genderRestriction = "male",
        prestigeRequirement = 5
    },
    
    -- Skins supremas (solo para MYTHIC)
    ["goddess_form"] = {
        id = "goddess_form",
        name = "Forma de Diosa",
        description = "La forma suprema de una diosa celestial",
        rarity = CharacterTypes.Rarity.MYTHIC,
        price = 5000,
        category = "divine",
        applicableRarities = {6}, -- Solo MYTHIC
        visualEffects = {"divine_light", "angel_wings", "holy_aura", "celestial_music"},
        genderRestriction = "female",
        prestigeRequirement = 10,
        limitedEdition = true
    },
    
    ["cosmic_emperor"] = {
        id = "cosmic_emperor",
        name = "Emperador Cósmico",
        description = "El poder del universo mismo",
        rarity = CharacterTypes.Rarity.MYTHIC,
        price = 5000,
        category = "cosmic",
        applicableRarities = {6},
        visualEffects = {"galaxy_aura", "star_field", "cosmic_energy", "space_distortion"},
        genderRestriction = "male",
        prestigeRequirement = 10,
        limitedEdition = true
    }
}

-- Verificar si un jugador puede comprar una skin
function SkinManager.CanPurchaseSkin(playerId, skinId)
    local skin = SkinCatalog[skinId]
    if not skin then
        return false, "Skin no encontrada"
    end
    
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    if not playerData then
        return false, "Error cargando datos del jugador"
    end
    
    -- Verificar si ya tiene la skin
    local ownedSkins = playerData.inventory.skins or {}
    for _, ownedSkin in ipairs(ownedSkins) do
        if ownedSkin.id == skinId then
            return false, "Ya posees esta skin"
        end
    end
    
    -- Verificar monedas
    if playerData.currency.premiumCurrency < skin.price then
        return false, "No tienes suficiente moneda premium"
    end
    
    -- Verificar requisitos de prestigio
    if skin.prestigeRequirement then
        local prestigeLevel = playerData.prestigeLevel or 0
        if prestigeLevel < skin.prestigeRequirement then
            return false, "Necesitas nivel de prestigio " .. skin.prestigeRequirement
        end
    end
    
    -- Verificar si es de temporada
    if skin.seasonal then
        local currentSeason = SkinManager.GetCurrentSeason()
        if currentSeason ~= skin.season then
            return false, "Esta skin no está disponible en la temporada actual"
        end
    end
    
    -- Verificar edición limitada
    if skin.limitedEdition then
        local globalStats = CharacterDatabase.GetGlobalStats()
        local skinsSold = globalStats["skins_sold_" .. skinId] or 0
        local maxSkins = 1000 -- Límite de 1000 copias
        
        if skinsSold >= maxSkins then
            return false, "Esta skin de edición limitada ya no está disponible"
        end
    end
    
    return true, nil
end

-- Comprar una skin
function SkinManager.PurchaseSkin(playerId, skinId)
    local canPurchase, error = SkinManager.CanPurchaseSkin(playerId, skinId)
    if not canPurchase then
        return false, error
    end
    
    local skin = SkinCatalog[skinId]
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    
    -- Deducir moneda
    local success = CharacterDatabase.UpdatePlayerCurrency(playerId, {
        premiumCurrency = -skin.price
    })
    
    if not success then
        return false, "Error procesando el pago"
    end
    
    -- Agregar skin al inventario
    if not playerData.inventory.skins then
        playerData.inventory.skins = {}
    end
    
    local newSkin = {
        id = skinId,
        name = skin.name,
        rarity = skin.rarity,
        purchaseDate = os.time(),
        timesUsed = 0
    }
    
    table.insert(playerData.inventory.skins, newSkin)
    
    -- Guardar datos
    CharacterDatabase.SavePlayerData(playerId, playerData)
    
    -- Actualizar estadísticas globales para ediciones limitadas
    if skin.limitedEdition then
        CharacterDatabase.UpdateGlobalStats({
            ["skins_sold_" .. skinId] = 1
        })
    end
    
    return true, newSkin
end

-- Aplicar skin a un personaje
function SkinManager.ApplySkinToCharacter(playerId, characterId, skinId)
    local character = CharacterDatabase.LoadCharacter(characterId)
    if not character or character.ownerId ~= tostring(playerId) then
        return false, "Personaje no válido"
    end
    
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    local ownedSkins = playerData.inventory.skins or {}
    
    -- Verificar que el jugador posee la skin
    local ownsSkin = false
    local skinData = nil
    for _, ownedSkin in ipairs(ownedSkins) do
        if ownedSkin.id == skinId then
            ownsSkin = true
            skinData = ownedSkin
            break
        end
    end
    
    if not ownsSkin then
        return false, "No posees esta skin"
    end
    
    local skin = SkinCatalog[skinId]
    if not skin then
        return false, "Skin no encontrada en el catálogo"
    end
    
    -- Verificar compatibilidad con rareza del personaje
    local compatible = false
    for _, rarity in ipairs(skin.applicableRarities) do
        if character.rarity == rarity then
            compatible = true
            break
        end
    end
    
    if not compatible then
        return false, "Esta skin no es compatible con la rareza del personaje"
    end
    
    -- Verificar restricción de género
    if skin.genderRestriction then
        -- Aquí necesitarías tener información de género en el personaje
        -- Por simplicidad, asumimos que es compatible
    end
    
    -- Aplicar skin
    if not character.equippedSkins then
        character.equippedSkins = {}
    end
    
    character.equippedSkins[skin.category] = skinId
    character.lastUpdated = os.time()
    
    -- Incrementar contador de uso de la skin
    skinData.timesUsed = (skinData.timesUsed or 0) + 1
    
    -- Guardar cambios
    CharacterDatabase.SaveCharacter(character)
    CharacterDatabase.SavePlayerData(playerId, playerData)
    
    return true, "Skin aplicada exitosamente"
end

-- Remover skin de un personaje
function SkinManager.RemoveSkinFromCharacter(playerId, characterId, category)
    local character = CharacterDatabase.LoadCharacter(characterId)
    if not character or character.ownerId ~= tostring(playerId) then
        return false, "Personaje no válido"
    end
    
    if character.equippedSkins and character.equippedSkins[category] then
        character.equippedSkins[category] = nil
        character.lastUpdated = os.time()
        
        CharacterDatabase.SaveCharacter(character)
        return true, "Skin removida exitosamente"
    end
    
    return false, "El personaje no tiene una skin equipada en esa categoría"
end

-- Obtener temporada actual
function SkinManager.GetCurrentSeason()
    local month = os.date("*t").month
    
    if month >= 3 and month <= 5 then
        return "spring"
    elseif month >= 6 and month <= 8 then
        return "summer"
    elseif month >= 9 and month <= 11 then
        return "autumn"
    else
        return "winter"
    end
end

-- Obtener skins disponibles para compra
function SkinManager.GetAvailableSkins(playerId)
    local playerData = CharacterDatabase.LoadPlayerData(playerId)
    local ownedSkins = {}
    
    -- Crear lookup de skins poseídas
    if playerData.inventory.skins then
        for _, skin in ipairs(playerData.inventory.skins) do
            ownedSkins[skin.id] = true
        end
    end
    
    local availableSkins = {}
    local currentSeason = SkinManager.GetCurrentSeason()
    
    for skinId, skin in pairs(SkinCatalog) do
        local available = true
        local reason = ""
        
        -- Verificar si ya la posee
        if ownedSkins[skinId] then
            available = false
            reason = "Ya poseída"
        end
        
        -- Verificar temporada
        if skin.seasonal and skin.season ~= currentSeason then
            available = false
            reason = "Fuera de temporada"
        end
        
        -- Verificar prestigio
        if skin.prestigeRequirement then
            local prestigeLevel = playerData.prestigeLevel or 0
            if prestigeLevel < skin.prestigeRequirement then
                available = false
                reason = "Prestigio insuficiente"
            end
        end
        
        -- Verificar edición limitada
        if skin.limitedEdition then
            local globalStats = CharacterDatabase.GetGlobalStats()
            local skinsSold = globalStats["skins_sold_" .. skinId] or 0
            if skinsSold >= 1000 then
                available = false
                reason = "Agotada"
            end
        end
        
        table.insert(availableSkins, {
            id = skinId,
            name = skin.name,
            description = skin.description,
            rarity = skin.rarity,
            price = skin.price,
            category = skin.category,
            visualEffects = skin.visualEffects,
            available = available,
            reason = reason,
            owned = ownedSkins[skinId] or false
        })
    end
    
    return availableSkins
end

-- Obtener efectos visuales de las skins equipadas en un personaje
function SkinManager.GetCharacterVisualEffects(character)
    local effects = {}
    
    if character.equippedSkins then
        for category, skinId in pairs(character.equippedSkins) do
            local skin = SkinCatalog[skinId]
            if skin and skin.visualEffects then
                for _, effect in ipairs(skin.visualEffects) do
                    table.insert(effects, effect)
                end
            end
        end
    end
    
    return effects
end

-- Obtener bonus de combate de las skins equipadas
function SkinManager.GetCharacterSkinBonuses(character)
    local bonuses = {}
    
    if character.equippedSkins then
        for category, skinId in pairs(character.equippedSkins) do
            local skin = SkinCatalog[skinId]
            if skin and skin.combatBonus then
                for stat, bonus in pairs(skin.combatBonus) do
                    bonuses[stat] = (bonuses[stat] or 0) + bonus
                end
            end
        end
    end
    
    return bonuses
end

return SkinManager