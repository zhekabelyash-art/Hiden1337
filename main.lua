local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Ждём загрузки интерфейса
local playerGui = player:WaitForChild("PlayerGui")
wait(0.5)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

print("[HUB] GUI создан") -- Для дебага

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

-- Заголовок
local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 35)
header.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
header.TextColor3 = Color3.fromRGB(255, 255, 255)
header.Text = "BRAINROT HUB"
header.FontSize = Enum.FontSize.Size18
header.Parent = mainMenu

-- Контейнер для кнопок
local buttonContainer = Instance.new("Frame")
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

print("[HUB] Меню загружено и видимо")
