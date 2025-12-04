local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local cam = workspace.CurrentCamera
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")

local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

local toggleButton = Instance.new("TextButton", gui)
toggleButton.Size = UDim2.new(0, 120, 0, 40)
toggleButton.Position = UDim2.new(0, 20, 0, 20)
toggleButton.Text = "Abrir Painel"
toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleButton.TextColor3 = Color3.new(1,1,1)

local panel = Instance.new("Frame", gui)
panel.Size = UDim2.new(0, 250, 0, 300)
panel.Position = UDim2.new(0, 20, 0, 70)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
panel.Visible = false

local aimToggle = Instance.new("TextButton", panel)
aimToggle.Size = UDim2.new(1, -20, 0, 40)
aimToggle.Position = UDim2.new(0, 10, 0, 10)
aimToggle.Text = "Aimbot Simulado: OFF"
aimToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
aimToggle.TextColor3 = Color3.new(1,1,1)

local espToggle = Instance.new("TextButton", panel)
espToggle.Size = UDim2.new(1, -20, 0, 40)
espToggle.Position = UDim2.new(0, 10, 0, 60)
espToggle.Text = "ESP Simulado: OFF"
espToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
espToggle.TextColor3 = Color3.new(1,1,1)

local dragging = false
local dragInput, dragStart, startPos

local function updateDrag(input)
	local delta = input.Position - dragStart
	panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

panel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = panel.Position
	end
end)

panel.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

uis.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		updateDrag(input)
	end
end)

toggleButton.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
end)

local aimbot = false
local esp = false

aimToggle.MouseButton1Click:Connect(function()
	aimbot = not aimbot
	aimToggle.Text = "Aimbot Simulado: " .. (aimbot and "ON" or "OFF")
end)

espToggle.MouseButton1Click:Connect(function()
	esp = not esp
	espToggle.Text = "ESP Simulado: " .. (esp and "ON" or "OFF")
end)

local espFolder = Instance.new("Folder", gui)

local function getNearestEnemy()
	local nearest = nil
	local nearestDist = math.huge

	for _, plr in pairs(game.Players:GetPlayers()) do
		if plr ~= player and plr.Team ~= player.Team then
			local char = plr.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChild("Humanoid")
			if hrp and hum and hum.Health > 0 then
				local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
				if onScreen then
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
					local ray = Ray.new(cam.CFrame.Position, (hrp.Position - cam.CFrame.Position).Unit * 999)
					local hit = workspace:FindPartOnRay(ray, player.Character)
					if hit and hit:IsDescendantOf(char) then
						if dist < nearestDist then
							nearestDist = dist
							nearest = hrp
						end
					end
				end
			end
		end
	end
	return nearest
end

local tool
player.CharacterAdded:Connect(function(char)
	tool = char:WaitForChild("Tool", 5)
end)

rs.RenderStepped:Connect(function()
	if esp then
		espFolder:ClearAllChildren()
		for _, plr in pairs(game.Players:GetPlayers()) do
			if plr ~= player then
				local char = plr.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				local hum = char and char:FindFirstChild("Humanoid")
				if hrp and hum and hum.Health > 0 then
					local box = Drawing.new("Square")
					box.Size = Vector2.new(80, 120)
					box.Position = Vector2.new(
						cam:WorldToViewportPoint(hrp.Position).X - 40,
						cam:WorldToViewportPoint(hrp.Position).Y - 60
					)
					box.Color = (plr.Team == player.Team and Color3.new(0,1,0) or Color3.new(1,0,0))
					box.Thickness = 2
					box.Filled = false
					box.Visible = true
					table.insert(espFolder:GetChildren(), box)
				end
			end
		end
	end
end)

if tool then
	tool.Activated:Connect(function()
		if aimbot then
			local target = getNearestEnemy()
			if target then
				cam.CFrame = CFrame.lookAt(cam.CFrame.Position, target.Position)
			end
		end
	end)
end
