-- Hub: Hiden1337 | Roblox Lua
-- deps: Roblox Studio, LocalScript в StarterPlayer.StarterCharacterScripts или StarterGui

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- ============= КОНФИГ =============
local CONFIG = {
    STEAL_BASE_POS = Vector3.new(100, 50, 100), -- позиция зоны сбора (замени на свою)
    INFINITE_JUMP_ENABLED = false,
    INSTANT_STEAL_ENABLED = false,
    STEEL_FLOOR_ENABLED = false,
    DROP_ENABLED = false,
    AUTO_BUY_ENABLED = false,
    SPEED_UPGRADE_ENABLED = false,
    STEEL_FLOOR_SPEED = 50, -- скорость подъёма платформы
    JUMP_KEY = Enum.KeyCode.Space,
    STEAL_KEY = Enum.KeyCode.E,
    DROP_KEY = Enum.KeyCode.R,
}

-- ============= GUI =============
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Hiden1337"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Иконка тогла
local toggleButton = Instance.new("ImageButton")
toggleButton.Name = "ToggleIcon"
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 20, 0, 20)
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.BorderSizePixel = 0
toggleButton.Image = "rbxasset://textures/Cursor.png"
toggleButton.Parent = screenGui

-- Главная панель
local mainPanel = Instance.new("Frame")
mainPanel.Name = "MainPanel"
mainPanel.Size = UDim2.new(0, 300, 0, 400)
mainPanel.Position = UDim2.new(0, 100, 0, 100)
mainPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainPanel.BorderSizePixel = 2
mainPanel.BorderColor3 = Color3.fromRGB(0, 255, 150)
mainPanel.Parent = screenGui
mainPanel.Visible = false

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "HIDEN1337"
titleLabel.Parent = mainPanel

-- Функция создания кнопки
local function createToggleButton(parent, name, configKey, yOffset)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, -10, 0, 35)
    button.Position = UDim2.new(0, 5, 0, 50 + yOffset)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.Text = name .. ": OFF"
    button.Parent = parent
    
    button.MouseButton1Click:Connect(function()
        CONFIG[configKey] = not CONFIG[configKey]
        button.Text = name .. ": " .. (CONFIG[configKey] and "ON" or "OFF")
        button.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(40, 40, 50)
    end)
    
    return button
end

createToggleButton(mainPanel, "Infinite Jump", "INFINITE_JUMP_ENABLED", 0)
createToggleButton(mainPanel, "Instant Steal", "INSTANT_STEAL_ENABLED", 45)
createToggleButton(mainPanel, "Steel Floor", "STEEL_FLOOR_ENABLED", 90)
createToggleButton(mainPanel, "Drop Brainrot", "DROP_ENABLED", 135)
createToggleButton(mainPanel, "Auto Buy", "AUTO_BUY_ENABLED", 180)
createToggleButton(mainPanel, "Speed Upgrade", "SPEED_UPGRADE_ENABLED", 225)

-- Логика тогла панели
toggleButton.MouseButton1Click:Connect(function()
    mainPanel.Visible = not mainPanel.Visible
    toggleButton.BackgroundColor3 = mainPanel.Visible and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(30, 30, 30)
end)

-- ============= МЕХАНИКИ =============

-- Infinite Jump (срабатывает при приземлении)
humanoid.StateChanged:Connect(function(oldState, newState)
    if not CONFIG.INFINITE_JUMP_ENABLED then return end
    
    if newState == Enum.HumanoidStateType.Landed then
        wait(0.05)
        humanoid:Jump()
    end
end)

-- Steel Floor (платформа с автоматическим подъёмом)
local steelFloor = nil
local steelFloorVelocity = nil

