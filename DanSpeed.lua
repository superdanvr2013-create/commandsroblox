-- Настройки
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local speaker = Players.LocalPlayer
local main = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")

-- Настройки
local espActive = false
local levitatingCtrl = false         -- левитация по Ctrl
local levitatingToggle = false       -- левитация по кнопке
local isAnchored = false
local targetSpeed = 25               -- скорость по умолчанию
local targetJump = 10                -- прыжок по умолчанию

-- ГЛАВНЫЙ ИНТЕРФЕЙС
main.Name = "EliteX_Lite"
main.Parent = speaker:WaitForChild("PlayerGui")
main.ResetOnSpawn = false

Frame.Name = "MainFrame"
Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.Position = UDim2.new(0.02, 0, 0.02, 0)
Frame.Size = UDim2.new(0, 280, 0, 320)
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

-- Заголовок
local title = Instance.new("TextLabel")
title.Parent = Frame
title.Text = "ELITEX — LITE"
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
title.TextColor3 = Color3.fromRGB(0, 255, 127)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local function createBtn(name, text, pos, size, color)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Text = text
	btn.Position = pos
	btn.Size = size
	btn.BackgroundColor3 = color
	btn.Font = Enum.Font.GothamSemibold
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextSize = 12
	btn.Parent = Frame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	return btn
end

-------------------------------------------------------------------
-- ESP
-------------------------------------------------------------------
local espBtn = createBtn("EspBtn", "ESP: OFF", UDim2.new(0.05, 0, 0.12, 0), UDim2.new(0.9, 0, 0, 35), Color3.fromRGB(80, 80, 80))

local function updateESP()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= speaker and player.Character then
			local char = player.Character
			local oldHighlight = char:FindFirstChild("EliteX_ESP")
			if espActive then
				if not oldHighlight then
					local highlight = Instance.new("Highlight")
					highlight.Name = "EliteX_ESP"
					highlight.FillColor = Color3.fromRGB(255, 100, 0)
					highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
					highlight.FillTransparency = 0.4
					highlight.Adornee = char
					highlight.Parent = char
				end
			else
				if oldHighlight then
					oldHighlight:Destroy()
				end
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

-------------------------------------------------------------------
-- СКОРОСТЬ И ПРЫЖОК (textbox'ы с подписями)
-------------------------------------------------------------------
local speedContainer = Instance.new("Frame")
speedContainer.Name = "SpeedContainer"
speedContainer.Position = UDim2.new(0.05, 0, 0.24, 0)
speedContainer.Size = UDim2.new(0.9, 0, 0, 30)
speedContainer.BackgroundTransparency = 1
speedContainer.Parent = Frame

-- Label слева
local speedLabel = Instance.new("TextLabel")
speedLabel.Text = "Speed"
speedLabel.Position = UDim2.new(0, 0, 0, 0)
speedLabel.Size = UDim2.new(0.25, 0, 1, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
speedLabel.Font = Enum.Font.GothamSemibold
speedLabel.TextSize = 12
speedLabel.Parent = speedContainer

-- TextBox
local speedTextBox = Instance.new("TextBox")
speedTextBox.Name = "SpeedTextBox"
speedTextBox.Position = UDim2.new(0.28, 0, 0, 0)
speedTextBox.Size = UDim2.new(0.7, 0, 1, 0)
speedTextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
speedTextBox.Text = tostring(targetSpeed)
speedTextBox.TextColor3 = Color3.new(1,1,1)
speedTextBox.PlaceholderText = "16"
speedTextBox.Font = Enum.Font.GothamSemibold
speedTextBox.TextSize = 12
speedTextBox.TextXAlignment = Enum.TextXAlignment.Center
speedTextBox.Parent = speedContainer
Instance.new("UICorner", speedTextBox).CornerRadius = UDim.new(0, 6)

-------------------------------------------------------------------
local jumpContainer = Instance.new("Frame")
jumpContainer.Name = "JumpContainer"
jumpContainer.Position = UDim2.new(0.05, 0, 0.34, 0)
jumpContainer.Size = UDim2.new(0.9, 0, 0, 30)
jumpContainer.BackgroundTransparency = 1
jumpContainer.Parent = Frame

-- Label слева
local jumpLabel = Instance.new("TextLabel")
jumpLabel.Text = "Jump"
jumpLabel.Position = UDim2.new(0, 0, 0, 0)
jumpLabel.Size = UDim2.new(0.25, 0, 1, 0)
jumpLabel.BackgroundTransparency = 1
jumpLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
jumpLabel.Font = Enum.Font.GothamSemibold
jumpLabel.TextSize = 12
jumpLabel.Parent = jumpContainer

-- TextBox
local JumpTextBox = Instance.new("TextBox")
JumpTextBox.Name = "JumpTextBox"
JumpTextBox.Position = UDim2.new(0.28, 0, 0, 0)
JumpTextBox.Size = UDim2.new(0.7, 0, 1, 0)
JumpTextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
JumpTextBox.Text = tostring(targetJump)
JumpTextBox.TextColor3 = Color3.new(1,1,1)
JumpTextBox.PlaceholderText = "10"
JumpTextBox.Font = Enum.Font.GothamSemibold
JumpTextBox.TextSize = 12
JumpTextBox.TextXAlignment = Enum.TextXAlignment.Center
JumpTextBox.Parent = jumpContainer
Instance.new("UICorner", JumpTextBox).CornerRadius = UDim.new(0, 6)

-- Update Speed
speedTextBox.FocusLost:Connect(function()
	local input = tonumber(speedTextBox.Text)
	if input and input >= 0 and input <= 500 then
		targetSpeed = input
		speedTextBox.Text = tostring(targetSpeed)
	end
end)

-- Update Jump
JumpTextBox.FocusLost:Connect(function()
	local input = tonumber(JumpTextBox.Text)
	if input and input >= 0 and input <= 500 then
		targetJump = input
		JumpTextBox.Text = tostring(targetJump)
	end
end)

-------------------------------------------------------------------
-- ЛЕВИТАЦИЯ (Ctrl + кнопка toggle)
-------------------------------------------------------------------
local levitationBtn = createBtn("LevitationBtn", "ЛЕВИТАЦИЯ: OFF", UDim2.new(0.05, 0, 0.46, 0), UDim2.new(0.9, 0, 0, 35), Color3.fromRGB(120, 40, 200))

local bodyVelocity = nil

local function createBodyVelocity(root)
	if bodyVelocity then
		bodyVelocity:Destroy()
		bodyVelocity = nil
	end

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.P = 1000
	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	bodyVelocity.Parent = root
end

-- Ctrl зажат
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.LeftControl then
		levitatingCtrl = true
	end
end)

-- Ctrl отпущен
UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.LeftControl then
		levitatingCtrl = false
	end
end)

