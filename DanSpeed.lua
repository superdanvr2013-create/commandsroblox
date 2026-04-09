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
local detachLowerTorsoActive = false
local animationsActive = true
local proximityBoostActive = false -- Настройка для увеличения радиуса ProximityPrompt

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

-- Переменные для отделенного LowerTorso
local detachedLowerTorso = nil
local savedWelds = {}
local savedProperties = {}
local gyro = nil
local velocityCtrl = nil
local originalHumanoidState = nil

-- Переменные для ProximityPrompt
local modifiedPrompts = {} -- Таблица для хранения оригинальных радиусов
local promptsFolder = nil -- Папка для отслеживания новых Prompt'ов

-- Функция для увеличения радиуса ProximityPrompt
local function boostProximityPrompt(prompt, multiplier)
	if not prompt or not prompt:IsA("ProximityPrompt") then return end
	
	-- Сохраняем оригинальный радиус если еще не сохранили
	if not modifiedPrompts[prompt] then
		modifiedPrompts[prompt] = {
			originalRadius = prompt.Radius,
			originalHoldDuration = prompt.HoldDuration
		}
		
		-- Увеличиваем радиус в 2 раза
		prompt.Radius = prompt.Radius * multiplier
		
		-- Опционально: уменьшаем время удержания для более быстрого взаимодействия
		prompt.HoldDuration = math.max(0.1, prompt.HoldDuration * 0.5)
		
		print($"✅ Увеличен радиус ProximityPrompt: {modifiedPrompts[prompt].originalRadius} -> {prompt.Radius}")
	end
end

-- Функция для восстановления оригинальных радиусов
local function restoreProximityPrompts()
	for prompt, data in pairs(modifiedPrompts) do
		if prompt and prompt.Parent then
			prompt.Radius = data.originalRadius
			prompt.HoldDuration = data.originalHoldDuration
		end
	end
	modifiedPrompts = {}
	print("✅ Все ProximityPrompt восстановлены до оригинальных значений")
end

