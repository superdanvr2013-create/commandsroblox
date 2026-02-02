-- Настройки

-- Сервисы
local Players = game:GetService("Players") 
local UserInputService = game:GetService("UserInputService") 
local RunService = game:GetService("RunService") 

local speaker = Players.LocalPlayer 
local main = Instance.new("ScreenGui") 
local Frame = Instance.new("Frame") 
local title = Instance.new("TextLabel") 

-- Настройки
local speedLockActive = false 
local espActive = false 
local isAnchored = false 
local targetSpeed = 30 
local targetJump = 15

local speeds = 1 
local nowe = false 

-- ГЛАВНЫЙ ИНТЕРФЕЙС
main.Name = "EliteX_Final_V23" 
main.Parent = speaker:WaitForChild("PlayerGui")
main.ResetOnSpawn = false

Frame.Name = "MainFrame" 
Frame.Parent = main 
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30) 
Frame.Position = UDim2.new(0.05, 0, 0.05, 0) 
Frame.Size = UDim2.new(0, 280, 0, 620) -- Увеличена высота для новой кнопки
Frame.Active = true 
Frame.Draggable = true 
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8) 

title.Parent = Frame 
title.Text = "ELITEX V23 (GEN SCANNER)" 
title.Size = UDim2.new(1, 0, 0, 35) 
title.BackgroundColor3 = Color3.fromRGB(45, 45, 50) 
title.TextColor3 = Color3.fromRGB(0, 255, 127) 
title.Font = Enum.Font.GothamBold 
title.TextSize = 14 

local function createBtn(name, text, pos, size, color)
	local btn = Instance.new("TextButton", Frame)
	btn.Name = name
	btn.Text = text
	btn.Position = pos
	btn.Size = size 
	btn.BackgroundColor3 = color 
	btn.Font = Enum.Font.GothamSemibold 
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextSize = 10 
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4) 
	return btn
end

-------------------------------------------------------------------
-- КНОПКИ УПРАВЛЕНИЯ (С четким распределением позиций)
-------------------------------------------------------------------
-- 1. ESP (Y: 0.1)
local espBtn = createBtn("EspBtn", "ESP: OFF", UDim2.new(0.05, 0, 0.08, 0), UDim2.new(0.9, 0, 0, 35), Color3.fromRGB(80, 80, 80))

-- 2. Air Jump (Y: 0.18)
local jumpBtn = createBtn("JumpBtn", "AIR JUMP (L-CTRL)", UDim2.new(0.05, 0, 0.16, 0), UDim2.new(0.9, 0, 0, 35), Color3.fromRGB(0, 150, 255))

-- 3. Speed Lock (Y: 0.26)
local speedLockBtn = createBtn("SpeedBtn", "SPEED LOCK: OFF", UDim2.new(0.05, 0, 0.24, 0), UDim2.new(0.9, 0, 0, 35), Color3.fromRGB(120, 40, 200))

-- 4. Speed Input Container (Y: 0.34)
local speedContainer = Instance.new("Frame", Frame)
speedContainer.Name = "SpeedContainer"
speedContainer.Position = UDim2.new(0.05, 0, 0.32, 0)
speedContainer.Size = UDim2.new(0.9, 0, 0, 35)
speedContainer.BackgroundTransparency = 1

--local speedInputBtn = Instance.new("TextButton", speedContainer)
--speedInputBtn.Name = "SpeedInputBtn"
--speedInputBtn.Text = "SPEED: " .. targetSpeed
--speedInputBtn.Position = UDim2.new(0, 0, 0, 0)
--speedInputBtn.Size = UDim2.new(0.65, 0, 1, 0)
--speedInputBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
--speedInputBtn.Font = Enum.Font.GothamSemibold
--speedInputBtn.TextColor3 = Color3.new(1,1,1)
--speedInputBtn.TextSize = 10
--Instance.new("UICorner", speedInputBtn).CornerRadius = UDim.new(0, 4)

