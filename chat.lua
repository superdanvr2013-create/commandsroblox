-- Настройки API
local API_URL = "https://asvego.ru/roblox/chat.php" -- Укажите ваш URL
local AUTH_TOKEN = "d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4"

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local userId = player.UserId
local username = player.Name
-- Используем JobId как sessionid, если пусто (в Studio), ставим заглушку
local sessionId = (game.JobId ~= "" and game.JobId) or "STUDIO_TEST_SESSION"

-- UI Переменные
local MAX_MESSAGES = 20
local isCooldown = false

-- Создание UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomChatGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local chatFrame = Instance.new("Frame")
chatFrame.Name = "MainFrame"
chatFrame.Size = UDim2.new(0, 300, 0, 350)
chatFrame.Position = UDim2.new(0, 20, 0.5, -175)
chatFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
chatFrame.BackgroundTransparency = 0.2
chatFrame.Visible = true
chatFrame.Parent = screenGui
Instance.new("UICorner", chatFrame)

local messagesFrame = Instance.new("ScrollingFrame")
messagesFrame.Name = "Messages"
messagesFrame.Size = UDim2.new(1, -10, 1, -60)
messagesFrame.Position = UDim2.new(0, 5, 0, 5)
messagesFrame.BackgroundTransparency = 1
messagesFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
messagesFrame.ScrollBarThickness = 4
messagesFrame.Parent = chatFrame

local layout = Instance.new("UIListLayout", messagesFrame)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)

local inputArea = Instance.new("Frame")
inputArea.Size = UDim2.new(1, -10, 0, 40)
inputArea.Position = UDim2.new(0, 5, 1, -45)
inputArea.BackgroundTransparency = 1
inputArea.Parent = chatFrame

local messageBox = Instance.new("TextBox")
messageBox.Size = UDim2.new(1, -70, 1, 0)
messageBox.PlaceholderText = "Введите сообщение..."
messageBox.Text = ""
messageBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
messageBox.TextColor3 = Color3.new(1, 1, 1)
messageBox.TextXAlignment = Enum.TextXAlignment.Left
messageBox.ClearTextOnFocus = true
messageBox.Parent = inputArea
Instance.new("UICorner", messageBox)

local sendButton = Instance.new("TextButton")
sendButton.Size = UDim2.new(0, 60, 1, 0)
sendButton.Position = UDim2.new(1, -60, 0, 0)
sendButton.Text = "Send"
sendButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
sendButton.TextColor3 = Color3.new(1, 1, 1)
sendButton.Parent = inputArea
Instance.new("UICorner", sendButton)

-- Функция отрисовки сообщения в UI
local function createMessage(fullText)
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -10, 0, 20)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = fullText
    msgLabel.TextColor3 = Color3.new(1, 1, 1)
    msgLabel.TextSize = 14
    msgLabel.Font = Enum.Font.SourceSans
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true
    msgLabel.Parent = messagesFrame
    
    -- Авто-скролл вниз
    messagesFrame.CanvasPosition = Vector2.new(0, messagesFrame.AbsoluteCanvasSize.Y)
    
    -- Удаление старых сообщений
    local currentMessages = messagesFrame:GetChildren()
    if #currentMessages > MAX_MESSAGES then
        currentMessages[2]:Destroy() -- [1] это UIListLayout
    end
end

-- Функция сетевого взаимодействия
local function apiRequest(msg)
    local payload = {
        userid = userId,
        sessionid = sessionId,
        message = msg,
        username = username
    }

    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = API_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. AUTH_TOKEN
            },
            Body = HttpService:JSONEncode(payload)
        })
    end)

    if success and response.Success then
        local data = HttpService:JSONDecode(response.Body)
        if data.status == "success" then
            if msg == "" then
                -- Режим получения: проходим по списку сообщений
                if data.data and #data.data > 0 then
                    for _, m in ipairs(data.data) do
                        createMessage(m)
                    end
                end
            else
                -- Режим отправки: подтверждаем свое сообщение
                createMessage(data.username .. ": " .. data.message)
            end
        end
    else
        warn("API Error: " .. tostring(response))
    end
end

-- Кнопка отправки
sendButton.MouseButton1Click:Connect(function()
    local text = messageBox.Text
    if text ~= "" and not isCooldown then
        isCooldown = true
        messageBox.Text = ""
        apiRequest(text)
        task.wait(1) -- Защита от спама кликом
        isCooldown = false
    end
end)

-- Также отправка по нажатию Enter
messageBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        sendButton.MouseButton1Click:Fire()
    end
end)

-- ГЛАВНЫЙ ЦИКЛ: Получение сообщений каждые 3 секунды
task.spawn(function()
    while true do
        apiRequest("") -- Пустой message заставляет PHP вернуть новые записи
        task.wait(3)
    end
end)

createMessage("System: Чат подключен. ID Сессии: " .. sessionId)
