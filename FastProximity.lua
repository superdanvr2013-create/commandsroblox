-- Сервисы
local Players = game:GetService("Players")
local speaker = Players.LocalPlayer

-- Создание GUI
local main = Instance.new("ScreenGui")
main.Name = "EliteX_Scanner_Teleporter"
main.Parent = speaker:WaitForChild("PlayerGui")
main.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.Position = UDim2.new(0.5, -150, 0.5, -325) 
Frame.Size = UDim2.new(0, 300, 0, 700) -- Увеличили высоту
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

-- Заголовок
local title = Instance.new("TextLabel")
title.Parent = Frame
title.Text = "ELITEX SCAN & TP + UTILS"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
title.TextColor3 = Color3.fromRGB(0, 255, 127)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
Instance.new("UICorner", title)

-------------------------------------------------------------------
-- СЕКЦИЯ 1: СКАНЕР
-------------------------------------------------------------------
local scanLabel = Instance.new("TextLabel", Frame)
scanLabel.Text = "-- SCANNER --"
scanLabel.Position = UDim2.new(0, 0, 0.05, 0)
scanLabel.Size = UDim2.new(1, 0, 0, 20)
scanLabel.BackgroundTransparency = 1
scanLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
scanLabel.Font = Enum.Font.Code
scanLabel.TextSize = 12

local radiusBox = Instance.new("TextBox", Frame)
radiusBox.PlaceholderText = "Radius (10)"
radiusBox.Text = "10"
radiusBox.Position = UDim2.new(0.05, 0, 0.09, 0)
radiusBox.Size = UDim2.new(0.9, 0, 0, 25)
radiusBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
radiusBox.TextColor3 = Color3.fromRGB(0, 200, 255)
radiusBox.Font = Enum.Font.Code
radiusBox.TextSize = 12
Instance.new("UICorner", radiusBox)

local scanBtn = Instance.new("TextButton", Frame)
scanBtn.Text = "SCAN AREA"
scanBtn.Position = UDim2.new(0.05, 0, 0.14, 0)
scanBtn.Size = UDim2.new(0.9, 0, 0, 30)
scanBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
scanBtn.TextColor3 = Color3.new(1, 1, 1)
scanBtn.Font = Enum.Font.GothamBold
scanBtn.TextSize = 12
Instance.new("UICorner", scanBtn)

-------------------------------------------------------------------
-- СЕКЦИЯ 2: ТЕЛЕПОРТЕР
-------------------------------------------------------------------
local tpLabel = Instance.new("TextLabel", Frame)
tpLabel.Text = "-- TELEPORTER --"
tpLabel.Position = UDim2.new(0, 0, 0.20, 0)
tpLabel.Size = UDim2.new(1, 0, 0, 20)
tpLabel.BackgroundTransparency = 1
tpLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
tpLabel.Font = Enum.Font.Code
tpLabel.TextSize = 12

local objectPathBox = Instance.new("TextBox", Frame)
objectPathBox.PlaceholderText = "Paste path here..."
objectPathBox.Text = ""
objectPathBox.Position = UDim2.new(0.05, 0, 0.24, 0)
objectPathBox.Size = UDim2.new(0.9, 0, 0, 30)
objectPathBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
objectPathBox.TextColor3 = Color3.fromRGB(255, 255, 0)
objectPathBox.Font = Enum.Font.Code
objectPathBox.TextSize = 10
Instance.new("UICorner", objectPathBox)

local targetPosBox = Instance.new("TextBox", Frame)
targetPosBox.PlaceholderText = "X, Y, Z"
targetPosBox.Text = ""
targetPosBox.Position = UDim2.new(0.05, 0, 0.30, 0)
targetPosBox.Size = UDim2.new(0.55, 0, 0, 30)
targetPosBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
targetPosBox.TextColor3 = Color3.fromRGB(0, 255, 0)
targetPosBox.Font = Enum.Font.Code
targetPosBox.TextSize = 11
Instance.new("UICorner", targetPosBox)

local getPosBtn = Instance.new("TextButton", Frame)
getPosBtn.Text = "GET MY POS"
getPosBtn.Position = UDim2.new(0.65, 0, 0.30, 0)
getPosBtn.Size = UDim2.new(0.3, 0, 0, 30)
getPosBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
getPosBtn.TextColor3 = Color3.new(1, 1, 1)
getPosBtn.Font = Enum.Font.GothamBold
getPosBtn.TextSize = 9
Instance.new("UICorner", getPosBtn)

