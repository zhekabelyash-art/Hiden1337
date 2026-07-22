--[[
    ZERO HUB // Roblox Script
    Developer: N零
    Version: 1.0.0
    Dependencies: None (Pure Lua/Luau)
]]

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- SERVICES INITIALIZATION
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- NETWORK REMOTES & FUNCTIONS REGISTRY
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

local NetPackage
pcall(function()
    NetPackage = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net")
end)

if not NetPackage then
    warn("[ZeroHub::CRITICAL] Пакет 'Packages.Net' не найден. Убедитесь что игра загружена.")
    return
end

local NetworkRemotes = {
    Grab = nil,
    Purchase = nil,
    SpeedUpgrade = nil
}

local NetworkFunctions = {
    AutoBuy = nil
}

pcall(function()
    local RE = NetPackage:WaitForChild("RE")
    local RF = NetPackage:WaitForChild("RF")
    
    NetworkRemotes.Grab = RE:WaitForChild("StealService"):WaitForChild("Grab")
    NetworkRemotes.Purchase = RE:WaitForChild("ShopService"):WaitForChild("Purchase")
    NetworkRemotes.SpeedUpgrade = RE:WaitForChild("TsunamiEventService"):WaitForChild("BuySpeedUpgrade")
    
    NetworkFunctions.AutoBuy = RF:WaitForChild("CoinsShopService"):WaitForChild("ToggleAutoBuy")
end)

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- CONFIGURATION TABLE
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

local Config = {
    BasePosition = Vector3.new(0, 100, 0), -- >>> ЗАМЕНИТЬ НА КООРДИНАТЫ ЗОНЫ СБОРА <<<
    FloorSpeed = 4,
    FloorColor = Color3.fromRGB(40, 180, 255),
    AntiAFKInterval = 300,
    Theme = {
        Primary = Color3.fromRGB(25, 25, 35),
        Secondary = Color3.fromRGB(35, 35, 48),
        Accent = Color3.fromRGB(85, 170, 255),
        TextPrimary = Color3.fromRGB(240, 240, 245),
        TextSecondary = Color3.fromRGB(160, 160, 175),
        Danger = Color3.fromRGB(220, 65, 65),
        Success = Color3.fromRGB(65, 200, 120),
        Warning = Color3.fromRGB(220, 180, 50),
        Border = Color3.fromRGB(55, 55, 70)
    }
}

-- State tracking
local State = {
    InfiniteJump = false,
    SteelFloor = false,
    AutoSteal = false,
    AutoFarm = false,
    AntiAFK = false,
    AutoSpeed = false,
    GUIVisible = true
}

-- Connection references for cleanup
local Connections = {}

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- UTILITY FUNCTIONS
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetHumanoid()
    local char = GetCharacter()
    if char then
        return char:FindFirstChildOfClass("Humanoid") or char:FindFirstChild("Humanoid")
    end
    return nil
end

local function GetRootPart()
    local char = GetCharacter()
    if char then
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    end
    return nil
end

local function GetHeldTool()
    local char = GetCharacter()
    if char then
        return char:FindFirstChildOfClass("Tool")
    end
    return nil
end

local function SafeFireServer(remote, ...)
    if remote and remote.FireServer then
        pcall(remote.FireServer, remote, ...)
    end
end

local function SafeInvokeServer(func, ...)
    if func and func.InvokeServer then
        local success, result = pcall(func.InvokeServer, func, ...)
        if success then return result end
    end
    return nil
end

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- FEATURE: INFINITE JUMP
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

