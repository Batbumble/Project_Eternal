-- @ScriptType: Script
local Storage = game:GetService("ReplicatedStorage"):WaitForChild("ENPGS — Storage")
local TS = game:GetService('TweenService')
local Config = script.Parent.Config
local spotDistance = Config.SpottingDistance.Value
local fov = math.rad(360)

local Alert
local Patrol
local FireSound
local DeltaTime
local LastTarget
local GroupPatrol
local InjuredScream
local FormationModel
local FriendlyInProximity
local HitPart,HitPos,IgnoreTable
local PermIgnoreTable = {}

local CurrentTime = tick()

local MaxPos,MaxDis,RayDis,RndAngle = 0,0,0,0
local Bots = 0
local HeadAngY = 0
local FormModelAngY = 0

local LastTime = tick()
local TorsoAngleX
local LookAngleX
local MoveAngleX
local HeadAngleX
local DeltaTime

local HeadCF,TorsoCF,RightLegCF,LeftLegCF
local RootAngleY,RootAngleX,RootAngleZ
local ArmsStatusCF
local AxisAttachY

local cs = game:GetService('CollectionService')
local pl = game:GetService('Players')
local zeroVec = Vector3.new()

game.ReplicatedStorage.Status.DeleteObject.OnServerEvent:Connect(function(player,object)
	if object then
		object:Destroy()
		cs:RemoveTag(object,"Airzac")
	end
end)

local function PosAndAnglesToCF(Pos,Angles)
	return CFrame.new(Pos) * CFrame.Angles(math.rad(Angles.X),math.rad(Angles.Y),math.rad(Angles.Z))
end

local airzacs = {}
local Airzac = {}
Airzac.__index = Airzac
Airzac.TAG_NAME = "Airzac"

function Airzac.new(airzac)
	local self = {}
	setmetatable(self,Airzac)
	self.airzac = airzac
	return self
end

local airzacAddedSignal = cs:GetInstanceAddedSignal(Airzac.TAG_NAME)
local airzacRemovedSignal = cs:GetInstanceRemovedSignal(Airzac.TAG_NAME)

local function onAirzacAdded(airzac)
	if airzac:FindFirstChild('Settings') or pl:GetPlayerFromCharacter(airzac) then
		airzacs[airzac] = Airzac.new(airzac)
	else
		cs:RemoveTag(airzac,"Airzac")
	end
end

local function onAirzacRemoved(airzac)
	if airzacs[airzac] then
		airzacs[airzac] = nil
	end
end

for _,air in pairs(cs:GetTagged(Airzac.TAG_NAME)) do
	onAirzacAdded(air)
end

airzacAddedSignal:Connect(onAirzacAdded)
airzacRemovedSignal:Connect(onAirzacRemoved)

local function IsChar(Object)
	return Object and Object:IsA("Model") and Object.PrimaryPart and ((Object:FindFirstChild("Humanoid") and Object.Humanoid.Health > 0) or (Object:FindFirstChild('VecHealth') and Object.VecHealth.Value > 0))
end

local function IsNPG(Object)
	return Object and Object:FindFirstChild("Signature") and Object.Signature.ClassName == "StringValue"
		and Object.Signature.Value == "Evy24's Non-Player Gunman System" and Object:FindFirstChild("Settings") and IsChar(Object)
end

local function GetAngle(VecA,VecB)
	return math.acos(VecA.Unit:Dot(VecB.Unit))
end

local function GetAngleBasedOnBallistic(C,MuzzleVelocity,Distance)
	return 35 * (Distance/(MuzzleVelocity * 3.571)) ^ 2
end

local function IsPatroling(C)
	Patrol = C.Settings.Patrol
	if C.Settings.Group.Id.Value > 0 then Patrol = Storage.Patrol[C.Settings.Group.Id.Value] end
	return Patrol.Points:FindFirstChild(1) and Patrol.Sum.Value >= Patrol.Num.Value
end

local function SetWalkSpeed(C)
	if not C:FindFirstChild('Humanoid') then return end
	local multiplyer = C.Speed.Value
	
	if C.Settings.General.Sprint.Value == "High" then
		if C.Settings.General.Stance.Value == "Prone" then C.Humanoid.WalkSpeed = 6
		elseif C.Settings.General.Stance.Value == "Kneel" then C.Humanoid.WalkSpeed = 12 
		else C.Humanoid.WalkSpeed = 23 * multiplyer end
	elseif C.Settings.General.Sprint.Value == "Low" then
		if C.Settings.General.Stance.Value == "Prone" then C.Humanoid.WalkSpeed = 5
		elseif C.Settings.General.Stance.Value == "Kneel" then C.Humanoid.WalkSpeed = 10 
		else C.Humanoid.WalkSpeed = 19 * multiplyer end
	else
		if C.Settings.General.Stance.Value == "Prone" then C.Humanoid.WalkSpeed = 4
		elseif C.Settings.General.Stance.Value == "Kneel" then C.Humanoid.WalkSpeed = 8
		else C.Humanoid.WalkSpeed = 16 * multiplyer end
	end
	
	if C.Speed.Value == 0 then
		C.Humanoid.WalkSpeed = 0
	end
	
	--if IsPatroling(C) and (C.Settings.Group.Id.Value == 0 or C == C.Settings.Group.Leader.Value)
	--	and (C.Settings.Combat.Target.Value or C.Settings.Combat.SuppressTime.Value > 0) then C.Humanoid.WalkSpeed = 0
	--elseif C.Settings.General.FacingTime.Value > 0 and C.Settings.General.Stance.Value ~= "Stand" --[[and not C.Humanoid.AutoRotate]] then C.Humanoid.WalkSpeed = 0 end
end

local function SetActionTime(C)
	C.Settings.General.ActionTime.Value = Config.ActionDuration.Value * math.random(5,15)/10
end

local function CreateAlert(Name,C,Pos,IgnoreTeam)
	if C.GunStat:GetAttribute('GunName') ~= "Blank" then return end
	if C.Settings.Combat.AlertTime.Value > 0 then return end
	if C and C:FindFirstChild("Settings") then
		if C.Settings.Combat.AlertTime.Value > 0 then return end
		
		SetActionTime(C)
		C.Settings.Combat.AlertTime.Value = 5 * math.random(5,15)/10
		C.Settings.Combat.Alerted.Value = true
		if C.Settings.Group.Leader.Value and C.Settings.Group.Leader.Value.Parent then C.Settings.Group.Leader.Value.Settings.Combat.Alerted.Value = true end
	end
	
	Alert = Instance.new("Vector3Value")
	Alert.Name = Name
	Alert.Value = Pos
	Instance.new("IntValue",Alert).Name = "Uses"
	Instance.new("StringValue",Alert).Name = "Team"
	if not IgnoreTeam then Alert.Team.Value = C.Settings.General.Team.Value end
	Alert.Parent = script.Parent.Alerts
	game:GetService("Debris"):AddItem(Alert,3)
end

local function GetRayPos(Pos1,Pos2)
	HitPart,HitPos,IgnoreTable = nil,nil,{}

	while true do
		HitPart,HitPos = workspace:FindPartOnRayWithIgnoreList(Ray.new(HitPos or Pos1,Pos2),IgnoreTable)
		
		HitPos = Pos1 + (HitPos - Pos1).Unit * ((HitPos - Pos1).Magnitude - 3)
		
		--workspace.MarkParts.A.Position = Pos1
		--workspace.MarkParts.B.Position = Pos2
		--workspace.MarkParts.C.Position = HitPos
		
		if not HitPart or HitPart.CanCollide then return HitPos else table.insert(IgnoreTable,HitPart) end
	end
end

local function LookAt(C,Ignore,Pos,FacingTime)
	if not Pos then
		MaxPos,MaxDis,RayDis,RndAngle = Vector3.new(),0,0,math.random(1,15)
		
		for Num = 0,2 do
			Pos = C.Head.Position + CFrame.Angles(0,math.rad(Num * 120 + RndAngle * 8),0).LookVector * 35
			RayDis = (GetRayPos(C.Head.Position,Pos) - C.Head.Position).Magnitude
			if MaxDis < RayDis then MaxDis = RayDis MaxPos = Pos end
		end
		
		Pos = C.Head.Position + (MaxPos - C.Head.Position).Unit * 2000
	elseif not (Ignore or (GetRayPos(C.Head.Position,Pos) - C.Head.Position).Magnitude > (Pos - C.Head.Position).Magnitude * .75) then return false end

	C.Settings.General.LookAt.Value = Pos
	C.Settings.General.FacingTime.Value = FacingTime or 2
	
	return true
end

local function WalkTo(C,Pos)
	C.Settings.General.WalkTo.Value = Pos
	C.Settings.General.ActionTime.Value = math.max(C.Settings.General.ActionTime.Value,(Pos - C:GetPivot().Position).Magnitude/12)
end

local ArmorTable = {
	{"HeadArmor",{"Head"}},
	{"TorsoArmor",{"UpperTorso","LowerTorso"}},
	{"LeftLegArmor",{"LeftUpperLeg","LeftLowerLeg","LeftFoot"}},
	{"LeftArmArmor",{"LeftUpperArm","LeftLowerArm","LeftHand"}},
	{"RightLegArmor",{"RightUpperLeg","RightLowerLeg","RightFoot"}},
	{"RightArmArmor",{"RightUpperArm","RightLowerArm","RightHand"}},
}
local Debris = game:GetService("Debris")
local tweenInfo = TweenInfo.new(1,Enum.EasingStyle.Back)

