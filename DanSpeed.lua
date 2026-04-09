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
local teleportTarget = nil
local teleportButton = nil
local teleportFrame = nil
local lastCheckedText = ""

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

-- Функция для поиска всех GUI элементов с текстом
local function findAllGUIText()
	local allTexts = {}
	local playerGui = speaker:FindFirstChild("PlayerGui")
	if not playerGui then return allTexts end
	
	-- Рекурсивный поиск всех GUI элементов
	local function searchGUI(parent, depth)
		if depth > 20 then return end -- Защита от бесконечной рекурсии
		
		for _, child in pairs(parent:GetChildren()) do
			-- Проверяем TextLabel
			if child:IsA("TextLabel") and child.Text and child.Text ~= "" then
				table.insert(allTexts, {element = child, text = child.Text, type = "TextLabel"})
			end
			-- Проверяем TextButton
			if child:IsA("TextButton") and child.Text and child.Text ~= "" then
				table.insert(allTexts, {element = child, text = child.Text, type = "TextButton"})
			end
			-- Проверяем TextBox
			if child:IsA("TextBox") and child.Text and child.Text ~= "" then
				table.insert(allTexts, {element = child, text = child.Text, type = "TextBox"})
			end
			-- Проверяем ScreenGui и Frame
			if child:IsA("ScreenGui") or child:IsA("Frame") or child:IsA("ScrollingFrame") then
				searchGUI(child, depth + 1)
			end
		end
	end
	
	searchGUI(playerGui, 0)
	return allTexts
end

-- Функция для извлечения имени игрока из текста
local function extractPlayerNameFromText(text)
	-- Ищем любые имена игроков в тексте
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= speaker then
			local playerName = player.Name
			local playerDisplayName = player.DisplayName
			
			-- Проверяем, содержится ли имя игрока в тексте
			if string.find(text, playerName) or string.find(text, playerDisplayName) then
				return playerName
			end
			
			-- Проверяем вариант с "Someone" и именем рядом
			if string.find(text:lower(), "someone") and (string.find(text, playerName) or string.find(text, playerDisplayName)) then
				return playerName
			end
		end
	end
	
	-- Если текст содержит "Someone" но нет точного имени, пробуем извлечь любое слово
	if string.find(text:lower(), "someone") then
		-- Ищем слова в кавычках или скобках
		local inQuotes = string.match(text, '"([^"]+)"')
		if inQuotes then
			for _, player in pairs(Players:GetPlayers()) do
				if player ~= speaker and (string.find(inQuotes, player.Name) or string.find(inQuotes, player.DisplayName)) then
					return player.Name
				end
			end
		end
		
		-- Ищем слова в скобках
		local inParens = string.match(text, '%(([^%)]+)%')
		if inParens then
			for _, player in pairs(Players:GetPlayers()) do
				if player ~= speaker and (string.find(inParens, player.Name) or string.find(inParens, player.DisplayName)) then
					return player.Name
				end
			end
		end
	end
	
	return nil
end