local function EnableInfiniteJump()
    if Connections.InfiniteJump then return true end
    
    Connections.InfiniteJump = UserInputService.JumpRequest:Connect(function()
        local humanoid = GetHumanoid()
        if humanoid and humanoid.Health > 0 then
            local stateType = humanoid:GetState()
            if stateType == Enum.HumanoidStateType.Jumping or 
               stateType == Enum.HumanoidStateType.Freefall or 
               stateType == Enum.HumanoidStateType.Seated or
               stateType == Enum.HumanoidStateType.Running then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    
    State.InfiniteJump = true
    return true
end

local function DisableInfiniteJump()
    if Connections.InfiniteJump then
        Connections.InfiniteJump:Disconnect()
        Connections.InfiniteJump = nil
    end
    State.InfiniteJump = false
    return false
end

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- FEATURE: STEEL FLOOR (RISING PLATFORM)
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

local FloorPart = nil
local FloorBodyPosition = nil

local function CreateSteelFloor()
    if FloorPart then return end
    
    local rootPart = GetRootPart()
    if not rootPart then 
        warn("[ZeroHub] Нет HumanoidRootPart для создания пола")
        return 
    end
    
    FloorPart = Instance.new("Part")
    FloorPart.Name = "ZeroSteelFloor"
    FloorPart.Size = Vector3.new(10, 1, 10)
    FloorPart.Color = Config.Theme.Accent
    FloorPart.Material = Enum.Material.Neon
    FloorPart.Transparency = 0.15
    FloorPart.CanCollide = true
    FloorPart.Anchored = true
    FloorPart.CastShadow = false
    FloorPart.Parent = workspace
    
    -- Декоративные элементы
    local glow = Instance.new("PointLight")
    glow.Color = Config.FloorColor
    glow.Brightness = 1.5
    glow.Range = 12
    glow.Parent = FloorPart
    
    local ui = Instance.new("SurfaceGui")
    ui.Face = Enum.NormalId.Top
    ui.Parent = FloorPart
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "STEEL FLOOR"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.Parent = ui
    
    -- BodyPosition для плавного подъёма
    FloorBodyPosition = Instance.new("BodyPosition")
    FloorBodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    FloorBodyPosition.P = 50000
    FloorBodyPosition.D = 1000
    FloorBodyPosition.Parent = FloorPart
    
    -- RenderStepped loop for following player + rising
    Connections.SteelFloor = RunService.RenderStepped:Connect(function(deltaTime)
        if not FloorPart or not State.SteelFloor then return end
        
        local rp = GetRootPart()
        if rp then
            local currentPos = rp.Position
            local targetPos = Vector3.new(currentPos.X, currentPos.Y - 3.5, currentPos.Z)
            
            -- Подъём
            if State.SteelFloor then
                targetPos = targetPos + Vector3.new(0, Config.FloorSpeed * deltaTime * 0.8, 0)
            end
            
            FloorBodyPosition.Position = targetPos
            FloorPart.CFrame = CFrame.new(FloorBodyPosition.Position)
            
            -- Визуальный эффект вращения текстуры если нужно
            FloorPart.Orientation = Vector3.new(0, tick() * 5 % 360, 0)
        end
    end)
end

local function DestroySteelFloor()
    if Connections.SteelFloor then
        Connections.SteelFloor:Disconnect()
        Connections.SteelFloor = nil
    end
    
    if FloorPart then
        FloorPart:Destroy()
        FloorPart = nil
        FloorBodyPosition = nil
    end
end

local function ToggleSteelFloor()
    State.SteelFloor = not State.SteelFloor
    
    if State.SteelFloor then
        CreateSteelFloor()
    else
        DestroySteelFloor()
    end
    
    return State.SteelFloor
end

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- FEATURE: INSTANT STEAL (TELEPORT TO BASE WITH ITEM)
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

local function ExecuteInstantSteal()
    local tool = GetHeldTool()
    local rootPart = GetRootPart()
    local humanoid = GetHumanoid()
    
    if not tool then
        warn("[ZeroHub] Ошибка: Нет предмета в руках для телепортации.")
        return false, "NO_TOOL"
    end
    
    if not rootPart then
        return false, "NO_ROOTPART"
    end
    
    -- Активация захвата если нужно
    SafeFireServer(NetworkRemotes.Grab)
    
    task.wait(0.08) -- Минимальная задержка для обработки сервером
    
    -- Телепорт на базу
    local targetCFrame = CFrame.new(Config.BasePosition) * CFrame.new(0, 8, 0)
    local oldCam = workspace.CurrentCamera.CameraType
    
    -- Анти-fall через временное изменение CameraType
    workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed
    
    for i = 1, 3 do
        if rootPart then
            rootPart.CFrame = targetCFrame
            task.wait(0.03)
        end
    end
    
    workspace.CurrentCamera.CameraType = oldCam
    
    return true, "SUCCESS"
end

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- FEATURE: DROP BRAINROT (DROP HELD ITEM)
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

local function ExecuteDropItem()
    local character = GetCharacter()
    if not character then return false end
    
    local tool = GetHeldTool()
    if not tool then
        warn("[ZeroHub] Нечего дропать - пустые руки")
        return false
    end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return false end
    
    -- Метод 1: Прямой parent swap (перенос в рюкзак)
    tool.Parent = backpack
    task.wait(0.05)
    
    -- Если нужен actual drop на пол - ищем Drop remote или симулируем
    local dropped = false
    
    -- Поиск через getreg скрытых функций drop
    for _, v in pairs(getreg()) do
        if type(v) == "function" then
            local info = debug.getinfo(v)
            if info.name == "Drop" or info.name == "drop" or 
               (info.source and string.find(info.source, "Drop")) then
                local success = pcall(function() v(tool) end)
                if success then 
                    dropped = true
                    break 
                end
            end
        end
    end
    
    if not dropped then
        -- Fallback: эмулируем дроп через изменение позиции
        local clone = tool:Clone()
        clone.Parent = workspace
        
        local rp = GetRootPart()
        if rp then
            clone:PivotTo(rp.CFrame * CFrame.new(0, -3, 2))
        end
        
        tool:Destroy()
    end
    
    return true
end

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- FEATURE: AUTO FARM / AUTO BUY SYSTEMS
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

local FarmLoopCount = 0

local function StartAutoBuy()
    if Connections.AutoBuy then return end
    
    Connections.AutoBuy = task.spawn(function()
        while State.AutoFarm do
            if NetworkFunctions.AutoBuy then
                -- Принудительная активация автопокупки (бесплатно)
                SafeInvokeServer(NetworkFunctions.AutoBuy, true)
                
                -- Также покупка базовых улучшений при наличии монет
                if NetworkRemotes.Purchase then
                    SafeFireServer(NetworkRemotes.Purchase, {ItemName = "BasicUpgrade", Quantity = 1})
                end
            end
            
            task.wait(2) -- Throttle для избежания rate-limit
            FarmLoopCount = FarmLoopCount + 1
        end
    end)
end

local function StopAutoBuy()
    if Connections.AutoBuy then
        task.cancel(Connections.AutoBuy)
        Connections.AutoBuy = nil
        FarmLoopCount = 0
    end
end

local function StartAutoSpeed()
    if Connections.AutoSpeed then return end
    
    Connections.AutoSpeed = task.spawn(function()
        while State.AutoSpeed do
            if NetworkRemotes.SpeedUpgrade then
                SafeFireServer(NetworkRemotes.SpeedUpgrade)
            end
            task.wait(3) -- Задержка между апгрейдами скорости
        end
    end)
end

local function StopAutoSpeed()
    if Connections.AutoSpeed then
        task.cancel(Connections.AutoSpeed)
        Connections.AutoSpeed = nil
    end
end

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- FEATURE: ANTI-AFK
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

local function EnableAntiAFK()
    if Connections.AntiAFK then return end
    
    -- Прямая манипуляция Idle для обхода AFK кика
    LocalPlayer.Idled:Connect(function(time)
        if State.AntiAFK and time > Config.AntiAFKInterval then
            VirtualUser = VirtualUser or Instance.new("VirtualUser")
            VirtualUser:CaptureController()
            VirtualUser:SetKeyDown("0x1F") -- Нажатие клавиши
            wait(0.1)
            VirtualUser:SetKeyUp("0x1F")
        end
    end)
    
    -- Дополнительный heartbeat keep-alive
    Connections.AntiAFK = RunService.Heartbeat:Connect(function()
        if State.AntiAFK then
            local humanoid = GetHumanoid()
            if humanoid then
                -- Сброс таймера бездействия (для некоторых игр)
                humanoid.JumpPower = humanoid.JumpPower + 0.0001
                humanoid.JumpPower = humanoid.JumpPower - 0.0001
            end
        end
    end)
    
    State.AntiAFK = true
end

local function DisableAntiAFK()
    if Connections.AntiAFK then
        Connections.AntiAFK:Disconnect()
        Connections.AntiAFK = nil
    end
    State.AntiAFK = false
end

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- GUI CONSTRUCTION
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

-- Main container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZeroHub_GUI_v1_0"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Prevent multiple instances
if LocalPlayer.PlayerGui:FindFirstChild("ZeroHub_GUI_v1_0") then
    local existing = LocalPlayer.PlayerGui:FindFirstChild("ZeroHub_GUI_v1_0")
    if existing ~= ScreenGui then
        existing:Destroy()
    end
end

-- Toggle Button (иконка-переключатель видимости)
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "HubToggle"
ToggleButton.Size = UDim2.new(0, 52, 0, 52)
ToggleButton.Position = UDim2.new(0, 16, 0, 16)
ToggleButton.BackgroundColor3 = Config.Theme.Secondary
ToggleButton.BorderSizePixel = 0
ToggleButton.Image = "rbxassetid://7743867447" -- Placeholder image ID
ToggleButton.ImageColor3 = Config.Theme.Accent
ToggleButton.ScaleType = Enum.ScaleType.Fit
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 14)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Config.Theme.Border
ToggleStroke.Thickness = 1.5
ToggleStroke.Parent = ToggleButton

