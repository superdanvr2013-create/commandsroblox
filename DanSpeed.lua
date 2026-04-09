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

-- Левитация через платформу
local levitatePart = nil
local levitateSpeed = 10

-- Оригинальные настройки персонажа
local originalSpeed = 16
local originalJump = 50

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
Frame.Size = UDim2.new(0, 240, 0, 310)
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
-- ESP
-------------------------------------------------------------------
local espBtn = createBtn("EspBtn", "ESP: OFF", 90, Color3.fromRGB(80, 80, 80))
local ESPParts = {}

local function updateESP()
	ESPParts = {}

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

-------------------------------------------------------------------
-- ЛЕВИТАЦИЯ ЧЕРЕЗ ПЛАТФОРМУ
-------------------------------------------------------------------
local levitationBtn = createBtn("LevitationBtn", "ЛЕВИТАЦИЯ: OFF", 140, Color3.fromRGB(120, 40, 200))

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
local anchorBtn = createBtn("AnchorBtn", "ANCHORED: OFF", 190, Color3.fromRGB(40, 40, 45))

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
local kickBtn = createBtn("KickBtn", "KICK", 240, Color3.fromRGB(255, 50, 50))

kickBtn.MouseButton1Click:Connect(function()
	game:Shutdown()
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
	
	-- Поддерживаем настройки буста
	if hum and boostActive then
		if hum.WalkSpeed ~= 30 then
			hum.WalkSpeed = 30
		end
		if hum.JumpPower ~= 10 then
			hum.JumpPower = 10
		end
	end
end)

-- Обработка появления персонажа
speaker.CharacterAdded:Connect(function(character)
	wait(0.5)
	saveOriginalSettings()
	if boostActive then
		applyBoost()
	end
end)

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
	main:Destroy()
end)

print("✅ EliteX Lite — Буст скорости (30) и прыжка (10), ESP, Левитация, Anchor, KICK")
