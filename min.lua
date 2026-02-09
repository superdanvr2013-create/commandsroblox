local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- === НАСТРОЙКИ АНИМАЦИИ ===
local WICKED_IDS = {
	run = 72301599441680,
	walk = 92072849924640,
	jump = 104325245285198,
	fall = 121152442762481,
	idle = {118832222982049, 76049494037641}, 
	climb = 131326830509784,
}

local savedAnimateScript = nil 

-- === 1. СОЗДАНИЕ ИНТЕРФЕЙСА ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UltraControlGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local function createButton(name, text, position, color)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Text = text
	btn.Size = UDim2.new(0, 220, 0, 35)
	btn.Position = position
	btn.BackgroundColor3 = color
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.Parent = screenGui
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	return btn
end

local function createSmallButton(name, text, position, size, color)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Text = text
	btn.Size = size
	btn.Position = position
	btn.BackgroundColor3 = color
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.Parent = screenGui
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	return btn
end

-- Кнопки
local freezeBtn     = createButton("FreezeBtn", "Заморозить", UDim2.new(0.02, 0, 0.40, 0), Color3.fromRGB(46, 204, 113))
local platformBtn   = createButton("PlatformBtn", "Платформа (L-Ctrl)", UDim2.new(0.02, 0, 0.45, 0), Color3.fromRGB(52, 152, 219))
local clearBtn      = createButton("ClearBtn", "Удалить все платформы", UDim2.new(0.02, 0, 0.50, 0), Color3.fromRGB(149, 165, 166))

local decXBtn = createSmallButton("DecX", "X -", UDim2.new(0.02, 0, 0.55, 0), UDim2.new(0, 105, 0, 35), Color3.fromRGB(230, 126, 34))
local incXBtn = createSmallButton("IncX", "X +", UDim2.new(0.02, 115, 0.55, 0), UDim2.new(0, 105, 0, 35), Color3.fromRGB(230, 126, 34))
local decZBtn = createSmallButton("DecZ", "Z -", UDim2.new(0.02, 0, 0.60, 0), UDim2.new(0, 105, 0, 35), Color3.fromRGB(211, 84, 0))
local incZBtn = createSmallButton("IncZ", "Z +", UDim2.new(0.02, 115, 0.60, 0), UDim2.new(0, 105, 0, 35), Color3.fromRGB(211, 84, 0))

local customAnimBtn = createButton("CustomAnimBtn", "Стиль: WICKED POPULAR", UDim2.new(0.02, 0, 0.65, 0), Color3.fromRGB(142, 68, 173))
local defaultAnimBtn = createButton("DefaultAnimBtn", "Стиль: СТАНДАРТ", UDim2.new(0.02, 0, 0.70, 0), Color3.fromRGB(44, 62, 80))
local xrayBtn       = createButton("XrayBtn", "Показать невидимые", UDim2.new(0.02, 0, 0.75, 0), Color3.fromRGB(50, 50, 50))

-- === 2. ЛОГИКА ИЗМЕНЕНИЯ РАЗМЕРА (ТОЛЬКО ПОД НОГАМИ) ===

local function resizeCurrentPlatform(axis, amount)
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	
	-- Ищем деталь на которой стоим
	local floorPart = hum and hum.SeatPart or (hum and hum.FloorPart)
	
	if floorPart and floorPart.Name == "MyPlatform" then
		local s = floorPart.Size
		if axis == "X" then
			floorPart.Size = Vector3.new(math.max(1, s.X + amount), s.Y, s.Z)
		elseif axis == "Z" then
			floorPart.Size = Vector3.new(s.X, s.Y, math.max(1, s.Z + amount))
		end
	end
end

decXBtn.MouseButton1Click:Connect(function() resizeCurrentPlatform("X", -4) end)
incXBtn.MouseButton1Click:Connect(function() resizeCurrentPlatform("X", 4) end)
decZBtn.MouseButton1Click:Connect(function() resizeCurrentPlatform("Z", -4) end)
incZBtn.MouseButton1Click:Connect(function() resizeCurrentPlatform("Z", 4) end)

