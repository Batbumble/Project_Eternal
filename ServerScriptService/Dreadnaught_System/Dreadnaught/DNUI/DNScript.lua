-- @ScriptType: LocalScript
-- By airzac123

local ui = script.Parent
local plr = game:GetService('Players').LocalPlayer
local rs = game:GetService('ReplicatedStorage')
local uis = game:GetService('UserInputService')
local rn = game:GetService('RunService')
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild('Humanoid',10)
local mouse = plr:GetMouse()

char:SetAttribute('Dreadnaught',false)
local event = game:GetService('ReplicatedStorage'):WaitForChild('DNEvent',10)
if event == nil then warn("incorrect") ui:Destroy() end
local dreadModel = ui:WaitForChild('Dread',10)
local armorNum = ui:WaitForChild('Frame'):WaitForChild('ArmorInfo')
local ropeInfo = ui:WaitForChild('Frame'):WaitForChild('RopeInfo')
local skinButton = ui:WaitForChild('Frame'):WaitForChild('SkinButton')
local downButton = ui:WaitForChild('Frame'):WaitForChild('DownButton')
local grappleAtt = nil
local dreadVector = nil
local dreadGun = nil
local humanoid = nil
local connectionInputBegan = nil
local connectionLoop = nil
local skinsFolder = nil

local holdingW = false
local holdingF = false
local holdingS = false
local holdingMouse = false
local holdingG = false
local shift = 1
local boostForce = 1.2
local timeInAir = 0
local airTimeReq = 0.2

local boostStart = tick()
local boostTime = 3
local burnoutTimer = 10
local canBoost = true
local maxHealth = nil
local moveVector = Vector3.new(0,0,5000000)
local airVector = 1
local maxRopeLength = 300
local zeroVector = Vector3.zero
local jumpCool = false
local jumpCool2 = false
local jumpVal = 1500000
local r = nil
local odd1 = false
local odd2 = false
local winchToggled = false
local flamerToggled = false
local considering = tick()
local dead = false

local function Loop(deltaTime)
	if not char then return end
	if not hum then return end
	if not dreadModel.Value then return end
	if dreadModel.Value.Humanoid.FloorMaterial == Enum.Material.Air then
		airVector = 0.000005
	else
		airVector = 1
	end
	if holdingW then
		dreadVector.Parent.Reverse1.Force = zeroVector
		dreadVector.Parent.Reverse2.Force = zeroVector
		event:FireServer('Sound',dreadModel.Value.PrimaryPart.Beep,false)
		dreadVector.Force = moveVector*shift*airVector
	else
		if holdingS then
			event:FireServer('Reverse',dreadModel.Value,true)
			dreadVector.Parent.Reverse1.Force = -moveVector*airVector/5
			dreadVector.Parent.Reverse2.Force = -moveVector*airVector/5
			event:FireServer('Sound',dreadModel.Value.PrimaryPart.Beep,true)
		else
			event:FireServer('Reverse',dreadModel.Value,false)
			dreadVector.Parent.Reverse1.Force = zeroVector
			dreadVector.Parent.Reverse2.Force = zeroVector
			event:FireServer('Sound',dreadModel.Value.PrimaryPart.Beep,false)
			dreadVector.Force = zeroVector
		end
	end
	if holdingMouse and shift == 1 then
		odd1 = not odd1
		if odd1 then
			dreadModel.Value:SetAttribute('Shooting',true)
		end
	end
	armorNum.Text = "Armor ["..tostring(math.floor(10000*math.max(dreadModel.Value.VecHealth.Value,0)/maxHealth)/100).."%]"
	if dreadModel.Value.VecHealth.Value <= 0 and not dead then
		dead = true
		event:FireServer('Shutdown',dreadModel.Value.TorsoModel.Torso.Eye)
		hum.Health = 0
	end
	if shift == boostForce then
		if tick() - boostStart > boostTime then
			canBoost = false
			shift = 1
			dreadModel.Value:SetAttribute('boost',false)
			for _,v in pairs(dreadModel.Value.TorsoModel.TorsoRoot:GetChildren()) do
				if v.Name ~= "FA" then continue end
				event:FireServer('Particle',v.ActiveBoost,false)
				event:FireServer('Particle',v.Smoke,true)
			end
			task.delay(burnoutTimer,function()
				canBoost = true
				for _,v in pairs(dreadModel.Value.TorsoModel.TorsoRoot:GetChildren()) do
					if v.Name ~= "FA" then continue end
					event:FireServer('Particle',v.Smoke,false)
				end
			end)
		end
	end
	if holdingF or flamerToggled then
		odd2 = not odd2
		if odd2 then
			event:FireServer('Flamer',grappleAtt.BurnAtt.WorldPosition,25)
		end
	end
	if holdingG then
		event:FireServer('Winch2',r)
	end
