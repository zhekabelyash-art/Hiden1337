local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetReplicatedStorage()
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Конфиг
local CONFIG = {
	STEAL_ZONE = Vector3.new(0, 50, 0),
	SPEED_BOOST = 32,
	DEFAULT_SPEED = 16,
	FLOOR_SIZE = Vector3.new(30, 2, 30),
	FLOOR_Y_OFFSET = -4
}

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Hidden1337"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "Toggle"
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 15, 0, 15)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
toggleBtn.BorderColor3 = Color3.fromRGB(80, 160, 255)
toggleBtn.BorderSizePixel = 2
toggleBtn.TextColor3 = Color3.fromRGB(120, 180, 255)
toggleBtn.Text = "≡"
toggleBtn.TextSize = 20
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = screenGui

local mainMenu = Instance.new("Frame")
mainMenu.Name = "Menu"
mainMenu.Size = UDim2.new(0, 280, 0, 380)
mainMenu.Position = UDim2.new(0, 80, 0, 15)
mainMenu.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
mainMenu.BorderColor3 = Color3.fromRGB(80, 160, 255)
mainMenu.BorderSizePixel = 2
mainMenu.Parent = screenGui

local header = Instance.new("TextLabel")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 36)
header.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
header.TextColor3 = Color3.fromRGB(120, 180, 255)
header.TextSize = 16
header.Font = Enum.Font.GothamBold
header.Text = "HIDDEN1337"
header.BorderSizePixel = 0
header.Parent = mainMenu

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "Scroll"
scrollFrame.Size = UDim2.new(1, -10, 1, -46)
scrollFrame.Position = UDim2.new(0, 5, 0, 41)
scrollFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 80, 120)
scrollFrame.Parent = mainMenu

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.Parent = scrollFrame

-- Состояние
local features = {
	InfiniteJump = false,
	InstantSteal = false,
	SteelFloor = false,
	DropBrainrot = false,
	AutoBuy = false,
	SpeedBoost = false
}

local steelFloor = nil
local menuVisible = true

-- Перетаскивание
local isDragging = false
local dragStart = nil
local menuStart = nil

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDragging = true
		dragStart = Vector2.new(input.Position.X, input.Position.Y)
		menuStart = mainMenu.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
		mainMenu.Position = UDim2.new(
			menuStart.X.Scale, menuStart.X.Offset + delta.X,
			menuStart.Y.Scale, menuStart.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if isDragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
		isDragging = false
	end
end)

-- Создание кнопки фичи
local function createFeatureButton(name)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(1, 0, 0, 38)
	btn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
	btn.TextColor3 = Color3.fromRGB(200, 210, 220)
	btn.TextSize = 13
	btn.Font = Enum.Font.Gotham
	btn.Text = name .. " [OFF]"
	btn.BorderSizePixel = 1
	btn.BorderColor3 = Color3.fromRGB(60, 70, 90)
	btn.Parent = scrollFrame

	btn.MouseButton1Click:Connect(function()
		features[name] = not features[name]
		btn.Text = name .. (features[name] and " [ON]" or " [OFF]")
		btn.BackgroundColor3 = features[name] and Color3.fromRGB(30, 90, 60) or Color3.fromRGB(35, 40, 55)
		btn.TextColor3 = features[name] and Color3.fromRGB(120, 255, 160) or Color3.fromRGB(200, 210, 220)
	end)
end

for name, _ in pairs(features) do
	createFeatureButton(name)
end

-- Тогл меню
toggleBtn.MouseButton1Click:Connect(function()
	menuVisible = not menuVisible
	mainMenu.Visible = menuVisible
	toggleBtn.Text = menuVisible and "≡" or "▶"
end)

-- RemoteEvent/Function поиск
local function findRemote(path)
	local obj = ReplicatedStorage:FindFirstChild(path)
	if obj then return obj end
	for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
		if v.Name:lower() == path:lower() and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
			return v
		end
	end
	return nil
end

local grabEvent = findRemote("Packages.Net.RE.StealService.Grab") or findRemote("Grab")
local purchaseRemote = findRemote("Packages.Net.RE.ShopService.Purchase")
local autoBuyRemote = findRemote("Packages.Net.RF.CoinsShopService.ToggleAutoBuy")
local speedRemote = findRemote("Packages.Net.RE.TsunamiEventService.BuySpeedUpgrade")

-- INFINITE JUMP
UserInputService.InputBegan:Connect(function(input, gp)
	if gp or not features.InfiniteJump then return end
	if input.KeyCode == Enum.KeyCode.Space then
		character = player.Character
		if character and character:FindFirstChild("Humanoid") then
			character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

-- INSTANT STEAL
local function performInstantSteal()
	if not grabEvent then return end
	grabEvent:FireServer()
	
	character = player.Character
	if not character then return end
	humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end
	
	humanoidRootPart.CFrame = CFrame.new(CONFIG.STEAL_ZONE)
	humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
end

UserInputService.InputBegan:Connect(function(input, gp)
	if gp or not features.InstantSteal then return end
	if input.KeyCode == Enum.KeyCode.E then
		performInstantSteal()
	end
end)

-- STEEL FLOOR
local function updateSteelFloor()
	if not features.SteelFloor then
		if steelFloor then
			steelFloor:Destroy()
			steelFloor = nil
		end
		return
	end
	
	character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	if not steelFloor then
		steelFloor = Instance.new("Part")
		steelFloor.Name = "SteelFloor"
		steelFloor.Shape = Enum.PartType.Block
		steelFloor.Material = Enum.Material.Metal
		steelFloor.Size = CONFIG.FLOOR_SIZE
		steelFloor.CanCollide = true
		steelFloor.Anchored = false
		steelFloor.TopSurface = Enum.SurfaceType.Smooth
		steelFloor.BottomSurface = Enum.SurfaceType.Smooth
		steelFloor.Parent = workspace
		Debris:AddItem(steelFloor, 10)
	end
	
	steelFloor.CFrame = CFrame.new(
		hrp.Position.X, hrp.Position.Y + CONFIG.FLOOR_Y_OFFSET, hrp.Position.Z
	)
end

RunService.RenderStepped:Connect(updateSteelFloor)

-- DROP BRAINROT
local function dropHeldItem()
	character = player.Character
	if not character then return end
	
	local tool = character:FindFirstChildOfClass("Tool")
	if tool then
		tool.Parent = workspace
		tool.Handle.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2, 3)
		return
	end
	
	for _, part in pairs(character:GetChildren()) do
		if part:IsA("BasePart") and part.Name:lower():find("brainrot") then
			part.Parent = workspace
			part.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2, 3)
			return
		end
	end
end

UserInputService.InputBegan:Connect(function(input, gp)
	if gp or not features.DropBrainrot then return end
	if input.KeyCode == Enum.KeyCode.G then
		dropHeldItem()
	end
end)

-- AUTO BUY & SPEED BOOST
local function applyAutoBuy()
	if autoBuyRemote and features.AutoBuy then
		autoBuyRemote:InvokeServer(true)
	end
end

local function updateSpeed()
	character = player.Character
	if not character then return end
	local hum = character:FindFirstChild("Humanoid")
	if not hum then return end
	
	if features.SpeedBoost then
		hum.WalkSpeed = CONFIG.SPEED_BOOST
		if speedRemote then speedRemote:FireServer() end
	else
		hum.WalkSpeed = CONFIG.DEFAULT_SPEED
	end
end

RunService.RenderStepped:Connect(updateSpeed)

-- Инициализация
task.spawn(applyAutoBuy)

-- Респавн
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
	task.wait(1)
	updateSpeed()
	applyAutoBuy()
end)
