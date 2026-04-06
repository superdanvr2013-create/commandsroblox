local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Создаём GUI полностью
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InvisibilityGui"
screenGui.ResetOnSpawn = false  -- Не сбрасывается при смерти
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 50)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
frame.Parent = screenGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(1, 0, 1, 0)
button.Text = "ВКЛ НЕВИДИМОСТЬ"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
button.Font = Enum.Font.SourceSansBold
button.Parent = frame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim2.new(0, 8, 0, 8)
corner.Parent = frame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim2.new(0, 6, 0, 6)
buttonCorner.Parent = button

-- Переменные для невидимости
local isInvisible = false
local originalTransparencies = {}
local connections = {}
local updateConnection

-- Рекурсивная функция прозрачности
local function setTransparency(part, transparency)
    if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("Texture") or part:IsA("SpecialMesh") then
        if transparency == 1 and not originalTransparencies[part] then
            originalTransparencies[part] = part.Transparency
        elseif transparency == 0 and originalTransparencies[part] then
            part.Transparency = originalTransparencies[part]
            originalTransparencies[part] = nil
        end
        if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("Texture") then
            part.Transparency = transparency
        end
    end
    for _, child in pairs(part:GetChildren()) do
        setTransparency(child, transparency)
    end
end

-- Обработка персонажа
local function handleCharacter(targetPlayer, hide)
    if targetPlayer == player then return end
    local character = targetPlayer.Character
    if character then
        setTransparency(character, hide and 1 or 0)
    end
end

-- Toggle функция
local function toggleInvisibility()
    isInvisible = not isInvisible
    button.Text = isInvisible and "ВЫКЛ НЕВИДИМОСТЬ" or "ВКЛ НЕВИДИМОСТЬ"
    button.BackgroundColor3 = isInvisible and Color3.fromRGB(170, 0, 0) or Color3.fromRGB(0, 170, 0)
    
    -- Очистка
    for _, conn in pairs(connections) do
        if conn then conn:Disconnect() end
    end
    connections = {}
    if updateConnection then updateConnection:Disconnect() end
    
    if isInvisible then
        -- Скрываем текущих
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            handleCharacter(targetPlayer, true)
        end
        -- Цикл обновлений
        updateConnection = RunService.RenderStepped:Connect(function()
            for _, targetPlayer in pairs(Players:GetPlayers()) do
                if targetPlayer ~= player and targetPlayer.Character then
                    setTransparency(targetPlayer.Character, 1)
                end
            end
        end)
    else
        -- Показываем
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            handleCharacter(targetPlayer, false)
        end
    end
end

button.MouseButton1Click:Connect(toggleInvisibility)

-- Новые игроки
Players.PlayerAdded:Connect(function(newPlayer)
    newPlayer.CharacterAdded:Connect(function()
        if isInvisible then
            task.wait(0.1)  -- Небольшая задержка для загрузки
            setTransparency(newPlayer.Character, 1)
        end
    end)
end)

-- Обработка смерти своего персонажа (перезапуск)
player.CharacterAdded:Connect(function()
    -- Пересоздаём GUI если нужно (но ResetOnSpawn=false)
end)

print("Невидимость GUI загружена! Нажми кнопку для toggle.")
