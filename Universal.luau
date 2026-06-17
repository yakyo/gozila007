local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Black V Universal Hub",
    Icon = "sparkle", -- lucide icon. optional
    Author = "Youtube: @the_real_Panda-Skidder", -- optional
})

local Tab = Window:Tab({
    Title = "Movement",
    Icon = "sport-shoe", -- optional
    Locked = false,
})

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local flying = false
local flySpeed = 167
local bv, bg = nil, nil

local function startFly()
    if flying then return end
    flying = true

    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")

    humanoid.PlatformStand = true

    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = root

    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bg.P = 15000
    bg.Parent = root
end

local function stopFly()
    if not flying then return end
    flying = false

    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end

    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
end

-- Main flying loop
RunService.RenderStepped:Connect(function()
    if not flying then return end

    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root or not bv then return end

    local cam = workspace.CurrentCamera
    local dir = Vector3.new(0, 0, 0)

    dir += cam.CFrame:VectorToWorldSpace(humanoid.MoveDirection)

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end

    if dir.Magnitude > 0 then
        dir = dir.Unit * flySpeed
    end

    bv.Velocity = dir
    bg.CFrame = cam.CFrame
end)

-- Toggle bằng phím E (tùy chọn)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.E then
        if flying then
            stopFly()
        else
            startFly()
        end
    end
end)

local Toggle = Tab:Toggle({
    Title = "Fly",
    Desc = "Bay",
    Icon = "check",
    Type = "Checkbox",
    Value = false, -- default value
    Callback = function(state) 
        if state then
            startFly()
            print("🚀 Fly Enabled")
        else
            stopFly()
            print("❌ Fly Disabled")
        end
    end
})

local function startNoClip()
    if noclipping then return end
    noclipping = true

    noclipConnection = RunService.Stepped:Connect(function()
        local character = player.Character
        if not character then return end

        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)

    print("✅ NoClip Enabled")
end

local function stopNoClip()
    if not noclipping then return end
    noclipping = false

    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end

local Toggle = Tab:Toggle({
    Title = "No clip",
    Desc = "Đi xuyên tường",
    Icon = "check",
    Type = "Checkbox",
    Value = false, -- default value
    Callback = function(state) 
        if state then
            startNoClip()
        else
            stopNoClip()
        end
    end
})

local NormalSpeed = 16  -- tốc độ mặc định của Roblox
local CurrentSpeed = 50 -- tốc độ khi bật hack
local SpeedEnabled = false

-- Lấy Humanoid (hỗ trợ respawn)
local function GetHumanoid()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    return character:WaitForChild("Humanoid")
end

-- Hàm bật/tắt speed
local function ToggleSpeed(enabled)
    SpeedEnabled = enabled
    local humanoid = GetHumanoid()
    if humanoid then
        if enabled then
            humanoid.WalkSpeed = CurrentSpeed
        else
            humanoid.WalkSpeed = NormalSpeed
        end
    end
end

local Toggle = Tab:Toggle({
    Title = "Speed hack",
    Desc = "Chạy siêu nhanh",
    Icon = "check",
    Type = "Checkbox",
    Value = false, -- default value
    Callback = function(value) 
        ToggleSpeed(value)
    end
})

local Slider = Tab:Slider({
    Title = "Change speed",
    Desc = "Chỉnh tốc độ chạy",
    
    -- To make float number supported, 
    -- make the Step a float number.
    -- example: Step = 0.1
    Step = 1,
    Value = {
        Min = 20,
        Max = 367,
        Default = 70,
    },
    Callback = function(value)
        CurrentSpeed = value
        if SpeedEnabled then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    end
})

local InfiniteJumpEnabled = false
local JumpConnection = nil

local function EnableInfiniteJump()
    if JumpConnection then return end
    
    JumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
        if InfiniteJumpEnabled then
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

local function DisableInfiniteJump()
    if JumpConnection then
        JumpConnection:Disconnect()
        JumpConnection = nil
    end
end

local Toggle = Tab:Toggle({
    Title = "Infinity jump",
    Desc = "Nhảy vô hạn",
    Icon = "check",
    Type = "Checkbox",
    Value = false, -- default value
    Callback = function(value)
        InfiniteJumpEnabled = value
        if value then
            EnableInfiniteJump()
            print("🚀 Infinite Jump đã BẬT")
        else
            DisableInfiniteJump()
            print("🚀 Infinite Jump đã TẮT")
        end
    end
})

local NormalJumpPower = 50          -- JumpPower mặc định của Roblox
local CurrentJumpPower = 100        -- Giá trị ban đầu
local JumpPowerEnabled = false