end

local function InputEnded(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.W then
			holdingW = false
		elseif input.KeyCode == Enum.KeyCode.S then
			holdingS = false
		elseif input.KeyCode == Enum.KeyCode.CapsLock then
			shift = 1
			dreadModel.Value:SetAttribute('boost',false)
			for _,v in pairs(dreadModel.Value.TorsoModel.TorsoRoot:GetChildren()) do
				if v.Name ~= "FA" then continue end
				v.ActiveBoost.Enabled = false
				event:FireServer('Particle',v.ActiveBoost,false)
			end
		elseif input.KeyCode == Enum.KeyCode.T and r then
			if not winchToggled then
				event:FireServer('Winch',r,false)
			end
		elseif input.KeyCode == Enum.KeyCode.F then
			holdingF = false
			if not flamerToggled then
				event:FireServer('Sound',grappleAtt.Burn,false)
				event:FireServer('Particle',grappleAtt.Flame,false)
				event:FireServer('Particle',grappleAtt.Light,false)
			end
		elseif input.KeyCode == Enum.KeyCode.G then
			holdingG = false
		elseif input.KeyCode == Enum.KeyCode.Space then
			if dreadModel.Value.Humanoid.FloorMaterial ~= Enum.Material.Air and not jumpCool then
				jumpCool = true
				dreadVector.Parent.JumpForce.Force = Vector3.new(0,jumpVal,0)
				task.wait(0.2)
				dreadVector.Parent.JumpForce.Force = Vector3.new(0,0,0)
				task.wait(1)
				jumpCool = false
			elseif shift == boostForce and dreadModel.Value.Humanoid.FloorMaterial == Enum.Material.Air and not jumpCool2 then
				jumpCool2 = true
				dreadVector.Parent.JumpForce.Force = Vector3.new(0,jumpVal/2,4000000)
				task.wait(0.2)
				dreadVector.Parent.JumpForce.Force = Vector3.new(0,0,0)
				task.wait(2)
				jumpCool2 = false
			end
		end
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
		holdingMouse = false
		dreadModel.Value:SetAttribute('Shooting',false)
	end
end

local function InputBegan(input, processed)
	if processed then return end
	if not char then return end
	if not hum then return end
	if dreadModel.Value == nil then return end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.W then
			holdingW = true
		elseif input.KeyCode == Enum.KeyCode.S then
			holdingS = true
		elseif input.KeyCode == Enum.KeyCode.CapsLock and canBoost then
			shift = boostForce
			dreadModel.Value:SetAttribute('boost',true)
			for _,v in pairs(dreadModel.Value.TorsoModel.TorsoRoot:GetChildren()) do
				if v.Name ~= "FA" then continue end
				event:FireServer('Particle',v.ActiveBoost,true)
			end
			holdingMouse = false
			dreadModel.Value:SetAttribute('Shooting',false)
			boostStart = tick()
		elseif input.KeyCode == Enum.KeyCode.R then
			if r == nil then
				if mouse.Target then
					if not mouse.Target.Anchored or shift == boostForce then
						local length = (mouse.Hit.Position - grappleAtt.WorldPosition).Magnitude
						if length > maxRopeLength then
							ropeInfo.Text = "ERROR: Target exceeds range ("..tostring(math.floor(length))..")"
							considering = tick()
						else
							event:FireServer('Rope',mouse.Target,mouse.Hit,grappleAtt)
							event:FireServer('Sound',dreadModel.Value.PrimaryPart.Hold,true)
							if mouse.Target.Parent:IsA('Model') then
								ropeInfo.Text = "SUCCESS: Sending grapple to "..mouse.Target.Parent.Name
							else
								ropeInfo.Text = "SUCCESS: Sending grapple to "..mouse.Target.Name
							end
							considering = tick()
						end
					else
						ropeInfo.Text = "ERROR: Invalid target"
						considering = tick()
					end
				else
					ropeInfo.Text = "ERROR: No target"
					considering = tick()
				end
			else
				event:FireServer('Rope2',r,nil,grappleAtt)
			end
		elseif input.KeyCode == Enum.KeyCode.T and r then
			if shift == boostForce then
				winchToggled = not winchToggled
			end
			event:FireServer('Winch',r,true)
		elseif input.KeyCode == Enum.KeyCode.Y then
			event:FireServer('Sound',dreadModel.Value.PrimaryPart.Hello,true)
		elseif input.KeyCode == Enum.KeyCode.F then
			if shift == boostForce then
				flamerToggled = not flamerToggled
			end
			event:FireServer('Sound',grappleAtt.Burn,true)
			event:FireServer('Particle',grappleAtt.Flame,true)
			event:FireServer('Particle',grappleAtt.Light,true)
			holdingF = true
		elseif input.KeyCode == Enum.KeyCode.G then
			holdingG = true
		end
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 and shift == 1 then
		holdingMouse = true
	end
end

ropeInfo.Changed:Connect(function()
	task.wait(3)
	if tick() - considering > 3 then
		ropeInfo.Text = ""
	end
end)

event.OnClientEvent:Connect(function(info) r = info end)

skinButton.MouseButton1Click:Connect(function()
	for i,v in pairs(skinButton:GetChildren()) do
		if not v:IsA('TextButton') then continue end
		v.Visible = not v.Visible
		v.MouseButton1Click:Connect(function()
			event:FireServer('Skin',skinsFolder:FindFirstChild(v.Name),dreadModel.Value)
		end)
	end
end)

downButton.MouseButton1Click:Connect(function()
	event:FireServer('Shutdown',dreadModel.Value.TorsoModel.Torso.Eye)
end)

char:GetAttributeChangedSignal('Dreadnaught'):Connect(function()
	if not hum then return end
	if dreadModel.Value == nil then return end
	if char:GetAttribute('Dreadnaught') == true then
		hum:UnequipTools()
		task.wait(0.5)
		hum:UnequipTools()
		game:GetService('StarterGui'):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)
		hum:UnequipTools()
		maxHealth = dreadModel.Value.VecHealth.Value
		dreadVector = dreadModel.Value.PrimaryPart:WaitForChild('VectorForce',3)
		dreadGun = dreadModel.Value:WaitForChild('Right Arm').RightArm.Att
		grappleAtt = dreadModel.Value:WaitForChild('Left Arm').LeftArm.Att
		connectionInputBegan = uis.InputBegan:Connect(InputBegan)
		connectionInputEnded = uis.InputEnded:Connect(InputEnded)
		connectionLoop = rn.Heartbeat:Connect(Loop)
		skinsFolder = dreadModel.Value:WaitForChild('Skins')
		for i,v in pairs(skinsFolder:GetChildren()) do
			local copy = skinButton.SkinButtonLower:Clone()
			copy.Text = v.Name
			copy.Name = v.Name
			copy.Position = UDim2.new(0,0,i,0)
			copy.Parent = skinButton
		end
		skinButton.SkinButtonLower:Destroy()
	end
end)