-- Функция для поиска и обработки всех ProximityPrompt в workspace
local function scanAndBoostProximityPrompts(multiplier)
	local count = 0
	
	-- Функция для рекурсивного поиска
	local function scanDescendants(parent)
		for _, descendant in pairs(parent:GetChildren()) do
			if descendant:IsA("ProximityPrompt") then
				boostProximityPrompt(descendant, multiplier)
				count = count + 1
			else
				-- Рекурсивно ищем в дочерних объектах
				scanDescendants(descendant)
			end
		end
	end
	
	-- Сканируем workspace
	scanDescendants(workspace)
	
	-- Также сканируем Players (могут быть Prompt'ы в инвентаре)
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character then
			scanDescendants(player.Character)
		end
		if player.PlayerGui then
			scanDescendants(player.PlayerGui)
		end
	end
	
	if count > 0 then
		print($"✅ Обработано {count} ProximityPrompt, радиус увеличен в {multiplier} раз")
	else
		print("⚠️ ProximityPrompt не найдены в workspace")
	end
	
	return count
end

-- Функция для отслеживания новых ProximityPrompt
local function trackNewProximityPrompts()
	-- Создаем папку для отслеживания если её нет
	if not promptsFolder then
		promptsFolder = Instance.new("Folder")
		promptsFolder.Name = "ProximityTracker"
		promptsFolder.Parent = workspace
	end
	
	-- Отслеживаем добавление новых объектов в workspace
	local function onDescendantAdded(descendant)
		if proximityBoostActive then
			if descendant:IsA("ProximityPrompt") then
				task.wait(0.1) -- Небольшая задержка чтобы объект полностью загрузился
				boostProximityPrompt(descendant, 2)
			else
				-- Проверяем дочерние объекты у добавленного объекта
				task.wait(0.05)
				for _, child in pairs(descendant:GetChildren()) do
					if child:IsA("ProximityPrompt") then
						boostProximityPrompt(child, 2)
					end
				end
			end
		end
	end
	
	-- Подключаем событие для workspace
	workspace.DescendantAdded:Connect(onDescendantAdded)
	
	-- Также отслеживаем в Character игрока
	local function onCharacterAdded(character)
		if proximityBoostActive then
			character.DescendantAdded:Connect(onDescendantAdded)
			-- Сканируем персонажа сразу
			for _, child in pairs(character:GetDescendants()) do
				if child:IsA("ProximityPrompt") then
					boostProximityPrompt(child, 2)
				end
			end
		end
	end
	
	-- Подключаем для текущего персонажа
	if speaker.Character then
		speaker.Character.DescendantAdded:Connect(onDescendantAdded)
	end
	
	-- Подключаем для будущих персонажей
	speaker.CharacterAdded:Connect(function(character)
		task.wait(0.5)
		if proximityBoostActive then
			character.DescendantAdded:Connect(onDescendantAdded)
			-- Сканируем нового персонажа
			for _, child in pairs(character:GetDescendants()) do
				if child:IsA("ProximityPrompt") then
					boostProximityPrompt(child, 2)
				end
			end
		end
	end)
	
	print("✅ Настройка отслеживания новых ProximityPrompt завершена")
end

-- Функция для включения/выключения увеличения радиуса
local function toggleProximityBoost(enable)
	proximityBoostActive = enable
	
	if enable then
		-- Сканируем и увеличиваем все существующие Prompt'ы
		scanAndBoostProximityPrompts(2)
		-- Запускаем отслеживание новых
		trackNewProximityPrompts()
		print("✅ Режим увеличения радиуса ProximityPrompt ВКЛЮЧЕН")
	else
		-- Восстанавливаем оригинальные радиусы
		restoreProximityPrompts()
		print("❌ Режим увеличения радиуса ProximityPrompt ВЫКЛЮЧЕН")
	end
end

-- Функция для поиска ближайшего игрока
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

-- Функция для телепортации к ближайшему игроку
local function teleportToNearest()
	local targetPlayer = findNearestPlayer()
	
	if targetPlayer and targetPlayer.Character then
		local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
		local playerRoot = speaker.Character and speaker.Character:FindFirstChild("HumanoidRootPart")
		
		if targetRoot and playerRoot then
			local oldPos = playerRoot.Position
			local teleportCFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
			playerRoot.CFrame = teleportCFrame
			
			local beam = Instance.new("Part")
			beam.Size = Vector3.new(2, 2, 2)
			beam.Anchored = true
			beam.CanCollide = false
			beam.Transparency = 0.3
			beam.Color = Color3.fromRGB(0, 255, 255)
			beam.Material = Enum.Material.Neon
			beam.Position = oldPos
			beam.Parent = workspace
			
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

-- Функция для управления анимациями персонажа
local function toggleAnimations(enable)
	local char = speaker.Character
	if not char then return end
	
	local humanoid = char:FindFirstChild("Humanoid")
	if not humanoid then return end
	
	if enable then
		local animator = humanoid:FindFirstChild("Animator")
		if not animator then
			local newAnimator = Instance.new("Animator")
			newAnimator.Parent = humanoid
			
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			task.wait(0.1)
			humanoid:ChangeState(Enum.HumanoidStateType.Running)
			task.wait(0.05)
			
			humanoid.WalkSpeed = originalSpeed
			humanoid.JumpPower = originalJump
			
			print("✅ Анимации включены и перезагружены")
		end
	else
		local animator = humanoid:FindFirstChild("Animator")
		if animator then
			for _, track in pairs(animator:GetPlayingAnimationTracks()) do
				track:Stop()
			end
			animator:Destroy()
			print("❌ Анимации отключены")
		end
	end
end

-- Функция для отделения LowerTorso
local function detachLowerTorso()
	local char = speaker.Character
	if not char then 
		print("❌ Персонаж не найден!")
		return 
	end
	
	local lowerTorso = char:FindFirstChild("LowerTorso")
	if not lowerTorso then 
		print("❌ LowerTorso не найден!")
		return 
	end
	
	local humanoid = char:FindFirstChild("Humanoid")
	if humanoid then
		originalHumanoidState = humanoid:GetState()
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		task.wait(0.1)
	end
	
	-- Сохраняем все weld соединения
	savedWelds = {}
	for _, weld in pairs(lowerTorso:GetChildren()) do
		if weld:IsA("Weld") or weld:IsA("Motor6D") then
			table.insert(savedWelds, {
				weld = weld,
				part0 = weld.Part0,
				part1 = weld.Part1,
				c0 = weld.C0,
				c1 = weld.C1,
				parent = weld.Parent
			})
			weld:Destroy()
		end
	end
	
	-- Сохраняем свойства
	savedProperties = {
		Anchored = lowerTorso.Anchored,
		CanCollide = lowerTorso.CanCollide,
		CFrame = lowerTorso.CFrame,
		Velocity = lowerTorso.Velocity,
		RotVelocity = lowerTorso.RotVelocity
	}
	
	-- Отцепляем LowerTorso
	lowerTorso.Anchored = false
	lowerTorso.CanCollide = true
	
	-- Сбрасываем скорость
	lowerTorso.Velocity = Vector3.new()
	lowerTorso.RotVelocity = Vector3.new()
	
	detachedLowerTorso = lowerTorso
	
	-- Добавляем свечение
	local highlight = Instance.new("Highlight")
	highlight.Name = "DetachedHighlight"
	highlight.FillColor = Color3.fromRGB(0, 255, 255)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.3
	highlight.Adornee = detachedLowerTorso
	highlight.Parent = detachedLowerTorso
	
	-- Создаем BodyGyro для управления поворотом
	gyro = Instance.new("BodyGyro")
	gyro.MaxTorque = Vector3.new(400000, 400000, 400000)
	gyro.P = 2000
	gyro.D = 500
	gyro.Parent = detachedLowerTorso
	
	-- Создаем BodyVelocity для управления движением
	velocityCtrl = Instance.new("BodyVelocity")
	velocityCtrl.MaxForce = Vector3.new(400000, 400000, 400000)
	velocityCtrl.P = 2000
	velocityCtrl.Parent = detachedLowerTorso
	
	print("✅ LowerTorso отделен! Управляйте им с помощью WASD")
end

-- Функция для восстановления LowerTorso
local function reattachLowerTorso()
	if not detachedLowerTorso then 
		print("❌ Нет отделенной части для восстановления")
		return 
	end
	
	local char = speaker.Character
	if not char then 
		print("❌ Персонаж не найден!")
		return 
	end
	
	local lowerTorso = detachedLowerTorso
	local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
	local humanoid = char:FindFirstChild("Humanoid")
	
	if not humanoidRootPart then
		print("❌ HumanoidRootPart не найден!")
		return
	end
	
	-- Останавливаем движение отделенной части
	if velocityCtrl then
		velocityCtrl.Velocity = Vector3.new()
		velocityCtrl:Destroy()
		velocityCtrl = nil
	end
	
	if gyro then 
		gyro:Destroy()
		gyro = nil
	end
	
	-- Сбрасываем скорость и вращение отделенной части
	lowerTorso.Velocity = Vector3.new()
	lowerTorso.RotVelocity = Vector3.new()
	lowerTorso.AssemblyLinearVelocity = Vector3.new()
	lowerTorso.AssemblyAngularVelocity = Vector3.new()
	
	-- Удаляем свечение
	local highlight = lowerTorso:FindFirstChild("DetachedHighlight")
	if highlight then highlight:Destroy() end
	
	-- Очищаем все существующие соединения
	for _, weld in pairs(lowerTorso:GetChildren()) do
		if weld:IsA("Weld") or weld:IsA("Motor6D") then
			weld:Destroy()
		end
	end
	
	-- Создаем новое weld соединение
	local newWeld = Instance.new("Weld")
	newWeld.Part0 = humanoidRootPart
	newWeld.Part1 = lowerTorso
	newWeld.C0 = CFrame.new(0, -1.5, 0)
	newWeld.C1 = CFrame.new(0, 0, 0)
	newWeld.Parent = lowerTorso
	
	-- Возвращаем на правильную позицию
	lowerTorso.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -1.5, 0)
	
	-- Сбрасываем свойства
	lowerTorso.Anchored = false
	lowerTorso.CanCollide = true
	
	-- Полный сброс персонажа
	if humanoid then
		local animator = humanoid:FindFirstChild("Animator")
		if animator then
			for _, track in pairs(animator:GetPlayingAnimationTracks()) do
				track:Stop()
			end
		end
		
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		task.wait(0.1)
		humanoid:ChangeState(Enum.HumanoidStateType.Running)
		task.wait(0.05)
		
		humanoid.PlatformStand = false
		humanoid.AutoRotate = true
		humanoid.Sit = false
		humanoid.Jump = false
		humanoid.WalkSpeed = originalSpeed
		humanoid.JumpPower = originalJump
	end
	
	if humanoidRootPart then
		humanoidRootPart.Velocity = Vector3.new()
		humanoidRootPart.RotVelocity = Vector3.new()
		humanoidRootPart.AssemblyLinearVelocity = Vector3.new()
		humanoidRootPart.AssemblyAngularVelocity = Vector3.new()
	end
	
	task.wait(0.15)
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end
	
	detachedLowerTorso = nil
	savedWelds = {}
	savedProperties = {}
	originalHumanoidState = nil
	
	print("✅ LowerTorso восстановлен!")
