-- =========================
-- RAINBOW PERIASTRON | UI RAINBOW + DRAG IDÊNTICO AO EXPLODE
-- =========================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local enabled = false
local loopConnection
local hue = 0

-- =========================
-- RAINBOW PERIASTRON ACTIVATION (SIMULA TECLA Q)
-- =========================

local function startRainbowPeriastron()
    if loopConnection then return end
    
    loopConnection = RunService.Heartbeat:Connect(function()
        if not enabled then return end
        task.wait(0.05)
        
        local char = LocalPlayer.Character
        local bp = LocalPlayer.Backpack
        if not char or not bp then return end
        
        local tools = {}
        for _, t in bp:GetChildren() do
            if t.Name == "RainbowPeriastron" then table.insert(tools, t) end
        end
        for _, t in char:GetChildren() do
            if t.Name == "RainbowPeriastron" then table.insert(tools, t) end
        end
        
        for _, tool in tools do
            tool.Parent = char
            local remote = tool:FindFirstChild("Remote") or tool:FindFirstChild("ServerControl")
            if remote then
                pcall(function()
                    remote:FireServer(Enum.KeyCode.Q)
                end)
            end
        end
    end)
end

local function stopRainbowPeriastron()
    if loopConnection then
        loopConnection:Disconnect()
        loopConnection = nil
    end
end

-- =========================
-- GUI (VISUAL RAINBOW)
-- =========================

local gui = Instance.new("ScreenGui")
gui.Name = "RainbowUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 110, 0, 30)
main.Position = UDim2.new(1, -140, 0.25, 0)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = false  -- controlado manualmente
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

-- RAINBOW BORDER
local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2.5
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 50, 1, 0)
title.Position = UDim2.new(0, 6, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Rainbow"
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

-- SWITCH
local switch = Instance.new("Frame")
switch.Size = UDim2.new(0, 34, 0, 18)
switch.Position = UDim2.new(1, -38, 0.5, -9)
switch.BackgroundColor3 = Color3.fromRGB(255, 40, 40)  -- OFF vermelho
switch.BorderSizePixel = 0
switch.Parent = main
Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 14, 0, 14)
knob.Position = UDim2.new(0, 2, 0.5, -7)
knob.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
knob.BorderSizePixel = 0
knob.Parent = switch
Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

-- =========================
-- DRAG SYSTEM (CÓPIA EXATA DO SEU EXPLODE QUE FUNCIONA)
-- =========================
local dragging = false
local dragStart
local startPos

main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

main.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- =========================
-- TOGGLE (CLIQUE DIRETO NO SWITCH)
-- =========================
switch.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		enabled = not enabled

		if enabled then
			TweenService:Create(switch, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(255, 170, 0)  -- opcional: cor fixa ou rainbow abaixo
			}):Play()

			TweenService:Create(knob, TweenInfo.new(0.2), {
				Position = UDim2.new(1, -16, 0.5, -7)
			}):Play()

			startRainbowPeriastron()

		else
			TweenService:Create(switch, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(255, 40, 40)
			}):Play()

			TweenService:Create(knob, TweenInfo.new(0.2), {
				Position = UDim2.new(0, 2, 0.5, -7)
			}):Play()

			stopRainbowPeriastron()
		end
	end
end)

-- =========================
-- RAINBOW LOOP (borda e texto sempre rainbow, switch rainbow só quando ligado)
-- =========================
RunService.RenderStepped:Connect(function(dt)
	hue = (hue + dt * 0.25) % 1
	local rainbow = Color3.fromHSV(hue, 1, 1)

	stroke.Color = rainbow
	title.TextColor3 = rainbow

	if enabled then
		switch.BackgroundColor3 = rainbow
	end
end)
