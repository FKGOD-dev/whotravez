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
    
    -- Crear placeholder más elaborado basado en rareza y género
    local placeholderIcon = Instance.new("TextLabel")
    placeholderIcon.Size = UDim2.new(1, 0, 0.7, 0)
    placeholderIcon.Position = UDim2.new(0, 0, 0.15, 0)
    placeholderIcon.BackgroundTransparency = 1
    
    -- Iconos más elaborados basados en género y rareza
    local genderIcons = {
        MALE = {"👨‍💼", "👨‍🎨", "👨‍⚔️", "🤴", "👨‍🚀", "🧙‍♂️"},
        FEMALE = {"👩‍💼", "👩‍🎨", "👩‍⚔️", "👸", "👩‍🚀", "🧙‍♀️"}
    }
    
    local rarityIndex = math.min(character.rarity or 1, 6)
    placeholderIcon.Text = genderIcons[character.gender or "MALE"][rarityIndex]
    placeholderIcon.TextColor3 = rarityColors[character.rarity] or Color3.fromRGB(169, 169, 169)
    placeholderIcon.TextScaled = true
    placeholderIcon.Font = Enum.Font.SourceSans
    placeholderIcon.Parent = imageFrame
    
    -- Agregar efectos de brillo para rarezas altas
    if character.rarity and character.rarity >= 4 then
        local glowEffect = Instance.new("Frame")
        glowEffect.Size = UDim2.new(1, 4, 1, 4)
        glowEffect.Position = UDim2.new(0, -2, 0, -2)
        glowEffect.BackgroundColor3 = rarityColors[character.rarity]
        glowEffect.BackgroundTransparency = 0.8
        glowEffect.Parent = imageFrame
        
        local glowCorner = Instance.new("UICorner")
        glowCorner.CornerRadius = UDim.new(0, 10)
        glowCorner.Parent = glowEffect
        
        -- Animación de pulso para míticos
        if character.rarity == 6 then
            spawn(function()
                while glowEffect.Parent do
                    local pulseTween = TweenService:Create(glowEffect, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                        BackgroundTransparency = 0.5
                    })
                    pulseTween:Play()
                    wait(2)
                end
            end)
        end
    end
    
    -- Agregar patrón de fondo sutil
    local backgroundPattern = Instance.new("Frame")
    backgroundPattern.Size = UDim2.new(1, 0, 1, 0)
    backgroundPattern.Position = UDim2.new(0, 0, 0, 0)
    backgroundPattern.BackgroundColor3 = rarityColors[character.rarity] or Color3.fromRGB(80, 80, 100)
    backgroundPattern.BackgroundTransparency = 0.9
    backgroundPattern.Parent = imageFrame
    backgroundPattern.ZIndex = -1
    
    local patternCorner = Instance.new("UICorner")
    patternCorner.CornerRadius = UDim.new(0, 8)
    patternCorner.Parent = backgroundPattern
    
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
    local teamSlots = {}
    for i = 1, 5 do
        local slot = Instance.new("Frame")
        slot.Name = "TeamSlot" .. i
        slot.Size = UDim2.new(0, 120, 0, 140)
        slot.Position = UDim2.new(0, 20 + (i-1) * 130, 0, 50)
        slot.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
        slot.Parent = teamPanel
        
        local slotCorner = Instance.new("UICorner")
        slotCorner.CornerRadius = UDim.new(0, 8)
        slotCorner.Parent = slot
        
        local slotLabel = Instance.new("TextLabel")
        slotLabel.Size = UDim2.new(1, 0, 0, 30)
        slotLabel.Position = UDim2.new(0, 0, 0, 5)
        slotLabel.BackgroundTransparency = 1
        slotLabel.Text = "Slot " .. i
        slotLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        slotLabel.TextScaled = true
        slotLabel.Font = Enum.Font.SourceSans
        slotLabel.Parent = slot
        
        local emptyIcon = Instance.new("TextLabel")
        emptyIcon.Name = "EmptyIcon"
        emptyIcon.Size = UDim2.new(1, -10, 1, -40)
        emptyIcon.Position = UDim2.new(0, 5, 0, 35)
        emptyIcon.BackgroundTransparency = 1
        emptyIcon.Text = "➕"
        emptyIcon.TextColor3 = Color3.fromRGB(150, 150, 150)
        emptyIcon.TextScaled = true
        emptyIcon.Font = Enum.Font.SourceSans
        emptyIcon.Parent = slot
        
        local selectBtn = Instance.new("TextButton")
        selectBtn.Name = "SelectButton"
        selectBtn.Size = UDim2.new(1, 0, 1, 0)
        selectBtn.BackgroundTransparency = 1
        selectBtn.Text = ""
        selectBtn.Parent = slot
        
        teamSlots[i] = {frame = slot, button = selectBtn, character = nil, emptyIcon = emptyIcon, slotLabel = slotLabel}
    end
    
    -- Panel de estadísticas del equipo
    local statsPanel = Instance.new("Frame")\n    statsPanel.Name = \"TeamStatsPanel\"\n    statsPanel.Size = UDim2.new(1, -20, 0, 120)\n    statsPanel.Position = UDim2.new(0, 10, 0, 200)\n    statsPanel.BackgroundColor3 = Color3.fromRGB(50, 50, 65)\n    statsPanel.Parent = teamPanel\n    \n    local statsCorner = Instance.new(\"UICorner\")\n    statsCorner.CornerRadius = UDim.new(0, 8)\n    statsCorner.Parent = statsPanel\n    \n    local statsTitle = Instance.new(\"TextLabel\")\n    statsTitle.Size = UDim2.new(1, 0, 0, 25)\n    statsTitle.Position = UDim2.new(0, 0, 0, 5)\n    statsTitle.BackgroundTransparency = 1\n    statsTitle.Text = \"Estadísticas del Equipo\"\n    statsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)\n    statsTitle.TextScaled = true\n    statsTitle.Font = Enum.Font.SourceSansBold\n    statsTitle.Parent = statsPanel\n    \n    -- Estadísticas\n    local statLabels = {\"Poder Total:\", \"ATK Promedio:\", \"DEF Promedio:\", \"HP Total:\", \"Velocidad Promedio:\"}\n    for i, label in ipairs(statLabels) do\n        local statFrame = Instance.new(\"Frame\")\n        statFrame.Size = UDim2.new(0.2, -5, 0, 20)\n        statFrame.Position = UDim2.new((i-1)*0.2, 2, 0, 35)\n        statFrame.BackgroundTransparency = 1\n        statFrame.Parent = statsPanel\n        \n        local statLabel = Instance.new(\"TextLabel\")\n        statLabel.Size = UDim2.new(1, 0, 0.5, 0)\n        statLabel.Position = UDim2.new(0, 0, 0, 0)\n        statLabel.BackgroundTransparency = 1\n        statLabel.Text = label\n        statLabel.TextColor3 = Color3.fromRGB(180, 180, 180)\n        statLabel.TextScaled = true\n        statLabel.Font = Enum.Font.SourceSans\n        statLabel.Parent = statFrame\n        \n        local statValue = Instance.new(\"TextLabel\")\n        statValue.Name = \"StatValue\" .. i\n        statValue.Size = UDim2.new(1, 0, 0.5, 0)\n        statValue.Position = UDim2.new(0, 0, 0.5, 0)\n        statValue.BackgroundTransparency = 1\n        statValue.Text = \"0\"\n        statValue.TextColor3 = Color3.fromRGB(255, 255, 255)\n        statValue.TextScaled = true\n        statValue.Font = Enum.Font.SourceSansBold\n        statValue.Parent = statFrame\n    end\n    \n    -- Panel de modos de batalla\n    local battleModesPanel = Instance.new(\"Frame\")\n    battleModesPanel.Name = \"BattleModesPanel\"\n    battleModesPanel.Size = UDim2.new(1, -20, 0, 250)\n    battleModesPanel.Position = UDim2.new(0, 10, 0, 390)\n    battleModesPanel.BackgroundColor3 = Color3.fromRGB(55, 55, 75)\n    battleModesPanel.Parent = battleFrame\n    \n    local modesCorner = Instance.new(\"UICorner\")\n    modesCorner.CornerRadius = UDim.new(0, 10)\n    modesCorner.Parent = battleModesPanel\n    \n    local modesTitle = Instance.new(\"TextLabel\")\n    modesTitle.Size = UDim2.new(1, 0, 0, 40)\n    modesTitle.Position = UDim2.new(0, 0, 0, 5)\n    modesTitle.BackgroundTransparency = 1\n    modesTitle.Text = \"Modos de Batalla\"\n    modesTitle.TextColor3 = Color3.fromRGB(255, 255, 255)\n    modesTitle.TextScaled = true\n    modesTitle.Font = Enum.Font.SourceSansBold\n    modesTitle.Parent = battleModesPanel\n    \n    -- Botones de modo de batalla\n    local battleModes = {\n        {name = \"PvE Fácil\", difficulty = 0, color = Color3.fromRGB(50, 200, 50)},\n        {name = \"PvE Normal\", difficulty = 1, color = Color3.fromRGB(200, 200, 50)},\n        {name = \"PvE Difícil\", difficulty = 2, color = Color3.fromRGB(200, 100, 50)},\n        {name = \"PvE Extremo\", difficulty = 3, color = Color3.fromRGB(200, 50, 50)}\n    }\n    \n    local battleButtons = {}\n    for i, mode in ipairs(battleModes) do\n        local modeBtn = Instance.new(\"TextButton\")\n        modeBtn.Name = \"BattleMode\" .. i\n        modeBtn.Size = UDim2.new(0.23, 0, 0, 80)\n        modeBtn.Position = UDim2.new((i-1)*0.25, 10, 0, 60)\n        modeBtn.BackgroundColor3 = mode.color\n        modeBtn.Text = mode.name .. \"\\n\\nIniciar Batalla\"\n        modeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)\n        modeBtn.TextScaled = true\n        modeBtn.Font = Enum.Font.SourceSansBold\n        modeBtn.Parent = battleModesPanel\n        \n        local btnCorner = Instance.new(\"UICorner\")\n        btnCorner.CornerRadius = UDim.new(0, 8)\n        btnCorner.Parent = modeBtn\n        \n        battleButtons[i] = {button = modeBtn, difficulty = mode.difficulty}\n    end\n    \n    -- Panel de historial de batallas\n    local historyPanel = Instance.new(\"Frame\")\n    historyPanel.Name = \"BattleHistoryPanel\"\n    historyPanel.Size = UDim2.new(1, -20, 0, 200)\n    historyPanel.Position = UDim2.new(0, 10, 0, 660)\n    historyPanel.BackgroundColor3 = Color3.fromRGB(55, 55, 75)\n    historyPanel.Parent = battleFrame\n    \n    local historyCorner = Instance.new(\"UICorner\")\n    historyCorner.CornerRadius = UDim.new(0, 10)\n    historyCorner.Parent = historyPanel\n    \n    local historyTitle = Instance.new(\"TextLabel\")\n    historyTitle.Size = UDim2.new(1, 0, 0, 30)\n    historyTitle.Position = UDim2.new(0, 0, 0, 5)\n    historyTitle.BackgroundTransparency = 1\n    historyTitle.Text = \"Historial de Batallas Recientes\"\n    historyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)\n    historyTitle.TextScaled = true\n    historyTitle.Font = Enum.Font.SourceSansBold\n    historyTitle.Parent = historyPanel\n    \n    local historyList = Instance.new(\"ScrollingFrame\")\n    historyList.Name = \"HistoryList\"\n    historyList.Size = UDim2.new(1, -20, 1, -50)\n    historyList.Position = UDim2.new(0, 10, 0, 40)\n    historyList.BackgroundTransparency = 1\n    historyList.CanvasSize = UDim2.new(0, 0, 0, 0)\n    historyList.ScrollBarThickness = 5\n    historyList.Parent = historyPanel\n    \n    local historyLayout = Instance.new(\"UIListLayout\")\n    historyLayout.SortOrder = Enum.SortOrder.LayoutOrder\n    historyLayout.Padding = UDim.new(0, 5)\n    historyLayout.Parent = historyList\n    \n    return battleFrame, teamSlots, battleButtons, statsPanel, historyList\nend