hum.Died:Connect(function()
	if connectionLoop then connectionLoop:Disconnect() end
	if connectionInputBegan then connectionInputBegan:Disconnect() end
	if connectionInputEnded then connectionInputEnded:Disconnect() end
	holdingMouse = false
	dreadModel.Value:SetAttribute('Shooting',false)
	event:FireServer('Sound',dreadModel.Value.PrimaryPart.Beep,false)
	event:FireServer('Sound',dreadModel.Value.PrimaryPart.Hello,false)
	event:FireServer('Sound',dreadModel.Value.PrimaryPart.Hold,false)
	dreadModel.Value = nil
	grappleAtt = nil
	dreadGun = nil
	winchToggled = false
	flamerToggled = false
end)

dreadModel.Value:GetAttributeChangedSignal('Shooting'):Connect(function()
	if dreadModel.Value:GetAttribute('Shooting') == true then
		repeat
			event:FireServer('Shoot',dreadGun.WorldPosition,mouse.Hit.Position,dreadGun)
			wait(0.1)
		until not dreadModel.Value:GetAttribute('Shooting')
	end
end)

plr:GetPropertyChangedSignal('CameraMinZoomDistance'):Connect(function()
	plr.CameraMaxZoomDistance = 14
	if char:FindFirstChild('CameraTilt') then
		char.CameraTilt.Enabled = false
	end
end)

hum.BreakJointsOnDeath = false
if char:FindFirstChild('CameraTilt') then
	char.CameraTilt.Enabled = false
end
plr.CameraMaxZoomDistance = 14