-- Lấy Humanoid an toàn
local function GetHumanoid()
    local player = game.Players.LocalPlayer
    if not player.Character then 
        player.CharacterAdded:Wait() 
    end
    return player.Character:WaitForChild("Humanoid", 5)
end

-- Áp dụng JumpPower
local function ApplyJumpPower()
    local humanoid = GetHumanoid()
    if humanoid then
        if JumpPowerEnabled then
            humanoid.JumpPower = CurrentJumpPower
        else
            humanoid.JumpPower = NormalJumpPower
        end
    end
end

local Toggle = Tab:Toggle({
    Title = "Super jump",
    Desc = "Nhảy cao",
    Icon = "check",
    Type = "Checkbox",
    Value = false, -- default value
    Callback = function(value) 
        JumpPowerEnabled = value
        ApplyJumpPower()
        
        if value then
            print("⏫ JumpPower Hack đã BẬT - Độ cao: " .. CurrentJumpPower)
        else
            print("⏫ JumpPower Hack đã TẮT")
        end
    end
})

local Slider = Tab:Slider({
    Title = "Change jump power",
    Desc = "Chỉnh độ cao nhảy",
    
    -- To make float number supported, 
    -- make the Step a float number.
    -- example: Step = 0.1
    Step = 1,
    Value = {
        Min = 20,
        Max = 367,
        Default = 70,
    },
    Callback = function(value)
        CurrentJumpPower = value
        
        -- Nếu đang bật thì áp dụng ngay
        if JumpPowerEnabled then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.JumpPower = value
            end
        end
    end
})

game.Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    ApplyJumpPower()
end)

local Tab = Window:Tab({
    Title = "Visual&ESP",
    Icon = "eye", -- optional
    Locked = false,
})

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local ENABLED = false
local REFRESH_RATE = 0.1  -- Làm mới mỗi 0.1 giây

-- ================== TẠO NAMETAG ==================
local function createNametag(character, player)
	if character:FindFirstChild("Nametag") then return end
	
	local head = character:FindFirstChild("Head")
	if not head then return end
	
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Nametag"
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 220, 0, 60)
	billboard.StudsOffset = Vector3.new(0, 3.5, 0)
	billboard.AlwaysOnTop = true
	billboard.LightInfluence = 0
	billboard.MaxDistance = 1500000000000000000000000000000000000000000000000000000
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextStrokeTransparency = 0
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextScaled = true
	textLabel.RichText = true
	
	textLabel.Text = player.DisplayName .. "\n<font size='15'>@" .. player.Name .. "</font>"
	
	textLabel.Parent = billboard
	billboard.Parent = character
end

-- ================== TẠO HIGHLIGHT ==================
local function createHighlight(character)
	if character:FindFirstChild("PlayerHighlight") then return end
	
	local highlight = Instance.new("Highlight")
	highlight.Name = "PlayerHighlight"
	highlight.FillColor = Color3.fromRGB(0, 255, 255)      -- Cyan
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Adornee = character
	highlight.Parent = character
end

-- ================== CẬP NHẬT / LÀM MỚI ESP CHO MỘT PLAYER ==================
local function refreshESPForPlayer(player)
	if player == LocalPlayer then return end
	if not player.Character then return end
	
	local character = player.Character
	
	-- Tạo lại nếu bị mất
	if not character:FindFirstChild("Nametag") then
		createNametag(character, player)
	end
	
	if not character:FindFirstChild("PlayerHighlight") then
		createHighlight(character)
	end
	
	-- Bật/Tắt theo trạng thái ENABLED
	local nametag = character:FindFirstChild("Nametag")
	if nametag then
		nametag.Enabled = ENABLED
	end
	
	local highlight = character:FindFirstChild("PlayerHighlight")
	if highlight then
		highlight.Enabled = ENABLED
	end
end

-- ================== REFRESH LOOP - Mỗi 0.1 giây ==================
local lastRefresh = 0

RunService.Heartbeat:Connect(function()
	if not ENABLED then return end
	
	local currentTime = tick()
	if currentTime - lastRefresh < REFRESH_RATE then return end
	lastRefresh = currentTime
	
	for _, player in ipairs(Players:GetPlayers()) do
		refreshESPForPlayer(player)
	end
end)

-- ================== ÁP DỤNG KHI PLAYER VÀO GAME ==================
local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.3) -- Đợi character load ổn định
		if ENABLED then
			refreshESPForPlayer(player)
		end
	end)
	
	-- Nếu character đã tồn tại
	if player.Character then
		if ENABLED then
			refreshESPForPlayer(player)
		end
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
Players.PlayerAdded:Connect(onPlayerAdded)

