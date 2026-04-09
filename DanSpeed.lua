local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local speaker = Players.LocalPlayer
local main = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")

-- Настройки
local espActive = false
local levitatingCtrl = false
local levitatingToggle = false
local isAnchored = false
local boostActive = false
local xrayActive = false

-- Левитация через платформу
local levitatePart = nil
local levitateSpeed = 10

-- Оригинальные настройки персонажа
local originalSpeed = 16
local originalJump = 50

-- Xray переменные
local originalTransparencies = {}
local xrayParts = {}
local xrayRadius = 30

-- Переменные для телепортации
local teleportButton = nil
local teleportFrame = nil
local isSomeoneActive = false

-- Функция для поиска ближайшего игрока (ДОЛЖНА БЫТЬ ПЕРВОЙ)
local function findNearestPlayer()
	local char = speaker.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return nil end
	
	local closestPlayer = nil
	local closestDistance = math.huge
	
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= speaker then
			local playerChar = player.Character
			local playerRoot = playerChar and playerChar:FindFirstChild("HumanoidRootPart")
			local humanoid = playerChar and playerChar:FindFirstChild("Humanoid")
			
			if playerRoot and humanoid and humanoid.Health > 0 then
				local distance = (playerRoot.Position - root.Position).Magnitude
				if distance < closestDistance then
					closestDistance = distance
					closestPlayer = player
				end
			end
		end
	end
	
	return closestPlayer, closestDistance
end

-- Функция для телепортации к ближайшему игроку (ДОЛЖНА БЫТЬ ПОСЛЕ findNearestPlayer)
local function teleportToNearest()
	local targetPlayer = findNearestPlayer()
	
	if targetPlayer and targetPlayer.Character then
		local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
		local playerRoot = speaker.Character and speaker.Character:FindFirstChild("HumanoidRootPart")
		
		if targetRoot and playerRoot then
			-- Визуальный эффект перед телепортацией
			local oldPos = playerRoot.Position
			
			-- Телепортируем игрока
			local teleportCFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
			playerRoot.CFrame = teleportCFrame
			
			-- Визуальный эффект в точке телепортации
			local beam = Instance.new("Part")
			beam.Size = Vector3.new(2, 2, 2)
			beam.Anchored = true
			beam.CanCollide = false
			beam.Transparency = 0.3
			beam.Color = Color3.fromRGB(0, 255, 255)
			beam.Material = Enum.Material.Neon
			beam.Position = oldPos
			beam.Parent = workspace
			
			-- Эффект в точке прибытия
			local beam2 = Instance.new("Part")
			beam2.Size = Vector3.new(2, 2, 2)
			beam2.Anchored = true
			beam2.CanCollide = false
			beam2.Transparency = 0.3
			beam2.Color = Color3.fromRGB(255, 0, 255)
			beam2.Material = Enum.Material.Neon
			beam2.Position = teleportCFrame.Position
			beam2.Parent = workspace
			
			task.spawn(function()
				for i = 0.3, 1, 0.05 do
					if beam and beam2 then
						beam.Transparency = i
						beam2.Transparency = i
						beam.Size = beam.Size + Vector3.new(0.5, 0.5, 0.5)
						beam2.Size = beam2.Size + Vector3.new(0.5, 0.5, 0.5)
					end
					task.wait(0.05)
				end
				if beam then beam:Destroy() end
				if beam2 then beam2:Destroy() end
			end)
			
			-- Визуальное уведомление на кнопке
			if teleportButton then
				local originalText = teleportButton.Text
				teleportButton.Text = "✅ ТЕЛЕПОРТИРОВАНО!"
				task.wait(0.3)
				if teleportButton then
					teleportButton.Text = originalText
				end
			end
			
			return true
		end
	end
	return false
end

-- Функция для проверки, находится ли блок рядом с игроком (но не под ногами)
local function isNearPlayerButNotUnder(part)
	local char = speaker.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return false end
	
	local partPos = part.Position
	local playerPos = root.Position
	local distance = (partPos - playerPos).Magnitude
	local distanceY = playerPos.Y - partPos.Y
	
	local isUnderFeet = distanceY > 0 and distanceY < 5 and math.abs(partPos.X - playerPos.X) < 5 and math.abs(partPos.Z - playerPos.Z) < 5
	
	return distance <= xrayRadius and not isUnderFeet
