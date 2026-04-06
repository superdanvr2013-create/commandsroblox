local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local player = Players.LocalPlayer

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- НАХОДИМ ВСЕ ProximityPrompt "Steal"
local function findStealPrompts()
    local prompts = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.ActionText:lower():find("steal") then
            prompts[#prompts + 1] = obj.Parent  -- Родитель (brainrot)
            print("Найден brainrot:", obj.Parent.Name, "в позиции", obj.Parent.Position)
        end
    end
    return prompts
end

-- Бежим к ближайшему
local function goToNearestBrainrot()
    local brainrots = findStealPrompts()
    if #brainrots == 0 then 
        print("Brainrot не найден!")
        return 
    end
    
    local closest = nil
    local minDist = math.huge
    
    for _, brainrot in pairs(brainrots) do
        if brainrot:IsA("BasePart") and brainrot.Position then
            local dist = (rootPart.Position - brainrot.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closest = brainrot
            end
        end
    end
    
    if closest then
        print("Бежим к brainrot на расстоянии", minDist)
        
        -- Pathfinding (умный путь)
        local path = PathfindingService:CreatePath({
            AgentRadius = 3,
            AgentHeight = 6,
            AgentCanJump = true
        })
        
        path:ComputeAsync(rootPart.Position, closest.Position)
        local waypoints = path:GetWaypoints()
        
        for _, waypoint in pairs(waypoints) do
            humanoid:MoveTo(waypoint.Position)
            humanoid.MoveToFinished:Wait()
        end
        
        print("Дошли до brainrot! Interact...")
        -- Авто interact (если есть)
        fireproximityprompt(closest:FindFirstChildOfClass("ProximityPrompt"))
    end
end

-- HOTKEY E = Auto Steal
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then
        goToNearestBrainrot()
    end
end)

print("✅ Auto Steal готов! Нажми E - побежит к ближайшему brainrot.")