local function makeExplosion(pos,dam,OTU,wepName,C)
	if C.Settings and C.Settings.Combat.HoldFire.Value == true then return end
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
	sound.SoundId = C.Arms.GunModel.Muzzle:FindFirstChild('Fire').SoundId--"rbxassetid://5801257793"
	sound.Looped = false
	sound:Play()

	local e = Instance.new("Explosion")
	if wepName == "Heal" then
		e:SetAttribute('Ignore',true)
		e.BlastRadius = 99
	end
	e.Position = pos
	e.BlastPressure = 1
	e.BlastRadius = 15
	e.DestroyJointRadiusPercent = 0
	e.Visible = false
	local slower = false
	if wepName == "AcidSpit" or wepName == "AcidSpit2" or wepName == "Monolith" then
		Storage.Other.AcidExplosion:Clone().Parent = sf
	elseif wepName == "Ta'u Artillery Gun" or wepName == "Ta'u Mech Gun" or wepName == "Plasma Pistol" or wepName == "Twin Plasma Pistol" then
		Storage.Other.PlasmaExplosion:Clone().Parent = sf
		task.delay(0.5,function()
			sf.PlasmaExplosion:Destroy()
		end)
	elseif wepName == "Dreadnaught Plasma Cannon" then
		Storage.Other.ChaosPlasmaExplosion:Clone().Parent = sf
		task.delay(0.5,function()
			sf.ChaosPlasmaExplosion:Destroy()
		end)
	elseif wepName == "Thunder" or wepName == "Staff" then
		slower = true
		e:SetAttribute('Sorcerer',true)
	elseif wepName ~= "Heal" then
		Storage.Other.NormExplosion:Clone().Parent = sf
		task.delay(0.5,function()
			sf.NormExplosion:Destroy()
		end)
	elseif wepName == "Heal" then
		e.BlastRadius = 99
		task.spawn(function()
			C.PrimaryPart.Shield.ParryRings.Size = NumberSequence.new(0)
			for i = 1, 75 do
				C.PrimaryPart.Shield.ParryRings.Size = NumberSequence.new(1*i)
				task.wait()
			end
			C.PrimaryPart.Shield.ParryRings.Size = NumberSequence.new(0)
		end)
	end
	e.ExplosionType = Enum.ExplosionType.NoCraters
	e.Parent = workspace
	e.Hit:Connect(function(hit,distance)
		if not hit.Parent then return end
		if hit.Parent == C then return end
		--if not hit.Parent:FindFirstChild('Humanoid') then return end
		local hum = hit.Parent:FindFirstChild('Humanoid') --or hit.Parent:FindFirstChild('VecHealth')
		if hum and hum.Parent.Name == "Arms" then return end
		if dam == nil then dam = 10 end
		local dam2 = math.min(dam*(5/(distance+1)),400)
		if hum then--game:GetService("Players"):GetPlayerFromCharacter(hum.Parent) or hum.Parent:FindFirstChildOfClass('Humanoid') then
			if wepName == "Heal" then
				if hit.Parent:FindFirstChild('Settings') and C.Settings.General.Team.Value == hit.Parent:FindFirstChild('Settings').General.Team.Value then
					hum.Health = math.min(hum.Health + dam2,hum.MaxHealth)
					if hum.Parent:FindFirstChild('Dreadnaught') then
						hum.Parent.Dreadnaught.VecHealth.Value = math.min(hum.Parent.Dreadnaught.VecHealth.Value + 7*dam2,hum.Parent.Dreadnaught.VecHealth:GetAttribute('Max'))
					elseif hum.Parent:FindFirstChild("Armor") then
						local ArmorToBeAffected
						local CharacterArmor = hum.Parent:FindFirstChild("Armor")

						for _,Info in pairs(ArmorTable) do
							for _,Limb in pairs(Info[2]) do
								if hit.Name == Limb or hit.Parent.Name == Limb or (hum.Parent:GetAttribute('Morph') and hit.Parent.Name == hum.Parent:GetAttribute('Morph').."_"..Limb) then
									ArmorToBeAffected = Info[1]
									break
								end
							end	
						end
						if hum.Parent:GetAttribute('Morph') and hit.Parent.Name == hum.Parent:GetAttribute('Morph').." Helmet_Head" then
							ArmorToBeAffected = "HeadArmor"
						end

						if ArmorToBeAffected ~= nil then
							if CharacterArmor:FindFirstChild(ArmorToBeAffected).Value > 0 then
								local armorVal = CharacterArmor:FindFirstChild(ArmorToBeAffected).Value
								CharacterArmor:FindFirstChild(ArmorToBeAffected).Value = CharacterArmor:FindFirstChild(ArmorToBeAffected).Value + dam2

								if armorVal < 0 then
									armorVal = 0
								end
							else
								hum.Health = math.min(hum.Health + dam2,hum.MaxHealth)
							end
						end
					elseif HitPart.Parent and HitPart.Parent:GetAttribute("Health") then
						HitPart:SetAttribute("Health", HitPart.Parent:GetAttribute("Health") + dam2)
					else
						hum.Health = math.min(hum.Health + dam2,hum.MaxHealth)
					end
				else
					if distance < 75 then
						if hum.Parent:FindFirstChild('Dreadnaught') then
							hum.Parent.Dreadnaught.VecHealth.Value = math.min(hum.Parent.Dreadnaught.VecHealth.Value - 7*dam2,hum.Parent.Dreadnaught.VecHealth:GetAttribute('Max'))
						elseif hum.Parent:FindFirstChild("Armor") then
							local ArmorToBeAffected
							local CharacterArmor = hum.Parent:FindFirstChild("Armor")

							--for _,Info in pairs(ArmorTable) do
							--	for _,Limb in pairs(Info[2]) do
							--		if hit.Name == Limb then
							--			ArmorToBeAffected = Info[1]
							--			break
							--		end
							--	end
							--end
							
							for _,Info in pairs(ArmorTable) do
								for _,Limb in pairs(Info[2]) do
									if hit.Name == Limb or hit.Parent.Name == Limb or (hum.Parent:GetAttribute('Morph') and hit.Parent.Name == hum.Parent:GetAttribute('Morph').."_"..Limb) then
										ArmorToBeAffected = Info[1]
										break
									end
								end	
							end
							if hum.Parent:GetAttribute('Morph') and hit.Parent.Name == hum.Parent:GetAttribute('Morph').." Helmet_Head" then
								ArmorToBeAffected = "HeadArmor"
							end

							if ArmorToBeAffected ~= nil then
								if CharacterArmor:FindFirstChild(ArmorToBeAffected).Value > 0 then
									local armorVal = CharacterArmor:FindFirstChild(ArmorToBeAffected).Value
									CharacterArmor:FindFirstChild(ArmorToBeAffected).Value = CharacterArmor:FindFirstChild(ArmorToBeAffected).Value - dam2

									if armorVal < 0 then
										armorVal = 0
									end
								else
									hum.Health = math.min(hum.Health - dam2,hum.MaxHealth)
								end
							end
						elseif HitPart.Parent and HitPart.Parent:GetAttribute("Health") then
							HitPart:SetAttribute("Health", HitPart.Parent:GetAttribute("Health") - dam2)
						else
							hum.Health = math.min(hum.Health - dam2,hum.MaxHealth)
						end
					end
				end
			else
				--if wepName == "Heal" and hit.Parent:FindFirstChild('Settings') and C.Settings.General.Team.Value == hit.Parent:FindFirstChild('Settings').General.Team.Value then
				--	dam2 = -math.abs(3*dam2)
				--end
				if hum.Parent:FindFirstChild('Dreadnaught') then
					hum.Parent.Dreadnaught.VecHealth.Value = math.min(hum.Parent.Dreadnaught.VecHealth.Value - 7*dam2,hum.Parent.Dreadnaught.VecHealth:GetAttribute('Max'))
				elseif hum.Parent:FindFirstChild("Armor") then
					local ArmorToBeAffected
					local CharacterArmor = hum.Parent:FindFirstChild("Armor")

					for _,Info in pairs(ArmorTable) do
						for _,Limb in pairs(Info[2]) do
							if hit.Name == Limb or hit.Parent.Name == Limb or (hum.Parent:GetAttribute('Morph') and hit.Parent.Name == hum.Parent:GetAttribute('Morph').."_"..Limb) then
								ArmorToBeAffected = Info[1]
								break
							end
						end	
					end
					if hum.Parent:GetAttribute('Morph') and hit.Parent.Name == hum.Parent:GetAttribute('Morph').." Helmet_Head" then
						ArmorToBeAffected = "HeadArmor"
					end

					if ArmorToBeAffected ~= nil then
						if CharacterArmor:FindFirstChild(ArmorToBeAffected).Value > 0 then
							local armorVal = CharacterArmor:FindFirstChild(ArmorToBeAffected).Value
							CharacterArmor:FindFirstChild(ArmorToBeAffected).Value = CharacterArmor:FindFirstChild(ArmorToBeAffected).Value - dam2

							if armorVal < 0 then
								armorVal = 0
							end
						else
							hum.Health = math.min(hum.Health - dam2,hum.MaxHealth)
						end
					end
				elseif HitPart.Parent and HitPart.Parent:GetAttribute("Health") then
					HitPart:SetAttribute("Health", HitPart.Parent:GetAttribute("Health") - dam2)
				else
					hum.Health = math.min(hum.Health - dam2,hum.MaxHealth)
				end
				if not slower then return end
				if hum:GetAttribute('Slowed') then return end
				hum:SetAttribute('Slowed',true)
				local savW = hum.WalkSpeed
				hum.WalkSpeed = hum.WalkSpeed/5
				TS:Create(hum,TweenInfo.new(2),{WalkSpeed = savW}):Play()
				task.delay(2,function()
					hum:SetAttribute('Slowed',nil)
				end)
			end
		elseif hit.Parent:FindFirstChild('VecHealth') then
			if wepName == "Heal" then
				if hit.Parent:FindFirstChild('Settings') and C.Settings.General.Team.Value == hit.Parent:FindFirstChild('Settings').General.Team.Value then
					hit.Parent:FindFirstChild('VecHealth').Value = math.min(hit.Parent:FindFirstChild('VecHealth').Value + dam2*80,hit.Parent:FindFirstChild('VecHealth'):GetAttribute('Max'))
				elseif distance < 75 then
					hit.Parent:FindFirstChild('VecHealth').Value = math.min(hit.Parent:FindFirstChild('VecHealth').Value - dam2*80,hit.Parent:FindFirstChild('VecHealth'):GetAttribute('Max'))
				end
			else
				hit.Parent:FindFirstChild('VecHealth').Value = math.min(hit.Parent:FindFirstChild('VecHealth').Value - dam2*80,hit.Parent:FindFirstChild('VecHealth'):GetAttribute('Max'))
			end
		end
	end)
	Debris:AddItem(e,3)
	Debris:AddItem(sf,3)
end

