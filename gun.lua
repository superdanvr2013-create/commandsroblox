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
Frame.Size = UDim2.new(0, 300, 0, 600)
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

-- Заголовок
local title = Instance.new("TextLabel")
title.Parent = Frame
title.Text = "ELITEX SCAN & CLONE"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
title.TextColor3 = Color3.fromRGB(0, 255, 127)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
Instance.new("UICorner", title)

-------------------------------------------------------------------
-- СЕКЦИЯ 1: СКАНЕР
-------------------------------------------------------------------
local scanLabel = Instance.new("TextLabel", Frame)
scanLabel.Text = "-- SCANNER --"
scanLabel.Position = UDim2.new(0, 0, 0.06, 0)
scanLabel.Size = UDim2.new(1, 0, 0, 20)
scanLabel.BackgroundTransparency = 1
scanLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
scanLabel.Font = Enum.Font.Code
scanLabel.TextSize = 12

local radiusBox = Instance.new("TextBox", Frame)
radiusBox.PlaceholderText = "Radius (10)"
radiusBox.Text = "10"
radiusBox.Position = UDim2.new(0.05, 0, 0.11, 0)
radiusBox.Size = UDim2.new(0.9, 0, 0, 25)
radiusBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
radiusBox.TextColor3 = Color3.fromRGB(0, 200, 255)
radiusBox.Font = Enum.Font.Code
radiusBox.TextSize = 12
Instance.new("UICorner", radiusBox)

local scanBtn = Instance.new("TextButton", Frame)
scanBtn.Text = "SCAN AREA"
scanBtn.Position = UDim2.new(0.05, 0, 0.17, 0)
scanBtn.Size = UDim2.new(0.9, 0, 0, 30)
scanBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
scanBtn.TextColor3 = Color3.new(1, 1, 1)
scanBtn.Font = Enum.Font.GothamBold
scanBtn.TextSize = 12
Instance.new("UICorner", scanBtn)

-------------------------------------------------------------------
-- СЕКЦИЯ 2: УПРАВЛЕНИЕ ОБЪЕКТОМ
-------------------------------------------------------------------
local tpLabel = Instance.new("TextLabel", Frame)
tpLabel.Text = "-- OBJECT CONTROL --"
tpLabel.Position = UDim2.new(0, 0, 0.24, 0)
tpLabel.Size = UDim2.new(1, 0, 0, 20)
tpLabel.BackgroundTransparency = 1
tpLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
tpLabel.Font = Enum.Font.Code
tpLabel.TextSize = 12

-- Путь к объекту
local objectPathBox = Instance.new("TextBox", Frame)
objectPathBox.PlaceholderText = "Path: Name or Folder > Name"
objectPathBox.Text = ""
objectPathBox.Position = UDim2.new(0.05, 0, 0.32, 0)
objectPathBox.Size = UDim2.new(0.9, 0, 0, 30)
objectPathBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
objectPathBox.TextColor3 = Color3.fromRGB(255, 255, 0)
objectPathBox.Font = Enum.Font.Code
objectPathBox.TextSize = 10
objectPathBox.ClearTextOnFocus = false
Instance.new("UICorner", objectPathBox)

-- Координаты
local targetPosBox = Instance.new("TextBox", Frame)
targetPosBox.PlaceholderText = "X, Y, Z"
targetPosBox.Text = ""
targetPosBox.Position = UDim2.new(0.05, 0, 0.42, 0)
targetPosBox.Size = UDim2.new(0.55, 0, 0, 30)
targetPosBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
targetPosBox.TextColor3 = Color3.fromRGB(0, 255, 0)
targetPosBox.Font = Enum.Font.Code
targetPosBox.TextSize = 11
targetPosBox.ClearTextOnFocus = false
Instance.new("UICorner", targetPosBox)

local getPosBtn = Instance.new("TextButton", Frame)
getPosBtn.Text = "GET MY POS"
getPosBtn.Position = UDim2.new(0.65, 0, 0.42, 0)
getPosBtn.Size = UDim2.new(0.3, 0, 0, 30)
getPosBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
getPosBtn.TextColor3 = Color3.new(1, 1, 1)
getPosBtn.Font = Enum.Font.GothamBold
getPosBtn.TextSize = 9
Instance.new("UICorner", getPosBtn)

-- КНОПКИ ДЕЙСТВИЯ (Уменьшены для размещения в ряд)
local tpBtn = Instance.new("TextButton", Frame)
tpBtn.Text = "TELEPORT"
tpBtn.Position = UDim2.new(0.05, 0, 0.49, 0)
tpBtn.Size = UDim2.new(0.43, 0, 0, 35)
tpBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
tpBtn.TextColor3 = Color3.new(1, 1, 1)
tpBtn.Font = Enum.Font.GothamBold
tpBtn.TextSize = 11
Instance.new("UICorner", tpBtn)

local cloneBtn = Instance.new("TextButton", Frame)
cloneBtn.Text = "CLONE"
cloneBtn.Position = UDim2.new(0.52, 0, 0.49, 0)
cloneBtn.Size = UDim2.new(0.43, 0, 0, 35)
cloneBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
cloneBtn.TextColor3 = Color3.new(1, 1, 1)
cloneBtn.Font = Enum.Font.GothamBold
cloneBtn.TextSize = 11
Instance.new("UICorner", cloneBtn)

