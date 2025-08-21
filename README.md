# Waifu/Husbando Collection Game - Roblox

Sistema de colección de personajes de anime para Roblox con las siguientes características:

## Estructura del Proyecto

```
Scripts/
├── ServerScriptService/
│   ├── CharacterSystem/
│   │   ├── CharacterGenerator.lua
│   │   ├── CharacterDatabase.lua
│   │   └── CharacterAging.lua
│   ├── GachaSystem/
│   │   ├── GachaCore.lua
│   │   ├── ProbabilityManager.lua
│   │   └── TicketManager.lua
│   ├── CombatSystem/
│   │   ├── BattleManager.lua
│   │   ├── AutoCombat.lua
│   │   └── TrainingSystem.lua
│   ├── MonetizationSystem/
│   │   ├── PurchaseHandler.lua
│   │   ├── SlotManager.lua
│   │   └── SkinManager.lua
│   └── DataManager.lua
├── StarterPlayerScripts/
│   ├── ClientMain.lua
│   ├── UI/
│   │   ├── GachaUI.lua
│   │   ├── CharacterUI.lua
│   │   ├── CombatUI.lua
│   │   └── ShopUI.lua
│   └── ClientDataSync.lua
└── ReplicatedStorage/
    ├── Events/
    │   ├── CharacterEvents.lua
    │   ├── GachaEvents.lua
    │   └── CombatEvents.lua
    ├── SharedModules/
    │   ├── CharacterTypes.lua
    │   ├── GameConfig.lua
    │   └── Utilities.lua
    └── Assets/
        ├── CharacterModels/
        └── UI/
```

## Características Principales

1. **Sistema de Colección de Personajes**: Personajes únicos generados por IA
2. **Sistema Gacha**: Obtención aleatoria con probabilidades
3. **Combate Automático**: Batallas basadas en estadísticas
4. **Sistema de Envejecimiento**: Los personajes se vuelven más raros con el tiempo
5. **Monetización**: Slots adicionales, pases de cría, skins

## Instalación

1. Copia los scripts a tu lugar de Roblox Studio
2. Configura los RemoteEvents en ReplicatedStorage
3. Importa los modelos de personajes
4. Configura el DataStore para persistencia de datos