local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

-- === НАСТРОЙКИ ===
local DIST_UP       = 6
local DIST_FORWARD  = 90
local DIST_LEFT     = 17
local DIST_RIGHT    = 17
local DIST_BACK     = 90
local DIST_EXTRA_UP = 10 

local SPEED_BEFORE = 40
local SPEED_AFTER  = 15  
-- =================

-- Создаем GUI
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)

-- Кнопка СТАРТ
local StartBtn = Instance.new("TextButton", ScreenGui)
StartBtn.Size = UDim2.new(0, 150, 0, 50)
StartBtn.Position = UDim2.new(0.5, -160, 0.8, -50)
StartBtn.Text = "Запустить"
StartBtn.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Font = Enum.Font.SourceSansBold
StartBtn.TextSize = 18

-- Кнопка СТОП
local StopBtn = Instance.new("TextButton", ScreenGui)
StopBtn.Size = UDim2.new(0, 150, 0, 50)
StopBtn.Position = UDim2.new(0.5, 10, 0.8, -50)
StopBtn.Text = "ОСТАНОВИТЬ"
StopBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.Font = Enum.Font.SourceSansBold
StopBtn.TextSize = 18

local isMoving = false
local stopForced = false -- Флаг для мгновенной остановки

-- Функция очистки (удаляет все BodyVelocity при стопе)
local function clearPhysics()
	for _, child in pairs(Root:GetChildren()) do
		if child:IsA("BodyVelocity") then
			child:Destroy()
		end
	end
	Root.Velocity = Vector3.new(0,0,0)
end

-- Универсальная функция движения с проверкой стопа
local function movePhysical(direction, distance, currentSpeed)
	if distance <= 0 or stopForced then return end

	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1, 1, 1) * 10^6 
	bv.Velocity = direction.Unit * currentSpeed
	bv.Name = "AutoMovementBV"
	bv.Parent = Root

	local travelTime = distance / currentSpeed
	local elapsed = 0

	-- Дробим ожидание, чтобы можно было прервать движение мгновенно
	while elapsed < travelTime do
		if stopForced then break end
		local dt = task.wait()
		elapsed = elapsed + dt
	end

	bv:Destroy()
	Root.Velocity = Vector3.new(0,0,0) 
end

-- Функция фиксации с проверкой стопа
local function holdPhysical(duration)
	if stopForced then return end
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1, 1, 1) * 10^6
	bv.Velocity = Vector3.new(0, 0, 0) 
	bv.Name = "HoldBV"
	bv.Parent = Root

	local elapsed = 0
	while elapsed < duration do
		if stopForced then break end
		local dt = task.wait()
		elapsed = elapsed + dt
	end

	bv:Destroy()
end

-- Логика кнопки СТОП
StopBtn.MouseButton1Click:Connect(function()
	if isMoving then
		stopForced = true
		clearPhysics()
		isMoving = false
		StartBtn.Active = true
		StartBtn.Text = "Запустить"
		print("Движение прервано игроком")
	end
end)

-- Логика кнопки СТАРТ
StartBtn.MouseButton1Click:Connect(function()
	if isMoving then return end

	isMoving = true
	stopForced = false
	StartBtn.Active = false

	-- Используем task.spawn, чтобы основной скрипт не "зависал" в ожидании конца движений
	task.spawn(function()
		-- 1. Вверх
		StartBtn.Text = "Вверх..."
		movePhysical(Vector3.new(0, 1, 0), DIST_UP, SPEED_BEFORE)
		if stopForced then return end

		-- 2. Вперед
		StartBtn.Text = "Вперед..."
		movePhysical(Root.CFrame.LookVector, DIST_FORWARD, SPEED_BEFORE)
		if stopForced then return end

		-- 3. Влево
		StartBtn.Text = "Влево..."
		movePhysical(-Root.CFrame.RightVector, DIST_LEFT, SPEED_BEFORE)
		if stopForced then return end

		-- ПАУЗА
		StartBtn.Text = "ПАУЗА (3 сек)"
		holdPhysical(3)
		if stopForced then return end

		-- 4. Вправо
		StartBtn.Text = "Вправо..."
		movePhysical(Root.CFrame.RightVector, DIST_RIGHT, SPEED_AFTER)
		if stopForced then return end

		-- 5. Назад + Вверх
		StartBtn.Text = "Назад и Вверх..."
		local backDirection = -Root.CFrame.LookVector * DIST_BACK
		local upDirection = Vector3.new(0, DIST_EXTRA_UP, 0)
		local combinedVector = backDirection + upDirection
		movePhysical(combinedVector, combinedVector.Magnitude, SPEED_AFTER)

		-- Финал
		isMoving = false
		stopForced = false
		StartBtn.Active = true
		StartBtn.Text = "Запустить"
	end)
end)