-- ================== TOGGLE BẰNG PHÍM H ==================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.H then
		ENABLED = not ENABLED
		
		-- Cập nhật ngay lập tức khi toggle
		for _, player in ipairs(Players:GetPlayers()) do
			refreshESPForPlayer(player)
		end
		
		print("ESP " .. (ENABLED and "BẬT ✅" or "TẮT ❌"))
	end
end)

print("ESP Script đã load! Nhấn H để bật/tắt. Refresh mỗi 0.1 giây.")

local Toggle = Tab:Toggle({
    Title = "ESP Player",
    Desc = "Định vị người chơi",
    Icon = "check",
    Type = "Checkbox",
    Value = false, -- default value
    Callback = function(state) 
        ENABLED = state
		for _, player in ipairs(Players:GetPlayers()) do
			refreshESPForPlayer(player)
		end
    end
})

local Button = Tab:Button({
    Title = "Delete visual",
    Desc = "Xoá hiệu ứng",
    Locked = false,
    Callback = function()
        -- 🧹 CLEAN UP SCRIPT - Xóa hết visual effects (Trail, Meteor, Particle, Lighting...)
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

print("🧹 Đang dọn dẹp tất cả visual effects...")

-- 1. Xóa Meteor Shower và các hiệu ứng sao băng
if Workspace:FindFirstChild("MeteorShower") then
    Workspace.MeteorShower:Destroy()
    print("✅ Đã xóa MeteorShower")
end

-- 2. Xóa Trail, ParticleEmitter, Attachment trên nhân vật
for _, obj in pairs(character:GetDescendants()) do
    if obj:IsA("Trail") or obj:IsA("ParticleEmitter") or obj:IsA("ForceField") then
        obj:Destroy()
    elseif obj:IsA("Attachment") and (obj.Parent:IsA("BasePart") or obj.Parent == character) then
        -- Chỉ xóa attachment liên quan đến trail/particle
        if obj:FindFirstChildWhichIsA("Trail") or obj:FindFirstChildWhichIsA("ParticleEmitter") then
            obj:Destroy()
        end
    end
end

-- 3. Reset Lighting về mặc định (xóa hiệu ứng toàn màn hình)
Lighting.TimeOfDay = "14:00:00"        -- Giờ ban ngày bình thường
Lighting.Brightness = 2
Lighting.Ambient = Color3.fromRGB(100, 100, 100)
Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
Lighting.ClockTime = 14

-- Xóa hoặc reset các effect trong Lighting
for _, effect in pairs(Lighting:GetChildren()) do
    if effect:IsA("BloomEffect") or effect:IsA("ColorCorrectionEffect") or 
       effect:IsA("Atmosphere") or effect:IsA("SunRaysEffect") or 
       effect:IsA("BlurEffect") or effect:IsA("DepthOfFieldEffect") then
        effect:Destroy()
    end
end

-- Reset Sky (nếu có)
if Lighting:FindFirstChild("Sky") then
    Lighting.Sky.StarCount = 3000  -- Giảm sao về mức bình thường
end

-- 4. Xóa các folder visual thừa khác (nếu có)
for _, folder in pairs(Workspace:GetChildren()) do
    if folder.Name == "MeteorShower" or folder.Name:find("Visual") or folder.Name:find("Effect") then
        folder:Destroy()
    end
end

-- 5. Cleanup trên toàn Workspace (an toàn hơn)
for _, obj in pairs(Workspace:GetDescendants()) do
    if obj.Name == "Meteor" and obj:IsA("Part") then
        obj:Destroy()
    end
end

print("✅ ĐÃ DỌN SẠCH HẾT visual effects!")
print("Bầu trời, mưa sao băng, vệt sáng, particle... đã bị xóa.")
    end
})

