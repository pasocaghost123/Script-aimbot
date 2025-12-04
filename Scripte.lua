-- HACKER GAME SCRIPT v2.0 - Funciona no DELTA (2025)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Configurações
local Config = {
    Aimbot = {Enabled = false, FOV = 120, Smooth = 0.12, WallCheck = true, TeamCheck = true, Predict = true},
    ESP = {Enabled = false}
}

-- GUI Moderna (Dark Theme)
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local AimbotBtn = Instance.new("TextButton")
local ESPBtn = Instance.new("TextButton")
local FOVLabel = Instance.new("TextLabel")

ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "HackerPanel"

Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 320, 0, 280)
Frame.Position = UDim2.new(0, 20, 0.5, -140)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.BorderSizePixel = 0
Frame.Visible = false

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = Frame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(60, 60, 70)
UIStroke.Thickness = 2
UIStroke.Parent = Frame

-- Título
Title.Parent = Frame
Title.Size = UDim2.new(1, 0, 0, 60)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
Title.Text = "🎮 HACKER PANEL v2.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextStrokeTransparency = 0.8

-- Botões
local function CreateButton(name, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = Frame
    btn.Size = UDim2.new(0.88, 0, 0, 50)
    btn.Position = UDim2.new(0.06, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    local corner = Instance.new("UICorner", btn); corner.CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", btn); stroke.Thickness = 1
    btn.MouseButton1Click:Connect(callback)
    return btn
end

AimbotBtn = CreateButton("Aimbot", 80, function()
    Config.Aimbot.Enabled = not Config.Aimbot.Enabled
    AimbotBtn.Text = "Aimbot: " .. (Config.Aimbot.Enabled and "ON" or "OFF")
    AimbotBtn.TextColor3 = Config.Aimbot.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
end)

ESPBtn = CreateButton("ESP", 140, function()
    Config.ESP.Enabled = not Config.ESP.Enabled
    ESPBtn.Text = "ESP: " .. (Config.ESP.Enabled and "ON" or "OFF")
    ESPBtn.TextColor3 = Config.ESP.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
end)

-- Toggle GUI (RightShift)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        Frame.Visible = not Frame.Visible
    end
end)

-- ESP System (Cubo + Nome + Vida)
local ESPs = {}
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local char = player.Character or player.CharacterAdded:Wait()
    local head = char:WaitForChild("Head")
    local root = char:WaitForChild("HumanoidRootPart")
    local humanoid = char:WaitForChild("Humanoid")
    
    -- Billboard GUI
    local billboard = Instance.new("BillboardGui")
    billboard.Parent = head
    billboard.Size = UDim2.new(0, 200, 0, 100)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    
    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.new(1,1,1)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 16
    
    local healthBar = Instance.new("Frame", billboard)
    healthBar.Size = UDim2.new(1, -10, 0.3, 0)
    healthBar.Position = UDim2.new(0, 5, 0.5, 0)
    healthBar.BackgroundColor3 = Color3.new(0,1,0)
    local corner = Instance.new("UICorner", healthBar)
    corner.CornerRadius = UDim.new(0, 4)
    
    -- Cubo ESP
    local cube = Instance.new("Part")
    cube.Parent = workspace
    cube.Size = Vector3.new(3, 3, 3)
    cube.Material = Enum.Material.Neon
    cube.BrickColor = BrickColor.new("Bright blue")
    cube.CanCollide = false
    cube.Anchored = true
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = cube
    weld.Part1 = root
    weld.Parent = cube
    
    ESPs[player] = {billboard, nameLabel, healthBar, cube, humanoid}
end

local function UpdateESP()
    for player, esp in pairs(ESPs) do
        if player.Character and esp[5] then
            local health = esp[5].Health / esp[5].MaxHealth
            esp[2].Text = player.Name .. " [" .. math.floor(esp[5].Health) .. "]"
            esp[3].Size = UDim2.new(health, 0, 1, 0)
            esp[3].BackgroundColor3 = health > 0.5 and Color3.new(0,1,0) or Color3.new(1,0,0)
            esp[4].CFrame = player.Character.HumanoidRootPart.CFrame
        else
            for _, obj in pairs(esp) do obj:Destroy() end
            ESPs[player] = nil
        end
    end
end

-- Aimbot (Inimigo mais próximo + Wallcheck + Teamcheck)
local function GetClosestEnemy()
    local closest, shortestDist = nil, Config.Aimbot.FOV
    local mousePos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if Config.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            
            if dist < shortestDist and onScreen then
                if Config.Aimbot.WallCheck then
                    local ray = workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 500)
                    if ray and ray.Instance:IsDescendantOf(player.Character) then
                        closest = player
                        shortestDist = dist
                    end
                else
                    closest = player
                    shortestDist = dist
                end
            end
        end
    end
    return closest
end

-- Main Loop
RunService.Heartbeat:Connect(function()
    if Config.ESP.Enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if not ESPs[player] and player.Character then
                CreateESP(player)
            end
        end
        UpdateESP()
    end
    
    if Config.Aimbot.Enabled then
        local target = GetClosestEnemy()
        if target and target.Character:FindFirstChild("Head") then
            local aimPos = target.Character.Head.Position
            if Config.Aimbot.Predict and target.Character:FindFirstChild("HumanoidRootPart") then
                aimPos = aimPos + target.Character.HumanoidRootPart.Velocity * 0.1
            end
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimPos), Config.Aimbot.Smooth)
        end
    end
end)

-- Auto ESP para novos players
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if Config.ESP.Enabled then
            wait(1)
            CreateESP(player)
        end
    end)
end)