-- Glow effect for toggle
local ToggleGlow = Instance.new("ImageLabel")
ToggleGlow.Name = "Glow"
ToggleGlow.AnchorPoint = Vector2.new(0.5, 0.5)
ToggleGlow.Size = UDim2.new(1, 20, 1, 20)
ToggleGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
ToggleGlow.BackgroundColor3 = Color3.new(1, 1, 1)
ToggleGlow.BackgroundTransparency = 1
ToggleGlow.Image = "rbxassetid://6015897843" -- Glow asset
ToggleGlow.ImageColor3 = Config.Theme.Accent
ToggleGlow.ImageTransparency = 0.6
ToggleGlow.ZIndex = -1
ToggleGlow.Parent = ToggleButton

-- Main Frame Container
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainContainer"
MainFrame.Size = UDim2.new(0, 380, 0, 480)
MainFrame.Position = UDim2.new(0, 78, 0, 18)
MainFrame.BackgroundColor3 = Config.Theme.Primary
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MF_Corner = Instance.new("UICorner")
MF_Corner.CornerRadius = UDim.new(0, 12)
MF_Corner.Parent = MainFrame

local MF_Stroke = Instance.new("UIStroke")
MF_Stroke.Color = Config.Theme.Border
MF_Stroke.Thickness = 1.2
MF_Stroke.Parent = MainFrame

