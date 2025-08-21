-- ClientMain.lua
-- Script principal del cliente que inicializa la UI y maneja eventos

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Requerir RemoteEvents
require(ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Init"))

-- Esperar a que los módulos estén disponibles
local CharacterTypes = require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("CharacterTypes"))
local GameConfig = require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("GameConfig"))
local Utilities = require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Utilities"))

-- ======================== UI CREATION FUNCTIONS ========================

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
        {name = "Shop", text = "🛒 Tienda", icon = "🛒"}
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

-- Función simple completada
print("✅ ClientMain_New.lua loaded successfully!")