local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

-- === НАСТРОЙКИ ===
local DIST_UP      = 5
local DIST_FORWARD = 90
local DIST_LEFT    = 15
local DIST_RIGHT   = 15
local DIST_BACK    = 90
local SPEED        = 30 
-- =================

-- Создаем GUI
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
local Button = Instance.new("TextButton", ScreenGui)
Button.Size = UDim2.new(0, 200, 0, 50)
Button.Position = UDim2.new(0.5, -100, 0.8, -50)
Button.Text = "Запустить (Physics Mode)"
Button.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 18

local isMoving = false

-- Универсальная функция движения через BodyVelocity
local function movePhysical(direction, distance)
	if distance <= 0 then return end

	-- Создаем "двигатель"
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1, 1, 1) * 10^6 -- Огромная сила, чтобы гравитация не мешала
	bv.Velocity = direction * SPEED
	bv.Parent = Root

	-- Рассчитываем время пути (t = s / v)
	local travelTime = distance / SPEED
	task.wait(travelTime)

	-- Выключаем двигатель
	bv:Destroy()
	Root.Velocity = Vector3.new(0,0,0) -- Мгновенная остановка
end

-- Функция фиксации (паузы)
local function holdPhysical(duration)
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1, 1, 1) * 10^6
	bv.Velocity = Vector3.new(0, 0, 0) -- Скорость ноль = стоять на месте
	bv.Parent = Root

	task.wait(duration)
	bv:Destroy()
end

Button.MouseButton1Click:Connect(function()
	if isMoving then return end
	isMoving = true
	Button.Active = false

	-- 1. Вверх (Мировая координата)
	Button.Text = "Вверх..."
	movePhysical(Vector3.new(0, 1, 0), DIST_UP)

	-- 2. Вперед (Относительно взгляда)
	Button.Text = "Вперед..."
	movePhysical(Root.CFrame.LookVector, DIST_FORWARD)

	-- 3. Влево
	Button.Text = "Влево..."
	movePhysical(-Root.CFrame.RightVector, DIST_LEFT)

	-- ПАУЗА (Игрок висит за счет BodyVelocity с нулевой скоростью)
	Button.Text = "ПАУЗА (4 сек)"
	holdPhysical(4)

	-- 4. Вправо
	Button.Text = "Вправо..."
	movePhysical(Root.CFrame.RightVector, DIST_RIGHT)

	-- 5. Назад
	Button.Text = "Назад..."
	movePhysical(-Root.CFrame.LookVector, DIST_BACK)

	-- Финал
	isMoving = false
	Button.Active = true
	Button.Text = "Запустить (Physics Mode)"
end)