local Button = Tab:Button({
    Title = "Meteor rain",
    Desc = "Mưa sao băng",
    Locked = false,
    Callback = function()
        -- 🌌 Bầu Trời Đêm + Mưa Sao Băng THƯA + VỆT SÁNG ĐẸP HƠN
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- === 1. Bầu trời đêm ===
Lighting.TimeOfDay = "00:00:00"
Lighting.Brightness = 1.5
Lighting.Ambient = Color3.fromRGB(50, 50, 80)
Lighting.OutdoorAmbient = Color3.fromRGB(60, 60, 100)
Lighting.ClockTime = 0

if Lighting:FindFirstChild("Sky") then
    Lighting.Sky.StarCount = 7000
end

local atmosphere = Lighting:FindFirstChild("Atmosphere") or Instance.new("Atmosphere")
atmosphere.Density = 0.25
atmosphere.Offset = 0.2
atmosphere.Color = Color3.fromRGB(30, 40, 90)
atmosphere.Decay = Color3.fromRGB(80, 100, 160)
atmosphere.Haze = 1.0
atmosphere.Glare = 0.3
atmosphere.Parent = Lighting

local bloom = Lighting:FindFirstChild("Bloom") or Instance.new("BloomEffect")
bloom.Intensity = 1.65
bloom.Size = 33
bloom.Threshold = 1.1
bloom.Parent = Lighting

local colorCorr = Lighting:FindFirstChild("ColorCorrection") or Instance.new("ColorCorrectionEffect")
colorCorr.Brightness = 0.1
colorCorr.Contrast = 0.2
colorCorr.Saturation = -0.18
colorCorr.Parent = Lighting

print("🌌 Bầu trời đêm đã bật!")

-- === 2. Mưa Sao Băng THƯA + VỆT SÁNG ĐẸP ===
local meteorFolder = Instance.new("Folder")
meteorFolder.Name = "MeteorShower"
meteorFolder.Parent = workspace

local function createMeteor()
    local meteor = Instance.new("Part")
    meteor.Size = Vector3.new(1.8, 1.8, 11)
    meteor.Shape = Enum.PartType.Ball
    meteor.Material = Enum.Material.Neon
    meteor.Color = Color3.fromRGB(240, 250, 255)
    meteor.Anchored = false
    meteor.CanCollide = false
    meteor.Transparency = 0.08
    meteor.Parent = meteorFolder

    local spawnHeight = 390 + math.random(90, 180)
    local spawnX = math.random(-520, 520)
    local spawnZ = math.random(-520, 520)
    meteor.Position = Vector3.new(spawnX, spawnHeight, spawnZ)

    local direction = Vector3.new(math.random(-120, 120), -210, math.random(-120, 120)).Unit * 280

    -- === VỆT SÁNG ĐẸP HƠN ===
    local att0 = Instance.new("Attachment")
    att0.Position = Vector3.new(0, 0, 4.5)
    att0.Parent = meteor

    local att1 = Instance.new("Attachment")
    att1.Position = Vector3.new(0, 0, -6)
    att1.Parent = meteor

    local trail = Instance.new("Trail")
    trail.Attachment0 = att0
    trail.Attachment1 = att1
    
    trail.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),   -- trắng chói
        ColorSequenceKeypoint.new(0.25,Color3.fromRGB(210, 240, 255)),   -- xanh dương sáng
        ColorSequenceKeypoint.new(0.55,Color3.fromRGB(180, 210, 255)),   -- xanh nhạt
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(140, 170, 255))    -- tím nhạt
    })
    
    trail.LightEmission = 1
    trail.LightInfluence = 0.15
    trail.Transparency = NumberSequence.new(0.15, 1)
    trail.Lifetime = 1.65                     -- vừa phải, đẹp
    trail.WidthScale = NumberSequence.new(1.05, 0)   -- mỏng nhẹ, tinh tế
    trail.Enabled = true
    trail.Parent = meteor

    -- Particle lấp lánh nhẹ nhàng
    local particle = Instance.new("ParticleEmitter")
    particle.Texture = "rbxassetid://243660364"
    particle.Color = ColorSequence.new(Color3.fromRGB(225, 245, 255))
    particle.LightEmission = 1
    particle.Size = NumberSequence.new(1.6, 0)
    particle.Lifetime = NumberRange.new(0.7, 1.3)
    particle.Rate = 70
    particle.Speed = NumberRange.new(2, 6)
    particle.SpreadAngle = Vector2.new(35, 35)
    particle.Parent = meteor

    meteor.Velocity = direction

    task.delay(5.5, function()
        if meteor and meteor.Parent then
            meteor:Destroy()
        end
    end)
end

-- Spawn sao băng THƯA hơn nhiều
local meteorConnection = RunService.Heartbeat:Connect(function()
    if math.random(1, 9) == 1 then           -- Giảm mạnh tần suất
        for i = 1, math.random(1, 2) do      -- Thường chỉ 1, đôi khi 2
            createMeteor()
        end
    end
end)

print("✨ Mưa sao băng thưa + vệt sáng đẹp hơn đang chạy! Nhìn lên trời 🌠")

-- Cleanup
game:BindToClose(function()
    if meteorConnection then meteorConnection:Disconnect() end
    if meteorFolder then meteorFolder:Destroy() end
end)
    end
})