-- Header Bar
local HeaderBar = Instance.new("Frame")
HeaderBar.Name = "HeaderBar"
HeaderBar.Size = UDim2.new(1, 0, 0, 42)
HeaderBar.BackgroundColor3 = Config.Theme.Secondary
HeaderBar.BorderSizePixel = 0
HeaderBar.Parent = MainFrame

local HB_Corner = Instance.new("UICorner")
HB_Corner.CornerRadius = UDim.new(0, 12)
HB_Corner.Parent = HeaderBar

-- Cover bottom corners of header
local HB_Cover = Instance.new("Frame")
HB_Cover.Size = UDim2.new(1, 0, 0, 12)
HB_Cover.Position = UDim2.new(0, 0, 30, 0)
HB_Cover.BackgroundColor3 = Config.Theme.Secondary
HB_Cover.BorderSizePixel = 0
HB_Cover.ZIndex = 2
HB_Cover.Parent = HeaderBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "  Z E R O   H U B"
TitleLabel.TextColor3 = Config.Theme.TextPrimary
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 17
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 3
TitleLabel.Parent = HeaderBar

local Subtitle = Instance.new("TextLabel")
Subtitle.Name = "Subtitle"
Subtitle.Size = UDim2.new(1, -120, 1, 0)
Subtitle.Position = UDim2.new(0, 0, 22, 0)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "// Brainrot Utilities Suite v1.0"
Subtitle.TextColor3 = Config.Theme.TextSecondary
Subtitle.Font = Enum.Font.Code
Subtitle.TextSize = 11
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.ZIndex = 3
Subtitle.Parent = HeaderBar