end

-- Функция для обновления управления отделенной частью
local function updateDetachedControl()
	if not detachedLowerTorso or not detachLowerTorsoActive then return end
	
	local lowerTorso = detachedLowerTorso
	if not lowerTorso or not lowerTorso.Parent then return end
	
	local camera = workspace.CurrentCamera
	local cameraCFrame = camera.CFrame
	
	local moveDirection = Vector3.new()
	
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		moveDirection = moveDirection + cameraCFrame.LookVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		moveDirection = moveDirection - cameraCFrame.LookVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		moveDirection = moveDirection - cameraCFrame.RightVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		moveDirection = moveDirection + cameraCFrame.RightVector
	end
	
	if moveDirection.Magnitude > 0 then
		moveDirection = moveDirection.Unit
	end
	
	local speed = 50
	if velocityCtrl then
		velocityCtrl.Velocity = moveDirection * speed
	end
	
	if gyro and moveDirection.Magnitude > 0 then
		gyro.CFrame = CFrame.lookAt(lowerTorso.Position, lowerTorso.Position + moveDirection)
	elseif gyro then
		gyro.CFrame = cameraCFrame
	end
end

-- Функция для проверки, находится ли блок рядом с игроком
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

-- Функция для поиска GUI с "Someone"
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
	if teleportFrame then
		teleportFrame:Destroy()
		teleportFrame = nil
		teleportButton = nil
	end
	
	local nearestPlayer, distance = findNearestPlayer()
	local playerInfo = nearestPlayer and (nearestPlayer.Name .. " (" .. math.floor(distance) .. " стутней)") or "нет игроков рядом"
	
	teleportFrame = Instance.new("Frame")
	teleportFrame.Name = "TeleportFrame"
	teleportFrame.Parent = main
	teleportFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	teleportFrame.Position = UDim2.new(0.02, 0, 0.45, 0)
	teleportFrame.Size = UDim2.new(0, 240, 0, 85)
	teleportFrame.BackgroundTransparency = 0
	teleportFrame.ZIndex = 10
	teleportFrame.BorderSizePixel = 1
	teleportFrame.BorderColor3 = Color3.fromRGB(255, 100, 0)
	Instance.new("UICorner", teleportFrame).CornerRadius = UDim.new(0, 8)
	
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
	
	local hotkeyText = Instance.new("TextLabel")
	hotkeyText.Parent = teleportFrame
	hotkeyText.Text = "⌨️ Нажмите Z для быстрой телепортации"
	hotkeyText.Size = UDim2.new(1, 0, 0, 15)
	hotkeyText.Position = UDim2.new(0, 0, 0, 45)
	hotkeyText.BackgroundTransparency = 1
	hotkeyText.TextColor3 = Color3.fromRGB(200, 200, 200)
	hotkeyText.Font = Enum.Font.Gotham
	hotkeyText.TextSize = 11
	hotkeyText.TextStrokeTransparency = 0.3
	hotkeyText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	hotkeyText.ZIndex = 11
	
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
	
	teleportButton.MouseButton1Click:Connect(function()
		teleportToNearest()
	end)
