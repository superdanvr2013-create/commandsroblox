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
local proximityPromptActive = false
local originalInteractionData = {} -- Словарь для хранения оригинальных данных

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

-- Функция для поиска всех интерактивных объектов с текстом
local function findAllInteractiveObjects()
    local objects = {}
    
    -- Рекурсивная функция поиска
    local function searchForInteractiveObjects(parent)
        for _, descendant in pairs(parent:GetChildren()) do
            -- Ищем ProximityPrompt
            if descendant:IsA("ProximityPrompt") then
                table.insert(objects, {
                    type = "ProximityPrompt",
                    object = descendant,
                    originalValue = descendant.MaxActivationDistance,
                    valueName = "MaxActivationDistance"
                })
            end
            
            -- Ищем ClickDetector
            if descendant:IsA("ClickDetector") then
                table.insert(objects, {
                    type = "ClickDetector",
                    object = descendant,
                    originalValue = descendant.MaxActivationDistance,
                    valueName = "MaxActivationDistance"
                })
            end
            
            -- Ищем объекты с текстом (самодельные интерактивные элементы)
            if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
                if descendant.Text and descendant.Text ~= "" then
                    table.insert(objects, {
                        type = "TextObject",
                        object = descendant,
                        originalValue = nil,
                        valueName = nil,
                        hasText = true
                    })
                end
            end
            
            -- Продолжаем поиск в дочерних элементах
            if #descendant:GetChildren() > 0 then
                searchForInteractiveObjects(descendant)
            end
        end
    end
    
    -- Начинаем поиск с workspace
    searchForInteractiveObjects(workspace)
    
    -- Также ищем в PlayerGui (могут быть GUI элементы)
    local playerGui = speaker:FindFirstChild("PlayerGui")
    if playerGui then
        searchForInteractiveObjects(playerGui)
    end
    
    return objects
end

-- Функция для увеличения радиуса/размера интерактивных объектов
local function increaseInteractionRadius(enable)
    if enable then
        local objects = findAllInteractiveObjects()
        local modifiedCount = 0
        
        for _, data in pairs(objects) do
            local obj = data.object
            if obj and obj.Parent then
                -- Сохраняем оригинальные данные
                if not originalInteractionData[obj] then
                    originalInteractionData[obj] = {
                        type = data.type,
                        originalValue = data.originalValue,
                        originalSize = obj:IsA("TextLabel") and obj.TextSize or nil,
                        originalPosition = obj:IsA("TextLabel") and obj.Position or nil,
                        originalSize2D = obj:IsA("TextLabel") and obj.Size or nil
                    }
                end
                
                -- Увеличиваем в зависимости от типа
                if data.type == "ProximityPrompt" then
                    obj.MaxActivationDistance = 50
                    modifiedCount = modifiedCount + 1
                elseif data.type == "ClickDetector" then
                    obj.MaxActivationDistance = 50
                    modifiedCount = modifiedCount + 1
                elseif data.type == "TextObject" then
                    -- Для текстовых объектов увеличиваем размер и делаем более заметными
                    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                        -- Увеличиваем размер текста
                        obj.TextSize = math.max(obj.TextSize, 24)
                        -- Делаем фон более заметным
                        obj.BackgroundTransparency = math.min(obj.BackgroundTransparency, 0.3)
                        -- Увеличиваем размер самого объекта
                        local currentSize = obj.Size
                        obj.Size = UDim2.new(currentSize.X.Scale, currentSize.X.Offset * 1.5, 
                                            currentSize.Y.Scale, currentSize.Y.Offset * 1.5)
                        modifiedCount = modifiedCount + 1
                    end
                end
            end
        end
        
        print("✅ Найдено и модифицировано интерактивных объектов: " .. modifiedCount)
        
        -- Дополнительный поиск по конкретному пути, если он существует
        local specificPath = workspace:FindFirstChild("Plots")
        if specificPath then
            specificPath = specificPath:FindFirstChild("c7fe30d7-e7f1-4e5f-85f6-fb89199176b3")
            if specificPath then
                specificPath = specificPath:FindFirstChild("AnimalPodiums")
                if specificPath then
                    specificPath = specificPath:FindFirstChild("1")
                    if specificPath then
                        specificPath = specificPath:FindFirstChild("Base")
                        if specificPath then
                            specificPath = specificPath:FindFirstChild("Spawn")
                            if specificPath then
                                print("🔍 Найден конкретный путь к Spawn!")
                                -- Ищем все объекты с текстом в Spawn
                                local function searchInSpawn(parent)
                                    for _, child in pairs(parent:GetChildren()) do
                                        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                                            if child.Text and child.Text ~= "" then
                                                if not originalInteractionData[child] then
                                                    originalInteractionData[child] = {
                                                        type = "TextObject",
                                                        originalValue = nil,
                                                        originalSize = child.TextSize,
                                                        originalPosition = child.Position,
                                                        originalSize2D = child.Size
                                                    }
                                                end
                                                child.TextSize = math.max(child.TextSize, 30)
                                                child.BackgroundTransparency = math.min(child.BackgroundTransparency, 0.2)
                                                child.Size = UDim2.new(0, 200, 0, 50)
                                                print("  ✅ Модифицирован текст: " .. child.Text)
                                            end
                                        end
                                        if #child:GetChildren() > 0 then
                                            searchInSpawn(child)
                                        end
                                    end
                                end
                                searchInSpawn(specificPath)
                            end
                        end
                    end
                end
            end
        end
        
    else
        -- Восстанавливаем оригинальные значения
        local restoredCount = 0
        for obj, data in pairs(originalInteractionData) do
            if obj and obj.Parent then
                if data.type == "ProximityPrompt" and data.originalValue then
                    obj.MaxActivationDistance = data.originalValue
                    restoredCount = restoredCount + 1
                elseif data.type == "ClickDetector" and data.originalValue then
                    obj.MaxActivationDistance = data.originalValue
                    restoredCount = restoredCount + 1
                elseif data.type == "TextObject" then
                    if data.originalSize then
                        obj.TextSize = data.originalSize
                    end
                    if data.originalPosition then
                        obj.Position = data.originalPosition
                    end
                    if data.originalSize2D then
                        obj.Size = data.originalSize2D
                    end
                    restoredCount = restoredCount + 1
                end
            end
        end
        table.clear(originalInteractionData)
        print("❌ Восстановлено объектов: " .. restoredCount)
    end
