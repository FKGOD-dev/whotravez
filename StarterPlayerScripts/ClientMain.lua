-- ClientMain.lua
-- Script principal del cliente que inicializa la UI y maneja eventos

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Esperar a que los módulos estén disponibles
local CharacterTypes = require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("CharacterTypes"))
local GameConfig = require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("GameConfig"))
local Utilities = require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Utilities"))

-- Crear UI principal
local function createMainUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WaifuHusbandoGame"
    screenGui.Parent = playerGui
    screenGui.DisplayOrder = 100
    
    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.Position = UDim2.new(0, 0, 0, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.Parent = screenGui
    
    -- Barra superior
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 80)
    topBar.Position = UDim2.new(0, 0, 0, 0)
    topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    topBar.Parent = mainFrame
    
    -- Título del juego
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(0, 300, 1, 0)
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Waifu & Husbando Collection"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = topBar
    
    -- Panel de monedas
    local currencyPanel = Instance.new("Frame")
    currencyPanel.Name = "CurrencyPanel"
    currencyPanel.Size = UDim2.new(0, 400, 0, 60)
    currencyPanel.Position = UDim2.new(1, -420, 0, 10)
    currencyPanel.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    currencyPanel.BorderSizePixel = 0
    currencyPanel.Parent = topBar
    
    -- Crear esquinas redondeadas
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = currencyPanel
    
    -- Indicadores de moneda
    local coinLabel = Instance.new("TextLabel")
    coinLabel.Name = "CoinLabel"
    coinLabel.Size = UDim2.new(0.33, -5, 1, 0)
    coinLabel.Position = UDim2.new(0, 5, 0, 0)
    coinLabel.BackgroundTransparency = 1
    coinLabel.Text = "💰 0"
    coinLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    coinLabel.TextScaled = true
    coinLabel.Font = Enum.Font.SourceSansBold
    coinLabel.Parent = currencyPanel
    
    local ticketLabel = Instance.new("TextLabel")
    ticketLabel.Name = "TicketLabel"
    ticketLabel.Size = UDim2.new(0.33, -5, 1, 0)
    ticketLabel.Position = UDim2.new(0.33, 5, 0, 0)
    ticketLabel.BackgroundTransparency = 1
    ticketLabel.Text = "🎫 0"
    ticketLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
    ticketLabel.TextScaled = true
    ticketLabel.Font = Enum.Font.SourceSansBold
    ticketLabel.Parent = currencyPanel
    
    local premiumLabel = Instance.new("TextLabel")
    premiumLabel.Name = "PremiumLabel"
    premiumLabel.Size = UDim2.new(0.33, -5, 1, 0)
    premiumLabel.Position = UDim2.new(0.66, 5, 0, 0)
    premiumLabel.BackgroundTransparency = 1
    premiumLabel.Text = "💎 0"
    premiumLabel.TextColor3 = Color3.fromRGB(255, 0, 255)
    premiumLabel.TextScaled = true
    premiumLabel.Font = Enum.Font.SourceSansBold
    premiumLabel.Parent = currencyPanel
    
    -- Panel de navegación
    local navPanel = Instance.new("Frame")
    navPanel.Name = "NavPanel"
    navPanel.Size = UDim2.new(0, 200, 1, -80)
    navPanel.Position = UDim2.new(0, 0, 0, 80)
    navPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    navPanel.Parent = mainFrame
    
    -- Botones de navegación
    local navButtons = {
        {name = "Collection", text = "📚 Colección", icon = "📚"},
        {name = "Gacha", text = "🎰 Gacha", icon = "🎰"},
        {name = "Battle", text = "⚔️ Batalla", icon = "⚔️"},
        {name = "Training", text = "💪 Entrenamiento", icon = "💪"},
        {name = "Shop", text = "🛒 Tienda", icon = "🛒"},
        {name = "Settings", text = "⚙️ Configuración", icon = "⚙️"}
    }
    
    for i, buttonData in ipairs(navButtons) do
        local button = Instance.new("TextButton")
        button.Name = buttonData.name .. "Button"
        button.Size = UDim2.new(1, -10, 0, 60)
        button.Position = UDim2.new(0, 5, 0, (i-1) * 70 + 10)
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        button.Text = buttonData.text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextScaled = true
        button.Font = Enum.Font.SourceSans
        button.Parent = navPanel
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
        buttonCorner.Parent = button
        
        -- Efectos hover
        button.MouseEnter:Connect(function()
            local tween = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 90)})
            tween:Play()
        end)
        
        button.MouseLeave:Connect(function()
            local tween = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 70)})
            tween:Play()
        end)
    end
    
    -- Panel de contenido principal
    local contentPanel = Instance.new("Frame")
    contentPanel.Name = "ContentPanel"
    contentPanel.Size = UDim2.new(1, -200, 1, -80)
    contentPanel.Position = UDim2.new(0, 200, 0, 80)
    contentPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    contentPanel.Parent = mainFrame
    
    return screenGui, {
        mainFrame = mainFrame,
        topBar = topBar,
        currencyPanel = currencyPanel,
        navPanel = navPanel,
        contentPanel = contentPanel,
        coinLabel = coinLabel,
        ticketLabel = ticketLabel,
        premiumLabel = premiumLabel
    }
