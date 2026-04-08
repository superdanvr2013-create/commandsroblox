-- Steal a Brainrot UNDETECTED Speed GUI (BodyVelocity Boost)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function onCharacterAdded(char)
	local humanoid = char:WaitForChild("Humanoid")
	local rootPart = char:WaitForChild("HumanoidRootPart")

	local speedEnabled = false
	local bodyVel = nil

	-- Создаём BodyVelocity (незаметный boost)
	local function toggleSpeed(enable)
		speedEnabled = enable
		if enable then
			bodyVel = Instance.new("BodyVelocity")
			bodyVel.MaxForce = Vector3.new(4000, 0, 4000)  -- Только XZ, малый Y
			bodyVel.Velocity = Vector3.new(0, 0, 0)
			bodyVel.Parent = rootPart
			print("🚀 Undetected Speed ON!")
		else
			if bodyVel then bodyVel:Destroy() end
			print("⏹️ Speed OFF!")
		end
	end

	-- Update Velocity каждый кадр (по MoveDirection, x2 speed)
	local conn = RunService.Heartbeat:Connect(function()
		if speedEnabled and bodyVel then
			local moveDir = humanoid.MoveDirection
			if moveDir.Magnitude > 0 then
				bodyVel.Velocity = moveDir * 32  -- 32 = x2 от default 16, незаметно
			else
				bodyVel.Velocity = Vector3.new(0, 0, 0)
			end
		end
	end)

	-- GUI
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "UndetectedSpeedGUI"
	screenGui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 220, 0, 110)
	frame.Position = UDim2.new(0, 20, 0.5, -55)
	frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	frame.Parent = screenGui
	local ucorner = Instance.new("UICorner")
	ucorner.CornerRadius = UDim.new(0, 15)
	ucorner.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0.35, 0)
	title.BackgroundTransparency = 1
	title.Text = "🛡️ Undetected Speed x2"
	title.TextColor3 = Color3.fromRGB(0, 255, 200)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.Parent = frame

	local btnOn = Instance.new("TextButton")
	btnOn.Size = UDim2.new(0.45, -5, 0.55, 0)
	btnOn.Position = UDim2.new(0.05, 0, 0.4, 0)
	btnOn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	btnOn.Text = "ON"
	btnOn.TextColor3 = Color3.new(1,1,1)
	btnOn.TextScaled = true
	btnOn.Font = Enum.Font.GothamBold
	btnOn.Parent = frame
	local cornerOn = Instance.new("UICorner")
	cornerOn.CornerRadius = UDim.new(0, 10)
	cornerOn.Parent = btnOn

	local btnOff = Instance.new("TextButton")
	btnOff.Size = UDim2.new(0.45, -5, 0.55, 0)
	btnOff.Position = UDim2.new(0.52, 0, 0.4, 0)
	btnOff.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	btnOff.Text = "OFF"
	btnOff.TextColor3 = Color3.new(1,1,1)
	btnOff.TextScaled = true
	btnOff.Font = Enum.Font.GothamBold
	btnOff.Parent = frame
	local cornerOff = Instance.new("UICorner")
	cornerOff.CornerRadius = UDim.new(0, 10)
	cornerOff.Parent = btnOff

	btnOn.MouseButton1Click:Connect(function()
		toggleSpeed(true)
		TweenService:Create(btnOn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 255, 0)}):Play()
	end)

	btnOff.MouseButton1Click:Connect(function()
		toggleSpeed(false)
		TweenService:Create(btnOff, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}):Play()
	end)

	print("✅ Undetected BodyVelocity GUI готов! Нет resetов.")
end

if player.Character then onCharacterAdded(player.Character) end
player.CharacterAdded:Connect(onCharacterAdded)