local Button = Tab:Button({
    Title = "Sakura rain",
    Desc = "Mưa hoa anh đào",
    Locked = false,
    Callback = function()
        -- LocalScript (đặt trong StarterPlayerScripts)
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ====================== THIẾT LẬP BẦU TRỜI HỒNG ======================
local function setupPinkSky()
	-- Xóa sky cũ nếu có (client-side)
	for _, child in pairs(Lighting:GetChildren()) do
		if child:IsA("Sky") then
			child:Destroy()
		end
	end

	-- Tạo Sky mới với tông hồng nhẹ (hoặc giữ sky cũ và tint)
	local sky = Instance.new("Sky")
	sky.SkyboxBk = "http://www.roblox.com/asset/?id=600830446"  -- sky mặc định, bạn có thể thay bằng ID sky hồng nếu có
	sky.SkyboxDn = "http://www.roblox.com/asset/?id=600831635"
	sky.SkyboxFt = "http://www.roblox.com/asset/?id=600832720"
	sky.SkyboxLf = "http://www.roblox.com/asset/?id=600833062"
	sky.SkyboxRt = "http://www.roblox.com/asset/?id=600833862"
	sky.SkyboxUp = "http://www.roblox.com/asset/?id=600835177"
	sky.Parent = Lighting

	-- ColorCorrectionEffect để tint toàn cảnh thành hồng lãng mạn
	local colorCorrection = Lighting:FindFirstChild("PinkRomanticCorrection") or Instance.new("ColorCorrectionEffect")
	colorCorrection.Name = "PinkRomanticCorrection"
	colorCorrection.Saturation = 0.4
	colorCorrection.Contrast = 0.2
	colorCorrection.Brightness = 0.1
	colorCorrection.TintColor = Color3.fromRGB(255, 180, 220)  -- hồng pastel lãng mạn
	colorCorrection.Parent = Lighting

	-- Atmosphere cho cảm giác mềm mại, mơ màng
	local atmosphere = Lighting:FindFirstChild("RomanticAtmosphere") or Instance.new("Atmosphere")
	atmosphere.Name = "RomanticAtmosphere"
	atmosphere.Density = 0.3
	atmosphere.Offset = 0.25
	atmosphere.Color = Color3.fromRGB(255, 200, 230)
	atmosphere.Decay = Color3.fromRGB(200, 150, 180)
	atmosphere.Glare = 0.4
	atmosphere.Haze = 2
	atmosphere.Parent = Lighting

	-- Chỉnh Lighting thêm
	Lighting.Brightness = 1.5
	Lighting.ClockTime = 16.5  -- giờ chiều muộn, ánh sáng ấm
	Lighting.FogEnd = 500
	Lighting.FogColor = Color3.fromRGB(255, 200, 230)
end

-- ====================== HIỆU ỨNG MƯA CÁNH HOA ANH ĐÀO ======================
local petalEmitter = nil

local function createCherryBlossomRain()
	-- Tạo một Part vô hình lớn theo camera để phát particle
	local rainPart = Instance.new("Part")
	rainPart.Name = "CherryBlossomRainPart"
	rainPart.Size = Vector3.new(200, 1, 200)  -- kích thước lớn
	rainPart.Transparency = 1
	rainPart.CanCollide = false
	rainPart.Anchored = true
	rainPart.Parent = camera

	-- ParticleEmitter cho cánh hoa
	petalEmitter = Instance.new("ParticleEmitter")
	petalEmitter.Name = "SakuraPetals"
	petalEmitter.Texture = "rbxassetid://241650934"  -- texture cánh hoa anh đào phổ biến (có thể thay bằng ID khác đẹp hơn)
	petalEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 180, 200)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 200, 220)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 240))
	})
	petalEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.6),
		NumberSequenceKeypoint.new(1, 0.3)
	})
	petalEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.7, 0.4),
		NumberSequenceKeypoint.new(1, 1)
	})
	petalEmitter.Lifetime = NumberRange.new(8, 15)
	petalEmitter.Rate = 80          -- số lượng cánh hoa mỗi giây
	petalEmitter.Speed = NumberRange.new(4, 8)
	petalEmitter.SpreadAngle = Vector2.new(30, 30)
	petalEmitter.RotSpeed = NumberRange.new(-100, 100)
	petalEmitter.Rotation = NumberRange.new(-180, 180)
	petalEmitter.Acceleration = Vector3.new(0, -3, 0)  -- rơi nhẹ
	petalEmitter.Drag = 0.5
	petalEmitter.VelocitySpread = 20
	petalEmitter.Parent = rainPart

	-- Cập nhật vị trí Part theo camera để mưa luôn bao phủ người chơi
	RunService.RenderStepped:Connect(function()
		if rainPart and rainPart.Parent then
			rainPart.CFrame = camera.CFrame * CFrame.new(0, 50, 0)  -- đặt phía trên camera
		end
	end)
end

-- ====================== CHẠY SCRIPT ======================
setupPinkSky()
createCherryBlossomRain()

print("🌸 Bầu trời hồng lãng mạn + mưa cánh hoa anh đào đã bật! (Client-side)")

-- Nếu muốn tắt sau này, bạn có thể thêm code destroy các object trên
    end
})

