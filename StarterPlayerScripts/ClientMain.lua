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
    
    -- Crear panel de gacha
    local gachaPanel, singleBtn, multiBtn = createGachaPanel(uiElements.contentPanel)
    
    -- Conectar botones de gacha
    singleBtn.Activated:Connect(function()
        local pullGacha = eventsFolder:WaitForChild("PullGacha")
        pullGacha:InvokeServer("FREE", 1)
    end)
    
    multiBtn.Activated:Connect(function()
        local pullGacha = eventsFolder:WaitForChild("PullGacha")
        pullGacha:InvokeServer("FREE", 10)
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