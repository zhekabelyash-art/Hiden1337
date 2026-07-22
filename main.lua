--[[
 ██████╗ ██╗   ██╗██╗    ███╗   ██╗██████╗  █████╗ ██╗     ███████╗██████╗ 
██╔════╝ ██║   ██║██║    ████╗  ██║██╔══██╗██╔══██╗██║     ██╔════╝██╔══██╗
██║  ███╗██║   ██║██║    ██╔██╗ ██║██║  ██║███████║██║     █████╗  ██████╔╝
██║   ██║██║   ██║██║    ██║╚██╗██║██║  ██║██╔══██║██║     ██╔══╝  ██╔══██╗
╚██████╔╝╚██████╔╝██║    ██║ ╚████║██████╔╝██║  ██║███████╗███████╗██║  ██║
 ╚═════╝  ╚═════╝ ╚═╝    ╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝
                                                            
    Полный скрипт. Одним файлом. Без сокращений.
]]

-- ============================================================
-- БЛОК 1: СЕРВИСЫ И ПЕРЕМЕННЫЕ
-- ============================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Таблица состояний — здесь хранится ВСЁ что включено/выключено
local State = {
    InfiniteJump = false,
    SteelFloor = false,
    InstantSteal = false,
    DropItem = false,
    AutoGrab = false,
    AutoBuy = false,
    AutoSpeed = false,
    AntiAFK = false,
    Noclip = false
}

-- Ссылки для очистки соединений
local Connections = {}
local FloorPart = nil

-- Загрузка сетевых событий
local Net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net")
local RE = Net:WaitForChild("RE")
local RF = Net:WaitForChild("RF")

local Remotes = {
    Grab = RE:WaitForChild("StealService"):WaitForChild("Grab"),
    Purchase = RE:WaitForChild("ShopService"):WaitForChild("Purchase"),
    SpeedUpgrade = RE:WaitForChild("TsunamiEventService"):WaitForChild("BuySpeedUpgrade")
}
local Funcs = {
    AutoBuy = RF:WaitForChild("CoinsShopService"):WaitForChild("ToggleAutoBuy")
}

-- Координаты базы (ЗАМЕНИТЬ!)
local BASE_POS = Vector3.new(0, 100, 0) 


-- ============================================================
-- БЛОК 2: ВСЕ ФУНКЦИИ РАБОТЫ (ЛОГИКА)
-- ============================================================

