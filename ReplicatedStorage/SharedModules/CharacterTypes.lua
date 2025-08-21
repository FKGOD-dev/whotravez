-- CharacterTypes.lua
-- Define todos los tipos y enums para el sistema de personajes

local CharacterTypes = {}

-- Enums
CharacterTypes.Rarity = {
    COMMON = 1,
    UNCOMMON = 2,
    RARE = 3,
    EPIC = 4,
    LEGENDARY = 5,
    MYTHIC = 6
}

CharacterTypes.PersonalityTrait = {
    SHY = "shy",
    CONFIDENT = "confident",
    TSUNDERE = "tsundere",
    KUUDERE = "kuudere",
    DANDERE = "dandere",
    YANDERE = "yandere",
    CHEERFUL = "cheerful",
    MYSTERIOUS = "mysterious",
    PROTECTIVE = "protective",
    PLAYFUL = "playful"
}

CharacterTypes.CombatStyle = {
    AGGRESSIVE = "aggressive",
    DEFENSIVE = "defensive",
    BALANCED = "balanced",
    SUPPORT = "support",
    TACTICAL = "tactical"
}

CharacterTypes.BodyType = {
    PETITE = "petite",
    AVERAGE = "average",
    TALL = "tall",
    ATHLETIC = "athletic",
    CURVY = "curvy"
}

CharacterTypes.ClothingStyle = {
    CASUAL = "casual",
    FORMAL = "formal",
    SCHOOL = "school",
    FANTASY = "fantasy",
    MODERN = "modern",
    TRADITIONAL = "traditional"
}

CharacterTypes.TicketType = {
    FREE = "free",
    PREMIUM = "premium",
    SPECIAL = "special"
}

CharacterTypes.RewardType = {
    EXPERIENCE = "experience",
    COINS = "coins",
    TICKETS = "tickets",
    ITEMS = "items"
}

-- Funciones de utilidad para crear estructuras de datos
function CharacterTypes.CreateCharacter(data)
    return {
        id = data.id or "",
        name = data.name or "",
        series = data.series or "",
        rarity = data.rarity or CharacterTypes.Rarity.COMMON,
        attributes = data.attributes or CharacterTypes.CreateAttributes(),
        personality = data.personality or CharacterTypes.CreatePersonality(),
        appearance = data.appearance or CharacterTypes.CreateAppearance(),
        createdAt = data.createdAt or os.time(),
        lastUpdated = data.lastUpdated or os.time(),
        age = data.age or 0,
        level = data.level or 1,
        experience = data.experience or 0,
        ownerId = data.ownerId
    }
end

function CharacterTypes.CreateAttributes(data)
    data = data or {}
    return {
        strength = data.strength or 10,
        intelligence = data.intelligence or 10,
        speed = data.speed or 10,
        resistance = data.resistance or 10,
        charm = data.charm or 10,
        luck = data.luck or 10
    }
end

function CharacterTypes.CreatePersonality(data)
    data = data or {}
    return {
        traits = data.traits or {},
        combatStyle = data.combatStyle or CharacterTypes.CombatStyle.BALANCED,
        loyaltyLevel = data.loyaltyLevel or 50,
        sociability = data.sociability or 50,
        stubbornness = data.stubbornness or 50
    }
end

function CharacterTypes.CreateAppearance(data)
    data = data or {}
    return {
        hairColor = data.hairColor or "black",
        eyeColor = data.eyeColor or "brown",
        height = data.height or 160,
        bodyType = data.bodyType or CharacterTypes.BodyType.AVERAGE,
        clothingStyle = data.clothingStyle or CharacterTypes.ClothingStyle.CASUAL,
        specialFeatures = data.specialFeatures or {}
    }
end

function CharacterTypes.CreatePlayer(data)
    data = data or {}
    return {
        id = data.id or "",
        username = data.username or "",
        characters = data.characters or {},
        currency = data.currency or CharacterTypes.CreateCurrency(),
        inventory = data.inventory or CharacterTypes.CreateInventory(),
        stats = data.stats or CharacterTypes.CreatePlayerStats(),
        createdAt = data.createdAt or os.time()
    }
end

function CharacterTypes.CreateCurrency(data)
    data = data or {}
    return {
        freeTickets = data.freeTickets or 3,
        premiumCurrency = data.premiumCurrency or 0,
        coins = data.coins or 1000
    }
end

function CharacterTypes.CreateInventory(data)
    data = data or {}
    return {
        characterSlots = data.characterSlots or 10,
        maxCharacterSlots = data.maxCharacterSlots or 10,
        breedingPasses = data.breedingPasses or 0,
        skins = data.skins or {}
    }
end

function CharacterTypes.CreatePlayerStats(data)
    data = data or {}
    return {
        totalPulls = data.totalPulls or 0,
        totalCharacters = data.totalCharacters or 0,
        battlesWon = data.battlesWon or 0,
        battlesLost = data.battlesLost or 0,
        totalSpent = data.totalSpent or 0
    }
end

return CharacterTypes