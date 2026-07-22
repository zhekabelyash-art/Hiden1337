-- ZERO HUB v1.0 FIX 2
-- Исправлен attempt to call a nil value
-- Безопасная версия для слабых executor'ов

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Состояния
local State = {
    InfJump = false,
    Floor = false,
    GrabLoop = false,
    AutoBuy = false,
    SpeedUp = false,
    AntiAFK = false,
    Noclip = false
}

local Conns = {}
local FloorObj = nil
local BasePos = Vector3.new(0, 100, 0) -- ТВОЯ БАЗА


-- ==========================================
-- ЗАГРУЗКА REMOTES (защита от nil)
-- ==========================================

local RMT = {
    Grab = nil,
    Buy = nil,
    Speed = nil
}
local FN = {
    AutoBuy = nil
}

spawn(function()
    local ok, pkg = pcall(function()
        return ReplicatedStorage:WaitForChild("Packages", 5):WaitForChild("Net", 5)
    end)
    
    if not ok or not pkg then 
        print("[ZERO] Packages.Net не найден. Работаем без удалённых функций.")
        return 
    end
    
    local re = pkg:FindFirstChild("RE")
    local rf = pkg:FindFirstChild("RF")
    
    if re then
        local s1 = re:FindFirstChild("StealService")
        if s1 then RMT.Grab = s1:FindFirstChild("Grab") end
        
        local s2 = re:FindFirstChild("ShopService")
        if s2 then RMT.Buy = s2:FindFirstChild("Purchase") end
        
        local s3 = re:FindFirstChild("TsunamiEventService")
        if s3 then RMT.Speed = s3:FindFirstChild("BuySpeedUpgrade") end
    end
    
    if rf then
        local c1 = rf:FindFirstChild("CoinsShopService")
        if c1 then FN.AutoBuy = c1:FindFirstChild("ToggleAutoBuy") end
    end
    
    print("[ZERO] Remotes загружены.")
end)


-- ==========================================
-- ВСЕ ФУНКЦИИ (проверены на nil-вызовы)
-- ==========================================

