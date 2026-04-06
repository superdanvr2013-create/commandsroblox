local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GhostMove"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 90)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.2)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "👻 Другие видят стоящим"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(0.9, 0, 0, 45)
button.Position = UDim2.new(0.05, 0, 0.4, 0)
button.Text = "🚀 ВКЛ"
button.TextColor3 = Color3.new(1,1,1)
button.BackgroundColor3 = Color3.new(0.2, 0.8, 1)
button.BorderSizePixel = 0
button.Font = Enum.Font.GothamBold
button.TextSize = 22
button.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 12)
btnCorner.Parent = button

-- Скрипт
local enabled = false
local connection
local baseCFrame
local humanoid

button.MouseButton1Click:Connect(function()
    enabled = not enabled
    button.Text = enabled and "⏹️ ВЫКЛ" or "🚀 ВКЛ"
    button.BackgroundColor3 = enabled and Color3.new(1, 0.3, 0.3) or Color3.new(0.2, 0.8, 1)
    
    local character = player.Character
    if not character then return end
    
    humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    
    if enabled then
        baseCFrame = rootPart.CFrame
        print("🚀 АКТИВНО - двигаетесь локально, другие видят стоящим!")
        
        -- ОСНОВНОЙ ЦИКЛ
        connection = RunService.Heartbeat:Connect(function()
            if not enabled then return end
            
            -- 1. Локальное движение (каждый кадр)
            local camera = workspace.CurrentCamera
            local moveVector = humanoid.MoveDirection
            
            if moveVector.Magnitude > 0 then
                -- Двигаемся в направлении камеры/движения
                local lookDirection = (camera.CFrame.LookVector * moveVector.Z + camera.CFrame.RightVector * moveVector.X)
                rootPart.CFrame = rootPart.CFrame + lookDirection * 16 * 0.016  -- Нормальная скорость
            end
            
            -- 2. Snap обратно каждые 0.1с (сервер видит base позицию)
            if tick() % 0.1 < 0.016 then
                rootPart.CFrame = baseCFrame
            end
        end)
    else
        print("⏹️ ОТКЛЮЧЕНО")
        if connection then 
            connection:Disconnect() 
            connection = nil
        end
        humanoid.PlatformStand = false
    end
end)

print("✅ Скрипт готов! Нажмите для активации.")
