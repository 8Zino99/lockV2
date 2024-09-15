-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

-- Player
local LocalPlayer = Players.LocalPlayer

-- Aimbot Settings
local Aimbot = {
    Enabled = false,
    FOVRadius = 100,
    LockPart = "HumanoidRootPart",
    Smoothness = 0.1,
    MaxDistance = 500, -- Adjust the max distance for bullet redirection
    HitChance = 1 -- 1 for 100% hit rate
}

-- UI Creation and Setup
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SettingsGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -200)
    MainFrame.Size = UDim2.new(0, 400, 0, 300)
    MainFrame.ClipsDescendants = true

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Font = Enum.Font.SourceSansBold
    Title.Text = "Aimbot & ESP Settings"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextScaled = true

    -- Silent Aim Toggle
    local SilentAimFrame = Instance.new("Frame")
    SilentAimFrame.Parent = MainFrame
    SilentAimFrame.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
    SilentAimFrame.BorderSizePixel = 0
    SilentAimFrame.Position = UDim2.new(0, 0, 0, 50)
    SilentAimFrame.Size = UDim2.new(1, 0, 0, 60)
    
    local SilentAimLabel = Instance.new("TextLabel")
    SilentAimLabel.Parent = SilentAimFrame
    SilentAimLabel.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
    SilentAimLabel.BorderSizePixel = 0
    SilentAimLabel.Size = UDim2.new(0.7, 0, 1, 0)
    SilentAimLabel.Font = Enum.Font.SourceSansBold
    SilentAimLabel.Text = "Silent Aim"
    SilentAimLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SilentAimLabel.TextScaled = true

    local SilentAimToggle = Instance.new("TextButton")
    SilentAimToggle.Parent = SilentAimFrame
    SilentAimToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    SilentAimToggle.BorderSizePixel = 0
    SilentAimToggle.Position = UDim2.new(0.7, 0, 0, 0)
    SilentAimToggle.Size = UDim2.new(0.3, 0, 1, 0)
    SilentAimToggle.Font = Enum.Font.SourceSansBold
    SilentAimToggle.Text = "OFF"
    SilentAimToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SilentAimToggle.TextScaled = true

    SilentAimToggle.MouseButton1Click:Connect(function()
        Aimbot.Enabled = not Aimbot.Enabled
        SilentAimToggle.Text = Aimbot.Enabled and "ON" or "OFF"
        SilentAimToggle.BackgroundColor3 = Aimbot.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)

    -- Minimize/Restore Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Parent = MainFrame
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Position = UDim2.new(1, -30, 0, 0)
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Font = Enum.Font.SourceSansBold
    MinimizeButton.Text = "-"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.TextScaled = true

    local function Minimize()
        MainFrame.Visible = false
        MinimizeButton.Text = "+"
    end

    local function Restore()
        MainFrame.Visible = true
        MinimizeButton.Text = "-"
    end

    MinimizeButton.MouseButton1Click:Connect(function()
        if MainFrame.Visible then
            Minimize()
        else
            Restore()
        end
    end)

    -- Command to reopen UI
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Slash and UserInputService:GetFocusedTextBox() == nil then
            local chatInput = Instance.new("TextBox")
            chatInput.Text = ""
            chatInput.Parent = ScreenGui
            chatInput.FocusLost:Connect(function()
                if chatInput.Text:lower() == "/open" then
                    Restore()
                end
                chatInput:Destroy()
            end)
            chatInput:CaptureFocus()
        end
    end)

    -- UI Initialization
end

-- Utility Functions
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

            if onScreen then
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

    local targetPosition = target.Character[Aimbot.LockPart].Position
    local direction = (targetPosition - Camera.CFrame.Position).Unit

    if Aimbot.Smoothness > 0 then
        local tweenInfo = TweenInfo.new(Aimbot.Smoothness, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
        local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
        local tween = TweenService:Create(Camera, tweenInfo, { CFrame = targetCFrame })
        tween:Play()
    else
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction * 1000)
    end
end

-- Bullet Redirection Logic
local function RedirectBullet(target)
    if target and target.Character and Aimbot.Enabled then
        local hitChance = math.random()
        if hitChance <= Aimbot.HitChance then
            local targetPosition = target.Character[Aimbot.LockPart].Position
            -- Simulate bullet direction redirection to the target
            -- You can modify this part based on how your game handles bullets or projectiles
            print("Redirecting bullet to", target.Name)
        end
    end
end

-- Aimbot functionality
RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled then
        local target = GetClosestTarget()
        if target then
            AimAt(target)
            -- Show the line indicating the target
            -- You can create a GUI line or an effect here to visualize the targeting
            RedirectBullet(target)
        end
    end
end)

-- Initialize UI
CreateUI()