local function createTrainingPanel(parent)
    local trainingFrame = Instance.new("ScrollingFrame")
    trainingFrame.Name = "TrainingFrame"
    trainingFrame.Size = UDim2.new(1, -20, 1, -20)
    trainingFrame.Position = UDim2.new(0, 10, 0, 10)
    trainingFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    trainingFrame.CanvasSize = UDim2.new(0, 0, 0, 1400)
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
    title.Text = "💪 Sistema de Entrenamiento Avanzado"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = trainingFrame
    
    -- Panel de estadísticas de entrenamiento diario
    local dailyStatsPanel = Instance.new("Frame")
    dailyStatsPanel.Name = "DailyStatsPanel"
    dailyStatsPanel.Size = UDim2.new(1, -20, 0, 80)
    dailyStatsPanel.Position = UDim2.new(0, 10, 0, 70)
    dailyStatsPanel.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    dailyStatsPanel.Parent = trainingFrame
    
    local dailyCorner = Instance.new("UICorner")
    dailyCorner.CornerRadius = UDim.new(0, 10)
    dailyCorner.Parent = dailyStatsPanel
    
    local dailyTitle = Instance.new("TextLabel")
    dailyTitle.Size = UDim2.new(0.3, 0, 1, 0)
    dailyTitle.Position = UDim2.new(0, 10, 0, 0)
    dailyTitle.BackgroundTransparency = 1
    dailyTitle.Text = "📊 Entrenamientos Hoy:"
    dailyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    dailyTitle.TextScaled = true
    dailyTitle.Font = Enum.Font.SourceSansBold
    dailyTitle.Parent = dailyStatsPanel
    
    local dailyCount = Instance.new("TextLabel")
    dailyCount.Name = "DailyCount"
    dailyCount.Size = UDim2.new(0.2, 0, 1, 0)
    dailyCount.Position = UDim2.new(0.3, 10, 0, 0)
    dailyCount.BackgroundTransparency = 1
    dailyCount.Text = "0/5"
    dailyCount.TextColor3 = Color3.fromRGB(0, 255, 127)
    dailyCount.TextScaled = true
    dailyCount.Font = Enum.Font.SourceSansBold
    dailyCount.Parent = dailyStatsPanel
    
    local experienceGained = Instance.new("TextLabel")
    experienceGained.Name = "ExperienceGained"
    experienceGained.Size = UDim2.new(0.5, 0, 1, 0)
    experienceGained.Position = UDim2.new(0.5, 0, 0, 0)
    experienceGained.BackgroundTransparency = 1
    experienceGained.Text = "⭐ EXP Total Ganada Hoy: 0"
    experienceGained.TextColor3 = Color3.fromRGB(255, 215, 0)
    experienceGained.TextScaled = true
    experienceGained.Font = Enum.Font.SourceSansBold
    experienceGained.Parent = dailyStatsPanel
    
    -- Panel de personajes disponibles para entrenar
    local availablePanel = Instance.new("Frame")
    availablePanel.Name = "AvailableCharactersPanel"
    availablePanel.Size = UDim2.new(1, -20, 0, 350)
    availablePanel.Position = UDim2.new(0, 10, 0, 160)
    availablePanel.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    availablePanel.Parent = trainingFrame
    
    local availableCorner = Instance.new("UICorner")
    availableCorner.CornerRadius = UDim.new(0, 10)
    availableCorner.Parent = availablePanel
    
    local availableTitle = Instance.new("TextLabel")
    availableTitle.Size = UDim2.new(1, 0, 0, 30)
    availableTitle.Position = UDim2.new(0, 0, 0, 5)
    availableTitle.BackgroundTransparency = 1
    availableTitle.Text = "Personajes Disponibles para Entrenamiento"
    availableTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    availableTitle.TextScaled = true
    availableTitle.Font = Enum.Font.SourceSansBold
    availableTitle.Parent = availablePanel
    
    local charactersScroll = Instance.new("ScrollingFrame")
    charactersScroll.Name = "CharactersScroll"
    charactersScroll.Size = UDim2.new(1, -20, 1, -50)
    charactersScroll.Position = UDim2.new(0, 10, 0, 40)
    charactersScroll.BackgroundTransparency = 1
    charactersScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    charactersScroll.ScrollBarThickness = 5
    charactersScroll.Parent = availablePanel
    
    local charactersLayout = Instance.new("UIGridLayout")
    charactersLayout.CellSize = UDim2.new(0, 140, 0, 180)
    charactersLayout.CellPadding = UDim2.new(0, 10, 0, 10)
    charactersLayout.SortOrder = Enum.SortOrder.LayoutOrder
    charactersLayout.Parent = charactersScroll
    
    -- Panel de tipos de entrenamiento
    local trainingTypesPanel = Instance.new("Frame")
    trainingTypesPanel.Name = "TrainingTypesPanel"
    trainingTypesPanel.Size = UDim2.new(1, -20, 0, 260)
    trainingTypesPanel.Position = UDim2.new(0, 10, 0, 520)
    trainingTypesPanel.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    trainingTypesPanel.Parent = trainingFrame
    
    local typesCorner = Instance.new("UICorner")
    typesCorner.CornerRadius = UDim.new(0, 10)
    typesCorner.Parent = trainingTypesPanel
    
    local typesTitle = Instance.new("TextLabel")
    typesTitle.Size = UDim2.new(1, 0, 0, 30)
    typesTitle.Position = UDim2.new(0, 0, 0, 5)
    typesTitle.BackgroundTransparency = 1
    typesTitle.Text = "🎯 Tipos de Entrenamiento Especializado"
    typesTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    typesTitle.TextScaled = true
    typesTitle.Font = Enum.Font.SourceSansBold
    typesTitle.Parent = trainingTypesPanel
    
    local trainingTypes = {
        {name = "STRENGTH", icon = "⚔️", color = Color3.fromRGB(255, 100, 100), duration = "30 min", cost = "100 💰", description = "Mejora Fuerza +2-5"},
        {name = "INTELLIGENCE", icon = "🧠", color = Color3.fromRGB(100, 100, 255), duration = "30 min", cost = "100 💰", description = "Mejora Inteligencia +2-5"},
        {name = "SPEED", icon = "💨", color = Color3.fromRGB(100, 255, 100), duration = "30 min", cost = "100 💰", description = "Mejora Velocidad +2-5"},
        {name = "RESISTANCE", icon = "🛡️", color = Color3.fromRGB(255, 255, 100), duration = "30 min", cost = "100 💰", description = "Mejora Resistencia +2-5"},
        {name = "CHARM", icon = "💖", color = Color3.fromRGB(255, 100, 255), duration = "30 min", cost = "100 💰", description = "Mejora Carisma +2-5"},
        {name = "LUCK", icon = "🍀", color = Color3.fromRGB(0, 255, 127), duration = "45 min", cost = "150 💰", description = "Mejora Suerte +1-3"},
        {name = "BALANCED", icon = "⚖️", color = Color3.fromRGB(200, 200, 200), duration = "60 min", cost = "300 💰", description = "Mejora Todos +1-2"}
    }
    
    local trainingButtons = {}
    
    -- Crear grid para los botones
    local trainingGrid = Instance.new("Frame")
    trainingGrid.Name = "TrainingGrid"
    trainingGrid.Size = UDim2.new(1, -20, 1, -40)
    trainingGrid.Position = UDim2.new(0, 10, 0, 35)
    trainingGrid.BackgroundTransparency = 1
    trainingGrid.Parent = trainingTypesPanel
    
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0.32, 0, 0, 100)
    gridLayout.CellPadding = UDim2.new(0.01, 0, 0, 10)
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.Parent = trainingGrid
    
    for i, trainingType in ipairs(trainingTypes) do
        local typeBtn = Instance.new("TextButton")
        typeBtn.Name = "TrainingType" .. trainingType.name
        typeBtn.LayoutOrder = i
        typeBtn.BackgroundColor3 = trainingType.color
        typeBtn.Text = trainingType.icon .. " " .. trainingType.name .. "\n" .. trainingType.duration .. " | " .. trainingType.cost .. "\n" .. trainingType.description
        typeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        typeBtn.TextScaled = true
        typeBtn.Font = Enum.Font.SourceSansBold
        typeBtn.Parent = trainingGrid
        
        local typeBtnCorner = Instance.new("UICorner")
        typeBtnCorner.CornerRadius = UDim.new(0, 8)
        typeBtnCorner.Parent = typeBtn
        
        -- Efecto hover
        typeBtn.MouseEnter:Connect(function()
            local tween = TweenService:Create(typeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.new(
                math.min(trainingType.color.R * 1.2, 1),
                math.min(trainingType.color.G * 1.2, 1), 
                math.min(trainingType.color.B * 1.2, 1)
            )})
            tween:Play()
        end)
        
        typeBtn.MouseLeave:Connect(function()
            local tween = TweenService:Create(typeBtn, TweenInfo.new(0.2), {BackgroundColor3 = trainingType.color})
            tween:Play()
        end)
        
        trainingButtons[trainingType.name] = typeBtn
    end
    
    -- Panel de entrenamiento activo con progreso en tiempo real
    local activePanel = Instance.new("Frame")
    activePanel.Name = "ActiveTrainingPanel"
    activePanel.Size = UDim2.new(1, -20, 0, 400)
    activePanel.Position = UDim2.new(0, 10, 0, 790)
    activePanel.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    activePanel.Parent = trainingFrame
    
    local activeCorner = Instance.new("UICorner")
    activeCorner.CornerRadius = UDim.new(0, 10)
    activeCorner.Parent = activePanel
    
    local activeTitle = Instance.new("TextLabel")
    activeTitle.Size = UDim2.new(1, 0, 0, 40)
    activeTitle.Position = UDim2.new(0, 0, 0, 5)
    activeTitle.BackgroundTransparency = 1
    activeTitle.Text = "⏳ Entrenamientos en Progreso - Tiempo Real"
    activeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    activeTitle.TextScaled = true
    activeTitle.Font = Enum.Font.SourceSansBold
    activeTitle.Parent = activePanel
    
    local activeScroll = Instance.new("ScrollingFrame")
    activeScroll.Name = "ActiveScroll"
    activeScroll.Size = UDim2.new(1, -20, 1, -50)
    activeScroll.Position = UDim2.new(0, 10, 0, 40)
    activeScroll.BackgroundTransparency = 1
    activeScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    activeScroll.ScrollBarThickness = 5
    activeScroll.Parent = activePanel
    
    local activeLayout = Instance.new("UIListLayout")
    activeLayout.SortOrder = Enum.SortOrder.LayoutOrder
    activeLayout.Padding = UDim.new(0, 5)
    activeLayout.Parent = activeScroll
    
    -- Botón para acelerar entrenamiento premium
    local boostPanel = Instance.new("Frame")
    boostPanel.Name = "BoostPanel"
    boostPanel.Size = UDim2.new(1, -20, 0, 60)
    boostPanel.Position = UDim2.new(0, 10, 1, -70)
    boostPanel.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    boostPanel.Parent = activePanel
    
    local boostCorner = Instance.new("UICorner")
    boostCorner.CornerRadius = UDim.new(0, 8)
    boostCorner.Parent = boostPanel
    
    local boostBtn = Instance.new("TextButton")
    boostBtn.Name = "BoostButton"
    boostBtn.Size = UDim2.new(1, -10, 1, -10)
    boostBtn.Position = UDim2.new(0, 5, 0, 5)
    boostBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    boostBtn.Text = "⚡ Acelerar Entrenamientos (50 💎) - ¡Completar al Instante!"
    boostBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    boostBtn.TextScaled = true
    boostBtn.Font = Enum.Font.SourceSansBold
    boostBtn.Parent = boostPanel
    
    local boostBtnCorner = Instance.new("UICorner")
    boostBtnCorner.CornerRadius = UDim.new(0, 6)
    boostBtnCorner.Parent = boostBtn
    
    return trainingFrame, charactersScroll, trainingButtons, activeScroll, availablePanel, dailyStatsPanel, boostBtn
end

