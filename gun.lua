-- Сервисы
local Players = game:GetService("Players")
local speaker = Players.LocalPlayer

-- Создание GUI
local main = Instance.new("ScreenGui")
main.Name = "EliteX_Scanner_Teleporter"
main.Parent = speaker:WaitForChild("PlayerGui")
main.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.Position = UDim2.new(0.5, -150, 0.5, -300)
Frame.Size = UDim2.new(0, 300, 0, 630) -- Увеличил высоту для новой кнопки
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

-- Заголовок
local title = Instance.new("TextLabel", Frame)
title.Text = "ELITEX SCAN & DUPE"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
title.TextColor3 = Color3.fromRGB(0, 255, 127)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
Instance.new("UICorner", title)

-------------------------------------------------------------------
-- ИНТЕРФЕЙС УПРАВЛЕНИЯ
-------------------------------------------------------------------

-- Поле пути (Obj Path)
local objectPathBox = Instance.new("TextBox", Frame)
objectPathBox.PlaceholderText = "Obj Path (Name or Folder > Name)"
objectPathBox.Position = UDim2.new(0.05, 0, 0.28, 0)
objectPathBox.Size = UDim2.new(0.9, 0, 0, 30)
objectPathBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
objectPathBox.TextColor3 = Color3.fromRGB(255, 255, 0)
objectPathBox.Font = Enum.Font.Code
objectPathBox.TextSize = 10
Instance.new("UICorner", objectPathBox)

-- Поле координат (Target Pos)
local targetPosBox = Instance.new("TextBox", Frame)
targetPosBox.PlaceholderText = "X, Y, Z"
targetPosBox.Position = UDim2.new(0.05, 0, 0.35, 0)
targetPosBox.Size = UDim2.new(0.55, 0, 0, 30)
targetPosBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
targetPosBox.TextColor3 = Color3.fromRGB(0, 255, 0)
targetPosBox.Font = Enum.Font.Code
targetPosBox.TextSize = 11
Instance.new("UICorner", targetPosBox)

local getPosBtn = Instance.new("TextButton", Frame)
getPosBtn.Text = "GET POS"
getPosBtn.Position = UDim2.new(0.65, 0, 0.35, 0)
getPosBtn.Size = UDim2.new(0.3, 0, 0, 30)
getPosBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
getPosBtn.TextColor3 = Color3.new(1, 1, 1)
getPosBtn.Font = Enum.Font.GothamBold
getPosBtn.TextSize = 9
Instance.new("UICorner", getPosBtn)

-- Кнопки действий (В один ряд)
local tpBtn = Instance.new("TextButton", Frame)
tpBtn.Text = "TELEPORT"
tpBtn.Position = UDim2.new(0.05, 0, 0.42, 0)
tpBtn.Size = UDim2.new(0.43, 0, 0, 35)
tpBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
tpBtn.TextColor3 = Color3.new(1, 1, 1)
tpBtn.Font = Enum.Font.GothamBold
tpBtn.TextSize = 11
Instance.new("UICorner", tpBtn)

local cloneBtn = Instance.new("TextButton", Frame)
cloneBtn.Text = "CLONE OBJ"
cloneBtn.Position = UDim2.new(0.52, 0, 0.42, 0)
cloneBtn.Size = UDim2.new(0.43, 0, 0, 35)
cloneBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
cloneBtn.TextColor3 = Color3.new(1, 1, 1)
cloneBtn.Font = Enum.Font.GothamBold
cloneBtn.TextSize = 11
Instance.new("UICorner", cloneBtn)

-- КНОПКА ДУБЛИРОВАНИЯ ИНСТРУМЕНТА
local dupeToolBtn = Instance.new("TextButton", Frame)
dupeToolBtn.Text = "DUPLICATE ALL SEEING SENTRY"
dupeToolBtn.Position = UDim2.new(0.05, 0, 0.49, 0)
dupeToolBtn.Size = UDim2.new(0.9, 0, 0, 35)
dupeToolBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
dupeToolBtn.TextColor3 = Color3.new(1, 1, 1)
dupeToolBtn.Font = Enum.Font.GothamBold
dupeToolBtn.TextSize = 10
Instance.new("UICorner", dupeToolBtn)