local function Fire(C)
	if C.Settings.Combat.HoldFire.Value == true then return end
	if C.Settings.Combat.FireTime.Value > 0 or C.GunStat.LoadedAmmo.Value == 0 or
		C.Settings.Combat.ReloadTime.Value > 0 or (C.Head:FindFirstChild('ArmsWeld') and C.Head.ArmsWeld.C0.Position.Magnitude > .03) 
		or C.Settings.Combat.ReactionTime.Value > 0 
	then return end
	
	C.Settings.Combat.FireTime.Value = 60/C.GunStat.FireRate.Value
	C.GunStat.LoadedAmmo.Value = math.max(C.GunStat.LoadedAmmo.Value - 1,0)
	if C.Head:FindFirstChild('ArmsWeld') then
		C.Head.ArmsWeld.C1 = CFrame.new()
	end
	if C.GunStat:GetAttribute('KumaSpecial') then
		local meleeTool = Storage.GunStats[C.GunStat:GetAttribute('MeleeTool')]
		if C.Settings.Combat.Target and (C.PrimaryPart.Position - C.Settings.Combat.Target.Value.PrimaryPart.Position).Magnitude <  C.GunStat:GetAttribute('CustomMeleeRange') then
			local pos = C.PrimaryPart.Position
			local dist = (pos - C.Settings.Combat.Target.Value.PrimaryPart.Position).Magnitude
			local hasSword = false
			local sword = nil
			local conn = nil
			if C.GunStat:GetAttribute('CanMelee') == true then
				C.GunStat:SetAttribute('CanMelee',false)
				if meleeTool.Name == "Sword" or meleeTool.Name == "Staff2" then
					hasSword = true
					for _,v in pairs(C.Arms:GetDescendants()) do
						if v.Name ~= "ignore" then continue end
						if not v:FindFirstChild('HolsterPos') then continue end
						sword = v
						v.HolsterPos.Enabled = false
						v.ArmPos.Enabled = true
					end
				end
				if not hasSword then
					local e = Instance.new("Explosion")
					e:SetAttribute('Ignore',true)
					e.Position = pos
					e.BlastPressure = 0
					e.BlastRadius = meleeTool:GetAttribute('MeleeRange')
					e.DestroyJointRadiusPercent = 0
					e.Visible = false
					e.ExplosionType = Enum.ExplosionType.NoCraters
					e.Parent = workspace.ZeusWorkspace
					e.Hit:Connect(function(hit,distance)
						if not hit.Parent then return end
						if not C:FindFirstChild('Humanoid') then return end
						if not hit.Parent:FindFirstChild('Humanoid') then return end
						if hit.Parent:FindFirstChild('Humanoid') == C.Humanoid then return end
						if hit.Parent:FindFirstChild('Settings') and hit.Parent:FindFirstChild('Settings').General.Team.Value == C.Settings.General.Team.Value then return end
						if hit.Parent:GetAttribute('MeleeHit') then return end
						hit.Parent:SetAttribute('MeleeHit',true)
						local hum = hit.Parent:FindFirstChild('Humanoid')
						local dam = C.GunStat.BaseDamage.Value
						if dam == nil then dam = 10 end
						local dam = dam*(distance/meleeTool:GetAttribute('MeleeRange'))
						if C.GunStat:GetAttribute('Explosive') then
							dam *= 2
						end
						if hum then
							local ArmorToBeAffected
							local CharacterArmor = hum.Parent:FindFirstChild("Armor")

							for _,Info in pairs(ArmorTable) do
								for _,Limb in pairs(Info[2]) do
									if hit.Name == Limb or hit.Parent.Name == Limb or (hum.Parent:GetAttribute('Morph') and hit.Parent.Name == hum.Parent:GetAttribute('Morph').."_"..Limb) then
										ArmorToBeAffected = Info[1]
										break
									end
								end	
							end
							if hum.Parent:GetAttribute('Morph') and hit.Parent.Name == hum.Parent:GetAttribute('Morph').." Helmet_Head" then
								ArmorToBeAffected = "HeadArmor"
							end

							if CharacterArmor and ArmorToBeAffected and CharacterArmor:FindFirstChild(ArmorToBeAffected) and CharacterArmor:FindFirstChild(ArmorToBeAffected).Value >= dam then
								local Surplus = CharacterArmor:FindFirstChild(ArmorToBeAffected).Value - dam

								if 0 > Surplus then
									CharacterArmor:FindFirstChild(ArmorToBeAffected).Value = CharacterArmor:FindFirstChild(ArmorToBeAffected).Value - dam

									if CharacterArmor:FindFirstChild(ArmorToBeAffected).Value == 0 then
										hum:TakeDamage(Surplus)
									end
								else
									CharacterArmor:FindFirstChild(ArmorToBeAffected).Value = CharacterArmor:FindFirstChild(ArmorToBeAffected).Value - dam
								end
							elseif HitPart.Parent and HitPart.Parent:GetAttribute("Health") then
								HitPart:SetAttribute("Health", HitPart.Parent:GetAttribute("Health") - dam)
							else
								hum:TakeDamage(dam)
							end
						end
						task.delay(0.4,function()
							if hit.Parent == nil then return end
							hit.Parent:SetAttribute('MeleeHit',nil)
						end)
					end)
					local tempSound = Storage.Audio.Fire[meleeTool.Name]:Clone()
					tempSound.Parent = C.PrimaryPart
					tempSound:Play()
					Debris:AddItem(tempSound,tempSound.TimeLength+0.2)
				else
					if C:GetAttribute('Stunned') then return end
					local tempSound = Storage.Audio.Fire[meleeTool.Name]:Clone()
					tempSound.Parent = C.PrimaryPart
					tempSound:Play()
					Debris:AddItem(tempSound,tempSound.TimeLength+0.2)
					local att = math.random(5)
					if att == 5 then --Lunge
						tempSound.Volume = 0.4
						--TS:Create(C.Arms.PrimaryPart["Right Shoulder"],tweenInfo,{C0 = PosAndAnglesToCF(Vector3.new(1.5,-1,-0.5),Vector3.new(20,10,0))}):Play()
						TS:Create(C.Arms.PrimaryPart["Right Shoulder"], TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{C0 = PosAndAnglesToCF(C.GunStat.RightArmsPos.Value,(C.GunStat.RightArmsAngles.Value + Vector3.new(-20,-50,90)))}):Play()
						task.wait(0.3)
						if not C:FindFirstChild('Arms') then return end
						TS:Create(C.Arms.PrimaryPart["Right Shoulder"], TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{C0 = PosAndAnglesToCF(C.GunStat.RightArmsPos.Value,(C.GunStat.RightArmsAngles.Value + Vector3.new(-80,50,90)))}):Play()
					--elseif att == 2 then -- Diagonal Slash
					--	TS:Create(C.Arms.PrimaryPart["Right Shoulder"], TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{C0 = PosAndAnglesToCF(C.GunStat.RightArmsPos.Value,(C.GunStat.RightArmsAngles.Value + Vector3.new(20,50,90)))}):Play()
					--	task.wait(0.3)
					--	TS:Create(C.Arms.PrimaryPart["Right Shoulder"], TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{C0 = PosAndAnglesToCF(C.GunStat.RightArmsPos.Value,(C.GunStat.RightArmsAngles.Value + Vector3.new(20,10,30)))}):Play()
					elseif att == 4 then -- Side Slash
						TS:Create(C.Arms.PrimaryPart["Right Shoulder"], TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{C0 = PosAndAnglesToCF(C.GunStat.RightArmsPos.Value,(C.GunStat.RightArmsAngles.Value + Vector3.new(-80,80,90)))}):Play()
						task.wait(0.3)
						if not C:FindFirstChild('Arms') then return end
						TS:Create(C.Arms.PrimaryPart["Right Shoulder"], TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{C0 = PosAndAnglesToCF(C.GunStat.RightArmsPos.Value,(C.GunStat.RightArmsAngles.Value + Vector3.new(-20,-50,90)))}):Play()
					else --Normal slash
						TS:Create(C.Arms.PrimaryPart["Right Shoulder"],tweenInfo,{C0 = PosAndAnglesToCF(C.GunStat.RightArmsPos.Value,(C.GunStat.RightArmsAngles.Value + Vector3.new(-45,30,0)))}):Play()
					end
					conn = sword.Touched:Connect(function(hit)
						if not hit.Parent then return end
						local hum = hit.Parent:FindFirstChild('Humanoid') 
						if hum == nil and hit.Parent.Parent then
							hum = hit.Parent.Parent:FindFirstChild('Humanoid') 
						end
						if not hum then return end
						if hum.Parent.Name == "Arms" then
							hum = hum.Parent.Parent.Humanoid
						end
						if hum == C.Humanoid then return end
						if hum:GetAttribute('MeleeHit') then return end
						hum:SetAttribute('MeleeHit',true)
						if hum:FindFirstChild('ParryActive') and hum.ParryActive.Value == true then
							hum.Parent:SetAttribute('ParrySuccessful',true)
							C:SetAttribute('Stunned',true)
							local tempSound = Instance.new("Sound")
							tempSound.SoundId = "rbxassetid://7029643523"
							tempSound.Parent = C.PrimaryPart
							tempSound.Volume = 1
							tempSound:Play()
							Debris:AddItem(tempSound,tempSound.TimeLength+0.2)
							sword.Shine:Emit(150)
							sword.Sparks:Emit(150)
							sword.Waves:Emit(150)
							task.delay(1,function()
								hum.Parent:SetAttribute('ParrySuccessful',false)
								task.wait(0.5)
								if not C:FindFirstChild('Arms') then return end
								TS:Create(C.Arms.PrimaryPart["Right Shoulder"],tweenInfo,{C0 = PosAndAnglesToCF(C.GunStat.RightArmsPos.Value,C.GunStat.RightArmsAngles.Value)}):Play()
								C:SetAttribute('Stunned',nil)
								C.GunStat:SetAttribute('CanMelee',true)
							end)
							task.wait(0.5)
						else
							local tempSound = Instance.new("Sound")
							tempSound.SoundId = "rbxassetid://4459571342"
							tempSound.Parent = C.PrimaryPart
							tempSound.Volume = 1
							tempSound:Play()
							hum.Health -= meleeTool.BaseDamage.Value + (10*att)
						end
						
						task.delay(0.4,function()
							if hum == nil then return end
							hum:SetAttribute('MeleeHit',nil)
						end)
					end)
				end
				Instance.new("BoolValue",script.Parent.FiresId).Name = Config.FiresCount.Value
				Config.FiresCount.Value += 1

				local recoil = math.min(meleeTool.BaseDamage.Value,25)
				C.Head.ArmsWeld.C1 = CFrame.new(0,0,-recoil/3000) * CFrame.Angles(-recoil/550,recoil * math.random(-10,10)/17000,recoil * math.random(-10,10)/17000)

				CreateAlert("Gunshot",C,C.Arms.GunModel.Muzzle.Position,true)

				task.delay(C.GunStat:GetAttribute('MeleeCooldown'),function()
					if hasSword then
						conn:Disconnect()
						local m = math.random(3)
						--TS:Create(sword.ArmPos,tweenInfo,{C1 = PosAndAnglesToCF(Vector3.new(-0.25,-2.7,-4.2),Vector3.new(-87,-180,-180))}):Play()
						if m == 1 then
							task.wait(0.5)
							if not C:FindFirstChild('Humanoid') then return end
							C.Humanoid.ParryActive.Value = true
							local tempSound = Instance.new("Sound")
							tempSound.SoundId = "rbxassetid://7647207390"
							tempSound.Parent = C.PrimaryPart
							tempSound.Volume = 1
							tempSound:Play()
							Debris:AddItem(tempSound,tempSound.TimeLength+0.2)
							TS:Create(C.Arms.PrimaryPart["Right Shoulder"],tweenInfo,{C0 = PosAndAnglesToCF(C.GunStat.RightArmsPos.Value,(C.GunStat.RightArmsAngles.Value + Vector3.new(0,30,-30)))}):Play()
							task.wait(1.5)
							if C:FindFirstChild('Humanoid') then
								C.Humanoid.ParryActive.Value = false
							end
						end
						if not C:FindFirstChild('Arms') then return end
						TS:Create(C.Arms.PrimaryPart["Right Shoulder"],tweenInfo,{C0 = PosAndAnglesToCF(C.GunStat.RightArmsPos.Value,C.GunStat.RightArmsAngles.Value)}):Play()
					end
					C.GunStat:SetAttribute('CanMelee',true)
				end)
			end
		
		else
			if meleeTool.Name == "Sword" or meleeTool.Name == "Staff2" then
				for _,v in pairs(C.Arms:GetDescendants()) do
					if v.Name ~= "ignore" then continue end
					if not v:FindFirstChild('HolsterPos') then continue end
					v.HolsterPos.Enabled = true
					v.ArmPos.Enabled = false
					C.Arms.PrimaryPart["Right Shoulder"].C0 = PosAndAnglesToCF(C.GunStat.RightArmsPos.Value,C.GunStat.RightArmsAngles.Value)
				end
			end
			local explosiveRound = C.GunStat:GetAttribute('Explosive')
			local OTU = C.GunStat:GetAttribute('OTU')

			Storage.Events.Remote:FireAllClients({
				Title = "CreateBulletProjectile",
				C = C,
				OriginPos = C.Arms.GunModel.Muzzle.Position,
				Direction = (C.Arms.GunModel.Muzzle.CFrame * CFrame.Angles(math.random(-10,10)/10000 * C.GunStat.Inaccuracy.Value,math.random(-10,10)/10000 * C.GunStat.Inaccuracy.Value,0)).LookVector,
				BaseDamage = C.GunStat.BaseDamage.Value,
				MuzzleVelocity = C.GunStat.MuzzleVelocity.Value,
				Team = C.Settings.General.Team.Value,
				FireId = Config.FiresCount.Value,
				Explosive = explosiveRound,
				OTU = OTU
			})

			Instance.new("BoolValue",script.Parent.FiresId).Name = Config.FiresCount.Value
			Config.FiresCount.Value += 1

			local recoil = math.min(C.GunStat.BaseDamage.Value,25)
			C.Head.ArmsWeld.C1 = CFrame.new(0,0,-recoil/3000) * CFrame.Angles(-recoil/550,recoil * math.random(-10,10)/17000,recoil * math.random(-10,10)/17000)

			CreateAlert("Gunshot",C,C.Arms.GunModel.Muzzle.Position,true)

			if C.Arms.GunModel.Muzzle:FindFirstChild('Fire') then C.Arms.GunModel.Muzzle.Fire:Play() end
			if C.Arms.GunModel.Handle:FindFirstChild('Echo') then C.Arms.GunModel.Handle.Echo:Play() end
		end
		return
	elseif C.GunStat:GetAttribute('Melee') then
		local pos = C.PrimaryPart.Position
		local dist = (pos - C.Settings.Combat.Target.Value.PrimaryPart.Position).Magnitude
		if dist > C.GunStat:GetAttribute('MeleeRange') then 
			if C.GunStat:GetAttribute('GunName') == "Sword" then
				for _,v in pairs(C.Arms:GetDescendants()) do
					if v.Name ~= "ignore" then continue end
					if not v:FindFirstChild('HolsterPos') then continue end
					v.HolsterPos.Enabled = true
					v.ArmPos.Enabled = false
					C.Arms.PrimaryPart["Right Shoulder"].C0 = PosAndAnglesToCF(C.GunStat.RightArmsPos.Value,C.GunStat.RightArmsAngles.Value)
				end
				C.GunStat:SetAttribute('Cooldown',false)
			end
			return 
		end
		local hasSword = false
		local sword = nil
		local conn = nil
		if C.GunStat:GetAttribute('MeleeCooldown') then --C.GunStat:GetAttribute('GunName') == "Sword" then
			hasSword = true
			for _,v in pairs(C.Arms:GetDescendants()) do
				if v.Name ~= "ignore" then continue end
				if not v:FindFirstChild('HolsterPos') then continue end
				sword = v
				v.HolsterPos.Enabled = false
				v.ArmPos.Enabled = true
			end
		end
		if not hasSword then
			if C.GunStat:GetAttribute('VisibleEXP') or C.GunStat:GetAttribute('GunName') == "ParadiseT" then
				makeExplosion(pos,C:FindFirstChild('GunStat').BaseDamage.Value,true,'AcidSpit',C)
				if C.GunStat:GetAttribute('OTU') then
					task.wait(0.5)
					if not C then return end
					if C:FindFirstChild('Humanoid') then
						C.Humanoid.Health = 0
					elseif C:FindFirstChild('VecHealth') then
						C.VecHealth.Value = 0
					end
				end
				return
			else
				local e = Instance.new("Explosion")
				e:SetAttribute('Ignore',true)
				e.Position = pos
				e.BlastPressure = 0
				e.BlastRadius = C.GunStat:GetAttribute('MeleeRange')
				e.DestroyJointRadiusPercent = 0
				e.Visible = false
					e.ExplosionType = Enum.ExplosionType.NoCraters
					e.Parent = workspace.ZeusWorkspace
					e.Hit:Connect(function(hit,distance)
						if not hit.Parent then return end
						if not C:FindFirstChild('Humanoid') and not C:FindFirstChild('VecHealth') then return end
						if not hit.Parent:FindFirstChild('Humanoid') then return end
						if hit.Parent:FindFirstChild('Settings') and hit.Parent:FindFirstChild('Settings').General.Team.Value == C.Settings.General.Team.Value then return end
						if hit.Parent:GetAttribute('MeleeHit') then return end
						hit.Parent:SetAttribute('MeleeHit',true)
						local hum = hit.Parent:FindFirstChild('Humanoid')
						local dam = C.GunStat.BaseDamage.Value
						if dam == nil then dam = 10 end
						local dam = dam*(distance/C.GunStat:GetAttribute('MeleeRange'))
						if C.GunStat:GetAttribute('Explosive') then
							dam *= 2
						end
						if hum then
							local ArmorToBeAffected
							local CharacterArmor = hum.Parent:FindFirstChild("Armor")

						for _,Info in pairs(ArmorTable) do
							for _,Limb in pairs(Info[2]) do
								if hit.Name == Limb or hit.Parent.Name == Limb or (hum.Parent:GetAttribute('Morph') and hit.Parent.Name == hum.Parent:GetAttribute('Morph').."_"..Limb) then
									ArmorToBeAffected = Info[1]
									break
								end
							end	
						end
						if hum.Parent:GetAttribute('Morph') and hit.Parent.Name == hum.Parent:GetAttribute('Morph').." Helmet_Head" then
							ArmorToBeAffected = "HeadArmor"
						end

							if CharacterArmor and ArmorToBeAffected and CharacterArmor:FindFirstChild(ArmorToBeAffected) and CharacterArmor:FindFirstChild(ArmorToBeAffected).Value >= dam then
								local Surplus = CharacterArmor:FindFirstChild(ArmorToBeAffected).Value - dam

								if 0 > Surplus then
									CharacterArmor:FindFirstChild(ArmorToBeAffected).Value = CharacterArmor:FindFirstChild(ArmorToBeAffected).Value - dam

									if CharacterArmor:FindFirstChild(ArmorToBeAffected).Value == 0 then
										hum:TakeDamage(Surplus)
									end
								else
									CharacterArmor:FindFirstChild(ArmorToBeAffected).Value = CharacterArmor:FindFirstChild(ArmorToBeAffected).Value - dam
								end
							elseif HitPart.Parent and HitPart.Parent:GetAttribute("Health") then
								HitPart:SetAttribute("Health", HitPart.Parent:GetAttribute("Health") - dam)
							else
								hum:TakeDamage(dam)
							end
						end
						task.delay(0.4,function()
							if hit.Parent == nil then return end
							hit.Parent:SetAttribute('MeleeHit',nil)
						end)
					end)
					Debris:AddItem(e,3)
			end
			
			
			if C.Arms.GunModel.Muzzle:FindFirstChild('Fire') then C.Arms.GunModel.Muzzle.Fire:Play() end
			if C.Arms.GunModel.Handle:FindFirstChild('Echo') then C.Arms.GunModel.Handle.Echo:Play() end
			if C.GunStat:GetAttribute('OTU') then
				task.wait(0.5)
				if not C then return end
				if C:FindFirstChild('Humanoid') then
					C.Humanoid.Health = 0
				elseif C:FindFirstChild('VecHealth') then
					C.VecHealth.Value = 0
				end
			end
		else
			if C:GetAttribute('Stunned') then return end
			if C.GunStat:GetAttribute('Cooldown') == true then return end
			C.GunStat:SetAttribute('Cooldown',true)
			local tempSound = Storage.Audio.Fire[C.GunStat:GetAttribute('GunName')]:Clone()
			tempSound.Parent = C.PrimaryPart
			tempSound:Play()
			Debris:AddItem(tempSound,tempSound.TimeLength+0.2)
			local att = math.random(3)
			if C.GunStat:GetAttribute('GunName') == "Sword" then
				if att == 3 then -- Side slash
					TS:Create(C.Arms.PrimaryPart["Right Shoulder"],TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{C0 = PosAndAnglesToCF(C.GunStat.RightArmsPos.Value,(C.GunStat.RightArmsAngles.Value + Vector3.new(0,0,45)))}):Play()
					task.wait(0.3)
					if not C:FindFirstChild('Arms') then return end
					TS:Create(C.Arms.PrimaryPart["Right Shoulder"],TweenInfo.new(0.7,Enum.EasingStyle.Sine),{C0 = PosAndAnglesToCF(C.GunStat.RightArmsPos.Value,(C.GunStat.RightArmsAngles.Value + Vector3.new(15,70,30)))}):Play()
				else
					TS:Create(C.Arms.PrimaryPart["Right Shoulder"],TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{C0 = PosAndAnglesToCF(C.GunStat.RightArmsPos.Value,(C.GunStat.RightArmsAngles.Value + Vector3.new(85,0,0)))}):Play()
					task.wait(0.3)
					if not C:FindFirstChild('Arms') then return end
					TS:Create(C.Arms.PrimaryPart["Right Shoulder"],TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{C0 = PosAndAnglesToCF(C.GunStat.RightArmsPos.Value,(C.GunStat.RightArmsAngles.Value + Vector3.new(20,0,0)))}):Play()
				end
			else
				if att == 3 then -- Side slash
					TS:Create(C.Arms.PrimaryPart["Right Shoulder"],TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{C0 = PosAndAnglesToCF(C.GunStat.RightArmsPos.Value,(C.GunStat.RightArmsAngles.Value + Vector3.new(0,0,45)))}):Play()
					task.wait(0.3)
					if not C:FindFirstChild('Arms') then return end
					TS:Create(C.Arms.PrimaryPart["Right Shoulder"],TweenInfo.new(0.7,Enum.EasingStyle.Sine),{C0 = PosAndAnglesToCF(C.GunStat.RightArmsPos.Value,(C.GunStat.RightArmsAngles.Value + Vector3.new(15,70,30)))}):Play()
				else
					TS:Create(C.Arms.PrimaryPart["Right Shoulder"],TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{C0 = PosAndAnglesToCF(C.GunStat.RightArmsPos.Value,(C.GunStat.RightArmsAngles.Value + Vector3.new(85,0,0)))}):Play()
					task.wait(0.3)
					if not C:FindFirstChild('Arms') then return end
					TS:Create(C.Arms.PrimaryPart["Right Shoulder"],TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{C0 = PosAndAnglesToCF(C.GunStat.RightArmsPos.Value,(C.GunStat.RightArmsAngles.Value + Vector3.new(20,0,0)))}):Play()
				end
			end
			conn = sword.Touched:Connect(function(hit)
				if not hit.Parent then return end
				local hum = hit.Parent:FindFirstChild('Humanoid') 
				if hum == nil and hit.Parent.Parent then
					hum = hit.Parent.Parent:FindFirstChild('Humanoid') 
				end
				if not hum then return end
				if hum.Parent.Name == "Arms" then
					hum = hum.Parent.Parent.Humanoid
				end
				if hum:GetAttribute('MeleeHit') then return end
				hum:SetAttribute('MeleeHit',true)
				if hum:FindFirstChild('ParryActive') and hum.ParryActive.Value == true then
					hum.Parent:SetAttribute('ParrySuccessful',true)
					C:SetAttribute('Stunned',true)
					local tempSound = Instance.new("Sound")
					tempSound.SoundId = "rbxassetid://7029643523"
					tempSound.Parent = C.PrimaryPart
					tempSound.Volume = 1
					tempSound:Play()
					Debris:AddItem(tempSound,tempSound.TimeLength+0.2)
					sword.Shine:Emit(150)
					sword.Sparks:Emit(150)
					sword.Waves:Emit(150)
					task.delay(1,function()
						hum.Parent:SetAttribute('ParrySuccessful',false)
						task.wait(0.5)
						if not C:FindFirstChild('Arms') then return end
						TS:Create(C.Arms.PrimaryPart["Right Shoulder"],tweenInfo,{C0 = PosAndAnglesToCF(C.GunStat.RightArmsPos.Value,C.GunStat.RightArmsAngles.Value)}):Play()
						C:SetAttribute('Stunned',nil)
						C.GunStat:SetAttribute('CanMelee',true)
					end)
					task.wait(0.5)
				else
					local tempSound = Instance.new("Sound")
					tempSound.SoundId = "rbxassetid://4459571342"
					tempSound.Parent = C.PrimaryPart
					tempSound.Volume = 1
					tempSound:Play()
					hum.Health -= C.GunStat.BaseDamage.Value + (10*att)
				end

				task.delay(0.4,function()
					if hum == nil then return end
					hum:SetAttribute('MeleeHit',nil)
				end)
			end)
		end
		Instance.new("BoolValue",script.Parent.FiresId).Name = Config.FiresCount.Value
		Config.FiresCount.Value += 1

		local recoil = math.min(C.GunStat.BaseDamage.Value,25)
		if C.Head:FindFirstChild('ArmsWeld') then
			C.Head.ArmsWeld.C1 = CFrame.new(0,0,-recoil/3000) * CFrame.Angles(-recoil/550,recoil * math.random(-10,10)/17000,recoil * math.random(-10,10)/17000)
		end
		CreateAlert("Gunshot",C,C.Arms.GunModel.Muzzle.Position,true)

		task.delay(C.GunStat:GetAttribute('MeleeCooldown'),function()
			if hasSword then
				conn:Disconnect()
				local m = math.random(3)
				if m == 1 then
					task.wait(0.5)
					if not C:FindFirstChild('Humanoid') then return end
					C.Humanoid.ParryActive.Value = true
					local tempSound = Instance.new("Sound")
					tempSound.SoundId = "rbxassetid://7647207390"
					tempSound.Parent = C.PrimaryPart
					tempSound.Volume = 1
					tempSound:Play()
					Debris:AddItem(tempSound,tempSound.TimeLength+0.2)
					TS:Create(C.Arms.PrimaryPart["Right Shoulder"],tweenInfo,{C0 = PosAndAnglesToCF(C.GunStat.RightArmsPos.Value,(C.GunStat.RightArmsAngles.Value + Vector3.new(15,70,70)))}):Play()
					task.wait(1.5)
					if C:FindFirstChild('Humanoid') then
						C.Humanoid.ParryActive.Value = false
					end
				end
				if not C:FindFirstChild('Arms') then return end
				TS:Create(C.Arms.PrimaryPart["Right Shoulder"],tweenInfo,{C0 = PosAndAnglesToCF(C.GunStat.RightArmsPos.Value,C.GunStat.RightArmsAngles.Value)}):Play()
			end
			if C:FindFirstChild('GunStat') then
				C.GunStat:SetAttribute('Cooldown',false)
			end
		end)
	elseif C.GunStat:GetAttribute('Flame') then
		print(2)
		if C.GunStat:GetAttribute('Flaming') then return end
		C.GunStat:SetAttribute('Flaming',true) 
		local gunModel = C.Arms.GunModel
		gunModel.Main.Att.Flame.Enabled = true
		gunModel.Main.Att.Light.Enabled = true
		gunModel.Main.Att.Burn:Play()
		Instance.new("BoolValue",script.Parent.FiresId).Name = Config.FiresCount.Value
		Config.FiresCount.Value += 1
		CreateAlert("Gunshot",C,gunModel.Muzzle.Position,true)
		local dmg = C.GunStat.BaseDamage.Value
		if gunModel.Muzzle:FindFirstChild('Fire') then gunModel.Muzzle.Fire:Play() end
		if gunModel.Handle:FindFirstChild('Echo') then gunModel.Handle.Echo:Play() end
		
		for i = 1, 15 do
			task.delay(i/10,function()
				if gunModel == nil then return end
				for _,v in pairs(gunModel.Main.Att:GetChildren()) do
					if string.sub(v.Name,1,7) ~= "BurnAtt" then continue end
					local boom = Instance.new("Explosion")
					boom:SetAttribute('Ignore',true)
					boom.BlastPressure = 0
					boom.BlastRadius = 10 + 2*tonumber(string.sub(v.Name,8))
					boom.DestroyJointRadiusPercent = 0
					boom.ExplosionType = Enum.ExplosionType.NoCraters
					boom.Visible = false
					boom.Parent = workspace.ZeusWorkspace
					boom.Position = v.WorldPosition
					boom.Hit:Connect(function(hit,distance)
						local dam =  dmg* math.clamp(distance/boom.BlastRadius,0.001,1)
						local hum = hit.Parent:FindFirstChildOfClass('Humanoid')
						if not hum or not hum.Parent then return end
						if hum.Parent:FindFirstChild("Armor") then
							local ArmorToBeAffected
							local CharacterArmor = hum.Parent:FindFirstChild("Armor")

							for _,Info in pairs(ArmorTable) do
								for _,Limb in pairs(Info[2]) do
									if hit.Name == Limb or hit.Parent.Name == Limb or (hum.Parent:GetAttribute('Morph') and hit.Parent.Name == hum.Parent:GetAttribute('Morph').."_"..Limb) then
										ArmorToBeAffected = Info[1]
										break
									end
								end	
							end
							if hum.Parent:GetAttribute('Morph') and hit.Parent.Name == hum.Parent:GetAttribute('Morph').." Helmet_Head" then
								ArmorToBeAffected = "HeadArmor"
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
						elseif HitPart.Parent and HitPart.Parent:GetAttribute("Health") then
							HitPart:SetAttribute("Health", HitPart.Parent:GetAttribute("Health") - dam)
						else
							hum:TakeDamage(dam)
						end
					end)
					Debris:AddItem(boom,2)
				end
				if i == 15 then
					gunModel.Main.Att.Flame.Enabled = false
					gunModel.Main.Att.Light.Enabled = false
					gunModel.Main.Att.Burn:Stop()
					task.wait(0.1)
					C.GunStat:SetAttribute('Flaming',nil) 
				end
			end)
		end
	elseif C.GunStat:GetAttribute('MortarMode') then
		local gunModel = C.Arms.GunModel
		local muzzle = nil
		for _,v in pairs(C:GetDescendants()) do
			if v.Name ~= "MortarMuzzle" then continue end
			muzzle = v
		end
		if not muzzle then return end
		
		local pos1 = muzzle.Position
		local pos2 = C.Settings.Combat.Target.Value.PrimaryPart
		local rand = math.random(50)/10
		local rand2 = math.random(-1,1)
		rand *= rand2
		local direction = pos2.Position - pos1
		
		if direction.Magnitude < 50 then return end
		
		Instance.new("BoolValue",script.Parent.FiresId).Name = Config.FiresCount.Value
		Config.FiresCount.Value += 1
		CreateAlert("Gunshot",C,gunModel.Muzzle.Position,true)
		local dmg = C.GunStat.BaseDamage.Value
		if gunModel.Muzzle:FindFirstChild('Fire') then gunModel.Muzzle.Fire:Play() end
		if gunModel.Handle:FindFirstChild('Echo') then gunModel.Handle.Echo:Play() end
		muzzle.DistantGunSound:Play()
		muzzle.Flash:Emit(50)
		muzzle.SmokeEffect1:Emit(50)
		muzzle.SmokeEffect2:Emit(50)
		
		
		local dist = math.clamp(direction.Magnitude/100,0.1,3)
		local duration = math.log(1.001 + direction.Magnitude * 0.01) + dist
		pos2 = pos2.Position + pos2.AssemblyLinearVelocity * duration
		direction = pos2 - pos1
		local force = direction / duration + Vector3.new(rand,rand + (game.Workspace.Gravity * duration * 0.5),rand)

		local clone = game.ServerStorage.Projectile:Clone()
		clone.Position = pos1
		clone.Parent = workspace.ZeusWorkspace
		clone:ApplyImpulse(force*clone.AssemblyMass)
		clone:SetNetworkOwner(nil)
		game:GetService('Debris'):AddItem(clone,2*duration)
		local dam = C.GunStat.BaseDamage.Value
		task.wait(0.5)
		local playSpeed = math.max(4.5/duration,0.9)
		if clone:FindFirstChild('Bomb') then
			clone.MiniNuke.Transparency = 0
			clone.Bomb.PlaybackSpeed = playSpeed
			clone.Bomb:Play()
			clone.Touched:Connect(function(hit)
				if not hit then return end
				clone.Anchored = true
				clone.Transparency = 1
				clone:ClearAllChildren()
				local pos = clone.Position
				local sf = Instance.new("Part",workspace.ZeusWorkspace)
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

				local e = Instance.new("Explosion")
				e:SetAttribute('Lowered',true)
				e.Position = pos
				e.BlastPressure = 10000
				e.BlastRadius = 50
				e.DestroyJointRadiusPercent = 0
				e.Visible = false
				
				Storage.Other.NormExplosion:Clone().Parent = sf
				task.delay(0.5,function()
					sf.NormExplosion:Destroy()
				end)
				e.ExplosionType = Enum.ExplosionType.NoCraters
				e.Parent = workspace.ZeusWorkspace
				e.Hit:Connect(function(hit,distance)
					if not hit.Parent then return end
					local hum = hit.Parent:FindFirstChild('Humanoid')
					distance = distance/10
					dam = math.clamp(dam/distance,1,100)
					if hum and game:GetService("Players"):GetPlayerFromCharacter(hum.Parent) then
						if hum.Parent:FindFirstChild('Dreadnaught') then
							hum.Parent.Dreadnaught.VecHealth.Value -= dam*7
						elseif hum.Parent:FindFirstChild("Armor") then
							local ArmorToBeAffected
							local CharacterArmor = hum.Parent:FindFirstChild("Armor")

							for _,Info in pairs(ArmorTable) do
								for _,Limb in pairs(Info[2]) do
									if hit.Name == Limb or hit.Parent.Name == Limb or (hum.Parent:GetAttribute('Morph') and hit.Parent.Name == hum.Parent:GetAttribute('Morph').."_"..Limb) then
										ArmorToBeAffected = Info[1]
										break
									end
								end	
							end
							if hum.Parent:GetAttribute('Morph') and hit.Parent.Name == hum.Parent:GetAttribute('Morph').." Helmet_Head" then
								ArmorToBeAffected = "HeadArmor"
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
						elseif HitPart.Parent and HitPart.Parent:GetAttribute("Health") then
							HitPart:SetAttribute("Health", HitPart.Parent:GetAttribute("Health") - dam)
						else
							hum:TakeDamage(dam)
						end

					else
						if hit.Parent:FindFirstChild('VecHealth') then
							hit.Parent:FindFirstChild('VecHealth').Value -= dam*5
						else
							hum:TakeDamage(dam)
						end
					end
				end)
				Debris:AddItem(e,3)
				Debris:AddItem(sf,3)
			end)
		end
	else
		local explosiveRound = C.GunStat:GetAttribute('Explosive')
		local OTU = C.GunStat:GetAttribute('OTU')
		
		local direction = nil
		local gunModel = C.Arms.GunModel
		if not C:GetAttribute('Special') then
			direction = (gunModel.Muzzle.CFrame * CFrame.Angles(math.random(-10,10)/10000 * C.GunStat.Inaccuracy.Value,math.random(-10,10)/10000 * C.GunStat.Inaccuracy.Value,0)).LookVector
		else
			direction = (C.Settings.Combat.SuppressPos.Value - gunModel.Muzzle.Position).Unit
		end
		
		Storage.Events.Remote:FireAllClients({
			Title = "CreateBulletProjectile",
			C = C,
			OriginPos = gunModel.Muzzle.Position,
			Direction = direction,
			BaseDamage = C.GunStat.BaseDamage.Value,
			MuzzleVelocity = C.GunStat.MuzzleVelocity.Value,
			Team = C.Settings.General.Team.Value,
			FireId = Config.FiresCount.Value,
			Explosive = explosiveRound,
			OTU = OTU,
			HitPart = HitPart
		})
		
		Instance.new("BoolValue",script.Parent.FiresId).Name = Config.FiresCount.Value
		Config.FiresCount.Value += 1
		
		if C:FindFirstChild('Humanoid') then

			local recoil = math.min(C.GunStat.BaseDamage.Value,25)
			C.Head.ArmsWeld.C1 = CFrame.new(0,0,-recoil/3000) * CFrame.Angles(-recoil/550,recoil * math.random(-10,10)/17000,recoil * math.random(-10,10)/17000)
		end

		CreateAlert("Gunshot",C,gunModel.Muzzle.Position,true)
		
		if gunModel.Muzzle:FindFirstChild('Fire') then gunModel.Muzzle.Fire:Play() end
		if gunModel.Handle:FindFirstChild('Echo') then gunModel.Handle.Echo:Play() end
	end
	
	--FireSound = gunModel.Muzzle.Fire:Clone()
	--FireSound.PlayOnRemove = true
	--FireSound.PlaybackSpeed = FireSound.PlaybackSpeed * .75
	--FireSound.Volume = FireSound.Volume/2
	--FireSound.RollOffMinDistance = 1000
	--FireSound.Parent = gunModel.Muzzle
	--FireSound:Destroy()
	
	--game:GetService("Debris"):AddItem(FireSound,3)
