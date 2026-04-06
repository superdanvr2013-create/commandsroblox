-- Настройки
local Players = game:GetService("Players") 
local UserInputService = game:GetService("UserInputService") 
local RunService = game:GetService("RunService") 

local speaker = Players.LocalPlayer 
local main = Instance.new("ScreenGui") 
local Frame = Instance.new("Frame") 
local title = Instance.new("TextLabel") 

-- Настройки
local espActive = false 
local levitating = false
local isAnchored = false 
local targetSpeed = 16 
local targetJump = 7
local nowe = false 

-- ГЛАВНЫЙ ИНТЕРФЕЙС
main.Name = "EliteX_Final_V23" 
main.Parent = speaker:WaitForChild("PlayerGui")
main.ResetOnSpawn = false

Frame.Name = "MainFrame" 
Frame.Parent = main 
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30) 
Frame.Position = UDim2.new(0.05, 0, 0.05, 0) 
Frame.Size = UDim2.new(0, 300, 0, 650) 
Frame.Active = true 
Frame.Draggable = true 
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8) 

title.Parent = Frame 
title.Text = "ELITEX V23 (PLAYER LIST)" 
title.Size = UDim2.new(1, 0, 0, 40) 
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
-- КНОПКИ УПРАВЛЕНИЯ
-------------------------------------------------------------------
local espBtn = createBtn("EspBtn", "ESP: OFF", UDim2.new(0.05, 0, 0.08, 0), UDim2.new(0.9, 0, 0, 40), Color3.fromRGB(80, 80, 80))
local jumpBtn = createBtn("JumpBtn", "AIR JUMP (L-CTRL)", UDim2.new(0.05, 0, 0.17, 0), UDim2.new(0.9, 0, 0, 40), Color3.fromRGB(0, 150, 255))
local levitationBtn = createBtn("LevitationBtn", "ЛЕВИТАЦИЯ: OFF", UDim2.new(0.05, 0, 0.26, 0), UDim2.new(0.9, 0, 0, 40), Color3.fromRGB(120, 40, 200))

-- Speed/Jump Input Container
local speedContainer = Instance.new("Frame")
speedContainer.Name = "SpeedContainer"
speedContainer.Position = UDim2.new(0.05, 0, 0.35, 0)
speedContainer.Size = UDim2.new(0.9, 0, 0, 40)
speedContainer.BackgroundTransparency = 1
speedContainer.Parent = Frame

local JumpTextBox = Instance.new("TextBox")
JumpTextBox.Name = "JumpTextBox"
JumpTextBox.Position = UDim2.new(0.02, 0, 0, 0)
JumpTextBox.Size = UDim2.new(0.24, 0, 1, 0)
JumpTextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
JumpTextBox.Text = tostring(targetJump)
JumpTextBox.TextColor3 = Color3.new(1,1,1)
JumpTextBox.PlaceholderText = "Jump"
JumpTextBox.Font = Enum.Font.GothamSemibold
JumpTextBox.TextSize = 14
JumpTextBox.TextXAlignment = Enum.TextXAlignment.Center
JumpTextBox.Parent = speedContainer
Instance.new("UICorner", JumpTextBox).CornerRadius = UDim.new(0, 6)

local speedTextBox = Instance.new("TextBox")
speedTextBox.Name = "SpeedTextBox"
speedTextBox.Position = UDim2.new(0.28, 0, 0, 0)
speedTextBox.Size = UDim2.new(0.24, 0, 1, 0)
speedTextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
speedTextBox.Text = tostring(targetSpeed)
speedTextBox.TextColor3 = Color3.new(1,1,1)
speedTextBox.PlaceholderText = "Speed"
speedTextBox.Font = Enum.Font.GothamSemibold
speedTextBox.TextSize = 14
speedTextBox.TextXAlignment = Enum.TextXAlignment.Center
speedTextBox.Parent = speedContainer
Instance.new("UICorner", speedTextBox).CornerRadius = UDim.new(0, 6)

