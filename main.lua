local Players=game:GetService("Players")
local LP=Players.LocalPlayer
local RS=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local TS=game:GetService("TweenService")
local RepSt=game:GetService("ReplicatedStorage")

local S={IJ=false,FL=false,AG=false,AB=false,SP=false,AF=false,NC=false}
local C={}
local FP=nil
local BP=Vector3.new(0,100,0)

local R={Grab=nil,Buy=nil,Spd=nil}
local F={ABuy=nil}

spawn(function()
	local pk=RepSt:FindFirstChild("Packages")
	if not pk then return end
	local nt=pk:FindFirstChild("Net")
	if not nt then return end
	local re=nt:FindFirstChild("RE")
	local rf=nt:FindFirstChild("RF")
	if re then
		local ss=re:FindFirstChild("StealService")
		if ss then R.Grab=ss:FindFirstChild("Grab") end
		local sh=re:FindFirstChild("ShopService")
		if sh then R.Buy=sh:FindFirstChild("Purchase") end
		local ts=re:FindFirstChild("TsunamiEventService")
		if ts then R.Spd=ts:FindFirstChild("BuySpeedUpgrade") end
	end
	if rf then
		local cs=rf:FindFirstChild("CoinsShopService")
		if cs then F.ABuy=cs:FindFirstChild("ToggleAutoBuy") end
	end
end)

function TogIJ(v)
	S.IJ=v
	if v then
		C.IJ=UIS.JumpRequest:Connect(function()
			local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
			if h and h.Health>0 then h:ChangeState(16) end
		end)
	elseif C.IJ then
		C.IJ:Disconnect();C.IJ=nil
	end
end

function TogFL(v)
	S.FL=v
	if v then
		FP=Instance.new("Part");FP.Name="ZF";FP.Size=Vector3.new(10,1,10);FP.Color=Color3.fromRGB(40,180,255);FP.Material=Enum.Material.Neon;FP.Transparency=0.2;FP.CanCollide=true;FP.Anchored=true;FP.Parent=workspace
		local bp=Instance.new("BodyPosition",FP);bp.MaxForce=Vector3.new(math.huge,math.huge,math.huge);bp.P=30000
		C.FL=RS.RenderStepped:Connect(function(dt)
			if not S.FL or not FP then return end
			local c=LP.Character;if c then local h=c:FindFirstChild("HumanoidRootPart")if h then bp.Position=h.Position+Vector3.new(0,-3.5,dt*4)end end
		end)
	else
		if C.FL then C.FL:Disconnect();C.FL=nil end
		if FP then FP:Destroy();FP=nil end
	end
end

function DoSt()
	local c=LP.Character;if not c then return"E"end
	local t=c:FindFirstChildOfClass("Tool");local r=c:FindFirstChild("HumanoidRootPart")
	if not t then return"E"end if not r then return"E"end
	if R.Grab then pcall(R.Grab.FireServer,R.Grab)end wait(0.08)r.CFrame=CFrame.new(BP+Vector3.new(0,8,0))return"OK"
end

function DoDr()
	local c=LP.Character;if not c then return"E"end
	local t=c:FindFirstChildOfClass("Tool");if not t then return"E"end
	local bk=LP:FindFirstChild("Backpack")if bk then t.Parent=bk;wait(0.05)return"OK"end return"F"
end

function TogAG(v)
	S.AG=v
	if v then C.AG=RS.RenderStepped:Connect(function()if S.AG and R.Grab then pcall(R.Grab.FireServer,R.Grab)end end)
	elseif C.AG then C.AG:Disconnect();C.AG=nil end
end

function TogAB(v)
	S.AB=v
	if v then C.AB=coroutine.wrap(function()while S.AB do if F.ABuy then pcall(F.ABuy.InvokeServer,F.ABuy,true)end wait(2)end end)()
	else S.AB=false end
end

function TogSP(v)
	S.SP=v
	if v then C.SP=coroutine.wrap(function()while S.SP do if R.Spd then pcall(R.Spd.FireServer,R.Spd)end wait(3)end end)()
	else S.SP=false end
end

