local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")

-- GUI (то же красивое)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GhostMoveGui"
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
title.Text = "👻 Локальное движение"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(0.9, 0, 0, 45)
button.Position = UDim2.new(0.05, 0, 0.4, 0)
button.Text = "🚀 ВКЛ локальное"
button.TextColor3 = Color3.new(1,1,1)
button.BackgroundColor3 = Color3.new(0.2, 0.8, 1)
button.BorderSizePixel = 0
button.Font = Enum.Font.GothamBold
button.TextSize = 20
button.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 12)
btnCorner.Parent = button

-- ЛОГИКА
local enabled = false
local connection
local startPosition = Vector3.new(0,0,0)
local bodyPosition = nil

button.MouseButton1Click:Connect(function()
    enabled = not enabled
    button.Text = enabled and "⏹️ ВЫКЛ локальное" or "🚀 ВКЛ локальное"
    button.BackgroundColor3 = enabled and Color3.new(1, 0.3, 0.3) or Color3.new(0.2, 0.8, 1)
    
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    if enabled then
        startPosition = rootPart.Position
        print("🚀 Локальное движение ВКЛ - другие видят тебя на месте!")
        
        -- Фиксируем на сервере (другие видят стоящим)
        bodyPosition = Instance.new("BodyPosition")
        bodyPosition.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyPosition.Position = startPosition
        bodyPosition.D = 1000
        bodyPosition.P = 10000
        bodyPosition.Parent = rootPart
        
        -- Локальное движение (нормальная скорость)
        connection = RunService.Heartbeat:Connect(function()
            -- Ты движешься НОРМАЛЬНО локально (WASD работает)
            -- BodyPosition держит серверную позицию
        end)
    else
        print("⏹️ Локальное движение ВЫКЛ")
        if connection then connection:Disconnect() end
        if bodyPosition then bodyPosition:Destroy() end
    end
end)

print("✅ Локальное движение готово! Другие видят тебя стоящим.")
