-- Fake Local Walk Exploit для Xeno
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Создаём GUI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Button = Instance.new("TextButton")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "FakeWalkGUI"
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 250, 0, 100)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 0
Button.Parent = Frame
Button.Size = UDim2.new(1, 0, 1, 0)
Button.Position = UDim2.new(0, 0, 0, 0)
Button.Text = "🚶 Локальная ходьба (F)"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
Button.Font = Enum.Font.GothamBold
Button.TextSize = 16

local walking = false
local connection

Button.MouseButton1Click:Connect(function()
    walking = not walking
    Button.Text = walking and "🛑 Стоп ходьба" or "🚶 Локальная ходьба (F)"
    Button.BackgroundColor3 = walking and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 162, 255)
end)

-- Горячая клавиша F
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        Button.MouseButton1Click:Fire()
    end
end)

-- Fake Walk Loop (работает через Xeno injection)
connection = RunService.Heartbeat:Connect(function()
    if walking and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local root = player.Character.HumanoidRootPart
        local humanoid = player.Character.Humanoid
        
        -- Локально: нормальная скорость
        humanoid.WalkSpeed = 50
        
        -- Подмена Network Ownership + CFrame spam (видно всем)
        root.CFrame = root.CFrame + (root.CFrame.LookVector * 0.3)
        
        -- Anti-detection (имитация легит скорости)
        if tick() % 0.1 < 0.05 then
            humanoid.WalkSpeed = 16 -- Показываем серверу "норм"
        end
    end
end)
