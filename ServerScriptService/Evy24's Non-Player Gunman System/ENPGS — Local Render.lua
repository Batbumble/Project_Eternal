-- @ScriptType: LocalScript
local Camera = workspace.CurrentCamera
local Storage = game:GetService("ReplicatedStorage"):WaitForChild("ENPGS — Storage")
local cs = game:GetService('CollectionService')
local pl = game:GetService('Players')
local db = game:GetService('Debris')

local BallisticProjectiles = {}
local HitPart,HitPos,HitDir,HitPlayer
local RicochetData
local TracerFire
local Ricochet
local CharHit
local Shieldhit
local EndPos
local Whiz
local Time

local LimbsToHit = {"Head","UpperTorso","LeftUpperArm","RightUpperArm","LeftUpperLeg","RightUpperLeg"}

local function IsChar(Object)
	return Object and Object:IsA("Model") and Object.PrimaryPart and ((Object:FindFirstChild("Humanoid") and Object.Humanoid.Health > 0) or (Object:FindFirstChild('VecHealth') and Object.VecHealth.Value > 0))
end

local function IsNPG(Object)
	return Object and Object:FindFirstChild("Signature") and Object.Signature.ClassName == "StringValue"
		and Object.Signature.Value == "Evy24's Non-Player Gunman System" and Object:FindFirstChild("Settings") and IsChar(Object)
end

local function GetHitEffect(Material)
	if Storage.HitEffects:FindFirstChild(Material) then
		return Material
	end
	
	return "Default"
end

local function GetDamage(BodyType,BaseDamage,Distance)
	if BodyType == "Head" then
		return BaseDamage * 3
	elseif BodyType == "Torso" then
		if Distance > 300 then
			return BaseDamage * .8
		elseif Distance > 150 then
			return BaseDamage * .9
		else
			return BaseDamage
		end
	else
		if Distance > 150 then
			return BaseDamage * .6
		else
			return BaseDamage * .7
		end
	end
end

local function CreateBallisticProjectile(NPG,OriginPos,Direction,BaseDamage,MuzzleVelocity,Team,FireId,SmokeColor,LightColor,Explosive,OTU)
	local TracerFolder = Storage.Other.TracerFolder
		if (NPG.GunStat:GetAttribute("GunName") == "AcidSpit" or NPG.GunStat:GetAttribute("GunName") == "AcidSpit2") then
			TracerFire = TracerFolder.AcidFire:Clone()
		elseif (NPG.GunStat:GetAttribute("GunName") == "Ta'u Artillery Gun") then
			TracerFire = TracerFolder.PlasmaFire:Clone()
		elseif (NPG.GunStat:GetAttribute("GunName") == "Dreadnaught Plasma Cannon") then
			TracerFire = TracerFolder.ChaosPlasmaFire:Clone()
		elseif (NPG.GunStat:GetAttribute("GunName") == "Dreadnaught Cannon") then
			TracerFire = TracerFolder.BigTracerFire:Clone()
		else
			TracerFire = TracerFolder.TracerFire:Clone()
		end

		TracerFire.Parent = workspace["ENPGS — Ground Effects"]
		TracerFire.BulletSmoke.Color = SmokeColor
		TracerFire.PointLight.Color = LightColor
		TracerFire.Position = OriginPos
		table.insert(BallisticProjectiles,{
			Char = NPG,
			OriginPos = OriginPos,
			StartPos = OriginPos,
			InitialTime = tick(),
			Direction = Direction.Unit,-- * MuzzleVelocity * 3.571,
			BaseDamage = BaseDamage,
			MuzzleVelocity = MuzzleVelocity,
			TracerFire = TracerFire,
			IgnoreList = {},
			Whizzed = false,
			Team = Team,
			FireId = FireId,
			Explosive = Explosive,
			OTU = OTU,
		})


end