end

local function FireAtTarget(C,Ignore,Pos,special)
	--if not cs:HasTag(C.Settings.Combat.Target.Value,'Airzac') then return end
	if not special and C.Settings.Combat.ReactionTime.Value > 10 then return end
	--if not C.Settings.Combat.Target.Value.PrimaryPart then return end
	if not C.PrimaryPart then return end
	local c1 = C.Head.Position
	local dist = 100
	if C.Settings.Combat.Target.Value ~= nil and C.Settings.Combat.Target.Value.PrimaryPart then
		local c2 = C.Settings.Combat.Target.Value.Head.Position
		dist = (c1 - c2).Magnitude
	end
	if C.GunStat:GetAttribute('Melee') and dist > C.GunStat:GetAttribute('MeleeRange') then return end
	if cs:HasTag(C.Settings.Combat.Target.Value,'Cloaked') and dist > 30 then return end
	if not special and not LookAt(C,Ignore,Pos + Vector3.new(0,GetAngleBasedOnBallistic(C,C.GunStat.MuzzleVelocity.Value,(Pos - C.Head.Position).Magnitude),0)) then return end
	if not C:GetAttribute('Special') then
		if C.Settings.General.Walking.Value and ((C.Settings.General.LookAt.Value - C.Head.Position).Unit - C.Head.CFrame.LookVector).Magnitude < 25
			or ((C.Settings.General.LookAt.Value - C.Head.Position).Unit - C.Head.CFrame.LookVector).Magnitude < 25 then
			
			Fire(C)
		end
	else
		--local dist = (Pos - C.Head.Position).Magnitude
		Fire(C,dist)
	end
