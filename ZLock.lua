-- by ZINO👾
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
    
    local circleSizeBox = Instance.new("TextBox", gui)
    circleSizeBox.Size = UDim2.new(0, 100, 0, 50)
    circleSizeBox.Position = UDim2.new(1, -110, 0, 70)
    circleSizeBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    circleSizeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    circleSizeBox.Text = tostring(Aimbot.FOVRadius)
    circleSizeBox.TextSize = 18
    circleSizeBox.Font = Enum.Font.SourceSans
    
    local speedBox = Instance.new("TextBox", gui)
    speedBox.Size = UDim2.new(0, 100, 0, 50)
    speedBox.Position = UDim2.new(1, -110, 0, 130)
    speedBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedBox.Text = "Enter Speed"
    speedBox.TextSize = 18
    speedBox.Font = Enum.Font.SourceSans

    toggleButton.MouseButton1Click:Connect(function()
        Aimbot.Enabled = not Aimbot.Enabled
        toggleButton.Text = Aimbot.Enabled and "Aimbot: ON" or "Aimbot: OFF"
        if not Aimbot.Enabled then
            Aimbot.LockedTarget = nil
        else
            Aimbot.LockedTarget = GetClosestTarget()
        end
    end)

    circleSizeBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            Aimbot.FOVRadius = tonumber(circleSizeBox.Text) or Aimbot.FOVRadius
            FOVCircle.Radius = Aimbot.FOVRadius
        end
    end)

    speedBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local newSpeed = tonumber(speedBox.Text)
            if newSpeed then
                LocalPlayer.Character.Humanoid.WalkSpeed = newSpeed
            end
        end
    end)
    
    return gui
end

LocalPlayer.CharacterAdded:Connect(function(character)
    wait(1) 
    if gui then
        gui:Destroy() 
    end
    gui = CreateGUI()
end)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    if Aimbot.Enabled then
        TrackPlayers()
    end
end)

local gui = CreateGUI()