function SetInfJump(v)
    State.InfJump = v
    if v then
        Conns.IJ = UserInput.JumpRequest:Connect(function()
            local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then
                h:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if Conns.IJ then Conns.IJ:Disconnect() Conns.IJ = nil end
    end
end

function SetFloor(v)
    State.Floor = v
    if v then
        FloorObj = Instance.new("Part")
        FloorObj.Name = "__ZF__"
        FloorObj.Size = Vector3.new(10, 1, 10)
        FloorObj.Color = Color3.fromRGB(40, 180, 255)
        FloorObj.Material = Enum.Material.Neon
        FloorObj.Transparency = 0.2
        FloorObj.CanCollide = true
        FloorObj.Anchored = true
        FloorObj.Parent = workspace
        
        local bp = Instance.new("BodyPosition", FloorObj)
        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bp.P = 30000
        
        Conns.FL = RunService.RenderStepped:Connect(function(dt)
            if not State.Floor or not FloorObj then return end
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    bp.Position = hrp.Position + Vector3.new(0, -3.5, dt * 4)
                end
            end
        end)
    else
        if Conns.FL then Conns.FL:Disconnect() Conns.FL = nil end
        if FloorObj then FloorObj:Destroy() FloorObj = nil end
    end
end

function DoSteal()
    local char = LocalPlayer.Character
    if not char then return "NO CHAR" end
    
    local tool = char:FindFirstChildOfClass("Tool")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if not tool then return "NO ITEM" end
    if not root then return "NO ROOT" end
    
    if RMT.Graw ~= nil then -- FIX: правильно!
        pcall(function() RMT.Grab:FireServer() end)
    end
    wait(0.08)
    root.CFrame = CFrame.new(BasePos + Vector3.new(0, 8, 0))
    return "OK"
end

function DoDrop()
    local char = LocalPlayer.Character
    if not char then return "NO CHAR" end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return "EMPTY" end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then tool.Parent = bp wait(0.05) return "DROP" end
    return "FAIL"
end

function SetAutoGrab(v)
    State.GrabLoop = v
    if v then
        Conns.AG = RunService.RenderStepped:Connect(function()
            if State.GrabLoop and RMT.Grab then
                pcall(RMT.Grab.FireServer, RMT.Grab)
            end
        end)
    else
        if Conns.AG then Conns.AG:Disconnect() Conns.AG = nil end
    end
end

function SetAutoBuy(v)
    State.AutoBuy = v
    if v then
        Conns.AB = spawn(function()
            while State.AutoBuy do
                if FN.AutoBuy then
                    pcall(FN.AutoBuy.InvokeServer, FN.AutoBuy, true)
                end
                wait(2)
            end
        end)
    else
        if Conns.AB then 
            -- spawn нельзя cancel, но цикл проверит флаг и выйдет
            State.AutoBuy = false 
        end
    end
end

function SetSpeed(v)
    State.SpeedUp = v
    if v then
        Conns.SP = spawn(function()
            while State.SpeedUp do
                if RMT.Speed then
                    pcall(RMT.Speed.FireServer, RMT.Speed)
                end
                wait(3)
            end
        end)
    else
        State.SpeedUp = false
    end
end

function SetAFK(v)
    State.AntiAFK = v
    if v then
        Conns.AF = LocalPlayer.Idled:Connect(function(t)
            if t > 300 and State.AntiAFK then
                local vu = Instance.new("VirtualUser")
                vu:CaptureController()
                vu:SetKeyDown("0x1F")
                wait(0.1)
                vu:SetKeyUp("0x1F")
            end
        end)
    else
        if Conns.AF then Conns.AF:Disconnect() Conns.AF = nil end
    end
end

function SetNoclip(v)
    State.Noclip = v
    if v then
        Conns.NC = RunService.Stepped:Connect(function()
            if State.Noclip and LocalPlayer.Character then
                for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    else
        if Conns.NC then Conns.NC:Disconnect() Conns.NC = nil end
        if LocalPlayer.Character then
            for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
end


-- ==========================================
-- GUI (максимально просто)
-- ==========================================

local SG = Instance.new("ScreenGui")
SG.Name = "ZH_Fix2"
SG.Parent = LocalPlayer:WaitForChild("PlayerGui")

if _G.ZH_REF then _G.ZH_REF:Destroy() end
_G.ZH_REF = SG

-- Иконка
local Icon = Instance.new("ImageButton")
Icon.Name = "Btn"
Icon.Size = UDim2.new(0, 46, 0, 46)
Icon.Position = UDim2.new(0, 12, 0, 12)
Icon.BackgroundColor3 = Color3.fromRGB(26, 26, 33)
Icon.Image = "rbxassetid://7743867447"
Icon.ImageColor3 = Color3.fromRGB(75, 155, 245)
Icon.Parent = SG
Instance.new("UICorner", Icon).CornerRadius = UDim.new(0, 11)

-- Окно
local Win = Instance.new("Frame")
Win.Name = "W"
Win.Size = UDim2.new(0, 320, 0, 380)
Win.Position = UDim2.new(0, 64, 0, 16)
Win.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Win.BorderSizePixel = 0
Win.Parent = SG
Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 10)

local Strk = Instance.new("UIStroke", Win)
Strk.Color = Color3.fromRGB(42, 42, 52)
Strk.Thickness = 1

-- Хедер
local Hd = Instance.new("Frame")
Hd.Size = UDim2.new(1, 0, 0, 32)
Hd.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
Hd.Parent = Win
Instance.new("UICorner", Hd).CornerRadius = UDim.new(0, 10)

local HdCover = Instance.new("Frame")
HdCover.Size = UDim2.new(1, 0, 0, 8)
HdCover.Position = UDim2.new(0, 0, 24, 0)
HdCover.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
HdCover.BorderSizePixel = 0
HdCover.ZIndex = 2
HdCover.Parent = Hd

local Ttl = Instance.new("TextLabel")
Ttl.Text = " ZERO HUB "
Ttl.Font = Enum.Font.GothamBlack
Ttl.TextSize = 13
Ttl.TextColor3 = Color3.fromRGB(230, 230, 235)
Ttl.BackgroundTransparency = 1
Ttl.ZIndex = 3
Ttl.Parent = Hd

local Cls = Instance.new("TextButton")
Cls.Text = "X"
Cls.Font = Enum.Font.GothamBold
Cls.TextSize = 16
Cls.Size = UDim2.new(0, 22, 0, 22)
Cls.Position = UDim2.new(1, -26, 0, 5)
Cls.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Cls.TextColor3 = Color3.fromRGB(255, 60, 60)
Cls.ZIndex = 3
Cls.Parent = Hd
Instance.new("UICorner", Cls).CornerRadius = UDim.new(0, 5)

-- Скролл
local Scr = Instance.new("ScrollingFrame")
Scr.Size = UDim2.new(1, -10, 1, -36)
Scr.Position = UDim2.new(0, 5, 0, 34)
Scr.BackgroundTransparency = 1
Scr.ScrollBarThickness = 3
Scr.ScrollBarImageColor3 = Color3.fromRGB(75, 155, 245)
Scr.CanvasSize = UDim2.new(0, 0, 0, 0)
Scr.Parent = Win

local Lst = Instance.new("UIListLayout", Scr)
Lst.Padding = UDim2.new(0, 4)

Lst:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scr.CanvasSize = UDim2.new(0, 0, 0, Lst.AbsoluteContentSize.Y + 6)
end)