end

-- Actualizar indicadores de moneda
local function updateCurrencyDisplay(currency, ui)
    if currency then
        ui.coinLabel.Text = "💰 " .. tostring(currency.coins or 0)
        ui.ticketLabel.Text = "🎫 " .. tostring(currency.freeTickets or 0)
        ui.premiumLabel.Text = "💎 " .. tostring(currency.premiumCurrency or 0)
    end
end

-- Crear panel de gacha
local function createGachaPanel(parent)
    local gachaFrame = Instance.new("ScrollingFrame")
    gachaFrame.Name = "GachaFrame"
    gachaFrame.Size = UDim2.new(1, -20, 1, -20)
    gachaFrame.Position = UDim2.new(0, 10, 0, 10)
    gachaFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    gachaFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
    gachaFrame.ScrollBarThickness = 10
    gachaFrame.Parent = parent
    gachaFrame.Visible = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = gachaFrame
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "🎰 Sistema Gacha"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = gachaFrame
    
    -- Panel de probabilidades
    local probPanel = Instance.new("Frame")
    probPanel.Name = "ProbabilityPanel"
    probPanel.Size = UDim2.new(1, -20, 0, 200)
    probPanel.Position = UDim2.new(0, 10, 0, 70)
    probPanel.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    probPanel.Parent = gachaFrame
    
    local probCorner = Instance.new("UICorner")
    probCorner.CornerRadius = UDim.new(0, 10)
    probCorner.Parent = probPanel
    
    -- Mostrar probabilidades
    local rarityNames = {"Común", "No Común", "Raro", "Épico", "Legendario", "Mítico"}
    local rarityColors = {
        Color3.fromRGB(169, 169, 169), -- Gris - Común
        Color3.fromRGB(30, 255, 0),   -- Verde - No Común
        Color3.fromRGB(0, 112, 255),  -- Azul - Raro
        Color3.fromRGB(163, 53, 238), -- Púrpura - Épico
        Color3.fromRGB(255, 128, 0),  -- Naranja - Legendario
        Color3.fromRGB(255, 215, 0)   -- Dorado - Mítico
    }
    
    for i = 1, 6 do
        local probLabel = Instance.new("TextLabel")
        probLabel.Name = "Prob" .. i
        probLabel.Size = UDim2.new(0.5, -10, 0, 30)
        probLabel.Position = UDim2.new((i-1) % 2 == 0 and 0 or 0.5, 5, 0, 10 + math.floor((i-1) / 2) * 35)
        probLabel.BackgroundTransparency = 1
        probLabel.Text = rarityNames[i] .. ": " .. string.format("%.1f%%", (GameConfig.GachaProbabilities[i] * 100))
        probLabel.TextColor3 = rarityColors[i]
        probLabel.TextScaled = true
        probLabel.Font = Enum.Font.SourceSans
        probLabel.Parent = probPanel
    end
    
    -- Botones de gacha
    local singlePullBtn = Instance.new("TextButton")
    singlePullBtn.Name = "SinglePullButton"
    singlePullBtn.Size = UDim2.new(0.45, 0, 0, 60)
    singlePullBtn.Position = UDim2.new(0.05, 0, 0, 300)
    singlePullBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    singlePullBtn.Text = "Pull Individual\n(1 Ticket)"
    singlePullBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    singlePullBtn.TextScaled = true
    singlePullBtn.Font = Enum.Font.SourceSansBold
    singlePullBtn.Parent = gachaFrame
    
    local singleCorner = Instance.new("UICorner")
    singleCorner.CornerRadius = UDim.new(0, 10)
    singleCorner.Parent = singlePullBtn
    
    local multiPullBtn = Instance.new("TextButton")
    multiPullBtn.Name = "MultiPullButton"
    multiPullBtn.Size = UDim2.new(0.45, 0, 0, 60)
    multiPullBtn.Position = UDim2.new(0.5, 0, 0, 300)
    multiPullBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    multiPullBtn.Text = "Pull x10\n(10 Tickets + 1 Gratis)"
    multiPullBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    multiPullBtn.TextScaled = true
    multiPullBtn.Font = Enum.Font.SourceSansBold
    multiPullBtn.Parent = gachaFrame
    
    local multiCorner = Instance.new("UICorner")
    multiCorner.CornerRadius = UDim.new(0, 10)
    multiCorner.Parent = multiPullBtn
    
    return gachaFrame, singlePullBtn, multiPullBtn
end

