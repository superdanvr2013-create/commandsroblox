-- Настройки
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
Frame.Size = UDim2.new(0, 280, 0, 700) -- Увеличена высота для списка игроков
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
-- КНОПКИ УПРАВЛЕНИЯ
-------------------------------------------------------------------
local espBtn = createBtn("EspBtn", "ESP: OFF", UDim2.new(0.05, 0, 0.08, 0), UDim2.new(0.9, 0, 0, 35), Color3.fromRGB(80, 80, 80))
local jumpBtn = createBtn("JumpBtn", "AIR JUMP (L-CTRL)", UDim2.new(0.05, 0, 0.16, 0), UDim2.new(0.9, 0, 0, 35), Color3.fromRGB(0, 150, 255))
local speedLockBtn = createBtn("SpeedBtn", "SPEED LOCK: OFF", UDim2.new(0.05, 0, 0.24, 0), UDim2.new(0.9, 0, 0, 35), Color3.fromRGB(120, 40, 200))

-- Speed/Jump Input Container
local speedContainer = Instance.new("Frame", Frame)
speedContainer.Name = "SpeedContainer"
speedContainer.Position = UDim2.new(0.05, 0, 0.32, 0)
speedContainer.Size = UDim2.new(0.9, 0, 0, 35)
speedContainer.BackgroundTransparency = 1

local JumpTextBox = Instance.new("TextBox", speedContainer)
JumpTextBox.Name = "JumpTextBox"
JumpTextBox.Position = UDim2.new(0.05, 0, 0, 0)
JumpTextBox.Size = UDim2.new(0.3, -10, 1, 0)
JumpTextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
JumpTextBox.Text = tostring(targetJump)
JumpTextBox.TextColor3 = Color3.new(1,1,1)
JumpTextBox.PlaceholderText = "Jump"
JumpTextBox.Font = Enum.Font.Gotham
JumpTextBox.TextSize = 12
JumpTextBox.TextXAlignment = Enum.TextXAlignment.Center
Instance.new("UICorner", JumpTextBox).CornerRadius = UDim.new(0, 4)

local speedTextBox = Instance.new("TextBox", speedContainer)
speedTextBox.Name = "SpeedTextBox"
speedTextBox.Position = UDim2.new(0.38, 0, 0, 0)
speedTextBox.Size = UDim2.new(0.3, -10, 1, 0)
speedTextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
speedTextBox.Text = tostring(targetSpeed)
speedTextBox.TextColor3 = Color3.new(1,1,1)
speedTextBox.PlaceholderText = "Speed"
speedTextBox.Font = Enum.Font.Gotham
speedTextBox.TextSize = 12
speedTextBox.TextXAlignment = Enum.TextXAlignment.Center
Instance.new("UICorner", speedTextBox).CornerRadius = UDim.new(0, 4)

local flyBtn = createBtn("FlyToggle", "FLY MODE", UDim2.new(0.05, 0, 0.40, 0), UDim2.new(0.9, 0, 0, 35), Color3.fromRGB(200, 160, 0))
local anchorBtn = createBtn("AnchorBtn", "ANCHORED: OFF", UDim2.new(0.05, 0, 0.48, 0), UDim2.new(0.9, 0, 0, 35), Color3.fromRGB(40, 40, 45))

-------------------------------------------------------------------
-- ЛОГИКА INPUT
-------------------------------------------------------------------
speedTextBox.FocusLost:Connect(function()
	local input = tonumber(speedTextBox.Text)
	if input and input >= 0 and input <= 100 then
		targetSpeed = input
		speedTextBox.Text = tostring(targetSpeed)
	end
end)

JumpTextBox.FocusLost:Connect(function()
	local input = tonumber(JumpTextBox.Text)
	if input and input >= 0 and input <= 100 then
		targetJump = input
		JumpTextBox.Text = tostring(targetJump)
	end
end)

-------------------------------------------------------------------
-- СПИСОК ИГРОКОВ (НОВЫЙ БЛОК)
-------------------------------------------------------------------
local playersFrame = Instance.new("ScrollingFrame", Frame)
playersFrame.Name = "PlayersList"
playersFrame.Position = UDim2.new(0.05, 0, 0.57, 0)
playersFrame.Size = UDim2.new(0.9, 0, 0, 130)
playersFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
playersFrame.BorderSizePixel = 0
playersFrame.ScrollBarThickness = 6
playersFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", playersFrame).CornerRadius = UDim.new(0, 4)