RunService.RenderStepped:Connect(function()
    if not CONFIG.STEEL_FLOOR_ENABLED then
        if steelFloor then
            steelFloor:Destroy()
            steelFloor = nil
        end
        if steelFloorVelocity then
            steelFloorVelocity:Destroy()
            steelFloorVelocity = nil
        end
        return
    end
    
    if not steelFloor then
        steelFloor = Instance.new("Part")
        steelFloor.Name = "SteelFloor"
        steelFloor.Shape = Enum.PartType.Block
        steelFloor.Size = Vector3.new(15, 1, 15)
        steelFloor.Material = Enum.Material.Metal
        steelFloor.CanCollide = true
        steelFloor.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, -5, 0))
        steelFloor.TopSurface = Enum.SurfaceType.Smooth
        steelFloor.BottomSurface = Enum.SurfaceType.Smooth
        steelFloor.Parent = workspace
        
        steelFloorVelocity = Instance.new("BodyVelocity")
        steelFloorVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        steelFloorVelocity.Velocity = Vector3.new(0, CONFIG.STEEL_FLOOR_SPEED, 0)
        steelFloorVelocity.Parent = steelFloor
    end
    
    -- Позиция платформы под игроком
    steelFloor.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, -5, 0))
    
    -- Пассивный подъём туловища вверх
    humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
        humanoidRootPart.AssemblyLinearVelocity.X,
        CONFIG.STEEL_FLOOR_SPEED,
        humanoidRootPart.AssemblyLinearVelocity.Z
    )
end)

-- Instant Steal (телепорт на базу с бреинротом)
local function performInstantSteal()
    if not CONFIG.INSTANT_STEAL_ENABLED then return end
    
    local stealEvent = ReplicatedStorage:FindFirstChild("Packages")
    if stealEvent then
        local path = stealEvent:FindFirstChild("Net")
        if path then
            local re = path:FindFirstChild("RE")
            if re then
                local stealService = re:FindFirstChild("StealService")
                if stealService then
                    local grabEvent = stealService:FindFirstChild("Grab")
                    if grabEvent then
                        grabEvent:FireServer()
                        wait(0.1)
                        humanoidRootPart.CFrame = CFrame.new(CONFIG.STEAL_BASE_POS)
                    end
                end
            end
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == CONFIG.STEAL_KEY then
        performInstantSteal()
    end
end)

-- Drop Brainrot (выкинуть бреинрота)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == CONFIG.DROP_KEY and CONFIG.DROP_ENABLED then
        local tools = character:FindFirstChildOfClass("Tool")
        if tools then
            tools.Parent = workspace
        end
    end
end)

-- Auto Buy (автопокупка монет)
local function toggleAutoBuy()
    if not CONFIG.AUTO_BUY_ENABLED then return end
    
    local coinsShop = ReplicatedStorage:FindFirstChild("Packages")
    if coinsShop then
        local net = coinsShop:FindFirstChild("Net")
        if net then
            local rf = net:FindFirstChild("RF")
            if rf then
                local service = rf:FindFirstChild("CoinsShopService")
                if service then
                    local toggle = service:FindFirstChild("ToggleAutoBuy")
                    if toggle then
                        toggle:InvokeServer(true)
                    end
                end
            end
        end
    end
end

-- Speed Upgrade (прокачка скорости)
local function buySpeedUpgrade()
    if not CONFIG.SPEED_UPGRADE_ENABLED then return end
    
    local tsunami = ReplicatedStorage:FindFirstChild("Packages")
    if tsunami then
        local net = tsunami:FindFirstChild("Net")
        if net then
            local re = net:FindFirstChild("RE")
            if re then
                local eventService = re:FindFirstChild("TsunamiEventService")
                if eventService then
                    local upgradeEvent = eventService:FindFirstChild("BuySpeedUpgrade")
                    if upgradeEvent then
                        upgradeEvent:FireServer()
                    end
                end
            end
        end
    end
end

-- Периодическая проверка состояния
RunService.Heartbeat:Connect(function()
    if CONFIG.AUTO_BUY_ENABLED then
        toggleAutoBuy()
    end
    
    if CONFIG.SPEED_UPGRADE_ENABLED then
        buySpeedUpgrade()
    end
end)

-- ============= ОЧИСТКА =============
character.Humanoid.Died:Connect(function()
    if steelFloor then
        steelFloor:Destroy()
    end
    if steelFloorVelocity then
        steelFloorVelocity:Destroy()
    end
end)

print("[Hiden1337] Инициализирован. Готов к работе.")