function TogAF(v)
	S.AF=v
	if v then C.AF=LP.Idled:Connect(function(t)if t>300 and S.AF then local vu=Instance.new("VirtualUser")vu:CaptureController();vu:SetKeyDown(0x1F);wait();vu:SetKeyUp(0x1F)end end)
	elseif C.AF then C.AF:Disconnect();C.AF=nil end
end

function TogNC(v)
	S.NC=v
	if v then C.NC=RS.Stepped:Connect(function()if S.NC and LP.Character then for _,p in pairs(LP.Character:GetDescendants())do if p:IsA("BasePart")then p.CanCollide=false end end end end)
	elseif C.NC then C.NC:Disconnect();C.NC=nil if LP.Character then for _,p in pairs(LP.Character:GetDescendants())do if p:IsA("BasePart")then p.CanCollide=true end end end end
end


-- GUI START

local g=Instance.new("ScreenGui")
g.Name="ZH4"
g.ResetOnSpawn=false
g.Parent=LP:WaitForChild("PlayerGui")
if _G.ZH4 then _G.ZH4:Destroy() end
_G.ZH4=g

-- Icon
local ic=Instance.new("ImageButton")
ic.Name="Ic"
ic.Size=UDim2.new(0,44,0,44)
ic.Position=UDim2.new(0,12,0,12)
ic.BackgroundColor3=Color3.fromRGB(26,26,32)
ic.Image="rbxassetid://7743867447"
ic.ImageColor3=Color3.fromRGB(70,150,240)
ic.Parent=g

-- Corner для Icon - УDIM (не UDim2!)
local icCr=Instance.new("UICorner")
icCr.CornerRadius=UDim.new(0,11)
icCr.Parent=ic

-- Main Window
local w=Instance.new("Frame")
w.Name="W"
w.Size=UDim2.new(0,300,0,360)
w.Position=UDim2.new(0,62,0,16)
w.BackgroundColor3=Color3.fromRGB(18,18,24)
w.BorderSizePixel=0
w.Visible=false -- Начально скрыто!
w.Parent=g

-- Corner для Window - УDIM
local wCr=Instance.new("UICorner")
wCr.CornerRadius=UDim.new(0,10)
wCr.Parent=w

local ws=Instance.new("UIStroke",w)
ws.Color=Color3.fromRGB(42,42,52)
ws.Thickness=1

-- Header
local hd=Instance.new("Frame")
hd.Size=UDim2.new(1,0,0,30)
hd.BackgroundColor3=Color3.fromRGB(24,24,32)
hd.Parent=w

-- Header corner - УDIM
local hdCr=Instance.new("UICorner")
hdCr.CornerRadius=UDim.new(0,10)
hdCr.Parent=hd

local hc=Instance.new("Frame")
hc.Size=UDim2.new(1,0,0,7)
hc.Position=UDim2.new(0,0,23,0)
hc.BackgroundColor3=Color3.fromRGB(24,24,32)
hc.BorderSizePixel=0
hc.ZIndex=2
hc.Parent=hd

local ttl=Instance.new("TextLabel")
ttl.Text=" ZERO HUB "
ttl.Font=Enum.Font.GothamBlack
ttl.TextSize=13
ttl.TextColor3=Color3.fromRGB(230,230,235)
ttl.BackgroundTransparency=1
ttl.ZIndex=3
ttl.Parent=hd

local cls=Instance.new("TextButton")
cls.Text="X"
cls.Font=Enum.Font.GothamBold
cls.TextSize=15
cls.Size=UDim2.new(0,20,0,20)
cls.Position=UDim2.new(1,-24,0,5)
cls.BackgroundColor3=Color3.fromRGB(40,40,50)
cls.TextColor3=Color3.fromRGB(255,60,60)
cls.ZIndex=3
cls.Parent=hd

-- Close button corner - УDIM
local clsCr=Instance.new("UICorner")
clsCr.CornerRadius=UDim.new(0,5)
clsCr.Parent=cls