-- Crear panel de colección
local function createCollectionPanel(parent)
    local collectionFrame = Instance.new("ScrollingFrame")
    collectionFrame.Name = "CollectionFrame"
    collectionFrame.Size = UDim2.new(1, -20, 1, -20)
    collectionFrame.Position = UDim2.new(0, 10, 0, 10)
    collectionFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    collectionFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    collectionFrame.ScrollBarThickness = 10
    collectionFrame.Parent = parent
    collectionFrame.Visible = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = collectionFrame
    
    -- Barra de búsqueda
    local searchFrame = Instance.new("Frame")
    searchFrame.Name = "SearchFrame"
    searchFrame.Size = UDim2.new(1, -20, 0, 80)
    searchFrame.Position = UDim2.new(0, 10, 0, 10)
    searchFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    searchFrame.Parent = collectionFrame
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 10)
    searchCorner.Parent = searchFrame
    
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(0.6, -10, 0, 40)
    searchBox.Position = UDim2.new(0, 10, 0, 10)
    searchBox.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    searchBox.Text = ""
    searchBox.PlaceholderText = "Buscar personajes..."
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.TextScaled = true
    searchBox.Font = Enum.Font.SourceSans
    searchBox.Parent = searchFrame
    
    local searchBoxCorner = Instance.new("UICorner")
    searchBoxCorner.CornerRadius = UDim.new(0, 8)
    searchBoxCorner.Parent = searchBox
    
    -- Filtros de rareza
    local filterFrame = Instance.new("Frame")
    filterFrame.Name = "FilterFrame"
    filterFrame.Size = UDim2.new(0.4, -10, 0, 60)
    filterFrame.Position = UDim2.new(0.6, 10, 0, 10)
    filterFrame.BackgroundTransparency = 1
    filterFrame.Parent = searchFrame
    
    local rarityFilters = {}
    local rarityColors = {
        Color3.fromRGB(169, 169, 169), -- Común
        Color3.fromRGB(30, 255, 0),   -- No Común
        Color3.fromRGB(0, 112, 255),  -- Raro
        Color3.fromRGB(163, 53, 238), -- Épico
        Color3.fromRGB(255, 128, 0),  -- Legendario
        Color3.fromRGB(255, 215, 0)   -- Mítico
    }
    
    for i = 1, 6 do
        local filterBtn = Instance.new("TextButton")
        filterBtn.Name = "RarityFilter" .. i
        filterBtn.Size = UDim2.new(1/6, -2, 0, 25)
        filterBtn.Position = UDim2.new((i-1)/6, 1, 0, 5)
        filterBtn.BackgroundColor3 = rarityColors[i]
        filterBtn.Text = string.rep("★", i)
        filterBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        filterBtn.TextScaled = true
        filterBtn.Font = Enum.Font.SourceSansBold
        filterBtn.Parent = filterFrame
        
        local filterCorner = Instance.new("UICorner")
        filterCorner.CornerRadius = UDim.new(0, 4)
        filterCorner.Parent = filterBtn
        
        rarityFilters[i] = {button = filterBtn, active = true}
    end
    
    local sortDropdown = Instance.new("TextButton")
    sortDropdown.Name = "SortDropdown"
    sortDropdown.Size = UDim2.new(0.4, -10, 0, 25)
    sortDropdown.Position = UDim2.new(0.6, 10, 0, 35)
    sortDropdown.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    sortDropdown.Text = "Ordenar por: Rareza"
    sortDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    sortDropdown.TextScaled = true
    sortDropdown.Font = Enum.Font.SourceSans
    sortDropdown.Parent = searchFrame
    
    local sortCorner = Instance.new("UICorner")
    sortCorner.CornerRadius = UDim.new(0, 4)
    sortCorner.Parent = sortDropdown
    
    -- Grid de personajes
    local charactersGrid = Instance.new("Frame")
    charactersGrid.Name = "CharactersGrid"
    charactersGrid.Size = UDim2.new(1, -20, 1, -110)
    charactersGrid.Position = UDim2.new(0, 10, 0, 100)
    charactersGrid.BackgroundTransparency = 1
    charactersGrid.Parent = collectionFrame
    
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0, 180, 0, 220)
    gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.Parent = charactersGrid
    
    return collectionFrame, searchBox, rarityFilters, sortDropdown, charactersGrid
end

