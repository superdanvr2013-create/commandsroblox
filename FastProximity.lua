-- Сервисы
local Players = game:GetService("Players")
local speaker = Players.LocalPlayer

-- Создание GUI
local main = Instance.new("ScreenGui")
main.Name = "Radius_Changer"
main.Parent = speaker:WaitForChild("PlayerGui")
main.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.Position = UDim2.new(0.5, -150, 0.5, -100)
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

-- Заголовок
local title = Instance.new("TextLabel")
title.Parent = Frame
title.Text = "RADIUS CHANGER"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
title.TextColor3 = Color3.fromRGB(0, 255, 127)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
Instance.new("UICorner", title)

-- Поле для радиуса
local radiusBox = Instance.new("TextBox", Frame)
radiusBox.PlaceholderText = "Radius (0.1 - 50)"
radiusBox.Text = "5"
radiusBox.Position = UDim2.new(0.05, 0, 0.15, 0)
radiusBox.Size = UDim2.new(0.9, 0, 0, 35)
radiusBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
radiusBox.TextColor3 = Color3.fromRGB(0, 200, 255)
radiusBox.Font = Enum.Font.Code
radiusBox.TextSize = 14
Instance.new("UICorner", radiusBox)

-- Кнопка активации
local radiusBtn = Instance.new("TextButton", Frame)
radiusBtn.Text = "CHANGE RADIUS"
radiusBtn.Position = UDim2.new(0.05, 0, 0.35, 0)
radiusBtn.Size = UDim2.new(0.9, 0, 0, 40)
radiusBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
radiusBtn.TextColor3 = Color3.new(1, 1, 1)
radiusBtn.Font = Enum.Font.GothamBold
radiusBtn.TextSize = 14
Instance.new("UICorner", radiusBtn)

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton", Frame)
closeBtn.Text = "X"
closeBtn.Position = UDim2.new(0.9, 0, 0, 0)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.MouseButton1Click:Connect(function() main:Destroy() end)

-- Статус
local statusLabel = Instance.new("TextLabel", Frame)
statusLabel.Text = "Ready"
statusLabel.Position = UDim2.new(0.05, 0, 0.6, 0)
statusLabel.Size = UDim2.new(0.9, 0, 0, 25)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statusLabel.Font = Enum.Font.Code
statusLabel.TextSize = 11

-- Логика изменения радиуса
local function changeRadius()
	local newRadius = tonumber(radiusBox.Text)
	
	if not newRadius then
		statusLabel.Text = "Error: Invalid number!"
		statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
		return
	end
	
	newRadius = math.clamp(newRadius, 0.1, 50)
	
	local count = 0
	
	-- Ищем все ProximityPrompt в игре
	for _, prompt in pairs(workspace:GetDescendants()) do
		if prompt:IsA("ProximityPrompt") then
			prompt.MaxActivationDistance = newRadius
			count = count + 1
		end
	end
	
	statusLabel.Text = string.format("Changed %d prompts to radius: %.1f", count, newRadius)
	statusLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
	
	-- Сброс цвета через 2 секунды
	task.wait(2)
	if statusLabel then
		statusLabel.Text = "Ready"
		statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	end
end

radiusBtn.MouseButton1Click:Connect(changeRadius)

-- Опционально: Enter в поле радиуса тоже применяет
radiusBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		changeRadius()
	end
end)