local flyBtn = createBtn("FlyToggle", "FLY MODE", UDim2.new(0.05, 0, 0.45, 0), UDim2.new(0.9, 0, 0, 40), Color3.fromRGB(200, 160, 0))
local anchorBtn = createBtn("AnchorBtn", "ANCHORED: OFF", UDim2.new(0.05, 0, 0.54, 0), UDim2.new(0.9, 0, 0, 40), Color3.fromRGB(40, 40, 45))

-------------------------------------------------------------------
-- БОЛЬШОЙ СПИСОК ИГРОКОВ
-------------------------------------------------------------------
local playersFrame = Instance.new("ScrollingFrame")
playersFrame.Name = "PlayersList"
playersFrame.Position = UDim2.new(0.05, 0, 0.64, 0)
playersFrame.Size = UDim2.new(0.9, 0, 0, 300)
playersFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
playersFrame.BorderSizePixel = 0
playersFrame.ScrollBarThickness = 8
playersFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 127)
playersFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
playersFrame.Parent = Frame
Instance.new("UICorner", playersFrame).CornerRadius = UDim.new(0, 6)

local playersTitle = Instance.new("TextLabel")
playersTitle.Text = "👥 ИГРОКИ НА СЕРВЕРЕ (Клик = ТП В HRP)"
playersTitle.Size = UDim2.new(1, 0, 0, 35)
playersTitle.Position = UDim2.new(0, 0, 0, 0)
playersTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
playersTitle.TextColor3 = Color3.fromRGB(0, 255, 127)
playersTitle.Font = Enum.Font.GothamBold
playersTitle.TextSize = 14
playersTitle.Parent = playersFrame
Instance.new("UICorner", playersTitle).CornerRadius = UDim.new(0, 6)

local function isFriend(playerName)
	local friendNames = {"Friend1", "Friend2", "Admin"}
	for _, friend in pairs(friendNames) do
		if string.find(string.lower(playerName), string.lower(friend)) then
			return true
		end
	end
	return false
end

local function updatePlayersList()
	for _, child in pairs(playersFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local players = Players:GetPlayers()
	local yPos = 40

	for i, player in ipairs(players) do
		if player ~= speaker then
			local playerBtn = Instance.new("TextButton")
			playerBtn.Name = "PlayerBtn_" .. player.Name
			playerBtn.Text = "🎮 " .. player.Name .. " [" .. i .. "]"
			playerBtn.Position = UDim2.new(0, 8, 0, yPos)
			playerBtn.Size = UDim2.new(1, -16, 0, 38)
			playerBtn.BackgroundColor3 = isFriend(player.Name) and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(40, 45, 55)
			playerBtn.Font = Enum.Font.GothamSemibold
			playerBtn.TextColor3 = Color3.new(1,1,1)
			playerBtn.TextSize = 13
			playerBtn.TextXAlignment = Enum.TextXAlignment.Left
			playerBtn.TextYAlignment = Enum.TextYAlignment.Center
			playerBtn.Parent = playersFrame
			Instance.new("UICorner", playerBtn).CornerRadius = UDim.new(0, 6)

			playerBtn.MouseEnter:Connect(function()
				playerBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
			end)
			playerBtn.MouseLeave:Connect(function()
				playerBtn.BackgroundColor3 = isFriend(player.Name) and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(40, 45, 55)
			end)

			playerBtn.MouseButton1Click:Connect(function()
				local speakerChar = speaker.Character
				local targetChar = player.Character
				if speakerChar and targetChar then
					local speakerHRP = speakerChar:FindFirstChild("HumanoidRootPart")
					local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")

					if speakerHRP and targetHRP then
						speakerHRP.CFrame = targetHRP.CFrame
						playerBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
						task.wait(0.2)
						playerBtn.BackgroundColor3 = isFriend(player.Name) and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(40, 45, 55)
						print("✅ ТП в HRP игрока: " .. player.Name)
					else
						print("❌ HRP не найден у " .. player.Name)
					end
				end
			end)

			yPos = yPos + 42
		end
	end

	playersFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(yPos, 400))