local Button = Tab:Button({
    Title = "Sunset",
    Desc = "Hoàng hôn",
    Locked = false,
    Callback = function()
        -- LocalScript: Romantic Sunset
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local function setupSunset()
	for _, v in pairs(Lighting:GetChildren()) do
		if v:IsA("Sky") or v:IsA("ColorCorrectionEffect") or v:IsA("Atmosphere") then v:Destroy() end
	end

	local sky = Instance.new("Sky")
	sky.SkyboxBk = "rbxassetid://600830446"
	sky.SkyboxDn = "rbxassetid://600831635"
	sky.SkyboxFt = "rbxassetid://600832720"
	sky.SkyboxLf = "rbxassetid://600833062"
	sky.SkyboxRt = "rbxassetid://600833862"
	sky.SkyboxUp = "rbxassetid://600835177"
	sky.Parent = Lighting

	local color = Instance.new("ColorCorrectionEffect")
	color.TintColor = Color3.fromRGB(255, 180, 100)
	color.Saturation = 0.3
	color.Contrast = 0.15
	color.Parent = Lighting

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Color = Color3.fromRGB(255, 140, 80)
	atmosphere.Decay = Color3.fromRGB(200, 100, 60)
	atmosphere.Density = 0.25
	atmosphere.Haze = 1.5
	atmosphere.Parent = Lighting

	Lighting.ClockTime = 17.5
	Lighting.Brightness = 1.8
end

-- Mưa ánh sáng nhẹ (glow particles)
local function createGlowRain()
	local part = Instance.new("Part")
	part.Size = Vector3.new(300, 1, 300)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.Parent = camera

	local emit = Instance.new("ParticleEmitter")
	emit.Texture = "rbxassetid://243098098"  -- glow particle
	emit.Color = ColorSequence.new(Color3.fromRGB(255, 220, 100))
	emit.Size = NumberSequence.new(0.4, 0.1)
	emit.Transparency = NumberSequence.new(0.2, 1)
	emit.Lifetime = NumberRange.new(12, 18)
	emit.Rate = 45
	emit.Speed = NumberRange.new(3, 7)
	emit.Acceleration = Vector3.new(0, -2, 0)
	emit.RotSpeed = NumberRange.new(-50, 50)
	emit.Parent = part

	RunService.RenderStepped:Connect(function()
		part.CFrame = camera.CFrame * CFrame.new(0, 60, 0)
	end)
end

setupSunset()
createGlowRain()
print("🌅 Bầu trời hoàng hôn lãng mạn đã bật!")
    end
})

local Button = Tab:Button({
    Title = "Rainbow sky",
    Desc = "Bầu trời cầu vồng",
    Locked = false,
    Callback = function()
        -- LocalScript: Rainbow Dreamy Sky
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local color = Instance.new("ColorCorrectionEffect")
color.Parent = Lighting

local hue = 0
game:GetService("RunService").Heartbeat:Connect(function(dt)
	hue = (hue + dt * 0.1) % 1
	color.TintColor = Color3.fromHSV(hue, 0.7, 1)
end)

Lighting.ClockTime = 14
Lighting.Brightness = 2

local atmosphere = Instance.new("Atmosphere")
atmosphere.Density = 0.35
atmosphere.Color = Color3.fromRGB(200, 255, 255)
atmosphere.Parent = Lighting

print("🌈 Bầu trời cầu vồng mơ màng đã bật!")
    end
})

local Button = Tab:Button({
    Title = "Snow rain",
    Desc = "Mưa tuyết",
    Locked = false,
    Callback = function()
        -- LocalScript: Winter Romance Snow
local Lighting = game:GetService("Lighting")
local camera = workspace.CurrentCamera

Lighting.ClockTime = 12
Lighting.Brightness = 1.2
Lighting.FogColor = Color3.fromRGB(220, 240, 255)
Lighting.FogEnd = 400

local color = Instance.new("ColorCorrectionEffect")
color.TintColor = Color3.fromRGB(220, 240, 255)
color.Saturation = 0.2
color.Parent = Lighting

local part = Instance.new("Part")
part.Size = Vector3.new(300, 1, 300)
part.Transparency = 1
part.Anchored = true
part.CanCollide = false
part.Parent = camera

local snow = Instance.new("ParticleEmitter")
snow.Texture = "rbxassetid://241650934"  -- thay bằng snowflake texture nếu muốn
snow.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
snow.Size = NumberSequence.new(0.6, 0.2)
snow.Transparency = NumberSequence.new(0, 1)
snow.Lifetime = NumberRange.new(10, 15)
snow.Rate = 120
snow.Speed = NumberRange.new(6, 12)
snow.Acceleration = Vector3.new(0, -8, 0)
snow.RotSpeed = NumberRange.new(-200, 200)
snow.Parent = part

game:GetService("RunService").RenderStepped:Connect(function()
	part.CFrame = camera.CFrame * CFrame.new(0, 70, 0)
end)

print("❄️ Mưa tuyết lãng mạn đã bật!")
    end
})