end

local function ChangeStance(C,NewStance)
	if C.Settings.General.StanceTime.Value == 0 then C.Settings.General.Stance.Value = NewStance end
end

local function Spotted(C1,C2)
	if C2 == nil then return end
	if not Storage.Command.EnableCombat.Value then return false end
	if not IsChar(C2) then return false end
	if pl:GetPlayerFromCharacter(C2) then
		if Storage.Command.Ignore.Value == "Players" then return false end
		if pl:GetPlayerFromCharacter(C2).Team.Name == "Zeus" or pl:GetPlayerFromCharacter(C2).Team.Name == C1.Settings.General.Team.Value then return false end
	elseif IsNPG(C2) or C2.Name == "Turret" then
		if Storage.Command.Ignore.Value == "Non-Players" then return false end
		if C2.Settings.General.Team.Value == C1.Settings.General.Team.Value then return false end
	end
	local C2p = C2.PrimaryPart.Position
	local C1p = C1.PrimaryPart.CFrame
	local dist = (C2p - C1p.Position).Magnitude 
	if dist > C1.GunStat:GetAttribute('SpottingDistance') then return false end
	local angleF = math.abs(GetAngle(C1p.LookVector,C2p - C1p.Position))
	if angleF > fov and not C1.GunStat:GetAttribute('Eyes') then return false end
		--if ((Storage.Command.Ignore.Value ~= "Players" and pl:GetPlayerFromCharacter(C2)
		--and (not pl:GetPlayerFromCharacter(C2).Team or pl:GetPlayerFromCharacter(C2).Team.Name ~= C1.Settings.General.Team.Value)) and pl:GetPlayerFromCharacter(C2).Team.Name ~= "Zeus"
		--or (Storage.Command.Ignore.Value ~= "Non-Players" and not IsNPG(C2) and not pl:GetPlayerFromCharacter(C2))
		--or (Storage.Command.Ignore.Value ~= "Non-Players" and IsNPG(C2) and C2.Settings.General.Team.Value ~= C1.Settings.General.Team.Value)) then
		
		----math.abs(math.acos(math.clamp(C.PrimaryPart.CFrame.LookVector:Dot((Target:GetPivot().Position - C:GetPivot().Position).Unit),-1,1))) <= math.rad(70)
		
		--if (C2.PrimaryPart.Position - C1.PrimaryPart.Position).Magnitude < C.GunStat:GetAttribute('SpottingDistance')
		--	and math.abs(GetAngle(C1.PrimaryPart.CFrame.LookVector,C2.PrimaryPart.Position - C1.PrimaryPart.Position)) <= math.rad(170) then
			--HitPart,HitPos,IgnoreTable = nil,nil,{C1}
			if C1.GunStat:GetAttribute('MortarMode') then
				return true
			end
			
			local TempIgnoreList = {C1}
			
			for i,v in pairs(PermIgnoreTable) do
				table.insert(TempIgnoreList, v)
			end
			
			local function RayRecursive()
				local HitPart,HitPos = workspace:FindPartOnRayWithIgnoreList(Ray.new(C1p.Position,C2p - C1p.Position),TempIgnoreList)
				if HitPart then
					if HitPart:HasTag("AIIgnore") or HitPart.Parent and HitPart.Parent:HasTag("AIIgnore") then
						table.insert(PermIgnoreTable, HitPart)
						wait()
						RayRecursive()
					else
						HitPart,HitPos = workspace:FindPartOnRayWithIgnoreList(Ray.new(C1p.Position,C2p - C1p.Position),TempIgnoreList)
						return HitPart, HitPos
					end
				else
					HitPart,HitPos = workspace:FindPartOnRayWithIgnoreList(Ray.new(C1p.Position,C2p - C1p.Position),TempIgnoreList)
					return HitPart, HitPos
				end
			end
			
			local HitPart, HitPos = RayRecursive()
			if not HitPart then return false end
			if cs:HasTag(C2,'Cloaked') and dist > 30 then return false end
			if HitPart.Parent == C2 then
				return true
			elseif HitPart.Parent.Parent == C2 then
				return true
			elseif cs:HasTag(HitPart.Parent,"Vehicle") then
				return true
			elseif cs:HasTag(HitPart.Parent.Parent,"Vehicle") then
				return true
			end
			--while true do
			--	HitPart,HitPos = workspace:FindPartOnRayWithIgnoreList(Ray.new(C1.PrimaryPart.Position,C2.PrimaryPart.Position - C1.PrimaryPart.Position),IgnoreTable)
				
			--	if not HitPart then return false end
			--	if HitPart:IsDescendantOf(C2) then return true end
			--	if HitPart.CanCollide and HitPart.Name ~= "ignore" then return false else table.insert(IgnoreTable,HitPart) end
			--end
		--end
	--end
	
	return false