-- Scroll Content
local scr=Instance.new("ScrollingFrame")
scr.Name="C"
scr.Size=UDim2.new(1,-8,1,-34)
scr.Position=UDim2.new(0,4,0,32)
scr.BackgroundTransparency=1
scr.ScrollBarThickness=3
scr.ScrollBarImageColor3=Color3.fromRGB(70,150,240)
scr.CanvasSize=UDim2.new(0,0,0,0)
scr.Parent=w

local lst=Instance.new("UIListLayout",scr)
lst.Padding=UDim2.new(0,4)

lst:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scr.CanvasSize=UDim2.new(0,0,0,lst.AbsoluteContentSize.Y+6)
end)


-- HELPERS WITH FIXED CORNERS (always use UDim.new for CornerRadius)

function Sec(t)
	local f=Instance.new("Frame");f.Size=UDim2.new(1,0,0,18);f.BackgroundTransparency=1;f.Parent=scr
	local ln=Instance.new("Frame");ln.Size=UDim2.new(1,0,0,1);ln.Position=UDim2.new(0,0,0,8.5);ln.BackgroundColor3=Color3.fromRGB(45,45,55);ln.BorderSizePixel=0;ln.Parent=f
	local bg=Instance.new("Frame");bg.Size=UDim2.new(0,#t*7+10,0,14);bg.Position=UDim2.new(0,4,0,2);bg.BackgroundColor3=Color3.fromRGB(28,28,36);bg.Parent=f
	local bgCr=Instance.new("UICorner");bgCr.CornerRadius=UDim.new(0,4);bgCr.Parent=bg -- FIX HERE
	local lb=Instance.new("TextLabel");lb.Size=UDim2.new(1,0,1,0);lb.BackgroundTransparency=1;lb.Text=t;lb.TextColor3=Color3.fromRGB(70,150,240);lb.Font=Enum.Font.GothamSemibold;lb.TextSize=9;lb.Parent=bg
end

function Tgl(nm,dsc,def,cb)
	local o=#scr:GetChildren()
	local r=Instance.new("Frame");r.Size=UDim2.new(1,0,0,34);r.BackgroundColor3=Color3.fromRGB(26,26,34);r.LayoutOrder=o;r.Parent=scr
	local rCr=Instance.new("UICorner");rCr.CornerRadius=UDim.new(0,5);rCr.Parent=r -- FIX HERE
	local nm2=Instance.new("TextLabel");nm2.Size=UDim2.new(1,-50,0.56,0);nm2.Position=UDim2.new(0,6,0,2);nm2.Text=nm;nm2.Font=Enum.Font.GothamSemibold;nm2.TextSize=11;nm2.TextColor3=Color3.fromRGB(220,220,225);nm2.BackgroundTransparency=1;nm2.TextXAlignment=Enum.TextXAlignment.Left;nm2.Parent=r
	local ds=Instance.new("TextLabel");ds.Size=UDim2.new(1,-58,0.38,0);ds.Position=UDim2.new(0,6,0.58,0);ds.Text=dsc or "";ds.Font=Enum.Font.Gotham;ds.TextSize=8;ds.TextColor3=Color3.fromRGB(120,120,135);ds.BackgroundTransparency=1;ds.TextXAlignment=Enum.TextXAlignment.Left;ds.TextWrapped=true;ds.Parent=r
	local sw=Instance.new("TextButton");sw.Size=UDim2.new(0,40,0,18);sw.Position=UDim2.new(1,-44,0.5,-9);sw.BackgroundColor3=Color3.fromRGB(48,48,60);sw.Text="";sw.AutoButtonColor=false;sw.Parent=r
	local swCr=Instance.new("UICorner");swCr.CornerRadius=UDim.new(1,0);swCr.Parent=sw -- FIX HERE
	local kn=Instance.new("Frame");kn.Size=UDim2.new(0,12,0,12);kn.Position=UDim2.new(0,3,0.5,-6);kn.BackgroundColor3=Color3.fromRGB(210,210,215);kn.Parent=sw
	local knCr=Instance.new("UICorner");knCr.CornerRadius=UDim.new(1,0);knCr.Parent=kn -- FIX HERE
	local st=Instance.new("TextLabel");st.Size=UDim2.new(0,40,0,9);st.Position=UDim2(1,-44,0.5,9);st.BackgroundTransparency=1;st.Text=def and "ON" or "OFF";st.Font=Enum.Font.GothamBold;st.TextSize=7;st.TextColor3=def and Color3.fromRGB(65,185,105) or Color3.fromRGB(115,115,130);st.Parent=r
	local cr=def
	function Up(v)
		cr=v;TS:Create(sw,TweenInfo(0.15),{BackgroundColor3=v and Color3.fromRGB(65,185,105) or Color3.fromRGB(48,48,60)}):Play();TS:Create(kn,TweenInfo(0.15),{Position=v and UDim2.new(1,-16,0.5,-6) or UDim2.new(0,3,0.5,-6)}):Play();st.Text=v and "ON" or "OFF";st.TextColor3=v and Color3.fromRGB(65,185,105) or Color3.fromRGB(115,115,130);if cb then cb(v)end
	end
	Up(cr);sw.MouseButton1Click:Connect(function()Up(not cr)end)
end

function Btn(nm,col,fn)
	local o=#scr:GetChildren()
	local r=Instance.new("Frame");r.Size=UDim2.new(1,0,0,28);r.BackgroundColor3=col;r.LayoutOrder=o;r.Parent=scr
	local rCr=Instance.new("UICorner");rCr.CornerRadius=UDim.new(0,5);rCr.Parent=r -- FIX HERE
	local b=Instance.new("TextButton");b.Size=UDim2.new(1,0,1,0);b.BackgroundTransparency=1;b.Text="> "..nm.." <";b.Font=Enum.Font.GothamBold;b.TextSize=11;b.TextColor3=Color3.new(1,1,1);b.Parent=r
	b.MouseButton1Click:Connect(function()
		local res=fn()
		if type(res)=="string" then b.Text="["..res.."]";wait(1);b.Text="> "..nm.." <" end
	end)
end


-- POPULATE

Sec("MOVEMENT")
Tgl("Infinite Jump","Бесконечные прыжки",false,function(v)TogIJ(v)end)
Tgl("Steel Floor","Поднимающийся пол",false,function(v)TogFL(v)end)
Tgl("Anti-AFK","Защита от кика AFK",false,function(v)TogAF(v)end)
Tgl("Noclip","Проход через стены",false,function(v)TogNC(v)end)

Sec("STEAL")
Btn("INSTANT STEAL",Color3.fromRGB(170,45,45),DoSt)
Btn("DROP ITEM",Color3.fromRGB(170,130,25),DoDr)
Tgl("Auto Grab","Спам захвата",false,function(v)TogAG(v)end)

Sec("AUTO FARM")
Tgl("Auto Upgrade","Автопокупка улучшений",false,function(v)TogAB(v)end)
Tgl("Auto Speed","Качать скорость",false,function(v)TogSP(v)end)


-- LOGIC

local dg,dI,dS,sP
hd.InputBegan:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 then dg=true;dS=i.Position;sP=w.Position;i.Changed:Connect(function()if i.UserInputState==Enum.UserInputState.End then dg=false end end) end
end)
hd.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then dI=i end end)
UIS.InputChanged:Connect(function(i) if i==dI and dg then w.Position=UDim2.new(sP.X.Scale,sP.X.Offset+(i.Position-dS).X,sP.Y.Scale,sP.Y.Offset+(i.Position-dS).Y) end end)

cls.MouseButton1Click:Connect(function() w.Visible=false;ic.ImageColor3=Color3.fromRGB(100,100,108) end)

-- TOGGLE BUTTON - ПОКАЗЫВАЕТ/СКРЫВАЕТ ОКНО
ic.MouseButton1Click:Connect(function()
	w.Visible=not w.Visible
	ic.ImageColor3=w.Visible and Color3.fromRGB(70,150,240) or Color3.fromRGB(100,100,108)
end)

ic.MouseButton2Click:Connect(function()
	for _,c in pairs(C) do if c then if type(c.Disconnect)=="function"then c:Disconnect()end end end
	if FP then FP:Destroy()end
	g:Destroy()
end)

print("[ZERO] V4 Loaded OK")