local playersTitle = Instance.new("TextLabel", playersFrame)
playersTitle.Text = "ИГРОКИ НА СЕРВЕРЕ:"
playersTitle.Size = UDim2.new(1, 0, 0, 25)
playersTitle.Position = UDim2.new(0, 0, 0, 0)
playersTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
playersTitle.TextColor3 = Color3.fromRGB(0, 255, 127)
playersTitle.Font = Enum.Font.GothamBold
playersTitle.TextSize = 11
Instance.new("UICorner", playersTitle).CornerRadius = UDim.new(0, 4)

local function updatePlayersList()
	for _, child in pairs(playersFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	
	local players = Players:GetPlayers()
	local yPos = 30
	for i, player in ipairs(players) do
		if player ~= speaker then
			local playerBtn = Instance.new("TextButton", playersFrame)
			playerBtn.Name = "PlayerBtn_" .. player.Name
			playerBtn.Text = player.Name
			playerBtn.Position = UDim2.new(0, 5, 0, yPos)
			playerBtn.Size = UDim2.new(1, -10, 0, 25)
			playerBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
			playerBtn.Font = Enum.Font.GothamSemibold
			playerBtn.TextColor3 = Color3.new(1,1,1)
			playerBtn.TextSize = 11
			playerBtn.TextXAlignment = Enum.TextXAlignment.Left
			Instance.new("UICorner", playerBtn).CornerRadius = UDim.new(0, 4)
			
			-- ТЕЛЕПОРТАЦИЯ ПО НАЖАТИЮ
			playerBtn.MouseButton1Click:Connect(function()
				local speakerChar = speaker.Character
				local targetChar = player.Character
				if speakerChar and targetChar and speakerChar:FindFirstChild("HumanoidRootPart") and targetChar:FindFirstChild("HumanoidRootPart") then
					speakerChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
					playerBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
					wait(0.3)
					playerBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
				end
			end)
			
			yPos = yPos + 30
		end
	end
	
	playersFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(yPos, 130))
end

-- Обновление списка каждые 5 секунд
task.spawn(function()
	while true do
		updatePlayersList()
		task.wait(5)
	end
end)

-------------------------------------------------------------------
-- TOP-3 GENERATION
-------------------------------------------------------------------
local topBox = Instance.new("TextLabel", Frame) 
topBox.Size = UDim2.new(0.9, 0, 0, 100) 
topBox.Position = UDim2.new(0.05, 0, 0.73, 0) 
topBox.BackgroundColor3 = Color3.fromRGB(10, 10, 15) 
topBox.TextColor3 = Color3.fromRGB(255, 255, 255) 
topBox.TextSize = 12 
topBox.Font = Enum.Font.Code 
topBox.Text = "Searching for Gen..." 
topBox.TextWrapped = true
Instance.new("UICorner", topBox).CornerRadius = UDim.new(0, 4)

-------------------------------------------------------------------
-- ЛОГИКА КНОПОК
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

		local resultText = "TOP 3 GENERATION:\n"
		for i = 1, 3 do
			if found[i] then
				resultText = resultText .. i .. ". [" .. found[i].path .. "] " .. found[i].original .. "\n"
			else 
				resultText = resultText .. i .. ". ---\n" 
			end
		end
		topBox.Text = resultText 
		task.wait(3) 
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

speedLockBtn.MouseButton1Click:Connect(function()
	speedLockActive = not speedLockActive
	speedLockBtn.Text = speedLockActive and "SPEED LOCK: ON" or "SPEED LOCK: OFF"
	speedLockBtn.BackgroundColor3 = speedLockActive and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(120, 40, 200)
end)

flyBtn.MouseButton1Click:Connect(function() nowe = not nowe end)

-- ОСНОВНОЙ LOOP
RunService.RenderStepped:Connect(function()
	for i, v in workspace:GetDescendants() do
		if v.ClassName ~= "Humanoid" then continue end
		local plr = Players:GetPlayerFromCharacter(v:FindFirstAncestorOfClass("Model"))
		if plr == nil then continue end
		if plr ~= speaker then continue end
		v.WalkSpeed = targetSpeed
		v.JumpHeight = targetJump
	end

	if espActive then updateESP() end
	if nowe and speaker.Character then 
		speaker.Character:TranslateBy(speaker.Character.Humanoid.MoveDirection * 16)
	end

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
closebutton.Font = Enum.Font.GothamBold
closebutton.TextSize = 14
Instance.new("UICorner", closebutton).CornerRadius = UDim.new(0, 4)
closebutton.MouseButton1Click:Connect(function() main:Destroy() end)