-- Логи
local scroll = Instance.new("ScrollingFrame", Frame)
scroll.Position = UDim2.new(0.05, 0, 0.57, 0)
scroll.Size = UDim2.new(0.9, 0, 0.40, 0)
scroll.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
scroll.ScrollBarThickness = 4
Instance.new("UICorner", scroll)

local outputBox = Instance.new("TextBox", scroll)
outputBox.Size = UDim2.new(1, 0, 1, 0)
outputBox.BackgroundTransparency = 1
outputBox.TextColor3 = Color3.new(1, 1, 1)
outputBox.TextSize = 10
outputBox.Font = Enum.Font.Code
outputBox.MultiLine = true
outputBox.TextEditable = false
outputBox.Text = "System Loaded..."

-------------------------------------------------------------------
-- ЛОГИКА
-------------------------------------------------------------------

local function log(text)
    outputBox.Text = "[" .. os.date("%X") .. "] " .. text .. "\n" .. outputBox.Text
end

-- Поиск объекта
local function findObject(pathStr)
    pathStr = pathStr:match("^%s*(.-)%s*$")
    if pathStr == "" then return nil end
    local segments = {}
    for segment in string.gmatch(pathStr, "[^>]+") do
        table.insert(segments, segment:match("^%s*(.-)%s*$"))
    end
    if #segments > 1 then
        local cur = workspace
        for _, name in ipairs(segments) do
            local n = cur:FindFirstChild(name)
            if not n then return nil end
            cur = n
        end
        return cur
    end
    return workspace:FindFirstChild(pathStr, true)
end

-- Дублирование инструмента
dupeToolBtn.MouseButton1Click:Connect(function()
    local toolName = "All Seeing Sentry"
    local backpack = speaker:FindFirstChild("Backpack")
    local char = speaker.Character
    
    if not backpack then log("Error: Backpack not found") return end

    -- Ищем оригинал (в рюкзаке или в руках)
    local original = backpack:FindFirstChild(toolName) or (char and char:FindFirstChild(toolName))
    
    if original and original:IsA("Tool") then
        local clone = original:Clone()
        clone.Parent = backpack
        log("Success: " .. toolName .. " duplicated to Backpack!")
    else
        log("Error: " .. toolName .. " not found in inventory!")
    end
end)

-- Телепорт и Клон объекта (из предыдущего запроса)
local function getCF()
    local x,y,z = targetPosBox.Text:match("([%d%.%-]+)%s*[,%s]%s*([%d%.%-]+)%s*[,%s]%s*([%d%.%-]+)")
    return x and CFrame.new(tonumber(x), tonumber(y), tonumber(z))
end

tpBtn.MouseButton1Click:Connect(function()
    local cf = getCF()
    local obj = findObject(objectPathBox.Text)
    if obj and cf then
        if obj:IsA("Model") then obj:PivotTo(cf) else obj.CFrame = cf end
        log("Moved: " .. obj.Name)
    else log("Error: Obj or Pos missing") end
end)

cloneBtn.MouseButton1Click:Connect(function()
    local cf = getCF()
    local obj = findObject(objectPathBox.Text)
    if obj and cf then
        obj.Archivable = true
        local cl = obj:Clone()
        cl.Parent = obj.Parent
        if cl:IsA("Model") then cl:PivotTo(cf) else cl.CFrame = cf end
        log("Cloned: " .. obj.Name)
    else log("Error: Obj or Pos missing") end
end)

getPosBtn.MouseButton1Click:Connect(function()
    local root = speaker.Character and speaker.Character:FindFirstChild("HumanoidRootPart")
    if root then targetPosBox.Text = string.format("%.1f, %.1f, %.1f", root.Position.X, root.Position.Y, root.Position.Z) end
end)

local closeBtn = Instance.new("TextButton", Frame)
closeBtn.Text = "X"
closeBtn.Position = UDim2.new(0.9, 0, 0, 0)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.MouseButton1Click:Connect(function() main:Destroy() end)