local function createShopPanel(parent)
    local shopFrame = Instance.new("ScrollingFrame")
    shopFrame.Name = "ShopFrame"
    shopFrame.Size = UDim2.new(1, -20, 1, -20)
    shopFrame.Position = UDim2.new(0, 10, 0, 10)
    shopFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    shopFrame.CanvasSize = UDim2.new(0, 0, 0, 2000)
    shopFrame.ScrollBarThickness = 10
    shopFrame.Parent = parent
    shopFrame.Visible = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = shopFrame
    
    -- Header con título y balance
    local headerFrame = Instance.new("Frame")
    headerFrame.Size = UDim2.new(1, -20, 0, 80)
    headerFrame.Position = UDim2.new(0, 10, 0, 10)
    headerFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    headerFrame.Parent = shopFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = headerFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🛒 Tienda Premium & Marketplace"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = headerFrame
    
    -- Panel de balance actual
    local balancePanel = Instance.new("Frame")
    balancePanel.Size = UDim2.new(0.45, 0, 0.8, 0)
    balancePanel.Position = UDim2.new(0.5, 10, 0.1, 0)
    balancePanel.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    balancePanel.Parent = headerFrame
    
    local balanceCorner = Instance.new("UICorner")
    balanceCorner.CornerRadius = UDim.new(0, 8)
    balanceCorner.Parent = balancePanel
    
    local balanceLabel = Instance.new("TextLabel")
    balanceLabel.Name = "BalanceLabel"
    balanceLabel.Size = UDim2.new(1, -10, 1, 0)
    balanceLabel.Position = UDim2.new(0, 5, 0, 0)
    balanceLabel.BackgroundTransparency = 1
    balanceLabel.Text = "💰 0  |  🎫 0  |  💎 0"
    balanceLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    balanceLabel.TextScaled = true
    balanceLabel.Font = Enum.Font.SourceSansBold
    balanceLabel.Parent = balancePanel
    
    -- Sección de Moneda Premium (Robux)
    local robuxSection = Instance.new("Frame")
    robuxSection.Name = "RobuxSection"
    robuxSection.Size = UDim2.new(1, -20, 0, 350)
    robuxSection.Position = UDim2.new(0, 10, 0, 100)
    robuxSection.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    robuxSection.Parent = shopFrame
    
    local robuxCorner = Instance.new("UICorner")
    robuxCorner.CornerRadius = UDim.new(0, 10)
    robuxCorner.Parent = robuxSection
    
    local robuxTitle = Instance.new("TextLabel")
    robuxTitle.Size = UDim2.new(1, 0, 0, 40)
    robuxTitle.Position = UDim2.new(0, 0, 0, 10)
    robuxTitle.BackgroundTransparency = 1
    robuxTitle.Text = "💎 Packs de Moneda Premium - ¡Compra con Robux!"
    robuxTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    robuxTitle.TextScaled = true
    robuxTitle.Font = Enum.Font.SourceSansBold
    robuxTitle.Parent = robuxSection
    
    -- Grid para productos de Robux
    local robuxGrid = Instance.new("Frame")
    robuxGrid.Size = UDim2.new(1, -20, 1, -55)
    robuxGrid.Position = UDim2.new(0, 10, 0, 45)
    robuxGrid.BackgroundTransparency = 1
    robuxGrid.Parent = robuxSection
    
    local robuxLayout = Instance.new("UIGridLayout")
    robuxLayout.CellSize = UDim2.new(0.32, 0, 0, 240)
    robuxLayout.CellPadding = UDim2.new(0.01, 0, 0, 15)
    robuxLayout.SortOrder = Enum.SortOrder.LayoutOrder
    robuxLayout.Parent = robuxGrid
    
    -- Productos reales con IDs de MarketplaceService
    local robuxProducts = {
        {
            name = "Starter Pack", 
            premium = 500, 
            tickets = 10, 
            coins = 5000,
            robux = 80, 
            productId = 1234567890, -- ID real del producto en Roblox
            description = "Pack inicial perfecto\npara comenzar",
            color = Color3.fromRGB(100, 200, 100),
            popular = false
        },
        {
            name = "Mega Pack", 
            premium = 2000, 
            tickets = 50, 
            coins = 25000,
            robux = 300, 
            productId = 1234567891,
            description = "El mejor valor\n¡Pack más popular!",
            color = Color3.fromRGB(255, 150, 0),
            popular = true
        },
        {
            name = "Ultimate Pack", 
            premium = 5000, 
            tickets = 150, 
            coins = 75000,
            robux = 700, 
            productId = 1234567892,
            description = "Para los verdaderos\ncoleccionistas",
            color = Color3.fromRGB(200, 100, 255),
            popular = false
        }
    }
    
    -- Crear productos de Robux
    local purchaseButtons = {}
    for i, product in ipairs(robuxProducts) do
        local productFrame = Instance.new("Frame")
        productFrame.Name = "Product" .. i
        productFrame.LayoutOrder = i
        productFrame.BackgroundColor3 = product.color
        productFrame.Parent = robuxGrid
        
        local productCorner = Instance.new("UICorner")
        productCorner.CornerRadius = UDim.new(0, 12)
        productCorner.Parent = productFrame
        
        -- Badge de popularidad
        if product.popular then
            local popularBadge = Instance.new("Frame")
            popularBadge.Size = UDim2.new(0, 80, 0, 25)
            popularBadge.Position = UDim2.new(0, -5, 0, -5)
            popularBadge.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
            popularBadge.ZIndex = 2
            popularBadge.Parent = productFrame
            
            local badgeCorner = Instance.new("UICorner")
            badgeCorner.CornerRadius = UDim.new(0, 12)
            badgeCorner.Parent = popularBadge
            
            local badgeLabel = Instance.new("TextLabel")
            badgeLabel.Size = UDim2.new(1, 0, 1, 0)
            badgeLabel.BackgroundTransparency = 1
            badgeLabel.Text = "🔥 POPULAR"
            badgeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            badgeLabel.TextScaled = true
            badgeLabel.Font = Enum.Font.SourceSansBold
            badgeLabel.Parent = popularBadge
        end
        
        -- Nombre del producto
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -10, 0, 35)
        nameLabel.Position = UDim2.new(0, 5, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = product.name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.Parent = productFrame
        
        -- Descripción
        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, -10, 0, 30)
        descLabel.Position = UDim2.new(0, 5, 0, 40)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = product.description
        descLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        descLabel.TextScaled = true
        descLabel.Font = Enum.Font.SourceSans
        descLabel.Parent = productFrame
        
        -- Panel de contenidos
        local contentsFrame = Instance.new("Frame")
        contentsFrame.Size = UDim2.new(1, -10, 0, 100)
        contentsFrame.Position = UDim2.new(0, 5, 0, 75)
        contentsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        contentsFrame.Parent = productFrame
        
        local contentsCorner = Instance.new("UICorner")
        contentsCorner.CornerRadius = UDim.new(0, 8)
        contentsCorner.Parent = contentsFrame
        
        local contentsList = Instance.new("TextLabel")
        contentsList.Size = UDim2.new(1, -5, 1, 0)
        contentsList.Position = UDim2.new(0, 5, 0, 0)
        contentsList.BackgroundTransparency = 1
        contentsList.Text = string.format("💎 %d Premium\n🎫 %d Tickets\n💰 %d Coins", 
            product.premium, product.tickets, product.coins)
        contentsList.TextColor3 = Color3.fromRGB(255, 215, 0)
        contentsList.TextScaled = true
        contentsList.Font = Enum.Font.SourceSansBold
        contentsList.Parent = contentsFrame
        
        -- Botón de compra
        local buyButton = Instance.new("TextButton")
        buyButton.Name = "BuyButton"
        buyButton.Size = UDim2.new(1, -10, 0, 45)
        buyButton.Position = UDim2.new(0, 5, 1, -50)
        buyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        buyButton.Text = string.format("💰 Comprar - %d R$", product.robux)
        buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        buyButton.TextScaled = true
        buyButton.Font = Enum.Font.SourceSansBold
        buyButton.Parent = productFrame
        
        local buyCorner = Instance.new("UICorner")
        buyCorner.CornerRadius = UDim.new(0, 8)
        buyCorner.Parent = buyButton
        
        -- Efectos hover
        buyButton.MouseEnter:Connect(function()
            local tween = TweenService:Create(buyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 0)})
            tween:Play()
        end)
        
        buyButton.MouseLeave:Connect(function()
            local tween = TweenService:Create(buyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 170, 0)})
            tween:Play()
        end)
        
        purchaseButtons[product.productId] = {button = buyButton, product = product}
    end
    
    -- Sección de Items de Juego
    local itemsSection = Instance.new("Frame")
    itemsSection.Name = "ItemsSection"
    itemsSection.Size = UDim2.new(1, -20, 0, 300)
    itemsSection.Position = UDim2.new(0, 10, 0, 470)
    itemsSection.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    itemsSection.Parent = shopFrame
    
    local itemsCorner = Instance.new("UICorner")
    itemsCorner.CornerRadius = UDim.new(0, 10)
    itemsCorner.Parent = itemsSection
    
    local itemsTitle = Instance.new("TextLabel")
    itemsTitle.Size = UDim2.new(1, 0, 0, 40)
    itemsTitle.Position = UDim2.new(0, 0, 0, 10)
    itemsTitle.BackgroundTransparency = 1
    itemsTitle.Text = "🛍️ Items Especiales - Compra con Moneda del Juego"
    itemsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    itemsTitle.TextScaled = true
    itemsTitle.Font = Enum.Font.SourceSansBold
    itemsTitle.Parent = itemsSection
    
    -- Items que se pueden comprar con moneda del juego
    local gameItems = {
        {name = "Boost XP x2", description = "Duplica XP por 1 hora", cost = 1000, currency = "coins", icon = "⚡", duration = "1h"},
        {name = "Gacha Gratis", description = "1 pull gratis extra", cost = 5, currency = "tickets", icon = "🎰", duration = "Inmediato"},
        {name = "Auto-Training", description = "Entrena automáticamente", cost = 50, currency = "premium", icon = "🤖", duration = "24h"},
        {name = "Luck Boost", description = "Mejor suerte en gacha", cost = 2000, currency = "coins", icon = "🍀", duration = "2h"}
    }
    
    local itemButtons = {}
    for i, item in ipairs(gameItems) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(0.48, 0, 0, 100)
        itemFrame.Position = UDim2.new((i-1) % 2 * 0.5, 10 + ((i-1) % 2) * 10, 0, 60 + math.floor((i-1) / 2) * 110)
        itemFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
        itemFrame.Parent = itemsSection
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 8)
        itemCorner.Parent = itemFrame
        
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(0, 50, 1, 0)
        iconLabel.Position = UDim2.new(0, 5, 0, 0)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = item.icon
        iconLabel.TextScaled = true
        iconLabel.Font = Enum.Font.SourceSans
        iconLabel.Parent = itemFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -60, 0, 25)
        nameLabel.Position = UDim2.new(0, 55, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = item.name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.Parent = itemFrame
        
        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, -60, 0, 20)
        descLabel.Position = UDim2.new(0, 55, 0, 30)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = item.description .. " (" .. item.duration .. ")"
        descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        descLabel.TextScaled = true
        descLabel.Font = Enum.Font.SourceSans
        descLabel.Parent = itemFrame
        
        local buyItemBtn = Instance.new("TextButton")
        buyItemBtn.Size = UDim2.new(1, -60, 0, 30)
        buyItemBtn.Position = UDim2.new(0, 55, 0, 55)
        buyItemBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        
        local currencyIcon = item.currency == "coins" and "💰" or (item.currency == "tickets" and "🎫" or "💎")
        buyItemBtn.Text = string.format("Comprar - %d %s", item.cost, currencyIcon)
        buyItemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        buyItemBtn.TextScaled = true
        buyItemBtn.Font = Enum.Font.SourceSansBold
        buyItemBtn.Parent = itemFrame
        
        local buyItemCorner = Instance.new("UICorner")
        buyItemCorner.CornerRadius = UDim.new(0, 6)
        buyItemCorner.Parent = buyItemBtn
        
        itemButtons[item.name] = buyItemBtn
    end
    
    -- Sección de Historial de Compras
    local historySection = Instance.new("Frame")
    historySection.Name = "HistorySection"
    historySection.Size = UDim2.new(1, -20, 0, 250)
    historySection.Position = UDim2.new(0, 10, 0, 790)
    historySection.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    historySection.Parent = shopFrame
    
    local historyCorner = Instance.new("UICorner")
    historyCorner.CornerRadius = UDim.new(0, 10)
    historyCorner.Parent = historySection
    
    local historyTitle = Instance.new("TextLabel")
    historyTitle.Size = UDim2.new(1, 0, 0, 40)
    historyTitle.Position = UDim2.new(0, 0, 0, 5)
    historyTitle.BackgroundTransparency = 1
    historyTitle.Text = "📜 Historial de Compras"
    historyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    historyTitle.TextScaled = true
    historyTitle.Font = Enum.Font.SourceSansBold
    historyTitle.Parent = historySection
    
    local historyScroll = Instance.new("ScrollingFrame")
    historyScroll.Name = "HistoryScroll"
    historyScroll.Size = UDim2.new(1, -20, 1, -50)
    historyScroll.Position = UDim2.new(0, 10, 0, 40)
    historyScroll.BackgroundTransparency = 1
    historyScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    historyScroll.ScrollBarThickness = 5
    historyScroll.Parent = historySection
    
    local historyLayout = Instance.new("UIListLayout")
    historyLayout.SortOrder = Enum.SortOrder.LayoutOrder
    historyLayout.Padding = UDim.new(0, 5)
    historyLayout.Parent = historyScroll
    
    return shopFrame, purchaseButtons, itemButtons, balanceLabel, historyScroll
