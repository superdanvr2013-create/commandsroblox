-- === EliteX Lite — Full Original + Instant Purchase + Magnet to Player ===
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local speaker = Players.LocalPlayer
local main = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")

-- Настройки
local espActive = false
local levitatingCtrl = false
local levitatingToggle = false
local isAnchored = false
local boostActive = false
local xrayActive = false
local detachLowerTorsoActive = false
local animationsActive = true
local camAimEnabled = false
local instantPurchaseActive = false

-- Левитация
local levitatePart = nil

-- Оригинальные настройки персонажа
local originalSpeed = 16
local originalJump = 50

-- Xray
local originalTransparencies = {}
local xrayParts = {}
local xrayRadius = 30

-- Teleport
local teleportButton = nil
local teleportFrame = nil
local isSomeoneActive = false

-- Detach LowerTorso
local detachedLowerClone = nil
local detachedControlPart = nil
local gyro = nil
local velocityCtrl = nil
local LOWER_PARTS = {
    "LowerTorso", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
    "RightUpperLeg", "RightLowerLeg", "RightFoot"
}

-- === MAGNET TO PLAYER ===
local magnetConnection = nil
local magnetTarget = nil
local magnetEnabled = false

-- ==================== ФУНКЦИИ ====================

local function cloneLowerBody(char)
    if not char then return nil end
    local cloneModel = Instance.new("Model")
    cloneModel.Name = "DetachedLowerClone"
    local originalToClone = {}
    for _, partName in ipairs(LOWER_PARTS) do
        local originalPart = char:FindFirstChild(partName)
        if originalPart then
            local clonedPart = originalPart:Clone()
            clonedPart.CanCollide = true
            clonedPart.Transparency = 0
            clonedPart.Parent = cloneModel
            originalToClone[originalPart] = clonedPart
        end
    end
    for _, joint in pairs(cloneModel:GetDescendants()) do
        if joint:IsA("Motor6D") or joint:IsA("Weld") then
            if originalToClone[joint.Part0] then joint.Part0 = originalToClone[joint.Part0] end
            if originalToClone[joint.Part1] then joint.Part1 = originalToClone[joint.Part1] end
        end
    end
    cloneModel.PrimaryPart = cloneModel:FindFirstChild("LowerTorso")
    cloneModel.Parent = workspace
    return cloneModel
end

local function hideLowerBody(char)
    if not char then return end
    for _, partName in ipairs(LOWER_PARTS) do
        local part = char:FindFirstChild(partName)
        if part then
            part.Transparency = 1
            part.CanCollide = false
        end
    end
end

local function unhideLowerBody(char)
    if not char then return end
    for _, partName in ipairs(LOWER_PARTS) do
        local part = char:FindFirstChild(partName)
        if part then
            part.Transparency = 0
            part.CanCollide = true
        end
    end
end

