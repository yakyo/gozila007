-- LocalScript (dat trong StarterPlayer > StarterPlayerScripts)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local flying = false
local hoverConnection = nil
local bodyPosition = nil

-- ==================== UI ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SimpleFlyGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 120)
frame.Position = UDim2.new(0.5, -110, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.1
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.4, 0)
title.BackgroundTransparency = 1
title.Text = "FLY MODE"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0.85, 0, 0.45, 0)
toggle.Position = UDim2.new(0.075, 0, 0.5, 0)
toggle.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
toggle.Text = "OFF"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.TextScaled = true
toggle.Font = Enum.Font.GothamSemibold
toggle.Parent = frame

Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 12)

-- ==================== Fly Logic ====================
local HOVER_HEIGHT = 80  -- Do cao bay lên (co the chỉnh)

local function startFlying()
	if bodyPosition then bodyPosition:Destroy() end
	
	-- Bay lên mượt mà
	local targetCFrame = root.CFrame * CFrame.new(0, HOVER_HEIGHT, 0)
	
	local tween = TweenService:Create(root, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = targetCFrame
	})
	tween:Play()
	tween.Completed:Wait()
	
	-- Giữ đứng yên chắc chắn
	bodyPosition = Instance.new("BodyPosition")
	bodyPosition.Name = "FlyPosition"
	bodyPosition.MaxForce = Vector3.new(40000, 40000, 40000)
	bodyPosition.Position = root.Position
	bodyPosition.Parent = root
	
	humanoid.PlatformStand = true
	
	-- Cập nhật liên tục để giữ vị trí
	hoverConnection = RunService.Heartbeat:Connect(function()
		if bodyPosition and root then
			bodyPosition.Position = Vector3.new(root.Position.X, targetCFrame.Position.Y, root.Position.Z)
		end
	end)
end

local function stopFlying()
	if hoverConnection then
		hoverConnection:Disconnect()
		hoverConnection = nil
	end
	if bodyPosition then
		bodyPosition:Destroy()
		bodyPosition = nil
	end
	humanoid.PlatformStand = false
end

-- ==================== Toggle ====================
toggle.MouseButton1Click:Connect(function()
	flying = not flying
	
	if flying then
		toggle.BackgroundColor3 = Color3.fromRGB(40, 200, 40)
		toggle.Text = "ON"
		startFlying()
	else
		toggle.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
		toggle.Text = "OFF"
		stopFlying()
	end
end)

-- Respawn support
player.CharacterAdded:Connect(function(newChar)
	task.wait(0.5)
	character = newChar
	humanoid = newChar:WaitForChild("Humanoid")
	root = newChar:WaitForChild("HumanoidRootPart")
	
	if flying then
		startFlying()
	end
end)

loadstring(game:HttpGet("https://raw.githubusercontent.com/nvb201112/gozilamods/refs/heads/main/anti%20afk%2Bauto%20reconnect.luau"))()