end

-- Функция для проверки GUI
local function checkForSomeoneGUI()
	local wasSomeone = false
	
	while true do
		if main and main.Parent then
			local hasSomeone = hasSomeoneText()
			
			if hasSomeone and not wasSomeone then
				createTeleportButton()
				isSomeoneActive = true
				wasSomeone = true
			elseif not hasSomeone and wasSomeone then
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

-- Функция для отслеживания новых GUI
local function trackNewGUI()
	local playerGui = speaker:WaitForChild("PlayerGui")
	
	playerGui.DescendantAdded:Connect(function(descendant)
		if (descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox")) and descendant.Text then
			if string.find(string.lower(descendant.Text), "someone") then
				task.wait(0.2)
				if not teleportFrame then
					createTeleportButton()
					isSomeoneActive = true
				end
			end
		end
	end)
end

-- Обработчик клавиш
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	-- Клавиша Z для телепортации
	if input.KeyCode == Enum.KeyCode.Z then
		if isSomeoneActive and teleportFrame and teleportFrame.Parent then
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
			
			local success = teleportToNearest()
			
			if not success and teleportButton then
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
	
	-- Клавиша Q для отделения/прикрепления LowerTorso
	if input.KeyCode == Enum.KeyCode.Q then
		detachLowerTorsoActive = not detachLowerTorsoActive
		
		if detachLowerTorsoActive then
			if detachBtn then
				detachBtn.Text = "🦿 DETACH LOWER TORSO: ON (Q)"
				detachBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
			end
			detachLowerTorso()
		else
			if detachBtn then
				detachBtn.Text = "🦿 DETACH LOWER TORSO: OFF (Q)"
				detachBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
			end
			reattachLowerTorso()
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
Frame.Size = UDim2.new(0, 240, 0, 490) -- Увеличил высоту для новой кнопки
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
-- PROXIMITY PROMPT BOOST (НОВАЯ КНОПКА)
-------------------------------------------------------------------
local proximityBtn = createBtn("ProximityBtn", "📡 PROXIMITY BOOST: OFF", 90, Color3.fromRGB(200, 100, 0))

proximityBtn.MouseButton1Click:Connect(function()
	proximityBoostActive = not proximityBoostActive
	proximityBtn.Text = proximityBoostActive and "📡 PROXIMITY BOOST: ON" or "📡 PROXIMITY BOOST: OFF"
	proximityBtn.BackgroundColor3 = proximityBoostActive and Color3.fromRGB(255, 150, 0) or Color3.fromRGB(200, 100, 0)
	toggleProximityBoost(proximityBoostActive)
end)

-------------------------------------------------------------------
-- ANIMATIONS TOGGLE
-------------------------------------------------------------------
local animBtn = createBtn("AnimBtn", "🎭 АНИМАЦИИ: ON", 140, Color3.fromRGB(100, 100, 255))

animBtn.MouseButton1Click:Connect(function()
	animationsActive = not animationsActive
	animBtn.Text = animationsActive and "🎭 АНИМАЦИИ: ON" or "🎭 АНИМАЦИИ: OFF"
	animBtn.BackgroundColor3 = animationsActive and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
	toggleAnimations(animationsActive)
end)

-------------------------------------------------------------------
-- DETACH LOWER TORSO
-------------------------------------------------------------------
local detachBtn = createBtn("DetachBtn", "🦿 DETACH LOWER TORSO: OFF (Q)", 190, Color3.fromRGB(150, 0, 150))

detachBtn.MouseButton1Click:Connect(function()
	detachLowerTorsoActive = not detachLowerTorsoActive
	
	if detachLowerTorsoActive then
		detachBtn.Text = "🦿 DETACH LOWER TORSO: ON (Q)"
		detachBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
		detachLowerTorso()
	else
		detachBtn.Text = "🦿 DETACH LOWER TORSO: OFF (Q)"
		detachBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
		reattachLowerTorso()
	end
end)

-------------------------------------------------------------------
-- XRAY
-------------------------------------------------------------------
local xrayBtn = createBtn("XrayBtn", "XRAY: OFF", 240, Color3.fromRGB(0, 100, 200))

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
local espBtn = createBtn("EspBtn", "ESP: OFF", 290, Color3.fromRGB(80, 80, 80))
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
local levitationBtn = createBtn("LevitationBtn", "ЛЕВИТАЦИЯ: OFF", 340, Color3.fromRGB(120, 40, 200))

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
local anchorBtn = createBtn("AnchorBtn", "ANCHORED: OFF", 390, Color3.fromRGB(40, 40, 45))

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
local kickBtn = createBtn("KickBtn", "KICK", 440, Color3.fromRGB(255, 50, 50))

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
	
	if detachLowerTorsoActive then
		updateDetachedControl()
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
	if animationsActive then
		task.wait(0.3)
		toggleAnimations(true)
	else
		toggleAnimations(false)
	end
	if proximityBoostActive then
		task.wait(0.2)
		scanAndBoostProximityPrompts(2)
	end
	-- Если была активна функция отделения, отключаем её при респавне
	if detachLowerTorsoActive then
		detachLowerTorsoActive = false
		detachBtn.Text = "🦿 DETACH LOWER TORSO: OFF (Q)"
		detachBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
	end
end)

-- Запускаем проверку GUI
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
	if detachLowerTorsoActive then
		reattachLowerTorso()
	end
	if not animationsActive then
		toggleAnimations(true)
	end
	if proximityBoostActive then
		restoreProximityPrompts()
	end
	main:Destroy()
end)

print("✅ EliteX Lite — Добавлено: увеличение радиуса ProximityPrompt в 2 раза!")
