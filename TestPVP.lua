local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Создаём GUI кнопку
local screenGui = Instance.new("ScreenGui")
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 200, 0, 50)
btn.Position = UDim2.new(0, 10, 0, 10)
btn.Text = "Локальная ходьба"
btn.Parent = screenGui
screenGui.Parent = playerGui

local walking = false
local humanoidRootPart = nil

btn.MouseButton1Click:Connect(function()
	walking = not walking
	btn.Text = walking and "Стоп" or "Локальная ходьба"

	local char = player.Character or player.CharacterAdded:Wait()
	humanoidRootPart = char:WaitForChild("HumanoidRootPart")

	if walking then
		spawn(function()
			while walking do
				-- Локальное движение (только вы видите)
				local tween = TweenService:Create(humanoidRootPart, TweenInfo.new(0.1), {CFrame = humanoidRootPart.CFrame + humanoidRootPart.CFrame.LookVector * 5})
				tween:Play()
				wait(0.1)
			end
		end)
	end
end)