-- Бесконечный прыжок
function ToggleInfiniteJump(val)
    State.InfiniteJump = val
    if val then
        Connections.InfJump = UserInputService.JumpRequest:Connect(function()
            local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if Connections.InfJump then Connections.InfJump:Disconnect() Connections.InfJump = nil end
    end
    return State.InfiniteJump
end

-- Стальной пол
function ToggleSteelFloor(val)
    State.SteelFloor = val
    if val then
        FloorPart = Instance.new("Part")
        FloorPart.Size = Vector3.new(10,1,10)
        FloorPart.Color = Color3.fromRGB(40,180,255)
        FloorPart.Material = Enum.Material.Neon
        FloorPart.Transparency = 0.2
        FloorPart.CanCollide = true
        FloorPart.Anchored = true
        FloorPart.Name = "__ZeroFloor__"
        FloorPart.Parent = workspace
        
        local bp = Instance.new("BodyPosition", FloorPart)
        bp.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
        bp.P = 30000
        
        Connections.Floor = RunService.RenderStepped:Connect(function(dt)
            if not State.SteelFloor or not FloorPart then return end
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local target = hrp.Position + Vector3.new(0,-3.5,dt*5)
                bp.Position = target
                FloorPart.CFrame = CFrame.new(bp.Position) * CFrame.Angles(0,tick()*2%360,0)
            end
        end)
    else
        if Connections.Floor then Connections.Floor:Disconnect() Connections.Floor = nil end
        if FloorPart then FloorPart:Destroy() FloorPart = nil end
    end
    return State.SteelFloor
end

-- Инстант стил (одноразовое действие)
function DoInstantSteal()
    local char = LocalPlayer.Character
    if not char then return "NO_CHAR" end
    
    local tool = char:FindFirstChildOfClass("Tool")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if not tool then return "NO_TOOL" end
    if not root then return "NO_ROOT" end
    
    pcall(Remotes.Grab.FireServer, Remotes.Grab)
    task.wait(0.1)
    
    for i=1,4 do
        root.CFrame = CFrame.new(BASE_POS + Vector3.new(0,8,0))
        task.wait(0.02)
    end
    return "OK"
end

-- Дроп предмета
function DoDropItem()
    local char = LocalPlayer.Character
    if not char then return "NO_CHAR" end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return "NO_TOOL" end
    
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then tool.Parent = bp end
    task.wait(0.05)
    return "DROPPED"
end

-- Автограб
function ToggleAutoGrab(val)
    State.AutoGrab = val
    if val then
        Connections.GrabLoop = RunService.RenderStepped:Connect(function()
            if State.AutoGrab then pcall(Remotes.Grab.FireServer, Remotes.Grab) end
        end)
    else
        if Connections.GrabLoop then Connections.GrabLoop:Disconnect() Connections.GrabLoop = nil end
    end
    return State.AutoGrab
end

-- Автобай
function ToggleAutoBuy(val)
    State.AutoBuy = val
    if val then
        Connections.BuyLoop = task.spawn(function()
            while State.AutoBuy do
                pcall(Funcs.AutoBuy.InvokeServer, Funcs.AutoBuy, true)
                task.wait(2)
            end
        end)
    else
        if Connections.BuyLoop then task.cancel(Connections.BuyLoop) Connections.BuyLoop = nil end
    end
    return State.AutoBuy
end

-- Авто скорость
function ToggleAutoSpeed(val)
    State.AutoSpeed = val
    if val then
        Connections.SpeedLoop = task.spawn(function()
            while State.AutoSpeed do
                pcall(Remotes.SpeedUpgrade.FireServer, Remotes.SpeedUpgrade)
                task.wait(3)
            end
        end)
    else
        if Connections.SpeedLoop then task.cancel(Connections.SpeedLoop) Connections.SpeedLoop = nil end
    end
    return State.AutoSpeed
end

-- АнтиAFK
function ToggleAntiAFK(val)
    State.AntiAFK = val
    if val then
        Connections.AFK = LocalPlayer.Idled:Connect(function(t)
            if t > 300 and State.AntiAFK then
                local vu = Instance.new("VirtualUser")
                vu:CaptureController(); vu:SetKeyDown("0x1F"); wait(); vu:SetKeyUp("0x1F")
            end
        end)
    else
        if Connections.AFK then Connections.AFK:Disconnect() Connections.AFK = nil end
    end
    return State.AntiAFK
end

-- Ноклип
function ToggleNoclip(val)
    State.Noclip = val
    if val then
        Connections.Noclip = RunService.Stepped:Connect(function()
            if State.Noclip and LocalPlayer.Character then
                for _,p in pairs(LocalPlayer.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    else
        if Connections.Noclip then Connections.Noclip:Disconnect() Connections.Noclip = nil
            if LocalPlayer.Character then
                for _,p in pairs(LocalPlayer.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end
        end
    end
    return State.Noclip
end


-- ============================================================
-- БЛОК 3: СОЗДАНИЕ GUI — ЭЛЕМЕНТЫ ИНТЕРФЕЙСА
-- ============================================================

-- Основной контейнер ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "ZeroHub_Full"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Если уже был создан — удаляем старый
if _G.ZeroHubRef then _G.ZeroHubRef:Destroy() end
_G.ZeroHubRef = gui


--- [TOGGLE BUTTON] ---
local btn = Instance.new("ImageButton")
btn.Name = "ToggleBtn"
btn.Size = UDim2.new(0,50,0,50)
btn.Position = UDim2.new(0,15,0,15)
btn.BackgroundColor3 = Color3.fromRGB(30,30,38)
btn.Image = "rbxassetid://7743867447"
btn.ImageColor3 = Color3.fromRGB(85,170,255)
btn.Parent = gui
Instance.new("UICorner", btn).CornerRadius = UDim.new(0,12)


--- [MAIN WINDOW] ---
local main = Instance.new("Frame")
main.Name = "Window"
main.Size = UDim2.new(0,360,0,420)
main.Position = UDim2.new(0,72,0,18)
main.BackgroundColor3 = Color3.fromRGB(22,22,28)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

local strk = Instance.new("UIStroke", main)
strk.Color = Color3.fromRGB(50,50,62); strk.Thickness = 1.2


--- [HEADER] ---
local hdr = Instance.new("Frame")
hdr.Name = "Header"
hdr.Size = UDim2.new(1,0,0,36)
hdr.BackgroundColor3 = Color3.fromRGB(28,28,36)
hdr.Parent = main
Instance.new("UICorner", hdr).CornerRadius = UDim.new(0,12)
local hdrCover = Instance.new("Frame"); hdrCover.Size = UDim2.new(1,0,0,10); hdrCover.Position = UDim2.new(0,0,26,0)
hdrCover.BackgroundColor3 = Color3.fromRGB(28,28,36); hdrCover.BorderSizePixel = 0; hdrCover.ZIndex = 2; hdrCover.Parent = hdr

local ttl = Instance.new("TextLabel"); ttl.Text = " ZERO // HUB v1.0 "; ttl.Font = Enum.Font.GothamBlack; ttl.TextSize = 15
ttl.TextColor3 = Color3.fromRGB(240,240,245); ttl.BackgroundTransparency = 1; ttl.ZIndex = 3; ttl.Parent = hdr

local close = Instance.new("TextButton"); close.Text = "×"; close.Font = Enum.Font.GothamBold; close.TextSize = 20
close.Size = UDim2.new(0,26,0,26); close.Position = UDim2.new(1,-32,0,5); close.BackgroundColor3 = Color3.fromRGB(45,45,55)
close.TextColor3 = Color3.fromRGB(255,70,70); close.ZIndex = 3; close.BackgroundTransparency = 0; close.Parent = hdr
Instance.new("UICorner", close).CornerRadius = UDim.new(0,6)


--- [SCROLLING CONTENT] ---
local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Content"
scroll.Size = UDim2.new(1,-16,1,-44)
scroll.Position = UDim2.new(0,8,0,40)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(85,170,255)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.Parent = main
Instance.new("UIListLayout", scroll).Padding = UDim.new(0,6)


-- ============================================================
-- БЛОК 4: КОМПОНЕНТЫ UI (Генераторы элементов)
-- ============================================================

-- Создание заголовка секции
function SectionLabel(text)
    local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,24); f.BackgroundTransparency = 1; f.Parent = scroll
    local ln = Instance.new("Frame"); ln.Size = UDim2.new(1,0,0,1); ln.Position = UDim2.new(0,0,0,11.5)
    ln.BackgroundColor3 = Color3.fromRGB(50,50,60); ln.BorderSizePixel = 0; ln.Parent = f
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(0,text:len()*8+16,0,20); bg.Position = UDim2.new(0,8,0,2)
    bg.BackgroundColor3 = Color3.fromRGB(35,35,45); bg.Parent = f; Instance.new("UICorner",bg).CornerRadius = UDim.new(0,4)
    local lb = Instance.new("TextLabel"); lb.Size = UDim2.new(1,0,1,0); lb.BackgroundTransparency = 1
    lb.Text = text; lb.TextColor3 = Color3.fromRGB(85,170,255); lb.Font = Enum.Font.GothamSemibold; lb.TextSize = 11; lb.Parent = bg
    return f
end

-- Создание TOGGLE (переключателя) с привязкой к функции
function MakeToggle(name, desc, default, func)
    local order = #scroll:GetChildren()
    
    -- Контейнер строки
    local row = Instance.new("Frame"); row.Name = name.."_Row"; row.Size = UDim2.new(1,0,0,42)
    row.BackgroundColor3 = Color3.fromRGB(30,30,38); row.LayoutOrder = order; row.Parent = scroll
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,7)
    
    -- Текст слева
    local txt = Instance.new("TextLabel"); txt.Size = UDim2.new(1,-64,0.65,0); txt.Position = UDim2.new(0,10,0,3)
    txt.BackgroundTransparency = 1; txt.Text = name; txt.TextColor3 = Color3.fromRGB(230,230,235)
    txt.Font = Enum.Font.GothamSemibold; txt.TextSize = 13; txt.TextXAlignment = Enum.TextXAlignment.Left; txt.Parent = row
    
    local dsc = Instance.new("TextLabel"); dsc.Size = UDim2(1,-74,0.32,0); dsc.Position = UDim2.new(0,10,0.66,0)
    dsc.BackgroundTransparency = 1; dsc.Text = desc or ""; dsc.TextColor3 = Color3.fromRGB(130,130,145)
    dsc.Font = Enum.Font.Gotham; dsc.TextSize = 9; dsc.TextXAlignment = Enum.TextXAlignment.Left; dsc.TextWrapped=true; dsc.Parent = row
    
    -- Свитч справа
    local sw = Instance.new("TextButton"); sw.Name = "Switch"; sw.Size = UDim2.new(0,46,0,24); sw.Position = UDim2.new(1,-52,0.5,-12)
    sw.BackgroundColor3 = Color3.fromRGB(55,55,68); sw.Text = ""; sw.AutoButtonColor = false; sw.Parent = row
    Instance.new("UICorner",sw).CornerRadius = UDim.new(1,0)
    
    local knob = Instance.new("Frame"); knob.Name = "Knob"; knob.Size = UDim2.new(0,18,0,18)
    knob.Position = UDim2.new(0,3,0.5,-9); knob.BackgroundColor3 = Color3.fromRGB(220,220,225); knob.Parent = sw
    Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)
    
    -- Статусная метка (ПОКАЗ СТАТУСА ФУНКЦИИ)
    local stlbl = Instance.new("TextLabel"); stlbl.Name = "Status"
    stlbl.Size = UDim2.new(0,46,0,14); stlbl.Position = UDim2.new(1,-52,0.5,13)
    stlbl.BackgroundTransparency = 1; stlbl.Text = "OFF"; stlbl.Font = Enum.Font.GothamBold; stlbl.TextSize = 8
    stlbl.TextColor3 = Color3.fromRGB(140,140,150); stlbl.Parent = row
    
    -- Логика переключения
    local cur = default or false
    local function update(state)
        cur = state
        -- АНИМАЦИЯ цвета свитча
        TweenService:Create(sw, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(80,200,120) or Color3.fromRGB(55,55,68)
        }):Play()
        -- АНИМАЦИЯ позиции крутилки
        TweenService:Create(knob, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
        }):Play()
        -- ПОКАЗ СТАТУСА ТЕКСТОМ
        stlbl.Text = state and "ON" or "OFF"
        stlbl.TextColor3 = state and Color3.fromRGB(80,200,120) or Color3.fromRGB(140,140,150)
        
        -- Вызов привязанной функции
        if func then func(state) end
    end
    
    update(cur) -- начальное состояние
    sw.MouseButton1Click:Connect(function() update(not cur) end)
    
    return {row=row, switch=sw, set=function(s) update(s) end, get=function() return cur end}
