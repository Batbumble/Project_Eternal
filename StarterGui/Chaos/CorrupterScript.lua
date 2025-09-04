-- @ScriptType: LocalScript
local player = game:GetService('Players').LocalPlayer
local ui = script.Parent
local rn = game:GetService('RunService')
local uis = game:GetService('UserInputService')
local ts = game:GetService('TweenService')
local ca = game:GetService('ContextActionService')
local rs = game:GetService('ReplicatedStorage')
local char = player.Character or player.CharacterAdded:Wait()

local timeToPress = 5
local frequency = 1
local t = 0
local presses = 0
local shakeMagnitude = ui.SM
local ti = TweenInfo.new(timeToPress*2)
local odd = false
local saved = 0
local check = 0
local corrupted = false
local spaceButton = ui.Frame:WaitForChild('SpaceButton',10)

local function shakeCamera(deltaTime)
	check += 1
	if check > 5 then
		check = 0
	else
		shakeMagnitude.Value += deltaTime/2.5
		return
	end
	t += deltaTime/10
	local x = (math.noise(0,t*frequency) - 1)*0.1
	local y = (math.noise(1,t*frequency) - 1)*0.1
	--x *= shakeMagnitude.Value
	--y *= shakeMagnitude.Value
	odd = not odd
	if odd then x = -x end
	char.Humanoid.CameraOffset = Vector3.new(x,y,0)
	shakeMagnitude.Value += deltaTime/2.5
	if saved > 0 then
		shakeMagnitude.Value += saved/50
	end
end

local function count()
	presses += 1
	shakeMagnitude.Value = math.max(shakeMagnitude.Value - 0.05,0)
end

shakeMagnitude.Changed:Connect(function()
	if corrupted then return end
	if shakeMagnitude.Value == 0 then
		ui.Vignette.ImageTransparency = 1
		ui.Frame.BackgroundTransparency = 1
	else
		ui.Vignette.ImageTransparency = math.max(1 - (shakeMagnitude.Value/2),0)
		ui.Frame.BackgroundTransparency = math.max(1 - (shakeMagnitude.Value/3.2),0.1)
	end
	if shakeMagnitude.Value > 5 then
		corrupted = true
		shakeMagnitude.Value = 0
		ca:UnbindAction('DenyJump')
		rn:UnbindFromRenderStep("Shake")
		ts:Create(char.Humanoid,TweenInfo.new(1),{CameraOffset = Vector3.new(0,0,0)}):Play()
		ts:Create(ui.Frame,ti,{BackgroundTransparency = 0, BackgroundColor3 = Color3.new(0,0,0)}):Play()
		task.wait(timeToPress)
		rs.ACS_Engine.Eventos.Afogar:FireServer()
		task.wait(1)
		corrupted = false
	end
end)

spaceButton.MouseButton1Click:Connect(function()
	presses += 1
	shakeMagnitude.Value = math.max(shakeMagnitude.Value - 0.045,0)
end)

ui:GetAttributeChangedSignal('Corrupting'):Connect(function()
	if corrupted then return end
	if ui:GetAttribute('Corrupting') == true then
		ui.Monk:Play()
		ca:BindAction('DenyJump',count,false,Enum.KeyCode.Space)
		rn:BindToRenderStep("Shake", 1999, shakeCamera)
		spaceButton.Visible = true
		char.Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
		char.PrimaryPart.AssemblyLinearVelocity += 	char.PrimaryPart.CFrame.LookVector * 15
		char.PrimaryPart.AssemblyLinearVelocity += 	char.PrimaryPart.CFrame.RightVector * math.random(-5,5)
		local rand = math.random(-50,50)/500
		ui.Whispers.PSSE.Octave = 1 + rand
		ui.Whispers:Play()
		task.wait(timeToPress)
		saved += shakeMagnitude.Value
		ui:SetAttribute('Corrupting',false)
		ui.Scary:Play()
	else
		ca:UnbindAction('DenyJump')
		spaceButton.Visible = false
		rn:UnbindFromRenderStep("Shake")
		ts:Create(shakeMagnitude,TweenInfo.new(1),{Value = 0}):Play()
		ts:Create(char.Humanoid,TweenInfo.new(1),{CameraOffset = Vector3.new(0,0,0)}):Play()
	end
end)

rs:WaitForChild('Corrupt').OnClientEvent:Connect(function()
	ui:SetAttribute('Corrupting',true)
end)

char:WaitForChild('Humanoid').Died:Connect(function()
	ca:UnbindAction('DenyJump')
	rn:UnbindFromRenderStep("Shake")
end)

player.CharacterAdded:Connect(function()
	ca:UnbindAction('DenyJump')
	rn:UnbindFromRenderStep("Shake")
end)