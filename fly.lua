local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

-- === НАСТРОЙКИ ДИСТАНЦИИ (в студах) ===
local DIST_UP      = 0   
local DIST_FORWARD = 100   
local DIST_LEFT    = 15   
local DIST_RIGHT   = 15   
local DIST_BACK    = 100   

-- === НАСТРОЙКА СКОРОСТИ (студов в секунду) ===
local SPEED = 20 
-- ======================================

-- Создаем GUI
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
local Button = Instance.new("TextButton", ScreenGui)
Button.Size = UDim2.new(0, 200, 0, 50)
Button.Position = UDim2.new(0.5, -100, 0.8, -50)
Button.Text = "Запустить движение"
Button.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 20

local isMoving = false

-- Функция для перемещения вручную через CFrame
local function moveManual(directionVector, distance)
	local traveled = 0
	local startCFrame = Root.CFrame

	-- directionVector должен быть нормализован (длина 1)
	local unitDir = directionVector.Unit

	-- Подключаемся к циклу обновления кадров
	local connection
	connection = RunService.Heartbeat:Connect(function(dt)
		local step = SPEED * dt -- Расстояние за этот кадр

		if traveled + step >= distance then
			-- Если это последний шаг, ставим точно в цель
			local finalStep = distance - traveled
			Root.CFrame = Root.CFrame * CFrame.new(unitDir * finalStep)
			traveled = distance
			connection:Disconnect() -- Останавливаем цикл
		else
			-- Обычный шаг
			Root.CFrame = Root.CFrame * CFrame.new(unitDir * step)
			traveled = traveled + step
		end
	end)

	-- Ждем, пока перемещение закончится
	while traveled < distance do
		task.wait()
	end
end

Button.MouseButton1Click:Connect(function()
	if isMoving then return end
	isMoving = true
	Button.Active = false

	-- Включаем Anchored, чтобы гравитация не мешала
	Root.Anchored = true

	-- 1. Вверх
	Button.Text = "Вверх..."
	moveManual(Vector3.new(0, 1, 0), DIST_UP)

	-- 2. Вперед
	Button.Text = "Вперед..."
	moveManual(Vector3.new(0, 0, -1), DIST_FORWARD)

	-- 3. Влево
	Button.Text = "Влево..."
	moveManual(Vector3.new(-1, 0, 0), DIST_LEFT)

	-- ПАУЗА
	Button.Text = "ПАУЗА (3 сек)"
	task.wait(3)

	-- 4. Вправо
	Button.Text = "Вправо..."
	moveManual(Vector3.new(1, 0, 0), DIST_RIGHT)

	-- 5. Назад
	Button.Text = "Назад..."
	moveManual(Vector3.new(0, 0, 1), DIST_BACK)

	-- Завершение
	Root.Anchored = false
	isMoving = false
	Button.Active = true
	Button.Text = "Запустить движение"
end)
