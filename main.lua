-- node: meridian/gui_hub_demo
-- deps: built-in Roblox UI libs

-- Создание экрана‑UI
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DemoHub"
screenGui.Parent = PlayerGui

-- иконка, сворачивающая окно
local iconButton = Instance.new("ImageButton")
iconButton.Name = "ToggleButton"
iconButton.Size = UDim2.new(0, 50, 0, 50)
iconButton.Position = UDim2.new(0, 20, 0, 20)
iconButton.Image = "rbxassetid://3926305904" -- пример иконки
iconButton.Parent = screenGui

-- основное окно
local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 200, 0, 250)
mainFrame.Position = UDim2.new(0, 80, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Visible = true
mainFrame.Parent = screenGui

-- кнопки функций
local function createButton(name, text, posY)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Text = text
	b.Size = UDim2.new(0, 180, 0, 30)
	b.Position = UDim2.new(0, 10, 0, posY)
	b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Parent = mainFrame
	return b
end

local jumpButton   = createButton("InfJump",  "Infinite Jump", 10)
local stealButton  = createButton("Instant",  "Instant Steal", 50)
local floorButton  = createButton("SteelFlr", "Steel Floor", 90)
local dropButton   = createButton("DropBr",   "Drop Brainrot",130)

-- пример логики сворачивания
iconButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

-- заглушки: сюда можно вставить легитимные игровые действия
jumpButton.MouseButton1Click:Connect(function()
	print("[DemoHub] Infinite Jump placeholder triggered")
end)

stealButton.MouseButton1Click:Connect(function()
	print("[DemoHub] Instant Steal placeholder triggered")
end)

floorButton.MouseButton1Click:Connect(function()
	print("[DemoHub] Steel Floor placeholder triggered")
end)

dropButton.MouseButton1Click:Connect(function()
	print("[DemoHub] Drop Brainrot placeholder triggered")
end)
