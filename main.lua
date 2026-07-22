-- // Steal A Brainrot – Hiden Hub v3 (Merid Adjust)
-- // фиксы: быстрый и маленький Steel Floor, мягкий Infinite Jump, нет Drop/Stats

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer

local function getChar()
    return lp.Character or lp.CharacterAdded:Wait()
end

local function getHum()
    local c = getChar()
    return c:WaitForChild("Humanoid"), c
end

local function getHRP()
    local c = getChar()
    return c:WaitForChild("HumanoidRootPart"), c
end

-- ============ FLAGS ============

getgenv().SAB_InfiniteJump = false
getgenv().SAB_SteelFloor = false
getgenv().SAB_InstantSteal = false

local SteelPart = nil
local SavedBaseCF = nil

-- ============ GUI ============

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SAB_MeridHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = false
ScreenGui.Parent = CoreGui

local IconButton = Instance.new("ImageButton")
IconButton.Name = "ToggleButton"
IconButton.Size = UDim2.new(0, 60, 0, 60)
IconButton.Position = UDim2.new(0, 20, 0.5, -30)
IconButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
IconButton.BorderSizePixel = 0
IconButton.AutoButtonColor = true
IconButton.Image = "rbxassetid://7734068321" -- замени на свой asset
IconButton.Parent = ScreenGui

local UICornerIcon = Instance.new("UICorner")
UICornerIcon.CornerRadius = UDim.new(0, 14)
UICornerIcon.Parent = IconButton

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 190) -- ещё компактнее
MainFrame.Position = UDim2.new(0, 95, 0.5, -95)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 12)
UICornerMain.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 32)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local UICornerTop = Instance.new("UICorner")
UICornerTop.CornerRadius = UDim.new(0, 12)
UICornerTop.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Steal A Brainrot | Hiden Hub"
TitleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.GothamSemibold
TitleLabel.TextSize = 14
TitleLabel.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Position = UDim2.new(1, -28, 0.5, -12)
CloseButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(220, 220, 220)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = TopBar

local UICornerClose = Instance.new("UICorner")
UICornerClose.CornerRadius = UDim.new(1, 0)
UICornerClose.Parent = CloseButton

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "Content"
ContentFrame.Size = UDim2.new(1, -20, 1, -42)
ContentFrame.Position = UDim2.new(0, 10, 0, 36)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
UIListLayout.Parent = ContentFrame

local function makeToggle(name, default, callback)
    local outer = Instance.new("Frame")
    outer.Size = UDim2.new(1, 0, 0, 24)
    outer.BackgroundTransparency = 1
    outer.Parent = ContentFrame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 160, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.BorderSizePixel = 0
    btn.Text = default and "[ON] " .. name or "[OFF] " .. name
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.Parent = outer

    local UICornerBtn = Instance.new("UICorner")
    UICornerBtn.CornerRadius = UDim.new(0, 8)
    UICornerBtn.Parent = btn

    local state = default

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = (state and "[ON] " or "[OFF] ") .. name
        callback(state)
    end)
end

local function makeButton(name, callback)
    local outer = Instance.new("Frame")
    outer.Size = UDim2.new(1, 0, 0, 24)
    outer.BackgroundTransparency = 1
    outer.Parent = ContentFrame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 230, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.Parent = outer

    local UICornerBtn = Instance.new("UICorner")
    UICornerBtn.CornerRadius = UDim.new(0, 8)
    UICornerBtn.Parent = btn

    btn.MouseButton1Click:Connect(function()
        callback()
    end)
end

local function makeLabel(text)
    local lab = Instance.new("TextLabel")
    lab.Size = UDim2.new(1, 0, 0, 18)
    lab.BackgroundTransparency = 1
    lab.Text = text
    lab.TextColor3 = Color3.fromRGB(200, 200, 200)
    lab.Font = Enum.Font.Gotham
    lab.TextXAlignment = Enum.TextXAlignment.Left
    lab.TextSize = 12
    lab.Parent = ContentFrame
    return lab
end

local function toggleMainVisible()
    MainFrame.Visible = not MainFrame.Visible
end

IconButton.MouseButton1Click:Connect(toggleMainVisible)
CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- перетаскивание окна
do
    local dragging, dragInput, dragStart, startPos

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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

    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============ FEATURES ============

makeLabel("Movement / Utility")

-- мягкий Infinite Jump: форсим переход в Jumping при запросе прыжка
UIS.JumpRequest:Connect(function()
    if not getgenv().SAB_InfiniteJump then return end
    local hum = getHum()
    if hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

makeToggle("Infinite Jump", false, function(state)
    getgenv().SAB_InfiniteJump = state
end)

-- Steel Floor: меньше размер, быстрее трекинг
local function ensureSteelPart()
    if SteelPart and SteelPart.Parent then return SteelPart end
    local hrp = getHRP()
    local p = Instance.new("Part")
    p.Name = "SAB_SteelFloor"
    p.Size = Vector3.new(4, 0.7, 4) -- уменьшен размер
    p.Anchored = true
    p.CanCollide = true
    p.Material = Enum.Material.Metal
    p.Color = Color3.fromRGB(120, 120, 120)
    p.CFrame = hrp.CFrame * CFrame.new(0, -2.5, 0)
    p.Parent = workspace
    SteelPart = p
    return SteelPart
end

local function steelFloorLoop()
    while getgenv().SAB_SteelFloor do
        task.wait(0.02) -- ещё быстрее
        pcall(function()
            local hrp = getHRP()
            local p = ensureSteelPart()
            p.CFrame = hrp.CFrame * CFrame.new(0, -2.5, 0)
        end)
    end
    if SteelPart then
        SteelPart:Destroy()
        SteelPart = nil
    end
end

makeToggle("Steel Floor (под тобой)", false, function(state)
    getgenv().SAB_SteelFloor = state
    if state then
        task.spawn(steelFloorLoop)
    else
        if SteelPart then
            SteelPart:Destroy()
            SteelPart = nil
        end
    end
end)

makeLabel("Steal / Base")

makeButton("Сохранить позицию Зоны Сбора (стой на зелёном)", function()
    local hrp = getHRP()
    SavedBaseCF = hrp.CFrame
end)

local function instantSteal()
    if not SavedBaseCF then return end
    local hrp = getHRP()
    hrp.CFrame = SavedBaseCF
end

makeToggle("Instant Steal (G → TP на Зону Сбора)", false, function(state)
    getgenv().SAB_InstantSteal = state
end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.G and getgenv().SAB_InstantSteal then
        instantSteal()
    end
end)