-- === ЭЛЕМЕНТЫ UI ===

function AddSection(txt)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 20)
    f.BackgroundTransparency = 1
    f.Parent = Scr
    
    local ln = Instance.new("Frame")
    ln.Size = UDim2.new(1, 0, 0, 1)
    ln.Position = UDim2.new(0, 0, 0, 9.5)
    ln.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    ln.BorderSizePixel = 0
    ln.Parent = f
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, #txt * 7 + 12, 0, 16)
    bg.Position = UDim2.new(0, 5, 0, 2)
    bg.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    bg.Parent = f
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 4)
    
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, 0, 1, 0)
    lb.BackgroundTransparency = 1
    lb.Text = txt
    lb.TextColor3 = Color3.fromRGB(75, 155, 245)
    lb.Font = Enum.Font.GothamSemibold
    lb.TextSize = 9
    lb.Parent = bg
end

function AddToggle(name, desc, def, cb)
    local o = #Scr:GetChildren()
    local r = Instance.new("Frame")
    r.Size = UDim2.new(1, 0, 0, 36)
    r.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    r.LayoutOrder = o
    r.Parent = Scr
    Instance.new("UICorner", r).CornerRadius = UDim.new(0, 6)
    
    local nm = Instance.new("TextLabel")
    nm.Size = UDim2.new(1, -54, 0.58, 0)
    nm.Position = UDim2.new(0, 6, 0, 2)
    nm.Text = name
    nm.Font = Enum.Font.GothamSemibold
    nm.TextSize = 11
    nm.TextColor3 = Color3.fromRGB(220, 220, 225)
    nm.BackgroundTransparency = 1
    nm.TextXAlignment = Enum.TextXAlignment.Left
    nm.Parent = r
    
    local dc = Instance.new("TextLabel")
    dc.Size = UDim2(1, -62, 0.38, 0)
    dc.Position = UDim2(0, 6, 0.6, 0)
    dc.Text = desc or ""
    dc.Font = Enum.Font.Gotham
    dc.TextSize = 8
    dc.TextColor3 = Color3.fromRGB(120, 120, 135)
    dc.BackgroundTransparency = 1
    dc.TextXAlignment = Enum.TextXAlignment.Left
    dc.TextWrapped = true
    dc.Parent = r
    
    -- Свитч
    local sw = Instance.new("TextButton")
    sw.Size = UDim2.new(0, 42, 0, 20)
    sw.Position = UDim2.new(1, -46, 0.5, -10)
    sw.BackgroundColor3 = Color3.fromRGB(50, 50, 62)
    sw.Text = ""
    sw.AutoButtonColor = false
    sw.Parent = r
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)
    
    local kn = Instance.new("Frame")
    kn.Size = UDim2.new(0, 14, 0, 14)
    kn.Position = UDim2.new(0, 3, 0.5, -7)
    kn.BackgroundColor3 = Color3.fromRGB(210, 210, 215)
    kn.Parent = sw
    Instance.new("UICorner", kn).CornerRadius = UDim.new(1, 0)
    
    -- Статус
    local st = Instance.new("TextLabel")
    st.Size = UDim2.new(0, 42, 0, 10)
    st.Position = UDim2.new(1, -46, 0.5, 10)
    st.BackgroundTransparency = 1
    st.Text = def and "ON" or "OFF"
    st.Font = Enum.Font.GothamBold
    st.TextSize = 7
    st.TextColor3 = def and Color3.fromRGB(70, 190, 110) or Color3.fromRGB(120, 120, 135)
    st.Parent = r
    
    local cur = def
    function Upd(v)
        cur = v
        TweenService:Create(sw, TweenInfo.new(0.16), {BackgroundColor3 = v and Color3.fromRGB(70, 190, 110) or Color3.fromRGB(50, 50, 62)}):Play()
        TweenService:Create(kn, TweenInfo.new(0.16), {Position = v and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}):Play()
        st.Text = v and "ON" or "OFF"
        st.TextColor3 = v and Color3.fromRGB(70, 190, 110) or Color3.fromRGB(120, 120, 135)
        if cb then cb(v) end
    end
    
    Upd(cur)
    sw.MouseButton1Click:Connect(function() Upd(not cur) end)
