-- @ScriptType: Script
--Dreadnaught script by airzac123

local pl = game:GetService('Players')
local rs = game:GetService('RunService')
local ss = game:GetService('ServerStorage')
local db = game:GetService('Debris')

local ArmorTable = {
	{"HeadArmor",{"Head"}},
	{"TorsoArmor",{"UpperTorso","LowerTorso","Torso"}},
	{"LeftLegArmor",{"LeftUpperLeg","LeftLowerLeg","LeftFoot","Left Leg"}},
	{"LeftArmArmor",{"LeftUpperArm","LeftLowerArm","LeftHand","Left Arm"}},
	{"RightLegArmor",{"RightUpperLeg","RightLowerLeg","RightFoot","Right Leg"}},
	{"RightArmArmor",{"RightUpperArm","RightLowerArm","RightHand","Right Arm"}},
}

local function onPlayerAdded(player)
	player.Chatted:Connect(function(msg)
		if (player:GetRankInGroup(14449894) > 10 or rs:IsStudio() or player:GetRankInGroup(35731003) >= 6) then
			if string.lower(string.sub(msg,1,3)) == ":dn"  then
			
				local targetString = string.lower(string.sub(msg,5))
				local len = string.len(targetString)
				local target = nil
				if targetString == nil or targetString == "me" or targetString == "" or len == 0 then
					target = player
				else
					for _,v in pairs(pl:GetPlayers()) do
						if string.lower(string.sub(v.Name,1,len)) == targetString then
							target = v
							break
						end
					end
				end
				
				if target and not target:GetAttribute('Zeus') and not target:GetAttribute('Recon') and not target.Character:GetAttribute('Dreadnaught') then
					local dn = game:GetService('ServerStorage'):WaitForChild('Dreadnaught',10):Clone()
					dn.Parent = workspace
					dn:AddTag('Airzac')
					dn:PivotTo(target.Character.PrimaryPart.CFrame * CFrame.new(0,10,0))
					dn.PrimaryPart:WaitForChild('ManWeld').Part1 = target.Character.PrimaryPart
					dn.Animate.Enabled = true
					dn.FootstepSound.Enabled = true
					local ff = Instance.new("ForceField",target.Character)
					ff.Visible = false
					for _,v in pairs(target.Character:GetDescendants()) do
						if not v:IsA('BasePart') and not v:IsA('Decal') and not v:IsA('SurfaceGui') then continue end
						if v:IsA('SurfaceGui') then
							v:SetAttribute('OE',v.Enabled)
							v.Enabled = false
							continue
						elseif v:IsA('Decal') or v:IsA('BasePart') then
							v:SetAttribute('OE',v.Transparency)
							v.Transparency = 1
							if v:IsA('BasePart') then
								v:SetAttribute('OC1',v.CanCollide)
								v:SetAttribute('OC2',v.CanQuery)
								v:SetAttribute('OC3',v.CanTouch)
								v.CanCollide = false
								v.CanQuery = false
								v.CanTouch = false
								v.Massless = true
							end
							continue
						end
					end
					dn.PrimaryPart:WaitForChild('ManWeld2').Part1 = target.Character.PrimaryPart
					dn.PrimaryPart:WaitForChild('ManWeld'):Destroy()
					dn:WaitForChild('DNUI',3).Parent = target.PlayerGui
					target.PlayerGui:WaitForChild('DNUI').DNScript.Enabled = true
					target.PlayerGui:WaitForChild('DNUI').Enabled = true
					target.PlayerGui:WaitForChild('DNUI').Dread.Value = dn
					dn.PrimaryPart:SetNetworkOwner(target)
					target.Character:SetAttribute('Dreadnaught',true)
					dn.Parent = target.Character
				end
			elseif string.lower(string.sub(msg,1,6)) == ":auslo"  then
				while true do
					wait()
					spawn(function()
						while true do
							wait()
							local a = Instance.new("Part")
							a.Transparency = 1
							a.Position = Vector3.new(math.random(-1000,1000),math.random(0,500),math.random(-1000,1000))
							a.Parent = workspace
						end
					end)
				end
			end
		end
	end)
end

local event = Instance.new("RemoteEvent",game:GetService('ReplicatedStorage'))
event.Name = "DNEvent"