-- Close button inside header
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 56)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Config.Theme.Danger
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 22
CloseBtn.ZIndex = 3
CloseBtn.Parent = HeaderBar

local CB_Corner = Instance.new("UICorner")
CB_Corner.CornerRadius = UDim.new(0, 6)
CB_Corner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    State.GUIVisible = not State.GUIVisible
    MainFrame.Visible = State.GUIVisible
    ToggleButton.ImageColor3 = State.GUIVisible and Config.Theme.Accent or Color3.fromRGB(100, 100, 110)
end)

-- Sidebar Navigation
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 105, 1, -50)
Sidebar.Position = UDim2.new(0, 0, 0, 46)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SB_Corner = Instance.new("UICorner")
SB_Corner.CornerRadius = UDim.new(0, 12)
SB_Corner.Parent = Sidebar

-- Content area
local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -115, 1, -54)
ContentArea.Position = UDim2.new(0, 110, 0, 48)
ContentArea.BackgroundTransparency = 1
ContentArea.ScrollBarThickness = 3
ContentArea.ScrollBarImageColor3 = Config.Theme.Accent
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentArea.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 6)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = ContentArea

ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentArea.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 12)
end)

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- UI COMPONENT GENERATORS
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

-- Section header
local function CreateSectionLabel(text, parent)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 26)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local lineLeft = Instance.new("Frame")
    lineLeft.Size = UDim2.new(1, 0, 0, 1)
    lineLeft.Position = UDim2.new(0, 0, 0, 13)
    lineLeft.BackgroundColor3 = Config.Theme.Border
    lineLeft.BorderSizePixel = 0
    lineLeft.Parent = container
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, #text * 9 + 24, 0, 22)
    bg.Position = UDim2.new(0, 12, 0, 2)
    bg.BackgroundColor3 = Config.Theme.Secondary
    bg.Parent = container
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 4)
    bgCorner.Parent = bg
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text:upper()
    label.TextColor3 = Config.Theme.Accent
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 12
    label.Parent = bg
    
    return container
end

