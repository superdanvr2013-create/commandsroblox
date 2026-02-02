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
Frame.Size = UDim2.new(0, 300, 0, 650) -- Увеличили высоту
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
-- НОВАЯ СЕКЦИЯ 3: UTILITIES (FAST PROXIMITY)
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
fastProxBtn.Size = UDim2.new(0.9, 0, 0, 35)
fastProxBtn.BackgroundColor3 = Color3.fromRGB(75, 0, 130)
fastProxBtn.TextColor3 = Color3.new(1, 1, 1)
fastProxBtn.Font = Enum.Font.GothamBold
fastProxBtn.TextSize = 12
Instance.new("UICorner", fastProxBtn)

-------------------------------------------------------------------
-- ОКНО ВЫВОДА (LOGS)
-------------------------------------------------------------------
local scroll = Instance.new("ScrollingFrame", Frame)
scroll.Position = UDim2.new(0.05, 0, 0.55, 0)
scroll.Size = UDim2.new(0.9, 0, 0.43, 0)
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
end

local fastProxActive = false
local targetPrompts = {} -- Табличная переменная для хранения найденных объектов

fastProxBtn.MouseButton1Click:Connect(function()
	fastProxActive = not fastProxActive

	if fastProxActive then
		fastProxBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
		log("FastProx: ENABLED (Turbo Mode)")

		-- 1. Сбор объектов в таблицу
		targetPrompts = {} -- Очищаем перед новым поиском
		local foundCount = 0

		for _, obj in pairs(workspace:GetDescendants()) do
			-- Проверяем путь: ... > Base > Spawn > ProximityPrompt
			if obj:IsA("ProximityPrompt") then
				local parent = obj.Parent
				if parent and (parent.Name == "Spawn" or parent.Name == "Base") then
					table.insert(targetPrompts, obj)
					foundCount = foundCount + 1
				end
			end
		end

		log("Added to table: " .. foundCount .. " prompts")

		-- 2. Асинхронный "Турбо-цикл" для борьбы с сервером
		task.spawn(function()
			while fastProxActive do
				-- Используем pairs для перебора сохраненных в таблице объектов
				for i = #targetPrompts, 1, -1 do
					local prompt = targetPrompts[i]

					-- Проверка, не удален ли объект из игры (чтобы не было ошибок)
					if prompt and prompt.Parent then
						-- Принудительно ставим 0, даже если сервер меняет обратно
						if prompt.HoldDuration ~= 0 then
							prompt.HoldDuration = 0
						end
					else
						-- Удаляем из таблицы, если объект уничтожен
						table.remove(targetPrompts, i)
					end
				end

				-- Минимально возможная задержка в движке Roblox
				-- task.wait() без аргументов ~0.03 сек, heartbeat еще быстрее
				game:GetService("RunService").Heartbeat:Wait()
			end
		end)

	else
		fastProxBtn.BackgroundColor3 = Color3.fromRGB(75, 0, 130)
		log("FastProx: DISABLED")
		targetPrompts = {} -- Очищаем таблицу при выключении
	end
end)

-- Остальная логика (Scan/TP) остается как была
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
	if not root then return end
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
end)

getPosBtn.MouseButton1Click:Connect(function()
	local char = speaker.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then
		targetPosBox.Text = string.format("%.1f, %.1f, %.1f", root.Position.X, root.Position.Y, root.Position.Z)
	end
end)

tpBtn.MouseButton1Click:Connect(function()
	local x, y, z = targetPosBox.Text:match("([%d%.%-]+)%s*,%s*([%d%.%-]+)%s*,%s*([%d%.%-]+)")
	if not (x and y and z) then log("Error: Bad Pos") return end

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
		if current:IsA("Model") then current:PivotTo(cf) else current.CFrame = cf end
		log("Teleported: " .. current.Name)
	else
		log("Object not found!")
	end
end)