end

local function SpotChar(C1)
	if Storage.Command.EnableCombat.Value then
		for _,C2 in pairs(airzacs) do local C2 = C2.airzac
		--for _,C2 in pairs(workspace:GetChildren()) do
			if C1 == C2 then continue end
			if Spotted(C1,C2) then return C2 end
		end
	end
	
	return nil
end

local function Leader(C)
	if C.Settings.General.ActionTime.Value == 0 then
		if C.Settings.General.Stance.Value == "Prone" then ChangeStance(C,"Kneel") else ChangeStance(C,"Stand") end
	end
	
	GroupPatrol = Storage.Patrol[C.Settings.Group.Id.Value]
	
	if not C.Settings.Combat.Target.Value and C.Settings.Combat.SuppressTime.Value == 0 then
		if GroupPatrol.Points:FindFirstChild(GroupPatrol.Num.Value) then
			C.Settings.General.WalkTo.Value = GroupPatrol.Points[GroupPatrol.Num.Value].Value
			local moveMagnitude = 7.5
			if C.Stage.Value == "Tank" then moveMagnitude = 14 end
			if (C:GetPivot().Position - C.Settings.General.WalkTo.Value).Magnitude < moveMagnitude then
				GroupPatrol.Num.Value += 1 end
		elseif GroupPatrol.Loop.Value then
			GroupPatrol.Num.Value = 1
		end
	end
	--Storage.Events.Remote:FireAllClients({Title = "MoveIndicate",Pos = C.Settings.General.WalkTo.Value,Char = C})
end

local function Member(C,L)
	C.Settings.Combat.Alerted.Value = L.Settings.Combat.Alerted.Value
	C.Settings.Combat.SuppressTime.Value = L.Settings.Combat.SuppressTime.Value
	C.Settings.Combat.SuppressPos.Value = L.Settings.Combat.SuppressPos.Value
	C.Settings.Group.Formation.Value = L.Settings.Group.Formation.Value
	C.Settings.General.ActionTime.Value = L.Settings.General.ActionTime.Value
	C.Settings.General.Stance.Value = L.Settings.General.Stance.Value
	
	if Storage.Formations:FindFirstChild(C.Settings.Group.Formation.Value) and (L.Settings.General.Walking.Value or L.Settings.Group.ReassembleTime.Value == 0) then
		FormationModel = Storage.Formations[C.Settings.Group.Formation.Value]
		FormationModel:PivotTo(L:GetPivot() - L:GetPivot().Position)
		C.Settings.General.WalkTo.Value = FormationModel[C.Settings.Group.Num.Value].Position * Config.FormationSpace.Value + L:GetPivot().Position
		--Storage.Events.Remote:FireAllClients({Title = "MoveIndicate",Pos = C.Settings.General.WalkTo.Value,Char = C})
		if (C:GetPivot().Position - C.Settings.General.WalkTo.Value).Magnitude > 15 or C.Settings.Combat.HoldFire.Value == true then
			C.Settings.General.Sprint.Value = "High"
		elseif (C:GetPivot().Position - C.Settings.General.WalkTo.Value).Magnitude > 7.5 then
			C.Settings.General.Sprint.Value = "Low"
		end
		
		if not C.Settings.Combat.Alerted.Value and C.Settings.Combat.SuppressTime.Value == 0
			and not L.Settings.General.Walking.Value and not C.Settings.General.Walking.Value
			--[[and math.abs(C:GetPivot().Position.X - C.Settings.General.WalkTo.Value.X) < 5
			and math.abs(C:GetPivot().Position.Z - C.Settings.General.WalkTo.Value.Z) < 5]] then
			FormationModel:PivotTo(CFrame.new())
			_,FormModelAngY,_ = FormationModel[C.Settings.Group.Num.Value].CFrame:ToEulerAnglesYXZ()
			_,HeadAngY,_ = C.Settings.Group.Leader.Value:GetPivot():ToEulerAnglesYXZ()
			LookAt(C,true,C:GetPivot().Position + CFrame.Angles(0,FormModelAngY + HeadAngY,0).LookVector * 2000)
			C.Settings.General.FacingTime.Value = .25
		end
		--Storage.Events.Remote:FireAllClients({Title = "MoveIndicate",Pos = C.Settings.General.WalkTo.Value,Char = C})
	end
end

local function Single(C)
	--if C.Settings.General.ActionTime.Value == 0 then
	--	if C.Settings.General.Stance.Value == "Prone" then ChangeStance(C,"Kneel") else ChangeStance(C,"Stand") end
	--end
	
	
		if C.Settings.Combat.LastContact.Value ~= Vector3.new() and not C.Settings.Combat.Target.Value and not C.Settings.Patrol.Points:FindFirstChild(1) then
			--if math.random(1,2) == 1 then
				C.Settings.Combat.ReactionTime.Value = math.random(0,8)/10
				--C.Settings.Combat.SuppressTime.Value = Config.SuppressionDuration.Value * math.random(5,15)/20
				C.Settings.Combat.SuppressPos.Value = C.Settings.Combat.LastContact.Value + Vector3.new(math.random(0,10)/10,math.random(0,10)/10,math.random(0,10)/10) * (C.Settings.Combat.LastContact.Value - C:GetPivot().Position)/20
				if math.random(1,2) == 2 and C.Settings.General.Movement.Value == "Mobile" then C.Settings.General.WalkTo.Value = GetRayPos(C:GetPivot().Position,C.Settings.Combat.LastContact.Value) end
			--elseif math.random(1,2) == 2 and C.Settings.General.Movement.Value == "Mobile" then C.Settings.General.WalkTo.Value = GetRayPos(C:GetPivot().Position,C.Settings.Combat.LastContact.Value) end
			C.Settings.Combat.LastContact.Value = Vector3.new()
		end
		
		if C.Settings.General.ActionTime.Value == 0 and not IsPatroling(C) then
			if not C.Settings.Combat.Target.Value and math.random(1,2) == 1 then
				LookAt(C,false,nil,5)
			elseif (not C.Settings.Combat.Target.Value or math.random(1,2) == 1) then
				if C.Settings.General.Movement.Value == "Mobile" then
					WalkTo(C,C.Settings.General.OriginPos.Value)
					if not C.Settings.Patrol.Points:FindFirstChild(1) then
						WalkTo(C,GetRayPos(C:GetPivot().Position,
							(C:GetPivot() * CFrame.Angles(0,math.rad(math.random(0,360)),0)).LookVector * math.random(5,15) * 3))
					end
				end
			end
		end
		
		if not C.Settings.Combat.Alerted.Value and C.Settings.Combat.SuppressTime.Value == 0 then
			if C.Settings.Patrol.Points:FindFirstChild(C.Settings.Patrol.Num.Value) and C.Settings.General.Movement.Value == "Mobile" then
				C.Settings.General.WalkTo.Value = C.Settings.Patrol.Points[C.Settings.Patrol.Num.Value].Value
				local moveMagnitude = 7.5
				if C.Stage.Value == "Tank" then moveMagnitude = 14 end
				if C:GetAttribute('Special') and C.Settings.Combat.Target.Value == nil then
					moveMagnitude = 50
					local LoiterHeight = C:GetAttribute('LoiterHeight')
					if C:GetAttribute("RandomHeight") then
						LoiterHeight = Vector3.new(0, LoiterHeight + math.random(C:GetAttribute("RandomHeight").Min, C:GetAttribute("RandomHeight").Max),0)
					end
					C.PrimaryPart.AP.Position = C.Settings.General.WalkTo.Value + LoiterHeight
					C.PrimaryPart.AP.MaxVelocity = C:GetAttribute('MoveSpeed')
					local TheadCF = CFrame.new(C.PrimaryPart.Position, C.Settings.General.WalkTo.Value)
					local _,Yrot,_ = TheadCF:ToOrientation()
					local TheadCF = CFrame.Angles(0,Yrot,0)
					C.PrimaryPart.AO.CFrame = TheadCF
				end
				if (C:GetPivot().Position - C.Settings.General.WalkTo.Value).Magnitude < moveMagnitude then C.Settings.Patrol.Num.Value += 1 end
			elseif C.Settings.Patrol.Loop.Value then
				C.Settings.Patrol.Num.Value = 1
			end
		end

