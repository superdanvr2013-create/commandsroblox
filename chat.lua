local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local API_URL = "https://asvego.ru/roblox/chat.php"
local TOKEN = "d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4"

local sessionId = game.JobId ~= "" and game.JobId or "STUDIO_" .. player.UserId

-- UI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false
screenGui.Name = "XenoChatUI"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 350)
frame.Position = UDim2.new(0, 20, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true -- Можно двигать по экрану

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -10, 1, -70)
scroll.Position = UDim2.new(0, 5, 0, 30)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollBarThickness = 4
local layout = Instance.new("UIListLayout", scroll)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(1, -70, 0, 30)
input.Position = UDim2.new(0, 5, 1, -35)
input.PlaceholderText = "Напиши сообщение..."
input.Text = ""

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0, 60, 0, 30)
btn.Position = UDim2.new(1, -65, 1, -35)
btn.Text = "Send"
btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)

local function addMessage(txt)
	local lbl = Instance.new("TextLabel", scroll)
	lbl.Size = UDim2.new(1, -5, 0, 20)
	lbl.Text = " " .. txt
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.BackgroundTransparency = 1
	lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    -- Авто-скролл вниз
    scroll.CanvasPosition = Vector2.new(0, 9999)
end

local function apiCall(msg)
    local httpRequest = (syn and syn.request) or (http and http.request) or request
    if not httpRequest then return end

    local isPolling = (msg == "")
    
    -- Используем defer для моментального освобождения основного потока
    task.defer(function()
        local payload = {
            userid = player.UserId,
            username = tostring(player.Name),
            sessionid = tostring(sessionId),
            Question = isPolling and "POLLING" or tostring(msg),
            Recipient = "GlobalChat"
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
            if response.StatusCode == 200 then
                local res = HttpService:JSONDecode(response.Body)
                if res.status == "success" and res.data then
                    for _, text in ipairs(res.data) do
                        addMessage(text)
                    end
                end
            else
                warn("[Xeno] Server Error: " .. response.StatusCode .. " | " .. response.Body)
            end
        else
            warn("[Xeno] Connection Failed: " .. tostring(response))
        end
    end)
end

-- Отправка
btn.MouseButton1Click:Connect(function()
    local text = input.Text
    if text ~= "" then
        addMessage(player.Name .. ": " .. text) -- Свое сообщение локально
        apiCall(text)
        input.Text = ""
    end
end)

-- Поллинг (каждые 3 секунды)
task.spawn(function()
    warn("[Xeno] Chat Started. Session: " .. sessionId)
	while true do
		apiCall("") 
		task.wait(3)
	end
end)
