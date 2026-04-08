-- Steal a Brainrot CFrame Speed (No WalkSpeed Change, AntiCheat Safe)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local enabled = false
local speedMultiplier = 3  -- 2=быстро, 5=супер (не переборщи, античит)

-- CFrame Speed Loop (по MoveDirection)
RunService.Heartbeat:Connect(function(dt)
    if enabled and humanoid.MoveDirection.Magnitude > 0 then
        local moveVector = humanoid.MoveDirection * speedMultiplier * 16 * dt  -- 16=default speed
        rootPart.CFrame = rootPart.CFrame + rootPart.CFrame.LookVector * moveVector.Z + rootPart.CFrame.RightVector * moveVector.X
    end
end)

-- Toggle
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.R then
        enabled = not enabled
        print("CFrame Speed: " .. (enabled and "ON (x" .. speedMultiplier .. ")" or "OFF"))
    end
end)

print("✅ CFrame Speed готов! R=ON. Двигайся WASD — лети вперед без WalkSpeed!")
