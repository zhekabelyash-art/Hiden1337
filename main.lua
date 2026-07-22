--[[
    ZERO HUB v1.0 — FIXED VERSION
    Исправлена ошибка Stack Yield на WaitForChild
]]

-- СЕРВИСЫ
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- СОСТОЯНИЯ
local State = {
    InfiniteJump = false,
    SteelFloor = false,
    AutoGrab = false,
    AutoBuy = false,
    AutoSpeed = false,
    AntiAFK = false,
    Noclip = false
}
local Connections = {}
local FloorPart = nil
local BasePosition = Vector3.new(0, 100, 0) -- <<<< ТВОЯ БАЗА ЗДЕСЬ


-- ============================================================
-- БЕЗОПАСНАЯ ЗАГРУЗКА СЕТИ (ФИКС ОШИБКИ)
-- ============================================================

local Remotes = {Grab=nil, Purchase=nil, SpeedUpgrade=nil}
local Funcs = {AutoBuy=nil}

-- Запускаем загрузку через spawn чтобы не блочить основной поток
task.spawn(function()
    -- Пытаемся найти пакет с таймаутом
    local Net = ReplicatedStorage:FindFirstChild("Packages")
    if not Net then
        ReplicatedStorage.ChildAdded:WaitForChild("Packages")
        Net = ReplicatedStorage.Packages
    end
    
    Net = Net:FindFirstChild("Net")
    if not Net then warn("[Zero] Нет Net пакета"); return; end
    
    local RE = Net:FindFirstChild("RE")
    local RF = Net:FindFirstChild("RF")
    
    if RE then
        -- Безопасное получение с проверкой существования
        local stealSvc = RE:FindFirstChild("StealService")
        if stealSvc then Remotes.Grab = stealSvc:FindFirstChild("Grab") end
        
        local shopSvc = RE:FindFirstChild("ShopService")
        if shopSvc then Remotes.Purchase = shopSvc:FindFirstChild("Purchase") end
        
        local tsunamiSvc = RE:FindFirstChild("TsunamiEventService")
        if tsunamiSvc then Remotes.SpeedUpgrade = tsunamiSvc:FindFirstChild("BuySpeedUpgrade") end
    end
    
    if RF then
        local coinSvc = RF:FindFirstChild("CoinsShopService")
        if coinSvc then Funcs.AutoBuy = coinSvc:FindFirstChild("ToggleAutoBuy") end
    end
    
    print("[Zero] Загружено. Grab:", Remotes.Grab ~= nil and "OK" or "MISSING", "| AutoBuy:", Funcs.AutoBuy ~= nil and "OK" or "MISSING")
end)


-- ============================================================
-- ВСЕ ФУНКЦИИ РАБОТЫ
-- ============================================================

