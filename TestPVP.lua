local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")

-- Создаём GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LevitationGui"
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 60)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.3)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(1, 0, 1, 0)
button.Text = "🪶 Левитация"
button.TextColor3 = Color3.new(1, 1, 1)
button.BackgroundColor3 = Color3.new(0, 0.7, 1)
button.Font = Enum.Font.GothamBold
button.TextSize = 18
button.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = button

-- Логика левитации
local levitating = false
local bodyVelocity

button.MouseButton1Click:Connect(function()
	local character = player.Character
	if not character then return end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	if not levitating then
		levitating = true
		button.Text = "⏳ Левитация..."
		button.BackgroundColor3 = Color3.new(1, 0.5, 0)

		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
		bodyVelocity.Velocity = Vector3.new(0, 15, 0)  -- Медленный подъём
		bodyVelocity.Parent = rootPart

		wait(1.5)

		if bodyVelocity then
			bodyVelocity:Destroy()
		end

		levitating = false
		button.Text = "🪶 Левитация"
		button.BackgroundColor3 = Color3.new(0, 0.7, 1)
		print("Левитация завершена!")
	end
end)

print("✅ Левитация готова! Кнопка слева сверху.")