-- Функция для создания кнопки телепортации
local function createTeleportButton(targetPlayerName)
	-- Удаляем старую кнопку если есть
	if teleportFrame then
		teleportFrame:Destroy()
		teleportFrame = nil
		teleportButton = nil
	end
	
	-- Создаем фрейм для кнопки (поверх основного GUI)
	teleportFrame = Instance.new("Frame")
	teleportFrame.Name = "TeleportFrame"
	teleportFrame.Parent = main
	teleportFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	teleportFrame.Position = UDim2.new(0.02, 0, 0.45, 0)
	teleportFrame.Size = UDim2.new(0, 240, 0, 60)
	teleportFrame.BackgroundTransparency = 0.05
	teleportFrame.ZIndex = 10
	Instance.new("UICorner", teleportFrame).CornerRadius = UDim.new(0, 8)
	
	-- Текст с информацией
	local infoText = Instance.new("TextLabel")
	infoText.Parent = teleportFrame
	infoText.Text = "🔍 НАЙДЕН ИГРОК!"
	infoText.Size = UDim2.new(1, 0, 0, 20)
	infoText.Position = UDim2.new(0, 0, 0, 5)
	infoText.BackgroundTransparency = 1
	infoText.TextColor3 = Color3.fromRGB(0, 255, 0)
	infoText.Font = Enum.Font.GothamBold
	infoText.TextSize = 12
	
	-- Текст с именем игрока
	local targetText = Instance.new("TextLabel")
	targetText.Parent = teleportFrame
	targetText.Text = "Цель: " .. targetPlayerName
	targetText.Size = UDim2.new(1, 0, 0, 20)
	targetText.Position = UDim2.new(0, 0, 0, 25)
	targetText.BackgroundTransparency = 1
	targetText.TextColor3 = Color3.fromRGB(255, 255, 0)
	targetText.Font = Enum.Font.GothamBold
	targetText.TextSize = 11
	
	-- Кнопка телепортации
	teleportButton = Instance.new("TextButton")
	teleportButton.Name = "TeleportBtn"
	teleportButton.Parent = teleportFrame
	teleportButton.Text = "🚀 ТЕЛЕПОРТИРОВАТЬСЯ"
	teleportButton.Position = UDim2.new(0.05, 0, 0, 45)
	teleportButton.Size = UDim2.new(0.9, 0, 0, 0)
	teleportButton.Size = UDim2.new(0.9, 0, 0, 25)
	teleportButton.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
	teleportButton.Font = Enum.Font.GothamSemibold
	teleportButton.TextColor3 = Color3.new(1, 1, 1)
	teleportButton.TextSize = 12
	teleportButton.ZIndex = 11
	Instance.new("UICorner", teleportButton).CornerRadius = UDim.new(0, 6)
	
	-- Анимация появления
	teleportFrame.BackgroundTransparency = 0.5
	task.spawn(function()
		for i = 0.5, 0.05, -0.05 do
			teleportFrame.BackgroundTransparency = i
			task.wait(0.05)
		end
	end)
	
	-- Функция телепортации
	teleportButton.MouseButton1Click:Connect(function()
		local targetPlayer = Players:FindFirstChild(targetPlayerName)
		if targetPlayer and targetPlayer.Character then
			local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
			local playerRoot = speaker.Character and speaker.Character:FindFirstChild("HumanoidRootPart")
			
			if targetRoot and playerRoot then
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
				beam.Position = teleportCFrame.Position
				beam.Parent = workspace
				
				-- Эффект в точке прибытия
				local beam2 = Instance.new("Part")
				beam2.Size = Vector3.new(2, 2, 2)
				beam2.Anchored = true
				beam2.CanCollide = false
				beam2.Transparency = 0.3
				beam2.Color = Color3.fromRGB(255, 0, 255)
				beam2.Material = Enum.Material.Neon
				beam2.Position = playerRoot.Position
				beam2.Parent = workspace
				
				task.spawn(function()
					for i = 0.3, 1, 0.05 do
						beam.Transparency = i
						beam2.Transparency = i
						beam.Size = beam.Size + Vector3.new(0.5, 0.5, 0.5)
						beam2.Size = beam2.Size + Vector3.new(0.5, 0.5, 0.5)
						task.wait(0.05)
					end
					beam:Destroy()
					beam2:Destroy()
				end)
				
				-- Уведомление
				infoText.Text = "✅ Телепортация выполнена!"
				infoText.TextColor3 = Color3.fromRGB(0, 255, 0)
				targetText.Text = "Телепортирован к " .. targetPlayerName
				
				-- Удаляем кнопку через 2 секунды
				task.wait(2)
				if teleportFrame then
					teleportFrame:Destroy()
					teleportFrame = nil
					teleportButton = nil
				end
			end
		else
			-- Если игрок не найден или нет персонажа
			infoText.Text = "❌ Игрок не найден!"
			infoText.TextColor3 = Color3.fromRGB(255, 0, 0)
			targetText.Text = targetPlayerName .. " недоступен"
			teleportButton.Visible = false
			
			task.wait(2)
			if teleportFrame then
				teleportFrame:Destroy()
				teleportFrame = nil
				teleportButton = nil
			end
		end
	end)
end

-- Функция для проверки GUI каждую секунду
local function checkForSomeoneGUI()
	print("🔍 Начинаем поиск GUI с текстом...")
	
	while true do
		if main and main.Parent then
			local allGUITexts = findAllGUIText()
			
			local foundSomeone = false
			local foundPlayerName = nil
			local foundText = nil
			
			-- Проверяем все найденные тексты
			for _, guiInfo in pairs(allGUITexts) do
				local text = guiInfo.text
				
				-- Проверяем наличие слова "Someone" (регистронезависимо)
				if text and string.find(string.lower(text), "someone") then
					foundSomeone = true
					foundText = text
					print("🔍 Найден GUI с текстом: " .. text)
					
					-- Пытаемся извлечь имя игрока
					local playerName = extractPlayerNameFromText(text)
					if playerName then
						foundPlayerName = playerName
						print("🔍 Извлечено имя игрока: " .. playerName)
						break
					end
				end
			end
			
			-- Если нашли текст с "Someone" и имя игрока
			if foundSomeone and foundPlayerName then
				if not teleportFrame or (teleportFrame and not teleportFrame.Parent) then
					print("✅ Создаем кнопку телепортации для игрока: " .. foundPlayerName)
					createTeleportButton(foundPlayerName)
				end
			elseif foundSomeone and not foundPlayerName then
				-- Если нашли "Someone" но не смогли определить имя, показываем сообщение
				if not teleportFrame then
					print("⚠️ Найдено 'Someone' но не удалось определить имя игрока в тексте: " .. (foundText or "unknown"))
				end
			else
				-- Если GUI исчез, удаляем кнопку
				if teleportFrame then
					print("🔴 GUI с 'Someone' исчез, удаляем кнопку")
					teleportFrame:Destroy()
					teleportFrame = nil
					teleportButton = nil
				end
			end
		end
		task.wait(0.5) -- Проверяем каждые 0.5 секунды для быстрой реакции
	end
end

-- Функция для отслеживания новых GUI элементов
local function trackNewGUI()
	local playerGui = speaker:WaitForChild("PlayerGui")
	
	-- Отслеживаем появление новых объектов
	playerGui.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
			if descendant.Text and string.find(string.lower(descendant.Text), "someone") then
				print("🔔 Обнаружен новый GUI элемент с 'Someone'!")
				local playerName = extractPlayerNameFromText(descendant.Text)
				if playerName then
					task.wait(0.2) -- Небольшая задержка для стабильности
					createTeleportButton(playerName)
				end
			end
		end
	end)
end

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

print("✅ EliteX Lite — Улучшенная телепортация при появлении GUI с 'Someone'")
