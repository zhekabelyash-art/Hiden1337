local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetReplicatedStorage()

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Настройки
local STEAL_ZONE = Vector3.new(0, 50, 0) -- Координаты зоны сбора, замени на реальные
local STEAL_RADIUS = 50

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotHubGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local toggleButton = Instance.new("ImageButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 60, 0, 60)
toggleButton.Position = UDim2.new(0, 20, 0, 20)
toggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
toggleButton.BorderColor3 = Color3.fromRGB(100, 200, 255)
toggleButton.BorderSizePixel = 2
toggleButton.Parent = screenGui

local toggleLabel = Instance.new("TextLabel")
toggleLabel.Name = "Label"
toggleLabel.Size = UDim2.new(1, 0, 1, 0)
toggleLabel.BackgroundTransparency = 1
toggleLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
toggleLabel.TextSize = 18
toggleLabel.Font = Enum.Font.GothamBold
toggleLabel.Text = "≡"
toggleLabel.Parent = toggleButton

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 450)
mainFrame.Position = UDim2.new(0, 100, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BorderColor3 = Color3.fromRGB(100, 200, 255)
mainFrame.BorderSizePixel = 2
mainFrame.Parent = screenGui
mainFrame.Visible = true

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
title.TextColor3 = Color3.fromRGB(100, 200, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Text = "BRAINROT HUB"
title.BorderSizePixel = 0
title.Parent = mainFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, -10, 1, -50)
scrollFrame.Position = UDim2.new(0, 5, 0, 45)
scrollFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 8
scrollFrame.Parent = mainFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 8)
uiListLayout.Parent = scrollFrame

-- Состояние фич
local features = {
	InfiniteJump = false,
	InstantSteal = false,
	SteelFloor = false,
	DropBrainrot = false,
	AutoBuy = false,
	SpeedBoost = false
}

local buttons = {}

-- Создание кнопок
local function createButton(featureName, description)
	local button = Instance.new("TextButton")
	button.Name = featureName
	button.Size = UDim2.new(1, -10, 0, 45)
	button.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	button.TextColor3 = Color3.fromRGB(200, 200, 200)
	button.TextSize = 13
	button.Font = Enum.Font.Gotham
	button.Text = featureName .. " [OFF]"
	button.BorderColor3 = Color3.fromRGB(60, 60, 80)
	button.BorderSizePixel = 1
	button.Parent = scrollFrame
	
	button.MouseButton1Click:Connect(function()
		features[featureName] = not features[featureName]
		local status = features[featureName] and "[ON]" or "[OFF]"
		local color = features[featureName] and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(200, 200, 200)
		button.Text = featureName .. " " .. status
		button.TextColor3 = color
	end)
	
	buttons[featureName] = button
end

createButton("InfiniteJump", "Бесконечные прыжки")
createButton("InstantSteal", "Моментальное воровство")
createButton("SteelFloor", "Стальная платформа")
createButton("DropBrainrot", "Выбросить бреинрота")
createButton("AutoBuy", "Автопокупка")
createButton("SpeedBoost", "Ускорение")

-- Toggle основного меню
toggleButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

-- INFINITE JUMP
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Space and features.InfiniteJump then
		character = player.Character
		if character then
			humanoid = character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end
end)

-- INSTANT STEAL (Grab)
local function fireGrabEvent()
	local net = ReplicatedStorage:FindFirstChild("Packages")
	if net then
		local remoteFolder = net:FindFirstChild("Net")
		if remoteFolder then
			local grabEvent = remoteFolder:FindFirstChild("RE") 
			if not grabEvent then
				-- Ищем любой RemoteEvent с "Grab" в имени
				for _, v in pairs(remoteFolder:GetDescendants()) do
					if v:IsA("RemoteEvent") and string.find(v.Name:lower(), "grab") then
						grabEvent = v
						break
					end
				end
			end
			if grabEvent then
				grabEvent:FireServer()
			end
		end
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.E and features.InstantSteal then
		fireGrabEvent()
	end
end)

-- STEEL FLOOR
local steelFloorActive = false
local function createAndMaintainSteelFloor()
	if not steelFloorActive or not features.SteelFloor then return end
	
	character = player.Character
	if not character then return end
	humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end
	
	local floor = Instance.new("Part")
	floor.Name = "SteelFloor"
	floor.Shape = Enum.PartType.Block
	floor.Material = Enum.Material.Metal
	floor.Size = Vector3.new(30, 2, 30)
	floor.CanCollide = true
	floor.CFrame = humanoidRootPart.CFrame - Vector3.new(0, 4, 0)
	floor.TopSurface = Enum.SurfaceType.Smooth
	floor.BottomSurface = Enum.SurfaceType.Smooth
	floor.Parent = workspace
	
	game:GetService("Debris"):AddItem(floor, 15)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.F then
		if features.SteelFloor then
			steelFloorActive = true
			createAndMaintainSteelFloor()
		end
	end
end)

-- DROP BRAINROT
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.G and features.DropBrainrot then
		local net = ReplicatedStorage:FindFirstChild("Packages")
		if net then
			local remoteFolder = net:FindFirstChild("Net")
			if remoteFolder then
				local dropEvent = remoteFolder:FindFirstChild("RE")
				if dropEvent then
					dropEvent:FireServer()
				end
			end
		end
	end
end)

-- AUTO BUY
if features.AutoBuy then
	local net = ReplicatedStorage:FindFirstChild("Packages")
	if net then
		local remoteFolder = net:FindFirstChild("Net")
		if remoteFolder then
			local autoBuyFunc = remoteFolder:FindFirstChild("RF")
			if autoBuyFunc then
				autoBuyFunc:InvokeServer(true)
			end
		end
	end
end

-- SPEED BOOST
local speedBoost = 1
RunService.RenderStepped:Connect(function()
	if features.SpeedBoost then
		character = player.Character
		if character then
			humanoid = character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = 25
			end
		end
	else
		character = player.Character
		if character then
			humanoid = character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = 16
			end
		end
	end
end)

-- Handle respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
end)
