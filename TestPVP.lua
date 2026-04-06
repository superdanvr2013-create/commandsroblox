local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Ждём PlayerGui
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then
    warn("PlayerGui не найден!")
    return
end

-- Удаляем старые GUI если есть
local oldGui = playerGui:FindFirstChild("InvisibilityGui")
if oldGui then oldGui:Destroy() end

-- Создаём GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InvisibilityGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 10  -- Выше других GUI
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 60)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true  -- Можно перетаскивать!
frame.Parent = screenGui

local uicorner = Instance.new("UICorner")
uicorner.CornerRadius = UDim2.new(0, 12, 0, 12)
uicorner.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(1, -20, 1, -10)
button.Position = UDim2.new(0, 10, 0, 5)
button.Text = "🕶️ ВКЛ НЕВИДИМОСТЬ"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
button.Font = Enum.Font.GothamBold
button.Parent = frame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim2.new(0, 8, 0, 8)
buttonCorner.Parent = button

-- Анимация hover
button.MouseEnter:Connect(function()
    button.BackgroundColor3 = Color3.fromRGB(0, 130, 200)
end)
button.MouseLeave:Connect(function()
    button.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
end)

-- Переменные
local isInvisible = false
local originalTransparencies = {}
local connections = {}
local updateConnection

-- Функция прозрачности
local function setTransparency(instance, transparency)
    if not instance or not instance.Parent then return end
    
    if instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("Texture") then
        if transparency == 1 and not originalTransparencies[instance] then
            originalTransparencies[instance] = instance.Transparency
        elseif transparency < 1 and originalTransparencies[instance] ~= nil then
            instance.Transparency = originalTransparencies[instance]
            originalTransparencies[instance] = nil
        end
        if instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("Texture") then
            instance.Transparency = transparency
        end
    end
    
    for _, child in pairs(instance:GetChildren()) do
        setTransparency(child, transparency)
    end
end

-- Toggle
local function toggleInvisibility()
    isInvisible = not isInvisible
    button.Text = isInvisible and "👁️ ВЫКЛ НЕВИДИМОСТЬ" or "🕶️ ВКЛ НЕВИДИМОСТЬ"
    button.BackgroundColor3 = isInvisible and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(0, 162, 255)
    
    -- Очистка
    for i = #connections, 1, -1 do
        if connections[i] then connections[i]:Disconnect() end
        table.remove(connections, i)
    end
    if updateConnection then updateConnection:Disconnect() updateConnection = nil end
    
    if isInvisible then
        print("Невидимость ВКЛ")
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player and targetPlayer.Character then
                setTransparency(targetPlayer.Character, 1)
            end
        end
        updateConnection = RunService.Heartbeat:Connect(function()
            for _, targetPlayer in pairs(Players:GetPlayers()) do
                if targetPlayer ~= player and targetPlayer.Character then
                    setTransparency(targetPlayer.Character, 1)
                end
            end
        end)
    else
        print("Невидимость ВЫКЛ")
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player and targetPlayer.Character then
                setTransparency(targetPlayer.Character, 0)
            end
        end
    end
end

button.MouseButton1Click:Connect(toggleInvisibility)

-- Новые игроки
Players.PlayerAdded:Connect(function(newPlayer)
    table.insert(connections, newPlayer.CharacterAdded:Connect(function(char)
        if isInvisible then
            task.wait(0.5)
            setTransparency(char, 1)
        end
    end))
end)

-- Своя смерть
player.CharacterAdded:Connect(function()
    task.wait(1)  -- Перезапуск GUI если сломался
end)

print("✅ Невидимость GUI загружена! Кнопка в левом верхнем углу.")
