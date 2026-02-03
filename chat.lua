local API_URL = "https://robloxchat.vercel.app/api/chat" 
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- GUI: Основной контейнер (в CoreGui, чтобы не удалялся при ресете)
local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
screenGui.Name = "GlobalNodeChat"

-- КНОПКА ОТКРЫТИЯ/ЗАКРЫТИЯ
local toggleButton = Instance.new("TextButton", screenGui)
toggleButton.Size = UDim2.new(0, 40, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "💬"
toggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toggleButton.BackgroundTransparency = 0.3
toggleButton.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", toggleButton)

-- ОКНО ЧАТА
local chatFrame = Instance.new("Frame", screenGui)
chatFrame.Size = UDim2.new(0.3, 0, 0.4, 0)
chatFrame.Position = UDim2.new(0, 60, 0, 10)
chatFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
chatFrame.BackgroundTransparency = 0.5 -- ПОЛУПРОЗРАЧНОСТЬ
chatFrame.Visible = false
Instance.new("UICorner", chatFrame)

-- ОБЛАСТЬ СООБЩЕНИЙ
local messagesFrame = Instance.new("ScrollingFrame", chatFrame)
messagesFrame.Size = UDim2.new(1, -10, 1, -50)
messagesFrame.Position = UDim2.new(0, 5, 0, 5)
messagesFrame.BackgroundTransparency = 1
messagesFrame.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", messagesFrame)
layout.Padding = UDim.new(0, 5)

-- ПОЛЕ ВВОДА
local messageBox = Instance.new("TextBox", chatFrame)
messageBox.Size = UDim2.new(1, -10, 0, 35)
messageBox.Position = UDim2.new(0, 5, 1, -40)
messageBox.PlaceholderText = "Введите сообщение..."
messageBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
messageBox.BackgroundTransparency = 0.4
messageBox.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", messageBox)

-- Функция отрисовки сообщений
local function renderMessages(data)
	messagesFrame:ClearAllChildren()
	Instance.new("UIListLayout", messagesFrame).Padding = UDim.new(0, 5)
	
	for _, msg in pairs(data) do
		local frame = Instance.new("Frame", messagesFrame)
		frame.Size = UDim2.new(1, 0, 0, 40)
		frame.BackgroundTransparency = 1

		local name = Instance.new("TextLabel", frame)
		name.Text = msg.user .. " [" .. msg.time .. "]:"
		name.TextColor3 = Color3.fromRGB(0, 100, 0) -- ТЕМНО-ЗЕЛЕНЫЙ
		name.TextSize = 12
		name.Font = Enum.Font.GothamBold
		name.Size = UDim2.new(1, 0, 0, 15)
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.BackgroundTransparency = 1

		local text = Instance.new("TextLabel", frame)
		text.Text = msg.text
		text.Position = UDim2.new(0, 0, 0, 18) -- СДВИГ НИЖЕ
		text.Size = UDim2.new(1, 0, 0, 20)
		text.TextColor3 = Color3.new(1, 1, 1)
		text.TextSize = 14
		text.BackgroundTransparency = 1
		text.TextWrapped = true
		text.TextXAlignment = Enum.TextXAlignment.Left
	end
	messagesFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end

-- РАБОТА С API
local function refresh()
	local req = request({ Url = API_URL, Method = "GET" })
	if req.Success then
		renderMessages(HttpService:JSONDecode(req.Body))
	end
end

local function send(txt)
	request({
		Url = API_URL,
		Method = "POST",
		Headers = {["Content-Type"] = "application/json"},
		Body = HttpService:JSONEncode({user = player.Name, text = txt})
	})
	refresh()
end

-- Кнопка скрыть/показать
toggleButton.MouseButton1Click:Connect(function()
	chatFrame.Visible = not chatFrame.Visible
end)

-- Отправка по Enter
messageBox.FocusLost:Connect(function(enter)
	if enter and messageBox.Text ~= "" then
		send(messageBox.Text)
		messageBox.Text = ""
	end
end)

-- Авто-обновление раз в 3 секунды
task.spawn(function()
	while true do
		refresh()
		task.wait(3)
	end
end)
