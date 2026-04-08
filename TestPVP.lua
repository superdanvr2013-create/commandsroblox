-- Steal a Brainrot GUI Speed FIXED (Кнопки ON/OFF)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Ждём character
local function onCharacterAdded(char)
    local humanoid = char:WaitForChild("Humanoid")
    local rootPart = char:WaitForChild("HumanoidRootPart")
    
    local speedEnabled = false
    local speedMultiplier = 3
    
    -- Speed Loop
    local connection
    connection = RunService.Heartbeat:Connect(function(dt)
        if speedEnabled and humanoid.MoveDirection.Magnitude > 0 then
            local moveVector = humanoid.MoveDirection * speedMultiplier * 16 * dt
            rootPart.CFrame = rootPart.CFrame + rootPart.CFrame.LookVector * moveVector.Z + rootPart.CFrame.RightVector * moveVector.X
        end
    end)
    
    -- GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SpeedGUI"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 110)
    frame.Position = UDim2.new(0, 20, 0.5, -55)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    local ucorner = Instance.new("UICorner")
    ucorner.CornerRadius = UDim.new(0, 15)
    ucorner.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.35, 0)
    title.BackgroundTransparency = 1
    title.Text = "🚀 CFrame Speed x3"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
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
    
    -- Кнопки
    btnOn.MouseButton1Click:Connect(function()
        speedEnabled = true
        TweenService:Create(btnOn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 255, 0)}):Play()
        print("🚀 Speed ON!")
    end)
    
    btnOff.MouseButton1Click:Connect(function()
        speedEnabled = false
        TweenService:Create(btnOff, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}):Play()
        print("⏹️ Speed OFF!")
    end)
    
    print("✅ GUI Speed FIXED готов!")
end

if player.Character then
    onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)