local Button = Tab:Button({
    Title = "Aurora borealis",
    Desc = "Cực quang",
    Locked = false,
    Callback = function()
        -- LocalScript: Aurora Borealis - Phiên bản đẹp hơn (đặt trong StarterPlayerScripts)
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local camera = workspace.CurrentCamera

-- Xóa các hiệu ứng cũ để tránh chồng chéo
for _, child in pairs(Lighting:GetChildren()) do
	if child:IsA("Sky") or child:IsA("ColorCorrectionEffect") or child:IsA("BloomEffect") or child:IsA("Atmosphere") then
		child:Destroy()
	end
end

-- ====================== THIẾT LẬP BẦU TRỜI & LIGHTING ======================
local sky = Instance.new("Sky")
sky.SkyboxBk = "rbxassetid://600830446"
sky.SkyboxDn = "rbxassetid://600831635"
sky.SkyboxFt = "rbxassetid://600832720"
sky.SkyboxLf = "rbxassetid://600833062"
sky.SkyboxRt = "rbxassetid://600833862"
sky.SkyboxUp = "rbxassetid://600835177"
sky.StarCount = 3000
sky.Parent = Lighting

Lighting.ClockTime = 23.5
Lighting.Brightness = 0.3
Lighting.Ambient = Color3.fromRGB(5, 10, 30)
Lighting.EnvironmentDiffuseScale = 0.2
Lighting.EnvironmentSpecularScale = 0.1

-- Bloom để tạo hiệu ứng sáng lung linh
local bloom = Instance.new("BloomEffect")
bloom.Intensity = 0.8
bloom.Size = 24
bloom.Threshold = 1.2
bloom.Parent = Lighting

-- ColorCorrection chính
local colorCorrection = Instance.new("ColorCorrectionEffect")
colorCorrection.Brightness = 0.05
colorCorrection.Contrast = 0.15
colorCorrection.Saturation = 0.4
colorCorrection.TintColor = Color3.fromRGB(180, 255, 220)
colorCorrection.Parent = Lighting

-- Atmosphere mềm mại
local atmosphere = Instance.new("Atmosphere")
atmosphere.Density = 0.35
atmosphere.Offset = 0.3
atmosphere.Color = Color3.fromRGB(80, 180, 255)
atmosphere.Decay = Color3.fromRGB(60, 100, 200)
atmosphere.Haze = 2.5
atmosphere.Glare = 0.6
atmosphere.Parent = Lighting

-- ====================== HIỆU ỨNG AURORA PARTICLE (2 lớp) ======================
local auroraPart = Instance.new("Part")
auroraPart.Name = "AuroraPart"
auroraPart.Size = Vector3.new(600, 20, 600)
auroraPart.Transparency = 1
auroraPart.Anchored = true
auroraPart.CanCollide = false
auroraPart.CanQuery = false
auroraPart.Parent = camera

-- Particle chính (lớp dưới - rộng và chậm)
local mainAurora = Instance.new("ParticleEmitter")
mainAurora.Texture = "rbxassetid://110170832236629"  -- Texture Aurora đẹp nhất hiện nay
mainAurora.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 120)),
	ColorSequenceKeypoint.new(0.35, Color3.fromRGB(80, 180, 255)),
	ColorSequenceKeypoint.new(0.65, Color3.fromRGB(180, 100, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 200))
})
mainAurora.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 90), NumberSequenceKeypoint.new(1, 140)})
mainAurora.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.65), NumberSequenceKeypoint.new(1, 1)})
mainAurora.Lifetime = NumberRange.new(35, 55)
mainAurora.Rate = 4
mainAurora.Speed = NumberRange.new(0.2, 0.8)
mainAurora.RotSpeed = NumberRange.new(-8, 8)
mainAurora.SpreadAngle = Vector2.new(180, 10)
mainAurora.Acceleration = Vector3.new(0, 0, 0)
mainAurora.Parent = auroraPart

-- Particle overlay (lớp trên - mảnh và sáng hơn)
local overlayAurora = mainAurora:Clone()
overlayAurora.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 50), NumberSequenceKeypoint.new(1, 85)})
overlayAurora.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 1)})
overlayAurora.Rate = 6
overlayAurora.Lifetime = NumberRange.new(25, 40)
overlayAurora.Parent = auroraPart

