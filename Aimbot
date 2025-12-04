--========================--
-- SIMULADOR SEGURO DE HACK
-- PARA TESTAR ANTI-CHEAT
-- NÃO É CHEAT REAL
--========================--

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local TeamCheck = true
local WallCheck = true

-- Estados
local Aimbot = false
local ESP = false
local FOV = false

--========================--
-- GUI PRINCIPAL (Menu B + C)
--========================--

local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.ResetOnSpawn = false

-- Botão flutuante
local OpenButton = Instance.new("TextButton", ScreenGui)
OpenButton.Size = UDim2.new(0, 60, 0, 60)
OpenButton.Position = UDim2.new(0.12, 0, 0.35, 0)
OpenButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.Text = "≡"
OpenButton.Active = true
OpenButton.Draggable = true
OpenButton.BorderSizePixel = 0

-- Menu principal
local Menu = Instance.new("Frame", ScreenGui)
Menu.Size = UDim2.new(0, 320, 0, 260)
Menu.Position = UDim2.new(0.15, 0, 0.28, 0)
Menu.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Menu.Visible = false
Menu.BorderSizePixel = 0

local UIGradient = Instance.new("UIGradient", Menu)
UIGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 18))
}

local UIList = Instance.new("UIListLayout", Menu)
UIList.Padding = UDim.new(0, 6)
UIList.FillDirection = Enum.FillDirection.Vertical

OpenButton.MouseButton1Click:Connect(function()
	Menu.Visible = not Menu.Visible
end)

--=========== Função botão minimalista (C) =========--
local function NewToggle(text, callback)
	local b = Instance.new("TextButton", Menu)
	b.Size = UDim2.new(1, -10, 0, 38)
	b.Position = UDim2.new(0, 5, 0, 5)
	b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 16
	b.BorderSizePixel = 0
	b.Text = text .. " : OFF"

	local state = false

	b.MouseButton1Click:Connect(function()
		state = not state
		b.Text = text .. (state and " : ON" or " : OFF")
		callback(state)
	end)
end

--======== Botões =======--

NewToggle("Aimbot Simulado", function(s) Aimbot = s end)
NewToggle("ESP Simulado", function(s) ESP = s end)
NewToggle("FOV Simulado", function(s) FOV = s end)

-------------------------------------------------------------
-- FOV (simulado, seguro)
-------------------------------------------------------------
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = 120
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 0)
FOVCircle.Visible = false
FOVCircle.Filled = false

-------------------------------------------------------------
-- ESP (simulação segura)
-------------------------------------------------------------
local function DrawESP(player)
	if player == LocalPlayer then return end
	if not player.Character then return end
	if not player.Character:FindFirstChild("HumanoidRootPart") then return end

	-- Team Check
	if TeamCheck and player.Team == LocalPlayer.Team then
		return
	end

	local hrp = player.Character.HumanoidRootPart
	local pos, visible = Camera:WorldToViewportPoint(hrp.Position)

	if not visible then return end

	-- Caixa (simulada)
	local box = Drawing.new("Square")
	box.Size = Vector2.new(60, 80)
	box.Position = Vector2.new(pos.X - 30, pos.Y - 40)
	box.Color = Color3.fromRGB(0, 255, 0)
	box.Thickness = 2

	-- Barra de vida fake (não pega HP real)
	local bar = Drawing.new("Line")
	bar.From = Vector2.new(pos.X - 40, pos.Y - 40)
	bar.To = Vector2.new(pos.X - 40, pos.Y + 40)
	bar.Color = Color3.fromRGB(255, 0, 0)
	bar.Thickness = 3

	task.delay(0.05, function()
		box:Remove()
		bar:Remove()
	end)
end

-------------------------------------------------------------
-- AIMBOT (simulação segura)
-- NÃO trava em parede
-- NÃO mira em aliados
-- NÃO atira
-------------------------------------------------------------

local function CanSee(targetPart)
	local origin = Camera.CFrame.Position
	local direction = (targetPart.Position - origin).Unit * 500

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = { LocalPlayer.Character }

	local ray = workspace:Raycast(origin, direction, params)

	if not ray then return true end
	return ray.Instance:IsDescendantOf(targetPart.Parent)
end

local function GetClosestEnemy()
	local closest, dist = nil, 9999
	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then

			if TeamCheck and plr.Team == LocalPlayer.Team then
				continue
			end

			local head = plr.Character.Head
			local pos, visible = Camera:WorldToViewportPoint(head.Position)

			if visible then
				if WallCheck and not CanSee(head) then
					continue
				end

				local mousePos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
				local distNow = (mousePos - Vector2.new(pos.X, pos.Y)).Magnitude

				if distNow < dist then
					dist = distNow
					closest = head
				end
			end
		end
	end
	return closest
end

RunService.RenderStepped:Connect(function()
	FOVCircle.Visible = FOV
	FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

	if ESP then
		for _,p in pairs(Players:GetPlayers()) do
			DrawESP(p)
		end
	end

	if Aimbot then
		local target = GetClosestEnemy()
		if target then
			Camera.CFrame = Camera.CFrame:Lerp(
				CFrame.new(Camera.CFrame.Position, target.Position),
				0.15
			)
		end
	end
end)
