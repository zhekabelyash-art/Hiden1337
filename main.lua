-- // [zero_core v4.4] // game: steal a brainrot
-- // target: localplayer / bypass hooked

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")

local gethui = gethui or function() return CoreGui end

-- Удаляем старую копию UI
if CoreGui:FindFirstChild("ZeroHub_Brainrot") then
    CoreGui.ZeroHub_Brainrot:Destroy()
end

-- UI Core
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZeroHub_Brainrot"
ScreenGui.Parent = gethui()
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 128)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
MainFrame.Size = UDim2.new(0, 250, 0, 320)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 1

-- Header Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "ZERO // BRAINROT"
Title.TextColor3 = Color3.fromRGB(0, 255, 128)
Title.TextSize = 16
Title.ZIndex = 2

-- Close Button (Крестик)
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = Title
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -30, 0, 5)
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.ZIndex = 3

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Container for buttons
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 0, 0, 40)
Container.Size = UDim2.new(1, 0, 1, -40)
Container.ZIndex = 2

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Container
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)

local function createToggle(name, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = Container
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.BorderColor3 = Color3.fromRGB(60, 60, 60)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = name .. ": [ OFF ]"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 14
    btn.ZIndex = 3
    
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            btn.TextColor3 = Color3.fromRGB(0, 255, 128)
            btn.Text = name .. ": [ ON ]"
        else
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            btn.Text = name .. ": [ OFF ]"
        end
        callback(enabled)
    end)
end

-- 1. Steel Floor (Поднимающаяся платформа)
local flyPart = nil
local flyConn = nil
createToggle("Steel Floor", function(state)
    if state then
        flyPart = Instance.new("Part")
        flyPart.Size = Vector3.new(12, 1, 12)
        flyPart.Anchored = true
        flyPart.CanCollide = true
        flyPart.Transparency = 0.4
        flyPart.Color = Color3.fromRGB(0, 255, 128)
        flyPart.Parent = Workspace
        
        if Root then
            flyPart.CFrame = Root.CFrame - Vector3.new(0, 3.5, 0)
        end
        
        flyConn = RunService.RenderStepped:Connect(function()
            if flyPart and Root then
                flyPart.CFrame = flyPart.CFrame + Vector3.new(0, 0.25, 0)
                Root.CFrame = flyPart.CFrame + Vector3.new(0, 3.5, 0)
            end
        end)
    else
        if flyConn then flyConn:Disconnect() flyConn = nil end
        if flyPart then flyPart:Destroy() flyPart = nil end
    end
end)

-- 2. Infinite Jump
local infJumpConn
createToggle("Infinite Jump", function(state)
    if state then
        infJumpConn = UserInputService.JumpRequest:Connect(function()
            if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
                LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidState.Jumping)
            end
        end)
    else
        if infJumpConn then
            infJumpConn:Disconnect()
        end
    end
end)

-- 3. Remove Walls (Отключение коллизий у объектов)
createToggle("Remove Walls", function(state)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(LP.Character) and obj.Name ~= "Terrain" then
            if state then
                if not obj:FindFirstChild("OrigCollide") then
                    local val = Instance.new("BoolValue")
                    val.Name = "OrigCollide"
                    val.Value = obj.CanCollide
                    val.Parent = obj
                end
                obj.CanCollide = false
            else
                local val = obj:FindFirstChild("OrigCollide")
                if val then
                    obj.CanCollide = val.Value
                    val:Destroy()
                end
            end
        end
    end
end)

-- 4. Noclip
local noclipConn
createToggle("Noclip", function(state)
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            if LP.Character then
                for _, part in ipairs(LP.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConn then
            noclipConn:Disconnect()
        end
    end
end)

-- 5. Instant Steal
createToggle("Instant Steal", function(state)
    if state then
        task.spawn(function()
            while task.wait(0.2) do
                pcall(function()
                    for _, v in ipairs(Workspace:GetDescendants()) do
                        if v:IsA("ProximityPrompt") then
                            v.HoldDuration = 0
                        end
                    end
                end)
            end
        end)
    end
end)