end

local function Render()
	DeltaTime = tick() - LastTime
	LastTime = tick()

	--for _,C in pairs(workspace:GetChildren()) do
	for _,C in pairs(airzacs) do local C = C.airzac
		if IsNPG(C) then
			RootAngleY,RootAngleX,RootAngleZ = C.PrimaryPart.CFrame:ToEulerAnglesYXZ()
			_,LookAngleX,_ = CFrame.new(C.PrimaryPart.Position,C.Settings.General.LookAt.Value):ToEulerAnglesYXZ()
			_,MoveAngleX,_ = CFrame.new(C.PrimaryPart.Position,C.Settings.General.WalkTo.Value):ToEulerAnglesYXZ()
			if C:FindFirstChild('Humanoid') then
				local multiplyer = 1

				if C.Stage.Value == "Astartes" then
					multiplyer = 1.25
				elseif C.Stage.Value == "Ranger" or C.Stage.Value == "Vore" then
					multiplyer = 1.5
				elseif C.Stage.Value == "Gaunt" then
					multiplyer = 0.75
				elseif C.Stage.Value == "Terminator" then
					multiplyer = 1.7
				elseif C.Stage.Value == "Mech" or C.Stage.Value == "Monolith" then
					multiplyer = 10
				end

				if C.Settings.General.LookAt.Value ~= Vector3.new() and not C.Humanoid.Sit and not C.Humanoid.PlatformStand
					and C.Settings.General.FacingTime.Value > 0 then
					TorsoAngleX = LookAngleX - RootAngleX
				else TorsoAngleX = 0 end

				HeadCF = CFrame.new(0,1.5,0)

				if C.Settings.General.Stance.Value == "Stand" then
					if C.Stage.Value == "Mech" or C.Stage.Value == "Monolith" then
						HeadCF = CFrame.new(0,1.5*5.5,0)
					else
						HeadCF = CFrame.new(0,1.5*multiplyer,0)
					end
					TorsoCF = CFrame.Angles(math.rad(-90),0,math.rad(180) + TorsoAngleX)
					RightLegCF = CFrame.new(1*multiplyer,-1*multiplyer,0) * CFrame.Angles(0,math.rad(90),0)
					LeftLegCF = CFrame.new(-1*multiplyer,-1*multiplyer,0) * CFrame.Angles(0,math.rad(-90),0)
				elseif C.Settings.General.Stance.Value == "Kneel" then
					if C.Stage.Value == "Mech" or C.Stage.Value == "Monolith" then
						HeadCF = CFrame.new(0,1.5*5.5,.1) * CFrame.Angles(math.rad(20),0,0)
					else
						HeadCF = CFrame.new(0,1.5*multiplyer,.1) * CFrame.Angles(math.rad(20),0,0)
					end
					TorsoCF = CFrame.new(0,-.75*multiplyer,.35*multiplyer) * CFrame.Angles(math.rad(-110),0,math.rad(180))
					RightLegCF = CFrame.new(1*multiplyer,-1*multiplyer,-.75*multiplyer) * CFrame.Angles(0,math.rad(90),math.rad(-45))
					LeftLegCF = CFrame.new(-1*multiplyer,-.5*multiplyer,-.75*multiplyer) * CFrame.Angles(0,math.rad(-90),0)
				elseif C.Settings.General.Stance.Value == "Prone" then
					if C.Stage.Value == "Mech" or C.Stage.Value == "Monolith" then
						HeadCF = CFrame.new(0,1.25*5.5,.5*5.5) * CFrame.Angles(math.rad(90),0,0)
					else
						HeadCF = CFrame.new(0,1.25*multiplyer,.5*multiplyer) * CFrame.Angles(math.rad(90),0,0)
					end
					TorsoCF = CFrame.new(0,-2.5*multiplyer,1.1*multiplyer) * CFrame.Angles(math.rad(-180),0,math.rad(180))
					RightLegCF = CFrame.new(1*multiplyer,-1,0*multiplyer) * CFrame.Angles(0,math.rad(90),0)
					LeftLegCF = CFrame.new(-1*multiplyer,-1*multiplyer,0) * CFrame.Angles(0,math.rad(-90),0)
				end
				if C.Stage.Value ~= "Tank" then
					C.PrimaryPart["Root Hip"].C0 = C.PrimaryPart["Root Hip"].C0:Lerp(TorsoCF,1 - math.exp(-10 * DeltaTime))
					C.Torso.Neck.C0 = C.Torso.Neck.C0:Lerp(HeadCF,1 - math.exp(-10 * DeltaTime))
				else
					if (C.PrimaryPart.Position - C.Settings.General.WalkTo.Value).Magnitude > 12 then
						local TTorsoAngleX = MoveAngleX - RootAngleX
						local TankTorsoCF = CFrame.Angles(math.rad(-90),0,math.rad(180) + TTorsoAngleX)
						C.PrimaryPart["Root Hip"].C0 = C.PrimaryPart["Root Hip"].C0:Lerp(TankTorsoCF,1 - math.exp(-1 * DeltaTime))
					end
					if C.Settings.Combat.Target.Value ~= nil then
						local TheadCF = CFrame.new(C.Torso.Position, C.Settings.General.LookAt.Value)
						local _,Yrot,_ = TheadCF:ToOrientation()
						Yrot = Yrot - math.rad(C.Torso.Orientation.Y)
						local TheadCF = HeadCF*CFrame.Angles(0,Yrot,0)
						C.Torso.Neck.C0 = C.Torso.Neck.C0:Lerp(TheadCF,1 - math.exp(-10 * DeltaTime))
					else
						C.Torso.Neck.C0 = C.Torso.Neck.C0:Lerp(HeadCF,1 - math.exp(-10 * DeltaTime))
					end
				end
				C.Torso["Right Hip"].C0 = C.Torso["Right Hip"].C0:Lerp(RightLegCF,1 - math.exp(-10 * DeltaTime))
				C.Torso["Left Hip"].C0 = C.Torso["Left Hip"].C0:Lerp(LeftLegCF,1 - math.exp(-10 * DeltaTime))

				if C.Settings.Arms.Status.Value == "Port" and C.FactionType and C.FactionType.Value ~= "Civilian" and C.Stage.Value ~= "Terminator" and C.Stage.Value ~= "Dreadnaught" and C.Stage.Value ~= "Mech" and C.Stage.Value ~= "Truck" and C.Stage.Value ~= "Tank" and C.Stage.Value ~= "Ranger" then
					if not C.GunStat:GetAttribute('DenyPort') then
						ArmsStatusCF = CFrame.new(0,-.25*multiplyer,0) * CFrame.Angles(math.rad(-30),math.rad(70),math.rad(30))
					end
				else
					ArmsStatusCF = CFrame.new()
				end

				C.Head.ArmsWeld.C0 = C.Head.ArmsWeld.C0:Lerp(ArmsStatusCF,1 - math.exp(-10 * DeltaTime))
				C.Head.ArmsWeld.C1 = C.Head.ArmsWeld.C1:Lerp(CFrame.new(),1 - math.exp(-10 * DeltaTime))

				if C.Settings.General.LookAt.Value ~= Vector3.new() and not C.Humanoid.Sit and not C.Humanoid.PlatformStand and C.Settings.General.FacingTime.Value > 0 then
					HeadAngleX,_,_ = CFrame.new(C.Head.Position,C.Settings.General.LookAt.Value):ToEulerAnglesYXZ()
					C.Torso.Neck.C1 = C.Torso.Neck.C1:Lerp(CFrame.Angles(-HeadAngleX,0,0),1 - math.exp(-10 * DeltaTime))

					if C.Settings.General.Stance.Value ~= "Stand" then
						--C.PrimaryPart.CFrame = CFrame.new(C.PrimaryPart.Position)
						--	* CFrame.Angles(RootAngleY,LookAngleX,RootAngleZ)
						C.PrimaryPart.CFrame = C.PrimaryPart.CFrame:Lerp(CFrame.new(C.PrimaryPart.Position)
							* CFrame.Angles(RootAngleY,LookAngleX,RootAngleZ),1 - math.exp(-10 * DeltaTime))
					end
				end
			else
				if C.Name == "Death Scythe" then --C:GetAttribute('Special') then --
					local dist = (C.PrimaryPart.Position - C.PrimaryPart.AP.Position).Magnitude
					if dist < 10 then
						C.PrimaryPart.AP.MaxVelocity = 10
						C.PrimaryPart.AP.Position = C.PrimaryPart.AP.Position + C.PrimaryPart.CFrame.LookVector*15
					end
				end
			end
		end
	end
end

task.wait(2)

local serverRunner = function()
	while task.wait() do
		Render()
	end
end