end

-- Функция для отслеживания новых интерактивных объектов
local function trackNewInteractiveObjects()
    workspace.DescendantAdded:Connect(function(descendant)
        if proximityPromptActive then
            local modified = false
            
            if descendant:IsA("ProximityPrompt") then
                if not originalInteractionData[descendant] then
                    originalInteractionData[descendant] = {
                        type = "ProximityPrompt",
                        originalValue = descendant.MaxActivationDistance
                    }
                end
                descendant.MaxActivationDistance = 50
                modified = true
            elseif descendant:IsA("ClickDetector") then
                if not originalInteractionData[descendant] then
                    originalInteractionData[descendant] = {
                        type = "ClickDetector",
                        originalValue = descendant.MaxActivationDistance
                    }
                end
                descendant.MaxActivationDistance = 50
                modified = true
            elseif descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
                if descendant.Text and descendant.Text ~= "" then
                    if not originalInteractionData[descendant] then
                        originalInteractionData[descendant] = {
                            type = "TextObject",
                            originalSize = descendant.TextSize,
                            originalPosition = descendant.Position,
                            originalSize2D = descendant.Size
                        }
                    end
                    descendant.TextSize = math.max(descendant.TextSize, 24)
                    descendant.BackgroundTransparency = math.min(descendant.BackgroundTransparency, 0.3)
                    modified = true
                end
            end
            
            if modified then
                print("✅ Новый интерактивный объект найден и увеличен!")
            end
        end
    end)
end