end

-- Создание ACTION BUTTON (кнопки действия)
function MakeAction(name, color, callback)
    local order = #scroll:GetChildren()
    local row = Instance.new("Frame"); row.Name = name.."_Act"; row.Size = UDim2.new(1,0,0,36)
    row.BackgroundColor3 = color; row.LayoutOrder = order; row.Parent = scroll
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,7)
    
    local b = Instance.new("TextButton"); b.Size = UDim2.new(1,0,1,0); b.BackgroundTransparency = 1
    b.Text = ">> "..name.." <<"; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamBold; b.TextSize = 12
    b.Parent = row
    
    local statusText = Instance.new("TextLabel"); statusText.Name = "Result"
    statusText.Size = UDim2.new(1,0,1,0); statusText.BackgroundTransparency = 1
    statusText.Text = ""; statusText.Font = Enum.Font.GothamBold; statusText.TextSize = 11
    statusText.Visible = false; statusText.Parent = row
    
    b.MouseButton1Click:Connect(function()
        local result = callback()
        if type(result) == "string" then
            b.Text = "["..result.."]"
            delay(1.2, function() b.Text = ">> "..name.." <<" end)
        end
    end)
    
    return {btn=b, label=statusText, setTxt=function(t) b.Text=t end}
end


-- ============================================================
-- БЛОК 5: ЗАПОЛНЕНИЕ МЕНЮ + ПРИВЯЗКА ФУНКЦИЙ КНОПКАМ
-- ============================================================