local operatorRunner = function()

	while task.wait() do
		DeltaTime = tick() - CurrentTime
		CurrentTime = tick()
		
		Bots = 0
		--comment out one or the other between the next two lines
		for _,C in pairs(airzacs) do local C = C.airzac		--collection service method
		--for _,C in pairs(workspace:GetChildren()) do		--non collection service method
			--if Bots%0 == 0 then wait() end	--adding this improves fps but makes ai slower. Basically every i bots (bots%i) it will wait
			
			if not C:FindFirstChild("Head") then
				C:Destroy()
			end
			
			if not IsNPG(C) then continue end
				
				local faction = C.FactionType.Value
				if not C:FindFirstChild('Settings') then continue end
				if math.random(1,12000) == 1 and C.Settings.Combat.HoldFire.Value == false and Storage.Audio.Voicelines:FindFirstChild(faction) and not C:GetAttribute('Special') then
					local voiceline = Storage.Audio.Voicelines[faction]:GetChildren()[math.random(1,#Storage.Audio.Voicelines[faction]:GetChildren())]:Clone()
					voiceline.Parent = C.Head
					voiceline.PlayOnRemove = true
					voiceline:Destroy()
				end
				
				Bots += 1
				
				--if C.Settings.General.ActionTime.Value == 0 then C.Settings.Combat.Alerted.Value = false end
				if not C:FindFirstChild('Settings') then continue end
				if C.Settings.General.WalkTo.Value ~= Vector3.new() then
					--if (C:GetPivot().Position - C.Settings.General.WalkTo.Value).Magnitude < 5 then
					--	if not C.Settings.Combat.Alerted.Value then C.Settings.General.ActionTime.Value = 0 end
					--	C.Settings.General.WalkTo.Value = Vector3.new()
					local moveMagnitude = 10
					if C:FindFirstChild('Stage') and C.Stage.Value == "Tank" then moveMagnitude = 20 end
					if (not C.Settings.General.Walking.Value or (C.Humanoid.WalkToPoint - C.Settings.General.WalkTo.Value).Magnitude > moveMagnitude) and C:FindFirstChild('Humanoid') then
					--C.Humanoid:MoveTo(C.Settings.General.WalkTo.Value + Vector3.new(math.random(-100,100),math.random(-100,100),math.random(-100,100))/100)
						C.Humanoid:MoveTo(C.Settings.General.WalkTo.Value)
					end
				end
				
				if Storage.Command.EnableCombat.Value and C.GunStat:GetAttribute('GunName') ~= "Blank" then
					if not C:GetAttribute('Special') then
						LastTarget = C.Settings.Combat.Target.Value
						C.Settings.Combat.Target.Value = Spotted(C,C.Settings.Combat.Target.Value) and C.Settings.Combat.Target.Value or SpotChar(C) --SpotTarget(C)
						if C.Settings.Combat.Target.Value then
							if LastTarget ~= C.Settings.Combat.Target.Value then
								C.Settings.Combat.ReactionTime.Value = math.random(5,10)/20
								SetActionTime(C)
							end
							C.Settings.Combat.Alerted.Value = true
							C.Settings.Combat.LastContact.Value = C.Settings.Combat.Target.Value:GetPivot().Position
							FireAtTarget(C,true,C.Settings.Combat.Target.Value.PrimaryPart.Position)
							if C:FindFirstChild('Settings') then
								CreateAlert("Contact",C,C.Settings.Combat.Target.Value:GetPivot().Position,false)

								if C.Settings.General.Robot.Value and C.Settings.Combat.Target.Value.PrimaryPart then
									WalkTo(C,C.Settings.Combat.Target.Value.PrimaryPart.Position)
								end
							end
						
							
						elseif C.Settings.Combat.SuppressTime.Value > 0 then
							FireAtTarget(C,false,C.Settings.Combat.SuppressPos.Value)
						end
					else
						if C.Settings.Combat.SuppressPos.Value ~= zeroVec and not C:GetAttribute('Heal') then
							FireAtTarget(C,false,C.Settings.Combat.SuppressPos.Value,true)
							if C:GetAttribute('Target') then
								C.Settings.Combat.SuppressPos.Value = zeroVec
							end
						else
							if C:GetAttribute('Heal') and C.PrimaryPart and C.Settings.Combat.HoldFire.Value == false then
								if tick() > (C:GetAttribute('lastHealedTime') + C:GetAttribute('HealCooldown')) then
									C:SetAttribute('lastHealedTime',tick())
									makeExplosion(C.PrimaryPart.Position,C.GunStat.BaseDamage.Value,true,"Heal",C)
								end
							end
							C.Settings.Combat.Target.Value = Spotted(C,C.Settings.Combat.Target.Value) and C.Settings.Combat.Target.Value or SpotChar(C) --SpotTarget(C)
							if C.Settings.Combat.Target.Value then
								C:SetAttribute('Target',true)
								local pos = C.Settings.Combat.Target.Value.PrimaryPart.Position
								C.Settings.Combat.SuppressPos.Value = pos
								if C.Settings.General.Robot.Value == true then
									C.PrimaryPart.AP.Position = pos + Vector3.new(0,C:GetAttribute('AttackHeight'),0)
									C.PrimaryPart.AP.MaxVelocity = C:GetAttribute('AttackSpeed')
									local TheadCF = CFrame.new(C.PrimaryPart.Position, pos)
									local _,Yrot,_ = TheadCF:ToOrientation()
									local TheadCF = CFrame.Angles(0,Yrot,0)
									C.PrimaryPart.AO.CFrame = TheadCF
								end
								if C:GetAttribute('AlwaysFace') then
									C.PrimaryPart.AO.CFrame = CFrame.new(C.PrimaryPart.Position, pos)
								end
							else
								C:SetAttribute('Target',nil)
								--if C:GetAttribute('AlwaysFace') then
								--	local TheadCF = CFrame.new(C.PrimaryPart.Position, C.PrimaryPart.Position + C.PrimaryPart.CFrame.LookVector*15)
								--	local _,Yrot,_ = TheadCF:ToOrientation()
								--	local TheadCF = CFrame.Angles(0,Yrot,0)
									--	C.PrimaryPart.AO.CFrame = TheadCF
								--end
							end
						end
					end
				else
					C.Settings.Combat.Target.Value = nil
					C.Settings.Combat.SuppressTime.Value = 0
					C.Settings.Combat.LastContact.Value = Vector3.new()
				end
				if not C:FindFirstChild('Settings') then continue end
				if C.Settings.Group.Id.Value > 0 and not IsChar(C.Settings.Group.Leader.Value) then
					SetActionTime(C)
					C.Settings.Combat.Alerted.Value = true
					C.Settings.Group.Leader.Value = C
					C.Settings.Group.Num.Value = 0
					C.Settings.Group.ReassembleTime.Value = 5
					
					for _,Child in pairs(airzacs) do local Child = Child.airzac
					--for _,Child in pairs(workspace:GetChildren()) do
						if C.Settings.Group.Num.Value < 8 and C ~= Child and IsNPG(Child) and C.Settings.Group.Id.Value == Child.Settings.Group.Id.Value then
							C.Settings.Group.Num.Value += 1
							Child.Settings.Group.Num.Value = C.Settings.Group.Num.Value
							Child.Settings.Group.Leader.Value = C
							Child.Settings.General.ActionTime.Value = C.Settings.General.ActionTime.Value
						end
					end
					
					if C.Settings.Group.Num.Value == 0 then
						C.Settings.Group.Leader.Value = nil
						C.Settings.Group.Id.Value = 0
					end
				end
				if not C:FindFirstChild('Settings') then continue end
				if C:FindFirstChild('Humanoid') and C.Settings.General.LastHealth.Value > C.Humanoid.Health then
					CreateAlert("Injury",C,C:GetPivot().Position,false)
					C:SetAttribute('TimeNotHit',0)
					if C.Settings.Group.Leader.Value then
						SetActionTime(C.Settings.Group.Leader.Value)
						C.Settings.Group.Leader.Value.Settings.Combat.Alerted.Value = true
					else
						SetActionTime(C)
						C.Settings.Combat.Alerted.Value = true
					end
					
					--if math.random(1,40) == 1 then
					--	if C.Settings.General.Stance.Value == "Stand" then ChangeStance(C,"Kneel") else ChangeStance(C,"Prone") end
					--end
					
					--if not C.Settings.Combat.Target.Value then 
					--	LookAt(C,false,nil,5) 
					--end
					
					if math.random(1,2) == 1 and C.Settings.General.LastHealth.Value == 100 then
						InjuredScream = Storage.Audio.InjuredScreams:GetChildren()[math.random(1,#Storage.Audio.InjuredScreams:GetChildren())]:Clone()
						InjuredScream.Parent = C.Head
						InjuredScream:Destroy()
					end
					--if C.FactionType.Value == "Civilian" then
					--	warn("A civilian was injured")
					--end
				--elseif C.Humanoid.Health ~= C.Humanoid.MaxHealth and (C.Settings.Combat.Target.Value == nil or C.Settings.Combat.HoldFire.Value == true) then
				--	C:SetAttribute('TimeNotHit',C:GetAttribute('TimeNotHit')+1)
				--	if C:GetAttribute('TimeNotHit') >= 2000 then
				--		C.Humanoid.Health += 0.0001*C.Humanoid.MaxHealth
				--		if C.Humanoid.Health >= C.Humanoid.MaxHealth then
				--			C:SetAttribute('TimeNotHit',0)
				--		end
				--	end
				end
				
				--Move on damaged
				if not C:FindFirstChild('Settings') then continue end
				if not C.Settings.Combat.Alerted.Value and C.GunStat:GetAttribute('GunName') ~= "Blank" then
					for _,A in pairs(script.Parent.Alerts:GetChildren()) do
						if A.Uses.Value > 2 then A:Destroy()
						elseif math.random(1,2) == 1 and A.Team.Value == C.Settings.General.Team.Value
							and (A.Value - C:GetPivot().Position).Magnitude < C.GunStat:GetAttribute('SpottingDistance')
							and (GetRayPos(C.Head.Position,A.Value) - C.Head.Position).Magnitude > (A.Value - C.Head.Position).Magnitude * .75 then
							A.Uses.Value += 1
							C.Settings.Combat.Alerted.Value = true
							SetActionTime(C)

							--if C.Settings.General.Movement.Value == "Mobile" then
							--	C.Settings.General.WalkTo.Value = C:GetPivot().Position
							--end

							--if math.random(1,2) == 1 then
							--	LookAt(C,false,A.Value,5)
							--end

							if not IsPatroling(C)
								and C.Settings.General.Movement.Value == "Mobile" then
								C.Settings.General.WalkTo.Value = GetRayPos(C:GetPivot().Position,
									(C:GetPivot() * CFrame.Angles(0,math.rad(math.random(0,360)),0)).LookVector * math.random(5,15) * 3)
							end
						end
					end
				end
				
				if C == C.Settings.Group.Leader.Value then
					Leader(C)
				elseif C.Settings.Group.Id.Value > 0 then
					Member(C,C.Settings.Group.Leader.Value)
				else
					Single(C)
				end
				
				if C.Settings.Combat.ReloadTime.Value > 0 and C.Settings.Combat.ReloadTime.Value - DeltaTime < .25 then
					
					C.Settings.Combat.ReloadTime.Value = 0
					C.GunStat.LoadedAmmo.Value = C.GunStat.MaxAmmo.Value
				end
				
				if C.Settings.Combat.ReloadTime.Value == 0 and C.GunStat.LoadedAmmo.Value < C.GunStat.MaxAmmo.Value/2
					and (C.GunStat.LoadedAmmo.Value == 0 or C.Settings.Combat.SuppressTime.Value == 0 and not C.Settings.Combat.Alerted.Value) then
					C.Settings.Combat.ReloadTime.Value = C.Arms.GunModel.Handle.Reload.TimeLength
						--Config.ReloadTime.Value * math.random(5,15)/10
					

					--local ReloadSound = C.Arms.GunModel.Handle.Reload:Clone()
					--ReloadSound.PlayOnRemove = true
					--ReloadSound.RollOffMinDistance = 50
					--ReloadSound.Parent = C.Arms.GunModel.Handle
					--ReloadSound:Destroy()
					--game:GetService("Debris"):AddItem(ReloadSound,3)
					
					C.Arms.GunModel.Handle.Reload:Play()
					
				elseif C.Settings.Arms.Status.Value == "Port" and (C.Settings.Combat.Alerted.Value or C.Settings.Combat.SuppressTime.Value > 0) and C.Settings.Combat.HoldFire.Value == false then
					C.Settings.Arms.Status.Value = "Present"
				elseif C.Settings.Arms.Status.Value == "Present" and C.Settings.Combat.SuppressTime.Value == 0
					and C.Settings.General.ActionTime.Value == 0 and math.random(1,2) == 1 then
					if not C.GunStat:GetAttribute('DenyPort') then
						C.Settings.Arms.Status.Value = "Port"
					end
				end
				
				if C.Settings.General.Stance.Value ~= "Stand" and C.Settings.Arms.Status.Value == "Port" then C.Settings.Arms.Status.Value = "Present" end
				
				if C.Settings.General.ActionTime.Value == 0 then SetActionTime(C) end
				if C:FindFirstChild('Humanoid') then
					C.Humanoid.AutoRotate = not C.Settings.Combat.Target.Value and C.Settings.Combat.SuppressTime.Value == 0
					C.Settings.General.LastHealth.Value = C.Humanoid.Health
				end
				C.Settings.Combat.FireTime.Value = math.max(C.Settings.Combat.FireTime.Value - DeltaTime,0)
				C.Settings.Combat.AlertTime.Value = math.max(C.Settings.Combat.AlertTime.Value - DeltaTime,0)
				C.Settings.Combat.ReloadTime.Value = math.max(C.Settings.Combat.ReloadTime.Value - DeltaTime,0)
				
				C.Settings.Combat.ReactionTime.Value = math.max(C.Settings.Combat.ReactionTime.Value - DeltaTime,0)
				C.Settings.Combat.SuppressTime.Value = math.max(C.Settings.Combat.SuppressTime.Value - DeltaTime,0)
				C.Settings.General.StanceTime.Value = math.max(C.Settings.General.StanceTime.Value - DeltaTime,0)
				C.Settings.General.ActionTime.Value = math.max(C.Settings.General.ActionTime.Value - DeltaTime,0)
				C.Settings.General.FacingTime.Value = math.max(C.Settings.General.FacingTime.Value - DeltaTime,0)
				C.Settings.Group.ReassembleTime.Value = math.max(C.Settings.Group.ReassembleTime.Value - DeltaTime,0)
				
				SetWalkSpeed(C)
			--end
		end
		
		Storage.Command.Bots.Value = Bots
		--Storage.Command.Resources.Value += Storage.Command.ResourceRate.Value
	end
end



task.spawn(serverRunner)
task.spawn(operatorRunner)