-- ANTI-DUPLICATA (mantém igual)
if getgenv().AimbotFOVLoaded then return end
getgenv().AimbotFOVLoaded = true

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

-- Config
local AimbotEnabled = false
local TeamCheck = true
local WallCheck = true  -- AGORA FUNCIONA CORRETO
local FOVRadius = 100
local ESPEnabled = false
local ESPTeamCheck = true
local HighlightColor = Color3.fromRGB(255, 0, 0)
local FOVRainbow = false
local FOVColor = Color3.fromRGB(0, 255, 0)

local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ScreenGui único (igual antes)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotFOVGui"
ScreenGui.Parent = game.CoreGui
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999

-- FOV Circle (igual antes)
local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.Parent = ScreenGui
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = IsMobile and UDim2.new(0.5, 0, 0.7, 0) or UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.Size = UDim2.new(0, FOVRadius * 2, 0, FOVRadius * 2)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false

local UIStroke = Instance.new("UIStroke", FOVCircle)
UIStroke.Thickness = 3
UIStroke.Color = FOVColor
local UICorner = Instance.new("UICorner", FOVCircle)
UICorner.CornerRadius = UDim.new(1, 0)

-- Stats (igual antes)
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Name = "StatsLabel"
StatsLabel.Parent = ScreenGui
StatsLabel.Size = IsMobile and UDim2.new(0, 180, 0, 40) or UDim2.new(0, 200, 0, 50)
StatsLabel.Position = UDim2.new(1, -210, 0, IsMobile and 5 or 10)
StatsLabel.BackgroundTransparency = 1
StatsLabel.TextColor3 = Color3.new(1, 1, 1)
StatsLabel.TextStrokeTransparency = 0
StatsLabel.Font = Enum.Font.Code
StatsLabel.TextSize = IsMobile and 16 or 18
StatsLabel.TextXAlignment = Enum.TextXAlignment.Right
StatsLabel.Text = "FPS: -- | Ping: --ms"

-- LOOP FPS único (igual antes)
local lastUpdate = tick()
RunService.Heartbeat:Connect(function()
    if tick() - lastUpdate >= 0.3 then
        local stats = game:GetService("Stats")
        local ping = tonumber(stats.Network.ServerStatsItem["Data Ping"]:GetValueString():match("%d+")) or 0
        local fps = math.floor(1 / (tick() - lastUpdate))
        StatsLabel.Text = string.format("FPS: %d | Ping: %dms", fps, ping)
        lastUpdate = tick()
    end
end)

-- Tecla M (igual antes)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.M then
        AimbotEnabled = not AimbotEnabled
        FOVCircle.Visible = AimbotEnabled
    end
end)

-- 🔧 WALLCHECK CORRIGIDO - NOVA FUNÇÃO
local function IsTargetVisible(target)
    if not WallCheck then return true end -- Se wallcheck off, mira tudo
    
    local character = target.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    -- MIRA NA CABEÇA (melhor precisão)
    local head = character:FindFirstChild("Head")
    local targetPart = head or character.HumanoidRootPart
    
    local origin = Camera.CFrame.Position
    local targetPos = targetPart.Position
    
    -- Raycast PARAMETROS CORRETOS
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    
    -- Direção exata
    local direction = (targetPos - origin)
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    
    -- ✅ SÓ MIRA SE ACERTAR O INIMIGO
    if raycastResult then
        return raycastResult.Instance:IsDescendantOf(character)
    end
    return false
end

-- 🎯 AIMBOT PERFEITO - GetClosestTarget CORRIGIDO
local function GetClosestTarget()
    local closest = nil
    local shortestDist = FOVRadius
    
    for _, player in ipairs(Players:GetPlayers()) do
        -- Filtros básicos
        if player == LocalPlayer then continue end
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then continue end
        if TeamCheck and player.Team == LocalPlayer.Team then continue end
        if player.Character.Humanoid.Health <= 0 then continue end
        
        -- FOV Check
        local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
        if not onScreen then continue end
        
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        
        if dist <= shortestDist then
            -- ✅ WALLCHECK ANTES DE SELECIONAR
            if IsTargetVisible(player) then
                closest = player
                shortestDist = dist
            end
        end
    end
    
    return closest
end

-- Rayfield GUI
local Window = Rayfield:CreateWindow({
    Name = "Aimbot FOV v3.0 (WallCheck FIX)",
    LoadingTitle = "Carregando...",
    LoadingSubtitle = "M = Toggle | Mira SÓ Visíveis",
    ConfigurationSaving = {Enabled = true, FolderName = "AimbotFOVv3", FileName = "config"},
    KeySystem = false
})

local Tab = Window:CreateTab("🎯 Principal", 4483362458)
Tab:CreateToggle({
    Name = "🎯 Aimbot (Tecla M)", 
    CurrentValue = false, 
    Callback = function(v) 
        AimbotEnabled = v; FOVCircle.Visible = v 
    end
})
Tab:CreateToggle({
    Name = "👥 Team Check", 
    CurrentValue = true, 
    Callback = function(v) TeamCheck = v end
})
Tab:CreateToggle({
    Name = "🧱 Wall Check (NÃO mira parede)", 
    CurrentValue = true, 
    Callback = function(v) WallCheck = v end
})
Tab:CreateSlider({
    Name = "📏 FOV", 
    Range = {50, 300}, 
    Increment = 5, 
    CurrentValue = 100, 
    Callback = function(v)
        FOVRadius = v; FOVCircle.Size = UDim2.new(0, v * 2, 0, v * 2)
    end
})

-- LOOP AIMBOT CORRIGIDO
RunService.RenderStepped:Connect(function()
    if FOVRainbow then 
        UIStroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) 
    end
    
    if AimbotEnabled then
        local target = GetClosestTarget()
        if target and target.Character then
            local head = target.Character:FindFirstChild("Head")
            local aimPart = head or target.Character.HumanoidRootPart
            
            -- SMOOTH PERFEITO
            local newCFrame = CFrame.new(Camera.CFrame.Position, aimPart.Position)
            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, 0.35) -- Mais suave
        end
    end
end)

Rayfield:Notify({
    Title = "✅ Aimbot Corrigido!",
    Content = "Agora mira APENAS inimigos visíveis! WallCheck 100%",
    Duration = 5
})