-- === ДВИЖЕНИЕ ===
SectionLabel("MOVEMENT")

MakeToggle("Infinite Jump", "Бесконечные прыжки в воздухе", false, function(v) ToggleInfiniteJump(v) end)
MakeToggle("Steel Floor", "Платформа под ногами поднимает вверх", false, function(v) ToggleSteelFloor(v) end)
MakeToggle("Anti-AFK", "Блокировка кика за бездействие", false, function(v) ToggleAntiAFK(v) end)
MakeToggle("Noclip", "Проход сквозь стены", false, function(v) ToggleNoclip(v) end)

-- === СТЕЙЛ ОПЕРАЦИИ ===
SectionLabel("STEAL OPERATIONS")

MakeAction("INSTANT STEAL", Color3.fromRGB(200,60,60), function()
    return DoInstantSteal()
end)

MakeAction("DROP ITEM", Color3.fromRGB(200,160,40), function()
    return DoDropItem()
end)

MakeToggle("Auto Grab Loop", "Автоматический спам захвата объектов", false, function(v) ToggleAutoGrab(v) end)

-- === АВТОМАТИЗАЦИЯ ===
SectionLabel("AUTOMATION / FARM")

MakeToggle("Auto Buy Upgrade", "Принудительная покупка улучшений", false, function(v) ToggleAutoBuy(v) end)
MakeToggle("Auto Speed Pump", "Непрерывная прокачка скорости", false, function(v) ToggleAutoSpeed(v) end)


