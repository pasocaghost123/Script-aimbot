--[[  
===========================================
 SISTEMA DE TESTE INTERNO (AIMBOT + ESP)
 Painel móvel + ESP 3D + HP Bar + Aimbot + FOV
 100% permitido dentro do seu próprio jogo.
===========================================
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CONFIGURAÇÕES GLOBAIS
_G.ESPAtivo = false
_G.AimbotAtivo = false
_G.FOV = 200 -- FOV inicial

-------------------------------------------------------
-- GUI / PAINEL DE CONTROLE
-------------------------------------------------------
local screen = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
screen.ResetOnSpawn = false

local painel = Instance.new("Frame", screen)
painel.Size = UDim2.new(0, 250, 0, 210)
painel.Position = UDim2.new(0.05, 0, 0.15, 0)
painel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
painel.Active = true
painel.Draggable = true

local title = Instance.new("TextLabel", painel)
title.Size = UDim2.new(1, 0, 0, 32)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.Text = "Painel de Teste"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

local espButton = Instance.new("TextButton", painel)
espButton.Size = UDim2.new(1, -20, 0, 40)
espButton.Position = UDim2.new(0, 10, 0, 45)
espButton.Text = "ESP: OFF"
espButton.BackgroundColor3 = Color3.fromRGB(45,45,45)
espButton.TextColor3 = Color3.new(1,1,1)

local aimbotButton = Instance.new("TextButton", painel)
aimbotButton.Size = UDim2.new(1, -20, 0, 40)
aimbotButton.Position = UDim2.new(0, 10, 0, 90)
aimbotButton.Text = "Aimbot: OFF"
aimbotButton.BackgroundColor3 = Color3.fromRGB(45,45,45)
aimbotButton.TextColor3 = Color3.new(1,1,1)

local fovSlider = Instance.new("TextButton", painel)
fovSlider.Size = UDim2.new(1, -20, 0, 40)
fovSlider.Position = UDim2.new(0, 10, 0, 140)
fovSlider.Text = "FOV: " .. _G.FOV
fovSlider.BackgroundColor3 = Color3.fromRGB(45,45,45)
fovSlider.TextColor3 = Color3.new(1,1,1)

espButton.MouseButton1Click:Connect(function()
	_G.ESPAtivo = not _G.ESPAtivo
	espButton.Text = "ESP: " .. (_G.ESPAtivo and "ON" or "OFF")
end)

aimbotButton.MouseButton1Click:Connect(function()
	_G.AimbotAtivo = not _G.AimbotAtivo
	aimbotButton.Text = "Aimbot: " .. (_G.AimbotAtivo and "ON" or "OFF")
end)

fovSlider.MouseButton1Click:Connect(function()
	_G.FOV = _G.FOV + 50
	if _G.FOV > 500 then _G.FOV = 50 end
	fovSlider.Text = "FOV: " .. _G.FOV
end)

-------------------------------------------------------
-- ESP 3D + BARRA DE VIDA
-------------------------------------------------------
local function criarHPBar(char)
	if char:FindFirstChild("HPBillboard") then return end

	local bill = Instance.new("BillboardGui")
	bill.Name = "HPBillboard"
	bill.Size = UDim2.new(4,0,1,0)
	bill.StudsOffset = Vector3.new(0, 4, 0)
	bill.AlwaysOnTop = true
	bill.Parent = char:WaitForChild("HumanoidRootPart")

	local barBG = Instance.new("Frame", bill)
	barBG.Size = UDim2.new(1,0,0.2,0)
	barBG.Position = UDim2.new(0,0,0.8,0)
	barBG.BackgroundColor3 = Color3.fromRGB(30,30,30)

	local bar = Instance.new("Frame", barBG)
	bar.Name = "HP"
	bar.Size = UDim2.new(1,0,1,0)
	bar.BackgroundColor3 = Color3.fromRGB(255,50,50)

	local hum = char:WaitForChild("Humanoid")
	hum.HealthChanged:Connect(function(hp)
		bar.Size = UDim2.new(hp / hum.MaxHealth, 0, 1, 0)
	end)
end

local function criarESP(char)
	if char:FindFirstChild("BoxESP") then return end

	local h = Instance.new("Highlight")
	h.Name = "BoxESP"
	h.FillTransparency = 0.75
	h.OutlineColor = Color3.fromRGB(0,255,255)
	h.Parent = char
end

-------------------------------------------------------
-- MAIN ESP LOOP
-------------------------------------------------------
task.spawn(function()
	while true do
		task.wait(0.2)

		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character then

				if _G.ESPAtivo then
					criarESP(plr.Character)
					criarHPBar(plr.Character)
				else
					if plr.Character:FindFirstChild("BoxESP") then
						plr.Character.BoxESP:Destroy()
					end
					if plr.Character:FindFirstChild("HumanoidRootPart")
					and plr.Character.HumanoidRootPart:FindFirstChild("HPBillboard") then
						plr.Character.HumanoidRootPart.HPBillboard:Destroy()
					end
				end
			end
		end
	end
end)

-------------------------------------------------------
-- AIMBOT COM FOV
-------------------------------------------------------
local function getAlvo()
	local mousePos = UIS:GetMouseLocation()
	local menor = math.huge
	local alvo = nil

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
			local headPos = plr.Character.Head.Position
			local screenPos, vis = Camera:WorldToViewportPoint(headPos)
			if vis then
				local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
				if dist < menor and dist < _G.FOV then
					menor = dist
					alvo = plr
				end
			end
		end
	end
	return alvo
end

RunService.RenderStepped:Connect(function()
	if not _G.AimbotAtivo then return end
	local alvo = getAlvo()
	if alvo and alvo.Character and alvo.Character:FindFirstChild("Head") then
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, alvo.Character.Head.Position)
	end
end)
