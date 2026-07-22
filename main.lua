-- хаб: MeridianHub
-- deps: Roblox Lua (LocalScript в StarterGui или workspace)
-- RemoteEvent’ы: в соответствии с указанными путями (проверить актуальность перед запуском)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Конфигурация
local infJumpEnabled = false
local instantStealEnabled = false
local steelFloorEnabled = false
local dropBrainrotEnabled = false
local farmEnabled = false
local autoUpgradeEnabled = false

-- Координаты зоны сбора (настраиваются)
local COLLECTION_ZONE_POS = Vector3.new(0, 0, 0) -- Заменить на реальные координаты

-- GUI элементы (исправлено)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MeridianHub"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Создаём иконку-круг
local iconButton = Instance.new("ImageButton")
iconButton.Size = UDim2.new(0, 50, 0, 50)
iconButton.Position = UDim2.new(0.8, 0, 0.1, 0)
iconButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- видимый фон, если картинка не грузится
iconButton.BackgroundTransparency = 0.2
iconButton.Image = "" -- оставляем пустым, используем фон
iconButton.AutoButtonColor = false
iconButton.Parent = screenGui

-- Круглая обводка
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = iconButton

-- Лейбл внутри (как значок)
local iconLabel = Instance.new("TextLabel")
iconLabel.Size = UDim2.new(1, 0, 1, 0)
iconLabel.BackgroundTransparency = 1
iconLabel.Text = "⚙"
iconLabel.TextScaled = true
iconLabel.TextColor3 = Color3.new(1, 1, 1)
iconLabel.Font = Enum.Font.GothamBold
iconLabel.Parent = iconButton

