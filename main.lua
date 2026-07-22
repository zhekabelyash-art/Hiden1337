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
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")
wait(0.5)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Hidden1337"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

print("[Hidden1337] GUI создан")

-- Кнопка тогла
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "Toggle"
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "▼"
toggleBtn.FontSize = Enum.FontSize.Size24
toggleBtn.Parent = screenGui

-- Основное меню
local mainMenu = Instance.new("Frame")
mainMenu.Name = "Menu"
mainMenu.Size = UDim2.new(0, 250, 0, 300)
mainMenu.Position = UDim2.new(0, 70, 0, 10)
mainMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainMenu.BorderColor3 = Color3.fromRGB(0, 150, 200)
mainMenu.BorderSizePixel = 2
mainMenu.Parent = screenGui
mainMenu.Active = true
mainMenu.Draggable = true

-- Заголовок
local header = Instance.new("TextLabel")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 35)
header.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
header.TextColor3 = Color3.fromRGB(255, 255, 255)
header.Text = "HIDEN1337"
header.FontSize = Enum.FontSize.Size18
header.Parent = mainMenu
header.Active = true
header.Draggable = true

-- Контейнер для кнопок
local buttonContainer = Instance.new("Frame")
buttonContainer.Name = "ButtonContainer"
buttonContainer.Size = UDim2.new(1, -10, 1, -45)
buttonContainer.Position = UDim2.new(0, 5, 0, 40)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = mainMenu

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = buttonContainer

-- Фичи
local features = {
	InfiniteJump = false,
	InstantSteal = false,
	SteelFloor = false,
	DropBrainrot = false,
	AutoBuy = false
}

-- Создание кнопок фич
for featureName, _ in pairs(features) do
	local btn = Instance.new("TextButton")
	btn.Name = featureName
	btn.Size = UDim2.new(1, 0, 0, 35)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	btn.Text = featureName .. " [OFF]"
	btn.FontSize = Enum.FontSize.Size14
	btn.Parent = buttonContainer
	btn.Active = false
	
	btn.MouseButton1Click:Connect(function()
		features[featureName] = not features[featureName]
		btn.Text = featureName .. (features[featureName] and " [ON]" or " [OFF]")
		btn.BackgroundColor3 = features[featureName] and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(40, 40, 60)
	end)
end

-- Тогл видимости меню
local menuVisible = true
toggleBtn.MouseButton1Click:Connect(function()
	menuVisible = not menuVisible
	mainMenu.Visible = menuVisible
	toggleBtn.Text = menuVisible and "▼" or "▶"
end)

print("[Hidden1337] Меню загружено и видимо")
print("[Hidden1337] Меню можно перемещать за заголовок")
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