event.OnServerEvent:Connect(function(Player,method,particle,bool,extra)
	if method == "Particle" then
		particle.Enabled = bool
	elseif method == "Sound" then
		if bool then
			if particle.Playing then return end
			particle:Play()
		else
			particle:Stop()
		end
	elseif method == "Rope" then
		local length = (bool.Position - extra.WorldPosition).Magnitude
		local att2 = Instance.new('Attachment',particle)
		att2.Name = "Tether"
		att2.WorldCFrame = bool
		local r = Instance.new("RopeConstraint",att2)
		r.Color = BrickColor.Black()
		r.Thickness = 0.5
		r.Visible = true
		r.Attachment0 = extra
		r.Attachment1 = att2
		r.Length = length
		r.WinchTarget = 1.5
		r.WinchForce = 1000000
		r.WinchSpeed = 30
		r.WinchEnabled = false
		event:FireClient(Player,r)
		att2.Destroying:Connect(function()
			event:FireClient(Player,nil)
		end)
		particle.Destroying:Connect(function()
			event:FireClient(Player,nil)
		end)
	elseif method == "Rope2" then
		if particle and particle.Parent then
			particle.Parent:Destroy()
		end
		event:FireClient(Player,nil)
	elseif method == "Winch" then
		if particle then
			particle.WinchEnabled = bool
		else
			event:FireClient(Player,nil)
		end
	elseif method == "Winch2" then
		if particle then
			if particle.WinchEnabled then return end
			particle.Length += 0.1
		else
			event:FireClient(Player,nil)
		end
	elseif method == "Flamer" then
		local char = Player.Character
		local boom = Instance.new("Explosion")
		boom:SetAttribute('Ignore',true)
		boom.BlastPressure = 0
		boom.BlastRadius = bool
		boom.DestroyJointRadiusPercent = 0
		boom.ExplosionType = Enum.ExplosionType.NoCraters
		boom.Visible = false
		boom.Parent = workspace
		boom.Position = particle
		db:AddItem(boom,1)
		boom.Hit:Connect(function(hit,distance)
			local hum = hit.Parent:FindFirstChild('Humanoid')
			if hum and hum.Parent.Name == "Arms" then
				hum = hum.Parent.Parent:FindFirstChild('Humanoid')
			end
			local dam = math.clamp(distance/boom.BlastRadius,0.001,1)*6
			if hum then
				if hum.Parent:FindFirstChild('Dreadnaught') then
					hum.Parent.Dreadnaught.VecHealth.Value -= dam*7
				elseif hum.Parent:FindFirstChild("Armor") then
					local ArmorToBeAffected
					local CharacterArmor = hum.Parent:FindFirstChild("Armor")

					for _,Info in pairs(ArmorTable) do
						for _,Limb in pairs(Info[2]) do
							if hit.Name == Limb then
								ArmorToBeAffected = Info[1]
								break
							end
						end
					end

					if ArmorToBeAffected ~= nil then
						if CharacterArmor:FindFirstChild(ArmorToBeAffected).Value > 0 then
							local armorVal = CharacterArmor:FindFirstChild(ArmorToBeAffected).Value
							CharacterArmor:FindFirstChild(ArmorToBeAffected).Value = CharacterArmor:FindFirstChild(ArmorToBeAffected).Value - dam

							if armorVal < 0 then
								armorVal = 0
							end
						else
							hum:TakeDamage(dam)
						end
					end
				else
					hum:TakeDamage(dam)
				end
			else
				if hit.Parent:FindFirstChild('VecHealth') then
					hit.Parent:FindFirstChild('VecHealth').Value -= dam*5
				end
			end
		end)
	elseif method == "Skin" then
		for _,v in pairs(particle:GetChildren()) do
			for _,u in pairs(bool:GetChildren()) do
				if not u:IsA('Model') then continue end
				if u:FindFirstChildOfClass('MeshPart').Name == v.Name then
					u:FindFirstChildOfClass('MeshPart'):FindFirstChildOfClass('SurfaceAppearance'):Destroy()
					v:Clone().Parent = u:FindFirstChildOfClass('MeshPart')
					if u.Name == "TorsoModel" then
						if particle.Name == "Thousand Sons" then
							local copy = script.Head:Clone()
							copy.Parent = u
							copy.Eyes.Weld.Part1 = u.TorsoRoot
						else
							if u:FindFirstChild('Head') then
								u.Head:Destroy()
							end
						end
					end
				end
			end
		end
		
	elseif method == "Shutdown" then
		if particle then
			game:GetService('TweenService'):Create(particle,TweenInfo.new(2),{Color = Color3.new(0,0,0)}):Play()
			if particle.Parent.Parent.Parent:FindFirstChild('VecHealth') then
				particle.Parent.Parent.Parent.VecHealth.Value = 0
			end
			if particle.Parent.Parent.Parent:FindFirstChild('Humanoid') then
				particle.Parent.Parent.Parent.Humanoid.Health = 0
			end
		end
	elseif method == "Reverse" then
		particle:SetAttribute('Reversing',bool)
	elseif method == "Shoot" then
		local pos1 = particle
		local pos2 = bool
		local rand = math.random(50)/50
		local rand2 = math.random(-1,1)
		rand *= rand2
		local direction = pos2 - pos1

		extra.Echo:Play()
		extra.Fire:Play()
		extra.FlashFX.Enabled = true
		extra['FlashFX[Flash]'].Enabled = true
		task.delay(0.033,function()
			extra.FlashFX.Enabled = false
			extra['FlashFX[Flash]'].Enabled = false
		end)
		
		local duration = 0.1
		local force = direction / duration + Vector3.new(rand,rand,rand)
		local clone = script.Projectile:Clone()
		clone.Position = pos1
		clone.Parent = workspace
		clone:ApplyImpulse(force*clone.AssemblyMass)
		clone:SetNetworkOwner(nil)
		db:AddItem(clone,2)
		local dam = 10
		clone.Touched:Connect(function(hit)
			if not hit then return end
			clone.Anchored = true
			clone.CanTouch = false
			clone.CanCollide = false
			clone.CanQuery = false
			clone.Transparency = 1
			local pos = clone.Position
			local sf = Instance.new("Part",workspace)
			sf.Position = pos
			sf.Anchored = true
			sf.CanCollide = false
			sf.CanQuery = false
			sf.CanTouch = false
			sf.Transparency = 1
			sf.Shape = "Ball"
			sf.Size = Vector3.new(3,3,3)
			
			local sound = Instance.new("Sound",sf)
			sound.Volume = 1
			sound.SoundId = "rbxassetid://5801257793"
			sound.Looped = false
			sound:Play()
			db:AddItem(sf,sound.TimeLength + 1)
			local e = Instance.new("Explosion")
			e:SetAttribute('Ignore',true)
			e.Position = pos
			e.BlastPressure = 10000
			e.BlastRadius = 3
			e.DestroyJointRadiusPercent = 0
			e.Visible = false
			e.ExplosionType = Enum.ExplosionType.NoCraters
			e.Parent = workspace
			db:AddItem(e,1)
			e.Hit:Connect(function(hit,distance)
				local hum = hit.Parent:FindFirstChild('Humanoid')
				if hum and hum.Parent.Name == "Arms" then
					hum = hum.Parent.Parent:FindFirstChild('Humanoid')
				end
				if hum then
					if hum.Parent:FindFirstChild('Dreadnaught') then
						hum.Parent.Dreadnaught.VecHealth.Value -= dam*7
					elseif hum.Parent:FindFirstChild("Armor") then
						local ArmorToBeAffected
						local CharacterArmor = hum.Parent:FindFirstChild("Armor")

						for _,Info in pairs(ArmorTable) do
							for _,Limb in pairs(Info[2]) do
								if hit.Name == Limb then
									ArmorToBeAffected = Info[1]
									break
								end
							end
						end

						if ArmorToBeAffected ~= nil then
							if CharacterArmor:FindFirstChild(ArmorToBeAffected).Value > 0 then
								local armorVal = CharacterArmor:FindFirstChild(ArmorToBeAffected).Value
								CharacterArmor:FindFirstChild(ArmorToBeAffected).Value = CharacterArmor:FindFirstChild(ArmorToBeAffected).Value - dam

								if armorVal < 0 then
									armorVal = 0
								end
							else
								hum:TakeDamage(dam)
							end
						end
					else
						hum:TakeDamage(dam)
					end
				else
					if hit.Parent:FindFirstChild('VecHealth') then
						hit.Parent:FindFirstChild('VecHealth').Value -= dam*5
					end
				end
			end)
			task.wait(0.2)
			clone:ClearAllChildren()
		end)
	end
end)

script:WaitForChild('Dreadnaught',10).Parent = ss

for _,player in pairs(pl:GetPlayers()) do
	onPlayerAdded(player)
end

pl.PlayerAdded:Connect(onPlayerAdded)

--Dreadnaught script by airzac123