-------------------------------------------------------------------
-- ЛОГИ (ВЫВОД)
-------------------------------------------------------------------
local scroll = Instance.new("ScrollingFrame", Frame)
scroll.Position = UDim2.new(0.05, 0, 0.57, 0)
scroll.Size = UDim2.new(0.9, 0, 0.41, 0)
scroll.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
scroll.ScrollBarThickness = 4
Instance.new("UICorner", scroll)

local outputBox = Instance.new("TextBox", scroll)
outputBox.Size = UDim2.new(1, 0, 1, 0)
outputBox.BackgroundTransparency = 1
outputBox.TextColor3 = Color3.new(1, 1, 1)
outputBox.TextSize = 10
outputBox.Font = Enum.Font.Code
outputBox.TextXAlignment = Enum.TextXAlignment.Left
outputBox.TextYAlignment = Enum.TextYAlignment.Top
outputBox.MultiLine = true
outputBox.TextEditable = false
outputBox.Text = "Ready..."

local closeBtn = Instance.new("TextButton", Frame)
closeBtn.Text = "X"
closeBtn.Position = UDim2.new(0.9, 0, 0, 0)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.MouseButton1Click:Connect(function() main:Destroy() end)

-------------------------------------------------------------------
-- ЛОГИКА
-------------------------------------------------------------------

local function log(text)
    outputBox.Text = "[" .. os.date("%X") .. "] " .. text .. "\n" .. outputBox.Text
end

-- Универсальный поиск: по полному пути или просто по имени
local function findObject(pathStr)
    pathStr = pathStr:match("^%s*(.-)%s*$")
    if pathStr == "" then return nil, "Path empty" end

    -- Сначала пробуем найти как прямой путь через сегменты >
    local segments = {}
    for segment in string.gmatch(pathStr, "[^>]+") do
        table.insert(segments, segment:match("^%s*(.-)%s*$"))
    end

    if #segments > 1 then
        local currentObj = workspace
        for i, name in ipairs(segments) do
            if i == 1 and name:lower() == "workspace" then
                currentObj = workspace
            else
                local nextObj = currentObj:FindFirstChild(name)
                if not nextObj then return nil, "Path failed at: " .. name end
                currentObj = nextObj
            end
        end
        return currentObj, "Found by path"
    else
        -- Если пути нет, ищем рекурсивно по всему Workspace по имени
        local found = workspace:FindFirstChild(pathStr, true)
        if found then return found, "Found by name" end
    end

    return nil, "Not found"
end

local function getTargetCFrame()
    local x, y, z = targetPosBox.Text:match("([%d%.%-]+)%s*[,%s]%s*([%d%.%-]+)%s*[,%s]%s*([%d%.%-]+)")
    if x and y and z then
        return CFrame.new(tonumber(x), tonumber(y), tonumber(z))
    end
    return nil
end

-- Логика SCANNER
scanBtn.MouseButton1Click:Connect(function()
    local root = speaker.Character and speaker.Character:FindFirstChild("HumanoidRootPart")
    if not root then log("Error: No Character") return end
    
    local radius = tonumber(radiusBox.Text) or 10
    local found = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Position - root.Position).Magnitude <= radius then
            table.insert(found, string.format("%.1f | %s", (obj.Position - root.Position).Magnitude, obj.Name))
        end
    end
    outputBox.Text = "Found:\n" .. table.concat(found, "\n")
end)

-- Логика GET POS
getPosBtn.MouseButton1Click:Connect(function()
    local root = speaker.Character and speaker.Character:FindFirstChild("HumanoidRootPart")
    if root then
        targetPosBox.Text = string.format("%.1f, %.1f, %.1f", root.Position.X, root.Position.Y, root.Position.Z)
        log("Position saved.")
    end
end)

-- Логика TELEPORT
tpBtn.MouseButton1Click:Connect(function()
    local cf = getTargetCFrame()
    if not cf then log("Error: Invalid Pos!") return end
    
    local obj, msg = findObject(objectPathBox.Text)
    if obj then
        if obj:IsA("Model") then obj:PivotTo(cf) else obj.CFrame = cf end
        log("Teleported: " .. obj.Name)
    else
        log("Error: " .. msg)
    end
end)

-- Логика CLONE (НОВАЯ ФУНКЦИЯ)
cloneBtn.MouseButton1Click:Connect(function()
    local cf = getTargetCFrame()
    if not cf then log("Error: Invalid Pos for Clone!") return end
    
    local obj, msg = findObject(objectPathBox.Text)
    if obj then
        -- Проверка возможности клонирования (Archivable)
        local oldArchivable = obj.Archivable
        obj.Archivable = true
        
        local newObj = obj:Clone()
        if newObj then
            newObj.Parent = obj.Parent
            if newObj:IsA("Model") then
                newObj:PivotTo(cf)
            else
                newObj.CFrame = cf
            end
            log("Cloned: " .. newObj.Name)
        else
            log("Error: Could not clone (Locked?)")
        end
        
        obj.Archivable = oldArchivable
    else
        log("Error: " .. msg)
    end
end)
