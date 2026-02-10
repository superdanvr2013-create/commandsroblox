local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Создаем GUI
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
local Button = Instance.new("TextButton", ScreenGui)
Button.Size = UDim2.new(0, 200, 0, 50)
Button.Position = UDim2.new(0.5, -100, 0.8, -50)
Button.Text = "Начать полет"
Button.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 20

local isMoving = false

-- Функция движения
local function move(directionVector, duration)
	local attachment = Instance.new("Attachment", HumanoidRootPart)
	local linearVelocity = Instance.new("LinearVelocity", attachment)

	linearVelocity.MaxForce = 100000 
	linearVelocity.VectorVelocity = directionVector
	linearVelocity.Attachment0 = attachment

	task.wait(duration)
	attachment:Destroy()
end

Button.MouseButton1Click:Connect(function()
	if isMoving then return end
	isMoving = true
	Button.Active = false
	Button.Text = "Летим..."

	-- 1. Вверх (на 3 секунды)
	-- Vector3.new(0, 10, 0) толкает строго вверх
	move(Vector3.new(0, 1.5, 0), 3)

	-- 2. Вперед (на 3 секунды)
	local forwardDir = HumanoidRootPart.CFrame.LookVector * 15
	move(forwardDir, 3)

	-- 3. Влево (на 4 секунды)
	local leftDir = -HumanoidRootPart.CFrame.RightVector * 3
	move(leftDir, 4)

	-- 4. Вправо (на 4 секунды) — возвращаемся по горизонтали
	-- Скорость та же, время то же, значит вернемся в центр
	move(-leftDir, 4)

	-- 5. Назад (на 3 секунды) — возвращаемся в точку старта
	move(-forwardDir, 3)

	-- Завершение
	Button.Text = "Готово!"
	task.wait(1)
	isMoving = false
	Button.Active = true
	Button.Text = "Начать полет"
end)