local speedTextBox = Instance.new("TextBox", speedContainer)
speedTextBox.Name = "SpeedTextBox"
speedTextBox.Position = UDim2.new(0.68, 0, 0, 0)
speedTextBox.Size = UDim2.new(0.3, -10, 1, 0)
speedTextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
speedTextBox.Text = tostring(targetSpeed)
speedTextBox.TextColor3 = Color3.new(1,1,1)
speedTextBox.PlaceholderText = "0-100"
speedTextBox.Font = Enum.Font.Gotham
speedTextBox.TextSize = 12
speedTextBox.TextXAlignment = Enum.TextXAlignment.Center
Instance.new("UICorner", speedTextBox).CornerRadius = UDim.new(0, 4)

local JumpTextBox = Instance.new("TextBox", speedContainer)
JumpTextBox.Name = "JumpTextBox"
JumpTextBox.Position = UDim2.new(0.2, 0, 0, 0)
JumpTextBox.Size = UDim2.new(0.3, -10, 1, 0)
JumpTextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
JumpTextBox.Text = tostring(targetJump)
JumpTextBox.TextColor3 = Color3.new(1,1,1)
JumpTextBox.PlaceholderText = "0-100"
JumpTextBox.Font = Enum.Font.Gotham
JumpTextBox.TextSize = 12
JumpTextBox.TextXAlignment = Enum.TextXAlignment.Center
Instance.new("UICorner", JumpTextBox).CornerRadius = UDim.new(0, 4)




-- 5. Fly Mode (Y: 0.42)
local flyBtn = createBtn("FlyToggle", "FLY MODE", UDim2.new(0.05, 0, 0.40, 0), UDim2.new(0.9, 0, 0, 35), Color3.fromRGB(200, 160, 0))

-- 6. ANCHORED (Y: 0.50)
local anchorBtn = createBtn("AnchorBtn", "ANCHORED: OFF", UDim2.new(0.05, 0, 0.48, 0), UDim2.new(0.9, 0, 0, 35), Color3.fromRGB(40, 40, 45))

-------------------------------------------------------------------
-- ЛОГИКА SPEED INPUT
-------------------------------------------------------------------
--speedInputBtn.MouseButton1Click:Connect(function()
--	speedTextBox:CaptureFocus()
--end)

speedTextBox.FocusLost:Connect(function(enterPressed)
	local input = tonumber(speedTextBox.Text)
	if input and input >= 0 and input <= 100 then
		targetSpeed = input
		--speedInputBtn.Text = "SPEED: " .. targetSpeed
		speedTextBox.Text = tostring(targetSpeed)
	else
		speedTextBox.Text = tostring(targetSpeed)
	end
end)


JumpTextBox.FocusLost:Connect(function(enterPressed)
	local input = tonumber(JumpTextBox.Text)
	if input and input >= 0 and input <= 100 then
		targetJump = input
		--speedInputBtn.Text = "SPEED: " .. targetSpeed
		JumpTextBox.Text = tostring(targetJump)
	else
		JumpTextBox.Text = tostring(targetJump)
	end
end)

-------------------------------------------------------------------
-- ЛОГИКА ANCHORED
-------------------------------------------------------------------
anchorBtn.MouseButton1Click:Connect(function()
	isAnchored = not isAnchored
	anchorBtn.Text = isAnchored and "ANCHORED: ON" or "ANCHORED: OFF"
	anchorBtn.BackgroundColor3 = isAnchored and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(40, 40, 45)

	local char = speaker.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then
		root.Anchored = isAnchored
	end
end)

-- Блок для вывода ТОП-3 Generation
local topBox = Instance.new("TextLabel", Frame) 
topBox.Size = UDim2.new(0.9, 0, 0, 100) 
topBox.Position = UDim2.new(0.05, 0, 0.8, 0) 
topBox.BackgroundColor3 = Color3.fromRGB(10, 10, 15) 
topBox.TextColor3 = Color3.fromRGB(255, 255, 255) 
topBox.TextSize = 12 
topBox.Font = Enum.Font.Code 
topBox.Text = "Searching for Gen..." 
topBox.TextWrapped = true
Instance.new("UICorner", topBox) 