end

local function createSettingsPanel(parent)
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Name = "SettingsFrame"
    settingsFrame.Size = UDim2.new(1, -20, 1, -20)
    settingsFrame.Position = UDim2.new(0, 10, 0, 10)
    settingsFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    settingsFrame.Parent = parent
    settingsFrame.Visible = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = settingsFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "⚙️ Configuración"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = settingsFrame
    
    return settingsFrame
end

-- Crear interface principal
local function createMainInterface()
    -- Servicios de Roblox
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    
    local mainGui, uiElements = createMainUI()
    
    -- Conectar eventos remotos
    local eventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
    
    -- Crear todos los paneles
    local collectionPanel, searchBox, rarityFilters, sortDropdown, charactersGrid = createCollectionPanel(uiElements.contentPanel)
    local gachaPanel, singleBtn, multiBtn = createGachaPanel(uiElements.contentPanel)
    local battlePanel = createBattlePanel(uiElements.contentPanel)
    local trainingPanel, trainingCharactersScroll, trainingButtons, trainingActiveScroll, trainingAvailablePanel, trainingDailyStats, trainingBoostBtn = createTrainingPanel(uiElements.contentPanel)
    local shopPanel, shopPurchaseButtons, shopItemButtons, shopBalanceLabel, shopHistoryScroll = createShopPanel(uiElements.contentPanel)
    local settingsPanel = createSettingsPanel(uiElements.contentPanel)
    
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
        settingsPanel.Visible = false
        
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
        elseif panelName == "Settings" then
            settingsPanel.Visible = true
        end
        
        currentPanel = panelName
    end
        ticketIcon.TextColor3 = Color3.fromRGB(0, 255, 127)
        ticketIcon.TextScaled = true
        ticketIcon.Font = Enum.Font.SourceSans
        ticketIcon.Parent = productFrame
        
        local ticketAmount = Instance.new("TextLabel")
        ticketAmount.Size = UDim2.new(1, -10, 0, 25)
        ticketAmount.Position = UDim2.new(0, 5, 0, 105)
        ticketAmount.BackgroundTransparency = 1
        local bonusText = product.bonus and " (+" .. product.bonus .. " BONUS!)" or ""
        ticketAmount.Text = product.tickets .. " Tickets" .. bonusText
        ticketAmount.TextColor3 = Color3.fromRGB(0, 255, 127)
        ticketAmount.TextScaled = true
        ticketAmount.Font = Enum.Font.SourceSans
        ticketAmount.Parent = productFrame
        
        local buyBtn = Instance.new("TextButton")
        buyBtn.Size = UDim2.new(1, -10, 0, 40)
        buyBtn.Position = UDim2.new(0, 5, 1, -50)
        buyBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
        buyBtn.Text = "R$ " .. product.robux
        buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        buyBtn.TextScaled = true
        buyBtn.Font = Enum.Font.SourceSansBold
        buyBtn.Parent = productFrame
        
        local buyCorner = Instance.new("UICorner")
        buyCorner.CornerRadius = UDim.new(0, 8)
        buyCorner.Parent = buyBtn
        
        if product.bonus then
            local bonusLabel = Instance.new("TextLabel")
            bonusLabel.Size = UDim2.new(0, 80, 0, 25)
            bonusLabel.Position = UDim2.new(1, -85, 0, 5)
            bonusLabel.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
            bonusLabel.Text = "BONUS!"
            bonusLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
            bonusLabel.TextScaled = true
            bonusLabel.Font = Enum.Font.SourceSansBold
            bonusLabel.Parent = productFrame
            
            local bonusCorner = Instance.new("UICorner")
            bonusCorner.CornerRadius = UDim.new(0, 12)
            bonusCorner.Parent = bonusLabel
        end
        
        buyBtn.Activated:Connect(function()
            print("Attempting to purchase:", product.name, "for", product.robux, "Robux")
            -- TODO: Implementar compra con MarketplaceService
        end)
    end
    
    -- Sección de Monedas
    local coinsSection = Instance.new("Frame")
    coinsSection.Name = "CoinsSection"
    coinsSection.Size = UDim2.new(1, -20, 0, 300)
    coinsSection.Position = UDim2.new(0, 10, 0, 390)
    coinsSection.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    coinsSection.Parent = shopFrame
    
    local coinsCorner = Instance.new("UICorner")
    coinsCorner.CornerRadius = UDim.new(0, 10)
    coinsCorner.Parent = coinsSection
    
    local coinsTitle = Instance.new("TextLabel")
    coinsTitle.Size = UDim2.new(1, 0, 0, 40)
    coinsTitle.Position = UDim2.new(0, 0, 0, 10)
    coinsTitle.BackgroundTransparency = 1
    coinsTitle.Text = "💰 Monedas del Juego"
    coinsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    coinsTitle.TextScaled = true
    coinsTitle.Font = Enum.Font.SourceSansBold
    coinsTitle.Parent = coinsSection
    
    local coinProducts = {
        {name = "Bolsa Pequeña", coins = 1000, robux = 49, productId = 123456793},
        {name = "Bolsa Mediana", coins = 5000, robux = 199, productId = 123456794, bonus = 500},
        {name = "Bolsa Grande", coins = 15000, robux = 499, productId = 123456795, bonus = 2000},
        {name = "Cofre del Tesoro", coins = 50000, robux = 1199, productId = 123456796, bonus = 10000}
    }
    
    for i, product in ipairs(coinProducts) do
        local productFrame = Instance.new("Frame")
        productFrame.Size = UDim2.new(0.23, 0, 0, 200)
        productFrame.Position = UDim2.new((i-1)*0.25, 10, 0, 60)
        productFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
        productFrame.Parent = coinsSection
        
        local productCorner = Instance.new("UICorner")
        productCorner.CornerRadius = UDim.new(0, 10)
        productCorner.Parent = productFrame
        
        local productName = Instance.new("TextLabel")
        productName.Size = UDim2.new(1, -10, 0, 30)
        productName.Position = UDim2.new(0, 5, 0, 10)
        productName.BackgroundTransparency = 1
        productName.Text = product.name
        productName.TextColor3 = Color3.fromRGB(255, 255, 255)
        productName.TextScaled = true
        productName.Font = Enum.Font.SourceSansBold
        productName.Parent = productFrame
        
        local coinIcon = Instance.new("TextLabel")
        coinIcon.Size = UDim2.new(1, -10, 0, 60)
        coinIcon.Position = UDim2.new(0, 5, 0, 45)
        coinIcon.BackgroundTransparency = 1
        coinIcon.Text = "💰"
        coinIcon.TextColor3 = Color3.fromRGB(255, 215, 0)
        coinIcon.TextScaled = true
        coinIcon.Font = Enum.Font.SourceSans
        coinIcon.Parent = productFrame
        
        local coinAmount = Instance.new("TextLabel")
        coinAmount.Size = UDim2.new(1, -10, 0, 25)
        coinAmount.Position = UDim2.new(0, 5, 0, 105)
        coinAmount.BackgroundTransparency = 1
        local bonusText = product.bonus and " (+" .. product.bonus .. " BONUS!)" or ""
        coinAmount.Text = product.coins .. " Coins" .. bonusText
        coinAmount.TextColor3 = Color3.fromRGB(255, 215, 0)
        coinAmount.TextScaled = true
        coinAmount.Font = Enum.Font.SourceSans
        coinAmount.Parent = productFrame
        
        local buyBtn = Instance.new("TextButton")
        buyBtn.Size = UDim2.new(1, -10, 0, 40)
        buyBtn.Position = UDim2.new(0, 5, 1, -50)
        buyBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
        buyBtn.Text = "R$ " .. product.robux
        buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        buyBtn.TextScaled = true
        buyBtn.Font = Enum.Font.SourceSansBold
        buyBtn.Parent = productFrame
        
        local buyCorner = Instance.new("UICorner")
        buyCorner.CornerRadius = UDim.new(0, 8)
        buyCorner.Parent = buyBtn
        
        if product.bonus then
            local bonusLabel = Instance.new("TextLabel")
            bonusLabel.Size = UDim2.new(0, 80, 0, 25)
            bonusLabel.Position = UDim2.new(1, -85, 0, 5)
            bonusLabel.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
            bonusLabel.Text = "BONUS!"
            bonusLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
            bonusLabel.TextScaled = true
            bonusLabel.Font = Enum.Font.SourceSansBold
            bonusLabel.Parent = productFrame
            
            local bonusCorner = Instance.new("UICorner")
            bonusCorner.CornerRadius = UDim.new(0, 12)
            bonusCorner.Parent = bonusLabel
        end
        
        buyBtn.Activated:Connect(function()
            print("Attempting to purchase:", product.name, "for", product.robux, "Robux")
            -- TODO: Implementar compra con MarketplaceService
        end)
    end
    
    -- Sección de Skins Premium
    local skinsSection = Instance.new("Frame")
    skinsSection.Name = "SkinsSection"
    skinsSection.Size = UDim2.new(1, -20, 0, 350)
    skinsSection.Position = UDim2.new(0, 10, 0, 710)
    skinsSection.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    skinsSection.Parent = shopFrame
    
    local skinsCorner = Instance.new("UICorner")
    skinsCorner.CornerRadius = UDim.new(0, 10)
    skinsCorner.Parent = skinsSection
    
    local skinsTitle = Instance.new("TextLabel")
    skinsTitle.Size = UDim2.new(1, 0, 0, 40)
    skinsTitle.Position = UDim2.new(0, 0, 0, 10)
    skinsTitle.BackgroundTransparency = 1
    skinsTitle.Text = "🎭 Skins Premium"
    skinsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    skinsTitle.TextScaled = true
    skinsTitle.Font = Enum.Font.SourceSansBold
    skinsTitle.Parent = skinsSection
    
    local skinProducts = {
        {name = "Aura Dorada", description = "Efecto dorado brillante", robux = 299, productId = 123456797, rarity = "Epic"},
        {name = "Aura de Fuego", description = "Llamas ardientes", robux = 399, productId = 123456798, rarity = "Legendary"},
        {name = "Aura Celestial", description = "Estrellas y galaxias", robux = 599, productId = 123456799, rarity = "Mythic"},
        {name = "Pack Completo", description = "Todas las skins!", robux = 999, productId = 123456800, rarity = "Ultimate"}
    }
    
    local rarityColors = {
        Epic = Color3.fromRGB(163, 53, 238),
        Legendary = Color3.fromRGB(255, 128, 0),
        Mythic = Color3.fromRGB(255, 215, 0),
        Ultimate = Color3.fromRGB(255, 0, 255)
    }
    
    for i, product in ipairs(skinProducts) do
        local productFrame = Instance.new("Frame")
        productFrame.Size = UDim2.new(0.23, 0, 0, 250)
        productFrame.Position = UDim2.new((i-1)*0.25, 10, 0, 60)
        productFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
        productFrame.Parent = skinsSection
        
        local productCorner = Instance.new("UICorner")
        productCorner.CornerRadius = UDim.new(0, 10)
        productCorner.Parent = productFrame
        
        local rarityBorder = Instance.new("UIStroke")
        rarityBorder.Thickness = 3
        rarityBorder.Color = rarityColors[product.rarity] or Color3.fromRGB(100, 100, 100)
        rarityBorder.Parent = productFrame
        
        local productName = Instance.new("TextLabel")
        productName.Size = UDim2.new(1, -10, 0, 30)
        productName.Position = UDim2.new(0, 5, 0, 10)
        productName.BackgroundTransparency = 1
        productName.Text = product.name
        productName.TextColor3 = Color3.fromRGB(255, 255, 255)
        productName.TextScaled = true
        productName.Font = Enum.Font.SourceSansBold
        productName.Parent = productFrame
        
        local rarityLabel = Instance.new("TextLabel")
        rarityLabel.Size = UDim2.new(1, -10, 0, 20)
        rarityLabel.Position = UDim2.new(0, 5, 0, 45)
        rarityLabel.BackgroundTransparency = 1
        rarityLabel.Text = product.rarity
        rarityLabel.TextColor3 = rarityColors[product.rarity]
        rarityLabel.TextScaled = true
        rarityLabel.Font = Enum.Font.SourceSansBold
        rarityLabel.Parent = productFrame
        
        local skinIcon = Instance.new("TextLabel")
        skinIcon.Size = UDim2.new(1, -10, 0, 80)
        skinIcon.Position = UDim2.new(0, 5, 0, 70)
        skinIcon.BackgroundTransparency = 1
        skinIcon.Text = "✨"
        skinIcon.TextColor3 = rarityColors[product.rarity]
        skinIcon.TextScaled = true
        skinIcon.Font = Enum.Font.SourceSans
        skinIcon.Parent = productFrame
        
        local description = Instance.new("TextLabel")
        description.Size = UDim2.new(1, -10, 0, 35)
        description.Position = UDim2.new(0, 5, 0, 155)
        description.BackgroundTransparency = 1
        description.Text = product.description
        description.TextColor3 = Color3.fromRGB(200, 200, 200)
        description.TextScaled = true
        description.Font = Enum.Font.SourceSans
        description.Parent = productFrame
        
        local buyBtn = Instance.new("TextButton")
        buyBtn.Size = UDim2.new(1, -10, 0, 40)
        buyBtn.Position = UDim2.new(0, 5, 1, -50)
        buyBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
        buyBtn.Text = "R$ " .. product.robux
        buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        buyBtn.TextScaled = true
        buyBtn.Font = Enum.Font.SourceSansBold
        buyBtn.Parent = productFrame
        
        local buyCorner = Instance.new("UICorner")
        buyCorner.CornerRadius = UDim.new(0, 8)
        buyCorner.Parent = buyBtn
        
        buyBtn.Activated:Connect(function()
            print("Attempting to purchase skin:", product.name, "for", product.robux, "Robux")
            -- TODO: Implementar compra de skin con MarketplaceService
        end)
    end
    
    -- Sección de Pases Premium
    local passesSection = Instance.new("Frame")
    passesSection.Name = "PassesSection"
    passesSection.Size = UDim2.new(1, -20, 0, 300)
    passesSection.Position = UDim2.new(0, 10, 0, 1080)
    passesSection.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    passesSection.Parent = shopFrame
    
    local passesCorner = Instance.new("UICorner")
    passesCorner.CornerRadius = UDim.new(0, 10)
    passesCorner.Parent = passesSection
    
    local passesTitle = Instance.new("TextLabel")
    passesTitle.Size = UDim2.new(1, 0, 0, 40)
    passesTitle.Position = UDim2.new(0, 0, 0, 10)
    passesTitle.BackgroundTransparency = 1
    passesTitle.Text = "🎟️ Pases Premium"
    passesTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    passesTitle.TextScaled = true
    passesTitle.Font = Enum.Font.SourceSansBold
    passesTitle.Parent = passesSection
    
    local passProducts = {
        {name = "VIP Pass", description = "2x XP y monedas", robux = 499, productId = 123456801},
        {name = "Premium Pass", description = "Gacha garantizado raro+", robux = 799, productId = 123456802},
        {name = "Ultimate Pass", description = "Todos los beneficios", robux = 1299, productId = 123456803}
    }
    
    for i, product in ipairs(passProducts) do
        local productFrame = Instance.new("Frame")
        productFrame.Size = UDim2.new(0.31, 0, 0, 200)
        productFrame.Position = UDim2.new((i-1)*0.33, 10, 0, 60)
        productFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
        productFrame.Parent = passesSection
        
        local productCorner = Instance.new("UICorner")
        productCorner.CornerRadius = UDim.new(0, 10)
        productCorner.Parent = productFrame
        
        local goldBorder = Instance.new("UIStroke")
        goldBorder.Thickness = 2
        goldBorder.Color = Color3.fromRGB(255, 215, 0)
        goldBorder.Parent = productFrame
        
        local productName = Instance.new("TextLabel")
        productName.Size = UDim2.new(1, -10, 0, 30)
        productName.Position = UDim2.new(0, 5, 0, 10)
        productName.BackgroundTransparency = 1
        productName.Text = product.name
        productName.TextColor3 = Color3.fromRGB(255, 215, 0)
        productName.TextScaled = true
        productName.Font = Enum.Font.SourceSansBold
        productName.Parent = productFrame
        
        local passIcon = Instance.new("TextLabel")
        passIcon.Size = UDim2.new(1, -10, 0, 60)
        passIcon.Position = UDim2.new(0, 5, 0, 45)
        passIcon.BackgroundTransparency = 1
        passIcon.Text = "🎟️"
        passIcon.TextColor3 = Color3.fromRGB(255, 215, 0)
        passIcon.TextScaled = true
        passIcon.Font = Enum.Font.SourceSans
        passIcon.Parent = productFrame
        
        local description = Instance.new("TextLabel")
        description.Size = UDim2.new(1, -10, 0, 35)
        description.Position = UDim2.new(0, 5, 0, 110)
        description.BackgroundTransparency = 1
        description.Text = product.description
        description.TextColor3 = Color3.fromRGB(200, 200, 200)
        description.TextScaled = true
        description.Font = Enum.Font.SourceSans
        description.Parent = productFrame
        
        local buyBtn = Instance.new("TextButton")
        buyBtn.Size = UDim2.new(1, -10, 0, 40)
        buyBtn.Position = UDim2.new(0, 5, 1, -50)
        buyBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
        buyBtn.Text = "R$ " .. product.robux
        buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        buyBtn.TextScaled = true
        buyBtn.Font = Enum.Font.SourceSansBold
        buyBtn.Parent = productFrame
        
        local buyCorner = Instance.new("UICorner")
        buyCorner.CornerRadius = UDim.new(0, 8)
        buyCorner.Parent = buyBtn
        
        buyBtn.Activated:Connect(function()
            print("Attempting to purchase pass:", product.name, "for", product.robux, "Robux")
            -- TODO: Implementar compra de pase con MarketplaceService
        end)
    end
    
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
    local trainingPanel, trainingCharactersScroll, trainingButtons, trainingActiveScroll, trainingAvailablePanel, trainingDailyStats, trainingBoostBtn = createTrainingPanel(uiElements.contentPanel)
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
    
    -- Variables de filtro y búsqueda
    local currentSearchTerm = ""
    local activeRarityFilters = {true, true, true, true, true, true}
    local currentSortMode = "rarity"
    local allCharacters = {}
    
    -- Función para filtrar personajes
    local function filterCharacters(characters)
        local filtered = {}
        
        for _, character in ipairs(characters) do
            local matchesSearch = true
            local matchesRarity = true
            
            -- Filtro de búsqueda por nombre y serie
            if currentSearchTerm ~= "" then
                local searchLower = string.lower(currentSearchTerm)
                local nameLower = string.lower(character.name or "")
                local seriesLower = string.lower(character.series or "")
                matchesSearch = string.find(nameLower, searchLower) or string.find(seriesLower, searchLower)
            end
            
            -- Filtro de rareza
            if character.rarity and character.rarity >= 1 and character.rarity <= 6 then
                matchesRarity = activeRarityFilters[character.rarity]
            end
            
            if matchesSearch and matchesRarity then
                table.insert(filtered, character)
            end
        end
        
        return filtered
    end
    
    -- Función para ordenar personajes
    local function sortCharacters(characters)
        local sorted = {}
        for _, char in ipairs(characters) do
            table.insert(sorted, char)
        end
        
        if currentSortMode == "rarity" then
            table.sort(sorted, function(a, b)
                if (a.rarity or 1) == (b.rarity or 1) then
                    return (a.name or "") < (b.name or "")
                end
                return (a.rarity or 1) > (b.rarity or 1)
            end)
        elseif currentSortMode == "name" then
            table.sort(sorted, function(a, b)
                return (a.name or "") < (b.name or "")
            end)
        elseif currentSortMode == "level" then
            table.sort(sorted, function(a, b)
                if (a.level or 1) == (b.level or 1) then
                    return (a.rarity or 1) > (b.rarity or 1)
                end
                return (a.level or 1) > (b.level or 1)
            end)
        elseif currentSortMode == "series" then
            table.sort(sorted, function(a, b)
                if (a.series or "") == (b.series or "") then
                    return (a.name or "") < (b.name or "")
                end
                return (a.series or "") < (b.series or "")
            end)
        end
        
        return sorted
    end
    
    -- Función para mostrar modal de detalles del personaje
    local function showCharacterDetails(character)
        local detailGui = Instance.new("ScreenGui")
        detailGui.Name = "CharacterDetails"
        detailGui.Parent = playerGui
        detailGui.DisplayOrder = 300
        
        local backdrop = Instance.new("Frame")
        backdrop.Size = UDim2.new(1, 0, 1, 0)
        backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        backdrop.BackgroundTransparency = 0.3
        backdrop.Parent = detailGui
        
        local detailFrame = Instance.new("Frame")
        detailFrame.Size = UDim2.new(0, 600, 0, 700)
        detailFrame.Position = UDim2.new(0.5, -300, 0.5, -350)
        detailFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        detailFrame.Parent = detailGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 20)
        corner.Parent = detailFrame
        
        -- Título con nombre del personaje
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -40, 0, 60)
        nameLabel.Position = UDim2.new(0, 20, 0, 20)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = character.name or "Personaje"
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.Parent = detailFrame
        
        -- Stats detalladas
        local statsFrame = Instance.new("Frame")
        statsFrame.Size = UDim2.new(1, -40, 0, 300)
        statsFrame.Position = UDim2.new(0, 20, 0, 100)
        statsFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
        statsFrame.Parent = detailFrame
        
        local statsCorner = Instance.new("UICorner")
        statsCorner.CornerRadius = UDim.new(0, 10)
        statsCorner.Parent = statsFrame
        
        local statsList = {
            {"Serie:", character.series or "Desconocida"},
            {"Rareza:", string.rep("★", character.rarity or 1)},
            {"Nivel:", tostring(character.level or 1)},
            {"Edad:", tostring(character.age or 16) .. " años"},
            {"ATK:", tostring(character.stats and character.stats.attack or 100)},
            {"DEF:", tostring(character.stats and character.stats.defense or 100)},
            {"HP:", tostring(character.stats and character.stats.health or 500)},
            {"Velocidad:", tostring(character.stats and character.stats.speed or 50)}
        }
        
        for i, stat in ipairs(statsList) do
            local statLabel = Instance.new("TextLabel")
            statLabel.Size = UDim2.new(0.5, -10, 0, 30)
            statLabel.Position = UDim2.new((i-1) % 2 == 0 and 0 or 0.5, 10, 0, 10 + math.floor((i-1) / 2) * 35)
            statLabel.BackgroundTransparency = 1
            statLabel.Text = stat[1] .. " " .. stat[2]
            statLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            statLabel.TextScaled = true
            statLabel.Font = Enum.Font.SourceSans
            statLabel.Parent = statsFrame
        end
        
        -- Botones de acción
        local actionFrame = Instance.new("Frame")
        actionFrame.Size = UDim2.new(1, -40, 0, 120)
        actionFrame.Position = UDim2.new(0, 20, 0, 420)
        actionFrame.BackgroundTransparency = 1
        actionFrame.Parent = detailFrame
        
        local actionButtons = {
            {text = "💪 Entrenar", color = Color3.fromRGB(0, 150, 255)},
            {text = "🎭 Skins", color = Color3.fromRGB(255, 100, 255)},
            {text = "⚔️ Equipar", color = Color3.fromRGB(255, 150, 0)},
            {text = "🗑️ Liberar", color = Color3.fromRGB(255, 50, 50)}
        }
        
        for i, btnData in ipairs(actionButtons) do
            local actionBtn = Instance.new("TextButton")
            actionBtn.Size = UDim2.new(0.48, 0, 0, 50)
            actionBtn.Position = UDim2.new((i-1) % 2 == 0 and 0 or 0.52, 0, 0, math.floor((i-1) / 2) * 60)
            actionBtn.BackgroundColor3 = btnData.color
            actionBtn.Text = btnData.text
            actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            actionBtn.TextScaled = true
            actionBtn.Font = Enum.Font.SourceSansBold
            actionBtn.Parent = actionFrame
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 8)
            btnCorner.Parent = actionBtn
            
            actionBtn.Activated:Connect(function()
                print("Action button clicked:", btnData.text, "for character:", character.name)
                -- TODO: Implementar acciones específicas
            end)
        end
        
        -- Botón cerrar
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(1, -40, 0, 50)
        closeBtn.Position = UDim2.new(0, 20, 1, -80)
        closeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
        closeBtn.Text = "Cerrar"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.TextScaled = true
        closeBtn.Font = Enum.Font.SourceSansBold
        closeBtn.Parent = detailFrame
        
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 8)
        closeCorner.Parent = closeBtn
        
        closeBtn.Activated:Connect(function()
            detailGui:Destroy()
        end)
        
        backdrop.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                detailGui:Destroy()
            end
        end)
    end
    
    -- Función para cargar y mostrar personajes en la colección
    local function loadCharacterCollection()
        local getPlayerCharacters = eventsFolder:WaitForChild("GetPlayerCharacters")
        local characters = getPlayerCharacters:InvokeServer()
        
        allCharacters = characters or {}
        
        -- Aplicar filtros y ordenamiento
        local filteredCharacters = filterCharacters(allCharacters)
        local sortedCharacters = sortCharacters(filteredCharacters)
        
        -- Limpiar grid actual
        for _, child in pairs(charactersGrid:GetChildren()) do
            if child:IsA("Frame") and child.Name:match("CharacterCard_") then
                child:Destroy()
            end
        end
        
        -- Crear tarjetas para cada personaje
        for _, character in ipairs(sortedCharacters) do
            local card, detailsBtn = createCharacterCard(character, charactersGrid)
            
            -- Conectar botón de detalles
            detailsBtn.Activated:Connect(function()
                showCharacterDetails(character)
            end)
        end
        
        -- Ajustar tamaño del canvas
        local gridLayout = charactersGrid:FindFirstChild("UIGridLayout")
        if gridLayout then
            local rows = math.ceil(#sortedCharacters / 4) -- 4 columnas aprox
            collectionPanel.CanvasSize = UDim2.new(0, 0, 0, math.max(600, rows * 230 + 120))
        end
    end
    
    -- Conectar funcionalidad de búsqueda
    searchBox.FocusLost:Connect(function(enterPressed)
        currentSearchTerm = searchBox.Text
        loadCharacterCollection()
    end)
    
    -- Conectar filtros de rareza
    for i, filterData in pairs(rarityFilters) do
        filterData.button.Activated:Connect(function()
            activeRarityFilters[i] = not activeRarityFilters[i]
            
            -- Actualizar apariencia del botón
            if activeRarityFilters[i] then
                filterData.button.BackgroundTransparency = 0
                filterData.button.TextColor3 = Color3.fromRGB(0, 0, 0)
            else
                filterData.button.BackgroundTransparency = 0.7
                filterData.button.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
            
            loadCharacterCollection()
        end)
    end
    
    -- Conectar dropdown de ordenamiento
    local sortModes = {"rarity", "name", "level", "series"}
    local sortLabels = {"Rareza", "Nombre", "Nivel", "Serie"}
    local currentSortIndex = 1
    
    sortDropdown.Activated:Connect(function()
        currentSortIndex = currentSortIndex + 1
        if currentSortIndex > #sortModes then
            currentSortIndex = 1
        end
        
        currentSortMode = sortModes[currentSortIndex]
        sortDropdown.Text = "Ordenar por: " .. sortLabels[currentSortIndex]
        loadCharacterCollection()
    end)
    
    -- Variables para el entrenamiento
    local selectedCharacterForTraining = nil
    local selectedTrainingType = nil
    local activeTrainings = {}
    local dailyTrainingCount = 0
    local dailyExpGained = 0
    
    -- Funciones auxiliares del entrenamiento
    local function showTrainingResults(improvements, leveledUp, experienceGained)
        local resultText = "🎉 ¡Entrenamiento Completado!\n\n"
        
        for statName, gain in pairs(improvements) do
            resultText = resultText .. "• " .. statName:upper() .. ": +" .. gain .. "\n"
        end
        
        if leveledUp then
            resultText = resultText .. "\n⭐ ¡NIVEL AUMENTADO! ⭐"
        end
        
        if experienceGained and experienceGained > 0 then
            resultText = resultText .. "\n📈 EXP: +" .. experienceGained
        end
        
        showNotification("Entrenamiento Exitoso", resultText, "success", 5)
        
        -- Actualizar estadísticas diarias
        dailyExpGained = dailyExpGained + (experienceGained or 0)
        updateDailyTrainingStats()
    end
    
    local function updateDailyTrainingStats()
        if trainingDailyStats then
            local dailyCount = trainingDailyStats:FindFirstChild("DailyCount")
            local expGained = trainingDailyStats:FindFirstChild("ExperienceGained")
            
            if dailyCount then
                dailyCount.Text = dailyTrainingCount .. "/5"
                dailyCount.TextColor3 = dailyTrainingCount >= 5 and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(0, 255, 127)
            end
            
            if expGained then
                expGained.Text = "⭐ EXP Total Ganada Hoy: " .. dailyExpGained
            end
        end
    end
    
    -- Función para crear tarjeta de personaje pequeña para entrenamiento
    local function createTrainingCharacterCard(character, parent)
        local card = Instance.new("Frame")
        card.Name = "TrainingCard_" .. character.id
        card.Size = UDim2.new(0, 140, 0, 180)
        card.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        card.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = card
        
        -- Border de rareza
        local rarityBorder = Instance.new("UIStroke")
        rarityBorder.Thickness = 2
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
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -10, 0, 25)
        nameLabel.Position = UDim2.new(0, 5, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = character.name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.Parent = card
        
        local levelLabel = Instance.new("TextLabel")
        levelLabel.Size = UDim2.new(1, -10, 0, 20)
        levelLabel.Position = UDim2.new(0, 5, 0, 30)
        levelLabel.BackgroundTransparency = 1
        levelLabel.Text = "Lv." .. (character.level or 1)
        levelLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        levelLabel.TextScaled = true
        levelLabel.Font = Enum.Font.SourceSans
        levelLabel.Parent = card
        
        -- Icono mejorado para entrenamiento
        local iconFrame = Instance.new("Frame")
        iconFrame.Size = UDim2.new(1, -10, 0, 80)
        iconFrame.Position = UDim2.new(0, 5, 0, 55)
        iconFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        iconFrame.Parent = card
        
        local iconFrameCorner = Instance.new("UICorner")
        iconFrameCorner.CornerRadius = UDim.new(0, 6)
        iconFrameCorner.Parent = iconFrame
        
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(1, 0, 1, 0)
        iconLabel.BackgroundTransparency = 1
        
        -- Iconos más elaborados para entrenamiento
        local trainingIcons = {
            MALE = {"👨‍🏭", "👨‍🔧", "👨‍⚔️", "🥋", "💪", "🏃‍♂️"},
            FEMALE = {"👩‍🏭", "👩‍🔧", "👩‍⚔️", "🥋", "💪", "🏃‍♀️"}
        }
        
        local rarityIndex = math.min(character.rarity or 1, 6)
        iconLabel.Text = trainingIcons[character.gender or "MALE"][rarityIndex]
        iconLabel.TextColor3 = rarityColors[character.rarity] or Color3.fromRGB(200, 200, 200)
        iconLabel.TextScaled = true
        iconLabel.Font = Enum.Font.SourceSans
        iconLabel.Parent = iconFrame
        
        local selectBtn = Instance.new("TextButton")
        selectBtn.Size = UDim2.new(1, -10, 0, 35)
        selectBtn.Position = UDim2.new(0, 5, 1, -40)
        selectBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        selectBtn.Text = "Seleccionar"
        selectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        selectBtn.TextScaled = true
        selectBtn.Font = Enum.Font.SourceSansBold
        selectBtn.Parent = card
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = selectBtn
        
        selectBtn.Activated:Connect(function()
            selectedCharacterForTraining = character
            
            -- Actualizar apariencia de todos los botones
            for _, child in pairs(trainingCharactersScroll:GetChildren()) do
                if child.Name:match("TrainingCard_") then
                    local btn = child:FindFirstChild("TextButton")
                    if btn then
                        if child.Name == "TrainingCard_" .. character.id then
                            btn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
                            btn.Text = "Seleccionado"
                        else
                            btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                            btn.Text = "Seleccionar"
                        end
                    end
                end
            end
        end)
        
        return card
    end
    
    -- Función para crear elemento de entrenamiento activo con progreso en tiempo real
    local function createActiveTrainingElement(character, trainingType, endTime, startTime)
        local element = Instance.new("Frame")
        element.Name = "ActiveTraining_" .. character.id
        element.Size = UDim2.new(1, -10, 0, 120)
        element.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
        element.Parent = trainingActiveScroll
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = element
        
        -- Panel de información del personaje
        local characterInfo = Instance.new("Frame")
        characterInfo.Size = UDim2.new(0.3, 0, 1, 0)
        characterInfo.Position = UDim2.new(0, 5, 0, 0)
        characterInfo.BackgroundTransparency = 1
        characterInfo.Parent = element
        
        local characterIcon = Instance.new("Frame")
        characterIcon.Size = UDim2.new(1, 0, 0.6, 0)
        characterIcon.Position = UDim2.new(0, 0, 0, 0)
        characterIcon.BackgroundColor3 = rarityColors[character.rarity] or Color3.fromRGB(200, 200, 200)
        characterIcon.Parent = characterInfo
        
        local iconCorner = Instance.new("UICorner")
        iconCorner.CornerRadius = UDim.new(0, 6)
        iconCorner.Parent = characterIcon
        
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(1, 0, 1, 0)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = character.name:sub(1, 2):upper()
        iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        iconLabel.TextScaled = true
        iconLabel.Font = Enum.Font.SourceSansBold
        iconLabel.Parent = characterIcon
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
        nameLabel.Position = UDim2.new(0, 0, 0.6, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = character.name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.Parent = characterInfo
        
        -- Panel de progreso
        local progressInfo = Instance.new("Frame")
        progressInfo.Size = UDim2.new(0.5, 0, 1, 0)
        progressInfo.Position = UDim2.new(0.3, 10, 0, 0)
        progressInfo.BackgroundTransparency = 1
        progressInfo.Parent = element
        
        local typeLabel = Instance.new("TextLabel")
        typeLabel.Size = UDim2.new(1, 0, 0, 25)
        typeLabel.Position = UDim2.new(0, 0, 0, 5)
        typeLabel.BackgroundTransparency = 1
        typeLabel.Text = "🎯 " .. trainingType
        typeLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        typeLabel.TextScaled = true
        typeLabel.Font = Enum.Font.SourceSansBold
        typeLabel.Parent = progressInfo
        
        -- Barra de progreso
        local progressBarBg = Instance.new("Frame")
        progressBarBg.Size = UDim2.new(1, 0, 0, 20)
        progressBarBg.Position = UDim2.new(0, 0, 0, 35)
        progressBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        progressBarBg.Parent = progressInfo
        
        local progressBarCorner = Instance.new("UICorner")
        progressBarCorner.CornerRadius = UDim.new(0, 10)
        progressBarCorner.Parent = progressBarBg
        
        local progressBar = Instance.new("Frame")
        progressBar.Name = "ProgressBar"
        progressBar.Size = UDim2.new(0, 0, 1, 0)
        progressBar.Position = UDim2.new(0, 0, 0, 0)
        progressBar.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
        progressBar.Parent = progressBarBg
        
        local progressBarFillCorner = Instance.new("UICorner")
        progressBarFillCorner.CornerRadius = UDim.new(0, 10)
        progressBarFillCorner.Parent = progressBar
        
        local timeLabel = Instance.new("TextLabel")
        timeLabel.Name = "TimeLabel"
        timeLabel.Size = UDim2.new(1, 0, 0, 25)
        timeLabel.Position = UDim2.new(0, 0, 0, 60)
        timeLabel.BackgroundTransparency = 1
        timeLabel.Text = "⏰ Calculando..."
        timeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        timeLabel.TextScaled = true
        timeLabel.Font = Enum.Font.SourceSans
        timeLabel.Parent = progressInfo
        
        local beforeStatsLabel = Instance.new("TextLabel")
        beforeStatsLabel.Size = UDim2.new(1, 0, 0, 20)
        beforeStatsLabel.Position = UDim2.new(0, 0, 0, 90)
        beforeStatsLabel.BackgroundTransparency = 1
        beforeStatsLabel.Text = "📊 Antes: ATK:" .. (character.attributes.strength or 0) .. " DEF:" .. (character.attributes.resistance or 0)
        beforeStatsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        beforeStatsLabel.TextScaled = true
        beforeStatsLabel.Font = Enum.Font.SourceSans
        beforeStatsLabel.Parent = progressInfo
        
        -- Panel de botones
        local buttonPanel = Instance.new("Frame")
        buttonPanel.Size = UDim2.new(0.2, 0, 1, 0)
        buttonPanel.Position = UDim2.new(0.8, 0, 0, 0)
        buttonPanel.BackgroundTransparency = 1
        buttonPanel.Parent = element
        
        local collectBtn = Instance.new("TextButton")
        collectBtn.Name = "CollectButton"
        collectBtn.Size = UDim2.new(1, -10, 0, 35)
        collectBtn.Position = UDim2.new(0, 5, 0, 10)
        collectBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        collectBtn.Text = "✅ Reclamar"
        collectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        collectBtn.TextScaled = true
        collectBtn.Font = Enum.Font.SourceSansBold
        collectBtn.Visible = false
        collectBtn.Parent = buttonPanel
        
        local collectCorner = Instance.new("UICorner")
        collectCorner.CornerRadius = UDim.new(0, 6)
        collectCorner.Parent = collectBtn
        
        local boostBtn = Instance.new("TextButton")
        boostBtn.Name = "BoostButton"
        boostBtn.Size = UDim2.new(1, -10, 0, 35)
        boostBtn.Position = UDim2.new(0, 5, 0, 55)
        boostBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
        boostBtn.Text = "⚡ Acelerar\n50 💎"
        boostBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        boostBtn.TextScaled = true
        boostBtn.Font = Enum.Font.SourceSansBold
        boostBtn.Parent = buttonPanel
        
        local boostCorner = Instance.new("UICorner")
        boostCorner.CornerRadius = UDim.new(0, 6)
        boostCorner.Parent = boostBtn
        
        -- Actualizar progreso en tiempo real
        local connection
        connection = game:GetService("RunService").Heartbeat:Connect(function()
            if not element.Parent then
                connection:Disconnect()
                return
            end
            
            local currentTime = tick()
            local totalDuration = endTime - (startTime or (endTime - 1800)) -- 30 min default
            local elapsed = currentTime - (startTime or (endTime - 1800))
            local remainingTime = endTime - currentTime
            
            if remainingTime <= 0 then
                -- Entrenamiento completado
                timeLabel.Text = "✅ ¡COMPLETADO!"
                timeLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                progressBar.Size = UDim2.new(1, 0, 1, 0)
                progressBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                collectBtn.Visible = true
                boostBtn.Visible = false
            else
                -- En progreso
                local progress = math.max(0, math.min(1, elapsed / totalDuration))
                progressBar.Size = UDim2.new(progress, 0, 1, 0)
                
                local hours = math.floor(remainingTime / 3600)
                local minutes = math.floor((remainingTime % 3600) / 60)
                local seconds = math.floor(remainingTime % 60)
                
                if hours > 0 then
                    timeLabel.Text = string.format("⏰ %dh %dm %ds", hours, minutes, seconds)
                else
                    timeLabel.Text = string.format("⏰ %dm %ds", minutes, seconds)
                end
                
                collectBtn.Visible = false
                boostBtn.Visible = true
            end
        end)
        
        -- Conectar botones
        collectBtn.Activated:Connect(function()
            -- Usar el RemoteFunction correcto para completar entrenamiento
            pcall(function()
                local completeTraining = eventsFolder:FindFirstChild("CompleteTraining")
                if completeTraining then
                    local success, result = completeTraining:InvokeServer(character.id)
                    if success then
                        showTrainingResults(result.improvements, result.leveledUp, result.experienceGained)
                        element:Destroy()
                        loadTrainingCharacters()
                        updateDailyTrainingStats()
                    else
                        showNotification("Error", result or "No se pudo completar el entrenamiento", "error", 3)
                    end
                end
            end)
        end)
        
        boostBtn.Activated:Connect(function()
            -- Usar el RemoteFunction correcto para acelerar entrenamiento
            pcall(function()
                local boostTraining = eventsFolder:FindFirstChild("BoostTraining")
                if boostTraining then
                    local success, result = boostTraining:InvokeServer(character.id)
                    if success then
                        showNotification("¡Acelerado!", "Entrenamiento completado instantáneamente", "success", 2)
                    else
                        showNotification("Error", result or "No se pudo acelerar el entrenamiento", "error", 3)
                    end
                end
            end)
        end)
        
        return element
    end
    
    -- Función para cargar personajes disponibles para entrenamiento
    local function loadTrainingCharacters()
        -- Limpiar lista actual
        for _, child in pairs(trainingCharactersScroll:GetChildren()) do
            if child.Name:match("TrainingCard_") then
                child:Destroy()
            end
        end
        
        -- Cargar personajes del jugador
        if allCharacters then
            for _, character in ipairs(allCharacters) do
                createTrainingCharacterCard(character, trainingCharactersScroll)
            end
            
            -- Ajustar tamaño del canvas
            local rows = math.ceil(#allCharacters / 4)
            trainingCharactersScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(300, rows * 190))
        end
    end
    
    -- Conectar botones de tipo de entrenamiento con funcionalidad mejorada
    for trainingType, button in pairs(trainingButtons) do
        button.Activated:Connect(function()
            if not selectedCharacterForTraining then
                showNotification("⚠️ Error", "Selecciona un personaje primero", "error", 3)
                return
            end
            
            -- Verificar límite diario
            if dailyTrainingCount >= 5 then
                showNotification("⚠️ Límite Alcanzado", "Has alcanzado el límite diario de entrenamientos (5/5)", "warning", 4)
                return
            end
            
            selectedTrainingType = trainingType
            
            -- Mostrar confirmación con detalles del entrenamiento
            local trainingData = {
                STRENGTH = {name = "Fuerza", duration = 30, cost = 100},
                INTELLIGENCE = {name = "Inteligencia", duration = 30, cost = 100},
                SPEED = {name = "Velocidad", duration = 30, cost = 100},
                RESISTANCE = {name = "Resistencia", duration = 30, cost = 100},
                CHARM = {name = "Carisma", duration = 30, cost = 100},
                LUCK = {name = "Suerte", duration = 45, cost = 150},
                BALANCED = {name = "Equilibrado", duration = 60, cost = 300}
            }
            
            local training = trainingData[trainingType]
            if not training then return end
            
            showNotification("🎯 Iniciando Entrenamiento", 
                string.format("Entrenando %s en %s\nDuración: %d min | Costo: %d 💰", 
                selectedCharacterForTraining.name, training.name, training.duration, training.cost), 
                "info", 3)
            
            -- Usar RemoteFunction correcto
            pcall(function()
                local startTraining = eventsFolder:FindFirstChild("StartTraining") or eventsFolder:WaitForChild("TrainCharacter")
                local success, result = startTraining:InvokeServer(selectedCharacterForTraining.id, trainingType)
                
                if success then
                    -- Crear elemento de entrenamiento activo con tiempo real
                    local startTime = tick()
                    local endTime = startTime + (training.duration * 60) -- Convertir minutos a segundos
                    createActiveTrainingElement(selectedCharacterForTraining, trainingType, endTime, startTime)
                    
                    -- Actualizar contadores
                    dailyTrainingCount = dailyTrainingCount + 1
                    updateDailyTrainingStats()
                    
                    -- Actualizar moneda (esto debería venir del servidor)
                    updateCurrencyDisplay({coins = (result.newCoins or 0), tickets = 0, premiumCurrency = 0}, uiElements)
                    
                    -- Limpiar selección
                    selectedCharacterForTraining = nil
                    selectedTrainingType = nil
                    loadTrainingCharacters()
                    
                    showNotification("✅ Éxito", "Entrenamiento iniciado para " .. (selectedCharacterForTraining and selectedCharacterForTraining.name or "personaje"), "success", 2)
                else
                    showNotification("❌ Error", result or "No se pudo iniciar el entrenamiento", "error", 4)
                end
            end)
        end)
    end
    
    -- Conectar botón de aceleración global
    if trainingBoostBtn then
        trainingBoostBtn.Activated:Connect(function()
            -- Encontrar entrenamientos activos
            local activeTrainingElements = {}
            for _, child in pairs(trainingActiveScroll:GetChildren()) do
                if child.Name:match("ActiveTraining_") then
                    table.insert(activeTrainingElements, child)
                end
            end
            
            if #activeTrainingElements == 0 then
                showNotification("⚠️ Sin Entrenamientos", "No tienes entrenamientos activos para acelerar", "warning", 3)
                return
            end
            
            -- Mostrar confirmación
            showNotification("⚡ Acelerar Todo", 
                string.format("¿Acelerar %d entrenamientos activos?\nCosto: %d 💎", 
                #activeTrainingElements, #activeTrainingElements * 50), 
                "info", 4)
            
            -- Acelerar todos los entrenamientos activos
            for _, element in ipairs(activeTrainingElements) do
                local characterId = element.Name:match("ActiveTraining_(.+)")
                if characterId then
                    pcall(function()
                        local boostTraining = eventsFolder:FindFirstChild("BoostTraining")
                        if boostTraining then
                            local success, result = boostTraining:InvokeServer(characterId)
                            if success then
                                showNotification("⚡ Acelerado", "Entrenamiento completado instantáneamente", "success", 1)
                            end
                        end
                    end)
                end
            end
        end)
    end
    
    -- FUNCIONALIDAD DE BATALLA
    local battleTeam = {}
    local isSelectingForTeam = false
    
    -- Función para mostrar selector de personajes para batalla
    local function showCharacterSelector()
        local selectorGui = Instance.new("ScreenGui")
        selectorGui.Name = "CharacterSelector"
        selectorGui.Parent = playerGui
        selectorGui.DisplayOrder = 250
        
        local backdrop = Instance.new("Frame")
        backdrop.Size = UDim2.new(1, 0, 1, 0)
        backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        backdrop.BackgroundTransparency = 0.3
        backdrop.Parent = selectorGui
        
        local selectorFrame = Instance.new("Frame")
        selectorFrame.Size = UDim2.new(0, 800, 0, 600)
        selectorFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
        selectorFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        selectorFrame.Parent = selectorGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 20)
        corner.Parent = selectorFrame
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -40, 0, 50)
        title.Position = UDim2.new(0, 20, 0, 20)
        title.BackgroundTransparency = 1
        title.Text = "Seleccionar Personajes para el Equipo"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextScaled = true
        title.Font = Enum.Font.SourceSansBold
        title.Parent = selectorFrame
        
        local charactersScroll = Instance.new("ScrollingFrame")
        charactersScroll.Size = UDim2.new(1, -40, 1, -140)
        charactersScroll.Position = UDim2.new(0, 20, 0, 80)
        charactersScroll.BackgroundTransparency = 1
        charactersScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        charactersScroll.ScrollBarThickness = 10
        charactersScroll.Parent = selectorFrame
        
        local gridLayout = Instance.new("UIGridLayout")
        gridLayout.CellSize = UDim2.new(0, 150, 0, 200)
        gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
        gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
        gridLayout.Parent = charactersScroll
        
        -- Crear tarjetas de personajes
        for _, character in ipairs(allCharacters or {}) do
            local card = Instance.new("Frame")
            card.Size = UDim2.new(0, 150, 0, 200)
            card.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
            card.Parent = charactersScroll
            
            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 10)
            cardCorner.Parent = card
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -10, 0, 30)
            nameLabel.Position = UDim2.new(0, 5, 0, 5)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = character.name
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextScaled = true
            nameLabel.Font = Enum.Font.SourceSansBold
            nameLabel.Parent = card
            
            local levelLabel = Instance.new("TextLabel")
            levelLabel.Size = UDim2.new(1, -10, 0, 20)
            levelLabel.Position = UDim2.new(0, 5, 0, 35)
            levelLabel.BackgroundTransparency = 1
            levelLabel.Text = "Lv." .. (character.level or 1) .. " | " .. string.rep("★", character.rarity or 1)
            levelLabel.TextColor3 = rarityColors[character.rarity] or Color3.fromRGB(200, 200, 200)
            levelLabel.TextScaled = true
            levelLabel.Font = Enum.Font.SourceSans
            levelLabel.Parent = card
            
            -- Agregar marco visual mejorado
            local visualFrame = Instance.new("Frame")
            visualFrame.Size = UDim2.new(1, -10, 0, 100)
            visualFrame.Position = UDim2.new(0, 5, 0, 60)
            visualFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            visualFrame.Parent = card
            
            local visualCorner = Instance.new("UICorner")
            visualCorner.CornerRadius = UDim.new(0, 8)
            visualCorner.Parent = visualFrame
            
            -- Borde de rareza
            local rarityBorder = Instance.new("UIStroke")
            rarityBorder.Thickness = 2
            rarityBorder.Color = rarityColors[character.rarity] or Color3.fromRGB(100, 100, 100)
            rarityBorder.Parent = visualFrame
            
            local battleIcon = Instance.new("TextLabel")
            battleIcon.Size = UDim2.new(1, 0, 1, 0)
            battleIcon.BackgroundTransparency = 1
            
            -- Iconos específicos para batalla
            local battleIcons = {
                MALE = {"🛡️", "⚔️", "🏹", "🔥", "⚡", "✨"},
                FEMALE = {"🛡️", "⚔️", "🏹", "🔥", "⚡", "✨"}
            }
            
            local rarityIndex = math.min(character.rarity or 1, 6)
            battleIcon.Text = battleIcons[character.gender or "MALE"][rarityIndex]
            battleIcon.TextColor3 = rarityColors[character.rarity] or Color3.fromRGB(200, 200, 200)
            battleIcon.TextScaled = true
            battleIcon.Font = Enum.Font.SourceSans
            battleIcon.Parent = visualFrame
            
            local selectBtn = Instance.new("TextButton")
            selectBtn.Size = UDim2.new(1, -10, 0, 40)
            selectBtn.Position = UDim2.new(0, 5, 1, -50)
            selectBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            selectBtn.Text = "Agregar al Equipo"
            selectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            selectBtn.TextScaled = true
            selectBtn.Font = Enum.Font.SourceSansBold
            selectBtn.Parent = card
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 8)
            btnCorner.Parent = selectBtn
            
            selectBtn.Activated:Connect(function()
                -- Verificar si ya está en el equipo
                for i, teamMember in ipairs(battleTeam) do
                    if teamMember.id == character.id then
                        return -- Ya está en el equipo
                    end
                end
                
                if #battleTeam < 5 then
                    table.insert(battleTeam, character)
                    selectorGui:Destroy()
                    updateBattleTeamDisplay()
                end
            end)
        end
        
        -- Ajustar tamaño del canvas
        local rows = math.ceil(#(allCharacters or {}) / 4)
        charactersScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(400, rows * 210))
        
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 100, 0, 40)
        closeBtn.Position = UDim2.new(1, -120, 1, -60)
        closeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
        closeBtn.Text = "Cerrar"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.TextScaled = true
        closeBtn.Font = Enum.Font.SourceSansBold
        closeBtn.Parent = selectorFrame
        
        local closeBtnCorner = Instance.new("UICorner")
        closeBtnCorner.CornerRadius = UDim.new(0, 8)
        closeBtnCorner.Parent = closeBtn
        
        closeBtn.Activated:Connect(function()
            selectorGui:Destroy()
        end)
        
        backdrop.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                selectorGui:Destroy()
            end
        end)
    end
    
    -- Función para actualizar la visualización del equipo de batalla
    local function updateBattleTeamDisplay()
        -- Actualizar slots de equipo
        for i = 1, 5 do
            local slot = teamSlots[i]
            if slot then
                if battleTeam[i] then
                    local character = battleTeam[i]
                    slot.emptyIcon.Visible = false
                    slot.slotLabel.Text = character.name
                    
                    -- Cambiar color según rareza
                    local rarityColors = {
                        [1] = Color3.fromRGB(169, 169, 169),
                        [2] = Color3.fromRGB(30, 255, 0),
                        [3] = Color3.fromRGB(0, 112, 255),
                        [4] = Color3.fromRGB(163, 53, 238),
                        [5] = Color3.fromRGB(255, 128, 0),
                        [6] = Color3.fromRGB(255, 215, 0)
                    }
                    slot.frame.BackgroundColor3 = rarityColors[character.rarity] or Color3.fromRGB(70, 70, 90)
                else
                    slot.emptyIcon.Visible = true
                    slot.slotLabel.Text = "Slot " .. i
                    slot.frame.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
                end
            end
        end
        
        -- Actualizar estadísticas del equipo
        local totalPower = 0
        local totalAttack = 0
        local totalDefense = 0
        local totalHealth = 0
        local totalSpeed = 0
        local teamSize = #battleTeam
        
        for _, character in ipairs(battleTeam) do
            local stats = character.stats or {}
            totalAttack = totalAttack + (stats.attack or 100)
            totalDefense = totalDefense + (stats.defense or 100)
            totalHealth = totalHealth + (stats.health or 500)
            totalSpeed = totalSpeed + (stats.speed or 50)
            totalPower = totalPower + ((stats.attack or 100) + (stats.defense or 100) + (stats.health or 500) / 10 + (stats.speed or 50))
        end
        
        -- Actualizar labels de estadísticas
        if statsPanel then
            local statValue1 = statsPanel:FindFirstChild("StatValue1")
            local statValue2 = statsPanel:FindFirstChild("StatValue2")
            local statValue3 = statsPanel:FindFirstChild("StatValue3")
            local statValue4 = statsPanel:FindFirstChild("StatValue4")
            local statValue5 = statsPanel:FindFirstChild("StatValue5")
            
            if statValue1 then statValue1.Text = tostring(math.floor(totalPower)) end
            if statValue2 then statValue2.Text = teamSize > 0 and tostring(math.floor(totalAttack / teamSize)) or "0" end
            if statValue3 then statValue3.Text = teamSize > 0 and tostring(math.floor(totalDefense / teamSize)) or "0" end
            if statValue4 then statValue4.Text = tostring(totalHealth) end
            if statValue5 then statValue5.Text = teamSize > 0 and tostring(math.floor(totalSpeed / teamSize)) or "0" end
        end
    end
    
    -- Conectar botones de slots de equipo
    for i, slot in ipairs(teamSlots) do
        slot.button.Activated:Connect(function()
            if battleTeam[i] then
                -- Remover personaje del equipo
                table.remove(battleTeam, i)
                updateBattleTeamDisplay()
            else
                -- Mostrar selector de personajes
                showCharacterSelector()
            end
        end)
    end
    
    -- SISTEMA DE NOTIFICACIONES
    local notifications = {}
    
    -- Función para crear notificación
    local function showNotification(title, message, type, duration)
        duration = duration or 3
        type = type or "info" -- info, success, error, warning
        
        local notificationGui = Instance.new("ScreenGui")
        notificationGui.Name = "Notification"
        notificationGui.Parent = playerGui
        notificationGui.DisplayOrder = 500
        
        local notification = Instance.new("Frame")
        notification.Size = UDim2.new(0, 350, 0, 80)
        notification.Position = UDim2.new(1, -370, 0, 20 + (#notifications * 90))
        notification.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        notification.Parent = notificationGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = notification
        
        local typeColors = {
            info = Color3.fromRGB(0, 162, 255),
            success = Color3.fromRGB(0, 255, 127),
            error = Color3.fromRGB(255, 50, 50),
            warning = Color3.fromRGB(255, 200, 0)
        }
        
        local typeIcons = {
            info = "ℹ️",
            success = "✅",
            error = "❌",
            warning = "⚠️"
        }
        
        local leftBorder = Instance.new("Frame")
        leftBorder.Size = UDim2.new(0, 4, 1, 0)
        leftBorder.Position = UDim2.new(0, 0, 0, 0)
        leftBorder.BackgroundColor3 = typeColors[type]
        leftBorder.Parent = notification
        
        local borderCorner = Instance.new("UICorner")
        borderCorner.CornerRadius = UDim.new(0, 10)
        borderCorner.Parent = leftBorder
        
        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.new(0, 30, 0, 30)
        icon.Position = UDim2.new(0, 15, 0, 10)
        icon.BackgroundTransparency = 1
        icon.Text = typeIcons[type]
        icon.TextColor3 = typeColors[type]
        icon.TextScaled = true
        icon.Font = Enum.Font.SourceSans
        icon.Parent = notification
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -60, 0, 25)
        titleLabel.Position = UDim2.new(0, 55, 0, 5)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextScaled = true
        titleLabel.Font = Enum.Font.SourceSansBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = notification
        
        local messageLabel = Instance.new("TextLabel")
        messageLabel.Size = UDim2.new(1, -60, 0, 40)
        messageLabel.Position = UDim2.new(0, 55, 0, 30)
        messageLabel.BackgroundTransparency = 1
        messageLabel.Text = message
        messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        messageLabel.TextScaled = true
        messageLabel.Font = Enum.Font.SourceSans
        messageLabel.TextXAlignment = Enum.TextXAlignment.Left
        messageLabel.TextWrapped = true
        messageLabel.Parent = notification
        
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 20, 0, 20)
        closeBtn.Position = UDim2.new(1, -25, 0, 5)
        closeBtn.BackgroundTransparency = 1
        closeBtn.Text = "✖"
        closeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        closeBtn.TextScaled = true
        closeBtn.Font = Enum.Font.SourceSans
        closeBtn.Parent = notification
        
        -- Animación de entrada
        notification.Position = UDim2.new(1, 0, 0, 20 + (#notifications * 90))
        local enterTween = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Position = UDim2.new(1, -370, 0, 20 + (#notifications * 90))
        })
        enterTween:Play()
        
        -- Agregar a la lista de notificaciones
        table.insert(notifications, {gui = notificationGui, frame = notification})
        
        -- Función para remover la notificación
        local function removeNotification()
            -- Animación de salida
            local exitTween = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Position = UDim2.new(1, 0, 0, notification.Position.Y.Offset)
            })
            exitTween:Play()
            
            exitTween.Completed:Connect(function()
                -- Remover de la lista
                for i, notif in ipairs(notifications) do
                    if notif.gui == notificationGui then
                        table.remove(notifications, i)
                        break
                    end
                end
                
                -- Reposicionar notificaciones restantes
                for i, notif in ipairs(notifications) do
                    local newPosition = UDim2.new(1, -370, 0, 20 + ((i-1) * 90))
                    local repositionTween = TweenService:Create(notif.frame, TweenInfo.new(0.2), {Position = newPosition})
                    repositionTween:Play()
                end
                
                notificationGui:Destroy()
            end)
        end
        
        closeBtn.Activated:Connect(removeNotification)
        
        -- Auto-remover después de la duración especificada
        spawn(function()
            wait(duration)
            if notificationGui.Parent then
                removeNotification()
            end
        end)
    end
    
    -- Función para mostrar notificaciones rápidas
    local function showToast(message, type)
        showNotification("", message, type, 2)
    end
    
    -- Eventos de notificaciones personalizadas
    local function connectTrainingNotifications()
        -- Notificación cuando se completa un entrenamiento
        spawn(function()
            while true do
                wait(5) -- Verificar cada 5 segundos
                
                for _, child in pairs(trainingActiveScroll:GetChildren()) do
                    if child.Name:match("ActiveTraining_") then
                        local timeLabel = child:FindFirstChild("TimeLabel")
                        local collectBtn = child:FindFirstChild("CollectButton")
                        
                        if timeLabel and collectBtn and collectBtn.Visible and timeLabel.Text:find("completado") then
                            -- Solo mostrar notificación si no se ha mostrado antes
                            if not child:GetAttribute("NotificationShown") then
                                showNotification("Entrenamiento Completado", "Un personaje ha terminado su entrenamiento!", "success", 5)
                                child:SetAttribute("NotificationShown", true)
                            end
                        end
                    end
                end
            end
        end)
    end
    
    -- Modificar las funciones existentes para usar notificaciones
    local originalTrainingActivated = trainingButtons and trainingButtons["ATK"] and trainingButtons["ATK"].Activated
    
    -- Conectar botones de entrenamiento con notificaciones
    for trainingType, button in pairs(trainingButtons) do
        button.Activated:Connect(function()
            if not selectedCharacterForTraining then
                showNotification("Error", "Selecciona un personaje primero", "error", 3)
                return
            end
        end)
    end
    
    -- Notificación para gacha results
    gachaPullResult.OnClientEvent:Connect(function(result)
        if result and result.character then
            local rarityNames = {"Común", "No Común", "Raro", "Épico", "Legendario", "Mítico"}
            local rarityName = rarityNames[result.character.rarity] or "Común"
            local notificationType = "success"
            
            if result.character.rarity >= 4 then
                notificationType = "success"
                showNotification("¡Personaje Épico!", 
                    string.format("¡Obtienes %s (%s)!", result.character.name, rarityName), 
                    notificationType, 6)
            end
            
            showGachaResult(result.character, result.isNew)
        end
    end)
    
    -- Notificaciones para moneda actualizada
    currencyUpdated.OnClientEvent:Connect(function(newCurrency)
        updateCurrencyDisplay(newCurrency, uiElements)
        -- Mostrar notificación solo si hay un aumento significativo
        if newCurrency and (newCurrency.coins > 100 or newCurrency.freeTickets > 0 or newCurrency.premiumCurrency > 0) then
            showToast("Recursos actualizados", "info")
        end
    end)
    
    -- Inicializar notificaciones de entrenamiento
    connectTrainingNotifications()
    
    -- Cargar colección inicial
    loadCharacterCollection()
    
    -- Cargar personajes de entrenamiento cuando se abra el panel
    spawn(function()
        wait(2) -- Esperar a que se carguen los personajes
        loadTrainingCharacters()
    end)
    
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