function ToggleInfJump(v)
    State.InfiniteJump = v
    if v then
        Connections.IJ = UserInputService.JumpRequest:Connect(function()
            local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if Connections.IJ then Connections.IJ:Disconnect(); Connections.IJ = nil end
    end
end

function ToggleSteelFloor(v)
    State.SteelFloor = v
    if v then
        FloorPart = Instance.new("Part")
        FloorPart.Name = "__Z_Floor"
        FloorPart.Size = Vector3.new(10,1,10)
        FloorPart.Color = Color3.fromRGB(40,180,255)
        FloorPart.Material = Enum.Material.Neon
        FloorPart.Transparency = 0.2
        FloorPart.CanCollide = true
        FloorPart.Anchored = true
        FloorPart.Parent = workspace
        
        local bp = Instance.new("BodyPosition", FloorPart)
        bp.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
        bp.P = 30000
        
        Connections.FL = RunService.RenderStepped:Connect(function(dt)
            if not State.SteelFloor or not FloorPart then return end
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                bp.Position = hrp.Position + Vector3.new(0,-3.5, dt*4)
                FloorPart.CFrame = CFrame.new(bp.Position) * CFrame.Angles(0,tick()*2%360,0)
            end
        end)
    else
        if Connections.FL then Connections.FL:Disconnect(); Connections.FL = nil end
        if FloorPart then FloorPart:Destroy(); FloorPart = nil end
    end
end

function DoInstaSteal()
    local c = LocalPlayer.Character
    if not c then return "NO CHAR" end
    local tool = c:FindFirstChildOfClass("Tool")
    local root = c:FindFirstChild("HumanoidRootPart")
    if not tool then return "NO ITEM" end
    if not root then return "NO ROOT" end
    
    -- Безопасный вызов с проверкой
    if Remotes.Grab then
        pcall(function() Remotes.Grab:FireServer() end)
    end
    task.wait(0.08)
    root.CFrame = CFrame.new(BasePosition + Vector3.new(0,8,0))
    return "TELEPORTED"
end

function DoDropItem()
    local c = LocalPlayer.Character
    if not c then return "NO CHAR" end
    local tool = c:FindFirstChildOfClass("Tool")
    if not tool then return "EMPTY HANDS" end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        tool.Parent = bp
        task.wait(0.05)
        return "DROPPED TO BAG"
    end
    return "FAIL"
end

function ToggleAutoGrab(v)
    State.AutoGrab = v
    if v then
        Connections.AG = RunService.RenderStepped:Connect(function()
            if State.AutoGrab and Remotes.Grab then
                pcall(Remotes.Grab.FireServer, Remotes.Grab)
            end
        end)
    else
        if Connections.AG then Connections.AG:Disconnect(); Connections.AG = nil end
    end
end

function ToggleAutoBuy(v)
    State.AutoBuy = v
    if v then
        Connections.AB = task.spawn(function()
            while State.AutoBuy do
                if Funcs.AutoBuy then
                    pcall(Funcs.AutoBuy.InvokeServer, Funcs.AutoBuy, true)
                end
                task.wait(2)
            end
        end)
    else
        if Connections.AB then task.cancel(Connections.AB); Connections.AB = nil end
    end
end

function ToggleAutoSpeed(v)
    State.AutoSpeed = v
    if v then
        Connections.AS = task.spawn(function()
            while State.AutoSpeed do
                if Remotes.SpeedUpgrade then
                    pcall(Remotes.SpeedUpgrade.FireServer, Remotes.SpeedUpgrade)
                end
                task.wait(3)
            end
        end)
    else
        if Connections.AS then task.cancel(Connections.AS); Connections.AS = nil end
    end
end

function ToggleAntiAFK(v)
    State.AntiAFK = v
    if v then
        Connections.AF = LocalPlayer.Idled:Connect(function(t)
            if t > 300 and State.AntiAFK then
                local vu = Instance.new("VirtualUser")
                vu:CaptureController()
                vu:SetKeyDown("0x1F")
                wait(0.1)
                vu:SetKeyUp("0x1F")
            end
        end)
    else
        if Connections.AF then Connections.AF:Disconnect(); Connections.AF = nil end
    end
end

function ToggleNoclip(v)
    State.Noclip = v
    if v then
        Connections.NC = RunService.Stepped:Connect(function()
            if State.Noclip and LocalPlayer.Character then
                for _,p in pairs(LocalPlayer.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    else
        if Connections.NC then Connections.NC:Disconnect(); Connections.NC = nil end
        if LocalPlayer.Character then
            for _,p in pairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
end


-- ============================================================
-- GUI ПОЛНОСТЬЮ (визуал + привязка)
-- ============================================================

local gui = Instance.new("ScreenGui")
gui.Name = "ZeroHubV1"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

if _G.ZeroH then _G.ZeroH:Destroy() end
_G.ZeroH = gui

--- TOGGLE ICON ---
local icon = Instance.new("ImageButton")
icon.Name = "Icon"
icon.Size = UDim2.new(0,48,0,48); icon.Position = UDim2.new(0,14,0,14)
icon.BackgroundColor3 = Color3.fromRGB(28,28,35)
icon.Image = "rbxassetid://7743867447"; icon.ImageColor3 = Color3.fromRGB(80,160,255)
icon.Parent = gui
Instance.new("UICorner",icon).CornerRadius = UDim.new(0,12)

--- MAIN FRAME ---
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0,340,0,400); main.Position = UDim2.new(0,68,0,18)
main.BackgroundColor3 = Color3.fromRGB(20,20,26); main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner",main).CornerRadius = UDim.new(0,11)
Instance.new("UIStroke",main).Color = Color3.fromRGB(45,45,55)

--- HEADER ---
local hdr = Instance.new("Frame")
hdr.Size = UDim2.new(1,0,0,34); hdr.BackgroundColor3 = Color3.fromRGB(26,26,34); hdr.Parent = main
Instance.new("UICorner",hdr).CornerRadius = UDim.new(0,11)
local hCov = Instance.new("Frame"); hCov.Size = UDim2(1,0,0,9); hCov.Position = UDim2(0,0,25,0)
hCov.BackgroundColor3 = Color3.fromRGB(26,26,34); hCov.BorderSizePixel = 0; hCov.ZIndex=2; hCov.Parent=hdr

local title = Instance.new("TextLabel"); title.Text=" ZERO HUB "; title.Font=Enum.Font.GothamBlack; title.TextSize=14
title.TextColor3=Color3.fromRGB(235,235,240); title.BackgroundTransparency=1; title.ZIndex=3; title.Parent=hdr

local xbtn = Instance.new("TextButton"); xbtn.Text="×"; xbtn.Font=Enum.Font.GothamBold; xbtn.TextSize=20
xbtn.Size=UDim2(0,24,0,24); xbtn.Position=UDim2(1,-28,0,5); xbtn.BackgroundColor3=Color3.fromRGB(42,42,52)
xbtn.TextColor3=Color3.fromRGB(255,65,65); xbtn.ZIndex=3; xbtn.Parent=hdr
Instance.new("UICorner",xbtn).CornerRadius=UDim2(0,6)

--- SCROLL CONTENT ---
local scr = Instance.new("ScrollingFrame")
scr.Name="Content"; scr.Size=UDim2(1,-12,1,-40); scr.Position=UDim2(0,6,0,36)
scr.BackgroundTransparency=1; scr.ScrollBarThickness=3; scr.ScrollBarImageColor3=Color3.fromRGB(80,160,255)
scr.CanvasSize=UDim2(0,0,0,0); scr.Parent=main
local lay = Instance.new("UIListLayout",scr); lay.Padding = UDim2(0,5)
lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scr.CanvasSize = UDim2(0,0,0,lay.AbsoluteContentSize.Y+8)
end)


-- === UI HELPERS ===

function SecTitle(txt)
    local f=Instance.new("Frame"); f.Size=UDim2(1,0,0,22); f.BackgroundTransparency=1; f.Parent=scr
    local ln=Instance.new("Frame"); ln.Size=UDim2(1,0,0,1); ln.Position=UDim2(0,0,0,10.5)
    ln.BackgroundColor3=Color3.fromRGB(48,48,58); ln.BorderSizePixel=0; ln.Parent=f
    local bg=Instance.new("Frame"); bg.Size=UDim2(0,#txt*7+14,0,18); bg.Position=UDim2(0,6,0,2)
    bg.BackgroundColor3=Color3.fromRGB(32,32,40); bg.Parent=f; Instance.new("UICorner",bg).CornerRadius=UDim2(0,4)
    local lb=Instance.new("TextLabel"); lb.Size=UDim2(1,0,1,0); lb.BackgroundTransparency=1
    lb.Text=txt; lb.TextColor3=Color3.fromRGB(80,160,255); lb.Font=Enum.Font.GothamSemibold; lb.TextSize=10; lb.Parent=bg
end

function MkToggle(name,desc,default,callback)
    local ord=#scr:GetChildren()
    local row=Instance.new("Frame"); row.Size=UDim2(1,0,0,40); row.BackgroundColor3=Color3.fromRGB(28,28,36)
    row.LayoutOrder=ord; row.Parent=scr; Instance.new("UICorner",row).CornerRadius=UDim2(0,6)
    
    local nm=Instance.new("TextLabel"); nm.Size=UDim2(1,-60,0.6,0); nm.Position=UDim2(0,8,0,2)
    nm.Text=name; nm.Font=Enum.Font.GothamSemibold; nm.TextSize=12; nm.TextColor3=Color3.fromRGB(225,225,230)
    nm.BackgroundTransparency=1; nm.TextXAlignment=Enum.TextXAlignment.Left; nm.Parent=row
    
    local ds=Instance.new("TextLabel"); ds.Size=UDim2(1,-68,0.36,0); ds.Position=UDim2(0,8,0.62,0)
    ds.Text=desc or ""; ds.Font=Enum.Font.Gotham; ds.TextSize=9; ds.TextColor3=Color3.fromRGB(125,125,140)
    ds.BackgroundTransparency=1; ds.TextXAlignment=Enum.TextXAlignment.Left; ds.TextWrapped=true; ds.Parent=row
    
    local sw=Instance.new("TextButton"); sw.Size=UDim2(0,44,0,22); sw.Position=UDim2(1,-50,0.5,-11)
    sw.BackgroundColor3=Color3.fromRGB(52,52,64); sw.Text=""; sw.AutoButtonColor=false; sw.Parent=row
    Instance.new("UICorner",sw).CornerRadius=UDim2(1,0)
    
    local knob=Instance.new("Frame"); knob.Size=UDim2(0,16,0,16); knob.Position=UDim2(0,3,0.5,-8)
    knob.BackgroundColor3=Color3.fromRGB(215,215,220); knob.Parent=sw
    Instance.new("UICorner",knob).CornerRadius=UDim2(1,0)
    
    -- СТАТУС ЛЕЙБЛ
    local st=Instance.new("TextLabel"); st.Size=UDim2(0,44,0,12); st.Position=UDim2(1,-50,0.5,11)
    st.BackgroundTransparency=1; st.Text=default and "ON" or "OFF"; st.Font=Enum.Font.GothamBold; st.TextSize=8
    st.TextColor3=default and Color3.fromRGB(75,195,115) or Color3.fromRGB(130,130,142); st.Parent=row
    
    local cur=default
    function Set(s)
        cur=s
        TweenService:Create(sw,TweenInfo(0.18),{BackgroundColor3=s and Color3.fromRGB(75,195,115) or Color3.fromRGB(52,52,64)}):Play()
        TweenService:Create(knob,TweenInfo(0.18),{Position=s and UDim2(1,-19,0.5,-8) or UDim2(0,3,0.5,-8)}):Play()
        st.Text=s and "ON" or "OFF"; st.TextColor3=s and Color3.fromRGB(75,195,115) or Color3.fromRGB(130,130,142)
        if callback then callback(s) end
    end
    Set(cur)
    sw.MouseButton1Click:Connect(function() Set(not cur) end)
end

function MkBtn(name,col,cb)
    local ord=#scr:GetChildren()
    local r=Instance.new("Frame"); r.Size=UDim2(1,0,0,34); r.BackgroundColor3=col; r.LayoutOrder=ord; r.Parent=scr
    Instance.new("UICorner",r).CornerRadius=UDim2(0,6)
    local b=Instance.new("TextButton"); b.Size=UDim2(1,0,1,0); b.BackgroundTransparency=1
    b.Text=">> "..name.." <<"; b.Font=Enum.Font.GothamBold; b.TextSize=12; b.TextColor3=Color3.fromRGB(1,1,1); b.Parent=r
    b.MouseButton1Click:Connect(function()
        local res=cb()
        b.Text=res and "["..res.."]" or "[DONE]"
        task.delay(1,function() b.Text=">> "..name<<" <<" end)
    end)
end


-- === ЗАПОЛНЕНИЕ ===

SecTitle("MOVEMENT")
MkToggle("Infinite Jump","Прыгай бесконечно",false,function(v) ToggleInfJump(v) end)
MkToggle("Steel Floor","Платформа под ногами",false,function(v) ToggleSteelFloor(v) end)
MkToggle("Anti-AFK","Не кикнут за AFK",false,function(v) ToggleAntiAFK(v) end)
MkToggle("Noclip","Через стены",false,function(v) ToggleNoclip(v) end)

SecTitle("STEAL OPS")
MkBtn("INSTANT STEAL",Color3.fromRGB(190,55,55),DoInstaSteal)
MkBtn("DROP ITEM",Color3.fromRGB(190,150,35),DoDropItem)
MkToggle("Auto Grab Loop","Спам захватом",false,function(v) ToggleAutoGrab(v) end)

SecTitle("FARM/AUTO")
MkToggle("Auto Buy Upgrade","Купить все улучшения",false,function(v) ToggleAutoBuy(v) end)
MkToggle("Auto Speed Pump","Качать скорость",false,function(v) ToggleAutoSpeed(v) end)


-- === DRAG & CONTROL ===
local dg,dI,dS,sP
hdr.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        dg=true;dS=i.Position;sP=main.Position;i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dg=false end end)
    end
end)
hdr.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then dI=i end end)
UserInputService.InputChanged:Connect(function(i) if i==dI and dg then main.Position=UDim2new(sP.X.Scale,sP.X.Offset+(i.Position-dS).X,sP.Y.Scale,sP.Y.Offset+(i.Position-dS).Y) end end)

xbtn.MouseButton1Click:connect(function() main.Visible=false; icon.ImageColor3=Color3.fromRGB(100,100,108) end)
icon.MouseButton1Click:connect(function()
    main.Visible=not main.Visible
    icon.ImageColor3=main.Visible and Color3.fromRGB(80,160,255) or Color3.fromRGB(100,100,108)
    TweenService:Create(icon,TweenInfo(0.15),{Size=main.Visible and UDim2(0,46,0,46) or UDim2(0,50,0,50)}):Play()
end)
icon.MouseButton2Click:Connect(function()
    for _,c in pairs(Connections) do if c then if c.Disconnect then c:Disconnect() elseif type(c)=='thread' then task.cancel(c) end end end
    if FloorPart then FloorPart:Destroy() end
    gui:Destroy()
end)

print("[ZERO] Ready.")
