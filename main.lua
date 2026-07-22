local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetReplicatedStorage()

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local toggleButton = Instance.new("ImageButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.BorderSizePixel = 0
toggleButton.Parent = screenGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0, 70, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.Visible = false

-- Features Toggle
local features = {
	InfiniteJump = false,
	InstantSteal = false,
	SteelFloor = false,
	DropBrainrot = false,
	AutoBuy = false
}

local buttons = {}

local function createButton(name, position)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0, 280, 0, 40)
	btn.Position = position
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 14
	btn.Text = name .. ": OFF"
	btn.Parent = mainFrame
	btn.BorderSizePixel = 0
	
	btn.MouseButton1Click:Connect(function()
		features[name] = not features[name]
		btn.Text = name .. ": " .. (features[name] and "ON" or "OFF")
		btn.BackgroundColor3 = features[name] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40)
	end)
	
	buttons[name] = btn
	return btn
end

createButton("InfiniteJump", UDim2.new(0, 10, 0, 10))
createButton("InstantSteal", UDim2.new(0, 10, 0, 60))
createButton("SteelFloor", UDim2.new(0, 10, 0, 110))
createButton("DropBrainrot", UDim2.new(0, 10, 0, 160))
createButton("AutoBuy", UDim2.new(0, 10, 0, 210))

toggleButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

-- Infinite Jump
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Space and features.InfiniteJump then
		character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- Instant Steal
local function performInstantSteal()
	local grabEvent = ReplicatedStorage:FindFirstChild("Packages")
	if grabEvent then
		local net = grabEvent:FindFirstChild("Net")
		if net then
			local stealService = net:FindFirstChild("RE") or net:FindFirstChild("RemoteEvent")
			if stealService then
				stealService:FireServer()
			end
		end
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.E and features.InstantSteal then
		performInstantSteal()
	end
end)

-- Steel Floor
local function createSteelFloor()
	local floor = Instance.new("Part")
	floor.Name = "SteelFloor"
	floor.Shape = Enum.PartType.Block
	floor.Material = Enum.Material.Metal
	floor.Size = Vector3.new(20, 1, 20)
	floor.CanCollide = true
	floor.CFrame = humanoidRootPart.CFrame - Vector3.new(0, 5, 0)
	floor.Parent = workspace
	
	game:GetService("Debris"):AddItem(floor, 10)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.F and features.SteelFloor then
		createSteelFloor()
	end
end)

-- Drop Brainrot
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.G and features.DropBrainrot then
		-- Здесь нужно искать инстанс бреинрота в руках персонажа
		local hand = character:FindFirstChild("RightHand") or character:FindFirstChild("RightUpperArm")
		if hand then
			for _, child in pairs(hand:GetChildren()) do
				if child:IsA("Model") or child:IsA("Part") then
					child.Parent = workspace
					if child:FindFirstChild("HumanoidRootPart") then
						child:MoveTo(humanoidRootPart.Position + Vector3.new(5, 0, 0))
					end
				end
			end
		end
	end
end)

-- Auto Buy
if features.AutoBuy then
	local autoBuyFunction = ReplicatedStorage:FindFirstChild("Packages")
	if autoBuyFunction then
		local net = autoBuyFunction:FindFirstChild("Net")
		if net then
			local toggleAutoBuy = net:FindFirstChild("RF")
			if toggleAutoBuy then
				toggleAutoBuy:InvokeServer(true)
			end
		end
	end
end

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)
