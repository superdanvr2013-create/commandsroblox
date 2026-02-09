local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService") -- Сервис для клавиш
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 1. Создаем интерфейс динамически
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlatformControlGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

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

local freezeBtn = createButton("FreezeBtn", "Заморозить", UDim2.new(0.02, 0, 0.65, 0), Color3.fromRGB(46, 204, 113))
local platformBtn = createButton("PlatformBtn", "Платформа (L-Ctrl)", UDim2.new(0.02, 0, 0.72, 0), Color3.fromRGB(52, 152, 219))
local clearBtn = createButton("ClearBtn", "Удалить платформы", UDim2.new(0.02, 0, 0.79, 0), Color3.fromRGB(149, 165, 166))

------------------------------------------------------------------
-- 2. Логика

local isAnchored = false

-- Функция создания платформы (вынесли отдельно для удобства)
local function spawnPlatform()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")

	if root then
		local platform = Instance.new("Part")
		platform.Name = "MyPlatform"
		platform.Size = Vector3.new(10, 1, 10)
		platform.Anchored = true
		platform.Color = Color3.fromRGB(120, 120, 120) 
		platform.Transparency = 0.5 
		platform.Material = Enum.Material.SmoothPlastic

		-- Ставим под ноги
		platform.Position = root.Position + Vector3.new(0, -3.5, 0)
		platform.Parent = game.Workspace
	end
end

-- Обработка нажатия кнопки на экране
platformBtn.MouseButton1Click:Connect(spawnPlatform)

-- Обработка горячей клавиши (Left Control)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	-- gameProcessed проверяет, не печатает ли игрок в этот момент в чате
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.LeftControl then
		spawnPlatform()
	end
end)

-- Логика заморозки
freezeBtn.MouseButton1Click:Connect(function()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then
		isAnchored = not isAnchored
		root.Anchored = isAnchored
		freezeBtn.Text = isAnchored and "Разморозить" or "Заморозить"
		freezeBtn.BackgroundColor3 = isAnchored and Color3.fromRGB(231, 76, 60) or Color3.fromRGB(46, 204, 113)
	end
end)

-- Очистка всех "MyPlatform"
clearBtn.MouseButton1Click:Connect(function()
	for _, obj in pairs(game.Workspace:GetChildren()) do
		if obj.Name == "MyPlatform" then
			obj:Destroy()
		end
	end
end)