-- Кнопка левитации
levitationBtn.MouseButton1Click:Connect(function()
	levitatingToggle = not levitatingToggle
	levitationBtn.Text = levitatingToggle and "ЛЕВИТАЦИЯ: ON" or "ЛЕВИТАЦИЯ: OFF"
	levitationBtn.BackgroundColor3 = levitatingToggle and Color3.fromRGB(255, 150, 0) or Color3.fromRGB(120, 40, 200)
end)

-------------------------------------------------------------------
-- ANCHORED BUTTON
-------------------------------------------------------------------
local anchorBtn = createBtn("AnchorBtn", "ANCHORED: OFF", UDim2.new(0.05, 0, 0.58, 0), UDim2.new(0.9, 0, 0, 35), Color3.fromRGB(40, 40, 45))

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
-- ОСНОВНОЙ LOOP: скорость, прыжок, левитация, ESP, anchor
-------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
	-- Обновление скорости / прыжка
	for _, desc in pairs(workspace:GetDescendants()) do
		if desc:IsA("Humanoid") then
			local model = desc:FindFirstAncestorOfClass("Model")
			local plr = Players:GetPlayerFromCharacter(model)
			if plr == speaker then
				desc.WalkSpeed = targetSpeed
				desc.JumpHeight = targetJump
			end
		end
	end

	-- ESP
	if espActive then
		updateESP()
	end

	-- Левитация (Ctrl + кнопка)
	local char = speaker.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then
		if levitatingCtrl or levitatingToggle then
			if not bodyVelocity then
				createBodyVelocity(root)
			end
			bodyVelocity.Velocity = Vector3.new(
				char.Humanoid.MoveDirection.X * 10,
				16,
				char.Humanoid.MoveDirection.Z * 10
			)
		else
			if bodyVelocity then
				bodyVelocity:Destroy()
				bodyVelocity = nil
			end
		end
	end

	-- Anchor
	if isAnchored and root then
		root.Anchored = true
	end
end)

-------------------------------------------------------------------
-- ЗАКРЫТИЕ
-------------------------------------------------------------------
local closebutton = Instance.new("TextButton")
closebutton.Text = "❌"
closebutton.Position = UDim2.new(0.92, 0, 0, 5)
closebutton.Size = UDim2.new(0, 30, 0, 30)
closebutton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closebutton.TextColor3 = Color3.new(1,1,1)
closebutton.Font = Enum.Font.GothamBold
closebutton.TextSize = 18
closebutton.Parent = Frame
Instance.new("UICorner", closebutton).CornerRadius = UDim.new(0, 6)
closebutton.MouseButton1Click:Connect(function()
	main:Destroy()
end)

print("✅ EliteX Lite (Speed, Jump, Levitation, ESP, Anchor) готов.")