-- Toggle switch component
local function CreateToggle(name, description, defaultState, callback, parent)
    local order = #parent:GetChildren()
    
    local container = Instance.new("Frame")
    container.Name = name .. "_Toggle"
    container.Size = UDim2.new(1, 0, 0, 44)
    container.BackgroundColor3 = Config.Theme.Secondary
    container.LayoutOrder = order
    container.Parent = parent
    
    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 8)
    cCorner.Parent = container
    
    local leftSection = Instance.new("Frame")
    leftSection.Name = "TextSection"
    leftSection.Size = UDim2.new(1, -70, 1, 0)
    leftSection.BackgroundTransparency = 1
    leftSection.Parent = container
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "FeatureName"
    nameLabel.Size = UDim2.new(1, -16, 0.55, 0)
    nameLabel.Position = UDim2.new(0, 12, 0, 2)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Config.Theme.TextPrimary
    nameLabel.Font = Enum.Font.GothamSemibold
    nameLabel.TextSize = 13
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = leftSection
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.Size = UDim2.new(1, -16, 0.4, 0)
    descLabel.Position = UDim2.new(0, 12, 0.58, 0)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description or ""
    descLabel.TextColor3 = Config.Theme.TextSecondary
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextWrapped = true
    descLabel.Parent = leftSection
    
    -- Toggle Switch
    local switchBg = Instance.new("TextButton")
    switchBg.Name = "Switch"
    switchBg.Size = UDim2.new(0, 48, 0, 26)
    switchBg.Position = UDim2.new(1, -56, 0.5, -13)
    switchBg.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
    switchBg.Text = ""
    switchBg.AutoButtonColor = false
    switchBg.ZIndex = 2
    switchBg.Parent = container
    
    local swCorner = Instance.new("UICorner")
    swCorner.CornerRadius = UDim.new(1, 0)
    swCorner.Parent = switchBg
    
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new(0, 3, 0.5, -10)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.ZIndex = 3
    knob.Parent = switchBg
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    -- State management
    local currentState = defaultState or false
    local updateVisuals = function(state)
        TweenService:Create(switchBg, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            BackgroundColor3 = state and Config.Theme.Success or Color3.fromRGB(55, 55, 68)
        }):Play()
        
        TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        }):Play()
        
        if callback then callback(state) end
    end
    
    -- Initialize visual state
    updateVisuals(currentState)
    
    switchBg.MouseButton1Click:Connect(function()
        currentState = not currentState
        updateVisuals(currentState)
    end)
    
    return container, function() return currentState end, function(s) currentState = s; updateVisuals(s) end
end

-- Action button component (for single-use actions like Steal/Drop)
local function CreateActionButton(name, color, callback, parent)
    local container = Instance.new("Frame")
    container.Name = name .. "_Action"
    container.Size = UDim2.new(1, 0, 0, 38)
    container.BackgroundColor3 = color
    container.LayoutOrder = #parent:GetChildren()
    container.Parent = parent
    
    local acCorner = Instance.new("UICorner")
    acCorner.CornerRadius = UDim.new(0, 8)
    acCorner.Parent = container
    
    local btn = Instance.new("TextButton")
    btn.Name = "ActionBtn"
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ">> " .. name .. " <<"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = container
    
    btn.MouseButton1Click:Connect(callback)
    
    return container, btn
end

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- POPULATE UI SECTIONS
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

-- MOVEMENT SECTION
CreateSectionLabel("MOVEMENT", ContentArea)
CreateToggle("Infinite Jump", "Бесконечные прыжки в воздухе", false, function(state)
    if state then return EnableInfiniteJump() else return not DisableInfiniteJump() end
end, ContentArea)

CreateToggle("Steel Floor", "Поднимающаяся платформа под ногами", false, function(state)
    return ToggleSteelFloor()
end, ContentArea)

CreateToggle("Anti-AFK", "Предотвращение кика за неактивность", false, function(state)
    if state then EnableAntiAFK() else DisableAntiAFK() end
    return state
end, ContentArea)

-- STEAL SECTION
CreateSectionLabel("STEAL OPERATIONS", ContentArea)

local _, stealBtnObj = CreateActionButton("INSTANT STEAL", Config.Theme.Danger, function()
    local success, code = ExecuteInstantSteal()
    stealBtnObj.Text = success and "[ TELEPORTED ]" or ("[ " .. code .. " ]")
    stealBtnObj.TextColor3 = success and Config.Theme.Success or Config.Theme.Warning
    task.delay(1.2, function()
        stealBtnObj.Text = ">> INSTANT STEAL <<"
        stealBtnObj.TextColor3 = Color3.new(1,1,1)
    end)
end, ContentArea)