local function RenderStepped(DeltaTime)
	task.wait()
	for Index,BP in pairs(BallisticProjectiles) do
		Time = tick() - BP.InitialTime
		
		if Time < 4 then
			EndPos = BP.OriginPos + BP.Direction * (BP.MuzzleVelocity - Time * 10) * 3.571 * Time + Vector3.new(0,-35,0) * Time ^ 2
			
			--[[
			local CharHit = nil
			local HitPart,HitPos,HitDir = workspace:FindPartOnRayWithIgnoreList(Ray.new(BP.StartPos,EndPos - BP.StartPos),BP.IgnoreList)
			if not HitPart then return end
			if not HitPart.Parent then return end
			--if HitPart and HitPart.Parent and HitPart.Name ~= "HumanoidRootPart" then

			for _,Child in pairs(cs:GetTagged("Airzac")) do
				--for _,Child in pairs(workspace:GetChildren()) do
				if HitPart.Parent == Child then
					CharHit = Child
					break
				elseif HitPart.Parent.Name == "Arms" and HitPart.Parent.Parent.Parent == Child then
					CharHit = Child
					break
				end
			end
			
			
			
			--end
			]]--
			
			
			--[[
			
			while true do
				CharHit = nil
				HitPart,HitPos,HitDir = workspace:FindPartOnRayWithIgnoreList(Ray.new(BP.StartPos,EndPos - BP.StartPos),BP.IgnoreList)

				if HitPart and HitPart.Parent and HitPart.Name ~= "HumanoidRootPart" then
					for _,Child in pairs(workspace:GetChildren()) do
						if IsChar(Child) and (HitPart.Parent == Child or (HitPart.Parent.Name == "Arms" and HitPart.Parent.Parent == Child)) then
							CharHit = Child break
						end
					end
				end

				if not HitPart or (CharHit and (not BP.Char or CharHit ~= BP.Char)) or (not CharHit and HitPart.CanCollide and HitPart.Name ~= "HumanoidRootPart") then break end

				BP.StartPos = HitPos
				table.insert(BP.IgnoreList,HitPart)
			end
			
			]]--
			
			local HitPart,HitPos,HitDir = nil,nil,nil
			for i = 1, 5 do
			--while true do
				CharHit = nil
				Shieldhit = nil
				
				HitPart,HitPos,HitDir = workspace:FindPartOnRayWithIgnoreList(Ray.new(BP.StartPos,EndPos - BP.StartPos),BP.IgnoreList)
				if not HitPart then break end
				if not HitPart.Parent then break end
				if HitPart.Name == "HumanoidRootPart" then break end
				--if HitPart and HitPart.Parent and HitPart.Name ~= "HumanoidRootPart" then
					for _,Child in pairs(cs:GetTagged("Airzac")) do
						--if HitPart.Parent == Child then
						--	CharHit = Child
						--	break
						--elseif HitPart.Parent.Name == "Arms" and HitPart.Parent.Parent.Parent == Child then
						--	CharHit = Child
						--	break
						--end
						if IsChar(Child) and (HitPart.Parent == Child or (HitPart.Parent.Name == "Arms" and HitPart.Parent.Parent == Child)) then
							CharHit = Child break
						elseif HitPart.Parent:GetAttribute("Health") then
							Shieldhit = HitPart.Parent
						end
					end
				--end
				
				--if HitPart then
				--	if HitPart.Parent then
				--		if HitPart.Name ~= "HumanoidRootPart" then
				--			for _,Child in pairs(cs:GetTagged("Airzac")) do
				--				--if HitPart.Parent == Child then
				--				--	CharHit = Child
				--				--	break
				--				--elseif HitPart.Parent.Name == "Arms" and HitPart.Parent.Parent.Parent == Child then
				--				--	CharHit = Child
				--				--	break
				--				--end
				--				if IsChar(Child) and (HitPart.Parent == Child or (HitPart.Parent.Name == "Arms" and HitPart.Parent.Parent == Child)) then
				--					CharHit = Child break
				--				end
				--			end
				--		end
				--	end
				--end

				if not HitPart or (CharHit and (not BP.Char or CharHit ~= BP.Char)) or (not CharHit and HitPart.CanCollide and HitPart.Name ~= "HumanoidRootPart") then break end

				BP.StartPos = HitPos
				table.insert(BP.IgnoreList,HitPart)
			end

			BP.TracerFire.CFrame = CFrame.new(HitPos/2 + BP.StartPos/2,BP.StartPos) * CFrame.Angles(0,math.pi/2,0)

			--if (BP.StartPos - Camera.CFrame.Position).Magnitude < 500 then
			--	BP.TracerFire.Shape = Enum.PartType.Cylinder
			--	BP.TracerFire.Size = Vector3.new((HitPos - BP.StartPos).magnitude/2,(BP.StartPos - Camera.CFrame.Position).Magnitude/300,(BP.StartPos - Camera.CFrame.Position).Magnitude/300)
			--	if (BP.StartPos - Camera.CFrame.Position).Magnitude < 250 then
			--		if BP.StartPos == BP.OriginPos then BP.TracerFire.Transparency = 1 else BP.TracerFire.Transparency = 1 end
			--	else
			--		BP.TracerFire.Transparency = 1
			--	end
			--else
			--	BP.TracerFire.Shape = Enum.PartType.Ball
			--	BP.TracerFire.Size = Vector3.new((BP.StartPos - Camera.CFrame.Position).Magnitude/300,(BP.StartPos - Camera.CFrame.Position).Magnitude/300,(BP.StartPos - Camera.CFrame.Position).Magnitude/300)
			--	BP.TracerFire.Transparency = 1
			--end

			if CharHit then
				Storage.Events.Remote:FireServer(	
					{
						HitPart = CharHit:FindFirstChild(LimbsToHit[math.random(1,#LimbsToHit)]),
						Title = "TakeDamage",
						CharHit = CharHit,
						Team = BP.Team,
						FireId = BP.FireId,
						Damage = GetDamage(HitPart.Name,BP.BaseDamage,
						(BP.OriginPos - EndPos).Magnitude),
						Explosive = BP.Explosive,
						OTU = BP.OTU,
						C = BP.Char
					}
				)
			elseif Shieldhit then
				Storage.Events.Remote:FireServer(
					{
						Title = "ShieldDamage",
						ShieldHit = Shieldhit,
						Pos = HitPos,
						LookAt = BP.StartPos,
						Material = HitPart.Material,
						FireId = BP.FireId,
						RicochetData = RicochetData,
						Explosive = BP.Explosive,
						Damage = BP.BaseDamage,
						OTU = BP.OTU,
						C = BP.Char
					}
				)
			elseif HitPart then -- and HitPart.CanCollide then
				RicochetData = {CreateRicochet = false}

				--if BP.MuzzleVelocity > 25 and ((BP.StartPos - HitPos).Unit - HitDir).Magnitude > 1 then
				--	Storage.Other.TwoParts.PrimaryPart = nil
				--	Storage.Other.TwoParts.Part2.Position = HitPos + (BP.StartPos - HitPos).Unit
				--	Storage.Other.TwoParts.Part1.CFrame = CFrame.new(HitPos,HitPos + HitDir)
				--	Storage.Other.TwoParts.PrimaryPart = Storage.Other.TwoParts.Part1
				--	Storage.Other.TwoParts:SetPrimaryPartCFrame(Storage.Other.TwoParts:GetPrimaryPartCFrame() * CFrame.Angles(0,0,math.pi))

				--	RicochetData = {
				--		CreateRicochet = true,
				--		Title = "CreateBulletProjectile",
				--		OriginPos = Storage.Other.TwoParts.Part1.Position,
				--		Direction = (Storage.Other.TwoParts.Part2.Position - Storage.Other.TwoParts.Part1.Position + Vector3.new(math.random(-10,10)/300,math.random(-10,10)/300,math.random(-10,10)/300)).Unit,
				--		BaseDamage = BP.BaseDamage,
				--		MuzzleVelocity = BP.MuzzleVelocity/2,
				--		Team =BP.Team
				--	} 
				--end
				
				local vec = false
				local vehicle = nil
				if cs:HasTag(HitPart.Parent,"Vehicle") then
					vec = true
				end
				if not vec and cs:HasTag(HitPart.Parent.Parent,"Vehicle") then
					vec = true
				end
				if vec then
					if HitPart.Parent:FindFirstChild('VecHealth') then
						vehicle = HitPart.Parent.VecHealth
					elseif HitPart.Parent.Parent:FindFirstChild('VecHealth') then
						vehicle = HitPart.Parent.Parent.VecHealth
					end
					if vehicle and vehicle.Parent:GetAttribute('Occupied') == false then
						vehicle = nil
					end
				end
				
			
				if vehicle then
					Storage.Events.Remote:FireServer({Title = "GroundHit",Pos = HitPos,LookAt = BP.StartPos,Material = HitPart.Material,FireId = BP.FireId,RicochetData = RicochetData,Explosive = BP.Explosive,Damage = BP.BaseDamage,OTU = BP.OTU,C = BP.Char,Vehicle = vehicle})
				elseif HitPart.CanCollide then
					Storage.Events.Remote:FireServer({Title = "GroundHit",Pos = HitPos,LookAt = BP.StartPos,Material = HitPart.Material,FireId = BP.FireId,RicochetData = RicochetData,Explosive = BP.Explosive,Damage = BP.BaseDamage,OTU = BP.OTU,C = BP.Char,Vehicle = nil})
				end
			
			--elseif not BP.Whizzed and ((HitPos - Camera.CFrame.Position).Magnitude < 5 or (BP.TracerFire.Position - Camera.CFrame.Position).Magnitude < 5) then
			--	BP.Whizzed = true

			--	local EffectPart = Storage.Other.Part:Clone()
			--	EffectPart.Position = BP.TracerFire.Position

			--	Whiz = Storage.Audio.Whiz:GetChildren()[math.random(1,#Storage.Audio.Whiz:GetChildren())]:Clone()
			--	Whiz.Parent = EffectPart
			--	Whiz:Play()

			--	EffectPart.Parent = workspace["ENPGS — Ground Effects"]
			--	game:GetService("Debris"):AddItem(EffectPart,3)
			elseif BP.OTU == true then
				Storage.Events.Remote:FireServer({Title = "GroundHit",Pos = BP.Char.PrimaryPart.Position,LookAt = BP.StartPos,Material = BP.Char.PrimaryPart.Material,FireId = BP.FireId,RicochetData = RicochetData,Explosive = BP.Explosive,Damage = BP.BaseDamage,OTU = BP.OTU,C = BP.Char})
			end

			BP.StartPos = EndPos

			if CharHit or (HitPart and HitPart.CanCollide) then
				BP.TracerFire:Destroy()
				table.remove(BallisticProjectiles,Index)
			end
		else
			BP.TracerFire:Destroy()
			table.remove(BallisticProjectiles,Index)
		end
	end
	
	for _,Child in pairs(cs:GetTagged("Airzac")) do
	--for _,Child in pairs(workspace:GetChildren()) do
		if IsNPG(Child) and Child ~= nil then
			if Child:FindFirstChild("Settings") then
				Child.Settings.Combat.FlashTime.Value = math.max(Child.Settings.Combat.FlashTime.Value - DeltaTime,0)
				if Child.Settings.Combat.FlashTime.Value == 0 then
					for _,Effect in pairs(Child.Arms.GunModel.Muzzle:GetChildren()) do
						if Effect.Name ~= "Fire" then
							Effect.Enabled = false
						end
					end
				end
			end
		end
	end
	
	--wait(1)
end

local function setTwoEndPoints(part, point1, point2)
	local magnitude = (point1 - point2).magnitude
	part.Size = Vector3.new(part.Size.X, part.Size.Y, magnitude)
	part.CFrame = CFrame.new(
		point1:Lerp(point2, 0.5),
		point2
	)
	return part
end

local function OnEvent(Data)
	if Data.Title == "CreateBulletProjectile" then
		local bulletColor = Data.C.GunStat.BulletSmoke.Color
		local bulletLight = Data.C.GunStat.PointLight.Color
		local flashColor = Data.C.GunStat.FlashFX.Color
		
		if Data.C and Data.C:FindFirstChild("Arms") and Data.C.Arms:FindFirstChild("GunModel") and Data.C.Arms.GunModel:FindFirstChild("Muzzle") then
			for _,Effect in pairs(Data.C.Arms.GunModel.Muzzle:GetChildren()) do
				if Effect.Name ~= "Fire" then
					Effect.Enabled = true
				end
				if Effect.Name == "FlashFX[Flash]" then
					Effect.Color = flashColor
				end
				if Effect.Name == "FlashFX" then
					Effect.Color = bulletLight
				end
			end
			
			Data.C.Settings.Combat.FlashTime.Value = .05
		end
		CreateBallisticProjectile(Data.C,Data.OriginPos,Data.Direction,Data.BaseDamage,Data.MuzzleVelocity,Data.Team,Data.FireId,bulletColor,bulletLight,Data.Explosive,Data.OTU)
	elseif Data.Title == "HitEffect" then
		local EffectPart = Storage.Other.Part:Clone()
		EffectPart.CFrame = CFrame.new(Data.Pos,Data.LookAt)

		Ricochet = Storage.Audio.Ricochet:GetChildren()[math.random(1,#Storage.Audio.Ricochet:GetChildren())]:Clone()
		Ricochet.Parent = EffectPart
		Ricochet:Play()
		
		for _,Child in pairs(Storage.HitEffects[GetHitEffect(string.sub(tostring(Data.Material),15))]:GetChildren()) do
			Child:Clone().Parent = EffectPart
		end

		for _,Child in pairs(EffectPart:GetChildren()) do
			if Child:IsA("ParticleEmitter") then
				Child.Enabled = true
			end
		end

		EffectPart.Parent = workspace["ENPGS — Ground Effects"]
		game:GetService("Debris"):AddItem(EffectPart,5)

		wait(.25)

		for _,Child in pairs(EffectPart:GetChildren()) do
			if Child:IsA("ParticleEmitter") then
				Child.Enabled = false
			end
		end
	elseif Data.Title == "MoveIndicate" then
		if pl.LocalPlayer:GetAttribute('Zeus') == nil then return end
		if pl.LocalPlayer:GetAttribute('Zeus') == false then return end
		if Data.Char == nil then return end
		if Data.Char:FindFirstChild('MoveIndicator') then Data.Char:FindFirstChild('MoveIndicator'):Destroy() end
		if Data.Char.PrimaryPart == nil then return end
		if (Data.Pos - Data.Char.PrimaryPart.Position).Magnitude < 5 then return end
		local copy = Storage.Other.MoveIndicator:Clone()
		copy.Parent = Data.Char
		copy.Position = Data.Pos--Vector3.new(Data.Pos.X,Data.Char.PrimaryPart.Position.Y,Data.Pos.Z)
		copy.Beam.Attachment1 = Data.Char.PrimaryPart.Attachment
		db:AddItem(copy,2)
		--local copy2 = Storage.Other.MoveIndicator2:Clone()
		--copy2.Parent = copy
		--setTwoEndPoints(copy2,copy.Position,Data.Char.PrimaryPart.Position - Vector3.new(0,3,0))
	end
end

game:GetService("RunService").RenderStepped:Connect(RenderStepped)
Storage.Events.Remote.OnClientEvent:Connect(OnEvent)