-- Crear tarjeta de personaje
local function createCharacterCard(character, parent)
    local card = Instance.new("Frame")
    card.Name = "CharacterCard_" .. character.id
    card.Size = UDim2.new(0, 180, 0, 220)
    card.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    card.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = card
    
    -- Border de rareza
    local rarityBorder = Instance.new("UIStroke")
    rarityBorder.Thickness = 3
    local rarityColors = {
        [1] = Color3.fromRGB(169, 169, 169),
        [2] = Color3.fromRGB(30, 255, 0),
        [3] = Color3.fromRGB(0, 112, 255),
        [4] = Color3.fromRGB(163, 53, 238),
        [5] = Color3.fromRGB(255, 128, 0),
        [6] = Color3.fromRGB(255, 215, 0)
    }
    rarityBorder.Color = rarityColors[character.rarity] or Color3.fromRGB(169, 169, 169)
    rarityBorder.Parent = card
    
    -- Imagen placeholder
    local imageFrame = Instance.new("Frame")
    imageFrame.Name = "ImageFrame"
    imageFrame.Size = UDim2.new(1, -10, 0, 120)
    imageFrame.Position = UDim2.new(0, 5, 0, 5)
    imageFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    imageFrame.Parent = card
    
    local imageCorner = Instance.new("UICorner")
    imageCorner.CornerRadius = UDim.new(0, 8)
    imageCorner.Parent = imageFrame
    
    local placeholderIcon = Instance.new("TextLabel")
    placeholderIcon.Size = UDim2.new(1, 0, 1, 0)
    placeholderIcon.BackgroundTransparency = 1
    placeholderIcon.Text = character.gender == "MALE" and "👨" or "👩"
    placeholderIcon.TextColor3 = Color3.fromRGB(200, 200, 200)
    placeholderIcon.TextScaled = true
    placeholderIcon.Font = Enum.Font.SourceSans
    placeholderIcon.Parent = imageFrame
    
    -- Nombre del personaje
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, -10, 0, 25)
    nameLabel.Position = UDim2.new(0, 5, 0, 130)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = character.name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.Parent = card
    
    -- Serie
    local seriesLabel = Instance.new("TextLabel")
    seriesLabel.Name = "SeriesLabel"
    seriesLabel.Size = UDim2.new(1, -10, 0, 20)
    seriesLabel.Position = UDim2.new(0, 5, 0, 155)
    seriesLabel.BackgroundTransparency = 1
    seriesLabel.Text = character.series
    seriesLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    seriesLabel.TextScaled = true
    seriesLabel.Font = Enum.Font.SourceSans
    seriesLabel.Parent = card
    
    -- Rareza
    local rarityLabel = Instance.new("TextLabel")
    rarityLabel.Name = "RarityLabel"
    rarityLabel.Size = UDim2.new(1, -10, 0, 20)
    rarityLabel.Position = UDim2.new(0, 5, 0, 175)
    rarityLabel.BackgroundTransparency = 1
    rarityLabel.Text = string.rep("★", character.rarity)
    rarityLabel.TextColor3 = rarityColors[character.rarity] or Color3.fromRGB(169, 169, 169)
    rarityLabel.TextScaled = true
    rarityLabel.Font = Enum.Font.SourceSansBold
    rarityLabel.Parent = card
    
    -- Nivel y edad
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "StatsLabel"
    statsLabel.Size = UDim2.new(1, -10, 0, 20)
    statsLabel.Position = UDim2.new(0, 5, 0, 195)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = string.format("Lv.%d | %d años", character.level or 1, character.age or 16)
    statsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    statsLabel.TextScaled = true
    statsLabel.Font = Enum.Font.SourceSans
    statsLabel.Parent = card
    
    -- Botón para ver detalles
    local detailsBtn = Instance.new("TextButton")
    detailsBtn.Name = "DetailsButton"
    detailsBtn.Size = UDim2.new(1, -10, 1, -10)
    detailsBtn.Position = UDim2.new(0, 5, 0, 5)
    detailsBtn.BackgroundTransparency = 1
    detailsBtn.Text = ""
    detailsBtn.Parent = card
    
    return card, detailsBtn
end

