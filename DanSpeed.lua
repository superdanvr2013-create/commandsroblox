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

-- Левитация через платформу
local levitatePart = nil
local levitateSpeed = 10

-- Настройки скорости и прыжка
local walkSpeed = 16
local jumpPower = 50

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

-- Функция применения настроек скорости/прыжка
local function applyMovementSettings()
	local char = speaker.Character
	local hum = char and char:FindFirstChild("Humanoid")
	if hum then
		hum.WalkSpeed = walkSpeed
		hum.JumpPower = jumpPower
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
Frame.Size = UDim2.new(0, 240, 0, 380) -- Увеличен размер
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

local function createTextBox(name, label, y, defaultValue)
	-- Текстовая метка
	local lbl = Instance.new("TextLabel")
	lbl.Name = name .. "_Label"
	lbl.Parent = Frame
	lbl.Text = label
	lbl.Position = UDim2.new(0.05, 0, 0, y)
	lbl.Size = UDim2.new(0.4, 0, 0, 20)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	
	-- Поле ввода
	local box = Instance.new("TextBox")
	box.Name = name
	box.Parent = Frame
	box.Text = tostring(defaultValue)
	box.Position = UDim2.new(0.55, 0, 0, y)
	box.Size = UDim2.new(0.4, 0, 0, 20)
	box.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	box.TextColor3 = Color3.new(1, 1, 1)
	box.Font = Enum.Font.Gotham
	box.TextSize = 11
	box.TextXAlignment = Enum.TextXAlignment.Center
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
	
	return box
end

-------------------------------------------------------------------
-- SPEED TextBox
-------------------------------------------------------------------
local speedBox = createTextBox("SpeedBox", "SPEED:", 35, 16)

speedBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local newSpeed = tonumber(speedBox.Text)
		if newSpeed and newSpeed >= 0 and newSpeed <= 100 then
			walkSpeed = newSpeed
			applyMovementSettings()
		else
			speedBox.Text = tostring(walkSpeed)
		end
	end
end)

-------------------------------------------------------------------
-- JUMP TextBox
-------------------------------------------------------------------
local jumpBox = createTextBox("JumpBox", "JUMP POWER:", 60, 50)

jumpBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local newJump = tonumber(jumpBox.Text)
		if newJump and newJump >= 0 and newJump <= 200 then
			jumpPower = newJump
			applyMovementSettings()
		else
			jumpBox.Text = tostring(jumpPower)
		end
	end
end)

-------------------------------------------------------------------
-- ESP
-------------------------------------------------------------------
local espBtn = createBtn("EspBtn", "ESP: OFF", 90, Color3.fromRGB(80, 80, 80))
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

-- Обновление ESP при добавлении/удалении игроков
Players.PlayerAdded:Connect(function()
	if espActive then updateESP() end
end)

Players.PlayerRemoving:Connect(function()
	if espActive then updateESP() end
end)

-------------------------------------------------------------------
-- ЛЕВИТАЦИЯ ЧЕРЕЗ ПЛАТФОРМУ
-------------------------------------------------------------------
local levitationBtn = createBtn("LevitationBtn", "ЛЕВИТАЦИЯ: OFF", 135, Color3.fromRGB(120, 40, 200))

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
local anchorBtn = createBtn("AnchorBtn", "ANCHORED: OFF", 180, Color3.fromRGB(40, 40, 45))

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
-- КНОПКА KICK (локально отключает клиента)
-------------------------------------------------------------------
local kickBtn = createBtn("KickBtn", "KICK", 220, Color3.fromRGB(255, 50, 50))

kickBtn.MouseButton1Click:Connect(function()
	game:Shutdown()
end)

-------------------------------------------------------------------
-- AUTO AIM: постоянно смотреть на ближайшего чужого игрока
-------------------------------------------------------------------
local aimBtn = createBtn("AimBtn", "AIM NEAREST: OFF", 260, Color3.fromRGB(0, 180, 255))

local isAutoAim = false

aimBtn.MouseButton1Click:Connect(function()
	isAutoAim = not isAutoAim
	aimBtn.Text = isAutoAim and "AIM NEAREST: ON" or "AIM NEAREST: OFF"

	local char = speaker.Character
	local hum = char and char:FindFirstChild("Humanoid")
	if not hum then return end

	if isAutoAim then
		hum.AutoRotate = false
	else
		hum.AutoRotate = true
	end
end)

local function findNearestPlayer()
	local root = speaker.Character and speaker.Character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end

	local closestPlayer
	local closestDist = math.huge

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= speaker then
			local char = plr.Character
			local hum = char and char:FindFirstChild("Humanoid")
			local target = char and char:FindFirstChild("HumanoidRootPart")
			if hum and target and hum.Health > 0 then
				local dist = (target.Position - root.Position).Magnitude
				if dist < closestDist then
					closestDist = dist
					closestPlayer = target
				end
			end
		end
	end

	return closestPlayer
end

-- Постоянно смотрим на ближайшего чужого игрока, пока isAutoAim = true
RunService.Heartbeat:Connect(function()
	local char = speaker.Character
	local hum = char and char:FindFirstChild("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return end

	if not isAutoAim then
		return
	end

	local nearestHRP = findNearestPlayer()
	if not nearestHRP then return end

	local flat = Vector3.new(
		nearestHRP.Position.X - root.Position.X,
		0,
		nearestHRP.Position.Z - root.Position.Z
	)

	if flat.Magnitude < 0.1 then return end

	hum:Move(flat.Unit, false)
end)

-------------------------------------------------------------------
-- ЛЕГКИЙ LOOP
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
	
	-- Применяем настройки скорости и прыжка при каждом появлении персонажа
	if hum then
		if hum.WalkSpeed ~= walkSpeed then
			hum.WalkSpeed = walkSpeed
		end
		if hum.JumpPower ~= jumpPower then
			hum.JumpPower = jumpPower
		end
	end
end)

-- Обработка респавна персонажа
speaker.CharacterAdded:Connect(function()
	wait(0.5)
	applyMovementSettings()
end)

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
	main:Destroy()
end)

print("✅ EliteX Lite — левитация, ESP, Anchor, KICK, Speed, Jump")
