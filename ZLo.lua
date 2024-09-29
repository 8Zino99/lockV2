-- reset if you execute the Script
-- made by -ZINO x MESSLT

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Aimbot = {
    Enabled = false,
    FOVRadius = 150,
    LockPart = "Head",
    MaxDistance = 1000,
    Smoothness = 0.1,
    Prediction = 0.1,
    AutoShoot = true,
    DrawFOV = true,
    LockedTarget = nil
}

local ESPSettings = {
    Enabled = true,
    BoxColor = Color3.fromRGB(0, 255, 0),
    NameColor = Color3.fromRGB(255, 255, 255),
    BoxThickness = 2
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Radius = Aimbot.FOVRadius
FOVCircle.Color = Color3.fromRGB(0, 255, 0)
FOVCircle.Filled = false
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOVCircle.Visible = Aimbot.DrawFOV

local ESPObjects = {}

local function CreateESP(player)
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    if not rootPart or not head then return end

    local box = Drawing.new("Square")
    box.Thickness = ESPSettings.BoxThickness
    box.Color = ESPSettings.BoxColor
    box.Visible = true
    box.Filled = false

    local nameTag = Drawing.new("Text")
    nameTag.Text = player.Name
    nameTag.Size = 18
    nameTag.Color = ESPSettings.NameColor
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.new(0, 0, 0)

    ESPObjects[player] = {box = box, nameTag = nameTag}

    local function UpdateESP()
        if not player.Character or not rootPart or not head or not rootPart:IsDescendantOf(workspace) then
            box.Visible = false
            nameTag.Visible = false
            return
        end

        local rootPosition, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        local headPosition = Camera:WorldToViewportPoint(head.Position)

        if onScreen then
            box.Size = Vector2.new(2000 / rootPosition.Z, 2500 / rootPosition.Z)
            box.Position = Vector2.new(rootPosition.X - box.Size.X / 2, rootPosition.Y - box.Size.Y / 2)
            nameTag.Position = Vector2.new(headPosition.X, headPosition.Y - 20)
            nameTag.Visible = true
            box.Visible = true
        else
            nameTag.Visible = false
            box.Visible = false
        end
    end

    local connection = RunService.RenderStepped:Connect(UpdateESP)

    player.CharacterRemoving:Connect(function()
        if ESPObjects[player] then
            ESPObjects[player].box:Remove()
            ESPObjects[player].nameTag:Remove()
            ESPObjects[player] = nil
        end
        connection:Disconnect()
    end)
end

local function AddESPToAllPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function()
                wait(1)
                CreateESP(player)
            end)
            if player.Character then
                CreateESP(player)
            end
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1)
        CreateESP(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        ESPObjects[player].box:Remove()
        ESPObjects[player].nameTag:Remove()
        ESPObjects[player] = nil
    end
end)

AddESPToAllPlayers()