-------------------------------------------------------------------
-- ЛОГИКА ПАРСИНГА И СОРТИРОВКИ
-------------------------------------------------------------------
local function getNumericValue(text)
	local valStr, suffix = text:match("([%d%.]+)([MB])") 
	if valStr and suffix then 
		local num = tonumber(valStr) 
		if suffix == "M" then return num * 1e6 end 
		if suffix == "B" then return num * 1e9 end 
	end 
	return 0 
end

local function getParentPath(obj)
	local path = ""
	local current = obj.Parent
	while current and current ~= workspace and current ~= game do
		path = (path == "" and current.Name or current.Name .. "." .. path)
		current = current.Parent
	end
	return path ~= "" and path or "Workspace"
end

task.spawn(function()
	while true do
		local found = {} 
		for _, v in pairs(workspace:GetDescendants()) do 
			if v.Name == "Generation" then 
				local success, text = pcall(function() return v.Text end) 
				if success and text then 
					local numeric = getNumericValue(text) 
					if numeric >= 10000000 then 
						table.insert(found, {original = text, value = numeric, path = getParentPath(v)}) 
					end
				end
			end
		end
		table.sort(found, function(a, b) return a.value > b.value end) 

		local resultText = "TOP 3 GENERATION:\\n"
		for i = 1, 3 do
			if found[i] then
				resultText = resultText .. i .. ". [" .. found[i].path .. "] " .. found[i].original .. "\\n"
			else 
				resultText = resultText .. i .. ". ---\\n" 
			end
		end
		topBox.Text = resultText 
		task.wait(3) 
	end
end)

-------------------------------------------------------------------
-- ФУНКЦИОНАЛ (ESP, JUMP, SPEED) - ИСПОЛЬЗУЕМ НОВУЮ ЛОГИКУ
-------------------------------------------------------------------
local function updateESP()
	for _, player in pairs(Players:GetPlayers()) do 
		if player ~= speaker and player.Character then 
			local char = player.Character 
			local oldHighlight = char:FindFirstChild("EliteX_ESP") 
			if espActive then
				if not oldHighlight then
					local highlight = Instance.new("Highlight")
					highlight.Name = "EliteX_ESP"
					highlight.FillColor = Color3.fromRGB(255, 0, 0)
					highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
					highlight.FillTransparency = 0.5
					highlight.Adornee = char 
					highlight.Parent = char 
				end
			else
				if oldHighlight then oldHighlight:Destroy() end
			end
		end 
	end 
end

espBtn.MouseButton1Click:Connect(function()
	espActive = not espActive
	espBtn.Text = espActive and "ESP: ON" or "ESP: OFF"
	espBtn.BackgroundColor3 = espActive and Color3.fromRGB(255, 80, 0) or Color3.fromRGB(80, 80, 80)
	updateESP()
end)

local function doAirJump()
	local char = speaker.Character 
	local root = char and char:FindFirstChild("HumanoidRootPart") 
	if root then 
		local part = Instance.new("Part", workspace) 
		part.Size = Vector3.new(8, 1, 8); part.Anchored = true; 
		part.Material = Enum.Material.ForceField; 
		part.Color = Color3.fromRGB(0, 255, 255); 
		part.Transparency = 0.5 
		part.CFrame = root.CFrame * CFrame.new(0, -3.5, 0) 
		task.spawn(function()
			for i = 1, 30 do
				part.Position = part.Position + Vector3.new(0, 0.6, 0)
				task.wait()
			end
			part:Destroy()
		end)
	end
end

jumpBtn.MouseButton1Click:Connect(doAirJump)
UserInputService.InputBegan:Connect(function(i, p) if not p and i.KeyCode == Enum.KeyCode.LeftControl then doAirJump() end end)

-- НОВАЯ ЛОГИКА SPEED LOCK С ИСПОЛЬЗОВАНИЕМ ПРЕДЛОЖЕННОГО КОДА
speedLockBtn.MouseButton1Click:Connect(function()
	speedLockActive = not speedLockActive
	speedLockBtn.Text = speedLockActive and "SPEED LOCK: ON" or "SPEED LOCK: OFF"
	speedLockBtn.BackgroundColor3 = speedLockActive and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(120, 40, 200)
end)