local tpBtn = Instance.new("TextButton", Frame)
tpBtn.Text = "TELEPORT OBJECT"
tpBtn.Position = UDim2.new(0.05, 0, 0.36, 0)
tpBtn.Size = UDim2.new(0.9, 0, 0, 35)
tpBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
tpBtn.TextColor3 = Color3.new(1, 1, 1)
tpBtn.Font = Enum.Font.GothamBold
tpBtn.TextSize = 12
Instance.new("UICorner", tpBtn)

-------------------------------------------------------------------
-- СЕКЦИЯ 3: UTILITIES (FAST PROXIMITY + MAXDISTANCE)
-------------------------------------------------------------------
local utilLabel = Instance.new("TextLabel", Frame)
utilLabel.Text = "-- UTILITIES --"
utilLabel.Position = UDim2.new(0, 0, 0.43, 0)
utilLabel.Size = UDim2.new(1, 0, 0, 20)
utilLabel.BackgroundTransparency = 1
utilLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
utilLabel.Font = Enum.Font.Code
utilLabel.TextSize = 12

local fastProxBtn = Instance.new("TextButton", Frame)
fastProxBtn.Text = "FAST PROXIMITY (E/F)"
fastProxBtn.Position = UDim2.new(0.05, 0, 0.47, 0)
fastProxBtn.Size = UDim2.new(0.9, 0, 0, 30)
fastProxBtn.BackgroundColor3 = Color3.fromRGB(75, 0, 130)
fastProxBtn.TextColor3 = Color3.new(1, 1, 1)
fastProxBtn.Font = Enum.Font.GothamBold
fastProxBtn.TextSize = 12
Instance.new("UICorner", fastProxBtn)

local fastDistBtn = Instance.new("TextButton", Frame)
fastDistBtn.Text = "FAST MAXDISTANCE"
fastDistBtn.Position = UDim2.new(0.05, 0, 0.52, 0)
fastDistBtn.Size = UDim2.new(0.9, 0, 0, 30)
fastDistBtn.BackgroundColor3 = Color3.fromRGB(75, 0, 130)
fastDistBtn.TextColor3 = Color3.new(1, 1, 1)
fastDistBtn.Font = Enum.Font.GothamBold
fastDistBtn.TextSize = 12
Instance.new("UICorner", fastDistBtn)

-------------------------------------------------------------------
-- ПОЛЯ ВВОДА
-------------------------------------------------------------------
local durationInput = Instance.new("TextBox", Frame)
durationInput.PlaceholderText = "Dur: 0"
durationInput.Text = "0"
durationInput.Position = UDim2.new(0.05, 0, 0.57, 0)
durationInput.Size = UDim2.new(0.4, 0, 0, 25)
durationInput.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
durationInput.TextColor3 = Color3.fromRGB(255, 255, 255)
durationInput.Font = Enum.Font.Code
durationInput.TextSize = 12
Instance.new("UICorner", durationInput)

local distanceInput = Instance.new("TextBox", Frame)
distanceInput.PlaceholderText = "Dist: 50"
distanceInput.Text = "50"
distanceInput.Position = UDim2.new(0.55, 0, 0.57, 0)
distanceInput.Size = UDim2.new(0.4, 0, 0, 25)
distanceInput.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
distanceInput.TextColor3 = Color3.fromRGB(255, 255, 255)
distanceInput.Font = Enum.Font.Code
distanceInput.TextSize = 12
Instance.new("UICorner", distanceInput)

local loopToggle = Instance.new("TextButton", Frame)
loopToggle.Text = "LOOP: OFF"
loopToggle.Position = UDim2.new(0.05, 0, 0.62, 0)
loopToggle.Size = UDim2.new(0.9, 0, 0, 25)
loopToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
loopToggle.TextColor3 = Color3.new(1, 1, 1)
loopToggle.Font = Enum.Font.GothamBold
loopToggle.TextSize = 10
Instance.new("UICorner", loopToggle)

local isLooped = false
loopToggle.MouseButton1Click:Connect(function()
	isLooped = not isLooped
	loopToggle.Text = isLooped and "LOOP: ON" or "LOOP: OFF"
	loopToggle.BackgroundColor3 = isLooped and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(50, 50, 50)
end)

-------------------------------------------------------------------
-- ОКНО ВЫВОДА (LOGS)
-------------------------------------------------------------------
local scroll = Instance.new("ScrollingFrame", Frame)
scroll.Position = UDim2.new(0.05, 0, 0.68, 0)
scroll.Size = UDim2.new(0.9, 0, 0.31, 0)
scroll.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
scroll.ScrollBarThickness = 6
Instance.new("UICorner", scroll)