-- === 3. ЛОГИКА АНИМАЦИИ (SWAP METHOD) ===

local function applyWickedIds(scriptObj)
	local function setVal(folder, child, id)
		local f = scriptObj:FindFirstChild(folder)
		local anim = f and f:FindFirstChild(child)
		if anim then anim.AnimationId = "rbxassetid://"..tostring(id) end
	end
	setVal("run", "RunAnim", WICKED_IDS.run)
	setVal("walk", "WalkAnim", WICKED_IDS.walk)
	setVal("jump", "JumpAnim", WICKED_IDS.jump)
	setVal("fall", "FallAnim", WICKED_IDS.fall)
	setVal("climb", "ClimbAnim", WICKED_IDS.climb)
	local idleF = scriptObj:FindFirstChild("idle")
	if idleF then
		if idleF:FindFirstChild("Animation1") then idleF.Animation1.AnimationId = "rbxassetid://"..tostring(WICKED_IDS.idle[1]) end
		if idleF:FindFirstChild("Animation2") then idleF.Animation2.AnimationId = "rbxassetid://"..tostring(WICKED_IDS.idle[2]) end
	end
end

local function switchAnimation(mode)
	local char = player.Character
	if not char or not savedAnimateScript then return end
	if char:FindFirstChild("Animate") then char.Animate:Destroy() end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:Stop(0) end
	end
	local newAnim = savedAnimateScript:Clone()
	if mode == "Wicked" then
		applyWickedIds(newAnim)
		customAnimBtn.Text = "Стиль: WICKED (ВКЛ)"
		defaultAnimBtn.Text = "Стиль: СТАНДАРТ"
	else
		customAnimBtn.Text = "Стиль: WICKED POPULAR"
		defaultAnimBtn.Text = "Стиль: СТАНДАРТ (ВКЛ)"
	end
	newAnim.Parent = char
end

-- === 4. ОСТАЛЬНЫЕ ФУНКЦИИ ===

local savedXray = {}
local xrayActive = false
xrayBtn.MouseButton1Click:Connect(function()
	xrayActive = not xrayActive
	if xrayActive then
		for _, o in pairs(workspace:GetDescendants()) do
			if o:IsA("BasePart") and o.Transparency >= 1 then
				savedXray[o] = o.Transparency
				o.Transparency = 0.5
			end
		end
		xrayBtn.Text = "Скрытые: ВИДНЫ"
	else
		for o, t in pairs(savedXray) do if o.Parent then o.Transparency = t end end
		table.clear(savedXray)
		xrayBtn.Text = "Показать невидимые"
	end
end)

local function onChar(char)
	local a = char:WaitForChild("Animate", 10)
	if a and not savedAnimateScript then savedAnimateScript = a:Clone() end
end
player.CharacterAdded:Connect(onChar)
if player.Character then onChar(player.Character) end

customAnimBtn.MouseButton1Click:Connect(function() switchAnimation("Wicked") end)
defaultAnimBtn.MouseButton1Click:Connect(function() switchAnimation("Default") end)

freezeBtn.MouseButton1Click:Connect(function()
	local r = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if r then r.Anchored = not r.Anchored end
end)

local function spawnP()
	local r = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if r then
		local p = Instance.new("Part")
		p.Name = "MyPlatform"
		p.Size = Vector3.new(10, 1, 10)
		p.Anchored = true
		p.Position = r.Position + Vector3.new(0, -3.5, 0)
		p.Parent = workspace
	end
end
platformBtn.MouseButton1Click:Connect(spawnP)
UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.LeftControl then spawnP() end end)
clearBtn.MouseButton1Click:Connect(function()
	for _, v in pairs(workspace:GetChildren()) do if v.Name == "MyPlatform" then v:Destroy() end end
end)
