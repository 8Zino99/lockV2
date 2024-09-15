-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local Mouse = Players.LocalPlayer:GetMouse()

-- Aimbot Settings
local Aimbot = {
    Enabled = true,
    FOVRadius = 100, -- Radius of the aimbot circle
    HitChance = 1,   -- 1 means 100% hit rate
    LockPart = "Head", -- Part to lock onto (usually "Head" or "HumanoidRootPart")
    MaxDistance = 1000, -- Maximum distance for aimbot to target
    Target = nil -- Current target
}

-- Draw the FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Radius = Aimbot.FOVRadius
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Filled = false
FOVCircle.Visible = true

-- Function to get distance from center of the screen
local function GetDistanceFromCenter(pos)
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    return (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
end

-- Function to get the closest target within the FOV
local function GetClosestTarget()
    local closestTarget = nil
    local closestDistance = Aimbot.FOVRadius

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild(Aimbot.LockPart) then
            local targetPart = player.Character[Aimbot.LockPart]
            local targetPosition, onScreen = Camera:WorldToViewportPoint(targetPart.Position)

            if onScreen then
                local distance = GetDistanceFromCenter(targetPosition)
                if distance < closestDistance then
                    closestDistance = distance
                    closestTarget = player
                end
            end
        end
    end

    return closestTarget
end

-- Function to aim at the target
local function AimAt(target)
    if target and target.Character and Aimbot.Enabled then
        local targetPart = target.Character[Aimbot.LockPart]
        local targetPosition = targetPart.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
    end
end

-- Main loop for updating the aimbot
RunService.RenderStepped:Connect(function()
    -- Update FOV Circle position
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)

    if Aimbot.Enabled then
        -- Get closest target in FOV
        local closestTarget = GetClosestTarget()

        if closestTarget then
            -- Aim at the closest target
            AimAt(closestTarget)

            -- Visualize line (optional)
            -- You can draw a line here to visualize the lock-on (not implemented here)
        end
    end
end)

-- Keybinds to toggle aimbot
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then
        Aimbot.Enabled = not Aimbot.Enabled
        FOVCircle.Visible = Aimbot.Enabled
    end
end)
