-- @ScriptType: Script
print(">> INITIALIZING ETERNAL CONQUEST FRAMEWORK...")
print("-----------------------------------------")
print("CURRENT GAME VERSION: ", game.PlaceVersion)
print("-----------------------------------------")
print("COLLABORATION BY BOYOHOO, AIRZAC123 and HONOURVALOUR.")
print("LAST VERSION UPDATE: - 05/03/2025 -")
print("-----------------------------------------")
print("-----------------------------------------")

local HttpService 	= game:GetService("HttpService")
local PhysicsService= game:GetService("PhysicsService")
local TS 			= game:GetService('TweenService')
local Debris 		= game:GetService("Debris")
local PhysicsService= game:GetService("PhysicsService")
local Run 			= game:GetService("RunService")
local RS 			= game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local plr 			= game:GetService("Players")

local ACS_Workspace = workspace:WaitForChild("ACS_WorkSpace")
local Engine 		= RS:WaitForChild("ACS_Engine")
local BulletFX		= Engine:WaitForChild("BulletFX")
local Evt 			= Engine:WaitForChild("Events")
local Mods 			= Engine:WaitForChild("Modules")
local GunModels 	= Engine:WaitForChild("GunModels")
local SVGunModels 	= Engine:WaitForChild("GrenadeModels")
local HUDs 			= Engine:WaitForChild("HUD")
local AttModels 	= Engine:WaitForChild("AttModels")
local AttModules  	= Engine:WaitForChild("AttModules")
local Rules			= Engine:WaitForChild("GameRules")

local gameRules		= require(Rules:WaitForChild("Config"))
local CombatLog		= require(Rules:WaitForChild("CombatLog"))
local SpringMod 	= require(Mods:WaitForChild("Spring"))
local HitMod 		= require(Mods:WaitForChild("Hitmarker"))
local Ultil			= require(Mods:WaitForChild("Utilities"))
local Ragdoll		= require(Mods:WaitForChild("Ragdoll"))
local Fracture		= require(Mods:WaitForChild("PartFractureModule"))
local Shrapnel		= require(Mods:WaitForChild("DirCast"))

local ACS_0 		= HttpService:GenerateGUID(true)
local Backup 		= 0

local PhysService = game:GetService("PhysicsService")

local GroupID = 35138992

PhysService:RegisterCollisionGroup("Casings")
PhysService:RegisterCollisionGroup("Characters")
PhysService:RegisterCollisionGroup("Guns")

PhysService:CollisionGroupSetCollidable("Casings","Characters",false)
PhysService:CollisionGroupSetCollidable("Casings","Casings",false)
PhysService:CollisionGroupSetCollidable("Casings","Guns",false)
PhysService:CollisionGroupSetCollidable("Guns","Characters",false)
PhysService:CollisionGroupSetCollidable("Guns","Guns",gameRules.WeaponCollisions)

_G.TempBannedPlayers = {} --Local ban list

local Explosion = {"287390459"; "287390954"; "287391087"; "287391197"; "287391361"; "287391499"; "287391567";}

local luaw,llaw,lhw, ruaw,rlaw,RA,LA,RightS,LeftS
local AnimBase,AnimBaseW
local dParts = {} -- Glass/Light storage
dParts.Glass = {}
dParts.Lights = {}

local gBreakParam = OverlapParams.new()
-----------------------------------------------------------------

game.StarterPlayer.CharacterWalkSpeed = gameRules.NormalWalkSpeed

local function AccessID(SKP_0,SKP_1)
	if SKP_0.UserId ~= SKP_1 then
		SKP_0:kick("Exploit Protocol");
		warn(SKP_0.Name.." - Potential Exploiter! Case 0-A: Client Tried To Access Server Code");
		table.insert(_G.TempBannedPlayers, SKP_0);
	end;
	return ACS_0;
end;

Evt.AcessId.OnServerInvoke = AccessID

local ArmorTable = {
	{"HeadArmor",{"Head"}},
	{"TorsoArmor",{"UpperTorso","LowerTorso","Torso","HumanoidRootPart"}},
	{"LeftLegArmor",{"LeftUpperLeg","LeftLowerLeg","LeftFoot","Left Leg"}},
	{"LeftArmArmor",{"LeftUpperArm","LeftLowerArm","LeftHand","Left Arm"}},
	{"RightLegArmor",{"RightUpperLeg","RightLowerLeg","RightFoot","Right Leg"}},
	{"RightArmArmor",{"RightUpperArm","RightLowerArm","RightHand","Right Arm"}},
}

--Glenn's Anti-Exploit System (GAE for short). This code is very ugly, but does job done
local function compareTables(arr1, arr2)
	if	arr1.gunName==arr2.gunName 				and 
		arr1.Type==arr2.Type 					and
		arr1.ShootRate==arr2.ShootRate 			and
		arr1.Bullets==arr2.Bullets				and
		arr1.LimbDamage[1]==arr2.LimbDamage[1]	and
		arr1.LimbDamage[2]==arr2.LimbDamage[2]	and
		arr1.TorsoDamage[1]==arr2.TorsoDamage[1]and
		arr1.TorsoDamage[2]==arr2.TorsoDamage[2]and
		arr1.HeadDamage[1]==arr2.HeadDamage[1]	and
		arr1.HeadDamage[2]==arr2.HeadDamage[2]
	then return true; end;
	return false;
end;

local function secureSettings(Player,Gun,Module)
	local PreNewModule = Gun:FindFirstChild("ACS_Settings");
	if not Gun or not PreNewModule then
		Player:kick("Exploit Protocol");
		warn(Player.Name.." - Potential Exploiter! Case 2: Missing Gun And Module")	;
		return false;
	end;

	local NewModule = require(PreNewModule);
	if (compareTables(Module, NewModule) == false) then
		Player:kick("Exploit Protocol");
		warn(Player.Name.." - Potential Exploiter! Case 4: Exploiting Gun Stats")	;
		table.insert(_G.TempBannedPlayers, Player);
		return false;
	end;
	return true;
end;

function airzacDamage(VitimaHuman,Hit,Dano)
	--print("Deal damage",VitimaHuman,Hit)
	if VitimaHuman ~= nil and Hit then
		if VitimaHuman.Parent == nil then return end

		
		if VitimaHuman.Parent:FindFirstChild("Armor") and Hit then	
			local ArmorToBeAffected = nil
			local CharacterArmor = VitimaHuman.Parent:FindFirstChild("Armor") 
			if not CharacterArmor then
				CharacterArmor = VitimaHuman.Parent.Parent:FindFirstChild("Armor")
			end

			for _,Info in pairs(ArmorTable) do
				for _,Limb in pairs(Info[2]) do
					if Hit.Name == Limb or Hit.Parent.Name == Limb or (VitimaHuman.Parent:GetAttribute('Morph') and Hit.Parent.Name == VitimaHuman.Parent:GetAttribute('Morph').."_"..Limb) then
						ArmorToBeAffected = Info[1]
						break
					end
				end	
			end
			if VitimaHuman.Parent:GetAttribute('Morph') and Hit.Parent.Name == VitimaHuman.Parent:GetAttribute('Morph').." Helmet_Head" then
				ArmorToBeAffected = "HeadArmor"
			end
			if ArmorToBeAffected and CharacterArmor:FindFirstChild(ArmorToBeAffected) and CharacterArmor:FindFirstChild(ArmorToBeAffected).Value ~= 0 then
				CharacterArmor:FindFirstChild(ArmorToBeAffected).Value = CharacterArmor:FindFirstChild(ArmorToBeAffected).Value - Dano
			else
				--if ArmorToBeAffected then
				--	print(CharacterArmor:FindFirstChild(ArmorToBeAffected),CharacterArmor:FindFirstChild(ArmorToBeAffected).Value ~= 0)
				--else
				--	print(Hit.Parent.Name)
				--end
				print("Straight through",Hit.Parent.Name)
				
				if VitimaHuman:IsA('NumberValue') then
					--print("Deal vecDamage")
					VitimaHuman.Value -= Dano/3
				else
					VitimaHuman:TakeDamage(Dano)
				end
			end
			
			
		else
			if VitimaHuman:IsA('NumberValue') then
				VitimaHuman.Value -= Dano/3
			else
				VitimaHuman:TakeDamage(Dano)
			end
			--VitimaHuman.Health = VitimaHuman.Health - Dano
		end
		--else
		--	VitimaHuman:TakeDamage(Dano)
	end
end

function CalculateDMG(SKP_0, SKP_1, SKP_2, SKP_4, SKP_5, SKP_6, airzac)
	--print("Calculate damage",airzac,SKP_1)
	local skp_0 = plr:GetPlayerFromCharacter(SKP_1.Parent) or nil
	local skp_1 = 0
	local skp_2 = SKP_5.MinDamage * SKP_6.minDamageMod

	if SKP_4 == 1 then
		local skp_3 = math.random(SKP_5.HeadDamage[1], SKP_5.HeadDamage[2])
		skp_1 = math.max(skp_2, (skp_3 * SKP_6.DamageMod) - (SKP_2 / 25) * SKP_5.DamageFallOf)
	elseif SKP_4 == 2 then
		local skp_3 = math.random(SKP_5.TorsoDamage[1], SKP_5.TorsoDamage[2])
		skp_1 = math.max(skp_2, (skp_3 * SKP_6.DamageMod) - (SKP_2 / 25) * SKP_5.DamageFallOf)
	else
		local skp_3 = math.random(SKP_5.LimbDamage[1], SKP_5.LimbDamage[2])
		skp_1 = math.max(skp_2, (skp_3 * SKP_6.DamageMod) - (SKP_2 / 25) * SKP_5.DamageFallOf)
	end

	if SKP_1.Parent and SKP_1.Parent:FindFirstChild("ACS_Client") and not SKP_5.IgnoreProtection then
		local skp_4 = SKP_1.Parent.ACS_Client.Protecao.VestProtect
		local skp_5 = SKP_1.Parent.ACS_Client.Protecao.HelmetProtect

		if SKP_4 == 1 then
			if SKP_5.BulletPenetration < skp_5.Value then
				skp_1 = math.max(.5, skp_1 * (SKP_5.BulletPenetration / skp_5.Value))
			end
		else
			if SKP_5.BulletPenetration < skp_4.Value then
				skp_1 = math.max(.5, skp_1 * (SKP_5.BulletPenetration / skp_4.Value))
			end
		end
	end

	if skp_0 then
		if skp_0.Team ~= SKP_0.Team or skp_0.Neutral then
			local skp_t = Instance.new("ObjectValue")
			skp_t.Name = "creator"
			skp_t.Value = SKP_0
			skp_t.Parent = SKP_1
			game.Debris:AddItem(skp_t, 1)
			airzacDamage(SKP_1, airzac, skp_1)
			return
		end

		if not gameRules.TeamKill then return end
		local skp_t = Instance.new("ObjectValue")
		skp_t.Name = "creator"
		skp_t.Value = SKP_0
		skp_t.Parent = SKP_1
		game.Debris:AddItem(skp_t, 1)
		airzacDamage(SKP_1, airzac, skp_1 * gameRules.TeamDmgMult)
		return
	end

	if SKP_1.Parent and SKP_1.Parent.Name == "Arms" then
		SKP_1 = SKP_1.Parent.Parent.Humanoid
	end

	local skp_t = Instance.new("ObjectValue")
	skp_t.Name = "creator"
	skp_t.Value = SKP_0
	skp_t.Parent = SKP_1
	game.Debris:AddItem(skp_t, 1)
	airzacDamage(SKP_1, airzac, skp_1)
	return
end

local function Damage(SKP_0, SKP_1, SKP_2, SKP_3, SKP_4, SKP_5, SKP_6, SKP_7, SKP_8, SKP_9, airzac)
	--print("Damage function",SKP_1,SKP_2)
	if not SKP_0 or not SKP_0.Character then return; end;
	if not SKP_0.Character:FindFirstChild("Humanoid") or SKP_0.Character.Humanoid.Health <= 0 then return; end;
	if SKP_9 == (ACS_0.."-"..SKP_0.UserId) then
		if SKP_7 then
			SKP_0.Character.Humanoid:TakeDamage(math.max(SKP_8, 0))
			return;
		end

		if SKP_1 then
			local skp_0 = secureSettings(SKP_0,SKP_1, SKP_5)
			if not skp_0 or not SKP_2 then return; end;
			CalculateDMG(SKP_0, SKP_2, SKP_3, SKP_4, SKP_5, SKP_6,airzac)
			return;
		end

		SKP_0:kick("Exploit Protocol")
		warn(SKP_0.Name.." - Potential Exploiter! Case 1: Tried To Access Damage Event")
		table.insert(_G.TempBannedPlayers, SKP_0)
		return;
	end
	SKP_0:kick("Exploit Protocol")
	warn(SKP_0.Name.." - Potential Exploiter! Case 0-B: Wrong Permission Code")
	table.insert(_G.TempBannedPlayers, SKP_0)
	return;
end

