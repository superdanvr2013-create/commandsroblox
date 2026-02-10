local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

-- === НАСТРОЙКИ ===
local DIST_UP      = 6
local DIST_FORWARD = 95
local DIST_LEFT    = 14
local DIST_RIGHT   = 14
local DIST_BACK    = 95
local DIST_EXTRA_UP = 5 -- На сколько еще поднять вверх во время движения назад

local SPEED_BEFORE = 30  
local SPEED_AFTER  = 15  
-- =================

-- Создаем GUI
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
local Button = Instance.new("TextButton", ScreenGui)
Button.Size = UDim2.new(0, 200, 0, 50)
Button.Position = UDim2.new(0.5, -100, 0.8, -50)
Button.Text = "Запустить"
Button.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 18

local isMoving = false

-- Универсальная функция движения
local function movePhysical(direction, distance, currentSpeed)
	if distance <= 0 then return end

	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1, 1, 1) * 10^6 
	bv.Velocity = direction.Unit * currentSpeed -- Используем .Unit для корректной скорости
	bv.Parent = Root

	local travelTime = distance / currentSpeed
	task.wait(travelTime)

	bv:Destroy()
	Root.Velocity = Vector3.new(0,0,0) 
end

-- Функция фиксации
local function holdPhysical(duration)
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1, 1, 1) * 10^6
	bv.Velocity = Vector3.new(0, 0, 0) 
	bv.Parent = Root

	task.wait(duration)
	bv:Destroy()
end

Button.MouseButton1Click:Connect(function()
	if isMoving then return end
	isMoving = true
	Button.Active = false

	-- 1. Вверх
	Button.Text = "Вверх..."
	movePhysical(Vector3.new(0, 1, 0), DIST_UP, SPEED_BEFORE)

	-- 2. Вперед
	Button.Text = "Вперед..."
	movePhysical(Root.CFrame.LookVector, DIST_FORWARD, SPEED_BEFORE)

	-- 3. Влево
	Button.Text = "Влево..."
	movePhysical(-Root.CFrame.RightVector, DIST_LEFT, SPEED_BEFORE)

	-- ПАУЗА
	Button.Text = "ПАУЗА (3 сек)"
	holdPhysical(3)

	-- 4. Вправо
	Button.Text = "Вправо..."
	movePhysical(Root.CFrame.RightVector, DIST_RIGHT, SPEED_AFTER)

	-- 5. Назад + Вверх ОДНОВРЕМЕННО
	Button.Text = "Назад и Вверх..."

	-- Создаем комбинированный вектор (назад + вверх)
	local backDirection = -Root.CFrame.LookVector * DIST_BACK
	local upDirection = Vector3.new(0, DIST_EXTRA_UP, 0)
	local combinedVector = backDirection + upDirection

	-- Дистанция здесь — это длина результирующего вектора
	local combinedDistance = combinedVector.Magnitude 

	movePhysical(combinedVector, combinedDistance, SPEED_AFTER)

	-- Финал: игрок просто упадет, так как мы ничего больше не создаем
	isMoving = false
	Button.Active = true
	Button.Text = "Запустить"
end)
