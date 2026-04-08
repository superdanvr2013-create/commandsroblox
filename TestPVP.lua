-- Steal a Brainrot GUI Speed (Кнопки ON/OFF, No WalkSpeed)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanChildRootPart")

local speedEnabled = false
local speedMultiplier = 3

-- Создаём GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedGUI"
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0, 10, 0.5, -50)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Parent = screenGui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.4, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🚀 CFrame Speed"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- Кнопка ON (зелёная)
local btnOn = Instance.new("TextButton")
btnOn.Size = UDim2.new(0.45, 0, 0.5, 0)
btnOn.Position = UDim2.new(0.05, 0, 0.45, 0)
btnOn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
btnOn.Text = "ON"
btnOn.TextColor3 = Color3.new(1,1,1)
btnOn.TextScaled = true
btnOn.Font = Enum.Font.GothamBold
btnOn.Parent = frame
local cornerOn = Instance.new("UICorner")
cornerOn.CornerRadius = UDim.new(0, 8)
cornerOn.Parent = btnOn

-- Кнопка OFF (красная)
local btnOff = Instance.new("TextButton")
btnOff.Size = UDim2.new(0.45, 0, 0.5, 0)
btnOff.Position = UDim2.new(0.5, 0, 0.45, 0)
btnOff.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
btnOff.Text = "OFF"
btnOff.TextColor3 = Color3.new(1,1,1)
btnOff.TextScaled = true
btnOff.Font = Enum.Font.GothamBold
btnOff.Parent = frame
local cornerOff = Instance.new("UICorner")
cornerOff.CornerRadius = UDim.new(0, 8)
cornerOff.Parent = btnOff

-- Speed Loop
RunService.Heartbeat:Connect(function(dt)
    if speedEnabled and humanoid.MoveDirection.Magnitude > 0 then
        local moveVector = humanoid.MoveDirection * speedMultiplier * 16 * dt
        rootPart.CFrame = rootPart.CFrame + rootPart.CFrame.LookVector * moveVector.Z + rootPart.CFrame.RightVector * moveVector.X
    end
end)

-- Клик ON
btnOn.MouseButton1Click:Connect(function()
    speedEnabled = true
    TweenService:Create(btnOn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 255, 0)}):Play()
    print("🚀 Speed ON!")
end)

-- Клик OFF
btnOff.MouseButton1Click:Connect(function()
    speedEnabled = false
    TweenService:Create(btnOff, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 0, 0)}):Play()
    print("⏹️ Speed OFF!")
end)

-- Drag GUI
local dragging = false
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)
frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
RunService.Heartbeat:Connect(function()
    if dragging then
        frame.Position = UDim2.new(0, frame.Position.X.Offset + UserInputService:GetMouseLocation().X - lastMouse.X, 0, frame.Position.Y.Offset + UserInputService:GetMouseLocation().Y - lastMouse.Y)
    end
end)
local lastMouse = Vector2.new()

print("✅ GUI Speed готов! Кликай ON/OFF на экране.")