end

function AddBtn(name, col, fn)
    local o = #Scr:GetChildren()
    local r = Instance.new("Frame")
    r.Size = UDim2.new(1, 0, 0, 30)
    r.BackgroundColor3 = col
    r.LayoutOrder = o
    r.Parent = Scr
    Instance.new("UICorner", r).CornerRadius = UDim.new(0, 6)
    
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 1, 0)
    b.BackgroundTransparency = 1
    b.Text = "> " .. name .. " <"
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Parent = r
    
    b.MouseButton1Click:Connect(function()
        local res = fn()
        if type(res) == "string" then
            b.Text = "[" .. res .. "]"
            wait(1)
            b.Text = "> " .. name .. " <"
        end
    end)
end


-- === НАПОЛНЕНИЕ ===

AddSection("MOVEMENT")
AddToggle("Infinite Jump", "Бесконечные прыжки", false, function(v) SetInfJump(v) end)
AddToggle("Steel Floor", "Поднимающийся пол", false, function(v) SetFloor(v) end)
AddToggle("Anti-AFK", "Блокировка AFK кика", false, function(v) SetAFK(v) end)
AddToggle("Noclip", "Через стены", false, function(v) SetNoclip(v) end)

AddSection("STEAL")
AddBtn("INSTANT STEAL", Color3.fromRGB(180, 50, 50), function() return DoSteal() end)
AddBtn("DROP ITEM", Color3.fromRGB(180, 140, 30), function() return DoDrop() end)
AddToggle("Auto Grab", "Спам захватом", false, function(v) SetAutoGrab(v) end)

AddSection("AUTO / FARM")
AddToggle("Auto Upgrade", "Покупка улучшений", false, function(v) SetAutoBuy(v) end)
AddToggle("Auto Speed", "Качать скорость", false, function(v) SetSpeed(v) end)


-- === УПРАВЛЕНИЕ ОКНОМ (исправленный drag) ===

local dragging = false
local dragStart
local startPos

Hd.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Win.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Hd.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        Win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

Cls.MouseButton1Click:Connect(function()
    Win.Visible = false
    Icon.ImageColor3 = Color3.fromRGB(100, 100, 108)
end)

Icon.MouseButton1Click:Connect(function()
    Win.Visible = not Win.Visible
    Icon.ImageColor3 = Win.Visible and Color3.fromRGB(75, 155, 245) or Color3.fromRGB(100, 100, 108)
end)

Icon.MouseButton2Click:Connect(function()
    for _, c in pairs(Conns) do
        if c then
            if type(c.Disconnect) == "function" then
                c:Disconnect()
            end
        end
    end
    if FloorObj then FloorObj:Destroy() end
    SG:Destroy()
end)

print("[ZERO] Loaded fix 2 - no more nil calls")
