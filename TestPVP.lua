local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then return end

-- Удаляем старое
pcall(function() playerGui.InvisibilityGui:Destroy() end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InvisibilityGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 100
screenGui.Parent = playerGui

-- Frame ФОН (ZIndex=1)
local frame = Instance.new("Frame")
frame.Name = "Frame"
frame.Size = UDim2.new(0, 250, 0, 70)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
frame.BorderSizePixel = 0
frame.ZIndex = 1
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim2.new(0, 15, 0, 15)
frameCorner.Parent = frame

-- Заголовок (виден всегда)
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 5)
title.BackgroundTransparency = 1
title.Text = "Невидимость других игроков"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.ZIndex = 2
title.Parent = frame

-- КНОПКА (ZIndex=10, НАВЕРХУ!)
local button = Instance.new("TextButton")
button.Name = "Button"
button.Size = UDim2.new(0.9, 0, 0, 35)
button.Position = UDim2.new(0.05, 0, 0.4, 0)
button.Text = "🕶️ ВКЛ НЕВИДИМОСТЬ"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
button.BorderSizePixel = 0
button.Font = Enum.Font.GothamBold
button.TextSize = 18  -- ФИКС TextScaled бага!
button.ZIndex = 10  -- НАИВЫШЕ!
button.Parent = frame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim2.new(0, 10, 0, 10)
buttonCorner.ZIndex = 10
buttonCorner.Parent = button

-- Hover эффект
button.MouseEnter:Connect(function()
    button.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
end)
button.MouseLeave:Connect(function()
    button.BackgroundColor3 = isInvisible and Color3.fromRGB(220, 50, 50) or Color3.fromRGB(0, 162, 255)
end)

-- Переменные
local isInvisible = false
local originalTransparencies = {}
local connections = {}
local updateConnection

local function setTransparency(instance, transparency)
    if not instance then return end
    if instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("Texture") then
        if transparency == 1 and not originalTransparencies[instance] then
            originalTransparencies[instance] = instance.Transparency
        elseif transparency == 0 and originalTransparencies[instance] then
            instance.Transparency = originalTransparencies[instance]
            originalTransparencies[instance] = nil
        end
        instance.Transparency = transparency
    end
    for _, child in pairs(instance:GetChildren()) do
        setTransparency(child, transparency)
    end
end

local function toggleInvisibility()
    print("Клик по кнопке!")  -- Проверка F9
    isInvisible = not isInvisible
    button.Text = isInvisible and "👁️ ВЫКЛ НЕВИДИМОСТЬ" or "🕶️ ВКЛ НЕВИДИМОСТЬ"
    button.BackgroundColor3 = isInvisible and Color3.fromRGB(220, 50, 50) or Color3.fromRGB(0, 162, 255)
    
    -- Очистка...
    for i = #connections, 1, -1 do
        if connections[i] then connections[i]:Disconnect() end
    end
    connections = {}
    if updateConnection then updateConnection:Disconnect() end
    
    if isInvisible then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                setTransparency(p.Character, 1)
            end
        end
        updateConnection = RunService.Heartbeat:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character then setTransparency(p.Character, 1) end
            end
        end)
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                setTransparency(p.Character, 0)
            end
        end
    end
end

button.MouseButton1Click:Connect(toggleInvisibility)

Players.PlayerAdded:Connect(function(newPlayer)
    table.insert(connections, newPlayer.CharacterAdded:Connect(function()
        if isInvisible then task.wait(0.3); setTransparency(newPlayer.Character, 1) end
    end))
end)

print("✅ GUI КНОПКА готова! Левый верхний угол. F9 для логов.")