local function GetClosestTarget()
    local closestTarget = nil
    local closestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Aimbot.LockPart) then
            local targetPart = player.Character[Aimbot.LockPart]
            local targetPosition, onScreen = Camera:WorldToViewportPoint(targetPart.Position)

            if onScreen then
                local distance = (Vector2.new(targetPosition.X, targetPosition.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                if distance <= Aimbot.FOVRadius then
                    local distanceFromPlayer = (targetPart.Position - Camera.CFrame.Position).Magnitude
                    if distanceFromPlayer <= Aimbot.MaxDistance and distance < closestDistance then
                        closestDistance = distance
                        closestTarget = player
                    end
                end
            end
        end
    end

    return closestTarget
end

local function PredictMovement(target)
    local targetPart = target.Character:FindFirstChild(Aimbot.LockPart)
    if not targetPart then return targetPart.Position end
    local velocity = targetPart.Velocity
    return targetPart.Position + (velocity * Aimbot.Prediction)
end

local function AimAt(target)
    if target and target.Character then
        local targetPosition = PredictMovement(target)
        local targetPart = target.Character:FindFirstChild(Aimbot.LockPart)
        if targetPart then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
            Camera.CFrame = targetCFrame
            if Aimbot.AutoShoot then
                local weapon = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                if weapon then
                    weapon:Activate()
                end
            end
        end
    end
end

local function TrackPlayers()
    if Aimbot.LockedTarget then
        AimAt(Aimbot.LockedTarget)
    else
        Aimbot.LockedTarget = GetClosestTarget()
    end
end

local SpinEnabled = false
local SpinSpeed = 140

local function ToggleSpin()
    SpinEnabled = not SpinEnabled
end

local normalSpeed = 16
local isGlitchActive = false
local glitchSpeed = 140

local function ToggleSpeedGlitch()
    local player = LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    if not isGlitchActive then
        humanoid.WalkSpeed = normalSpeed

        game:GetService("RunService").Heartbeat:Connect(function()
            if humanoid.MoveDirection.Magnitude > 0 and isGlitchActive then
                character:TranslateBy(humanoid.MoveDirection * (glitchSpeed - normalSpeed) * game:GetService("RunService").Heartbeat:Wait())
            end
        end)
    else
        humanoid.WalkSpeed = normalSpeed
    end

    isGlitchActive = not isGlitchActive
end

local function CreateGUI()
    local gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)

    local toggleButton = Instance.new("TextButton", gui)
    toggleButton.Size = UDim2.new(0, 100, 0, 50)
    toggleButton.Position = UDim2.new(1, -110, 0, 10)
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Text = "Aimbot: OFF"
    toggleButton.TextSize = 18
    toggleButton.Font = Enum.Font.SourceSans
    
    local speedToggle = Instance.new("TextButton", gui)
    speedToggle.Size = UDim2.new(0, 100, 0, 50)
    speedToggle.Position = UDim2.new(1, -110, 0, 70)
    speedToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    speedToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedToggle.Text = "Speed: OFF"
    speedToggle.TextSize = 18
    speedToggle.Font = Enum.Font.SourceSans

    local SpeedInput = Instance.new("TextBox", gui)
    SpeedInput.Size = UDim2.new(0, 100, 0, 50)
    SpeedInput.Position = UDim2.new(1, -110, 0, 130)
    SpeedInput.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedInput.Text = "Enter Speed"
    SpeedInput.TextSize = 18
    SpeedInput.Font = Enum.Font.SourceSans

    local spinButton = Instance.new("TextButton", gui)
    spinButton.Size = UDim2.new(0, 100, 0, 50)
    spinButton.Position = UDim2.new(1, -110, 0, 190)
    spinButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    spinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    spinButton.Text = "Spin: OFF"
    spinButton.TextSize = 18
    spinButton.Font = Enum.Font.SourceSans

    toggleButton.MouseButton1Click:Connect(function()
        Aimbot.Enabled = not Aimbot.Enabled
        toggleButton.Text = Aimbot.Enabled and "Aimbot: ON" or "Aimbot: OFF"
        if Aimbot.Enabled then
            Aimbot.LockedTarget = GetClosestTarget()
        end
    end)

    speedToggle.MouseButton1Click:Connect(function()
        ToggleSpeedGlitch()
        speedToggle.Text = isGlitchActive and "Speed: ON" or "Speed: OFF"
    end)

    SpeedInput.FocusLost:Connect(function()
        local speedValue = tonumber(SpeedInput.Text)
        if speedValue then
            glitchSpeed = speedValue
        end
    end)

    spinButton.MouseButton1Click:Connect(function()
        ToggleSpin()
        spinButton.Text = SpinEnabled and "Spin: ON" or "Spin: OFF"
    end)

    return gui
end

local function ShowGUIAfterRespawn()
    LocalPlayer.CharacterAdded:Connect(function()
        wait(1)
        CreateGUI()
    end)
end

RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled then
        TrackPlayers()
    end
    if SpinEnabled then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(SpinSpeed * RunService.RenderStepped:Wait()), 0)
    end
end)

ShowGUIAfterRespawn()
