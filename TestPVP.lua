local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")

-- Удаляем старое
if playerGui:FindFirstChild("InvisibilityGui") then
	playerGui.InvisibilityGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InvisibilityGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Frame фон
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 80)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.25)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 16)  -- ✅ UDim!
frameCorner.Parent = frame

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "🔮 Невидимость других"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- КНОПКА
local button = Instance.new("TextButton")
button.Size = UDim2.new(0.92, 0, 0, 42)
button.Position = UDim2.new(0.04, 0, 0.45, 0)
button.Text = "🕶️ ВКЛ НЕВИДИМОСТЬ"
button.TextColor3 = Color3.new(1, 1, 1)
button.BackgroundColor3 = Color3.new(0.1, 0.6, 1)
button.BorderSizePixel = 0
button.Font = Enum.Font.GothamBold
button.TextSize = 20
button.Parent = frame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 12)  -- ✅ UDim!
buttonCorner.Parent = button

-- Эффекты
local function updateButtonColor()
	button.BackgroundColor3 = isInvisible and Color3.new(1, 0.3, 0.3) or Color3.new(0.1, 0.6, 1)
end

button.MouseEnter:Connect(function()
	button.BackgroundColor3 = Color3.new(0.2, 0.7, 1)
end)
button.MouseLeave:Connect(updateButtonColor)

-- ЛОГИКА НЕВИДИМОСТИ
local isInvisible = false
local connections = {}

local function setTransparency(obj, trans)
	if not obj then return end
	if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
		obj.Transparency = trans
	end
	for _, child in obj:GetChildren() do
		setTransparency(child, trans)
	end
end

local function toggle()
	print("🔥 КНОПКА КЛИКНУТА!")
	isInvisible = not isInvisible
	button.Text = isInvisible and "👁️ ВЫКЛ НЕВИДИМОСТЬ" or "🕶️ ВКЛ НЕВИДИМОСТЬ"
	updateButtonColor()

	if isInvisible then
		for _, p in Players:GetPlayers() do
			if p ~= player and p.Character then
				setTransparency(p.Character, 1)
			end
		end
		spawn(function()
			while isInvisible do
				for _, p in Players:GetPlayers() do
					if p ~= player and p.Character then
						setTransparency(p.Character, 1)
					end
				end
				wait(0.1)
			end
		end)
	else
		for _, p in Players:GetPlayers() do
			if p ~= player and p.Character then
				setTransparency(p.Character, 0)
			end
		end
	end
end

button.MouseButton1Click:Connect(toggle)

-- Новые игроки
Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function()
		if isInvisible then
			wait(0.5)
			setTransparency(p.Character, 1)
		end
	end)
end)

print("✅ НЕВИДИМОСТЬ ЗАГРУЖЕНА! Синяя кнопка слева сверху!")
