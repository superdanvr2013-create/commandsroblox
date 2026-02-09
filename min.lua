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
	btn.Size = UDim2.new(0, 220, 0, 35) -- Чуть уменьшил высоту, чтобы все влезло
	btn.Position = position
	btn.BackgroundColor3 = color
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.Parent = screenGui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn
	return btn
end

-- Создаем 6 кнопок
local freezeBtn     = createButton("FreezeBtn", "Заморозить", UDim2.new(0.02, 0, 0.45, 0), Color3.fromRGB(46, 204, 113))
local platformBtn   = createButton("PlatformBtn", "Платформа (L-Ctrl)", UDim2.new(0.02, 0, 0.50, 0), Color3.fromRGB(52, 152, 219))
local clearBtn      = createButton("ClearBtn", "Удалить платформы", UDim2.new(0.02, 0, 0.55, 0), Color3.fromRGB(149, 165, 166))
local customAnimBtn = createButton("CustomAnimBtn", "Стиль: WICKED POPULAR", UDim2.new(0.02, 0, 0.60, 0), Color3.fromRGB(142, 68, 173))
local defaultAnimBtn = createButton("DefaultAnimBtn", "Стиль: СТАНДАРТ", UDim2.new(0.02, 0, 0.65, 0), Color3.fromRGB(44, 62, 80))
local xrayBtn       = createButton("XrayBtn", "Показать невидимые", UDim2.new(0.02, 0, 0.70, 0), Color3.fromRGB(211, 84, 0))

-- === 2. ЛОГИКА VISIBILITY (X-RAY) ===

local savedInvisibleParts = {} -- Таблица для запоминания скрытых частей
local isXrayActive = false

xrayBtn.MouseButton1Click:Connect(function()
	isXrayActive = not isXrayActive
	
	if isXrayActive then
		-- ВКЛЮЧАЕМ: Ищем невидимые блоки и делаем их видимыми
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") and obj.Transparency >= 1 then
				-- Сохраняем в таблицу: [объект] = его старая прозрачность (обычно 1)
				savedInvisibleParts[obj] = obj.Transparency
				-- Делаем полупрозрачным (красноватый оттенок для заметности)
				obj.Transparency = 0.5
				-- (Опционально) Можно добавить SelectionBox, но пока просто прозрачность
			end
		end
		
		xrayBtn.Text = "Скрытые: ВИДНЫ"
		xrayBtn.BackgroundColor3 = Color3.fromRGB(230, 126, 34) -- Оранжевый поярче
	else
		-- ВЫКЛЮЧАЕМ: Возвращаем как было
		for part, oldTrans in pairs(savedInvisibleParts) do
			if part and part.Parent then -- Проверяем, существует ли деталь до сих пор
				part.Transparency = oldTrans
			end
		end
		-- Очищаем список
		table.clear(savedInvisibleParts)
		
		xrayBtn.Text = "Показать невидимые"
		xrayBtn.BackgroundColor3 = Color3.fromRGB(211, 84, 0) -- Темно-оранжевый
	end
end)

-- === 3. ЛОГИКА АНИМАЦИИ ===

local function applyWickedIds(scriptObj)
	local function setVal(folderName, childName, id)
		local f = scriptObj:FindFirstChild(folderName)
		if f then
			local anim = f:FindFirstChild(childName)
			if anim and anim:IsA("Animation") then
				anim.AnimationId = "rbxassetid://"..tostring(id)
			end
		end
	end
	setVal("run", "RunAnim", WICKED_IDS.run)
	setVal("walk", "WalkAnim", WICKED_IDS.walk)
	setVal("jump", "JumpAnim", WICKED_IDS.jump)
	setVal("fall", "FallAnim", WICKED_IDS.fall)
	setVal("climb", "ClimbAnim", WICKED_IDS.climb)
	local idleF = scriptObj:FindFirstChild("idle")
	if idleF then
		local a1 = idleF:FindFirstChild("Animation1")
		local a2 = idleF:FindFirstChild("Animation2")
		if a1 then a1.AnimationId = "rbxassetid://"..tostring(WICKED_IDS.idle[1]) end
		if a2 then a2.AnimationId = "rbxassetid://"..tostring(WICKED_IDS.idle[2]) end
	end
end

local function switchAnimation(mode)
	local char = player.Character
	if not char or not savedAnimateScript then return end
	
	local old = char:FindFirstChild("Animate")
	if old then old:Destroy() end
	
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		local animator = hum:FindFirstChildOfClass("Animator")
		if animator then
			for _, track in pairs(animator:GetPlayingAnimationTracks()) do
				track:Stop(0)
			end
		end
	end
	
	local newAnimate = savedAnimateScript:Clone()
	if mode == "Wicked" then
		applyWickedIds(newAnimate)
		customAnimBtn.Text = "Стиль: WICKED (ВКЛ)"
		defaultAnimBtn.Text = "Стиль: СТАНДАРТ"
		customAnimBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 140)
		defaultAnimBtn.BackgroundColor3 = Color3.fromRGB(44, 62, 80)
	else
		customAnimBtn.Text = "Стиль: WICKED POPULAR"
		defaultAnimBtn.Text = "Стиль: СТАНДАРТ (ВКЛ)"
		customAnimBtn.BackgroundColor3 = Color3.fromRGB(142, 68, 173)
		defaultAnimBtn.BackgroundColor3 = Color3.fromRGB(22, 160, 133)
	end
	newAnimate.Parent = char
end

local function onCharacterAdded(char)
	local original = char:WaitForChild("Animate", 10)
	if original and not savedAnimateScript then
		original.Archivable = true
		savedAnimateScript = original:Clone()
	end
end

customAnimBtn.MouseButton1Click:Connect(function() switchAnimation("Wicked") end)
defaultAnimBtn.MouseButton1Click:Connect(function() switchAnimation("Default") end)

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then onCharacterAdded(player.Character) end

-- === 4. ФИЗИКА И ПЛАТФОРМЫ ===

local isAnchored = false
freezeBtn.MouseButton1Click:Connect(function()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root then
		isAnchored = not isAnchored
		root.Anchored = isAnchored
		freezeBtn.Text = isAnchored and "Разморозить" or "Заморозить"
		freezeBtn.BackgroundColor3 = isAnchored and Color3.fromRGB(231, 76, 60) or Color3.fromRGB(46, 204, 113)
	end
end)

local function spawnPlatform()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root then
		local p = Instance.new("Part")
		p.Name = "MyPlatform"
		p.Size = Vector3.new(10, 1, 10)
		p.Anchored = true
		p.Transparency = 0.5
		p.Color = Color3.fromRGB(128, 128, 128)
		p.Material = Enum.Material.SmoothPlastic
		p.Position = root.Position + Vector3.new(0, -3.5, 0)
		p.Parent = workspace
	end
end

platformBtn.MouseButton1Click:Connect(spawnPlatform)
UserInputService.InputBegan:Connect(function(input, g)
	if not g and input.KeyCode == Enum.KeyCode.LeftControl then spawnPlatform() end
end)

clearBtn.MouseButton1Click:Connect(function()
	for _, v in pairs(workspace:GetChildren()) do
		if v.Name == "MyPlatform" then v:Destroy() end
	end
end)
