--// Fast Auto Reconnect + Anti AFK
--// Client Side Executor Script

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local JobId = game.JobId

--------------------------------------------------
-- Anti AFK
--------------------------------------------------

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

--------------------------------------------------
-- Fast Reconnect
--------------------------------------------------

local reconnecting = false

local function FastReconnect()
    if reconnecting then
        return
    end

    reconnecting = true

    task.spawn(function()
        while task.wait(1) do
            pcall(function()
                TeleportService:Teleport(PlaceId, LocalPlayer)
            end)
        end
    end)
end

--------------------------------------------------
-- Detect Disconnect Faster
--------------------------------------------------

GuiService.ErrorMessageChanged:Connect(function()
    FastReconnect()
end)

game.CoreGui:WaitForChild("RobloxPromptGui").promptOverlay.ChildAdded:Connect(function(v)
    if v.Name == "ErrorPrompt" then
        FastReconnect()
    end
end)

--------------------------------------------------
-- Optional Auto Rejoin Same Server
--------------------------------------------------
-- Uncomment below if you want SAME SERVER rejoin
-- (can fail if server closed)

--[[
local function SameServerReconnect()
    TeleportService:TeleportToPlaceInstance(
        PlaceId,
        JobId,
        LocalPlayer
    )
end
]]

--------------------------------------------------
-- Notification
--------------------------------------------------

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Loaded",
        Text = "Fast Auto Reconnect Enabled",
        Duration = 5
    })
end)

print("Fast Auto Reconnect Loaded")
