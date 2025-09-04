-- @ScriptType: LocalScript
local player = {}
local input = {}
local animation = {}

local players = game:GetService("Players")
local runservice = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local Humanoid = character:WaitForChild("Humanoid")

local pdEvent = game.ReplicatedStorage.Dead

--local StarterGui = game:GetService("StarterGui")
--StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)

-- Joints
local HumanoidRootPart = character:WaitForChild("HumanoidRootPart",3)
local Torso = character.LowerTorso

-- Dashing
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local IsOn, DashLength, Cooldown = nil, .3, 1
local FrontDash = character.Humanoid:LoadAnimation(script:WaitForChild("Animations",3):WaitForChild("FrontDash",3))
local RightDash = character.Humanoid:LoadAnimation(script:WaitForChild("Animations",3):WaitForChild("RightDash",3))
local LeftDash = character.Humanoid:LoadAnimation(script:WaitForChild("Animations",3):WaitForChild("LeftDash",3))
local BackDash = character.Humanoid:LoadAnimation(script:WaitForChild("Animations",3):WaitForChild("BackDash",3))
local DefaultView = 70
local TrashTable = {}
local heldKeys = {}

local CharacterParts = {
	HumRp = character.HumanoidRootPart,
	Hum = character.Humanoid,
}

--while task.wait() do
--	if UIS:IsKeyDown(Enum.KeyCode.W) then
--		direction = "w"
--	end
--	if UIS:IsKeyDown(Enum.KeyCode.A) then
--		direction = "a"
--	end
--	if UIS:IsKeyDown(Enum.KeyCode.S) then
--		direction = "s"
--	end
--	if UIS:IsKeyDown(Enum.KeyCode.D) then
--		direction = "d"
--	end
--end

UIS.InputBegan:Connect(function(Input,IsTyping)
	if IsTyping then return end
	if tostring(Input.UserInputType.Name) == "Keyboard" then
		--print("Started holding "..string.sub(tostring(Input.KeyCode),14))
		table.insert(heldKeys,Input.KeyCode)
	end

	if Input.KeyCode == Enum.KeyCode.R then
		if IsOn then return end
		if Humanoid.Health > 0 then
			if character:GetAttribute('Parried') == false then
				if character:GetAttribute('CanDash') == true then
					
					--Humanoid:SetAttribute("Invulnerable", true)
					--task.spawn(function()
					--	task.wait(0.25)
					--	Humanoid:SetAttribute("Invulnerable", false)
					--end)
					
					IsOn = true
					game.ReplicatedStorage.Status.DashEvent:FireServer()
					local BV = Instance.new("BodyVelocity", character.HumanoidRootPart)
					BV.MaxForce = Vector3.new(100000,200,100000)
					TrashTable[character] = BV
					
					local direction = "s"
					--print(#heldKeys)
					
					if #heldKeys < 2 then
						BV.Velocity = character.HumanoidRootPart.CFrame.LookVector * -25
						BackDash:Play()
						direction = "s"
					--else
					--	for i = 1, #heldKeys do
					--		if heldKeys[i] == Enum.KeyCode.W then
					--			direction = "w"
					--			print("w")
					--		elseif heldKeys[i] == Enum.KeyCode.A then
					--			direction = "a"
					--			print("a")
					--		elseif heldKeys[i] == Enum.KeyCode.D then
					--			direction = "d"
					--			print("s")
					--		elseif heldKeys[i] == Enum.KeyCode.S then
					--			direction = "s"
					--			print("d")
					--		end
						--	end
					else
						for i = 1, #heldKeys do
							if UIS:IsKeyDown(Enum.KeyCode.W) then
								direction = "w"

							elseif UIS:IsKeyDown(Enum.KeyCode.A) then
								direction = "a"

							elseif UIS:IsKeyDown(Enum.KeyCode.D) then
								direction = "d"

							elseif UIS:IsKeyDown(Enum.KeyCode.S) then
								direction = "s"

							end
						end
					end
					
					if direction == "w" then
						BV.Velocity = character.HumanoidRootPart.CFrame.LookVector * 40
						FrontDash:Play()
					elseif direction == "a" then
						BV.Velocity = character.HumanoidRootPart.CFrame.RightVector * -40
						LeftDash:Play()
					elseif direction == "d" then
						BV.Velocity = character.HumanoidRootPart.CFrame.RightVector * 40
						RightDash:Play()
					elseif direction == "s" then
						BV.Velocity = character.HumanoidRootPart.CFrame.LookVector * -40
						BackDash:Play()
					end
					
					local Infomation = TweenInfo.new(DashLength, Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,true,0)
					TS:Create(game.Workspace.CurrentCamera,Infomation, {FieldOfView = DefaultView + 15}):Play()

					task.wait(DashLength)
					wait(0.275)
					Humanoid:SetAttribute("Dashing", false)
					if direction == "s" then
						BackDash:Stop()
					elseif direction == "w" then
						FrontDash:Stop()
					elseif direction == "a" then
						LeftDash:Stop()
					elseif direction == "d" then
						RightDash:Stop()
					end

					TrashTable[character]:Destroy()
					TrashTable[character] = nil
					task.wait(Cooldown)
					IsOn = nil
				end
			end	
		end
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		heldKeys[input.KeyCode.Name] = nil
	end
end)

pdEvent.OnClientEvent:Connect(function()
	local things = game.Workspace.Camera:GetChildren()

	for _, v in pairs(things) do
		v:Destroy()
	end
end)