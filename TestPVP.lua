local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local button = script.Parent -- Замените на путь к вашей кнопке, напр. player.PlayerGui.ScreenGui.Button
local isInvisible = false
local originalTransparencies = {} -- Храним оригинальные прозрачности
local connections = {}

-- Рекурсивная функция для установки прозрачности
local function setTransparency(part, transparency)
    if part:IsA("BasePart") or part:IsA("Decal") then
        if transparency == 1 then -- Сохраняем оригинал при скрытии
            if not originalTransparencies[part] then
                originalTransparencies[part] = part.Transparency
            end
        else -- Восстанавливаем при показе
            if originalTransparencies[part] then
                part.Transparency = originalTransparencies[part]
                originalTransparencies[part] = nil
            end
        end
        part.Transparency = transparency
    end
    
    -- Рекурсия для детей (аксессуары, инструменты)
    for _, child in pairs(part:GetChildren()) do
        setTransparency(child, transparency)
    end
end

-- Функция для обработки одного персонажа
local function handleCharacter(targetPlayer, hide)
    if targetPlayer == player then return end -- Не трогаем себя
    
    local character = targetPlayer.Character
    if character then
        setTransparency(character, hide and 1 or 0)
    end
    
    -- Подписка на респавн
    local charAddedConn = targetPlayer.CharacterAdded:Connect(function(newChar)
        newChar:WaitForChild("HumanoidRootPart", 5) -- Ждём загрузку
        setTransparency(newChar, hide and 1 or 0)
    end)
    table.insert(connections, charAddedConn)
end

-- Основной цикл обновления (каждый кадр, для новых игроков/частей)
local updateConnection
local function toggleInvisibility()
    isInvisible = not isInvisible
    button.Text = isInvisible and "Выкл невидимость" or "Вкл невидимость"
    
    -- Отключаем старые коннекшены
    for _, conn in pairs(connections) do
        conn:Disconnect()
    end
    connections = {}
    
    if isInvisible then
        -- Скрываем всех других
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            handleCharacter(targetPlayer, true)
        end
        
        -- Цикл для новых игроков и обновлений
        updateConnection = RunService.RenderStepped:Connect(function()
            for _, targetPlayer in pairs(Players:GetPlayers()) do
                if targetPlayer ~= player and targetPlayer.Character then
                    setTransparency(targetPlayer.Character, 1)
                end
            end
        end)
    else
        -- Показываем всех
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            handleCharacter(targetPlayer, false)
        end
        
        if updateConnection then
            updateConnection:Disconnect()
        end
    end
end

button.MouseButton1Click:Connect(toggleInvisibility)

-- Обработка новых игроков при входе
Players.PlayerAdded:Connect(function(newPlayer)
    if isInvisible then
        handleCharacter(newPlayer, true)
    end
end)
