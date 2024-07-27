-- Silent Aimbot Script with Crosshair, Toggle GUI, Player ESP, and Spin Function
-- Created by z-aq © 2024
-- This script is for educational purposes.

--// Cache
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Load and execute GitHub content
local function LoadGitHubContent(url)
    local success, response = pcall(function()
        return HttpService:GetAsync(url)
    end)

    if success then
        local func = loadstring(response)
        if func then
            func()
        else
            warn("Failed to load function from GitHub content.")
        end
    else
        warn("Failed to get GitHub content: " .. response)
    end
end

local githubUrl = "https://raw.githubusercontent.com/8Zino99/guy.s/main/aim.lua"
LoadGitHubContent(githubUrl)

--// Aimbot Settings | try to anfford the close,open tap.
local Aimbot = {
    Enabled = false,
    FOVRadius = 100,
    LockPart = "Head",
    Smoothness = 0.05,
    MaxDistance = 1000 -- Maximum distance to target in studs
}

--// aimlockService
local aimlockService = {}
local aimlockTarget

function aimlockService.acquire(target)
    aimlockTarget = target
end

function aimlockService.release()
    aimlockTarget = nil
end

--// Utility Functions
local function GetDistanceFromCursor(pos)
    local centerPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    return (Vector2.new(pos.X, pos.Y) - centerPos).Magnitude
end

local function GetClosestTarget()
    local closestTarget, closestDist = nil, Aimbot.FOVRadius

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Aimbot.LockPart) then
            local targetPos = player.Character[Aimbot.LockPart].Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
            local distance = (targetPos - Camera.CFrame.Position).Magnitude

            if onScreen and distance <= Aimbot.MaxDistance then
                local dist = GetDistanceFromCursor(screenPos)
                if dist < closestDist then
                    closestDist = dist
                    closestTarget = player
                end
            end
        end
    end

    return closestTarget
end

local function AimAt(target)
    if not target or not target.Character then return end

    aimlockService.acquire(target)
    local targetPosition = target.Character[Aimbot.LockPart].Position
    local direction = (targetPosition - Camera.CFrame.Position).Unit

    -- Implement smooth aiming
    local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
    if Aimbot.Smoothness > 0 then
        local tweenInfo = TweenInfo.new(Aimbot.Smoothness, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local tween = TweenService:Create(Camera, tweenInfo, { CFrame = targetCFrame })
        tween:Play()
    else
        Camera.CFrame = targetCFrame
    end
end

--// GUI Creation Function
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local Crosshair = Instance.new("Frame")
    Crosshair.Name = "Crosshair"
    Crosshair.Parent = ScreenGui
    Crosshair.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Crosshair.Size = UDim2.new(0, Aimbot.FOVRadius * 2, 0, Aimbot.FOVRadius * 2)
    Crosshair.Position = UDim2.new(0.5, -Aimbot.FOVRadius, 0.5, -Aimbot.FOVRadius)
    Crosshair.BackgroundTransparency = 1
    Crosshair.BorderSizePixel = 0

    local Circle = Instance.new("UICorner")
    Circle.Parent = Crosshair
    Circle.CornerRadius = UDim.new(1, 0)

    local Stroke = Instance.new("UIStroke")
    Stroke.Parent = Crosshair
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = 2

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = ScreenGui
    ToggleButton.Text = "Aimbot: OFF"
    ToggleButton.Position = UDim2.new(1, -120, 0, 20)
    ToggleButton.Size = UDim2.new(0, 80, 0, 40)
    ToggleButton.AnchorPoint = Vector2.new(1, 0)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextScaled = true
    ToggleButton.TextWrapped = true

    ToggleButton.MouseButton1Click:Connect(function()
        Aimbot.Enabled = not Aimbot.Enabled
        if Aimbot.Enabled then
            ToggleButton.Text = "Aimbot: ON"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        else
            ToggleButton.Text = "Aimbot: OFF"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            aimlockService.release()
        end
    end)

    local SpinButton = Instance.new("TextButton")
    SpinButton.Name = "SpinButton"
    SpinButton.Parent = ScreenGui
    SpinButton.Text = "Spin: OFF"
    SpinButton.Position = UDim2.new(1, -120, 0, 70)
    SpinButton.Size = UDim2.new(0, 80, 0, 40)
    SpinButton.AnchorPoint = Vector2.new(1, 0)
    SpinButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    SpinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpinButton.TextScaled = true
    SpinButton.TextWrapped = true

    SpinButton.MouseButton1Click:Connect(function()
        Spin.Enabled = not Spin.Enabled
        if Spin.Enabled then
            SpinButton.Text = "Spin: ON"
            SpinButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            SpinCharacter()
        else
            SpinButton.Text = "Spin: OFF"
            SpinButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
    end)
end

CreateGUI()

-- Ensure GUI persists on respawn
LocalPlayer.CharacterAdded:Connect(function()
    wait(1)  -- Wait for character to load
    CreateGUI()
end)

--// ESP Functionality
local function CreateESP(player)
    local function CreateBox()
        local Box = Instance.new("BoxHandleAdornment")
        Box.Size = player.Character:GetExtentsSize()
        Box.Adornee = player.Character.PrimaryPart
        Box.AlwaysOnTop = true
        Box.ZIndex = 10
        Box.Color3 = Color3.fromRGB(0, 255, 255)
        Box.Transparency = 0.5
        Box.Parent = player.Character

        player.Character.PrimaryPart:GetPropertyChangedSignal("Position"):Connect(function()
            Box.Adornee = player.Character.PrimaryPart
        end)
    end

    CreateBox()

    player.CharacterAdded:Connect(function()
        if player.Character:FindFirstChild("BoxHandleAdornment") then
            player.Character.BoxHandleAdornment:Destroy()
        end
        CreateBox()
    end)
end

-- Create ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character then
        CreateESP(player)
    end
end

-- Create ESP for new players
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        CreateESP(player)
    end)
end)

-- Aimbot functionality
RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled then
        local target = GetClosestTarget()
        if target then
            AimAt(target)
        end
    end
end)