function BreakGlass(HitPart,Position,cPos)
	local sounds = Engine.FX.GlassBreak:GetChildren()
	local sound = sounds[math.random(1,#sounds)]:Clone()
	sound.Name = "BreakSound"
	sound.Parent = HitPart

	local breakPoint = Instance.new("Attachment")
	breakPoint.Name = "BreakingPoint"
	breakPoint.Parent = HitPart
	breakPoint.WorldPosition = Position

	if cPos then breakPoint.Position = cPos end

	local config = Mods:WaitForChild("PartFractureModule").Configuration:Clone()
	config.Parent = HitPart
	config.DebrisDespawnDelay.Value = gameRules.ShardDespawn

	local hParent = HitPart.Parent
	local shards = Fracture.FracturePart(HitPart)
	table.insert(dParts.Glass,{HitPart:Clone(),hParent,shards})

	for _, shard in pairs(shards) do
		local forceAtt = Instance.new("Attachment",shard)
		forceAtt.WorldPosition = Position

		local pushForce = Instance.new("VectorForce")
		pushForce.Enabled = true
		pushForce.Force = Vector3.new(math.random(-50,50),math.random(-50,50),math.random(-50,50))
		pushForce.Attachment0 = forceAtt
		pushForce.Parent = forceAtt

		Debris:AddItem(forceAtt,0.1)
		Debris:AddItem(shard,gameRules.ShardDespawn)
	end
end

Evt.Damage.OnServerInvoke = Damage

Evt.Down.OnServerEvent:Connect(function(Player)
	if Player.Character then
		Player.Character:FindFirstChildOfClass('Humanoid').Health = 0
	end
end)

local cs = game:GetService('CollectionService')
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
	if airzac:FindFirstChild('Settings') or plr:GetPlayerFromCharacter(airzac) then
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

Evt.HitEffect.OnServerEvent:Connect(function(Player, Position, HitPart, Normal, Material, Settings)
	if Settings.BulletType ~= "Flame" then
		Evt.HitEffect:FireAllClients(Player, Position, HitPart, Normal, Material, Settings)
	end
	
	-- Explosion
	if Settings and Settings.ExplosiveHit then

		-- Damage calculation
		--for _, cPlr in pairs(plr:GetPlayers()) do
		--for _,c in pairs(airzacs) do local c = c.airzac
		--	if c and c.PrimaryPart then
		--		local dist                       = (c.PrimaryPart.Position - Position).Magnitude
		--		local MaxZone = Settings.ExplosionRadius
		--		local MinZone = MaxZone / 3
				
		--		local cPlr = game.Players:GetPlayerFromCharacter(c)

		--		if cPlr == Player or gameRules.TeamKill or cPlr.Team ~= Player.Team or cPlr.Neutral then
		--			if dist < Settings.ExplosionRadius / 3 then
		--				-- Too close!
		--				if c:FindFirstChild('Humanoid') then
		--					c.Humanoid:TakeDamage(0)
		--				elseif c:FindFirstChild('VecHealth') then
		--					c.VecHealth.Value -= 0
		--				end

		--				--local Pushback = Instance.new("VectorForce")
		--				--Pushback.Force = (c.HumanoidRootPart.Position - Position).Unit * 20000
		--				--Pushback.Parent = c.HumanoidRootPart
		--				--Pushback.Attachment0 = c.HumanoidRootPart.BodyFrontAttachment
		--				----Pushback.ApplyAtCenterOfMass = true
		--				--Debris:AddItem(Pushback,0.1)
		--			else
		--				local IgnoreList = {}
		--				for i,v in pairs(c:GetChildren()) do
		--					if v:IsA("Model") then
		--						table.insert(IgnoreList, v)
		--					end
		--				end
		--				local hit = workspace:Spherecast()
		--				 if hit then
		--					local dMult = ((Position - hit.Position).Magnitude + MinZone) / (MaxZone + MinZone)

		--					if c:FindFirstChild('Humanoid') then
		--						c.Humanoid:TakeDamage(Settings.ExplosionDamage - (Settings.ExplosionDamage * dMult))
		--					elseif c:FindFirstChild('VecHealth') then
		--						c.VecHealth.Value -= ((Settings.ExplosionDamage - (Settings.ExplosionDamage * dMult))*5)
		--					end
		--				end
		--			end
		--		end
		--	end
		--end
		
		local PlayersHit = {}
		
		local ExplosionCollisions = Instance.new("Part")
		ExplosionCollisions.Shape = Enum.PartType.Ball
		ExplosionCollisions.Name = "Explosion"
		ExplosionCollisions.Transparency = 1
		ExplosionCollisions.Position = Position
		ExplosionCollisions.CanCollide = false
		ExplosionCollisions.CanTouch = false
		ExplosionCollisions.Size = Vector3.new(Settings.ExplosionRadius, Settings.ExplosionRadius, Settings.ExplosionRadius)
		ExplosionCollisions.Parent = game.Workspace.ACS_WorkSpace.Server
		
		local Hits = game.Workspace:GetPartsInPart(ExplosionCollisions)
		
		for i,HitPart in Hits do
			if HitPart.Parent:FindFirstChild("Humanoid") and not table.find(PlayersHit, HitPart.Parent) then
				table.insert(PlayersHit, HitPart.Parent)
				local DamageMultiplier = ((Position - HitPart.Position).Magnitude + (Settings.ExplosionRadius / 3)) / (Settings.ExplosionRadius + (Settings.ExplosionRadius / 3))
				local RemainingDamage = Settings.ExplosionDamage - (Settings.ExplosionDamage * DamageMultiplier)
				
				if Settings.IgnoreProtection == false then
					if HitPart.Parent:FindFirstChild("Armor") then
						local ArmorCount =  #HitPart.Parent:FindFirstChild("Armor"):GetChildren()
						local ArmorIndividualDamage = math.clamp(RemainingDamage, 0, RemainingDamage / ArmorCount)
						for i,ArmorPart in pairs(HitPart.Parent:FindFirstChild("Armor"):GetChildren()) do
							if ArmorPart.Value > 0 then
								local ArmourActualDamage = math.clamp(ArmorPart.Value, 0, ArmorIndividualDamage)
								ArmorPart.Value -= ArmourActualDamage
								RemainingDamage -= math.clamp(RemainingDamage, 0, ArmourActualDamage)
							end
						end
					end
				end
				
				HitPart.Parent.Humanoid:TakeDamage(RemainingDamage)
			end
		end

		-- Explosion fx
		local expFX
		expFX = Engine.HITFX.Explosion[Settings.ExplosionEffect]
		if Engine.HITFX.Explosion:FindFirstChild(Settings.ExplosionEffect) then
			expFX = Engine.HITFX.Explosion[Settings.ExplosionEffect]
		else
			expFX = Engine.HITFX.Explosion.Default
		end

		local effectAtt = Instance.new("Attachment",workspace.Terrain)
		effectAtt.WorldCFrame = CFrame.new(Position)
		local echo = expFX.Echo:Clone()
		local exp = expFX.Explosion:Clone()
		echo.Parent = effectAtt
		exp.Parent = effectAtt
		echo:Play()
		exp:Play()

		--local exp2 = exp:Clone()
		--exp2.Parent = effectAtt
		--exp2.SoundId = Explosion[math.random(1,#Explosion)]
		--exp2:Play()

		for _, fx in pairs(expFX:GetChildren()) do
			if fx:IsA("ParticleEmitter") then
				local nEffect = fx:Clone()
				nEffect.Parent = effectAtt
				nEffect:Emit(nEffect.Count.Value)
			end
		end

		Debris:AddItem(effectAtt,120)

		-- Break nearby glass
		if gameRules.BreakGlass then
			local rParts = workspace:GetPartBoundsInRadius(Position,Settings.ExplosionRadius,gBreakParam)
			for i, cPart in pairs(rParts) do
				if i % 300 == 0 then wait() end
				if cPart.Name == gameRules.GlassName and cPart:IsA("Part") then
					local size = 0.8 * cPart.Size * (math.random(-10,10) / 10)
					BreakGlass(cPart,Position,Vector3.new(0.2,0.2,0.2))
					wait()
				end
			end
		end
	end
	
	if HitPart and HitPart.Name == "Capsule" and HitPart.Parent.Name == "AlarmLight" then
		local sounds = Engine.FX.GlassBreak:GetChildren()
		local sound = sounds[math.random(1,#sounds)]:Clone()
		sound.Name = "BreakSound"
		sound.Parent = HitPart
		
		local parent = HitPart.Parent:FindFirstChild('LightEmitter')
		parent.Transparency = 0.9
		parent:FindFirstChild('HingeConstraint').Enabled = false
		parent:FindFirstChild('SpotLight1').Enabled = false
		parent:FindFirstChild('SpotLight2').Enabled = false
		
		HitPart:ClearAllChildren()
		HitPart.Transparency = 0.75
		local decal = Instance.new("Decal",HitPart)
		decal.Face = Enum.NormalId.Right
		decal.Texture = "http://www.roblox.com/asset/?id=6552137211"
	end

	-- Glass breaking
	if gameRules.BreakGlass and HitPart and HitPart.Name == gameRules.GlassName and HitPart:IsA("Part") then
		BreakGlass(HitPart,Position)
	end

	-- Light breaking
	if gameRules.BreakLights and HitPart and HitPart.Name == "Light" and not HitPart:FindFirstChild("Broken") then
		table.insert(dParts.Lights,{HitPart,Material})

		local foundALight = false
		local tag = Instance.new("BoolValue",HitPart)
		tag.Name = "Broken"
		tag.Value = true

		local lights = {}

		for _, child in pairs(HitPart:GetChildren()) do
			if child:IsA("Light") then
				table.insert(lights,child)
				foundALight = true
			end
		end

		if foundALight then
			local newSound = Engine.FX.LightBreak:Clone()
			newSound.PlayOnRemove = true
			newSound.Parent = HitPart
			newSound:Destroy()

			local originalMat = HitPart.Material

			for i = 1, math.random(3,6) do
				HitPart.Material = Enum.Material.Metal
				for _, light in pairs(lights) do
					light.Enabled = false
				end

				wait(math.random(50,1000) / 10000)

				HitPart.Material = Enum.Material.Neon
				for _, light in pairs(lights) do
					light.Enabled = true
				end

				wait(math.random(50,1000) / 10000)
			end

			HitPart.Material = Enum.Material.Metal
			for _, light in pairs(lights) do
				light.Enabled = false
			end
		end
	end
end)

Evt.GunStance.OnServerEvent:Connect(function(Player,stance,Data)
	Evt.GunStance:FireAllClients(Player,stance,Data)
end)

Evt.ServerBullet.OnServerEvent:Connect(function(Player,Origin,Direction,WeaponData,ModTable)
	Evt.ServerBullet:FireAllClients(Player,Origin,Direction,WeaponData,ModTable)
end)

Evt.Stance.OnServerEvent:connect(function(Player, Stance, Virar)

	if Player.Character and Player.Character:FindFirstChild("Humanoid") ~= nil and Player.Character.Humanoid.Health > 0 then

		local char		= Player.Character
		local Human 	= char:WaitForChild("Humanoid")
		local ACS_Client= char:WaitForChild("ACS_Client")

		local LowerTorso= char:FindFirstChild("LowerTorso")
		local UpperTorso= char:FindFirstChild("UpperTorso")
		local RootJoint = char["LowerTorso"]:FindFirstChild("Root")
		local WaistJ 	= char["UpperTorso"]:FindFirstChild("Waist")
		local RS 		= char["RightUpperArm"]:FindFirstChild("RightShoulder")
		local LS 		= char["LeftUpperArm"]:FindFirstChild("LeftShoulder")
		local RH 		= char["RightUpperLeg"]:FindFirstChild("RightHip")
		local RK 		= char["RightLowerLeg"]:FindFirstChild("RightKnee")
		local LH 		= char["LeftUpperLeg"]:FindFirstChild("LeftHip")
		local LK 		= char["LeftLowerLeg"]:FindFirstChild("LeftKnee")

		local RightArm	= char["RightUpperArm"]
		local LeftArm 	= char["LeftUpperArm"]
		local LeftLeg 	= char["LeftUpperLeg"]
		local RightLeg 	= char["RightUpperLeg"]

		if Stance == 2 and RootJoint and WaistJ and RH and LH and RK and LK then
			--print("PRONE")
			TS:Create(RootJoint, TweenInfo.new(.3), {C0 = CFrame.new(0,-Human.HipHeight - LowerTorso.Size.Y+0.1,Human.HipHeight/1.05)* CFrame.Angles(math.rad(-90),0,math.rad(0))} ):Play()
			TS:Create(WaistJ, TweenInfo.new(.3), {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
			TS:Create(RH, TweenInfo.new(.3), {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LH, TweenInfo.new(.3), {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(RK, TweenInfo.new(.3), {C0 = CFrame.new(0, -RightLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LK, TweenInfo.new(.3), {C0 = CFrame.new(0, -LeftLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()

		end
		if Virar == 1 and RootJoint and WaistJ and RH and LH and RK and LK then
			if Stance == 0 then
				--print("RIGHT LEAN")
				TS:Create(WaistJ, TweenInfo.new(.3), {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0) * CFrame.Angles(math.rad(0),0,math.rad(-30))} ):Play()
				TS:Create(RootJoint, TweenInfo.new(.3), {C0 = CFrame.new(0,-(Human.HipHeight/1.8),0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
				TS:Create(RH, TweenInfo.new(.3), {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
				TS:Create(LH, TweenInfo.new(.3), {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
				TS:Create(RK, TweenInfo.new(.3), {C0 = CFrame.new(0, -RightLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
				TS:Create(LK, TweenInfo.new(.3), {C0 = CFrame.new(0, -LeftLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()

			elseif Stance == 1 then
				--print("RIGHT LEAN CROUCH")
				TS:Create(WaistJ, TweenInfo.new(.3), {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0)* CFrame.Angles(math.rad(0),0,math.rad(-30))} ):Play()
				TS:Create(RootJoint, TweenInfo.new(.3), {C0 = CFrame.new(0,-Human.HipHeight/1.05,0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
				TS:Create(RH, TweenInfo.new(.3), {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
				TS:Create(LH, TweenInfo.new(.3), {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(75),math.rad(0),math.rad(0))} ):Play()
				TS:Create(RK, TweenInfo.new(.3), {C0 = CFrame.new(0, -RightLeg.Size.Y/2,0)* CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))} ):Play()
				TS:Create(LK, TweenInfo.new(.3), {C0 = CFrame.new(0, -LeftLeg.Size.Y/3.5,0)* CFrame.Angles(math.rad(-60),math.rad(0),math.rad(0))} ):Play()

			end
		elseif Virar == -1 and RootJoint and WaistJ and RH and LH and RK and LK then
			if Stance == 0 then
				--print("LEFT LEAN")
				TS:Create(WaistJ, TweenInfo.new(.3), {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0) * CFrame.Angles(math.rad(0),0,math.rad(30))} ):Play()
				TS:Create(RootJoint, TweenInfo.new(.3), {C0 = CFrame.new(0,-(Human.HipHeight/1.8),0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
				TS:Create(RH, TweenInfo.new(.3), {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
				TS:Create(LH, TweenInfo.new(.3), {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
				TS:Create(RK, TweenInfo.new(.3), {C0 = CFrame.new(0, -RightLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
				TS:Create(LK, TweenInfo.new(.3), {C0 = CFrame.new(0, -LeftLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()

			elseif Stance == 1 then
				--print("LEFT LEAN CROUCH")
				TS:Create(WaistJ, TweenInfo.new(.3), {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0)* CFrame.Angles(math.rad(0),0,math.rad(30))} ):Play()
				TS:Create(RootJoint, TweenInfo.new(.3), {C0 = CFrame.new(0,-Human.HipHeight/1.05,0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
				TS:Create(RH, TweenInfo.new(.3), {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
				TS:Create(LH, TweenInfo.new(.3), {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(75),math.rad(0),math.rad(0))} ):Play()
				TS:Create(RK, TweenInfo.new(.3), {C0 = CFrame.new(0, -RightLeg.Size.Y/2,0)* CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))} ):Play()
				TS:Create(LK, TweenInfo.new(.3), {C0 = CFrame.new(0, -LeftLeg.Size.Y/3.5,0)* CFrame.Angles(math.rad(-60),math.rad(0),math.rad(0))} ):Play()

			end
		elseif Virar == 0 and RootJoint and WaistJ and RH and LH and RK and LK then
			if Stance == 0 then
				--print("STANDING")
				TS:Create(WaistJ, TweenInfo.new(.3), {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0)* CFrame.Angles(math.rad(-0),0,math.rad(0))} ):Play()
				TS:Create(RootJoint, TweenInfo.new(.3), {C0 = CFrame.new(0,-(Human.HipHeight/1.8),0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
				TS:Create(RH, TweenInfo.new(.3), {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
				TS:Create(LH, TweenInfo.new(.3), {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
				TS:Create(RK, TweenInfo.new(.3), {C0 = CFrame.new(0, -RightLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
				TS:Create(LK, TweenInfo.new(.3), {C0 = CFrame.new(0, -LeftLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()

			elseif Stance == 1 then
				--print("CROUCHING")
				TS:Create(WaistJ, TweenInfo.new(.3), {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
				TS:Create(RootJoint, TweenInfo.new(.3), {C0 = CFrame.new(0,-Human.HipHeight/1.05,0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
				TS:Create(RH, TweenInfo.new(.3), {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
				TS:Create(LH, TweenInfo.new(.3), {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(75),math.rad(0),math.rad(0))} ):Play()
				TS:Create(RK, TweenInfo.new(.3), {C0 = CFrame.new(0, -RightLeg.Size.Y/2,0)* CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))} ):Play()
				TS:Create(LK, TweenInfo.new(.3), {C0 = CFrame.new(0, -LeftLeg.Size.Y/3.5,0)* CFrame.Angles(math.rad(-60),math.rad(0),math.rad(0))} ):Play()

			end
		end

		--if ACS_Client:GetAttribute("Surrender") then
		--	TS:Create(RS, TweenInfo.new(.3), {C0 = CFrame.new(RightArm.Size.X/1.15, UpperTorso.Size.Y/2.8,0)* CFrame.Angles(math.rad(179),math.rad(0),math.rad(0))} ):Play()
		--	TS:Create(LS, TweenInfo.new(.3), {C0 = CFrame.new(-LeftArm.Size.X/1.15, UpperTorso.Size.Y/2.8,0)* CFrame.Angles(math.rad(179),math.rad(0),math.rad(0))} ):Play()
		--elseif Stance == 2 then
		--	TS:Create(RS, TweenInfo.new(.3), {C0 = CFrame.new(RightArm.Size.X/1.15, UpperTorso.Size.Y/2.8,0)* CFrame.Angles(math.rad(170),math.rad(0),math.rad(0))} ):Play()
		--	TS:Create(LS, TweenInfo.new(.3), {C0 = CFrame.new(-LeftArm.Size.X/1.15, UpperTorso.Size.Y/2.8,0)* CFrame.Angles(math.rad(170),math.rad(0),math.rad(0))} ):Play()
		--else
		--	TS:Create(RS, TweenInfo.new(.3), {C0 = CFrame.new(RightArm.Size.X/1.15, UpperTorso.Size.Y/2.8,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
		--	TS:Create(LS, TweenInfo.new(.3), {C0 = CFrame.new(-LeftArm.Size.X/1.15, UpperTorso.Size.Y/2.8,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
		--end
	end
end)

Evt.Surrender.OnServerEvent:Connect(function(Player,Victim)
	if not Player or not Player.Character then return; end;

	local PClient 	= nil
	if Victim then
		if Victim == Player or not Victim.Character then return; end;

		PClient = Victim.Character:FindFirstChild("ACS_Client")
		if not PClient then return; end;

		if PClient:GetAttribute("Surrender") then
			PClient:SetAttribute("Surrender",false)
		end
	end

	PClient = Player.Character:FindFirstChild("ACS_Client")

	if not PClient then return; end;

	if not PClient:GetAttribute("Surrender") and not Victim then
		PClient:SetAttribute("Surrender",true)
	end
end)

Evt.Grenade.OnServerEvent:Connect(function(SKP_0, SKP_1, SKP_2, SKP_3, SKP_4, SKP_5, SKP_6)
	if not SKP_0 or not SKP_0.Character then return; end;
	if not SKP_0.Character:FindFirstChild("Humanoid") or SKP_0.Character.Humanoid.Health <= 0 then return; end;

	if SKP_6 ~= (ACS_0.."-"..SKP_0.UserId) then
		SKP_0:kick("Exploit Protocol")
		warn(SKP_0.Name.." - Potential Exploiter! Case 0-B: Wrong Permission Code")
		table.insert(_G.TempBannedPlayers, SKP_0)
		return;
	end

	if not SKP_1 or not SKP_2 then
		SKP_0:kick("Exploit Protocol")
		warn(SKP_0.Name.." - Potential Exploiter! Case 3: Tried To Access Grenade Event")
		return;
	end

	local skp_0 = secureSettings(SKP_0, SKP_1, SKP_2)
	if not skp_0 or SKP_2.Type ~= "Grenade" then return; end;

	if not SVGunModels:FindFirstChild(SKP_2.gunName) then warn("ACS_Server Couldn't Find "..SKP_2.gunName.." In Grenade Model Folder"); return; end;

	local skp_0 = SVGunModels[SKP_2.gunName]:Clone()

	for SKP_Arg0, SKP_Arg1 in pairs(SKP_0.Character:GetChildren()) do
		if not SKP_Arg1:IsA('BasePart') then continue; end;
		local skp_1 = Instance.new("NoCollisionConstraint")
		skp_1.Parent= skp_0
		skp_1.Part0 = skp_0.PrimaryPart
		skp_1.Part1 = SKP_Arg1
	end

	local skp_1	= Instance.new("ObjectValue")
	skp_1.Name	= "creator"
	skp_1.Value	= SKP_0
	skp_1.Parent= skp_0.PrimaryPart

	skp_0.Parent 	= ACS_Workspace.Server
	skp_0.PrimaryPart.CFrame = SKP_3
	skp_0.PrimaryPart:ApplyImpulse(SKP_4 * SKP_5 * skp_0.PrimaryPart:GetMass())
	skp_0.PrimaryPart:SetNetworkOwner(nil)
	if skp_0.PrimaryPart:FindFirstChild('Damage') then
		skp_0.PrimaryPart.Damage.Disabled = false
		local left = SKP_1:GetAttribute('Uses')
		SKP_1:SetAttribute('Uses',left - 1)
		SKP_1.ToolTip = tostring(left - 1)
		SKP_0.Character:FindFirstChild("Humanoid"):UnequipTools()
		if left <= 1 then
			SKP_1:Destroy()
		end
	elseif skp_0.Name == "Ammo Box" then
		local left = SKP_1:GetAttribute('Uses')
		SKP_1:SetAttribute('Uses',left - 0)
		SKP_1.ToolTip = tostring(left - 0)
		SKP_0.Character:FindFirstChild("Humanoid"):UnequipTools()
		if left <= 1 then
			SKP_1:Destroy()
		end
	end
end)

function loadAttachment(weapon,WeaponData)
	if not weapon or not WeaponData or not weapon:FindFirstChild("Nodes") then return; end;
	--load sight Att
	if weapon.Nodes:FindFirstChild("Sight") and WeaponData.SightAtt ~= "" then

		local SightAtt = AttModels[WeaponData.SightAtt]:Clone()
		SightAtt.Parent = weapon
		SightAtt:SetPrimaryPartCFrame(weapon.Nodes.Sight.CFrame)

		for index, key in pairs(weapon:GetChildren()) do
			if not key:IsA('BasePart') or key.Name ~= "IS" then continue; end;
			key.Transparency = 1
		end

		for index, key in pairs(SightAtt:GetChildren()) do
			if key.Name == "SightMark" or key.Name == "Main" then key:Destroy(); continue; end;
			if not key:IsA('BasePart') then continue; end;
			Ultil.Weld(weapon:WaitForChild("Handle"), key )
			key.Anchored = false
			key.CanCollide = false
		end

	end

	--load Barrel Att
	if weapon.Nodes:FindFirstChild("Barrel") and WeaponData.BarrelAtt ~= "" then

		local BarrelAtt = AttModels[WeaponData.BarrelAtt]:Clone()
		BarrelAtt.Parent = weapon
		BarrelAtt:SetPrimaryPartCFrame(weapon.Nodes.Barrel.CFrame)

		if BarrelAtt:FindFirstChild("BarrelPos") then
			weapon.Handle.Muzzle.WorldCFrame = BarrelAtt.BarrelPos.CFrame
		end

		for index, key in pairs(BarrelAtt:GetChildren()) do
			if not key:IsA('BasePart') then continue; end;
			Ultil.Weld(weapon:WaitForChild("Handle"), key )
			key.Anchored = false
			key.CanCollide = false
		end
	end

	--load Under Barrel Att
	if weapon.Nodes:FindFirstChild("UnderBarrel") and WeaponData.UnderBarrelAtt ~= "" then

		local UnderBarrelAtt = AttModels[WeaponData.UnderBarrelAtt]:Clone()
		UnderBarrelAtt.Parent = weapon
		UnderBarrelAtt:SetPrimaryPartCFrame(weapon.Nodes.UnderBarrel.CFrame)


		for index, key in pairs(UnderBarrelAtt:GetChildren()) do
			if not key:IsA('BasePart') then continue; end;
			Ultil.Weld(weapon:WaitForChild("Handle"), key )
			key.Anchored = false
			key.CanCollide = false
		end
	end

	if weapon.Nodes:FindFirstChild("Other") and WeaponData.OtherAtt ~= "" then

		local OtherAtt = AttModels[WeaponData.OtherAtt]:Clone()
		OtherAtt.Parent = weapon
		OtherAtt:SetPrimaryPartCFrame(weapon.Nodes.Other.CFrame)

		for index, key in pairs(OtherAtt:GetChildren()) do
			if not key:IsA('BasePart') then continue; end;
			Ultil.Weld(weapon:WaitForChild("Handle"), key )
			key.Anchored = false
			key.CanCollide = false

		end
	end
end

function SetupRepAmmo(Tool,Settings)
	if not Settings then Settings = require(Tool.ACS_Settings) end
	if not Tool:FindFirstChild("RepValues") then
		local repValues = Instance.new("Folder",Tool)
		repValues.Name = "RepValues"

		local mag = Instance.new("IntValue",repValues)
		mag.Name = "Mag"
		mag.Value = Settings.AmmoInGun

		local storedAmmo = Instance.new("IntValue",repValues)
		storedAmmo.Name = "StoredAmmo"
		storedAmmo.Value = Settings.StoredAmmo
		

		local chambered = Instance.new("BoolValue",repValues)
		chambered.Name = "Chambered"
		chambered.Value = true
	end
end

Evt.Equip.OnServerEvent:Connect(function(Player,Arma,Mode,Settings,Anim)
	if not Player or not Player.Character then return; end;

	for i,v in pairs(Player.Character:FindFirstChild("Humanoid"):GetChildren()) do if v:IsA("IKControl") then v:Destroy() end end

	--// Replicate Ammo
	local Tool = Player.Character:FindFirstChildOfClass("Tool")
	if Tool and not Tool:FindFirstChild("RepValues") and Settings then
		local repValues =	Instance.new('Folder')
		repValues.Parent = Tool
		repValues.Name = "RepValues"
		local mag = Instance.new("IntValue",repValues)
		mag.Name = "Mag"
		mag.Value = Settings.AmmoInGun
		local storedAmmo = Instance.new("IntValue",repValues)
		storedAmmo.Name = "StoredAmmo"
		storedAmmo.Value = Settings.StoredAmmo
		local chambered = Instance.new("BoolValue",repValues)
		chambered.Name = "Chambered"
		chambered.Value = true
	end
	local Head 		= Player.Character:FindFirstChild('Head')
	local Torso 	= Player.Character:FindFirstChild('UpperTorso')
	local LeftArm 	= Player.Character:FindFirstChild('LeftUpperArm')
	local RightArm 	= Player.Character:FindFirstChild('RightUpperArm')

	if not Head or not Torso or not LeftArm or not RightArm then return; end;
	local RS 		= Torso:FindFirstChild("RightShoulder")
	local LS 		= Torso:FindFirstChild("LeftShoulder")
	if not RS or not LS then return; end;

	--// Replicate Ammo
	if Arma and Settings and Settings.Type == "Gun" then SetupRepAmmo(Arma,Settings) end

	--// EQUIP
	if Mode == 1 then
		local GunModel = GunModels:FindFirstChild(Arma.Name)
		if not GunModel then warn(Player.Name..": Couldn't load Server-side weapon model") return; end;

		local ServerGun = GunModel:Clone()
		ServerGun.Name = 'S' .. Arma.Name

		for _, part in pairs(ServerGun:GetChildren()) do
			if part.Name == "Warhead" and Settings.IsLauncher and Arma:FindFirstChild("RepValues") and Arma.RepValues.Mag.Value < 1 then
				part.Transparency = 1
			end
		end

		local AnimBase = Instance.new("Part", Player.Character)
		AnimBase.FormFactor = "Custom"
		AnimBase.CanCollide = false
		AnimBase.Transparency = 1
		AnimBase.Anchored = false
		AnimBase.Name = "AnimBase"
		AnimBase.Size = Vector3.new(0.1, 0.1, 0.1)

		local AnimBaseW = Instance.new("Motor6D")
		AnimBaseW.Part0 = Head
		AnimBaseW.Part1 = AnimBase
		AnimBaseW.Parent = AnimBase
		AnimBaseW.Name = "AnimBaseW"
		--AnimBaseW.C0 = CFrame.new(0,-1.25,0)

		RA = Player.Character['RightUpperArm']
		LA = Player.Character['LeftUpperArm']
		RightS = RA:WaitForChild("RightShoulder")
		LeftS = LA:WaitForChild("LeftShoulder")

		ruaw = Instance.new("Motor6D")
		ruaw.Name = "RAW"
		ruaw.Part0 = RA
		ruaw.Part1 = AnimBase
		ruaw.Parent = AnimBase
		ruaw.C0 = Anim.SV_RightArmPos
		RightS.Enabled = false

		rlaw = Instance.new("Motor6D")
		rlaw.Name = "RLAW"
		rlaw.Part0 = Player.Character.RightLowerArm
		rlaw.Part1 = RA
		rlaw.Parent = AnimBase
		rlaw.C0 = CFrame.new(0,RA.Size.Y/2,0) * Anim.SV_RightElbowPos


		ruaw = Instance.new("Motor6D")
		ruaw.Name = "RHW"
		ruaw.Part0 = Player.Character.RightHand
		ruaw.Part1 = Player.Character.RightLowerArm
		ruaw.Parent = AnimBase
		ruaw.C0 = CFrame.new(0,Player.Character.RightLowerArm.Size.Y/2,0) * Anim.SV_RightWristPos

		luaw = Instance.new("Motor6D")
		luaw.Name = "LAW"
		luaw.Part0 = LA
		luaw.Part1 = AnimBase
		luaw.Parent = AnimBase
		luaw.C0 = Anim.SV_LeftArmPos
		LeftS.Enabled = false

		llaw = Instance.new("Motor6D")
		llaw.Name = "LLAW"
		llaw.Part0 = Player.Character.LeftLowerArm
		llaw.Part1 = LA
		llaw.Parent = AnimBase
		llaw.C0 = CFrame.new(0,LA.Size.Y/2,0) * Anim.SV_LeftElbowPos

		lhw = Instance.new("Motor6D")
		lhw.Name = "LHW"
		lhw.Part0 = Player.Character.LeftHand
		lhw.Part1 = Player.Character.LeftLowerArm
		lhw.Parent = AnimBase
		lhw.C0 = CFrame.new(0,Player.Character.LeftLowerArm.Size.Y/2,0) * Anim.SV_LeftWristPos

		ServerGun.Parent = Player.Character

		loadAttachment(ServerGun,Settings)

		if ServerGun:FindFirstChild("Nodes") ~= nil then
			ServerGun.Nodes:Destroy()
		end

		for SKP_001, SKP_002 in pairs(ServerGun:GetDescendants()) do
			if SKP_002.Name ~= "SightMark" or SKP_002.Name ~= "AmmoBg" then continue; end;
			SKP_002:Destroy()
		end

		for SKP_001, SKP_002 in pairs(ServerGun:GetDescendants()) do
			if not SKP_002:IsA('BasePart') or SKP_002.Name == 'Handle' then continue; end;
			Ultil.WeldComplex(ServerGun:WaitForChild("Handle"), SKP_002, SKP_002.Name)
		end

		local SKP_004 = Instance.new('Motor6D')
		SKP_004.Name = 'Handle'
		SKP_004.Parent = ServerGun.Handle
		SKP_004.Part0 = Player.Character['RightHand']
		SKP_004.Part1 = ServerGun.Handle
		SKP_004.C1 = Anim.SV_GunPos:inverse()

		for L_74_forvar1, L_75_forvar2 in pairs(ServerGun:GetDescendants()) do
			if not L_75_forvar2:IsA('BasePart') then continue; end;
			L_75_forvar2.Anchored = false
			L_75_forvar2.CanCollide = false
		end
		return;
	end;
	--// UNEQUIP
	if Mode == 2 then
		if Arma and Player.Character:FindFirstChild('S' .. Arma.Name) then
			Player.Character['S' .. Arma.Name]:Destroy()
			Player.Character.AnimBase:Destroy()
		end


		RS.Enabled = true
		LS.Enabled = true
	end
	return;
end)

Evt.Equip.OnServerEvent:Connect(function(Player,Arma,Mode,Settings,Anim)
	if Player.Character then
		if Mode == 1 then
			local Head = Player.Character:FindFirstChild('Head')
			local ServerGun = GunModels:FindFirstChild(Arma.Name):clone()
			ServerGun.Name = 'S' .. Arma.Name

			AnimBase = Instance.new("Part", Player.Character)
			AnimBase.FormFactor = "Custom"
			AnimBase.CanCollide = false
			AnimBase.Transparency = 1
			AnimBase.Anchored = false
			AnimBase.Name = "AnimBase"
			AnimBase.Size = Vector3.new(0.1, 0.1, 0.1)

			AnimBaseW = Instance.new("Motor6D")
			AnimBaseW.Part0 = Head
			AnimBaseW.Part1 = AnimBase
			AnimBaseW.Parent = AnimBase
			AnimBaseW.Name = "AnimBaseW"
			--AnimBaseW.C0 = CFrame.new(0,-1.25,0)

			RA = Player.Character['RightUpperArm']
			LA = Player.Character['LeftUpperArm']
			RightS = RA:WaitForChild("RightShoulder",10)
			LeftS = LA:WaitForChild("LeftShoulder",10)

			ruaw = Instance.new("Motor6D")
			ruaw.Name = "RAW"
			ruaw.Part0 = RA
			ruaw.Part1 = AnimBase
			ruaw.Parent = AnimBase
			ruaw.C0 = Anim.SV_RightArmPos
			RightS.Enabled = false

			rlaw = Instance.new("Motor6D")
			rlaw.Name = "RLAW"
			rlaw.Part0 = Player.Character.RightLowerArm
			rlaw.Part1 = RA
			rlaw.Parent = AnimBase
			rlaw.C0 = CFrame.new(0,RA.Size.Y/2,0) * Anim.SV_RightElbowPos


			ruaw = Instance.new("Motor6D")
			ruaw.Name = "RHW"
			ruaw.Part0 = Player.Character.RightHand
			ruaw.Part1 = Player.Character.RightLowerArm
			ruaw.Parent = AnimBase
			ruaw.C0 = CFrame.new(0,Player.Character.RightLowerArm.Size.Y/2,0) * Anim.SV_RightWristPos

			luaw = Instance.new("Motor6D")
			luaw.Name = "LAW"
			luaw.Part0 = LA
			luaw.Part1 = AnimBase
			luaw.Parent = AnimBase
			luaw.C0 = Anim.SV_LeftArmPos
			LeftS.Enabled = false

			llaw = Instance.new("Motor6D")
			llaw.Name = "LLAW"
			llaw.Part0 = Player.Character.LeftLowerArm
			llaw.Part1 = LA
			llaw.Parent = AnimBase
			llaw.C0 = CFrame.new(0,LA.Size.Y/2,0) * Anim.SV_LeftElbowPos

			lhw = Instance.new("Motor6D")
			lhw.Name = "LHW"
			lhw.Part0 = Player.Character.LeftHand
			lhw.Part1 = Player.Character.LeftLowerArm
			lhw.Parent = AnimBase
			lhw.C0 = CFrame.new(0,Player.Character.LeftLowerArm.Size.Y/2,0) * Anim.SV_LeftWristPos

			ServerGun.Parent = Player.Character

			loadAttachment(ServerGun,Settings)

			if ServerGun:FindFirstChild("Nodes") ~= nil then
				ServerGun.Nodes:Destroy()
			end

			for SKP_001, SKP_002 in pairs(ServerGun:GetDescendants()) do
				if SKP_002.Name == "SightMark" or SKP_002.Name == "AmmoBg" then
					SKP_002:Destroy()
				end
			end

			for SKP_001, SKP_002 in pairs(ServerGun:GetDescendants()) do
				if SKP_002:IsA('BasePart') and SKP_002.Name ~= 'Handle' then
					Ultil.WeldComplex(ServerGun:WaitForChild("Handle"), SKP_002, SKP_002.Name)
				end;
			end

			local SKP_004 = Instance.new('Motor6D')
			SKP_004.Name = 'Handle'
			SKP_004.Parent = ServerGun.Handle
			SKP_004.Part0 = Player.Character['RightHand']
			SKP_004.Part1 = ServerGun.Handle
			SKP_004.C1 = Anim.SV_GunPos:inverse()

			for L_74_forvar1, L_75_forvar2 in pairs(ServerGun:GetDescendants()) do
				if L_75_forvar2:IsA('BasePart') then
					L_75_forvar2.Anchored = false
					L_75_forvar2.CanCollide = false
				end
			end

		elseif Mode == 2 then
			if Arma and Player.Character:FindFirstChild('S' .. Arma.Name) ~= nil then
				Player.Character['S' .. Arma.Name]:Destroy()
				Player.Character.AnimBase:Destroy()
			end

			if Player.Character:FindFirstChild("RightUpperArm") and Player.Character.RightUpperArm:FindFirstChild("RightShoulder") then
				Player.Character.RightUpperArm:WaitForChild("RightShoulder").Enabled = true
			end

			if Player.Character:FindFirstChild("LeftUpperArm") and Player.Character.LeftUpperArm:FindFirstChild("LeftShoulder") then
				Player.Character.LeftUpperArm:WaitForChild("LeftShoulder").Enabled = true
			end
		end
	end
end)

Evt.Squad.OnServerEvent:Connect(function(Player,SquadName,SquadColor)
	if not Player or not Player.Character then return; end;
	if not Player.Character:FindFirstChild("ACS_Client") then return; end;

	Player.Character.ACS_Client.FireTeam.SquadName.Value = SquadName
	Player.Character.ACS_Client.FireTeam.SquadColor.Value = SquadColor
end)

Evt.HeadRot.OnServerEvent:connect(function(Player, CF)
	Evt.HeadRot:FireAllClients(Player, CF)
end)

Evt.Atirar.OnServerEvent:Connect(function(Player, Arma, Suppressor, FlashHider)
	Evt.Atirar:FireAllClients(Player, Arma, Suppressor, FlashHider)
end)

Evt.Whizz.OnServerEvent:Connect(function(Player, Victim)
	Evt.Whizz:FireAllClients(Victim)
end)

Evt.Suppression.OnServerEvent:Connect(function(Player,Victim,Mode,Intensity,Time)
	Evt.Suppression:FireClient(Victim,Mode,Intensity,Time)
end)

Evt.Refil.OnServerEvent:Connect(function(Player, Tool, Infinite, ContainerStored, MaxStoredAmmo, CurrentStored)

	local Settings = require(Tool.ACS_Settings)

	if Settings.Type ~= "Melee" and Tool:FindFirstChild('RepValues') then
		if not Tool:FindFirstChild("RepValues") and Settings.Type == "Gun" then
			SetupRepAmmo(Tool,Settings)
		end

		local RepValues = Tool.RepValues

		if not Infinite then
			local AmountLeft = CurrentStored or RepValues.StoredAmmo.Value
			ContainerStored.Value = ContainerStored.Value - (MaxStoredAmmo - AmountLeft)
		end

		RepValues.StoredAmmo.Value = MaxStoredAmmo
		
		Evt.AmmoRefilled:FireClient(Player)
	end

end)

Evt.SVLaser.OnServerEvent:Connect(function(Player,Position,Modo,Cor,IRmode,Arma)
	Evt.SVLaser:FireAllClients(Player,Position,Modo,Cor,IRmode,Arma)
end)

Evt.SVFlash.OnServerEvent:Connect(function(Player,Arma,Mode)
	Evt.SVFlash:FireAllClients(Player,Arma,Mode)
end)

----------------------------------------------------------------
--\\DOORS & BREACHING SYSTEM
----------------------------------------------------------------

local DoorsFolder 		= ACS_Workspace:FindFirstChild("Doors")
local DoorsFolderClone 	= DoorsFolder:Clone()
local BreachClone 		= ACS_Workspace.Breach:Clone()
BreachClone.Parent 		= ServerStorage
DoorsFolderClone.Parent = ServerStorage

function ToggleDoor(Door)
	local Hinge = Door.Door:FindFirstChild("Hinge")
	if not Hinge then return end
	local HingeConstraint = Hinge.HingeConstraint

	if HingeConstraint.TargetAngle == 0 then
		HingeConstraint.TargetAngle = -90
	elseif HingeConstraint.TargetAngle == -90 then
		HingeConstraint.TargetAngle = 0
	end	
end

Evt.DoorEvent.OnServerEvent:Connect(function(Player,Door,Mode,Key)
	if Door ~= nil then
		if Mode == 1 then
			if Door:FindFirstChild("Locked") ~= nil and Door.Locked.Value == true then
				if Door:FindFirstChild("RequiresKey") then
					local Character = Player.Character
					if Character:FindFirstChild(Key) ~= nil or Player.Backpack:FindFirstChild(Key) ~= nil then
						if Door.Locked.Value == true then
							Door.Locked.Value = false
						end
						ToggleDoor(Door)
					end	
				end
			else
				ToggleDoor(Door)
			end
		elseif Mode == 2 then
			if Door:FindFirstChild("Locked") == nil or (Door:FindFirstChild("Locked") ~= nil and Door.Locked.Value == false) then
				ToggleDoor(Door)
			end
		elseif Mode == 3 then
			if Door:FindFirstChild("RequiresKey") then
				local Character = Player.Character
				Key = Door.RequiresKey.Value
				if Character:FindFirstChild(Key) ~= nil or Player.Backpack:FindFirstChild(Key) ~= nil then
					if Door:FindFirstChild("Locked") ~= nil and Door.Locked.Value == true then
						Door.Locked.Value = false
					else
						Door.Locked.Value = true
					end
				end
			end
		elseif Mode == 4 then
			if Door:FindFirstChild("Locked") ~= nil and Door.Locked.Value == true then
				Door.Locked.Value = false
			end
		end
	end
end)

function BreachFunction(Player,Mode,BreachPlace,Pos,Norm,Hit)

	if Mode == 1 then
		if Player.Character.ACS_Client.Kit.BreachCharges.Value > 0 then
			Player.Character.ACS_Client.Kit.BreachCharges.Value = Player.Character.ACS_Client.Kit.BreachCharges.Value - 1
			BreachPlace.Destroyed.Value = true
			local C4 = Engine.FX.BreachCharge:Clone()

			C4.Parent = BreachPlace.Destroyable
			C4.Center.CFrame = CFrame.new(Pos, Pos + Norm) * CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))
			C4.Center.Place:play()

			local weld = Instance.new("WeldConstraint")
			weld.Parent = C4
			weld.Part0 = BreachPlace.Destroyable.Charge
			weld.Part1 = C4.Center

			wait(1)
			C4.Center.Beep:play()
			wait(4)
			if C4 and C4:FindFirstChild("Center") then
				local att = Instance.new("Attachment")
				att.CFrame = C4.Center.CFrame
				att.Parent = workspace.Terrain

				local aw = Engine.FX.ExpEffect:Clone()
				aw.Parent = att
				aw.Enabled = false
				aw:Emit(35)
				Debris:AddItem(aw,aw.Lifetime.Max)

				local Exp = Instance.new("Explosion")
				Exp.BlastPressure = 0
				Exp.BlastRadius = 0
				Exp.DestroyJointRadiusPercent = 0
				Exp.Position = C4.Center.Position
				Exp.Parent = workspace

				local S = Instance.new("Sound")
				S.EmitterSize = 10
				S.MaxDistance = 1000
				S.SoundId = "rbxassetid://"..Explosion[math.random(1, 7)]
				S.PlaybackSpeed = math.random(30,55)/40
				S.Volume = 2
				S.Parent = att
				S.PlayOnRemove = true
				S:Destroy()

				for SKP_001, SKP_002 in pairs(game.Players:GetChildren()) do
					if SKP_002:IsA('Player') and SKP_002.Character and SKP_002.Character:FindFirstChild('Head') and (SKP_002.Character.Head.Position - C4.Center.Position).magnitude <= 15 then
						local DistanceMultiplier = (((SKP_002.Character.Head.Position - C4.Center.Position).magnitude/35) - 1) * -1
						local intensidade = DistanceMultiplier
						local Tempo = 15 * DistanceMultiplier
						Evt.Suppression:FireClient(SKP_002,2,intensidade,Tempo)
					end
				end

				Debris:AddItem(BreachPlace.Destroyable,0)
			end
		end

	elseif Mode == 2 then

		local aw = Engine.FX.DoorBreachFX:Clone()
		aw.Parent = BreachPlace.Door.Door
		aw.RollOffMaxDistance = 100
		aw.RollOffMinDistance = 5
		aw:Play()

		BreachPlace.Destroyed.Value = true
		if BreachPlace.Door:FindFirstChild("Hinge") ~= nil then
			BreachPlace.Door.Hinge:Destroy()
		end
		if BreachPlace.Door:FindFirstChild("Knob") ~= nil then
			BreachPlace.Door.Knob:Destroy()
		end

		local forca = Instance.new("BodyForce")
		forca.Force = -Norm * BreachPlace.Door.Door:GetMass() * Vector3.new(50,0,50)
		forca.Parent = BreachPlace.Door.Door

		Debris:AddItem(BreachPlace,3)

	elseif Mode == 3 then
		if Player.Character.ACS_Client.Kit.Fortifications.Value > 0 then
			Player.Character.ACS_Client.Kit.Fortifications.Value = Player.Character.ACS_Client.Kit.Fortifications.Value - 1
			BreachPlace.Fortified.Value = true
			local C4 = Instance.new('Part')

			C4.Parent = BreachPlace.Destroyable
			C4.Size =  Vector3.new(Hit.Size.X + .05,Hit.Size.Y + .05,Hit.Size.Z + 0.5) 
			C4.Material = Enum.Material.DiamondPlate
			C4.Anchored = true
			C4.CFrame = Hit.CFrame

			local S = Engine.FX.FortFX:Clone()
			S.PlaybackSpeed = math.random(30,55)/40
			S.Volume = 1
			S.Parent = C4
			S.PlayOnRemove = true
			S:Destroy()
		end
	end
end

Evt.Breach.OnServerInvoke = BreachFunction

-------------------------------------------------------------------
-----------------------[MEDSYSTEM]---------------------------------
-------------------------------------------------------------------

Evt.Ombro.OnServerEvent:Connect(function(Player,Vitima)
	local Nombre
	for SKP_001, SKP_002 in pairs(game.Players:GetChildren()) do
		if SKP_002:IsA('Player') and SKP_002 ~= Player and SKP_002.Name == Vitima then
			if SKP_002.Team == Player.Team then
				Nombre = Player.Name
			else
				Nombre = "Someone"
			end
			Evt.Ombro:FireClient(SKP_002,Nombre)
		end
	end
end)

Evt.Target.OnServerEvent:Connect(function(Player,Vitima)
	Player.Character.ACS_Client.Variaveis.PlayerSelecionado.Value = Vitima
end)

Evt.Render.OnServerEvent:Connect(function(Player,Status,Vitima)
	if Vitima == "N/A" then
		Player.Character.ACS_Client.Stances.Rendido.Value = Status
	else

		local VitimaTop = game.Players:FindFirstChild(Vitima)
		if VitimaTop.Character.ACS_Client.Stances.Algemado.Value == false then
			VitimaTop.Character.ACS_Client.Stances.Rendido.Value = Status
			VitimaTop.Character.ACS_Client.Variaveis.HitCount.Value = 0
		end
	end
end)

Evt.Drag.OnServerEvent:Connect(function(player)
	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Item = Human.Parent.ACS_Client.Kit.EpiAir2


	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid

		local Sangrando = PlHuman.Parent.ACS_Client.Stances.Sangrando
		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido
		local PlCaido = PlHuman.Parent.ACS_Client.Stances.Caido
		local Sang = PlHuman.Parent.ACS_Client.Variaveis.Sangue

		if enabled.Value == false then

			if PlCaido.Value == true or PlCaido.Parent.Algemado.Value == true then 
				enabled.Value = true	

				coroutine.wrap(function()
					while target.Value ~= "N/A" and PlCaido.Value == true and PlHuman.Health > 0 and Human.Health > 0 and Human.Parent.ACS_Client.Stances.Caido.Value == false or target.Value ~= "N/A" and PlCaido.Parent.Algemado.Value == true do
						wait()
						pcall(function()
							player2.Character.UpperTorso.Anchored = true
							player2.Character.UpperTorso.CFrame = Human.Parent.UpperTorso.CFrame*CFrame.new(0,0.75,2)*CFrame.Angles(math.rad(0), math.rad(0), math.rad(90))
							enabled.Value = true
						end)
					end
					pcall(function()
						player2.Character.UpperTorso.Anchored = false
						enabled.Value = false
						coroutine.yield()
					end)
				end)()

				enabled.Value = false
			end	
		end	
	end
end)

local Functions = Evt.MedSys
local FunctionsMulti = Evt.MedSys.Multi


local Bandage = Functions.Bandage
local Splint = Functions.Splint
local GreenRed = Functions.GreenRed
local Energetic = Functions.Energetic
local Tourniquet = Functions.Tourniquet


local Compress_Multi = FunctionsMulti.Compress
local Bandage_Multi = FunctionsMulti.Bandage
local Splint_Multi = FunctionsMulti.Splint
local EpiAir_Multi = FunctionsMulti.EpiAir
local sleep_Multi = FunctionsMulti.sleep
local MorAir_Multi = FunctionsMulti.MorAir
local BloodBag_Multi = FunctionsMulti.BloodBag
local Tourniquet_Multi = FunctionsMulti.Tourniquet
local prolene_Multi = FunctionsMulti.prolene
local o2_Multi = FunctionsMulti.o2
local defib_Multi = FunctionsMulti.defib
local npa_Multi = FunctionsMulti.npa
local catheter_Multi = FunctionsMulti.catheter
local etube_Multi = FunctionsMulti.etube
local nylon_Multi = FunctionsMulti.nylon
local balloon_Multi = FunctionsMulti.balloon
local skit_Multi = FunctionsMulti.skit
local bvm_Multi = FunctionsMulti.bvm
local nrb_Multi = FunctionsMulti.nrb
local scalpel_Multi = FunctionsMulti.scalpel
local suction_Multi = FunctionsMulti.suction
local clamp_Multi = FunctionsMulti.clamp
local prolene5_Multi = FunctionsMulti.prolene5
local drawblood_Multi = FunctionsMulti.drawblood


local Algemar = Functions.Algemar
local Fome = Functions.Fome
local Stance = Evt.MedSys.Stance
local Collapse = Functions.Collapse
local rodeath = Functions.rodeath
local Reset = Functions.Reset

local medFolder = script.MedicalSounds
local stimSound = medFolder.Stim
local bloodBagSound = medFolder.Bloodbag
local bandageSound = medFolder.Bandage
local electroSound = medFolder.Electrolytes
local o2Sound = medFolder.O2
local scalpelSound = medFolder.Scalpel
local nylonSound = medFolder.Nylon
local suctionSound = medFolder.Suction
local catheterSound = medFolder.Catheter
local tourniquetSound = medFolder.Tourniquet
local setupIVSound = medFolder.Setup
local splintSound = medFolder.Splint


Collapse.OnServerEvent:Connect(function(player)


	local Human = player.Character.Humanoid
	local ACS_Client= Human.Parent.ACS_Client 
	local Dor = ACS_Client.Variaveis.Dor
	local Sangue = ACS_Client.Variaveis.Sangue
	local IsWounded = ACS_Client.Stances.Caido
	local IsDead = ACS_Client.Stances.rodeath


	if Sangue.Value <= 1250 or IsWounded.Value == true or IsDead.Value == true then -- Man this Guy's Really wounded,
		IsWounded.Value = true
		Human.PlatformStand = true
		Human.AutoRotate = false		
	elseif IsWounded.Value == false then -- YAY A MEDIC ARRIVED! =D
		Human.PlatformStand = false
		Human.AutoRotate = true

	end
end)

rodeath.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local ACS_Client= Human.Parent.ACS_Client
	local Dor = ACS_Client.Variaveis.Dor
	local Sangue = ACS_Client.Variaveis.Sangue

	local IsWounded = ACS_Client.Stances.Caido
	local IsDead = ACS_Client.Stances.rodeath
	local bleeding = ACS_Client.Stances.Sangrando
	local bbleeding = ACS_Client.Stances.bbleeding
	local cpr = ACS_Client.Stances.cpr
	local dead = ACS_Client.Stances.dead
	local life = ACS_Client.Stances.life
	local Sangrando = ACS_Client.Stances.Sangrando
	--local Teams = game:GetService("Teams")
	--local civilian = Teams.Civilian

	if IsDead.Value == true then
		life.Value = false
		IsWounded.Value = true
		--Sangrando.Value = true
		if Sangue.Value <= 0 then
			dead.Value = true	
			wait(1)
			Human.PlatformStand = false
			Human.AutoRotate = true	

			--player.Team = civilian
			Human.Health = 0
		else

			wait(90)



			if Human.Health <= 1 then


				dead.Value = true
				Sangue.Value = 0	

				wait(1)
				Human.PlatformStand = false
				Human.AutoRotate = true	

				--player.Team = civilian
				Human.Health = 0


			end
		end
	end

end)


Bandage.OnServerEvent:Connect(function(player)
	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local Sangrando = Human.Parent.ACS_Client.Stances.Sangrando
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Ferido = Human.Parent.ACS_Client.Stances.Ferido
	local bbleeding = Human.Parent.ACS_Client.Stances.bbleeding

	local Bandagens = Human.Parent.ACS_Client.Kit.Bandagem

	if enabled.Value == false and Caido.Value == false  then

		if Bandagens.Value >= 1 and Sangrando.Value == true then 
			enabled.Value = true

			local newBandage = bandageSound:Clone()
			newBandage.Parent = Human.Parent.Head
			newBandage:Destroy()

			wait(.3)	


			--local number = math.random(1, 2)

			--if number == 1 then		
			Sangrando.Value = false
			--end

			Bandagens.Value = Bandagens.Value - 1 


			wait(2)
			enabled.Value = false

		end	
	end	
end)

--[[
Compress.OnServerEvent:Connect(function(player)


	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local Sangrando = Human.Parent.ACS_Client.Stances.Sangrando
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local isdead = Human.Parent.ACS_Client.Stances.rodeath
	local cpr = Human.Parent.ACS_Client.Stances.cpr

	local Bandagens = Human.Parent.ACS_Client.Kit.Bandagem

	if enabled.Value == false and isdead.Value == true then
	
		enabled.Value = true
	
		cpr.Value = true

				
			
		Human.Health = Human.Health + 25
		
		
		
		
		wait(0.5)
		

		enabled.Value = false

	end	
end)







defib.OnServerEvent:Connect(function(player)


	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local Sangrando = Human.Parent.ACS_Client.Stances.Sangrando
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Ferido = Human.Parent.ACS_Client.Stances.Ferido
	local bbleeding = Human.Parent.ACS_Client.Stances.bbleeding
	local o2l = Human.Parent.ACS_Client.Stances.o2
	local isdead = Human.Parent.ACS_Client.Stances.rodeath

	local Bandagens = Human.Parent.ACS_Client.Kit.defib

	if enabled.Value == false then
	
		if Bandagens.Value >= 1 and o2l.Value == true and isdead.Value == true then 
		enabled.Value = true

		wait(4)		
		
			isdead.Value = false
			Caido.Value = false
			
			Human.Health = Human.Health + 100
		
		
		wait(1)
		enabled.Value = false
	
		end	
	end	
end)
]]--

Splint.OnServerEvent:Connect(function(player)
	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local Sangrando = Human.Parent.ACS_Client.Stances.Sangrando
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Ferido = Human.Parent.ACS_Client.Stances.Ferido

	local Bandagens = Human.Parent.ACS_Client.Kit.Splint

	if enabled.Value == false and Caido.Value == false  then

		if Bandagens.Value >= 1 and Ferido.Value == true  then 
			enabled.Value = true

			wait(.3)		

			Ferido.Value = false 

			local sound = splintSound:Clone()
			sound.Parent = Human.Parent.Head
			sound:Destroy()

			Bandagens.Value = Bandagens.Value - 1 


			wait(2)
			enabled.Value = false

		end	
	end	
end)

GreenRed.OnServerEvent:Connect(function(player)
	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local Sangrando = Human.Parent.ACS_Client.Stances.Sangrando
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Dor = Human.Parent.ACS_Client.Variaveis.Dor
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Ferido = Human.Parent.ACS_Client.Stances.Ferido

	local Bandagens = Human.Parent.ACS_Client.Kit.Bandagem

	if enabled.Value == false and Caido.Value == false  then

		if Bandagens.Value >= 1  and Dor.Value >= 1  then
			enabled.Value = true

			local stimClone = stimSound:Clone()
			stimClone.Parent = Human.Parent.Head
			stimClone:Destroy()

			wait(.3)		

			Dor.Value = Dor.Value - math.random(60,75)

			Bandagens.Value = Bandagens.Value - 1 


			wait(2)
			enabled.Value = false

		end	
	end	
end)

Energetic.OnServerEvent:Connect(function(player)
	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local Sangrando = Human.Parent.ACS_Client.Stances.Sangrando
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Dor = Human.Parent.ACS_Client.Variaveis.Dor
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Ferido = Human.Parent.ACS_Client.Stances.Ferido

	local Bandagens = Human.Parent.ACS_Client.Kit.Energetico
	--local Energia = Human.Parent.ACS_Client.Variaveis.Energia

	if enabled.Value == false and Caido.Value == false and Bandagens.Value >= 1 then

		if Human.Health < Human.MaxHealth  then
			enabled.Value = true

			local electroClone = electroSound:Clone()
			electroClone.Parent = Human.Parent.Head
			electroClone:Destroy()

			wait(.3)		

			Human.Health = Human.Health + (Human.MaxHealth/3)
			--Energia.Value = Energia.Value + (Energia.MaxValue/3)
			Bandagens.Value = Bandagens.Value - 1


			wait(2)
			enabled.Value = false

		end	
	end	
end)

Tourniquet.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local Sangrando = Human.Parent.ACS_Client.Stances.Sangrando
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Dor = Human.Parent.ACS_Client.Variaveis.Dor
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Ferido = Human.Parent.ACS_Client.Stances.Ferido

	local Bandagens = Human.Parent.ACS_Client.Kit.Tourniquet

	if Caido.Value == false then
		if Human.Parent.ACS_Client.Stances.Tourniquet.Value == false then
			if enabled.Value == false and Bandagens.Value > 0 then
				enabled.Value = true

				local sound = tourniquetSound:Clone()
				sound.Parent = Human.Parent.Head
				sound:Destroy()

				wait(.3)		

				Human.Parent.ACS_Client.Stances.Tourniquet.Value = true
				Bandagens.Value = Bandagens.Value - 1


				wait(2)
				enabled.Value = false

			end	
		else
			if enabled.Value == false then
				enabled.Value = true

				local sound = tourniquetSound:Clone()
				sound.Parent = Human.Parent.Head
				sound:Destroy()

				wait(.3)		

				Human.Parent.ACS_Client.Stances.Tourniquet.Value = false
				Bandagens.Value = Bandagens.Value + 1


				wait(2)
				enabled.Value = false
			end
		end
	end
end)

Compress_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local isdead = Human.Parent.ACS_Client.Stances.rodeath

	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.ACS_Client.Stances.Sangrando
		local bbleeding = PlHuman.Parent.ACS_Client.Stances.bbleeding
		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido
		local cpr = PlHuman.Parent.ACS_Client.Stances.cpr
		local isdead = PlHuman.Parent.ACS_Client.Stances.rodeath

		if enabled.Value == false then

			if isdead.Value == true and (Sangrando.Value == false or Human.Parent.ACS_Client.Stances.Tourniquet.Value == true) then 
				enabled.Value = true

				PlHuman.Health = PlHuman.Health + 5




				wait(0.5)

				enabled.Value = false
			end
		end
	end
end)

Bandage_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Item = Human.Parent.ACS_Client.Kit.Bandagem

	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.ACS_Client.Stances.Sangrando
		local bbleeding = PlHuman.Parent.ACS_Client.Stances.bbleeding
		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido

		if enabled.Value == false then

			if Item.Value >= 1 and Sangrando.Value == true then 
				enabled.Value = true

				wait(.3)		

				--local number = math.random(1, 2)

				--if number == 1 then		
				Sangrando.Value = false
				--end

				local newBandage = bandageSound:Clone()
				newBandage.Parent = Human.Parent.Head
				newBandage:Destroy()

				Item.Value = Item.Value - 1 


				wait(2)
				enabled.Value = false
			end	

		end	
	end
end)

scalpel_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Item = Human.Parent.ACS_Client.Kit.scalpel

	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.ACS_Client.Stances.Sangrando
		local cutopen = PlHuman.Parent.ACS_Client.Stances.cutopen
		local bbleeding = PlHuman.Parent.ACS_Client.Stances.bbleeding
		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido
		local o2 = PlHuman.Parent.ACS_Client.Stances.o2
		local caido = PlHuman.Parent.ACS_Client.Stances.Caido

		if enabled.Value == false and cutopen.Value == false and caido.Value == true and o2.Value == true then

			if Item.Value >= 1 then 
				enabled.Value = true

				wait(.3)		

				local sound = scalpelSound:Clone()
				sound.Parent = Human.Parent.Head
				sound:Destroy()

				cutopen.Value = true



				wait(2)

				enabled.Value = false
			end	

		end	
	end
end)

suction_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Item = Human.Parent.ACS_Client.Kit.suction

	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.ACS_Client.Stances.Sangrando
		local npa = PlHuman.Parent.ACS_Client.Stances.npa
		local etube = PlHuman.Parent.ACS_Client.Stances.etube
		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido

		if PlHuman.Parent.ACS_Client.Stances.cutopen.Value == true and PlHuman.Parent.ACS_Client.Stances.o2.Value == true and PlHuman.Parent.ACS_Client.Stances.Caido.Value == true then
			if enabled.Value == false then
				if Item.Value > 0 then 
					--if Item.Value > 0 then 
					if not player.Character:GetAttribute("SoloSurg") then
						enabled.Value = true
					end

					wait(.1)		

					PlHuman.Parent.ACS_Client.Stances.suction.Value = true	

					local sound = suctionSound:Clone()
					sound.Parent = Human.Parent.Head
					sound:Destroy()

					wait(3.5)	

					PlHuman.Parent.ACS_Client.Stances.suction.Value = false


					wait(0.1)
					if not player.Character:GetAttribute("SoloSurg") then
						enabled.Value = false
					end
				end
			end	
		end
	end

end)

clamp_Multi.OnServerEvent:Connect(function(player)
	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Item = Human.Parent.ACS_Client.Kit.clamp

	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.ACS_Client.Stances.Sangrando
		local npa = PlHuman.Parent.ACS_Client.Stances.npa
		local etube = PlHuman.Parent.ACS_Client.Stances.etube
		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido


		if PlHuman.Parent.ACS_Client.Stances.cutopen.Value == true and PlHuman.Parent.ACS_Client.Stances.o2.Value == true and PlHuman.Parent.ACS_Client.Stances.suction.Value == true and PlHuman.Parent.ACS_Client.Stances.Caido.Value == true then

			if enabled.Value == false then
				if Item.Value > 0 then 
					--if Item.Value > 0 then 
					if not player.Character:GetAttribute("SoloSurg") then
						enabled.Value = true
					end

					wait(.1)		

					PlHuman.Parent.ACS_Client.Stances.clamped.Value = true	
					wait(5.5)	

					PlHuman.Parent.ACS_Client.Stances.clamped.Value = false

					wait(0.1)

					if not player.Character:GetAttribute("SoloSurg") then
						enabled.Value = false
					end
				end
			end	
		end
	end

end)

catheter_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Item = Human.Parent.ACS_Client.Kit.catheter


	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.ACS_Client.Stances.Sangrando
		local bbleeding = PlHuman.Parent.ACS_Client.Stances.bbleeding
		local balloonbleed = PlHuman.Parent.ACS_Client.Stances.balloonbleed
		local balloon = PlHuman.Parent.ACS_Client.Stances.balloon
		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido
		local cutopen = PlHuman.Parent.ACS_Client.Stances.cutopen
		local suction = PlHuman.Parent.ACS_Client.Stances.suction

		if PlHuman.Parent.ACS_Client.Stances.catheter.Value == false and PlHuman.Parent.ACS_Client.Stances.o2.Value == true and cutopen.Value == true and suction.Value == true and PlHuman.Parent.ACS_Client.Stances.Caido.Value == true then

			if enabled.Value == false then
				if Item.Value > 0 and (Sangrando.Value == true or bbleeding.Value == true) then 
					enabled.Value = true



					wait(.3)		

					PlHuman.Parent.ACS_Client.Stances.catheter.Value = true	

					local sound = catheterSound:Clone()
					sound.Parent = Human.Parent.Head
					sound:Destroy()

					Item.Value = Item.Value - 1 


					wait(2)
					enabled.Value = false
				end
			end	
		else
			if enabled.Value == false then
				if PlHuman.Parent.ACS_Client.Stances.balloon.Value == false then 
					enabled.Value = true

					wait(.3)		

					PlHuman.Parent.ACS_Client.Stances.catheter.Value = false		

					Item.Value = Item.Value + 1 


					wait(2)
					enabled.Value = false
				end
			end	
		end
	end
end)

balloon_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Item = Human.Parent.ACS_Client.Kit.catheter


	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.ACS_Client.Stances.Sangrando
		local bbleeding = PlHuman.Parent.ACS_Client.Stances.bbleeding
		local balloonbleed = PlHuman.Parent.ACS_Client.Stances.balloonbleed
		local repaired = PlHuman.Parent.ACS_Client.Stances.repaired
		local catheter = PlHuman.Parent.ACS_Client.Stances.catheter
		local o2l = PlHuman.Parent.ACS_Client.Stances.o2
		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido


		if PlHuman.Parent.ACS_Client.Stances.balloon.Value == false then

			if enabled.Value == false then
				if Item.Value > 0 and (Sangrando.Value == true or bbleeding.Value == true) and o2l.Value == true and catheter.Value == true and PlHuman.Parent.ACS_Client.Stances.Caido.Value == true then 
					enabled.Value = true

					task.wait(.3)		

					PlHuman.Parent.ACS_Client.Stances.balloon.Value = true	
					Sangrando.Value = false
					bbleeding.Value = false	




					task.wait(2)
					enabled.Value = false
				end
			end	
		else
			if enabled.Value == false then
				if PlHuman.Parent.ACS_Client.Stances.balloon.Value == true and repaired.Value == true then 
					enabled.Value = true

					task.wait(.3)		

					PlHuman.Parent.ACS_Client.Stances.balloon.Value = false		


					task.wait(2)
					enabled.Value = false
				end
			end	
		end
	end
end)

prolene_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Item = Human.Parent.ACS_Client.Kit.prolene


	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.ACS_Client.Stances.Sangrando
		local bbleeding = PlHuman.Parent.ACS_Client.Stances.bbleeding
		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido
		local o2l = PlHuman.Parent.ACS_Client.Stances.o2
		local balloonbleed = PlHuman.Parent.ACS_Client.Stances.balloonbleed
		local repaired = PlHuman.Parent.ACS_Client.Stances.repaired
		local balloon = PlHuman.Parent.ACS_Client.Stances.balloon


		if enabled.Value == false then

			if Item.Value > 0 and o2l.Value == true and balloon.Value == true and PlHuman.Parent.ACS_Client.Stances.Caido.Value == true then 
				enabled.Value = true

				wait(2)		

				Sangrando.Value = false
				bbleeding.Value = false
				balloonbleed.Value = false
				repaired.Value = true
				Item.Value = Item.Value - 1



				wait(2)

				enabled.Value = false

			end	

		end	
	end
end)

prolene5_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Item = Human.Parent.ACS_Client.Kit.prolene5


	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid
		local Sangrando = PlHuman.Parent.ACS_Client.Stances.Sangrando
		local bbleeding = PlHuman.Parent.ACS_Client.Stances.bbleeding
		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido
		local o2l = PlHuman.Parent.ACS_Client.Stances.o2
		local balloonbleed = PlHuman.Parent.ACS_Client.Stances.balloonbleed
		local repaired = PlHuman.Parent.ACS_Client.Stances.repaired
		local balloon = PlHuman.Parent.ACS_Client.Stances.balloon
		local clamped = PlHuman.Parent.ACS_Client.Stances.clamped
		local surg2 = PlHuman.Parent.ACS_Client.Stances.surg2


		if enabled.Value == false then

			if Item.Value > 0 and o2l.Value == true and clamped.Value == true and PlHuman.Parent.ACS_Client.Stances.Caido.Value == true then 

				enabled.Value = true

				wait(2)		


				surg2.Value = false
				repaired.Value = true
				Item.Value = Item.Value - 1



				wait(2)

				enabled.Value = false

			end	

		end	
	end
end)

nylon_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Item = Human.Parent.ACS_Client.Kit.nylon


	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.ACS_Client.Stances.Sangrando
		local bbleeding = PlHuman.Parent.ACS_Client.Stances.bbleeding
		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido
		local o2l = PlHuman.Parent.ACS_Client.Stances.o2
		local balloonbleed = PlHuman.Parent.ACS_Client.Stances.balloonbleed
		local repaired = PlHuman.Parent.ACS_Client.Stances.repaired
		local balloon = PlHuman.Parent.ACS_Client.Stances.balloon
		local catheter = PlHuman.Parent.ACS_Client.Stances.catheter
		local cutopen = PlHuman.Parent.ACS_Client.Stances.cutopen


		if enabled.Value == false then

			if Item.Value >= 1 and o2l.Value == true and repaired.Value == true and catheter.Value == false and cutopen.Value == true and PlHuman.Parent.ACS_Client.Stances.Caido.Value == true then 
				enabled.Value = true

				wait(2)		

				repaired.Value = false
				cutopen.Value = false


				wait(2)
				Item.Value = Item.Value - 1
				enabled.Value = false

				local sound = nylonSound:Clone()
				sound.Parent = Human.Parent.Head
				sound:Destroy()

			end	

		end	
	end
end)

defib_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Item = Human.Parent.ACS_Client.Kit.defib


	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.ACS_Client.Stances.Sangrando
		local bbleeding = PlHuman.Parent.ACS_Client.Stances.bbleeding
		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido
		local PlCaido = PlHuman.Parent.ACS_Client.Stances.Caido
		local o2p = PlHuman.Parent.ACS_Client.Stances.o2
		local isdead = PlHuman.Parent.ACS_Client.Stances.rodeath
		local cpr = PlHuman.Parent.ACS_Client.Stances.cpr
		local life = PlHuman.Parent.ACS_Client.Stances.life


		if enabled.Value == false then

			if Item.Value >= 1 and o2p.Value == true and isdead.Value == true then 
				enabled.Value = true

				local defibCharge = script.MedicalSounds.Defib_Charge:Clone()
				local defibUse = script.MedicalSounds.Defib_Use:Clone()
				defibCharge.Parent = PlHuman.Parent.Head
				defibUse.Parent = PlHuman.Parent.Head

				defibCharge:Destroy()

				wait(2.5)		

				isdead.Value = false

				life.Value = true


				PlHuman.Health = PlHuman.MaxHealth

				defibUse:Destroy()

				wait(1)
				enabled.Value = false

			end	
		end	
	end
end)

Splint_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Item = Human.Parent.ACS_Client.Kit.Splint

	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.ACS_Client.Stances.Sangrando
		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido

		if enabled.Value == false then

			if Item.Value >= 1 and Ferido.Value == true  then 
				enabled.Value = true

				wait(.3)		

				Ferido.Value = false		

				local sound = splintSound:Clone()
				sound.Parent = Human.Parent.Head
				sound:Destroy()

				Item.Value = Item.Value - 1 


				wait(2)
				enabled.Value = false
			end	

		end	
	end
end)

Tourniquet_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Item = Human.Parent.ACS_Client.Kit.Tourniquet

	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.ACS_Client.Stances.Sangrando
		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido


		if PlHuman.Parent.ACS_Client.Stances.Tourniquet.Value == false then

			if enabled.Value == false then
				if Item.Value > 0 then 
					enabled.Value = true

					local sound = tourniquetSound:Clone()
					sound.Parent = Human.Parent.Head
					sound:Destroy()

					wait(.3)		

					PlHuman.Parent.ACS_Client.Stances.Tourniquet.Value = true		

					Item.Value = Item.Value - 1 


					wait(2)
					enabled.Value = false
				end
			end	
		else
			if enabled.Value == false then
				if PlHuman.Parent.ACS_Client.Stances.Tourniquet.Value == true then 
					enabled.Value = true

					local sound = tourniquetSound:Clone()
					sound.Parent = Human.Parent.Head
					sound:Destroy()

					wait(.3)		

					PlHuman.Parent.ACS_Client.Stances.Tourniquet.Value = false		


					Item.Value = Item.Value + 1 


					wait(2)
					enabled.Value = false
				end
			end	
		end
	end
end)

skit_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Item = Human.Parent.ACS_Client.Kit.skit

	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.ACS_Client.Stances.Sangrando
		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido


		if PlHuman.Parent.ACS_Client.Stances.skit.Value == false then

			if enabled.Value == false then
				if Item.Value > 0 then 
					enabled.Value = true

					wait(.3)		

					PlHuman.Parent.ACS_Client.Stances.skit.Value = true		

					Item.Value = Item.Value - 1 

					local sound = setupIVSound:Clone()
					sound.Parent = Human.Parent.Head
					sound:Destroy()

					wait(2)
					enabled.Value = false
				end
			end	
		else
			if enabled.Value == false then
				if PlHuman.Parent.ACS_Client.Stances.skit.Value == true then 
					enabled.Value = true

					wait(.3)		

					local sound = setupIVSound:Clone()
					sound.Parent = Human.Parent.Head
					sound:Destroy()

					PlHuman.Parent.ACS_Client.Stances.skit.Value = false		


					wait(2)
					enabled.Value = false
				end
			end	
		end
	end
end)

npa_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Item = Human.Parent.ACS_Client.Kit.npa

	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local faido = PlHuman.Parent.ACS_Client.Stances.Caido
		local o2p = PlHuman.Parent.ACS_Client.Stances.o2
		local nrb = PlHuman.Parent.ACS_Client.Stances.nrb

		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido


		if PlHuman.Parent.ACS_Client.Stances.npa.Value == false then

			if enabled.Value == false then
				if Item.Value > 0 and faido.Value == false then 
					enabled.Value = true

					wait(.3)		


					PlHuman.Parent.ACS_Client.Stances.npa.Value = true	


					Item.Value = Item.Value - 1 


					wait(2)
					enabled.Value = false
				end
			end	
		else
			if enabled.Value == false then
				if PlHuman.Parent.ACS_Client.Stances.npa.Value == true and nrb.Value == false then 
					enabled.Value = true

					wait(.3)		

					PlHuman.Parent.ACS_Client.Stances.npa.Value = false	

					Item.Value = Item.Value + 1 


					wait(2)
					enabled.Value = false
				end
			end	
		end
	end
end)

etube_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Item = Human.Parent.ACS_Client.Kit.etube

	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local faido = PlHuman.Parent.ACS_Client.Stances.Caido
		local o2p = PlHuman.Parent.ACS_Client.Stances.o2

		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido


		if PlHuman.Parent.ACS_Client.Stances.etube.Value == false then

			if enabled.Value == false then
				if Item.Value > 0 and faido.Value == true then 
					enabled.Value = true

					wait(.3)		


					PlHuman.Parent.ACS_Client.Stances.etube.Value = true

					Item.Value = Item.Value - 1 


					wait(2)
					enabled.Value = false
				end
			end	
		else
			if enabled.Value == false then
				if PlHuman.Parent.ACS_Client.Stances.etube.Value == true and o2p.Value == false then 
					enabled.Value = true

					wait(.3)		


					PlHuman.Parent.ACS_Client.Stances.etube.Value = false


					Item.Value = Item.Value + 1 


					wait(2)
					enabled.Value = false
				end
			end	
		end
	end
end)	

nrb_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Item = Human.Parent.ACS_Client.Kit.nrb

	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local faido = PlHuman.Parent.ACS_Client.Stances.Caido
		local o2p = PlHuman.Parent.ACS_Client.Stances.o2

		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido


		if PlHuman.Parent.ACS_Client.Stances.nrb.Value == false and PlHuman.Parent.ACS_Client.Stances.npa.Value == true then

			if enabled.Value == false then
				if Item.Value > 0 then 
					enabled.Value = true

					wait(.3)		


					PlHuman.Parent.ACS_Client.Stances.nrb.Value = true

					Item.Value = Item.Value - 1 


					wait(2)
					enabled.Value = false
				end
			end	
		else
			if enabled.Value == false then
				if PlHuman.Parent.ACS_Client.Stances.nrb.Value == true and o2p.Value == false then 
					enabled.Value = true

					wait(.3)		


					PlHuman.Parent.ACS_Client.Stances.nrb.Value = false


					Item.Value = Item.Value + 1 


					wait(2)
					enabled.Value = false
				end
			end	
		end
	end
end)

o2_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Item = Human.Parent.ACS_Client.Kit.o2

	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.ACS_Client.Stances.Sangrando
		local npa = PlHuman.Parent.ACS_Client.Stances.npa
		local nrb = PlHuman.Parent.ACS_Client.Stances.nrb
		local etube = PlHuman.Parent.ACS_Client.Stances.etube
		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido


		if PlHuman.Parent.ACS_Client.Stances.o2.Value == false then

			if enabled.Value == false then
				if Item.Value > 0 and (nrb.Value == true or etube.Value == true) then 
					--if Item.Value > 0 then 

					enabled.Value = true

					wait(.3)		

					PlHuman.Parent.ACS_Client.Stances.o2.Value = true		

					Item.Value = Item.Value - 1 

					local sound = o2Sound:Clone()
					sound.Parent = Human.Parent.Head
					sound:Destroy()

					wait(2)
					enabled.Value = false
				end
			end	
		else
			if enabled.Value == false then
				if PlHuman.Parent.ACS_Client.Stances.o2.Value == true then
					enabled.Value = true

					wait(.3)		

					PlHuman.Parent.ACS_Client.Stances.o2.Value = false		

					Item.Value = Item.Value + 1 


					wait(2)
					enabled.Value = false
				end
			end	
		end
	end
end)

bvm_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Item = Human.Parent.ACS_Client.Kit.bvm

	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.ACS_Client.Stances.Sangrando
		local npa = PlHuman.Parent.ACS_Client.Stances.npa
		local etube = PlHuman.Parent.ACS_Client.Stances.etube
		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido


		if PlHuman.Parent.ACS_Client.Stances.o2.Value == false then

			if enabled.Value == false then
				if Item.Value > 0 and (npa.Value == true or etube.Value == true) then 
					--if Item.Value > 0 then 

					enabled.Value = true

					wait(.2)		

					PlHuman.Parent.ACS_Client.Stances.o2.Value = true	
					wait(4.5)	

					PlHuman.Parent.ACS_Client.Stances.o2.Value = false


					wait(0.2)
					enabled.Value = false
				end
			end	
		end
	end

end)

EpiAir_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Item = Human.Parent.ACS_Client.Kit.EpiAir2
	local bbleeding = Human.Parent.ACS_Client.Stances.bbleeding


	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.ACS_Client.Stances.Sangrando
		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido
		local PlCaido = PlHuman.Parent.ACS_Client.Stances.Caido
		local isdead = PlHuman.Parent.ACS_Client.Stances.rodeath
		local skit = PlHuman.Parent.ACS_Client.Stances.skit

		if enabled.Value == false then
			--if enabled.Value == false and bbleeding.Value == false then
			if Item.Value >= 1 and PlCaido.Value == true and skit.Value == true then 
				enabled.Value = true

				local stimClone = stimSound:Clone()
				stimClone.Parent = Human.Parent.Head
				stimClone:Destroy()

				wait(.3)		

				if Dor.Value > 0 then
					Dor.Value = Dor.Value + math.random(10,20)
				end

				if Sangrando.Value == true then
					MLs.Value = MLs.Value + math.random(10,35)
				end

				isdead.Value = false

				PlCaido.Value = false	

				PlHuman.PlatformStand = false
				PlHuman.AutoRotate = true		

				Item.Value = Item.Value - 1 


				wait(2)
				enabled.Value = false
			end	

		end	
	end
end)

sleep_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Item = Human.Parent.ACS_Client.Kit.sleep
	local bbleeding = Human.Parent.ACS_Client.Stances.bbleeding

	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.ACS_Client.Stances.Sangrando
		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido
		local PlCaido = PlHuman.Parent.ACS_Client.Stances.Caido
		local skit = PlHuman.Parent.ACS_Client.Stances.skit

		if enabled.Value == false then
			--if enabled.Value == false and bbleeding.Value == false then
			if Item.Value >= 1 and PlCaido.Value == false and skit.Value == true then 
				enabled.Value = true

				local stimClone = stimSound:Clone()
				stimClone.Parent = Human.Parent.Head
				stimClone:Destroy()

				wait(.3)		



				PlCaido.Value = true	
				PlHuman.PlatformStand = true
				PlHuman.AutoRotate = false

				Item.Value = Item.Value - 1 


				wait(2)
				enabled.Value = false
			end	

		end	
	end
end)

MorAir_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Item = Human.Parent.ACS_Client.Kit.MorAir2

	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.ACS_Client.Stances.Sangrando
		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido
		local PlCaido = PlHuman.Parent.ACS_Client.Stances.Caido
		local skit = PlHuman.Parent.ACS_Client.Stances.skit

		if enabled.Value == false then

			if Item.Value >= 1 and Dor.Value >= 1 and skit.Value == true then 
				enabled.Value = true

				local stimClone = stimSound:Clone()
				stimClone.Parent = Human.Parent.Head
				stimClone:Destroy()

				wait(.3)		

				Dor.Value = Dor.Value - math.random(100,150)

				Item.Value = Item.Value - 1 


				wait(2)
				enabled.Value = false
			end	

		end	
	end
end)

BloodBag_Multi.OnServerEvent:Connect(function(player)
	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Item = Human.Parent.ACS_Client.Kit.SacoDeSangue

	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.ACS_Client.Stances.Sangrando
		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local blood = PlHuman.Parent.ACS_Client.Variaveis.Sangue
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido
		local PlCaido = PlHuman.Parent.ACS_Client.Stances.Caido
		local skit = PlHuman.Parent.ACS_Client.Stances.skit

		if enabled.Value == false then

			if Item.Value >= 1 and skit.Value == true then 
				enabled.Value = true
				
				local bloodClone = bloodBagSound:Clone()
				bloodClone.Parent = Human.Parent.Head
				bloodClone:Destroy()
				
				task.wait(.3)		

				blood.Value = blood.Value + 2000

				Item.Value = Item.Value - 1 


				task.wait(2)
				enabled.Value = false
			end	

		end	
	end
end)

drawblood_Multi.OnServerEvent:Connect(function(player)

	local Human = player.Character.Humanoid
	local enabled = Human.Parent.ACS_Client.Variaveis.Doer
	local MLs = Human.Parent.ACS_Client.Variaveis.MLs
	local Caido = Human.Parent.ACS_Client.Stances.Caido
	local Item = Human.Parent.ACS_Client.Kit.SacoDeSangue

	local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

	if Caido.Value == false and target.Value ~= "N/A" then

		local player2 = game.Players:FindFirstChild(target.Value)
		local PlHuman = player2.Character.Humanoid


		local Sangrando = PlHuman.Parent.ACS_Client.Stances.Sangrando
		local MLs = PlHuman.Parent.ACS_Client.Variaveis.MLs
		local Dor = PlHuman.Parent.ACS_Client.Variaveis.Dor
		local blood = PlHuman.Parent.ACS_Client.Variaveis.Sangue
		local Ferido = PlHuman.Parent.ACS_Client.Stances.Ferido
		local PlCaido = PlHuman.Parent.ACS_Client.Stances.Caido
		local skit = PlHuman.Parent.ACS_Client.Stances.skit

		if enabled.Value == false then

			if Item.Value < 10 and skit.Value == true then 
				enabled.Value = true

				wait(.3)		

				blood.Value = blood.Value - 2000

				Item.Value = Item.Value + 1 


				wait(2)
				enabled.Value = false
			end	

		end	
	end
end)

Reset.OnServerEvent:Connect(function(player)

	if player.Character:FindFirstChild("Humanoid") then
		local Human = player.Character.Humanoid
		local target = Human.Parent.ACS_Client.Variaveis.PlayerSelecionado

		target.Value = "N/A"
	end
end)

function UpdateLog(Player,humanoid)

	local tag = humanoid:findFirstChild("creator")

	if tag ~= nil then

		local hours = os.date("*t")["hour"]
		local mins = os.date("*t")["min"]
		local sec = os.date("*t")["sec"]
		local TagType = tag:findFirstChild("type")

		if tag.Value.Name == Player.Name then
			local String = Player.Name.." Died | "..hours..":"..mins..":"..sec
			table.insert(CombatLog,String)
		else
			local String = tag.Value.Name.." Killed "..Player.Name.." | "..hours..":"..mins..":"..sec
			table.insert(CombatLog,String)
		end

		if #CombatLog > 50 then
			Backup = Backup + 1
			warn("ACS: Cleaning Combat Log | Backup: "..Backup)
			warn(CombatLog)
			CombatLog = {}
		end
	end
end

-- Check if the player can run commands
function CheckHostID(player)

	-- Is the game running in studio
	if Run:IsStudio() then return true end


	if game.CreatorType == Enum.CreatorType.User then
		-- Is the player the game's owner
		if player.UserId == game.CreatorId then return true end
	elseif game.CreatorType == Enum.CreatorType.Group then
		-- Does the player have a high enough group rank
		if player:GetRankInGroup(game.CreatorId) >= gameRules.HostRank then return true end
	end

	-- Is the player in the game host list
	for _, cID in pairs(gameRules.HostList) do
		if player.UserId == cID then return true end
	end
	return false
end

-- Reset broken glass
function ResetGlass()
	for i, gData in pairs(dParts.Glass) do
		gData[1].Parent = gData[2]

		for _, shard in pairs(gData[3]) do
			if shard then shard:Destroy() end
		end

		dParts.Glass[i] = nil
	end
end

-- Reset broken lights
function ResetLights()
	for i, lData in pairs(dParts.Lights) do
		lData[1].Material = lData[2]
		lData[1].Broken:Destroy()

		for _, light in pairs(lData[1]:GetChildren()) do
			if light:IsA("Light") then
				light.Enabled = true
			end
		end
	end
end

-- Clear dropped weapons
function ClearDroppedGuns()
	for _, weapon in pairs(ACS_Workspace.DroppedGuns) do
		weapon:Destroy()
	end
end

plr.PlayerAdded:Connect(function(player)
	
	local Rank = player:GetRankInGroup(GroupID)
	if Rank == "Guest" and not game:GetService('RunService'):IsStudio() then
		--If user in not member
		player:Kick("You must be in the group to have access.") -- Is kick player from server
	else
		--If user is member
	end
	
	player.CharacterRemoving:Connect(function(char)

	if char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and gameRules.DropWeaponsOnLeave and char:FindFirstChild("UpperTorso") then
			local pos = char.UpperTorso.CFrame
			local tools = {}

			-- Get tools before player leaves
			for _, currTool in pairs(player.Backpack:GetChildren()) do
				if currTool:IsA("Tool") and currTool:FindFirstChild("ACS_Settings") then
					table.insert(tools,currTool)
					currTool.Parent = nil
				end
			end

			if char:FindFirstChildWhichIsA("Tool") and char:FindFirstChildWhichIsA("Tool"):FindFirstChild("ACS_Settings") then
				table.insert(tools,char:FindFirstChildWhichIsA("Tool"))
				char:FindFirstChildWhichIsA("Tool").Parent = nil
				--SpawnGun(gunName,char.UpperTorso.CFrame * CFrame.new(math.random(-5,5) / 10,1,-2),char[gunName],player)
			end

			for _, gun in pairs(tools) do
				SpawnGun(gun.Name,pos,gun)
				wait()
			end
		end

	end)

	for i,v in ipairs(_G.TempBannedPlayers) do
		if v == player.Name then
			player:Kick('Blacklisted')
			warn(player.Name.." (Temporary Banned) tried to join to server")
			break
		end
	end

	for i,v in ipairs(gameRules.Blacklist) do
		if v == player.UserId then
			player:Kick('Blacklisted')
			warn(player.Name.." (Blacklisted) tried to join to server")
			break
		end
	end

	if gameRules.AgeRestrictEnabled and not Run:IsStudio() then
		if player.AccountAge < gameRules.AgeLimit then
			player:Kick('Age restricted server! Please wait: '..(gameRules.AgeLimit - player.AccountAge)..' Days')
		end
	end

	--if game.CreatorType == Enum.CreatorType.User then
	--	if player.UserId == game.CreatorId or Run:IsStudio() then
	--		player.Chatted:Connect(function(Message)
	--			if string.lower(Message) == "/acslog" then
	--				Evt.CombatLog:FireClient(player,CombatLog)
	--			end
	--		end)
	--	end
	--elseif game.CreatorType == Enum.CreatorType.Group then
	--	if player:IsInGroup(game.CreatorId) or Run:IsStudio() then
	--		player.Chatted:Connect(function(Message)
	--			if string.lower(Message) == "/acslog" then
	--				Evt.CombatLog:FireClient(player,CombatLog)
	--			end
	--		end)
	--	end
	--end

	if CheckHostID(player) then
		player.Chatted:Connect(function(msg)
			-- Convert to lowercase
			msg = string.lower(msg)

			local pfx = gameRules.CommandPrefix

			if msg == pfx.."acslog" or msg == pfx.."acs log" then
				Evt.CombatLog:FireClient(player,CombatLog)
			elseif msg == pfx.."reset all" or msg == pfx.."resetall" or msg == pfx.."reset" then
				ResetGlass()
				ResetLights()
			elseif msg == pfx.."reset glass" or msg == pfx.."resetglass" then
				ResetGlass()
			elseif msg == pfx.. "reset lights" or msg == pfx.."resetlights" then
				ResetLights()
			elseif msg == pfx.. "clear guns" or msg == pfx.."clearguns" then
				ClearDroppedGuns()
			end
		end)
	end


	local setupWorked = false
	player.CharacterAdded:Connect(function(char)
		setupWorked = true
		SetupCharacter(player,char)
		
		local humanoid = game.Workspace:WaitForChild(player.Name).Humanoid
		
		humanoid.DisplayDistanceType = "None"
		humanoid.Parent.Head.CanCollide = true

		char:SetAttribute("CanDash", false)
		char:SetAttribute("ParrySuccessful", false)
		char:SetAttribute("Parried", false)
		char:SetAttribute("Invulnerable", false)
	end)

	-- Character setup failsafe
	repeat wait() until player.Character
	if not setupWorked then SetupCharacter(player,player.Character) end
end)

-- Dash Effect

game.ReplicatedStorage.Status.DashEvent.OnServerEvent:Connect(function(player)
	local Character = player.Character
	local wind = script.Wind:Clone()
	local dash = script.DashEffect:Clone()
	if Character.HumanoidRootPart then
		wind.Parent = Character.HumanoidRootPart
		dash.Parent = Character.HumanoidRootPart
		local WindSound = Character.HumanoidRootPart:WaitForChild("Wind",3)
		local DashEffect = Character.HumanoidRootPart:WaitForChild("DashEffect",3)
		WindSound:Play()
		DashEffect:Emit(4)
	end
end)


function SetupCharacter(player, char)
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = "Characters"
		end
	end

	if gameRules.TeamTags then
		local L_17_ = HUDs:WaitForChild('TeamTagUI'):clone()
		L_17_.Parent = char
		L_17_.Adornee = char.Head
	end
	
	game.ReplicatedStorage.NametagEvent:FireAllClients()
	
	char.Humanoid.BreakJointsOnDeath = false
	char.Humanoid.Died:Connect(function()

		-- Drop tools on death
		if gameRules.DropWeaponsOnDeath then
			for _, currTool in pairs(player.Backpack:GetChildren()) do
				if currTool:IsA("Tool") and currTool:FindFirstChild("ACS_Settings") then
					local gunFrame

					if char:FindFirstChild("S_"..currTool.Name) then
						gunFrame = char["S_"..currTool.Name].Handle.CFrame
						char:FindFirstChild("S_"..currTool.Name):Destroy()
					else
						gunFrame = char.UpperTorso.CFrame * CFrame.new(math.random(-5,5) / 10,1,-2)
					end

					SpawnGun(currTool.Name,gunFrame,currTool,player)
					wait()
				end
			end

			wait()
			-- Drop a gun if the player was holding it
			if char:FindFirstChildWhichIsA("Tool") and char:FindFirstChildWhichIsA("Tool"):FindFirstChild("ACS_Settings") then
				local gunName = char:FindFirstChildWhichIsA("Tool").Name
				SpawnGun(gunName,char.UpperTorso.CFrame * CFrame.new(math.random(-5,5) / 10,1,-2),char[gunName],player)
			end
		end

		UpdateLog(player,char.Humanoid)
		pcall(function()
			Ragdoll(char)
		end)
	end)

	repeat wait() until player:FindFirstChild("Backpack")

	-- Check the player's backpack for ACS guns
	for _, tool in pairs(player.Backpack:GetChildren()) do
		if tool:FindFirstChild("ACS_Settings") and require(tool.ACS_Settings).Holster then
			CheckHolster(player,tool.Name,require(tool.ACS_Settings),tool)
		end
	end

	-- Set up listeners for future tools
	player.Backpack.ChildAdded:Connect(function(newChild)
		if newChild:IsA("Tool") and newChild:FindFirstChild("ACS_Settings") and require(newChild.ACS_Settings).Holster then
			CheckHolster(player,newChild.Name,require(newChild.ACS_Settings),newChild)
		end
	end)

	player.Backpack.ChildRemoved:Connect(function(newChild)
		if newChild:IsA("Tool") and newChild:FindFirstChild("ACS_Settings") and char:FindFirstChild("S_"..newChild.Name) and player:FindFirstChild('Backpack') and not player.Backpack:FindFirstChild(newChild.Name) then
			char:FindFirstChild("S_"..newChild.Name):Destroy()
		end
	end)
end

-- Check if a holster model can be added
function CheckHolster(player,weaponName,toolSettings,tool)
	if player.Character and not player.Character:FindFirstChild("S_"..weaponName) and not player.Character:FindFirstChild(weaponName) then
		HolsterWeapon(player,weaponName,toolSettings,tool)
	end
end

-- Weld holster model to the player
function HolsterWeapon(player,weaponName,toolSettings,tool)
	if player.Character:FindFirstChild(toolSettings.HolsterPoint) then
		local holsterPoint = toolSettings.HolsterPoint
		local holsterModel = GunModels:FindFirstChild(weaponName):Clone()
		holsterModel.Name = "S_"..weaponName
		holsterModel.Parent = player.Character

		if holsterModel:FindFirstChild("Nodes") then
			holsterModel.Nodes:Destroy()
		end
		
		local config = tool:FindFirstChild("RepValues")
		--print(config.Mag.Value)
		
		for _, part in pairs(holsterModel:GetChildren()) do
			if part:IsA("BasePart") and part.Name ~= "Handle" then
				if part.Name == "SightMark" or (part.Name == "Warhead" and config and config.Mag.Value < 1) or part.Name == "AmmoDisplay" or part.Name == "AmmoBg" then
					part:Destroy()
				else
					local newWeld = Ultil.WeldComplex(holsterModel.Handle,part,part.Name)
					newWeld.Parent = holsterModel.Handle
					part.Anchored = false
					part.CanCollide = false
				end
			end
		end

		local holsterWeld = Ultil.Weld(player.Character[holsterPoint],holsterModel.Handle,toolSettings.HolsterCFrame)
		holsterWeld.Parent = holsterModel
		holsterWeld.Name = "HolsterWeld"
		holsterModel.Handle.Anchored = false
	end
end

function SpawnGun(gunName,gunPosition,tool,player,config)
	if ServerStorage:FindFirstChild('Prop'..gunName) then
		tool:Destroy()
		local returner = ServerStorage:FindFirstChild('Prop'..gunName)
		returner.Parent = workspace:WaitForChild('MainMap',10):WaitForChild('Floaters',10):WaitForChild('Props',10)
		returner:SetPrimaryPartCFrame(gunPosition)
		return
	end

	local dropModel = GunModels:FindFirstChild(gunName):Clone()
	dropModel.Handle.Anchored = false
	dropModel.Handle.CanTouch = true
	--dropModel.Handle.CFrame = CFrame.new(dropModel["Origin Position"])

	dropModel.PrimaryPart = dropModel.Handle
	dropModel.Handle.Size = dropModel:GetExtentsSize()

	if dropModel:FindFirstChild("Nodes") then dropModel.Nodes:Destroy() end
	
	if #dropModel:GetChildren() < 2 then
		dropModel.Handle.CanCollide = true
	else
		dropModel.Handle.CanCollide = false
	end

	for _, part in pairs(dropModel:GetChildren()) do
		if part.Name == "Warhead" and config and config.IsLauncher and tool:FindFirstChild("RepValues") and tool.RepValues.Mag.Value < 1 then
			part:Destroy()
		elseif part:IsA("BasePart") and part.Name ~= "Handle" then
			local newWeld = Ultil.WeldComplex(dropModel.Handle,part,part.Name)
			newWeld.Parent = dropModel.Handle
			part.Anchored = false
			part.CanCollide = true
			part.CanTouch = false
			part.CollisionGroup = "Guns"
		end
	end

	if not tool then
		tool = Engine.ToolStorage:FindFirstChild(gunName):Clone()
	end
	tool.Parent = dropModel

	--local clickDetector = Instance.new("ClickDetector")
	--clickDetector.MaxActivationDistance = gameRules.PickupDistance
	--clickDetector.Parent = dropModel
	--clickDetector.MouseClick:Connect(function(clicker)
		
	local clickDetector = Instance.new("ProximityPrompt")
	clickDetector.MaxActivationDistance = gameRules.PickupDistance
	clickDetector.ActionText = "Interact"
	clickDetector.KeyboardKeyCode = "F"
	--clickDetector.ObjectText = dropModel.Name
	clickDetector.Style = "Custom"
	clickDetector.Parent = dropModel
	clickDetector.Triggered:Connect(function(clicker)
		
		tool.Parent = clicker.Backpack
		dropModel:Destroy()

		local NewSound = Engine.FX.WeaponPickup:Clone()
		NewSound.Parent = clicker.Character.UpperTorso
		--NewSound.PlaybackSpeed = math.random(30,50)/40
		NewSound:Play()
		NewSound.PlayOnRemove = true
		NewSound:Destroy()
	end)

	dropModel.Parent = ACS_Workspace.DroppedGuns
	--if not RS:WaitForChild('ACS_Engine',3):WaitForChild('GunModels',3):FindFirstChild(dropModel.Name) then return end
	--local p = Instance.new("ProximityPrompt",dropModel)
	--p.ActionText = "Pick up"
	--p.ClickablePrompt = true
	--p.Enabled = true
	--p.HoldDuration = 0.5
	--p.MaxActivationDistance = 5
	--p.KeyboardKeyCode = Enum.KeyCode.E
	--p.Name = "GrabPrompt"
	--p.ObjectText = dropModel.Name
	--p.RequiresLineOfSight = true

	dropModel.Handle.Touched:Connect(function()
		if dropModel.Handle.AssemblyLinearVelocity.Magnitude > 7 then
			local DropSounds = Engine.FX.GunDrop
			local NewSound = DropSounds["GunDrop"..math.random(#DropSounds:GetChildren())]:Clone()
			NewSound.Parent = dropModel.Handle
			NewSound.PlaybackSpeed = math.random(30,50)/40
			NewSound:Play()
			NewSound.PlayOnRemove = true
			NewSound:Destroy()
		end
	end)

	if player then dropModel.Handle:SetNetworkOwner(player) end

	dropModel:SetPrimaryPartCFrame(gunPosition)

	if #ACS_Workspace.DroppedGuns:GetChildren() > gameRules.MaxDroppedWeapons then
		ACS_Workspace.DroppedGuns:GetChildren()[1]:Destroy()
	end

	if gameRules.TimeDespawn then
		Debris:AddItem(dropModel,gameRules.WeaponDespawnTime)
	end

	return dropModel
end

Evt.Shell.OnServerEvent:Connect(function(Player,Shell,Origin)
	Evt.Shell:FireAllClients(Shell,Origin)
end)

Evt.DropWeapon.OnServerEvent:Connect(function(player,tool,toolConfig)
	local tool = player.Backpack:FindFirstChild(tool.Name) or player.Character:FindFirstChild(tool.Name) 
	--print(player.Name.. " dropped a " ..tool.Name)
	--tool:Destroy()
	local NewSound = Engine.FX.WeaponDrop:Clone()
	NewSound.Parent = player.Character.UpperTorso
	--NewSound.PlaybackSpeed = math.random(30,50)/40
	NewSound:Play()
	NewSound.PlayOnRemove = true
	NewSound:Destroy()
	SpawnGun(tool.Name,player.Character.UpperTorso.CFrame * CFrame.new(0,1,-3),tool,player,toolConfig)
end)

Evt.RepAmmo.OnServerEvent:Connect(function(Player,tool,mag,ammo,chambered)
	if not tool:FindFirstChild('RepValues') then return end
	local config = tool.RepValues
	config.StoredAmmo.Value = ammo
	config.Mag.Value = mag
	config.Chambered.Value = chambered
	
	if tool.Parent:FindFirstChild("Humanoid") and tool.Parent:FindFirstChild("S"..tool.Name) then
		-- Tool is equipped
		for _, part in pairs(tool.Parent["S"..tool.Name]:GetChildren()) do
			if part.Name == "Warhead" then
				if mag > 0 then
					part.Transparency = 0
				else
					part.Transparency = 1
				end
			end
		end
	end
end)

Evt.DropAmmo.OnServerEvent:Connect(function(Player,tool,action)
	if action == "Weld" then
		local canModel = Engine.AmmoModels.AmmoBox:Clone()
		local handle = tool.Handle
		for _, part in pairs(canModel:GetChildren()) do
			if part:IsA("BasePart") and part.Name ~= "Main" then
				local newWeld = Ultil.WeldComplex(canModel.Main,part,part.Name)
				newWeld.Parent = canModel.Main
				part.Anchored = false
				part.CanCollide = true
				part.CanTouch = false
			end

			part.CollisionGroup = "Guns"

			if part.Name == "Main" then
				for _, child in pairs(part:GetChildren()) do
					if child:FindFirstChildWhichIsA("TextLabel") then
						child:FindFirstChildWhichIsA("TextLabel").Text = tool.AmmoType.Value
					end
				end
			end
		end
		local newWeld = Ultil.Weld(handle,canModel.Main,CFrame.new(0,-0.2,0),CFrame.new())
		newWeld.Name = "ToolWeld"
		newWeld.Parent = handle
		canModel.Main.Anchored = false
		handle.Anchored = false
		canModel.Parent = tool
	elseif action == "Destroy" then
		if tool:FindFirstChildWhichIsA("Model") then
			tool:FindFirstChildWhichIsA("Model"):Destroy()
			tool.Handle.ToolWeld:Destroy()
		end
	elseif action == "Drop" then
		local canModel = tool:FindFirstChildWhichIsA("Model")
		local handle = tool.Handle
		handle.ToolWeld:Destroy()
		canModel.Parent = ACS_Workspace.DroppedGuns
		canModel.Main.Touched:Connect(function(hitPart)
			if plr:GetPlayerFromCharacter(hitPart.Parent) then

				local player = plr:GetPlayerFromCharacter(hitPart.Parent)
				local f = player.Backpack:GetChildren()
				for i = 1, #f do

					if f[i]:IsA("Tool") and f[i]:FindFirstChild("ACS_Settings") then
						if tool.AmmoType.Value == "Universal" then
							Evt.Refil:FireClient(player, f[i], tool.Inf.Value, tool.Stored)
							if not canModel.Main.Sound.Playing then
								canModel.Main.Sound:Play()
							end
						elseif require(f[i].ACS_Settings).BulletType == tool.AmmoType.Value then
							Evt.Refil:FireClient(player, f[i], tool.Inf.Value, tool.Stored)
							if not canModel.Main.Sound.Playing then
								canModel.Main.Sound:Play()
							end
						end
					end
				end

				-- No more ammo
				if tool.Stored.Value <= 0 and not tool.Inf.Value then
					canModel:Destroy()
					tool:Destroy()
					return
				end
			end
		end)
		tool.Parent = nil

		local clicker = Instance.new("ClickDetector",canModel)
		clicker.MaxActivationDistance = gameRules.PickupDistance
		clicker.MouseClick:Connect(function(Player)
			--print("Give")
			tool.Parent = Player:WaitForChild("Backpack")
			canModel:Destroy()
		end)

		Debris:AddItem(canModel, gameRules.AmmoBoxDespawn)
	end
end)


for _, spawner in pairs(ACS_Workspace.WeaponSpawners:GetChildren()) do
	local constrainedValue = Instance.new("DoubleConstrainedValue")
	local maxTime = spawner.Config.WaitTime

	constrainedValue.Name = "WaitTime"
	constrainedValue.MaxValue = maxTime.Value
	constrainedValue.Value = maxTime.Value
	constrainedValue.Parent = spawner.Config

	maxTime:Destroy()
end

-- Footsteps
local stepEvent = Evt.Step
stepEvent.OnServerEvent:Connect(function(player,soundId,volume,timeStamp)
	stepEvent:FireAllClients(player,soundId,volume,timeStamp)
end)

-- Blood effects
--if gameRules.BloodSplats then
--	Mods["Realistic Blood"].Parent = game:GetService("ServerScriptService")
--end

-- Weapon spawning
function SetupSpawner(spawner)
	spawner.Transparency = 1
	spawner.Size = Vector3.new(0.2,0.2,0.2)
	spawner.CanCollide = false

	local evt = Instance.new("BindableEvent")
	evt.Name = "SpawnEvent"
	evt.Parent = spawner

	evt.Event:Connect(function()
		local newGun = SpawnGun(string.sub(spawner.Name,7),spawner.CFrame)
		newGun.Parent = spawner
	end)

	Mods.WeaponSpawn:Clone().Parent = spawner
end

for _, spawner in pairs(ACS_Workspace.WeaponSpawners:GetChildren()) do
	SetupSpawner(spawner)
end

ACS_Workspace.WeaponSpawners.ChildAdded:Connect(function(newChild)
	SetupSpawner(newChild)
end)

----------------------------------------------------------------
--\\RAPPEL SYSTEM
----------------------------------------------------------------


--// Events
local placeEvent = Evt.Rappel:WaitForChild('PlaceEvent')
local ropeEvent = Evt.Rappel:WaitForChild('RopeEvent')
local cutEvent = Evt.Rappel:WaitForChild('CutEvent')
local endEvent = Evt.Rappel:WaitForChild('EndEvent')

local rappelAssets = script.Rappel

--// Delcarables

local active = false

local TS = game:GetService("TweenService")

--// Event Connections
placeEvent.OnServerEvent:connect(function(plr,newPos,what)

	local char =	plr.Character

	if ACS_Workspace.Server:FindFirstChild(plr.Name.."_Rappel") == nil then
		local new = Instance.new('Part')
		new.Parent = workspace
		new.Anchored = true
		new.CanCollide = false
		new.Size = Vector3.new(0.2,0.2,0.2)
		new.BrickColor = BrickColor.new('Black')
		new.Material = Enum.Material.Metal
		new.Position = newPos + Vector3.new(0,new.Size.Y/2,0)
		new.Name = plr.Name.."_Rappel"

		local newW = Instance.new('WeldConstraint')
		newW.Parent = new
		newW.Part0 = new
		newW.Part1 = what
		new.Anchored = false
		
		local newAtt0 = Instance.new('Attachment')
		newAtt0.Parent = char.LowerTorso
		newAtt0.Position = Vector3.new(0,-.5,0)

		local newAtt1 = Instance.new('Attachment')
		newAtt1.Parent = new
		
		local grappelSound = rappelAssets.Grappel:Clone()
		local wireSound = rappelAssets.Wire:Clone()

		local newRope = Instance.new('RopeConstraint')
		newRope.Attachment0 = newAtt0
		newRope.Attachment1 = newAtt1
		newRope.Parent = char.LowerTorso
		newRope.Length = 20
		newRope.Restitution = 0.3
		newRope.Visible = true
		newRope.Thickness = 0.1
		newRope.Color = BrickColor.new("Black")
		
		wireSound.Parent = char.LowerTorso
		grappelSound.Parent = char.LowerTorso
		grappelSound:Destroy()
		
		placeEvent:FireClient(plr,new)
	end
end)

ropeEvent.OnServerEvent:connect(function(plr,dir)
	if workspace:FindFirstChild(plr.Name.."_Rappel") ~= nil then
		local wireSound = plr.Character.LowerTorso:FindFirstChild("Wire")
		
		if wireSound and wireSound.Playing == false then
			wireSound:Play()
		end
		
		if dir == 'Up' then
			wireSound.PlaybackSpeed = 1
			plr.Character.LowerTorso.RopeConstraint.Length = plr.Character.LowerTorso.RopeConstraint.Length + 0.4
		elseif dir == 'Down' then
			wireSound.PlaybackSpeed = 0.75
			plr.Character.LowerTorso.RopeConstraint.Length = plr.Character.LowerTorso.RopeConstraint.Length - 0.4
		end
	end
end)

endEvent.OnServerEvent:connect(function(plr)
	if workspace:FindFirstChild(plr.Name.."_Rappel") ~= nil then
		local wireSound = plr.Character.LowerTorso:FindFirstChild("Wire")
		if wireSound then
			wireSound:Stop()
		end
	end
end)

cutEvent.OnServerEvent:connect(function(plr)
	if workspace:FindFirstChild(plr.Name.."_Rappel") ~= nil then
		local cutSound = rappelAssets.Cut:Clone()
		cutSound.Parent = plr.Character.LowerTorso
		
		cutSound:Destroy()
		workspace:FindFirstChild(plr.Name.."_Rappel"):Destroy()

		plr.Character.LowerTorso.Attachment:Destroy()
		plr.Character.LowerTorso.RopeConstraint:Destroy()
		
		local wireSound = plr.Character.LowerTorso:FindFirstChild("Wire")
		if wireSound then
			wireSound:Destroy()
		end
	end
end)