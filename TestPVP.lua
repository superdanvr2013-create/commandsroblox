local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 120)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🧠 Brainrot Duel Helper"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = frame

local btnSteal = Instance.new("TextButton")
btnSteal.Size = UDim2.new(0.45, 0, 0, 40)
btnSteal.Position = UDim2.new(0.05, 0, 0.35, 0)
btnSteal.Text = "Auto Steal"
btnSteal.BackgroundColor3 = Color3.new(0, 0.8, 0)
btnSteal.TextColor3 = Color3.new(1,1,1)
btnSteal.Font = Enum.Font.GothamBold
btnSteal.TextSize = 16
btnSteal.Parent = frame

local btnFreeze = Instance.new("TextButton")
btnFreeze.Size = UDim2.new(0.45, 0, 0, 40)
btnFreeze.Position = UDim2.new(0.5, 0, 0.35, 0)
btnFreeze.Text = "Freeze Enemy"
btnFreeze.BackgroundColor3 = Color3.new(0.8, 0, 0)
btnFreeze.TextColor3 = Color3.new(1,1,1)
btnFreeze.Font = Enum.Font.GothamBold
btnFreeze.TextSize = 16
btnFreeze.Parent = frame

-- НАХОДИМ REMOTES (стандарт Brainrot)
local function findRemote(namePart)
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and string.find(string.lower(v.Name), namePart) then
            return v
        end
    end
    return nil
end

local stealRemote = findRemote("steal") or findRemote("brain") or findRemote("collect")
local kickRemote = findRemote("kick")

-- Anti-Kick
if kickRemote then kickRemote:Destroy() end

-- Auto Steal Loop
local stealing = false
btnSteal.MouseButton1Click:Connect(function()
    stealing = not stealing
    btnSteal.Text = stealing and "Steal ON" or "Auto Steal"
    btnSteal.BackgroundColor3 = stealing and Color3.new(0,1,0) or Color3.new(0,0.8,0)
    
    spawn(function()
        while stealing do
            if stealRemote then
                stealRemote:FireServer()  -- Крадём brainrot
            end
            wait(0.1)  -- Не спам (античит)
        end
    end)
end)

-- Freeze Enemy (ближайший игрок)
btnFreeze.MouseButton1Click:Connect(function()
    local character = player.Character
    if not character then return end
    
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (character.HumanoidRootPart.Position - otherPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = otherPlayer
            end
        end
    end
    
    if closestPlayer and closestPlayer.Character then
        local enemyRoot = closestPlayer.Character.HumanoidRootPart
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Velocity = Vector3.new(0,0,0)
        bodyVelocity.Parent = enemyRoot
        
        -- Заморозка 10с
        game:GetService("Debris"):AddItem(bodyVelocity, 10)
        print("🧊 Enemy заморожен:", closestPlayer.Name)
    end
end)

print("✅ Brainrot Duel Helper готов! Auto Steal + Freeze.")