local function findNearestPlayer()
    local char = speaker.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local closestPlayer = nil
    local closestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= speaker then
            local playerChar = player.Character
            local playerRoot = playerChar and playerChar:FindFirstChild("HumanoidRootPart")
            local humanoid = playerChar and playerChar:FindFirstChild("Humanoid")
            if playerRoot and humanoid and humanoid.Health > 0 then
                local distance = (playerRoot.Position - root.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer, closestDistance
end

-- ==================== MAGNET TO PLAYER ====================
local function toggleMagnet()
    magnetEnabled = not magnetEnabled

    if magnetEnabled then
        magnetTarget = findNearestPlayer()
        if not magnetTarget then
            magnetEnabled = false
            return
        end

        if magnetConnection then magnetConnection:Disconnect() end

        magnetConnection = RunService.Heartbeat:Connect(function()
            if not magnetEnabled or not magnetTarget or not magnetTarget.Character then
                toggleMagnet()
                return
            end

            local targetRoot = magnetTarget.Character:FindFirstChild("HumanoidRootPart")
            if not targetRoot then return end

            local desiredPosition = (targetRoot.CFrame * CFrame.new(0, 0.9, 2.4)).Position

            local direction = (desiredPosition - rootPart.Position)
            local distance = direction.Magnitude

            if distance > 1 then
                rootPart.Velocity = direction.Unit * math.min(distance * 13, 48)
            else
                rootPart.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    else
        if magnetConnection then
            magnetConnection:Disconnect()
            magnetConnection = nil
        end
        magnetTarget = nil
        if rootPart then rootPart.Velocity = Vector3.new(0, 0, 0) end
    end
end

local function teleportToNearest()
    local targetPlayer = findNearestPlayer()
    if targetPlayer and targetPlayer.Character then
        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local playerRoot = speaker.Character and speaker.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and playerRoot then
            local oldPos = playerRoot.Position
            local teleportCFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
            playerRoot.CFrame = teleportCFrame

            local beam = Instance.new("Part")
            beam.Size = Vector3.new(2, 2, 2)
            beam.Anchored = true
            beam.CanCollide = false
            beam.Transparency = 0.3
            beam.Color = Color3.fromRGB(0, 255, 255)
            beam.Material = Enum.Material.Neon
            beam.Position = oldPos
            beam.Parent = workspace

            local beam2 = Instance.new("Part")
            beam2.Size = Vector3.new(2, 2, 2)
            beam2.Anchored = true
            beam2.CanCollide = false
            beam2.Transparency = 0.3
            beam2.Color = Color3.fromRGB(255, 0, 255)
            beam2.Material = Enum.Material.Neon
            beam2.Position = teleportCFrame.Position
            beam2.Parent = workspace

            task.spawn(function()
                for i = 0.3, 1, 0.05 do
                    if beam and beam2 then
                        beam.Transparency = i
                        beam2.Transparency = i
                        beam.Size = beam.Size + Vector3.new(0.5, 0.5, 0.5)
                        beam2.Size = beam2.Size + Vector3.new(0.5, 0.5, 0.5)
                    end
                    task.wait(0.05)
                end
                if beam then beam:Destroy() end
                if beam2 then beam2:Destroy() end
            end)
            return true
        end
    end
    return false
end

local function toggleAnimations(enable)
    local char = speaker.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    if enable then
        local animator = humanoid:FindFirstChild("Animator")
        if not animator then
            local newAnimator = Instance.new("Animator")
            newAnimator.Parent = humanoid
        end
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        task.wait(0.1)
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
        task.wait(0.05)
        humanoid.WalkSpeed = originalSpeed
        humanoid.JumpPower = originalJump
    else
        local animator = humanoid:FindFirstChild("Animator")
        if animator then
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                track:Stop()
            end
            animator:Destroy()
        end
    end
end

local function detachLowerTorso()
    local char = speaker.Character
    if not char or detachedLowerClone then return end
    detachedLowerClone = cloneLowerBody(char)
    if not detachedLowerClone then return end
    hideLowerBody(char)
    detachedControlPart = detachedLowerClone:FindFirstChild("LowerTorso")
    if not detachedControlPart then return end

    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(0, 255, 255)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.3
    highlight.Adornee = detachedLowerClone
    highlight.Parent = detachedLowerClone

    gyro = Instance.new("BodyGyro")
    gyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    gyro.P = 2000
    gyro.D = 500
    gyro.Parent = detachedControlPart

    velocityCtrl = Instance.new("BodyVelocity")
    velocityCtrl.MaxForce = Vector3.new(400000, 400000, 400000)
    velocityCtrl.P = 2000
    velocityCtrl.Parent = detachedControlPart

    detachLowerTorsoActive = true
end

local function reattachLowerTorso()
    if not detachedLowerClone then return end
    if gyro then gyro:Destroy() gyro = nil end
    if velocityCtrl then velocityCtrl:Destroy() velocityCtrl = nil end
    detachedLowerClone:Destroy()
    detachedLowerClone = nil
    detachedControlPart = nil
    unhideLowerBody(speaker.Character)

    local humanoid = speaker.Character and speaker.Character:FindFirstChild("Humanoid")
    local root = speaker.Character and speaker.Character:FindFirstChild("HumanoidRootPart")
    if humanoid then
        humanoid.PlatformStand = true
        task.wait(0.05)
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        task.wait(0.1)
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
    if root then
        root.Velocity = Vector3.new()
        root.AssemblyLinearVelocity = Vector3.new()
        root.AssemblyAngularVelocity = Vector3.new()
    end
    detachLowerTorsoActive = false
end

local function updateDetachedControl()
    if not detachedControlPart or not detachLowerTorsoActive then return end
    local camera = workspace.CurrentCamera
    local cameraCFrame = camera.CFrame
    local moveDirection = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + cameraCFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - cameraCFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - cameraCFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + cameraCFrame.RightVector end
    if moveDirection.Magnitude > 0 then moveDirection = moveDirection.Unit end

    local speed = 50
    if velocityCtrl then velocityCtrl.Velocity = moveDirection * speed end
    if gyro then
        if moveDirection.Magnitude > 0 then
            gyro.CFrame = CFrame.lookAt(detachedControlPart.Position, detachedControlPart.Position + moveDirection)
        else
            gyro.CFrame = cameraCFrame
        end
    end
end

local function isNearPlayerButNotUnder(part)
    local char = speaker.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    local partPos = part.Position
    local playerPos = root.Position
    local distance = (partPos - playerPos).Magnitude
    local distanceY = playerPos.Y - partPos.Y
    local isUnderFeet = distanceY > 0 and distanceY < 5 and math.abs(partPos.X - playerPos.X) < 5 and math.abs(partPos.Z - playerPos.Z) < 5
    return distance <= xrayRadius and not isUnderFeet
end

local function applyXray()
    if xrayActive then
        for part, transparency in pairs(originalTransparencies) do
            if part and part.Parent then part.Transparency = transparency end
        end
        table.clear(originalTransparencies)
        table.clear(xrayParts)
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "LevitatePart" then
                local isNear = isNearPlayerButNotUnder(part)
                if isNear then
                    if not originalTransparencies[part] then
                        originalTransparencies[part] = part.Transparency
                    end
                    part.Transparency = 0.95
                    table.insert(xrayParts, part)
                end
            end
        end
    else
        for part, transparency in pairs(originalTransparencies) do
            if part and part.Parent then part.Transparency = transparency end
        end
        table.clear(originalTransparencies)
        table.clear(xrayParts)
    end
end

local function updateXray()
    if not xrayActive then return end
    local char = speaker.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "LevitatePart" then
            local distance = (part.Position - root.Position).Magnitude
            local isUnderFeet = false
            local distanceY = root.Position.Y - part.Position.Y
            if distanceY > 0 and distanceY < 5 and math.abs(part.Position.X - root.Position.X) < 5 and math.abs(part.Position.Z - root.Position.Z) < 5 then
                isUnderFeet = true
            end
            if distance <= xrayRadius and not isUnderFeet then
                if not originalTransparencies[part] then
                    originalTransparencies[part] = part.Transparency
                    part.Transparency = 0.95
                    table.insert(xrayParts, part)
                end
            elseif originalTransparencies[part] then
                part.Transparency = originalTransparencies[part]
                originalTransparencies[part] = nil
                for i, p in pairs(xrayParts) do
                    if p == part then
                        table.remove(xrayParts, i)
                        break
                    end
                end
            end
        end
    end
end

local function hasSomeoneText()
    local playerGui = speaker:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    local function searchGUI(parent)
        for _, child in pairs(parent:GetChildren()) do
            if (child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox")) and child.Text then
                if string.find(string.lower(child.Text), "someone") then return true end
            end
            if child:IsA("ScreenGui") or child:IsA("Frame") or child:IsA("ScrollingFrame") then
                if searchGUI(child) then return true end
            end
        end
        return false
    end
    return searchGUI(playerGui)
end

local function createTeleportButton()
    if teleportFrame then teleportFrame:Destroy() teleportFrame = nil teleportButton = nil end
    local nearestPlayer, distance = findNearestPlayer()
    local playerInfo = nearestPlayer and (nearestPlayer.Name .. " (" .. math.floor(distance) .. " стутней)") or "нет игроков рядом"

    teleportFrame = Instance.new("Frame")
    teleportFrame.Name = "TeleportFrame"
    teleportFrame.Parent = main
    teleportFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    teleportFrame.Position = UDim2.new(0.02, 0, 0.45, 0)
    teleportFrame.Size = UDim2.new(0, 240, 0, 85)
    teleportFrame.BackgroundTransparency = 0
    teleportFrame.ZIndex = 10
    teleportFrame.BorderSizePixel = 1
    teleportFrame.BorderColor3 = Color3.fromRGB(255, 100, 0)
    Instance.new("UICorner", teleportFrame).CornerRadius = UDim.new(0, 8)

    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Parent = teleportFrame
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.5
    shadow.Position = UDim2.new(0, 2, 0, 2)
    shadow.Size = UDim2.new(1, 0, 1, 0)
    shadow.ZIndex = 9
    shadow.BorderSizePixel = 0
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 8)

    local infoText = Instance.new("TextLabel")
    infoText.Parent = teleportFrame
    infoText.Text = "⚠️ ОБНАРУЖЕНО 'SOMEONE'!"
    infoText.Size = UDim2.new(1, 0, 0, 20)
    infoText.Position = UDim2.new(0, 0, 0, 5)
    infoText.BackgroundTransparency = 1
    infoText.TextColor3 = Color3.fromRGB(255, 100, 0)
    infoText.Font = Enum.Font.GothamBold
    infoText.TextSize = 14
    infoText.TextStrokeTransparency = 0.5
    infoText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    infoText.ZIndex = 11

    local targetText = Instance.new("TextLabel")
    targetText.Parent = teleportFrame
    targetText.Text = "🎯 Ближайший: " .. playerInfo
    targetText.Size = UDim2.new(1, 0, 0, 20)
    targetText.Position = UDim2.new(0, 0, 0, 25)
    targetText.BackgroundTransparency = 1
    targetText.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetText.Font = Enum.Font.GothamSemibold
    targetText.TextSize = 12
    targetText.TextStrokeTransparency = 0.5
    targetText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    targetText.ZIndex = 11

    local hotkeyText = Instance.new("TextLabel")
    hotkeyText.Parent = teleportFrame
    hotkeyText.Text = "⌨️ Нажмите Z для быстрой телепортации"
    hotkeyText.Size = UDim2.new(1, 0, 0, 15)
    hotkeyText.Position = UDim2.new(0, 0, 0, 45)
    hotkeyText.BackgroundTransparency = 1
    hotkeyText.TextColor3 = Color3.fromRGB(200, 200, 200)
    hotkeyText.Font = Enum.Font.Gotham
    hotkeyText.TextSize = 11
    hotkeyText.TextStrokeTransparency = 0.3
    hotkeyText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    hotkeyText.ZIndex = 11

    teleportButton = Instance.new("TextButton")
    teleportButton.Name = "TeleportBtn"
    teleportButton.Parent = teleportFrame
    teleportButton.Text = "🚀 ТЕЛЕПОРТИРОВАТЬСЯ"
    teleportButton.Position = UDim2.new(0.05, 0, 0, 60)
    teleportButton.Size = UDim2.new(0.9, 0, 0, 20)
    teleportButton.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    teleportButton.Font = Enum.Font.GothamSemibold
    teleportButton.TextColor3 = Color3.new(1, 1, 1)
    teleportButton.TextSize = 12
    teleportButton.ZIndex = 11
    teleportButton.BorderSizePixel = 0
    Instance.new("UICorner", teleportButton).CornerRadius = UDim.new(0, 6)

    teleportButton.MouseButton1Click:Connect(function()
        teleportToNearest()
    end)
end

local function checkForSomeoneGUI()
    local wasSomeone = false
    while true do
        if main and main.Parent then
            local hasSomeone = hasSomeoneText()
            if hasSomeone and not wasSomeone then
                createTeleportButton()
                isSomeoneActive = true
                wasSomeone = true
            elseif not hasSomeone and wasSomeone then
                if teleportFrame then
                    teleportFrame:Destroy()
                    teleportFrame = nil
                    teleportButton = nil
                end
                isSomeoneActive = false
                wasSomeone = false
            end
        end
        task.wait(0.5)
    end
end

local function trackNewGUI()
    local playerGui = speaker:WaitForChild("PlayerGui")
    playerGui.DescendantAdded:Connect(function(descendant)
        if (descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox")) and descendant.Text then
            if string.find(string.lower(descendant.Text), "someone") then
                task.wait(0.2)
                if not teleportFrame then
                    createTeleportButton()
                    isSomeoneActive = true
                end
            end
        end
    end)
end

local function isPurchasePrompt(prompt)
    if not prompt or processedPrompts[prompt] then return false end
    local actionText = (prompt.ActionText or ""):lower()
    local objectText = (prompt.ObjectText or ""):lower()
    return string.find(actionText, "purchase") or string.find(objectText, "purchase")
end

local function makePromptInstant(prompt)
    if not prompt or processedPrompts[prompt] then return end
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = 25
    processedPrompts[prompt] = true
end

local function toggleInstantPurchase()
    instantPurchaseActive = not instantPurchaseActive
end

local function createLevitatePart()
    if levitatePart then levitatePart:Destroy() levitatePart = nil end
    local char = speaker.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    levitatePart = Instance.new("Part")
    levitatePart.Name = "LevitatePart"
    levitatePart.Size = Vector3.new(6, 0.5, 6)
    levitatePart.Anchored = true
    levitatePart.CanCollide = true
    levitatePart.Transparency = 0.95
    levitatePart.Material = Enum.Material.SmoothPlastic
    levitatePart.Color = Color3.fromRGB(0, 0, 0)
    levitatePart.CFrame = root.CFrame * CFrame.new(0, -1.5, 0)
    levitatePart.Parent = workspace

    task.spawn(function()
        while levitatePart and (levitatingCtrl or levitatingToggle) do
            local char = speaker.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                levitatePart.CFrame = root.CFrame * CFrame.new(0, -1.5, 0)
            else
                break
            end
            task.wait(0.05)
        end
        if levitatePart then levitatePart:Destroy() levitatePart = nil end
    end)
end

local function stopLevitation()
    levitatingCtrl = false
    levitatingToggle = false
    if levitatePart then levitatePart:Destroy() levitatePart = nil end
end

local function applyBoost()
    local char = speaker.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum then
        if boostActive then
            hum.WalkSpeed = 30
            hum.JumpPower = 10
        else
            hum.WalkSpeed = originalSpeed
            hum.JumpPower = originalJump
        end
    end
end

local function saveOriginalSettings()
    local char = speaker.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum then
        originalSpeed = hum.WalkSpeed
        originalJump = hum.JumpPower
    end
end

local function updateCamAim()
    if not camAimEnabled then return end
    local char = speaker.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local closest = nil
    local minDist = 300
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= speaker and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            local dist = (hrp.Position - char.HumanoidRootPart.Position).Magnitude
            if dist < minDist then
                closest = hrp
                minDist = dist
            end
        end
    end
    if closest then
        local camera = workspace.CurrentCamera
        camera.CFrame = CFrame.lookAt(camera.CFrame.Position, closest.Position)
    end
end

-- ==================== GUI ====================
main.Name = "EliteX_Fly"
main.Parent = speaker:WaitForChild("PlayerGui")
main.ResetOnSpawn = false

Frame.Name = "MainFrame"
Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.Position = UDim2.new(0.02, 0, 0.02, 0)
Frame.Size = UDim2.new(0, 250, 0, 580)
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Parent = Frame
title.Text = "ELITEX — Lite + Magnet"
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
title.TextColor3 = Color3.fromRGB(0, 255, 127)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local function createBtn(name, text, y, color)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Text = text
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.BackgroundColor3 = color
    btn.Font = Enum.Font.GothamSemibold
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 12
    btn.Parent = Frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

-- Кнопки
local boostBtn = createBtn("BoostBtn", "SPEED & JUMP BOOST: OFF", 45, Color3.fromRGB(0, 150, 0))
local animBtn = createBtn("AnimBtn", "🎭 АНИМАЦИИ: ON", 85, Color3.fromRGB(100, 100, 255))
local detachBtn = createBtn("DetachBtn", "🦿 DETACH LOWER TORSO: OFF (Q)", 125, Color3.fromRGB(150, 0, 150))
local xrayBtn = createBtn("XrayBtn", "XRAY: OFF", 165, Color3.fromRGB(0, 100, 200))
local camAimBtn = createBtn("CamAimBtn", "🎯 AIM CAMERA: OFF", 205, Color3.fromRGB(180, 0, 180))
local purchaseBtn = createBtn("PurchaseBtn", "⚡ INSTANT PURCHASE: OFF", 245, Color3.fromRGB(180, 0, 180))
local espBtn = createBtn("EspBtn", "ESP: OFF", 285, Color3.fromRGB(80, 80, 80))
local levitationBtn = createBtn("LevitationBtn", "ЛЕВИТАЦИЯ: OFF", 325, Color3.fromRGB(120, 40, 200))
local anchorBtn = createBtn("AnchorBtn", "ANCHORED: OFF", 365, Color3.fromRGB(40, 40, 45))
local kickBtn = createBtn("KickBtn", "KICK", 405, Color3.fromRGB(255, 50, 50))
local magnetBtn = createBtn("MagnetBtn", "🧲 MAGNET TO PLAYER: OFF", 445, Color3.fromRGB(0, 120, 255))

-- Подключение кнопок
boostBtn.MouseButton1Click:Connect(function()
    boostActive = not boostActive
    boostBtn.Text = boostActive and "SPEED & JUMP BOOST: ON" or "SPEED & JUMP BOOST: OFF"
    boostBtn.BackgroundColor3 = boostActive and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(0, 150, 0)
    applyBoost()
end)

animBtn.MouseButton1Click:Connect(function()
    animationsActive = not animationsActive
    animBtn.Text = animationsActive and "🎭 АНИМАЦИИ: ON" or "🎭 АНИМАЦИИ: OFF"
    animBtn.BackgroundColor3 = animationsActive and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    toggleAnimations(animationsActive)
end)

detachBtn.MouseButton1Click:Connect(function()
    detachLowerTorsoActive = not detachLowerTorsoActive
    if detachLowerTorsoActive then
        detachBtn.Text = "🦿 DETACH LOWER TORSO: ON (Q)"
        detachBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
        detachLowerTorso()
    else
        detachBtn.Text = "🦿 DETACH LOWER TORSO: OFF (Q)"
        detachBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
        reattachLowerTorso()
    end
end)

xrayBtn.MouseButton1Click:Connect(function()
    xrayActive = not xrayActive
    xrayBtn.Text = xrayActive and "XRAY: ON" or "XRAY: OFF"
    xrayBtn.BackgroundColor3 = xrayActive and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(0, 100, 200)
    applyXray()
end)

camAimBtn.MouseButton1Click:Connect(function()
    camAimEnabled = not camAimEnabled
    camAimBtn.Text = camAimEnabled and "🎯 AIM CAMERA: ON" or "🎯 AIM CAMERA: OFF"
    camAimBtn.BackgroundColor3 = camAimEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(180, 0, 180)
end)

purchaseBtn.MouseButton1Click:Connect(function()
    toggleInstantPurchase()
    purchaseBtn.Text = instantPurchaseActive and "⚡ INSTANT PURCHASE: ON" or "⚡ INSTANT PURCHASE: OFF"
    purchaseBtn.BackgroundColor3 = instantPurchaseActive and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(180, 0, 180)
end)

espBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    espBtn.Text = espActive and "ESP: ON" or "ESP: OFF"
    espBtn.BackgroundColor3 = espActive and Color3.fromRGB(255, 80, 0) or Color3.fromRGB(80, 80, 80)
    if espActive then
        for _, part in pairs(ESPParts or {}) do if part and part.Parent then part:Destroy() end end
        ESPParts = {}
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= speaker and player.Character then
                local highlight = Instance.new("Highlight")
                highlight.Name = "EliteX_ESP"
                highlight.FillColor = Color3.fromRGB(255, 100, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.4
                highlight.Adornee = player.Character
                highlight.Parent = player.Character
                table.insert(ESPParts, highlight)
            end
        end
    else
        for _, part in pairs(ESPParts or {}) do if part and part.Parent then part:Destroy() end end
        ESPParts = {}
    end
end)

levitationBtn.MouseButton1Click:Connect(function()
    levitatingToggle = not levitatingToggle
    levitationBtn.Text = levitatingToggle and "ЛЕВИТАЦИЯ: ON" or "ЛЕВИТАЦИЯ: OFF"
    levitationBtn.BackgroundColor3 = levitatingToggle and Color3.fromRGB(255, 150, 0) or Color3.fromRGB(120, 40, 200)
    if levitatingToggle or levitatingCtrl then
        if not levitatePart then createLevitatePart() end
    else
        stopLevitation()
    end
end)

anchorBtn.MouseButton1Click:Connect(function()
    isAnchored = not isAnchored
    anchorBtn.Text = isAnchored and "ANCHORED: ON" or "ANCHORED: OFF"
    anchorBtn.BackgroundColor3 = isAnchored and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(40, 40, 45)
    local char = speaker.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then root.Anchored = isAnchored end
end)

kickBtn.MouseButton1Click:Connect(function()
    game:Shutdown()
end)

magnetBtn.MouseButton1Click:Connect(toggleMagnet)

-- Обработчик клавиш
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Z then
        if isSomeoneActive and teleportFrame and teleportFrame.Parent then
            if teleportButton then
                local originalColor = teleportButton.BackgroundColor3
                teleportButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
                task.spawn(function()
                    task.wait(0.1)
                    if teleportButton then teleportButton.BackgroundColor3 = originalColor end
                end)
            end
            teleportToNearest()
        end
    end
    if input.KeyCode == Enum.KeyCode.Q then
        detachLowerTorsoActive = not detachLowerTorsoActive
        if detachLowerTorsoActive then
            if detachBtn then
                detachBtn.Text = "🦿 DETACH LOWER TORSO: ON (Q)"
                detachBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
            end
            detachLowerTorso()
        else
            if detachBtn then
                detachBtn.Text = "🦿 DETACH LOWER TORSO: OFF (Q)"
                detachBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
            end
            reattachLowerTorso()
        end
    end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        levitatingCtrl = true
        if not levitatePart then createLevitatePart() end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        levitatingCtrl = false
        if not levitatingToggle and levitatePart then levitatePart:Destroy() levitatePart = nil end
    end
end)

-- LOOP
local ESPParts = {}
RunService.Stepped:Connect(function()
    local char = speaker.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")

    if root and isAnchored then root.Anchored = true end
    if hum and boostActive then
        hum.WalkSpeed = 30
        hum.JumpPower = 10
    end
    if xrayActive then updateXray() end
    if detachLowerTorsoActive then updateDetachedControl() end
    if camAimEnabled then updateCamAim() end
end)

-- Instant Purchase
ProximityPromptService.PromptShown:Connect(function(prompt)
    if instantPurchaseActive and isPurchasePrompt(prompt) then
        makePromptInstant(prompt)
    end
end)

speaker.CharacterAdded:Connect(function()
    task.wait(0.5)
    saveOriginalSettings()
    if boostActive then applyBoost() end
    if xrayActive then applyXray() end
    if animationsActive then toggleAnimations(true) else toggleAnimations(false) end
    if detachLowerTorsoActive then
        detachLowerTorsoActive = false
        if detachBtn then
            detachBtn.Text = "🦿 DETACH LOWER TORSO: OFF (Q)"
            detachBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
        end
        reattachLowerTorso()
    end
end)

if speaker.Character then saveOriginalSettings() end

-- ЗАКРЫТИЕ
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "❌"
closeBtn.Position = UDim2.new(0.92, 0, 0, 5)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = Frame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
    stopLevitation()
    if xrayActive then xrayActive = false applyXray() end
    if detachLowerTorsoActive then reattachLowerTorso() end
    if magnetEnabled then toggleMagnet() end
    if not animationsActive then toggleAnimations(true) end
    camAimEnabled = false
    instantPurchaseActive = false
    main:Destroy()
end)

task.spawn(checkForSomeoneGUI)
task.spawn(trackNewGUI)

print("EliteX Lite загружен с Magnet to player")