-- ============================================================
-- БЛОК 6: УПРАВЛЕНИЕ ОКНОМ (Drag, Toggle, Close)
-- ============================================================

-- Drag (перетаскивание за шапку)
local drag,dgInput,dgStart,startPos
hdr.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        drag=true; dgStart=i.Position; startPos=main.Position
        i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag=false end end)
    end
end)
hdr.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then dgInput=i end end)
UserInputService.InputChanged:Connect(function(i)
    if i==dgInput and drag then
        main.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+(i.Position-dgStart).X,startPos.Y.Scale,startPos.Y.Offset+(i.Position-dgStart).Y)
    end
end)

-- Close button (свернуть окно)
close.MouseButton1Click:Connect(function()
    main.Visible = false
    btn.ImageColor3 = Color3.fromRGB(100,100,110)
end)

-- Toggle button (иконка для открытия/закрытия)
btn.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
    btn.ImageColor3 = main.Visible and Color3.fromRGB(85,170,255) or Color3.fromRGB(100,100,110)
    TweenService:Create(btn, TweenInfo.new(0.15), {
        Size = main.Visible and UDim2.new(0,48,0,48) or UDim2.new(0,52,0,52)
    }):Play()
end)

-- Right-click destroy
btn.MouseButton2Click:Connect(function()
    for _,c in pairs(Connections) do if c then if c.Disconnect then c:Disconnect() elseif type(c)=='thread' then task.cancel(c) end end end
    if FloorPart then FloorPart:Destroy() end
    gui:Destroy()
    print("[ZeroHub] Destroyed.")
end)


-- ============================================================
-- ГОТОВО
-- ============================================================

print("[ZeroHub] Loaded. Items:", #scroll:GetChildren())