-- Основная панель
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 280) -- немного увеличена высота под все переключатели
mainFrame.Position = UDim2.new(0.8, -160, 0.12, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- ... (дальше titleLabel и createToggle без изменений)
-- Функция создания переключателя
local function createToggle(name, yPos, callback)
	local toggleFrame = Instance.new("Frame")
	toggleFrame.Size = UDim2.new(1, -10, 0, 30)
	toggleFrame.Position = UDim2.new(0, 5, 0, yPos)
	toggleFrame.BackgroundTransparency = 1
	toggleFrame.Parent = mainFrame

	local label = Instance.new("TextLabel")
	label.Text = name
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.Position = UDim2.new(0, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = toggleFrame

	local button = Instance.new("TextButton")
	button.Text = "OFF"
	button.Size = UDim2.new(0.4, -10, 1, -4)
	button.Position = UDim2.new(0.6, 5, 0, 2)
	button.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextSize = 12
	button.Parent = toggleFrame

	local enabled = false
	button.MouseButton1Click:Connect(function()
		enabled = not enabled
		button.Text = enabled and "ON" or "OFF"
		button.BackgroundColor3 = enabled and Color3.fromRGB(30, 100, 30) or Color3.fromRGB(100, 30, 30)
		callback(enabled)
	end)

	return button
end

-- Функции модулей
local function startInfJump()
	humanoid.JumpPower = 0
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.Space and infJumpEnabled then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)
end

local function instantSteal()
	-- Grab предмета
	local grabEvent = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages.Net.RE:FindFirstChild("StealService") and ReplicatedStorage.Packages.Net.RE.StealService:FindFirstChild("Grab")
	if grabEvent and character and character:FindFirstChildWhichIsA("Tool") then
		grabEvent:FireServer(character:FindFirstChildWhichIsA("Tool"))
		task.wait(0.2)
		-- Телепорт на зону сбора
		if character:FindFirstChild("HumanoidRootPart") then
			character.HumanoidRootPart.CFrame = CFrame.new(COLLECTION_ZONE_POS)
		end
	end
end

local function startSteelFloor()
	if not character:FindFirstChild("HumanoidRootPart") then return end
	local platform = Instance.new("Part")
	platform.Anchored = true
	platform.Size = Vector3.new(6, 0.2, 6)
	platform.CFrame = character.HumanoidRootPart.CFrame - Vector3.new(0, 3, 0)
	platform.BrickColor = BrickColor.new("Medium stone grey")
	platform.Parent = workspace

	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new(0, 10, 0)
	bodyVelocity.MaxForce = Vector3.new(0, 1e6, 0)
	bodyVelocity.Parent = platform

	-- Уничтожить через 5 сек
	task.delay(5, function()
		platform:Destroy()
	end)
end

local function dropBrainrot()
	if character then
		local tool = character:FindFirstChildWhichIsA("Tool")
		if tool then
			tool.Parent = workspace
			-- доп. сбросить удалённо
			local dropEvent = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages.Net.RE:FindFirstChild("StealService") and ReplicatedStorage.Packages.Net.RE.StealService:FindFirstChild("Drop")
			if dropEvent then
				dropEvent:FireServer(tool)
			end
		end
	end
end

-- Фарм: кража через Grab с интервалом
local farmLoop
local function startFarm()
	farmLoop = RunService.Heartbeat:Connect(function()
		if farmEnabled then
			local grabEvent = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages.Net.RE:FindFirstChild("StealService") and ReplicatedStorage.Packages.Net.RE.StealService:FindFirstChild("Grab")
			if grabEvent and character then
				-- Пытаемся украсть ближайший Brainrot (подразумевается, что персонаж рядом)
				-- В реальном сценарии нужно получить целевой объект; здесь просто вызываем Grab с nil? По документации может требоваться предмет.
				-- Используем обход: находим всех Brainrot в радиусе и крадём первого
				local brainrots = workspace:GetDescendants()
				local closest = nil
				for _, obj in ipairs(brainrots) do
					if obj:IsA("Tool") and obj.Name == "Brainrot" then -- предположительное имя
						if closest == nil or (obj.Position - character.HumanoidRootPart.Position).Magnitude < (closest.Position - character.HumanoidRootPart.Position).Magnitude then
							closest = obj
						end
					end
				end
				if closest then
					grabEvent:FireServer(closest)
				end
			end
		end
	end)
end

-- Авто-покупка улучшений
local function enableAutoBuy()
	local toggleAutoBuy = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages.Net.RF:FindFirstChild("CoinsShopService") and ReplicatedStorage.Packages.Net.RF.CoinsShopService:FindFirstChild("ToggleAutoBuy")
	if toggleAutoBuy then
		toggleAutoBuy:FireServer() -- принудительное включение
	end
	local buySpeedUpgrade = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages.Net.RE:FindFirstChild("TsunamiEventService") and ReplicatedStorage.Packages.Net.RE.TsunamiEventService:FindFirstChild("BuySpeedUpgrade")
	if buySpeedUpgrade then
		for i = 1, 10 do  -- купить 10 раз
			buySpeedUpgrade:FireServer()
			task.wait(0.5)
		end
	end
end

-- Создание GUI-переключателей
createToggle("Infinite Jump", 35, function(enabled)
	infJumpEnabled = enabled
	if enabled then startInfJump() end
end)

createToggle("Instant Steal", 70, function(enabled)
	instantStealEnabled = enabled
	-- При включении выполняем однократно? Лучше привязать к кнопке/действию, но сделаем функцию для теста
	if enabled then instantSteal() end
end)

createToggle("Steel Floor", 105, function(enabled)
	steelFloorEnabled = enabled
	if enabled then startSteelFloor() end
end)

createToggle("Drop Brainrot", 140, function(enabled)
	dropBrainrotEnabled = enabled
	-- Биндинг клавиши Drop (например, G) для сброса
	if enabled then
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then return end
			if input.KeyCode == Enum.KeyCode.G and dropBrainrotEnabled then
				dropBrainrot()
			end
		end)
	end
end)

createToggle("Auto Farm", 175, function(enabled)
	farmEnabled = enabled
	if enabled then
		startFarm()
	else
		if farmLoop then farmLoop:Disconnect() end
	end
end)

createToggle("Auto Upgrades", 210, function(enabled)
	autoUpgradeEnabled = enabled
	if enabled then enableAutoBuy() end
end)

-- Сворачивание GUI
iconButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

-- Сообщение в консоль при загрузке
print("MeridianHub loaded. BREAKER systems online.")
