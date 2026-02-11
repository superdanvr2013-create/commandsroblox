local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

-- === НАСТРОЙКИ ===
local DIST_UP = 40       -- На сколько студов поднять вверх
local SPEED_UP = 30       -- Скорость подъема (чем меньше, тем медленнее)
-- =================

-- Создаем GUI
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
ScreenGui.Name = "ElevatorGui"

-- Кнопка СТАРТ
local StartBtn = Instance.new("TextButton", ScreenGui)
StartBtn.Size = UDim2.new(0, 150, 0, 50)
StartBtn.Position = UDim2.new(0.5, -160, 0.8, -50)
StartBtn.Text = "ПОДНЯТЬСЯ"
StartBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Зеленый
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Font = Enum.Font.SourceSansBold
StartBtn.TextSize = 18

-- Кнопка СТОП
local StopBtn = Instance.new("TextButton", ScreenGui)
StopBtn.Size = UDim2.new(0, 150, 0, 50)
StopBtn.Position = UDim2.new(0.5, 10, 0.8, -50)
StopBtn.Text = "ОСТАНОВИТЬ"
StopBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Красный
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.Font = Enum.Font.SourceSansBold
StopBtn.TextSize = 18

local isMoving = false
local stopForced = false

-- Функция для очистки физики
local function clearPhysics()
	for _, child in pairs(Root:GetChildren()) do
		if child.Name == "UpLift" then
			child:Destroy()
		end
	end
	Root.Velocity = Vector3.new(0,0,0)
end

-- Функция медленного подъема
local function liftUp()
	local bv = Instance.new("BodyVelocity")
	bv.Name = "UpLift"
	bv.MaxForce = Vector3.new(0, 10^6, 0) -- Сила только по вертикали
	bv.Velocity = Vector3.new(0, SPEED_UP, 0)
	bv.Parent = Root

	local travelTime = DIST_UP / SPEED_UP
	local elapsed = 0

	while elapsed < travelTime do
		if stopForced then break end
		local dt = task.wait()
		elapsed = elapsed + dt
		StartBtn.Text = "Высота: " .. math.floor(elapsed * SPEED_UP) .. " / " .. DIST_UP
	end

	bv:Destroy()
	Root.Velocity = Vector3.new(0,0,0)
end

-- Событие СТОП
StopBtn.MouseButton1Click:Connect(function()
	if isMoving then
		stopForced = true
		clearPhysics()
		isMoving = false
		StartBtn.Active = true
		StartBtn.Text = "ПОДНЯТЬСЯ"
	end
end)

-- Событие СТАРТ
StartBtn.MouseButton1Click:Connect(function()
	if isMoving then return end

	isMoving = true
	stopForced = false
	StartBtn.Active = false

	task.spawn(function()
		liftUp()

		-- Завершение процесса
		isMoving = false
		StartBtn.Active = true
		StartBtn.Text = "ПОДНЯТЬСЯ"
	end)
end)
