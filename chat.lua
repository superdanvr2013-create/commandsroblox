local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local API_URL = "https://asvego.ru/roblox/weirdstrictworldaidata.php"
local TOKEN = "d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4"

-- ИСПРАВЛЕНИЕ: Используем JobId напрямую как строку. 
-- Если мы в Студии (где JobId пустой), ставим метку "STUDIO"
local sessionId = game.JobId
if sessionId == "" then
	sessionId = "STUDIO_" .. player.UserId
end

-- UI Часть
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 350)
frame.Position = UDim2.new(0, 20, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 25)
title.Text = "Session: " .. string.sub(sessionId, 1, 8) .. "..." -- Показываем часть ID
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -10, 1, -70)
scroll.Position = UDim2.new(0, 5, 0, 30)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local layout = Instance.new("UIListLayout", scroll)

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(1, -70, 0, 30)
input.Position = UDim2.new(0, 5, 1, -35)
input.PlaceholderText = "Напиши что-нибудь..."
input.Text = ""

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0, 60, 0, 30)
btn.Position = UDim2.new(1, -65, 1, -35)
btn.Text = "Send"
btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)

local function addMessage(txt)
	local lbl = Instance.new("TextLabel", scroll)
	lbl.Size = UDim2.new(1, 0, 0, 20)
	lbl.Text = txt
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.BackgroundTransparency = 1
	lbl.TextXAlignment = Enum.TextXAlignment.Left
end

-- Определяем функцию запроса для Xeno
local httpRequest = (syn and syn.request) or (http and http.request) or request

local function apiCall(msg)
    if not httpRequest then 
        warn("Xeno request function not found!")
        return 
    end

    local payload = {
        userid = player.UserId,
        sessionid = tostring(sessionId),
        username = tostring(player.Name),
        message = tostring(msg)
    }

    local success, response = pcall(function()
        return httpRequest({
            Url = API_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. TOKEN
            },
            Body = HttpService:JSONEncode(payload)
        })
    end)

    if success and response then
        -- Если сервер вернул 400, выведем тело ответа, чтобы понять причину
        if response.StatusCode ~= 200 then
            warn("API Error " .. response.StatusCode .. ": " .. response.Body)
            return
        end

        local decodeSuccess, res = pcall(function() return HttpService:JSONDecode(response.Body) end)
        
        if decodeSuccess and res.status == "success" then
            if msg == "" and res.data then
                for _, text in ipairs(res.data) do
                    -- Добавляем сообщение в UI (функция addMessage должна быть в коде выше)
                    if addMessage then addMessage(text) end
                end
            elseif msg ~= "" then
                if addMessage then addMessage(res.username .. ": " .. res.message) end
            end
        end
    else
        warn("Critical Request Failure: " .. tostring(response))
    end
end

btn.MouseButton1Click:Connect(function()
	if input.Text ~= "" then
		apiCall(input.Text)
		input.Text = ""
	end
end)

-- Поллинг новых сообщений
task.spawn(function()
	while true do
		apiCall("") 
		task.wait(3)
	end
end)
