local TweenService = game:GetService("TweenService")
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

-- === НАСТРОЙКИ ДИСТАНЦИИ (в студах) ===
local DIST_UP      = 0   -- Вверх
local DIST_FORWARD = 100   -- Вперед
local DIST_LEFT    = 15   -- Влево
local DIST_RIGHT   = 15   -- Вправо
local DIST_BACK    = 100   -- Назад

-- === НАСТРОЙКА СКОРОСТИ (студов в секунду) ===
local CONST_SPEED  = 20   -- Чем выше число, тем быстрее все движения
-- ======================================

-- Создаем GUI
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
local Button = Instance.new("TextButton", ScreenGui)
Button.Size = UDim2.new(0, 200, 0, 50)
Button.Position = UDim2.new(0.5, -100, 0.8, -50)
Button.Text = "Запустить цикл"
Button.BackgroundColor3 = Color3.fromRGB(142, 68, 173)
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 20

local isMoving = false

-- Функция плавного перемещения с расчетом времени под скорость
local function move(offsetVector, distance)
	if distance <= 0 then return end

	-- Рассчитываем время специально для этой дистанции
	local calculatedTime = distance / CONST_SPEED

	local targetCFrame = Root.CFrame * CFrame.new(offsetVector)
	local tweenInfo = TweenInfo.new(calculatedTime, Enum.EasingStyle.Linear) -- Linear делает скорость равномерной
	local tween = TweenService:Create(Root, tweenInfo, {CFrame = targetCFrame})

	tween:Play()
	tween.Completed:Wait()
end

Button.MouseButton1Click:Connect(function()
	if isMoving then return end
	isMoving = true
	Button.Active = false

	-- Отключаем гравитацию, чтобы не дергало
	Root.Anchored = true 

	-- 1. Вверх
	Button.Text = "Вверх..."
	move(Vector3.new(0, DIST_UP, 0), DIST_UP)

	-- 2. Вперед (в CFrame вперед это -Z)
	Button.Text = "Вперед..."
	move(Vector3.new(0, 0, -DIST_FORWARD), DIST_FORWARD)

	-- 3. Влево (в CFrame влево это -X)
	Button.Text = "Влево..."
	move(Vector3.new(-DIST_LEFT, 0, 0), DIST_LEFT)

	-- ПАУЗА (Зависание)
	Button.Text = "ПАУЗА (4 сек)"
	task.wait(4)

	-- 4. Вправо
	Button.Text = "Вправо..."
	move(Vector3.new(DIST_RIGHT, 0, 0), DIST_RIGHT)

	-- 5. Назад
	Button.Text = "Назад..."
	move(Vector3.new(0, 0, DIST_BACK), DIST_BACK)

	-- Возвращаем физику
	Root.Anchored = false
	isMoving = false
	Button.Active = true
	Button.Text = "Запустить цикл"
end)