-- Cập nhật vị trí particle theo camera
RunService.RenderStepped:Connect(function()
	if auroraPart and auroraPart.Parent then
		auroraPart.CFrame = camera.CFrame * CFrame.new(0, 140, 0) * CFrame.Angles(0, math.rad(180), 0)
	end
end)

-- ====================== LÀM MÀU AURORA CHUYỂN ĐỘNG MƯỢT ======================
local hue = 0
RunService.Heartbeat:Connect(function(dt)
	hue = (hue + dt * 0.08) % 1
	
	-- Thay đổi tint nhẹ theo thời gian
	colorCorrection.TintColor = Color3.fromHSV(hue * 0.15 + 0.45, 0.75, 1)
	
	-- Thay đổi màu Atmosphere nhẹ
	atmosphere.Color = Color3.fromHSV(hue * 0.12 + 0.48, 0.65, 1)
end)

print("🌌 Aurora Borealis cực đẹp & sống động đã bật! (Phiên bản nâng cấp)")

-- Nếu muốn tắt: xóa script và restart game
    end
})

local Tab = Window:Tab({
    Title = "Fix lag",
    Icon = "zap", -- optional
    Locked = false,
})

local Button = Tab:Button({
    Title = "Fix lag ",
    Desc = "Giảm hiệu ứng -> tăng fps",
    Locked = false,
    Callback = function()
        -- FPS Boost / Anti Lag Script

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")

-- giảm đồ họa Lighting
Lighting.GlobalShadows = false
Lighting.FogEnd = 9e9
Lighting.Brightness = 1

for _, v in pairs(Lighting:GetDescendants()) do
    if v:IsA("PostEffect") then
        v.Enabled = false
    end
end

-- giảm texture + material
for _, v in pairs(workspace:GetDescendants()) do
    if v:IsA("BasePart") then
        v.Material = Enum.Material.Plastic
        v.Reflectance = 0
    elseif v:IsA("Decal") or v:IsA("Texture") then
        v.Transparency = 1
    end
end

-- tắt hiệu ứng Terrain
if Terrain then
    Terrain.WaterWaveSize = 0
    Terrain.WaterWaveSpeed = 0
    Terrain.WaterReflectance = 0
    Terrain.WaterTransparency = 1
end

-- auto clean effect nặng
workspace.DescendantAdded:Connect(function(v)
    if v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Enabled = false
    end
end)

print("Anti Lag Loaded")
    end
})

local Button = Tab:Button({
    Title = "Clear map",
    Desc = "Xoá map",
    Locked = false,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/nvb201112/fix-lag/refs/heads/main/Fix%20Lag%20100%25.txt"))()
    end
})

local Tab = Window:Tab({
    Title = " Change Font",
    Icon = "a-large-small", -- optional
    Locked = false,
})

local Button = Tab:Button({
    Title = "Antique",
    Desc = "Change to Antique",
    Locked = false,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/nvb201112/font-changer/refs/heads/main/antique.luau"))()
    end
})

local Button = Tab:Button({
    Title = "Arcade",
    Desc = "Change to Arcade",
    Locked = false,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/nvb201112/font-changer/refs/heads/main/arcade.luau"))()
    end
})

local Button = Tab:Button({
    Title = "Bodoni",
    Desc = "Change to Bodoni",
    Locked = false,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/nvb201112/font-changer/refs/heads/main/bodoni.luau"))()
    end
})

local Button = Tab:Button({
    Title = "Cartoon",
    Desc = "Change to Cartoon",
    Locked = false,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/nvb201112/font-changer/refs/heads/main/cartoon.luau"))()
    end
})

local Button = Tab:Button({
    Title = "Code",
    Desc = "Change to Code",
    Locked = false,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/nvb201112/font-changer/refs/heads/main/code.luau"))()
    end
})

local Button = Tab:Button({
    Title = "Fantasy",
    Desc = "Change to Fantasy",
    Locked = false,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/nvb201112/font-changer/refs/heads/main/fantasy.luau"))()
    end
})

local Button = Tab:Button({
    Title = "Gotham",
    Desc = "Change to Gotham",
    Locked = false,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/nvb201112/font-changer/refs/heads/main/gotham.luau"))()
    end
})

local Button = Tab:Button({
    Title = "Highway",
    Desc = "Change to Highway",
    Locked = false,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/nvb201112/font-changer/refs/heads/main/highway.luau"))()
    end
})

local Button = Tab:Button({
    Title = "Scifi",
    Desc = "Change to Scifi",
    Locked = false,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/nvb201112/font-changer/refs/heads/main/scifi.luau"))()
    end
})

local Button = Tab:Button({
    Title = "SourceSans",
    Desc = "Change to SourceSans",
    Locked = false,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/yakyo/font-changer/refs/heads/main/sourcesans.luau"))()
    end
})