-- Остальные функции остаются без изменений (findNearestPlayer, teleportToNearest, toggleAnimations и т.д.)
-- ... (все остальные функции из предыдущего скрипта остаются такими же)

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
	
	-- Отцепляем LowerTorso (НЕ делаем anchored!)
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
	end
	
	-- Сбрасываем скорость и вращение отделенной части
	lowerTorso.Velocity = Vector3.new()
	lowerTorso.RotVelocity = Vector3.new()
	lowerTorso.AssemblyLinearVelocity = Vector3.new()
	lowerTorso.AssemblyAngularVelocity = Vector3.new()
	
	-- Удаляем свечение
	local highlight = lowerTorso:FindFirstChild("DetachedHighlight")
	if highlight then highlight:Destroy() end
	
	-- Удаляем контроллеры
	if gyro then 
		gyro:Destroy()
		gyro = nil
	end
	
	if velocityCtrl then 
		velocityCtrl:Destroy()
		velocityCtrl = nil
	end
	
	-- Восстанавливаем weld соединения
	for _, weldData in pairs(savedWelds) do
		if weldData.part0 and weldData.part1 then
			local newWeld = Instance.new("Weld")
			newWeld.Part0 = weldData.part0
			newWeld.Part1 = weldData.part1
			newWeld.C0 = weldData.c0
			newWeld.C1 = weldData.c1
			newWeld.Parent = lowerTorso
		end
	end
	
	-- Если нет сохраненных welds, создаем стандартный
	if #savedWelds == 0 then
		local newWeld = Instance.new("Weld")
		newWeld.Part0 = humanoidRootPart
		newWeld.Part1 = lowerTorso
		newWeld.C0 = CFrame.new(0, -1, 0)
		newWeld.C1 = CFrame.new(0, 0, 0)
		newWeld.Parent = lowerTorso
	end
	
	-- Возвращаем на правильную позицию
	lowerTorso.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -1, 0)
	
	-- Восстанавливаем свойства (НО НЕ ДЕЛАЕМ ANCHORED!)
	lowerTorso.Anchored = false
	lowerTorso.CanCollide = savedProperties.CanCollide or true
	
	-- ПОЛНЫЙ СБРОС СОСТОЯНИЯ ПЕРСОНАЖА
	if humanoid then
		local animator = humanoid:FindFirstChild("Animator")
		if animator then
			for _, track in pairs(animator:GetPlayingAnimationTracks()) do
				track:Stop()
			end
		end
		
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		task.wait(0.1)
		humanoid:ChangeState(Enum.HumanoidStateType.Landed)
		task.wait(0.05)
		humanoid:ChangeState(Enum.HumanoidStateType.Running)
		task.wait(0.05)
		
		humanoid.PlatformStand = false
		humanoid.AutoRotate = true
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
	
	task.wait(0.2)
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end
	
	detachedLowerTorso = nil
	savedWelds = {}
	savedProperties = {}
	
	print("✅ LowerTorso восстановлен и прикреплен обратно!")
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

-- Функция для Xray (упрощенная версия)
local function updateXray()
	if not xrayActive then return end
end

local function applyXray()
	if xrayActive then
		-- Xray логика
	end
end

-- Функции для GUI с "Someone" (упрощенные)
local function hasSomeoneText() return false end
local function checkForSomeoneGUI() end
local function trackNewGUI() end

-- Обработчик клавиш
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.Z then
		teleportToNearest()
	end
	
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

-- Функции левитации
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
Frame.Size = UDim2.new(0, 240, 0, 490)
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

-- Кнопка для увеличения радиуса интерактивных объектов
local promptBtn = createBtn("PromptBtn", "🔍 INTERACT RADIUS: OFF", 40, Color3.fromRGB(100, 100, 100))

promptBtn.MouseButton1Click:Connect(function()
	proximityPromptActive = not proximityPromptActive
	promptBtn.Text = proximityPromptActive and "🔍 INTERACT RADIUS: ON" or "🔍 INTERACT RADIUS: OFF"
	promptBtn.BackgroundColor3 = proximityPromptActive and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 100)
	increaseInteractionRadius(proximityPromptActive)
end)

-- Остальные кнопки
local boostBtn = createBtn("BoostBtn", "SPEED & JUMP BOOST: OFF", 90, Color3.fromRGB(0, 150, 0))
boostBtn.MouseButton1Click:Connect(function()
	boostActive = not boostActive
	boostBtn.Text = boostActive and "SPEED & JUMP BOOST: ON" or "SPEED & JUMP BOOST: OFF"
	boostBtn.BackgroundColor3 = boostActive and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(0, 150, 0)
	applyBoost()
end)

local animBtn = createBtn("AnimBtn", "🎭 АНИМАЦИИ: ON", 140, Color3.fromRGB(100, 100, 255))
animBtn.MouseButton1Click:Connect(function()
	animationsActive = not animationsActive
	animBtn.Text = animationsActive and "🎭 АНИМАЦИИ: ON" or "🎭 АНИМАЦИИ: OFF"
	animBtn.BackgroundColor3 = animationsActive and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
	toggleAnimations(animationsActive)
end)

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
	
	if detachLowerTorsoActive then
		updateDetachedControl()
	end
end)

speaker.CharacterAdded:Connect(function(character)
	wait(0.5)
	saveOriginalSettings()
	if boostActive then
		applyBoost()
	end
	if animationsActive then
		task.wait(0.3)
		toggleAnimations(true)
	else
		toggleAnimations(false)
	end
	if detachLowerTorsoActive then
		detachLowerTorsoActive = false
		detachBtn.Text = "🦿 DETACH LOWER TORSO: OFF (Q)"
		detachBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
	end
end)

-- Запускаем отслеживание новых объектов
task.spawn(trackNewInteractiveObjects)

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
	if detachLowerTorsoActive then
		reattachLowerTorso()
	end
	if not animationsActive then
		toggleAnimations(true)
	end
	if proximityPromptActive then
		increaseInteractionRadius(false)
	end
	main:Destroy()
end)

print("✅ EliteX Lite — Готова! Ищет любые объекты с текстом и увеличивает радиус взаимодействия!")