-- Crear panel de batalla completo
local function createBattlePanel(parent)
    local battleFrame = Instance.new("ScrollingFrame")
    battleFrame.Name = "BattleFrame"
    battleFrame.Size = UDim2.new(1, -20, 1, -20)
    battleFrame.Position = UDim2.new(0, 10, 0, 10)
    battleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    battleFrame.CanvasSize = UDim2.new(0, 0, 0, 1200)
    battleFrame.ScrollBarThickness = 10
    battleFrame.Parent = parent
    battleFrame.Visible = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = battleFrame
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "⚔️ Sistema de Batalla"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = battleFrame
    
    -- Panel de selección de equipo
    local teamPanel = Instance.new("Frame")
    teamPanel.Name = "TeamSelectionPanel"
    teamPanel.Size = UDim2.new(1, -20, 0, 300)
    teamPanel.Position = UDim2.new(0, 10, 0, 70)
    teamPanel.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    teamPanel.Parent = battleFrame
    
    local teamCorner = Instance.new("UICorner")
    teamCorner.CornerRadius = UDim.new(0, 10)
    teamCorner.Parent = teamPanel
    
    local teamTitle = Instance.new("TextLabel")
    teamTitle.Name = "TeamTitle"
    teamTitle.Size = UDim2.new(1, 0, 0, 40)
    teamTitle.Position = UDim2.new(0, 0, 0, 5)
    teamTitle.BackgroundTransparency = 1
    teamTitle.Text = "Seleccionar Equipo de Batalla (Máximo 5)"
    teamTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    teamTitle.TextScaled = true
    teamTitle.Font = Enum.Font.SourceSansBold
    teamTitle.Parent = teamPanel
    
    -- Slots de equipo
    local teamSlots = {}\n    for i = 1, 5 do\n        local slot = Instance.new(\"Frame\")\n        slot.Name = \"TeamSlot\" .. i\n        slot.Size = UDim2.new(0, 120, 0, 140)\n        slot.Position = UDim2.new(0, 20 + (i-1) * 130, 0, 50)\n        slot.BackgroundColor3 = Color3.fromRGB(70, 70, 90)\n        slot.Parent = teamPanel\n        \n        local slotCorner = Instance.new(\"UICorner\")\n        slotCorner.CornerRadius = UDim.new(0, 8)\n        slotCorner.Parent = slot\n        \n        local slotLabel = Instance.new(\"TextLabel\")\n        slotLabel.Size = UDim2.new(1, 0, 0, 30)\n        slotLabel.Position = UDim2.new(0, 0, 0, 5)\n        slotLabel.BackgroundTransparency = 1\n        slotLabel.Text = \"Slot \" .. i\n        slotLabel.TextColor3 = Color3.fromRGB(200, 200, 200)\n        slotLabel.TextScaled = true\n        slotLabel.Font = Enum.Font.SourceSans\n        slotLabel.Parent = slot\n        \n        local emptyIcon = Instance.new(\"TextLabel\")\n        emptyIcon.Name = \"EmptyIcon\"\n        emptyIcon.Size = UDim2.new(1, -10, 1, -40)\n        emptyIcon.Position = UDim2.new(0, 5, 0, 35)\n        emptyIcon.BackgroundTransparency = 1\n        emptyIcon.Text = \"➕\"\n        emptyIcon.TextColor3 = Color3.fromRGB(150, 150, 150)\n        emptyIcon.TextScaled = true\n        emptyIcon.Font = Enum.Font.SourceSans\n        emptyIcon.Parent = slot\n        \n        local selectBtn = Instance.new(\"TextButton\")\n        selectBtn.Name = \"SelectButton\"\n        selectBtn.Size = UDim2.new(1, 0, 1, 0)\n        selectBtn.BackgroundTransparency = 1\n        selectBtn.Text = \"\"\n        selectBtn.Parent = slot\n        \n        teamSlots[i] = {frame = slot, button = selectBtn, character = nil}\n    end\n    \n    -- Panel de estadísticas del equipo\n    local statsPanel = Instance.new(\"Frame\")\n    statsPanel.Name = \"TeamStatsPanel\"\n    statsPanel.Size = UDim2.new(1, -20, 0, 120)\n    statsPanel.Position = UDim2.new(0, 10, 0, 200)\n    statsPanel.BackgroundColor3 = Color3.fromRGB(50, 50, 65)\n    statsPanel.Parent = teamPanel\n    \n    local statsCorner = Instance.new(\"UICorner\")\n    statsCorner.CornerRadius = UDim.new(0, 8)\n    statsCorner.Parent = statsPanel\n    \n    local statsTitle = Instance.new(\"TextLabel\")\n    statsTitle.Size = UDim2.new(1, 0, 0, 25)\n    statsTitle.Position = UDim2.new(0, 0, 0, 5)\n    statsTitle.BackgroundTransparency = 1\n    statsTitle.Text = \"Estadísticas del Equipo\"\n    statsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)\n    statsTitle.TextScaled = true\n    statsTitle.Font = Enum.Font.SourceSansBold\n    statsTitle.Parent = statsPanel\n    \n    -- Estadísticas\n    local statLabels = {\"Poder Total:\", \"ATK Promedio:\", \"DEF Promedio:\", \"HP Total:\", \"Velocidad Promedio:\"}\n    for i, label in ipairs(statLabels) do\n        local statFrame = Instance.new(\"Frame\")\n        statFrame.Size = UDim2.new(0.2, -5, 0, 20)\n        statFrame.Position = UDim2.new((i-1)*0.2, 2, 0, 35)\n        statFrame.BackgroundTransparency = 1\n        statFrame.Parent = statsPanel\n        \n        local statLabel = Instance.new(\"TextLabel\")\n        statLabel.Size = UDim2.new(1, 0, 0.5, 0)\n        statLabel.Position = UDim2.new(0, 0, 0, 0)\n        statLabel.BackgroundTransparency = 1\n        statLabel.Text = label\n        statLabel.TextColor3 = Color3.fromRGB(180, 180, 180)\n        statLabel.TextScaled = true\n        statLabel.Font = Enum.Font.SourceSans\n        statLabel.Parent = statFrame\n        \n        local statValue = Instance.new(\"TextLabel\")\n        statValue.Name = \"StatValue\" .. i\n        statValue.Size = UDim2.new(1, 0, 0.5, 0)\n        statValue.Position = UDim2.new(0, 0, 0.5, 0)\n        statValue.BackgroundTransparency = 1\n        statValue.Text = \"0\"\n        statValue.TextColor3 = Color3.fromRGB(255, 255, 255)\n        statValue.TextScaled = true\n        statValue.Font = Enum.Font.SourceSansBold\n        statValue.Parent = statFrame\n    end\n    \n    -- Panel de modos de batalla\n    local battleModesPanel = Instance.new(\"Frame\")\n    battleModesPanel.Name = \"BattleModesPanel\"\n    battleModesPanel.Size = UDim2.new(1, -20, 0, 250)\n    battleModesPanel.Position = UDim2.new(0, 10, 0, 390)\n    battleModesPanel.BackgroundColor3 = Color3.fromRGB(55, 55, 75)\n    battleModesPanel.Parent = battleFrame\n    \n    local modesCorner = Instance.new(\"UICorner\")\n    modesCorner.CornerRadius = UDim.new(0, 10)\n    modesCorner.Parent = battleModesPanel\n    \n    local modesTitle = Instance.new(\"TextLabel\")\n    modesTitle.Size = UDim2.new(1, 0, 0, 40)\n    modesTitle.Position = UDim2.new(0, 0, 0, 5)\n    modesTitle.BackgroundTransparency = 1\n    modesTitle.Text = \"Modos de Batalla\"\n    modesTitle.TextColor3 = Color3.fromRGB(255, 255, 255)\n    modesTitle.TextScaled = true\n    modesTitle.Font = Enum.Font.SourceSansBold\n    modesTitle.Parent = battleModesPanel\n    \n    -- Botones de modo de batalla\n    local battleModes = {\n        {name = \"PvE Fácil\", difficulty = 0, color = Color3.fromRGB(50, 200, 50)},\n        {name = \"PvE Normal\", difficulty = 1, color = Color3.fromRGB(200, 200, 50)},\n        {name = \"PvE Difícil\", difficulty = 2, color = Color3.fromRGB(200, 100, 50)},\n        {name = \"PvE Extremo\", difficulty = 3, color = Color3.fromRGB(200, 50, 50)}\n    }\n    \n    local battleButtons = {}\n    for i, mode in ipairs(battleModes) do\n        local modeBtn = Instance.new(\"TextButton\")\n        modeBtn.Name = \"BattleMode\" .. i\n        modeBtn.Size = UDim2.new(0.23, 0, 0, 80)\n        modeBtn.Position = UDim2.new((i-1)*0.25, 10, 0, 60)\n        modeBtn.BackgroundColor3 = mode.color\n        modeBtn.Text = mode.name .. \"\\n\\nIniciar Batalla\"\n        modeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)\n        modeBtn.TextScaled = true\n        modeBtn.Font = Enum.Font.SourceSansBold\n        modeBtn.Parent = battleModesPanel\n        \n        local btnCorner = Instance.new(\"UICorner\")\n        btnCorner.CornerRadius = UDim.new(0, 8)\n        btnCorner.Parent = modeBtn\n        \n        battleButtons[i] = {button = modeBtn, difficulty = mode.difficulty}\n    end\n    \n    -- Panel de historial de batallas\n    local historyPanel = Instance.new(\"Frame\")\n    historyPanel.Name = \"BattleHistoryPanel\"\n    historyPanel.Size = UDim2.new(1, -20, 0, 200)\n    historyPanel.Position = UDim2.new(0, 10, 0, 660)\n    historyPanel.BackgroundColor3 = Color3.fromRGB(55, 55, 75)\n    historyPanel.Parent = battleFrame\n    \n    local historyCorner = Instance.new(\"UICorner\")\n    historyCorner.CornerRadius = UDim.new(0, 10)\n    historyCorner.Parent = historyPanel\n    \n    local historyTitle = Instance.new(\"TextLabel\")\n    historyTitle.Size = UDim2.new(1, 0, 0, 30)\n    historyTitle.Position = UDim2.new(0, 0, 0, 5)\n    historyTitle.BackgroundTransparency = 1\n    historyTitle.Text = \"Historial de Batallas Recientes\"\n    historyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)\n    historyTitle.TextScaled = true\n    historyTitle.Font = Enum.Font.SourceSansBold\n    historyTitle.Parent = historyPanel\n    \n    local historyList = Instance.new(\"ScrollingFrame\")\n    historyList.Name = \"HistoryList\"\n    historyList.Size = UDim2.new(1, -20, 1, -50)\n    historyList.Position = UDim2.new(0, 10, 0, 40)\n    historyList.BackgroundTransparency = 1\n    historyList.CanvasSize = UDim2.new(0, 0, 0, 0)\n    historyList.ScrollBarThickness = 5\n    historyList.Parent = historyPanel\n    \n    local historyLayout = Instance.new(\"UIListLayout\")\n    historyLayout.SortOrder = Enum.SortOrder.LayoutOrder\n    historyLayout.Padding = UDim.new(0, 5)\n    historyLayout.Parent = historyList\n    \n    return battleFrame, teamSlots, battleButtons, statsPanel, historyList\nend

local function createTrainingPanel(parent)
    local trainingFrame = Instance.new("ScrollingFrame")
    trainingFrame.Name = "TrainingFrame"
    trainingFrame.Size = UDim2.new(1, -20, 1, -20)
    trainingFrame.Position = UDim2.new(0, 10, 0, 10)
    trainingFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    trainingFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
    trainingFrame.ScrollBarThickness = 10
    trainingFrame.Parent = parent
    trainingFrame.Visible = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = trainingFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "💪 Sistema de Entrenamiento"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = trainingFrame
    
    return trainingFrame
end

local function createShopPanel(parent)
    local shopFrame = Instance.new("ScrollingFrame")
    shopFrame.Name = "ShopFrame"
    shopFrame.Size = UDim2.new(1, -20, 1, -20)
    shopFrame.Position = UDim2.new(0, 10, 0, 10)
    shopFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    shopFrame.CanvasSize = UDim2.new(0, 0, 0, 1200)
    shopFrame.ScrollBarThickness = 10
    shopFrame.Parent = parent
    shopFrame.Visible = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = shopFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "🛒 Tienda"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = shopFrame
    
    return shopFrame
end

-- Mostrar resultado de gacha
local function showGachaResult(character, isNew)
    local resultGui = Instance.new("ScreenGui")
    resultGui.Name = "GachaResult"
    resultGui.Parent = playerGui
    resultGui.DisplayOrder = 200
    
    local backdrop = Instance.new("Frame")
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 0.5
    backdrop.Parent = resultGui
    
    local resultFrame = Instance.new("Frame")
    resultFrame.Size = UDim2.new(0, 400, 0, 500)
    resultFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    resultFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    resultFrame.Parent = resultGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = resultFrame
    
    -- Efecto de aparición
    resultFrame.Size = UDim2.new(0, 0, 0, 0)
    local tween = TweenService:Create(resultFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0, 400, 0, 500)})
    tween:Play()
    
    -- Contenido del resultado
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -20, 0, 50)
    nameLabel.Position = UDim2.new(0, 10, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = character.name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.Parent = resultFrame
    
    local seriesLabel = Instance.new("TextLabel")
    seriesLabel.Size = UDim2.new(1, -20, 0, 30)
    seriesLabel.Position = UDim2.new(0, 10, 0, 60)
    seriesLabel.BackgroundTransparency = 1
    seriesLabel.Text = "De: " .. character.series
    seriesLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    seriesLabel.TextScaled = true
    seriesLabel.Font = Enum.Font.SourceSans
    seriesLabel.Parent = resultFrame
    
    local rarityColors = {
        [1] = Color3.fromRGB(169, 169, 169),
        [2] = Color3.fromRGB(30, 255, 0),
        [3] = Color3.fromRGB(0, 112, 255),
        [4] = Color3.fromRGB(163, 53, 238),
        [5] = Color3.fromRGB(255, 128, 0),
        [6] = Color3.fromRGB(255, 215, 0)
    }
    
    local rarityLabel = Instance.new("TextLabel")
    rarityLabel.Size = UDim2.new(1, -20, 0, 40)
    rarityLabel.Position = UDim2.new(0, 10, 0, 100)
    rarityLabel.BackgroundTransparency = 1
    rarityLabel.Text = "⭐ " .. string.rep("★", character.rarity)
    rarityLabel.TextColor3 = rarityColors[character.rarity]
    rarityLabel.TextScaled = true
    rarityLabel.Font = Enum.Font.SourceSansBold
    rarityLabel.Parent = resultFrame
    
    if isNew then
        local newLabel = Instance.new("TextLabel")
        newLabel.Size = UDim2.new(1, -20, 0, 30)
        newLabel.Position = UDim2.new(0, 10, 0, 150)
        newLabel.BackgroundTransparency = 1
        newLabel.Text = "🆕 ¡NUEVO!"
        newLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        newLabel.TextScaled = true
        newLabel.Font = Enum.Font.SourceSansBold
        newLabel.Parent = resultFrame
    end
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.8, 0, 0, 50)
    closeBtn.Position = UDim2.new(0.1, 0, 1, -70)
    closeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
    closeBtn.Text = "Continuar"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = resultFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 10)
    closeCorner.Parent = closeBtn
    
    closeBtn.Activated:Connect(function()
        resultGui:Destroy()
    end)
    
    -- Auto-cerrar después de 10 segundos
    game:GetService("Debris"):AddItem(resultGui, 10)
