local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 1. Создаем интерфейс динамически
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlatformControlGui"
screenGui.ResetOnSpawn = false -- GUI не пропадет после смерти
screenGui.Parent = playerGui

-- Функция для создания стилизованных кнопок
local function createButton(name, text, position, color)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Text = text
	button.Transparency = 0.5
	button.Size = UDim2.new(0, 220, 0, 45)
	button.Position = position
	button.BackgroundColor3 = color
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.SourceSansBold
	button.TextSize = 18
	button.Parent = screenGui

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 10)
	uiCorner.Parent = button

	return button
end

-- Создаем 3 кнопки
local freezeBtn = createButton("FreezeBtn", "Заморозить", UDim2.new(0.02, 0, 0.65, 0), Color3.fromRGB(46, 204, 113))
local platformBtn = createButton("PlatformBtn", "Создать платформу", UDim2.new(0.02, 0, 0.72, 0), Color3.fromRGB(52, 152, 219))
local clearBtn = createButton("ClearBtn", "Удалить все платформы", UDim2.new(0.02, 0, 0.79, 0), Color3.fromRGB(149, 165, 166))

------------------------------------------------------------------
-- 2. Логика работы
local isAnchored = false

-- Функция поиска HumanoidRootPart
local function getRoot()
	local char = player.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

-- Логика: Заморозка / Разморозка
freezeBtn.MouseButton1Click:Connect(function()
	local root = getRoot()
	if root then
		isAnchored = not isAnchored
		root.Anchored = isAnchored

		if isAnchored then
			freezeBtn.Text = "Разморозить"
			freezeBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
		else
			freezeBtn.Text = "Заморозить"
			freezeBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
		end
	end
end)

-- Логика: Создание платформы
platformBtn.MouseButton1Click:Connect(function()
	local root = getRoot()
	if root then
		local platform = Instance.new("Part")
		platform.Name = "MyPlatform" -- Уникальное имя
		platform.Size = Vector3.new(10, 1, 10)
		platform.Anchored = true

		-- Внешний вид: серая и полупрозрачная
		platform.Color = Color3.fromRGB(120, 120, 120) 
		platform.Transparency = 0.5 
		platform.Material = Enum.Material.SmoothPlastic -- Обычный пластик (не светится)

		-- Позиция под игроком
		platform.Position = root.Position + Vector3.new(0, -3.5, 0)
		platform.Parent = game.Workspace
	end
end)

-- Логика: Удаление всех платформ "MyPlatform"
clearBtn.MouseButton1Click:Connect(function()
	local count = 0
	for _, obj in pairs(game.Workspace:GetChildren()) do
		if obj.Name == "MyPlatform" and obj:IsA("BasePart") then
			obj:Destroy()
			count = count + 1
		end
	end
	print("Удалено платформ: " .. count)
end)