flyBtn.MouseButton1Click:Connect(function() nowe = not nowe end)

-- НОВАЯ СИСТЕМА SPEED С ИСПОЛЬЗОВАНИЕМ RenderStepped
RunService.RenderStepped:Connect(function()
	--if speedLockActive then
	for i, v in workspace:GetDescendants() do
		if v.ClassName ~= "Humanoid" then continue end
		local plr = Players:GetPlayerFromCharacter(v:FindFirstAncestorOfClass("Model"))
		if plr == nil then continue end
		if plr ~= speaker then continue end
		v.WalkSpeed = targetSpeed  -- Используем targetSpeed из TextBox (0-100)
		v.JumpHeight = targetJump
	end
	--end

	if espActive then updateESP() end
	if nowe and speaker.Character then 
		speaker.Character:TranslateBy(speaker.Character.Humanoid.MoveDirection * speeds)
	end

	-- Принудительное удержание Anchored, если включено
	if isAnchored and speaker.Character and speaker.Character:FindFirstChild("HumanoidRootPart") then
		if not speaker.Character.HumanoidRootPart.Anchored then
			speaker.Character.HumanoidRootPart.Anchored = true
		end
	end
end)

-- Закрытие
local closebutton = Instance.new("TextButton", Frame)
closebutton.Text = "X"
closebutton.Position = UDim2.new(0.9, 0, 0, 0)
closebutton.Size = UDim2.new(0, 25, 0, 25)
closebutton.BackgroundColor3 = Color3.new(0.8,0,0)
closebutton.TextColor3 = Color3.new(1,1,1) 
closebutton.MouseButton1Click:Connect(function() main:Destroy() end)

-- Настройки
local TARGET_DURATION = 0.3
local PATCH_INTERVAL = 0.5   -- Частота применения (0.5 сек)
local RESCAN_INTERVAL = 5.0  -- Частота обновления списка (5 сек)

-- Таблица-кэш
local cachedObjects = {}

-- Функция применения патча к объекту
local function patchObject(obj)
    if not obj or not obj.Parent then return false end

    -- 1. Стандартные ProximityPrompt
    if obj:IsA("ProximityPrompt") then
        if obj.HoldDuration ~= TARGET_DURATION then
            obj.HoldDuration = TARGET_DURATION
        end
    end

    -- 2. Атрибуты
    for name, value in pairs(obj:GetAttributes()) do
        local ln = name:lower()
        if ln:find("dur") or ln:find("hold") or ln:find("time") then
            if type(value) == "number" and value ~= TARGET_DURATION then
                obj:SetAttribute(name, TARGET_DURATION)
            end
        end
    end

    -- 3. Value-объекты
    if obj:IsA("NumberValue") or obj:IsA("IntValue") then
        local ln = obj.Name:lower()
        if ln:find("dur") or ln:find("hold") or ln:find("time") then
            if obj.Value ~= TARGET_DURATION then
                obj.Value = TARGET_DURATION
            end
        end
    end
    return true
end

-- Функция сканирования мира и наполнения таблицы
local function refreshCache()
    local newCache = {}
    local descendants = workspace:GetDescendants()
    
    for _, obj in pairs(descendants) do
        local ln = obj.Name:lower()
        if obj:IsA("ProximityPrompt") or ln:find("spawn") or ln:find("base") or ln:find("hold") then
            table.insert(newCache, obj)
        end
    end
    
    cachedObjects = newCache
    print("EliteX: Cache Refreshed. Total objects: " .. #cachedObjects)
end

-- Первый запуск сканирования
refreshCache()

-- Цикл 1: Быстрое обновление свойств (PATCH)
task.spawn(function()
    while true do
        for i = #cachedObjects, 1, -1 do
            local obj = cachedObjects[i]
            if not patchObject(obj) then
                table.remove(cachedObjects, i) -- Удаляем, если объект исчез из игры
            end
        end
        task.wait(PATCH_INTERVAL)
    end
end)

-- Цикл 2: Медленное обновление списка объектов (RESCAN)
task.spawn(function()
    while true do
        task.wait(RESCAN_INTERVAL)
        refreshCache()
    end
end)