end

-- Inicializar cliente
local function initializeClient()
    local mainGui, uiElements = createMainUI()
    
    -- Conectar eventos remotos
    local eventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
    
    -- Crear todos los paneles
    local collectionPanel, searchBox, rarityFilters, sortDropdown, charactersGrid = createCollectionPanel(uiElements.contentPanel)
    local gachaPanel, singleBtn, multiBtn = createGachaPanel(uiElements.contentPanel)
    local battlePanel = createBattlePanel(uiElements.contentPanel)
    local trainingPanel = createTrainingPanel(uiElements.contentPanel)
    local shopPanel = createShopPanel(uiElements.contentPanel)
    
    -- Estado actual del panel
    local currentPanel = "Collection"
    collectionPanel.Visible = true -- Mostrar colección por defecto
    
    -- Función para cambiar paneles
    local function switchToPanel(panelName)
        -- Ocultar todos los paneles
        collectionPanel.Visible = false
        gachaPanel.Visible = false
        battlePanel.Visible = false
        trainingPanel.Visible = false
        shopPanel.Visible = false
        
        -- Mostrar el panel seleccionado
        if panelName == "Collection" then
            collectionPanel.Visible = true
        elseif panelName == "Gacha" then
            gachaPanel.Visible = true
        elseif panelName == "Battle" then
            battlePanel.Visible = true
        elseif panelName == "Training" then
            trainingPanel.Visible = true
        elseif panelName == "Shop" then
            shopPanel.Visible = true
        end
        
        currentPanel = panelName
    end
    
    -- Conectar botones de navegación
    local navButtons = {
        {name = "Collection", panel = "Collection"},
        {name = "Gacha", panel = "Gacha"},
        {name = "Battle", panel = "Battle"},
        {name = "Training", panel = "Training"},
        {name = "Shop", panel = "Shop"}
    }
    
    for _, buttonData in ipairs(navButtons) do
        local button = uiElements.navPanel:FindFirstChild(buttonData.name .. "Button")
        if button then
            button.Activated:Connect(function()
                switchToPanel(buttonData.panel)
            end)
        end
    end
    
    -- Actualizar moneda cuando cambie
    local currencyUpdated = eventsFolder:WaitForChild("CurrencyUpdated")
    currencyUpdated.OnClientEvent:Connect(function(newCurrency)
        updateCurrencyDisplay(newCurrency, uiElements)
    end)
    
    -- Resultado de gacha
    local gachaPullResult = eventsFolder:WaitForChild("GachaPullResult")
    gachaPullResult.OnClientEvent:Connect(function(result)
        if result and result.character then
            showGachaResult(result.character, result.isNew)
        end
    end)
    
    -- Conectar botones de gacha
    singleBtn.Activated:Connect(function()
        local pullGacha = eventsFolder:WaitForChild("PullGacha")
        pullGacha:InvokeServer("FREE", 1)
    end)
    
    multiBtn.Activated:Connect(function()
        local pullGacha = eventsFolder:WaitForChild("PullGacha")
        pullGacha:InvokeServer("FREE", 10)
    end)
    
    -- Función para cargar y mostrar personajes en la colección
    local function loadCharacterCollection()
        local getPlayerCharacters = eventsFolder:WaitForChild("GetPlayerCharacters")
        local characters = getPlayerCharacters:InvokeServer()
        
        -- Limpiar grid actual
        for _, child in pairs(charactersGrid:GetChildren()) do
            if child:IsA("Frame") and child.Name:match("CharacterCard_") then
                child:Destroy()
            end
        end
        
        -- Crear tarjetas para cada personaje
        if characters then
            for _, character in ipairs(characters) do
                local card, detailsBtn = createCharacterCard(character, charactersGrid)
                
                -- Conectar botón de detalles
                detailsBtn.Activated:Connect(function()
                    print("Showing details for character:", character.name)
                    -- TODO: Implementar ventana de detalles
                end)
            end
        end
        
        -- Ajustar tamaño del canvas
        local gridLayout = charactersGrid:FindFirstChild("UIGridLayout")
        if gridLayout then
            local rows = math.ceil((characters and #characters or 0) / 4) -- 4 columnas aprox
            collectionPanel.CanvasSize = UDim2.new(0, 0, 0, math.max(600, rows * 230 + 120))
        end
    end
    
    -- Cargar colección inicial
    loadCharacterCollection()
    
    -- Obtener moneda inicial
    local getPlayerCurrency = eventsFolder:WaitForChild("GetPlayerCurrency")
    local initialCurrency = getPlayerCurrency:InvokeServer()
    updateCurrencyDisplay(initialCurrency, uiElements)
end

-- Esperar a que el jugador esté completamente cargado
player.CharacterAdded:Wait()
wait(2)

-- Inicializar
initializeClient()