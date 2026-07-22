-- // [zero_core v4.1] // game: steal a brainrot
-- // target: localplayer / bypass hooked

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")

-- ui lib minimal clean
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local Title = Instance.new("TextLabel")

ScreenGui.Name = "ZeroHub_Brainrot"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "Main"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 128)
MainFrame.BorderSizePixel = 1
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true

UIListLayout.Parent = MainFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.New(0, 8)

Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.Code
Title.Text = " [ ZERO // BRAINROT ] "
Title.TextColor3 = Color3.fromRGB(0, 255, 128)
Title.TextSize = 14

local function createToggle(name, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BorderColor3 = Color3.fromRGB(50, 50, 50)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Font = Enum.Font.Code
    btn.Text = name .. ": [ OFF ]"
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.TextSize = 12
    
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            btn.TextColor3 = Color3.fromRGB(0, 255, 128)
            btn.Text = name .. ": [ ON ]"
        else
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            btn.Text = name .. ": [ OFF ]"
        end
        callback(enabled)
    end)
end

-- 1. Steel Floor (летающая платформа)
local floorPart = nil
createToggle("Steel Floor", function(state)
    if state then
        floorPart = Instance.new("Part")
        floorPart.Size = Vector3.new(5, 0.4, 5)
        floorPart.Anchored = true
        floorPart.CanCollide = true
        floorPart.Transparency = 0.3
        floorPart.Color = Color3.fromRGB(0, 255, 128)
        floorPart.Parent = Workspace
        
        RunService.RenderStepped:Connect(function()
            if floorPart and Root then
                floorPart.CFrame = Root.CFrame - Vector3.new(0, 3.5, 0)
            end
        end)
    else
        if floorPart then
            floorPart:Destroy()
            floorPart = nil
        end
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

-- 3. Remove Walls (убрать стены)
createToggle("Remove Walls", function(state)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("wall") or obj.Name:lower():find("door")) then
            obj.CanCollide = not state
            if state then
                obj.Transparency = 0.7
            else
                obj.Transparency = 0
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

-- 5. Instant Steal (моментальный подбор / интеракт)
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

print("[zero] script injected successfully.")