end

-- Функция для Xray
local function applyXray()
	if xrayActive then
		for part, transparency in pairs(originalTransparencies) do
			if part and part.Parent then
				part.Transparency = transparency
			end
		end
		table.clear(originalTransparencies)
		table.clear(xrayParts)
		
		for _, part in pairs(workspace:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "LevitatePart" then
				local isNear = isNearPlayerButNotUnder(part)
				
				if isNear then
					if not originalTransparencies[part] then
						originalTransparencies[part] = part.Transparency
					end
					part.Transparency = 0.95
					table.insert(xrayParts, part)
				end
			end
		end
	else
		for part, transparency in pairs(originalTransparencies) do
			if part and part.Parent then
				part.Transparency = transparency
			end
		end
		table.clear(originalTransparencies)
		table.clear(xrayParts)
	end
end

-- Функция для обновления Xray
local function updateXray()
	if not xrayActive then return end
	
	local char = speaker.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	for _, part in pairs(workspace:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "LevitatePart" then
			local distance = (part.Position - root.Position).Magnitude
			local isUnderFeet = false
			
			local distanceY = root.Position.Y - part.Position.Y
			if distanceY > 0 and distanceY < 5 and math.abs(part.Position.X - root.Position.X) < 5 and math.abs(part.Position.Z - root.Position.Z) < 5 then
				isUnderFeet = true
			end
			
			if distance <= xrayRadius and not isUnderFeet then
				if not originalTransparencies[part] then
					originalTransparencies[part] = part.Transparency
					part.Transparency = 0.95
					table.insert(xrayParts, part)
				end
			elseif originalTransparencies[part] then
				part.Transparency = originalTransparencies[part]
				originalTransparencies[part] = nil
				for i, p in pairs(xrayParts) do
					if p == part then
						table.remove(xrayParts, i)
						break
					end
				end
			end
		end
	end
end

-- Функция для поиска всех GUI элементов с текстом "Someone"
local function hasSomeoneText()
	local playerGui = speaker:FindFirstChild("PlayerGui")
	if not playerGui then return false end
	
	local function searchGUI(parent)
		for _, child in pairs(parent:GetChildren()) do
			if (child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox")) and child.Text then
				if string.find(string.lower(child.Text), "someone") then
					return true
				end
			end
			if child:IsA("ScreenGui") or child:IsA("Frame") or child:IsA("ScrollingFrame") then
				if searchGUI(child) then
					return true
				end
			end
		end
		return false
	end
	
	return searchGUI(playerGui)
end

-- Функция для обновления информации о ближайшем игроке
local function updateTeleportInfo()
	if teleportFrame and teleportFrame.Parent then
		local nearestPlayer, distance = findNearestPlayer()
		local labels = {}
		
		for _, child in pairs(teleportFrame:GetChildren()) do
			if child:IsA("TextLabel") then
				table.insert(labels, child)
			end
		end
		
		if labels[2] then
			if nearestPlayer then
				labels[2].Text = "🎯 Ближайший: " .. nearestPlayer.Name .. " (" .. math.floor(distance) .. " стутней)"
				labels[2].TextColor3 = Color3.fromRGB(0, 255, 0)
			else
				labels[2].Text = "🎯 Ближайший: нет игроков рядом"
				labels[2].TextColor3 = Color3.fromRGB(255, 0, 0)
			end
		end
	end
end

-- Функция для создания кнопки телепортации
local function createTeleportButton()
	-- Удаляем старую кнопку если есть
	if teleportFrame then
		teleportFrame:Destroy()
		teleportFrame = nil
		teleportButton = nil
	end
	
	-- Находим ближайшего игрока для отображения
	local nearestPlayer, distance = findNearestPlayer()
	local playerInfo = "Неизвестно"
	
	if nearestPlayer then
		playerInfo = nearestPlayer.Name .. " (" .. math.floor(distance) .. " стутней)"
	else
		playerInfo = "нет игроков рядом"
	end
	
	-- Создаем фрейм для кнопки (делаем его полностью непрозрачным)
	teleportFrame = Instance.new("Frame")
	teleportFrame.Name = "TeleportFrame"
	teleportFrame.Parent = main
	teleportFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	teleportFrame.Position = UDim2.new(0.02, 0, 0.45, 0)
	teleportFrame.Size = UDim2.new(0, 240, 0, 85)
	teleportFrame.BackgroundTransparency = 0 -- Полностью непрозрачный
	teleportFrame.ZIndex = 10
	teleportFrame.BorderSizePixel = 1
	teleportFrame.BorderColor3 = Color3.fromRGB(255, 100, 0)
	Instance.new("UICorner", teleportFrame).CornerRadius = UDim.new(0, 8)
	
	-- Тень для фрейма
	local shadow = Instance.new("Frame")
	shadow.Name = "Shadow"
	shadow.Parent = teleportFrame
	shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shadow.BackgroundTransparency = 0.5
	shadow.Position = UDim2.new(0, 2, 0, 2)
	shadow.Size = UDim2.new(1, 0, 1, 0)
	shadow.ZIndex = 9
	shadow.BorderSizePixel = 0
	Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 8)
	
	-- Текст с информацией (делаем ярким и видимым)
	local infoText = Instance.new("TextLabel")
	infoText.Parent = teleportFrame
	infoText.Text = "⚠️ ОБНАРУЖЕНО 'SOMEONE'!"
	infoText.Size = UDim2.new(1, 0, 0, 20)
	infoText.Position = UDim2.new(0, 0, 0, 5)
	infoText.BackgroundTransparency = 1
	infoText.TextColor3 = Color3.fromRGB(255, 100, 0)
	infoText.Font = Enum.Font.GothamBold
	infoText.TextSize = 14
	infoText.TextStrokeTransparency = 0.5
	infoText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	infoText.ZIndex = 11
	
	-- Текст с информацией о ближайшем игроке
	local targetText = Instance.new("TextLabel")
	targetText.Parent = teleportFrame
	targetText.Text = "🎯 Ближайший: " .. playerInfo
	targetText.Size = UDim2.new(1, 0, 0, 20)
	targetText.Position = UDim2.new(0, 0, 0, 25)
	targetText.BackgroundTransparency = 1
	targetText.TextColor3 = Color3.fromRGB(255, 255, 255)
	targetText.Font = Enum.Font.GothamSemibold
	targetText.TextSize = 12
	targetText.TextStrokeTransparency = 0.5
	targetText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	targetText.ZIndex = 11
	
	-- Подсказка по хоткею
	local hotkeyText = Instance.new("TextLabel")
	hotkeyText.Parent = teleportFrame
	hotkeyText.Text = "⌨️ Нажмите Q для быстрой телепортации"
	hotkeyText.Size = UDim2.new(1, 0, 0, 15)
	hotkeyText.Position = UDim2.new(0, 0, 0, 45)
	hotkeyText.BackgroundTransparency = 1
	hotkeyText.TextColor3 = Color3.fromRGB(200, 200, 200)
	hotkeyText.Font = Enum.Font.Gotham
	hotkeyText.TextSize = 11
	hotkeyText.TextStrokeTransparency = 0.3
	hotkeyText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	hotkeyText.ZIndex = 11
	
	-- Кнопка телепортации
	teleportButton = Instance.new("TextButton")
	teleportButton.Name = "TeleportBtn"
	teleportButton.Parent = teleportFrame
	teleportButton.Text = "🚀 ТЕЛЕПОРТИРОВАТЬСЯ"
	teleportButton.Position = UDim2.new(0.05, 0, 0, 60)
	teleportButton.Size = UDim2.new(0.9, 0, 0, 20)
	teleportButton.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
	teleportButton.Font = Enum.Font.GothamSemibold
	teleportButton.TextColor3 = Color3.new(1, 1, 1)
	teleportButton.TextSize = 12
	teleportButton.ZIndex = 11
	teleportButton.BorderSizePixel = 0
	Instance.new("UICorner", teleportButton).CornerRadius = UDim.new(0, 6)
	
	-- Анимация появления
	teleportFrame.BackgroundTransparency = 0.5
	task.spawn(function()
		for i = 0.5, 0, -0.05 do
			if teleportFrame then
				teleportFrame.BackgroundTransparency = i
				task.wait(0.05)
			end
		end
	end)
	
	-- Функция телепортации по кнопке
	teleportButton.MouseButton1Click:Connect(function()
		teleportToNearest()
	end)
end

-- Функция для проверки GUI каждую секунду
local function checkForSomeoneGUI()
	print("🔍 Начинаем поиск GUI с текстом 'Someone'...")
	local wasSomeone = false
	
	while true do
		if main and main.Parent then
			local hasSomeone = hasSomeoneText()
			
			if hasSomeone and not wasSomeone then
				print("✅ Обнаружен GUI с текстом 'Someone'! Создаем кнопку телепортации...")
				createTeleportButton()
				isSomeoneActive = true
				wasSomeone = true
			elseif not hasSomeone and wasSomeone then
				print("🔴 GUI с 'Someone' исчез, удаляем кнопку")
				if teleportFrame then
					teleportFrame:Destroy()
					teleportFrame = nil
					teleportButton = nil
				end
				isSomeoneActive = false
				wasSomeone = false
			end
		end
		task.wait(0.5)
	end
end

-- Функция для обновления информации о ближайшем игроке
local function updateNearestPlayerInfo()
	while true do
		if teleportFrame and teleportFrame.Parent then
			updateTeleportInfo()
		end
		task.wait(0.5)
	end
end

-- Функция для отслеживания новых GUI элементов
local function trackNewGUI()
	local playerGui = speaker:WaitForChild("PlayerGui")
	
	playerGui.DescendantAdded:Connect(function(descendant)
		if (descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox")) and descendant.Text then
			if string.find(string.lower(descendant.Text), "someone") then
				print("🔔 Обнаружен новый GUI элемент с 'Someone'!")
				task.wait(0.2)
				if not teleportFrame then
					createTeleportButton()
					isSomeoneActive = true
				end
			end
		end
	end)
end

-- Обработчик нажатия клавиши Q (без защиты от спама)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	-- Проверяем нажатие клавиши Q
	if input.KeyCode == Enum.KeyCode.Q then
		-- Если активен режим Someone и есть кнопка
		if isSomeoneActive and teleportFrame and teleportFrame.Parent then
			-- Эффект нажатия на кнопку
			if teleportButton then
				local originalColor = teleportButton.BackgroundColor3
				teleportButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
				task.spawn(function()
					task.wait(0.1)
					if teleportButton then
						teleportButton.BackgroundColor3 = originalColor
					end
				end)
			end
			
			-- Телепортируемся без задержки
			local success = teleportToNearest()
			
			if success then
				print("✅ Телепортация по клавише Q выполнена!")
			else
				print("❌ Не удалось найти игрока для телепортации")
				-- Визуальное уведомление об ошибке
				if teleportButton then
					local originalText = teleportButton.Text
					teleportButton.Text = "❌ НЕТ ИГРОКОВ!"
					task.spawn(function()
						task.wait(0.5)
						if teleportButton then
							teleportButton.Text = originalText
						end
					end)
				end
			end
		end
	end
end)

local function createLevitatePart()
	if levitatePart then
		levitatePart:Destroy()
		levitatePart = nil
	end

	local char = speaker.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	levitatePart = Instance.new("Part")
	levitatePart.Name = "LevitatePart"
	levitatePart.Size = Vector3.new(6, 0.5, 6)
	levitatePart.Anchored = true
	levitatePart.CanCollide = true
	levitatePart.Transparency = 0.95
	levitatePart.Material = Enum.Material.SmoothPlastic
	levitatePart.Color = Color3.fromRGB(0, 0, 0)
	levitatePart.CFrame = root.CFrame * CFrame.new(0, -1.5, 0)
	levitatePart.Parent = workspace

	task.spawn(function()
		while levitatePart and (levitatingCtrl or levitatingToggle) do
			local char = speaker.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root then
				local targetCFrame = root.CFrame * CFrame.new(0, -1.5, 0)
				levitatePart.CFrame = targetCFrame
				levitatePart.Velocity = Vector3.new(0, levitateSpeed, 0)
			else
				break
			end
			task.wait(0.05)
		end
		if levitatePart then
			levitatePart:Destroy()
			levitatePart = nil
		end
	end)
end

local function stopLevitation()
	levitatingCtrl = false
	levitatingToggle = false
	if levitatePart then
		levitatePart:Destroy()
		levitatePart = nil
	end
end

-- Функция для применения буста
local function applyBoost()
	local char = speaker.Character
	local hum = char and char:FindFirstChild("Humanoid")
	if hum then
		if boostActive then
			hum.WalkSpeed = 30
			hum.JumpPower = 10
		else
			hum.WalkSpeed = originalSpeed
			hum.JumpPower = originalJump
		end
	end
end

-- Сохраняем оригинальные настройки при появлении персонажа
local function saveOriginalSettings()
	local char = speaker.Character
	local hum = char and char:FindFirstChild("Humanoid")
	if hum then
		originalSpeed = hum.WalkSpeed
		originalJump = hum.JumpPower
	end
end

-------------------------------------------------------------------
-- GUI
-------------------------------------------------------------------
main.Name = "EliteX_Fly"
main.Parent = speaker:WaitForChild("PlayerGui")
main.ResetOnSpawn = false

Frame.Name = "MainFrame"
Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.Position = UDim2.new(0.02, 0, 0.02, 0)
Frame.Size = UDim2.new(0, 240, 0, 350)
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Parent = Frame
title.Text = "ELITEX — Lite"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
title.TextColor3 = Color3.fromRGB(0, 255, 127)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

local function createBtn(name, text, y, color)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Text = text
	btn.Position = UDim2.new(0.05, 0, 0, y)
	btn.Size = UDim2.new(0.9, 0, 0, 30)
	btn.BackgroundColor3 = color
	btn.Font = Enum.Font.GothamSemibold
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextSize = 12
	btn.Parent = Frame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	return btn
end

-------------------------------------------------------------------
-- SPEED AND JUMP BOOST
-------------------------------------------------------------------
local boostBtn = createBtn("BoostBtn", "SPEED & JUMP BOOST: OFF", 40, Color3.fromRGB(0, 150, 0))

boostBtn.MouseButton1Click:Connect(function()
	boostActive = not boostActive
	boostBtn.Text = boostActive and "SPEED & JUMP BOOST: ON" or "SPEED & JUMP BOOST: OFF"
	boostBtn.BackgroundColor3 = boostActive and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(0, 150, 0)
	applyBoost()
end)

-------------------------------------------------------------------
-- XRAY
-------------------------------------------------------------------
local xrayBtn = createBtn("XrayBtn", "XRAY: OFF", 90, Color3.fromRGB(0, 100, 200))

xrayBtn.MouseButton1Click:Connect(function()
	xrayActive = not xrayActive
	xrayBtn.Text = xrayActive and "XRAY: ON" or "XRAY: OFF"
	xrayBtn.BackgroundColor3 = xrayActive and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(0, 100, 200)
	
	if xrayActive then
		applyXray()
	else
		applyXray()
	end
end)

-------------------------------------------------------------------
-- ESP
-------------------------------------------------------------------
local espBtn = createBtn("EspBtn", "ESP: OFF", 140, Color3.fromRGB(80, 80, 80))
local ESPParts = {}

local function updateESP()
	for _, part in pairs(ESPParts) do
		if part and part.Parent then
			part:Destroy()
		end
	end
	table.clear(ESPParts)

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= speaker and player.Character then
			local char = player.Character
			local highlight = Instance.new("Highlight")
			highlight.Name = "EliteX_ESP"
			highlight.FillColor = Color3.fromRGB(255, 100, 0)
			highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			highlight.FillTransparency = 0.4
			highlight.Adornee = char
			highlight.Parent = char
			table.insert(ESPParts, highlight)
		end
	end
end

espBtn.MouseButton1Click:Connect(function()
	espActive = not espActive
	espBtn.Text = espActive and "ESP: ON" or "ESP: OFF"
	espBtn.BackgroundColor3 = espActive and Color3.fromRGB(255, 80, 0) or Color3.fromRGB(80, 80, 80)

	if espActive then
		updateESP()
	else
		for _, part in pairs(ESPParts) do
			if part and part.Parent then
				part:Destroy()
			end
		end
		table.clear(ESPParts)
	end
end)

Players.PlayerAdded:Connect(function()
	if espActive then updateESP() end
end)

Players.PlayerRemoving:Connect(function()
	if espActive then updateESP() end
end)

-------------------------------------------------------------------
-- ЛЕВИТАЦИЯ
-------------------------------------------------------------------
local levitationBtn = createBtn("LevitationBtn", "ЛЕВИТАЦИЯ: OFF", 190, Color3.fromRGB(120, 40, 200))

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.LeftControl then
		levitatingCtrl = true
		if not levitatePart then
			createLevitatePart()
		end
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.LeftControl then
		levitatingCtrl = false
		if not levitatingToggle and levitatePart then
			levitatePart:Destroy()
			levitatePart = nil
		end
	end
end)

levitationBtn.MouseButton1Click:Connect(function()
	levitatingToggle = not levitatingToggle
	levitationBtn.Text = levitatingToggle and "ЛЕВИТАЦИЯ: ON" or "ЛЕВИТАЦИЯ: OFF"
	levitationBtn.BackgroundColor3 = levitatingToggle and Color3.fromRGB(255, 150, 0) or Color3.fromRGB(120, 40, 200)

	if levitatingToggle or levitatingCtrl then
		if not levitatePart then
			createLevitatePart()
		end
	else
		stopLevitation()
	end
end)

-------------------------------------------------------------------
-- ANCHORED
-------------------------------------------------------------------
local anchorBtn = createBtn("AnchorBtn", "ANCHORED: OFF", 240, Color3.fromRGB(40, 40, 45))

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

-------------------------------------------------------------------
-- KICK
-------------------------------------------------------------------
local kickBtn = createBtn("KickBtn", "KICK", 290, Color3.fromRGB(255, 50, 50))

kickBtn.MouseButton1Click:Connect(function()
	game:Shutdown()
end)

-------------------------------------------------------------------
-- LOOP
-------------------------------------------------------------------
RunService.Stepped:Connect(function()
	local char = speaker.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChild("Humanoid")
	
	if root then
		if isAnchored then
			root.Anchored = true
		end
	end
	
	if hum and boostActive then
		if hum.WalkSpeed ~= 30 then
			hum.WalkSpeed = 30
		end
		if hum.JumpPower ~= 10 then
			hum.JumpPower = 10
		end
	end
	
	if xrayActive then
		updateXray()
	end
end)

-- Обработка появления персонажа
speaker.CharacterAdded:Connect(function(character)
	wait(0.5)
	saveOriginalSettings()
	if boostActive then
		applyBoost()
	end
	if xrayActive then
		applyXray()
	end
end)

-- Запускаем проверку GUI для телепортации
task.spawn(checkForSomeoneGUI)
task.spawn(trackNewGUI)
task.spawn(updateNearestPlayerInfo)

-- При первом запуске сохраняем настройки
if speaker.Character then
	saveOriginalSettings()
end

-------------------------------------------------------------------
-- ЗАКРЫТИЕ
-------------------------------------------------------------------
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "❌"
closeBtn.Position = UDim2.new(0.92, 0, 0, 5)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = Frame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function()
	stopLevitation()
	if xrayActive then
		xrayActive = false
		applyXray()
	end
	main:Destroy()
end)

print("✅ EliteX Lite — Исправлена ошибка teleportToNearest, всё работает!")