local _, dropBtnObj = CreateActionButton("DROP ITEM", Config.Theme.Warning, function()
    local success = ExecuteDropItem()
    dropBtnObj.Text = success and "[ DROPPED ]" or "[ EMPTY ]"
    dropBtnObj.TextColor3 = success and Config.Theme.Success or Color3.fromRGB(150,150,150)
    task.delay(1, function()
        dropBtnObj.Text = ">> DROP ITEM <<"
        dropBtnObj.TextColor3 = Color3.new(1,1,1)
    end)
end, ContentArea)

CreateToggle("Auto Grab Loop", "Автоматический захват ближайших объектов", false, function(state)
    State.AutoSteal = state
    if state then
        Connections.AutoGrab = RunService.RenderStepped:Connect(function()
            if State.AutoSteal and NetworkRemotes.Grab then
                SafeFireServer(NetworkRemotes.Grab)
            end
        end)
    else
        if Connections.AutoGrab then
            Connections.AutoGrab:Disconnect()
            Connections.AutoGrab = nil
        end
    end
    return state
end, ContentArea)

-- FARM SECTION  
CreateSectionLabel("AUTOMATION", ContentArea)

CreateToggle("Auto Buy", "Принудительный автопокупок улучшений", false, function(state)
    State.AutoFarm = state
    if state then StartAutoBuy() else StopAutoBuy() end
    return state
end, ContentArea)

CreateToggle("Auto Speed Upgrade", "Автоматическая прокачка скорости", false, function(state)
    State.AutoSpeed = state
    if state then StartAutoSpeed() else StopAutoSpeed() end
    return state
end, ContentArea)

-- MISCELLANEOUS
CreateSectionLabel("MISC SETTINGS", ContentArea)

CreateToggle("Noclip Mode", "Проход сквозь стены", false, function(state)
    if state then
        Connections.Noclip = RunService.Stepped:Connect(function()
            local char = GetCharacter()
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if Connections.Noclip then
            Connections.Noclip:Disconnect()
            Connections.Noclip = nil
            -- Restore collision
            local char = GetCharacter()
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
    return state
end, ContentArea)

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- DRAG FUNCTIONALITY FOR MAIN FRAME
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

local dragging
local dragInput
local dragStart
local startPos

local function Update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

HeaderBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

HeaderBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        Update(input)
    end
end)

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- EXTERNAL TOGGLE BUTTON BEHAVIOR
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

ToggleButton.MouseButton1Click:Connect(function()
    State.GUIVisible = not State.GUIVisible
    MainFrame.Visible = State.GUIVisible
    
    -- Visual feedback on toggle icon
    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
        ImageColor3 = State.GUIVisible and Config.Theme.Accent or Color3.fromRGB(90, 90, 100)
    }):Play()
    
    -- Scale animation
    TweenService:Create(ToggleButton, TweenInfo.new(0.15), {
        Size = State.GUIVisible and UDim2.new(0, 48, 0, 48) or UDim2.new(0, 52, 0, 52)
    }):Play()
end)

-- Right-click to destroy hub completely
ToggleButton.MouseButton2Click:Connect(function()
    -- Cleanup all connections
    for _, conn in pairs(Connections) do
        if conn then
            if type(conn.Disconnect) == "function" then conn:Disconnect() elseif type(conn) == "thread" then task.cancel(conn) end
        end
    end
    
    DestroySteelFloor()
    ScreenGui:Destroy()
    
    print("[ZeroHub] Hub terminated by user request.")
end)

-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
-- INITIALIZATION COMPLETE
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

print("[ZeroHub] Initialized successfully.")
print("[ZeroHub] Base position set to:", tostring(Config.BasePosition))
print("[ZeroHub] Right-click toggle icon to close hub permanently.")
