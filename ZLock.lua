-- by ZINO👾 join discord! https://discord.gg/vWWM9nArfB
local P = game:GetService("Players")
local R = game:GetService("RunService")
local C = workspace.CurrentCamera
local U = game:GetService("UserInputService")
local L = P.LocalPlayer


local A = {
    E = false,
    F = 150,
    P = "Head",
    M = 1000,
    S = 0.1,
    D = 0.1,
    A = true,
    FOV = true,
    T = nil
}


local E = {
    E = true,
    C = Color3.fromRGB(0, 255, 0),
    N = Color3.fromRGB(255, 255, 255),
    T = 2
}

local FOVC = Drawing.new("Circle")
FOVC.Thickness = 2
FOVC.Radius = A.F
FOVC.Color = Color3.fromRGB(0, 255, 0)
FOVC.Filled = false
FOVC.Position = Vector2.new(C.ViewportSize.X / 2, C.ViewportSize.Y / 2)
FOVC.Visible = A.FOV

local ESPs = {}


local function CESP(p)
    local c = p.Character
    if not c then return end

    local r = c:FindFirstChild("HumanoidRootPart")
    local h = c:FindFirstChild("Head")
    if not r or not h then return end

    local b = Drawing.new("Square")
    b.Thickness = E.T
    b.Color = E.C
    b.Visible = true
    b.Filled = false

    local n = Drawing.new("Text")
    n.Text = p.Name
    n.Size = 18
    n.Color = E.N
    n.Center = true
    n.Outline = true
    n.OutlineColor = Color3.new(0, 0, 0)

    ESPs[p] = {box = b, nameTag = n}

    local function UESP()
        if not p.Character or not r or not h or not r:IsDescendantOf(workspace) then
            b.Visible = false
            n.Visible = false
            return
        end

        local rp, onScreen = C:WorldToViewportPoint(r.Position)
        local hp = C:WorldToViewportPoint(h.Position)

        if onScreen then
            b.Size = Vector2.new(2000 / rp.Z, 2500 / rp.Z)
            b.Position = Vector2.new(rp.X - b.Size.X / 2, rp.Y - b.Size.Y / 2)

            n.Position = Vector2.new(hp.X, hp.Y - 20)
            n.Visible = true
            b.Visible = true
        else
            n.Visible = false
            b.Visible = false
        end
    end

    local conn = R.RenderStepped:Connect(UESP)

    p.CharacterRemoving:Connect(function()
        if ESPs[p] then
            ESPs[p].box:Remove()
            ESPs[p].nameTag:Remove()
            ESPs[p] = nil
        end
        conn:Disconnect()
    end)
end

local function AESP()
    for _, p in ipairs(P:GetPlayers()) do
        if p ~= L then
            p.CharacterAdded:Connect(function()
                wait(1)
                CESP(p)
            end)
            if p.Character then
                CESP(p)
            end
        end
    end
end

P.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        wait(1)
        CESP(p)
    end)
end)

P.PlayerRemoving:Connect(function(p)
    if ESPs[p] then
        ESPs[p].box:Remove()
        ESPs[p].nameTag:Remove()
        ESPs[p] = nil
    end
end)

AESP()


local function GCT()
    local closest = nil
    local minDist = math.huge

    for _, p in pairs(P:GetPlayers()) do
        if p ~= L and p.Character and p.Character:FindFirstChild(A.P) then
            local tP = p.Character[A.P]
            local tPos, onScreen = C:WorldToViewportPoint(tP.Position)

            if onScreen then
                local dist = (Vector2.new(tPos.X, tPos.Y) - Vector2.new(C.ViewportSize.X / 2, C.ViewportSize.Y / 2)).Magnitude
                if dist <= A.F then
                    local distFromCamera = (tP.Position - C.CFrame.Position).Magnitude
                    if distFromCamera <= A.M and dist < minDist then
                        minDist = dist
                        closest = p
                    end
                end
            end
        end
    end

    return closest
end

local function PM(target)
    local tP = target.Character:FindFirstChild(A.P)
    if not tP then return tP.Position end
    local v = tP.Velocity
    return tP.Position + (v * A.D)
end

local function AA(target)
    if target and target.Character then
        local tPos = PM(target)
        local tP = target.Character:FindFirstChild(A.P)
        if tP then
            local tCFrame = CFrame.new(C.CFrame.Position, tPos)
            C.CFrame = tCFrame
            if A.A then
                local tool = L.Backpack:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
            end
        end
    end
end

local function TP()
    if A.T then
        AA(A.T)
    else
        A.T = GCT()
    end
end


local function CGUI()
    local g = Instance.new("ScreenGui", L.PlayerGui)
    
    local b = Instance.new("TextButton", g)
    b.Size = UDim2.new(0, 100, 0, 50)
    b.Position = UDim2.new(1, -110, 0, 10)
    b.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Text = "Aimbot: OFF"
    b.TextSize = 18
    b.Font = Enum.Font.SourceSans
    
    local cBox = Instance.new("TextBox", g)
    cBox.Size = UDim2.new(0, 100, 0, 50)
    cBox.Position = UDim2.new(1, -110, 0, 70)
    cBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    cBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    cBox.Text = tostring(A.F)
    cBox.TextSize = 18
    cBox.Font = Enum.Font.SourceSans
    
    local sBox = Instance.new("TextBox", g)
    sBox.Size = UDim2.new(0, 100, 0, 50)
    sBox.Position = UDim2.new(1, -110, 0, 130)
    sBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    sBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    sBox.Text = "Enter Speed"
    sBox.TextSize = 18
    sBox.Font = Enum.Font.SourceSans

    b.MouseButton1Click:Connect(function()
        A.E = not A.E
        b.Text = A.E and "Aimbot: ON" or "Aimbot: OFF"
        if not A.E then
            A.T = nil
        else
            A.T = GCT()
        end
    end)

    cBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            A.F = tonumber(cBox.Text) or A.F
            FOVC.Radius = A.F
        end
    end)

    sBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local newSpeed = tonumber(sBox.Text)
            if newSpeed then
                L.Character.Humanoid.WalkSpeed = newSpeed
            end
        end
    end)
    
    return g
end

L.CharacterAdded:Connect(function(c)
    wait(1) 
    if gui then
        gui:Destroy() 
    end
    gui = CGUI()
end)

R.RenderStepped:Connect(function()
    FOVC.Position = Vector2.new(C.ViewportSize.X / 2, C.ViewportSize.Y / 2)
    if A.E then
        TP()
    end
end)


local gui = CGUI()