local outputBox = Instance.new("TextBox", scroll)
outputBox.Size = UDim2.new(1, 0, 1, 0)
outputBox.BackgroundTransparency = 1
outputBox.TextColor3 = Color3.new(1, 1, 1)
outputBox.TextSize = 10
outputBox.Font = Enum.Font.Code
outputBox.TextXAlignment = Enum.TextXAlignment.Left
outputBox.TextYAlignment = Enum.TextYAlignment.Top
outputBox.MultiLine = true
outputBox.TextEditable = false
outputBox.Text = "System Ready..."
outputBox.TextWrapped = false

local closeBtn = Instance.new("TextButton", Frame)
closeBtn.Text = "X"
closeBtn.Position = UDim2.new(0.9, 0, 0, 0)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.MouseButton1Click:Connect(function() main:Destroy() end)

-------------------------------------------------------------------
-- ФУНКЦИИ
-------------------------------------------------------------------

local function log(text)
	outputBox.Text = text .. "\n" .. outputBox.Text
	scroll.CanvasSize = UDim2.new(0, 0, 0, outputBox.TextBounds.Y)
end

local fastProxActive = false
local fastDistActive = false

-- ФУНКЦИЯ DURATION (как было)
local function patchHoldProperties(obj, targetValue)
	if not obj then return end

	if obj:IsA("ProximityPrompt") then
		obj.HoldDuration = targetValue
	end

	for name, value in pairs(obj:GetAttributes()) do
		local ln = name:lower()
		if ln:find("dur") or ln:find("hold") or ln:find("time") then
			if type(value) == "number" then
				obj:SetAttribute(name, targetValue)
			end
		end
	end

	if obj:IsA("NumberValue") or obj:IsA("IntValue") then
		local ln = obj.Name:lower()
		if ln:find("dur") or ln:find("hold") or ln:find("time") then
			obj.Value = targetValue
		end
	end
end

-- ФУНКЦИЯ MAXDISTANCE
local function patchMaxDistance(obj, targetValue)
	if not obj then return end

	if obj:IsA("ProximityPrompt") then
		obj.MaxActivationDistance = targetValue
	end

	for name, value in pairs(obj:GetAttributes()) do
		local ln = name:lower()
		if ln:find("maxdist") or ln:find("distance") or ln:find("dist") then
			if type(value) == "number" then
				obj:SetAttribute(name, targetValue)
			end
		end
	end

	if obj:IsA("NumberValue") or obj:IsA("IntValue") then
		local ln = obj.Name:lower()
		if ln:find("maxdist") or ln:find("distance") or ln:find("dist") then
			obj.Value = targetValue
		end
	end
end