end

task.spawn(function()
	while true do
		updatePlayersList()
		task.wait(3)
	end
end)

-------------------------------------------------------------------
-- ЛОГИКА КНОПОК
-------------------------------------------------------------------
speedTextBox.FocusLost:Connect(function()
	local input = tonumber(speedTextBox.Text)
	if input and input >= 0 and input <= 500 then
		targetSpeed = input
		speedTextBox.Text = tostring(targetSpeed)
	end
end)

JumpTextBox.FocusLost:Connect(function()
	local input = tonumber(JumpTextBox.Text)
	if input and input >= 0 and input <= 500 then
		targetJump = input
		JumpTextBox.Text = tostring(targetJump)
	end
end)

levitationBtn.MouseButton1Click:Connect(function()
	local char = speaker.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	levitating = not levitating
	levitationBtn.Text = levitating and "ЛЕВИТАЦИЯ: ON" or "ЛЕВИТАЦИЯ: OFF"
	levitationBtn.BackgroundColor3 = levitating and Color3.fromRGB(255, 150, 0) or Color3.fromRGB(120, 40, 200)

	if levitating then
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
		bodyVelocity.Velocity = Vector3.new(0, 12, 0)
		bodyVelocity.Parent = root

		task.spawn(function()
			task.wait(1.5)
			if bodyVelocity and bodyVelocity.Parent then 
				bodyVelocity:Destroy() 
			end
		end)
	end
end)

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
-- ОСНОВНОЙ ФУНКЦИОНАЛ
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
					highlight.FillColor = isFriend(player.Name) and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 100, 0)
					highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
					highlight.FillTransparency = 0.4
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
		local part = Instance.new("Part")
		part.Size = Vector3.new(10, 1, 10)
		part.Anchored = true 
		part.Material = Enum.Material.ForceField 
		part.Color = Color3.fromRGB(0, 255, 255) 
		part.Transparency = 0.3 
		part.CFrame = root.CFrame * CFrame.new(0, -4, 0)
		part.Parent = workspace
		task.spawn(function()
			for i = 1, 40 do
				part.Position = part.Position + Vector3.new(0, 0.8, 0)
				task.wait()
			end
			part:Destroy()
		end)
	end
end

jumpBtn.MouseButton1Click:Connect(doAirJump)
UserInputService.InputBegan:Connect(function(i, p) 
	if not p and i.KeyCode == Enum.KeyCode.LeftControl then 
		doAirJump() 
	end 
end)

flyBtn.MouseButton1Click:Connect(function() 
	nowe = not nowe 
	flyBtn.BackgroundColor3 = nowe and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 160, 0)
end)

-- ОСНОВНОЙ LOOP
RunService.RenderStepped:Connect(function()
	for _, v in workspace:GetDescendants() do
		if v.ClassName ~= "Humanoid" then continue end
		local plr = Players:GetPlayerFromCharacter(v:FindFirstAncestorOfClass("Model"))
		if plr == nil or plr ~= speaker then continue end
		v.WalkSpeed = targetSpeed
		v.JumpHeight = targetJump
	end

	if espActive then updateESP() end
	if nowe and speaker.Character and speaker.Character:FindFirstChild("HumanoidRootPart") then 
		speaker.Character.HumanoidRootPart.CFrame = speaker.Character.HumanoidRootPart.CFrame + speaker.Character.Humanoid.MoveDirection * 0.5
	end

	if isAnchored and speaker.Character and speaker.Character:FindFirstChild("HumanoidRootPart") then
		speaker.Character.HumanoidRootPart.Anchored = true
	end
end)

-- Закрытие
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
closebutton.MouseButton1Click:Connect(function() main:Destroy() end)

print("✅ EliteX V23 с левитацией готов!")
