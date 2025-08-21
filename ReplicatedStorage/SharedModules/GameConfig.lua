-- GameConfig.lua
-- Configuración general del juego

local GameConfig = {}

-- Configuración de probabilidades del Gacha
GameConfig.GachaProbabilities = {
    [1] = 0.40, -- COMMON - 40%
    [2] = 0.30, -- UNCOMMON - 30%
    [3] = 0.20, -- RARE - 20%
    [4] = 0.08, -- EPIC - 8%
    [5] = 0.015, -- LEGENDARY - 1.5%
    [6] = 0.005  -- MYTHIC - 0.5%
}

-- Configuración de precios
GameConfig.Prices = {
    GachaPull = {
        FREE = 0,
        PREMIUM = 100,
        SPECIAL = 500
    },
    CharacterSlot = 1000,
    BreedingPass = 2500,
    Skins = {
        COMMON = 500,
        RARE = 1500,
        EPIC = 3000,
        LEGENDARY = 7500
    }
}

-- Configuración de experiencia y niveles
GameConfig.Experience = {
    BaseExpPerLevel = 100,
    ExpMultiplier = 1.2,
    MaxLevel = 100,
    CombatExpBase = 50,
    TrainingExpBase = 25
}

-- Configuración de envejecimiento
GameConfig.Aging = {
    AgeIntervalHours = 24, -- 24 horas reales = 1 año de personaje
    MaxAge = 30,
    RarityBonusPerAge = {
        [1] = 0.001, -- COMMON
        [2] = 0.002, -- UNCOMMON
        [3] = 0.005, -- RARE
        [4] = 0.01,  -- EPIC
        [5] = 0.02,  -- LEGENDARY
        [6] = 0.05   -- MYTHIC
    }
}

-- Configuración de combate
GameConfig.Combat = {
    BaseDamageMultiplier = 0.1,
    CriticalChance = 0.15,
    CriticalMultiplier = 1.5,
    SpeedAdvantageThreshold = 10,
    DefenseReduction = 0.8
}

-- Configuración de entrenamiento
GameConfig.Training = {
    MaxTrainingsPerDay = 5,
    TrainingCooldownMinutes = 30,
    AttributeGainRange = {1, 5},
    TrainingCost = 100
}

-- Configuración de monedas gratuitas
GameConfig.FreeCurrency = {
    DailyTickets = 3,
    DailyCoins = 500,
    LoginBonus = {
        Day1 = {freeTickets = 1, coins = 100},
        Day2 = {freeTickets = 1, coins = 200},
        Day3 = {freeTickets = 2, coins = 300},
        Day4 = {freeTickets = 2, coins = 400},
        Day5 = {freeTickets = 3, coins = 500},
        Day6 = {freeTickets = 3, coins = 750},
        Day7 = {freeTickets = 5, coins = 1000, premiumCurrency = 100}
    }
}

-- Base de datos de nombres y series de anime
GameConfig.AnimeDatabase = {
    MaleNames = {
        "Naruto", "Sasuke", "Ichigo", "Natsu", "Luffy", "Goku", "Vegeta",
        "Edward", "Alphonse", "Roy", "Levi", "Eren", "Armin", "Kirito",
        "Asuna", "Klein", "Sinon", "Tanjiro", "Zenitsu", "Inosuke"
    },
    FemaleNames = {
        "Sakura", "Hinata", "Rukia", "Orihime", "Lucy", "Erza", "Wendy",
        "Nami", "Robin", "Hancock", "Chi-Chi", "Bulma", "Android 18",
        "Winry", "Riza", "Mikasa", "Historia", "Asuna", "Silica", "Nezuko"
    },
    Series = {
        "Naruto", "Bleach", "One Piece", "Dragon Ball", "Attack on Titan",
        "Fullmetal Alchemist", "Sword Art Online", "Demon Slayer",
        "Fairy Tail", "My Hero Academia", "Hunter x Hunter", "Death Note",
        "Code Geass", "Evangelion", "Cowboy Bebop", "One Punch Man"
    }
}

-- Configuración de personalidades por serie
GameConfig.PersonalityByRarity = {
    [1] = {"SHY", "CHEERFUL"}, -- COMMON
    [2] = {"CONFIDENT", "PLAYFUL"}, -- UNCOMMON
    [3] = {"TSUNDERE", "PROTECTIVE"}, -- RARE
    [4] = {"KUUDERE", "MYSTERIOUS"}, -- EPIC
    [5] = {"DANDERE", "YANDERE"}, -- LEGENDARY
    [6] = {"YANDERE"} -- MYTHIC (solo yandere para máxima rareza)
}

return GameConfig