local function findSmartPath(pathStr)
	local segments = {}
	for segment in string.gmatch(pathStr, "[^>]+") do
		table.insert(segments, segment:match("^%s*(.-)%s*$"):lower())
	end

	if #segments == 0 then return nil end

	for _, obj in pairs(workspace:GetDescendants()) do
		if obj.Name:lower() == segments[#segments] then
			local current = obj
			local matchCount = 1
			for i = #segments - 1, 1, -1 do
				if current.Parent and current.Parent.Name:lower() == segments[i] then
					matchCount = matchCount + 1
					current = current.Parent
				else
					break
				end
			end
			if matchCount == #segments then
				return obj
			end
		end
	end
	return nil
end

-------------------------------------------------------------------
-- ЛОГИКА FAST PROXIMITY (DURATION)
-------------------------------------------------------------------
fastProxBtn.MouseButton1Click:Connect(function()
	fastProxActive = not fastProxActive

	local targetValue = tonumber(durationInput.Text) or 0
	targetValue = math.clamp(targetValue, 0, 3)

	if fastProxActive then
		fastProxBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
		log("FastProx START (Dur: " .. targetValue .. ")")

		local targets = {}
		local pathText = objectPathBox.Text:gsub("%s+", "")

		if pathText ~= "" then
			local t = findSmartPath(pathText)
			if t then
				table.insert(targets, t)
				for _, d in pairs(t:GetDescendants()) do table.insert(targets, d) end
			end
		else
			for _, obj in pairs(workspace:GetDescendants()) do
				if obj:IsA("ProximityPrompt") or obj.Name:lower():find("spawn") or obj.Name:lower():find("base") then
					table.insert(targets, obj)
				end
			end
		end

		task.spawn(function()
			if isLooped then
				while fastProxActive do
					for i = #targets, 1, -1 do
						if targets[i] and targets[i].Parent then
							patchHoldProperties(targets[i], targetValue)
						else
							table.remove(targets, i)
						end
					end
					task.wait(0.3)
				end
			else
				for _, obj in pairs(targets) do
					patchHoldProperties(obj, targetValue)
				end
				log("FastProx: One-time patch done.")
				fastProxActive = false
				fastProxBtn.BackgroundColor3 = Color3.fromRGB(75, 0, 130)
			end
		end)
	else
		fastProxBtn.BackgroundColor3 = Color3.fromRGB(75, 0, 130)
		log("FastProx: STOPPED")
	end
end)

-------------------------------------------------------------------
-- ЛОГИКА FAST MAXDISTANCE
-------------------------------------------------------------------
fastDistBtn.MouseButton1Click:Connect(function()
	fastDistActive = not fastDistActive

	local targetValue = tonumber(distanceInput.Text) or 50
	targetValue = math.clamp(targetValue, 0, 500)

	if fastDistActive then
		fastDistBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
		log("FastMaxDist START (Dist: " .. targetValue .. ")")

		local targets = {}
		local pathText = objectPathBox.Text:gsub("%s+", "")

		if pathText ~= "" then
			local t = findSmartPath(pathText)
			if t then
				table.insert(targets, t)
				for _, d in pairs(t:GetDescendants()) do table.insert(targets, d) end
			end
		else
			for _, obj in pairs(workspace:GetDescendants()) do
				if obj:IsA("ProximityPrompt") or obj.Name:lower():find("spawn") or obj.Name:lower():find("base") then
					table.insert(targets, obj)
				end
			end
		end

		task.spawn(function()
			if isLooped then
				while fastDistActive do
					for i = #targets, 1, -1 do
						if targets[i] and targets[i].Parent then
							patchMaxDistance(targets[i], targetValue)
						else
							table.remove(targets, i)
						end
					end
					task.wait(0.3)
				end
			else
				for _, obj in pairs(targets) do
					patchMaxDistance(obj, targetValue)
				end
				log("FastMaxDist: One-time patch done.")
				fastDistActive = false
				fastDistBtn.BackgroundColor3 = Color3.fromRGB(75, 0, 130)
			end
		end)
	else
		fastDistBtn.BackgroundColor3 = Color3.fromRGB(75, 0, 130)
		log("FastMaxDist: STOPPED")
	end
end)

-------------------------------------------------------------------
-- TELEPORTER И СКАНЕР
-------------------------------------------------------------------
local function getPathToWorkspace(obj)
	local path = obj.Name
	local current = obj.Parent
	while current and current ~= game and current ~= workspace do
		path = current.Name .. " > " .. path
		current = current.Parent
	end
	return path
end

scanBtn.MouseButton1Click:Connect(function()
	local char = speaker.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then 
		log("No character found!")
		return 
	end
	local radius = tonumber(radiusBox.Text) or 10
	local found = {}
	for _, part in pairs(workspace:GetDescendants()) do
		if part:IsA("BasePart") and part ~= root then
			local dist = (part.Position - root.Position).Magnitude
			if dist <= radius then
				table.insert(found, string.format("[%.1f] %s", dist, getPathToWorkspace(part)))
			end
		end
	end
	outputBox.Text = #found > 0 and table.concat(found, "\n") or "Nothing found."
	scroll.CanvasSize = UDim2.new(0, 0, 0, outputBox.TextBounds.Y)
end)

getPosBtn.MouseButton1Click:Connect(function()
	local char = speaker.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then
		targetPosBox.Text = string.format("%.1f, %.1f, %.1f", root.Position.X, root.Position.Y, root.Position.Z)
		log("Current position copied!")
	end
end)

tpBtn.MouseButton1Click:Connect(function()
	local x, y, z = targetPosBox.Text:match("([%d%.%-]+)%s*,%s*([%d%.%-]+)%s*,%s*([%d%.%-]+)")
	if not (x and y and z) then 
		log("Error: Bad Pos format (X, Y, Z)")
		return 
	end

	local path = objectPathBox.Text
	local current = workspace
	for seg in path:gmatch("[^>]+") do
		local name = seg:match("^%s*(.-)%s*$")
		if name:lower() ~= "workspace" then
			current = current and current:FindFirstChild(name)
		end
	end

	if current then
		local cf = CFrame.new(tonumber(x), tonumber(y), tonumber(z))
		if current:IsA("Model") then 
			current:PivotTo(cf) 
		else 
			current.CFrame = cf 
		end
		log("Teleported: " .. current.Name)
	else
		log("Object not found!")
	end
end)
