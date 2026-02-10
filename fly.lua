local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- === НАСТРОЙКИ ДИСТАНЦИИ (в студах) ===
local DIST_UP      = 5  -- На сколько поднять вверх
local DIST_FORWARD = 200  -- На сколько пронести вперед
local DIST_LEFT    = 15  -- На сколько капельку влево
local DIST_RIGHT   = 15  -- На сколько вправо (для возврата)
local DIST_BACK    = 200  -- На сколько назад (для возврата)
local MOVE_SPEED   = 20 -- Скорость перемещения (чем выше, тем резче)
-- ======================================

-- Создаем GUI
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
local Button = Instance.new("TextButton", ScreenGui)
Button.Size = UDim2.new(0, 200, 0, 50)
Button.Position = UDim2.new(0.5, -100, 0.8, -50)
Button.Text = "Запустить цикл"
Button.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 20

local isMoving = false

-- Функция перемещения на определенное расстояние
local function moveToDistance(directionVector, distance)
	if distance <= 0 then return end

	local attachment = Instance.new("Attachment", HumanoidRootPart)
	local linearVelocity = Instance.new("LinearVelocity", attachment)

	linearVelocity.MaxForce = 1000000
	linearVelocity.VectorVelocity = directionVector.Unit * MOVE_SPEED
	linearVelocity.Attachment0 = attachment

	-- Рассчитываем время, нужное для преодоления дистанции: t = s / v
	local duration = distance / MOVE_SPEED
	task.wait(duration)

	attachment:Destroy()
end

-- Функция фиксации в воздухе
local function holdInAir(duration)
	local holdAttachment = Instance.new("Attachment", HumanoidRootPart)
	local alignPos = Instance.new("AlignPosition", holdAttachment)
	alignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPos.Attachment0 = holdAttachment
	alignPos.Position = HumanoidRootPart.Position
	alignPos.MaxForce = 1000000
	alignPos.Responsiveness = 200

	task.wait(duration)
	holdAttachment:Destroy()
end

Button.MouseButton1Click:Connect(function()
	if isMoving then return end
	isMoving = true
	Button.Active = false

	-- 1. Вверх
	Button.Text = "Вверх..."
	moveToDistance(Vector3.new(0, 1, 0), DIST_UP)

	-- 2. Вперед
	Button.Text = "Вперед..."
	moveToDistance(HumanoidRootPart.CFrame.LookVector, DIST_FORWARD)

	-- 3. Влево
	Button.Text = "Влево..."
	moveToDistance(-HumanoidRootPart.CFrame.RightVector, DIST_LEFT)

	-- ПАУЗА (Зависание)
	Button.Text = "ПАУЗА (4 сек)"
	holdInAir(4)

	-- 4. Вправо
	Button.Text = "Вправо..."
	moveToDistance(HumanoidRootPart.CFrame.RightVector, DIST_RIGHT)

	-- 5. Назад
	Button.Text = "Назад..."
	moveToDistance(-HumanoidRootPart.CFrame.LookVector, DIST_BACK)

	-- Финал
	isMoving = false
	Button.Active = true
	Button.Text = "Запустить цикл"
end)
