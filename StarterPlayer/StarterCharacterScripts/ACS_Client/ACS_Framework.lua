-- @ScriptType: LocalScript
local RS 			= game:GetService("ReplicatedStorage")
local User 			= game:GetService("UserInputService")
local CAS 			= game:GetService("ContextActionService")
local Run 			= game:GetService("RunService")
local TS 			= game:GetService('TweenService')
local Debris 		= game:GetService("Debris")
local PhysicsService= game:GetService("PhysicsService")
local PlayersService= game:GetService("Players")

local ACS_Workspace = workspace:WaitForChild("ACS_WorkSpace")
local Engine 		= RS:WaitForChild("ACS_Engine")
local Evt 			= Engine:WaitForChild("Events")
local Mods 			= Engine:WaitForChild("Modules")
local HUDs 			= Engine:WaitForChild("HUD")
local Essential 	= Engine:WaitForChild("Essential")
local ArmModel 		= Engine:WaitForChild("ArmModel")
local GunModels 	= Engine:WaitForChild("GunModels")
local AttModels 	= Engine:WaitForChild("AttModels")
local AttModules  	= Engine:WaitForChild("AttModules")
local Rules			= Engine:WaitForChild("GameRules")
local PastaFx		= Engine:WaitForChild("FX")
local BulletFX		= Engine:WaitForChild("BulletFX")

local Lighting = game:GetService("Lighting")
local AimBlur = Lighting:WaitForChild("AimBlur")
local GunBlur = Lighting:WaitForChild("GunBlur")
local fov = 70

local gameRules		= require(Rules:WaitForChild("Config"))
local SpringMod 	= require(Mods:WaitForChild("Spring"))
local HitMod 		= require(Mods:WaitForChild("Hitmarker"))
local Thread 		= require(Mods:WaitForChild("Thread"))
local Ultil			= require(Mods:WaitForChild("Utilities"))

local plr 			= PlayersService.LocalPlayer
local char 			= plr.Character or plr.CharacterAdded:Wait()
local mouse 		= plr:GetMouse()
local cam 			= workspace.CurrentCamera
local ACS_Client 	= char:WaitForChild("ACS_Client")

local Equipped 		= 0
local Primary 		= ""
local Secondary 	= ""
local Grenades 		= ""

local Ammo
local StoredAmmo

local GreAmmo = 0

local WeaponInHand, WeaponTool, WeaponData, AnimData, PreviousTool, RepValues
local ViewModel, AnimPart, LArm, RArm, LArmWeld, RArmWeld, GunWeld
local SightData, BarrelData, UnderBarrelData, OtherData
local generateBullet = 1
local BSpread
local RecoilPower
local LastSpreadUpdate = time()
local SE_GUI
local SKP_01 = Evt.AcessId:InvokeServer(plr.UserId)

local CHup, CHdown, CHleft, CHright = UDim2.new(),UDim2.new(),UDim2.new(),UDim2.new()

local charspeed 	= 0
local running 		= false
local runKeyDown 	= false
local jogKeyDown	= false
local aimming 		= false
local shooting 		= false
local reloading 	= false
local mouse1down 	= false
local AnimDebounce 	= false
local CancelReload 	= false
local SafeMode		= false
local JumpDelay 	= false
local NVG 			= false
local NVGdebounce 	= false	
local canDrop		= false
local canPump		= false
local GunStance 	= 0
local AimPartMode 	= 1
local oldAimPartMode = 1

local SightAtt		= nil
local reticle		= nil
local CurAimpart 	= nil

local BarrelAtt 	= nil
local Suppressor 	= false
local FlashHider 	= false

local UnderBarrelAtt= nil

local OtherAtt 		= nil

local LaserAtt 		= false
local LaserActive	= false
local IRmode		= false
local IREnable		= false
local LaserDist 	= 0
local Laser 		= nil
local Pointer 		= nil

local TorchAtt 		= false
local TorchActive 	= false

local BipodAtt 		= false
local CanBipod 		= false
local BipodActive 	= false

local GRDebounce 	= false
local CookGrenade 	= false
local speedMult = 1

local canEquip = true
local ToolEquip 	= false
local Sens 			= 50
local Power 		= 100

local BipodCF 		= CFrame.new()
local NearZ 		= CFrame.new(0,0,-.5)

local tagsToggled = true

--------------------mods

local ModTable = {

	camRecoilMod 	= {
		RecoilTilt 	= 1,
		RecoilUp 	= 1,
		RecoilLeft 	= 1,
		RecoilRight = 1
	}

	,gunRecoilMod	= {
		RecoilUp 	= 1,
		RecoilTilt 	= 1,
		RecoilLeft 	= 1,
		RecoilRight = 1
	}

	,ZoomValue 		= 70
	,Zoom2Value 	= 70
	,Zoom3Value		= 70
	,AimRM 			= 1
	,SpreadRM 		= 1
	,DamageMod 		= 1
	,minDamageMod 	= 1

	,MinRecoilPower 			= 1
	,MaxRecoilPower 			= 1
	,RecoilPowerStepAmount 		= 1

	,MinSpread 					= 1
	,MaxSpread 					= 1					
	,AimInaccuracyStepAmount 	= 1
	,AimInaccuracyDecrease 		= 1
	,WalkMult 					= 1
	,adsTime 					= 0.1
	,MuzzleVelocity 			= 1
}  

--------------------mods

local maincf 		= CFrame.new() --weapon offset of camera
local guncf  		= CFrame.new() --weapon offset of camera
local larmcf 		= CFrame.new() --left arm offset of weapon
local rarmcf 		= CFrame.new() --right arm offset of weapon

local gunbobcf		= CFrame.new()
local recoilcf 		= CFrame.new()
local aimcf 		= CFrame.new()
local AimTween 		= TweenInfo.new(
	0.3,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.InOut,
	0,
	false,
	0
)

--plr.CameraMaxZoomDistance = gameRules.RegularMaxZoom

local Ignore_Model = {cam,char,ACS_Workspace.Client,ACS_Workspace.Server}

local ModStorageFolder 	= plr.PlayerGui:FindFirstChild('ModStorage') or Instance.new('Folder')
ModStorageFolder.Parent = plr.PlayerGui
ModStorageFolder.Name 	= 'ModStorage'

function RAND(Min, Max, Accuracy)
	local Inverse = 1 / (Accuracy or 1)
	return (math.random(Min * Inverse, Max * Inverse) / Inverse)
end

SE_GUI = HUDs:WaitForChild("StatusUI"):Clone()
SE_GUI.Parent = plr.PlayerGui 

local BloodScreen 		= TS:Create(SE_GUI.Efeitos.Health, TweenInfo.new(1,Enum.EasingStyle.Circular,Enum.EasingDirection.InOut,-1,true), {Size =  UDim2.new(1.2,0,1.4,0)})
local BloodScreenLowHP 	= TS:Create(SE_GUI.Efeitos.LowHealth, TweenInfo.new(1,Enum.EasingStyle.Circular,Enum.EasingDirection.InOut,-1,true), {Size =  UDim2.new(1.2,0,1.4,0)})

local Crosshair = SE_GUI.Crosshair

local RecoilSpring = SpringMod.new(Vector3.new())
RecoilSpring.d = .1
RecoilSpring.s = 20

local cameraspring = SpringMod.new(Vector3.new())
cameraspring.d	= .5
cameraspring.s	= 20

local SwaySpring = SpringMod.new(Vector3.new())
SwaySpring.d = 0.25
SwaySpring.s = 20

local Stance = Evt.Stance
local Stances = 0
local Virar = 0
local CameraX = 0
local CameraY = 0

local Sentado 		= false
local Swimming		= false
local falling 		= false
local Crouched 		= false
local Proned		= false
local Steady 		= false
local CanLean 		= true
local ChangeStance 	= true

--// Char Parts
local Humanoid = char:WaitForChild('Humanoid')
local Head = char:WaitForChild('Head')
local HumanoidRootPart = char:WaitForChild('HumanoidRootPart')
local Neck = Head:WaitForChild('Neck')

local YOffset = Neck.C0.Y
local CFAng = CFrame.Angles
local Asin = math.asin
local baseTween = TweenInfo.new(.2,Enum.EasingStyle.Linear)

local WaistYOffset = Neck.C0.Y
local CFNew, CFAng = CFrame.new, CFrame.Angles

local T = 0.15

local holdingMiddleMouse = false


User.MouseIconEnabled 	= true
if game.ReplicatedStorage.PermaDeath.Value == true then
	plr.CameraMode 			= Enum.CameraMode.LockFirstPerson
else
	plr.CameraMode 			= Enum.CameraMode.Classic
end

cam.CameraType = Enum.CameraType.Custom
cam.CameraSubject = Humanoid

if gameRules.TeamTags then
	local tag = Essential.TeamTag:clone()
	tag.Parent = char
	tag.Disabled = false
end

local ShellFolder = Instance.new("Folder",ACS_Workspace)
ShellFolder.Name = "Casings"
local Limit = gameRules.ShellLimit
local PhysService = game:GetService("PhysicsService")

function CreateShell(Shell,Origin)
	Evt.Shell:FireServer(Shell,Origin.WorldCFrame,WeaponData.EjectionOverride)
end

function SetWalkSpeed(Speed)
	if not char:FindFirstChild('Humanoid') then return end
	char.Humanoid.WalkSpeed = Speed
end

Evt.Shell.OnClientEvent:Connect(function(Shell,Origin,Override)
	if char:FindFirstChild("UpperTorso") == nil then return end
	local Distance = (char.UpperTorso.Position - Origin.Position).Magnitude
	local shellFolder
	if Engine.AmmoModels:FindFirstChild(Shell) then
		shellFolder = Engine.AmmoModels:FindFirstChild(Shell)
	else
		shellFolder = Engine.AmmoModels.Default
	end
	
	local shellStats = require(shellFolder.EjectionForce)
	
	if Distance < 100 then
		local NewShell = shellFolder.Casing:Clone()
		NewShell.Parent = ShellFolder
		NewShell.Anchored = false
		NewShell.CanCollide = true
		NewShell.CFrame = Origin * CFrame.Angles(0,math.rad(0),0)	
		NewShell.Name = Shell.."_Casing"
		NewShell.CastShadow = false
		NewShell.CustomPhysicalProperties = shellStats.PhysProperties
		NewShell.CollisionGroup = "Casings"
		local Att = Instance.new("Attachment",NewShell)
		Att.Position = shellStats.ForcePoint
		local ShellForce = Instance.new("VectorForce",NewShell)
		ShellForce.Visible = false
		
		if Override then
			ShellForce.Force = Override
		else
			ShellForce.Force = shellStats.CalculateForce()
		end
		
		ShellForce.Attachment0 = Att
		Debris:AddItem(ShellForce,0.01)

		if #ShellFolder:GetChildren() > Limit then
			ShellFolder:GetChildren()[math.random(#ShellFolder:GetChildren()/2,#ShellFolder:GetChildren())]:Destroy()
		end

		
		
		if gameRules.ShellDespawn > 0 then Debris:AddItem(NewShell,gameRules.ShellDespawn) end
		
		wait(0.25)
		if NewShell then
			if NewShell:FindFirstChild("Drop") then
				local NewSound = NewShell.Drop:Clone()
				NewSound.Parent = NewShell
				NewSound.PlaybackSpeed = math.random(30,50)/40
				NewSound:Play()
				NewSound.PlayOnRemove = true
				NewSound:Destroy()
				Debris:AddItem(NewSound,2)
			end
			local count = 0
			repeat
				wait()
				count += 1
			until NewShell.AssemblyLinearVelocity.Magnitude < 0.1 or count > 100
			NewShell.Anchored = true
			wait(0.5)
			NewShell:ClearAllChildren()
		end
	end
end)

local holdTime = 0
local jogTime = 0
local holdingR = false
local heldTime = 0

function handleAction(actionName, inputState, inputObject)

	if PreviousTool and canDrop and actionName == "DropWeapon" and inputState == Enum.UserInputState.Begin and gameRules.WeaponDropping then
		Evt.DropWeapon:FireServer(PreviousTool,require(PreviousTool.ACS_Settings))
		canDrop = false
	end

	if actionName == "Fire" and inputState == Enum.UserInputState.Begin and AnimDebounce then
		Shoot()

		if WeaponData and WeaponData.Type == "Grenade" then
			CookGrenade = true
			Grenade()
		end

	elseif actionName == "Fire" and inputState == Enum.UserInputState.End then
		mouse1down = false
		CookGrenade = false
	end
	
	if actionName == "Reload" and inputState == Enum.UserInputState.Begin and AnimDebounce and not CheckingMag and not reloading then
		--holdingR = true
		if WeaponData.Jammed then
			Jammed()
		else
			Reload()
		--	holdTime = tick()
		--	heldTime = 0
			--repeat
			--	task.wait()
			--	heldTime = tick() - holdTime
			--until heldTime > 0.7 or holdingR == false
			--if not CheckingMag and not reloading and not runKeyDown and AnimDebounce and WeaponData.CanCheckMag then
			--	CheckMagFunction()
			--	holdingR = false
			--end
		end
	end

	--if actionName == "Reload" and inputState == Enum.UserInputState.End and not CheckingMag then
	--	--holdingR = false
	--	--if heldTime <= 0.7 then
	--		Reload()
	--	--end
	--end

	--if actionName == "Reload" and inputState == Enum.UserInputState.Begin and reloading and WeaponData.ShellInsert then
	--	CancelReload = true
	--end

	if actionName == "CycleLaser" and inputState == Enum.UserInputState.Begin and LaserAtt then
		SetLaser()
	end

	if actionName == "CycleLight" and inputState == Enum.UserInputState.Begin and TorchAtt then
		SetTorch()
	end

	if actionName == "CycleFiremode" and inputState == Enum.UserInputState.Begin and WeaponData and WeaponData.FireModes.ChangeFiremode then
		Firemode()
	end

	if actionName == "CycleAimpart" and inputState == Enum.UserInputState.Begin then
		AimPartMode = oldAimPartMode
		SetAimpart()
	end

	if actionName == "ZeroUp" and inputState == Enum.UserInputState.Begin and WeaponData and WeaponData.EnableZeroing  then
		if WeaponData.CurrentZero < WeaponData.MaxZero then
			WeaponInHand.Handle.Click:play()
			WeaponData.CurrentZero = math.min(WeaponData.CurrentZero + WeaponData.ZeroIncrement, WeaponData.MaxZero) 
			UpdateGui()
		end
	end

	if actionName == "ZeroDown" and inputState == Enum.UserInputState.Begin and WeaponData and WeaponData.EnableZeroing  then
		if WeaponData.CurrentZero > 0 then
			WeaponInHand.Handle.Click:play()
			WeaponData.CurrentZero = math.max(WeaponData.CurrentZero - WeaponData.ZeroIncrement, 0) 
			UpdateGui()
		end
	end

	--if actionName == "CheckMag" and inputState == Enum.UserInputState.Begin and not CheckingMag and not reloading and not runKeyDown and AnimDebounce and WeaponData.CanCheckMag then
	--	CheckMagFunction()
	--end

	if actionName == "ToggleBipod" and inputState == Enum.UserInputState.Begin and CanBipod then

		BipodActive = not BipodActive
		UpdateGui()
	end

	if actionName == "NVG" and inputState == Enum.UserInputState.Begin and not NVGdebounce then
		if not plr.Character then return; end;
		local helmet = plr.Character:FindFirstChild("Helmet")
		if not helmet then return; end;
		local nvg = helmet:FindFirstChild("Up")
		if not nvg then return; end;
		NVGdebounce = true
		delay(.8,function()
			NVG = not NVG
			Evt.NVG:Fire(NVG)
			NVGdebounce = false		
		end)
	end

	if actionName == "ADS" and inputState == Enum.UserInputState.Begin and AnimDebounce then
		if WeaponData and WeaponData.canAim and GunStance > -2 and not runKeyDown and not CheckingMag then
			aimming = not aimming
			AimPartMode = oldAimPartMode
			ADS(aimming)
		end

		if WeaponData.Type == "Grenade" then
			GrenadeMode()
		end
	end

	if actionName == "Stand" and inputState == Enum.UserInputState.Begin and ChangeStance and not Swimming and not Sentado and not runKeyDown and not ACS_Client:GetAttribute("Collapsed") then
		if Stances == 2 then
			Crouched = true
			Proned = false
			Stances = 1
			CameraY = -1
			Crouch()


		elseif Stances == 1 then		
			Crouched = false
			Stances = 0
			CameraY = 0
			Stand()
		end	
	end

	if actionName == "Crouch" and inputState == Enum.UserInputState.Begin and ChangeStance and not Swimming and not Sentado and not runKeyDown and not ACS_Client:GetAttribute("Collapsed") then
		if Stances == 0 then
			Stances = 1
			CameraY = -0.5
			Crouch()
			Crouched = true
		elseif Stances == 1 then	
			Stances = 2
			CameraX = 0
			CameraY = -3.25
			Virar = 0
			Lean()
			Prone()
			Crouched = false
			Proned = true
		end
	end

	if actionName == "ToggleWalk" and inputState == Enum.UserInputState.Begin and ChangeStance and not runKeyDown then
		Steady = not Steady

		SE_GUI.MainFrame.Poses.Steady.Visible = Steady

		if Stances == 0 then
			Stand()
		end
	end

	if actionName == "LeanLeft" and inputState == Enum.UserInputState.Begin and Stances ~= 2 and ChangeStance and not Swimming and not runKeyDown and CanLean and not ACS_Client:GetAttribute("Collapsed") then
		if Virar == 0 or Virar == 1 then
			Virar = -1
			CameraX = -1.25
		else
			Virar = 0
			CameraX = 0
		end
		Lean()
	end

	if actionName == "LeanRight" and inputState == Enum.UserInputState.Begin and Stances ~= 2 and ChangeStance and not Swimming and not runKeyDown and CanLean and not ACS_Client:GetAttribute("Collapsed") then
		if Virar == 0 or Virar == -1 then
			Virar = 1
			CameraX = 1.25
		else
			Virar = 0
			CameraX = 0
		end
		Lean()
	end

	if actionName == "Jog" and inputState == Enum.UserInputState.Begin and running and not script.Parent:GetAttribute("Injured") then
		
		runKeyDown 	= true
		Stand()
		Stances = 0
		Virar = 0
		CameraX = 0
		CameraY = 0
		Lean()

		if aimming then
			aimming = false
			ADS(aimming)
		end

		if not CheckingMag and not reloading and (GunStance == 0 or GunStance == 2 or GunStance == 3) then
			GunStance = 3
			Evt.GunStance:FireServer(GunStance,AnimData)
			SprintAnim()
			SetWalkSpeed(char:GetAttribute("RunSpeed"))
		end

	elseif actionName == "Jog" and inputState == Enum.UserInputState.End and runKeyDown and not script.Parent:GetAttribute("Injured") then
		runKeyDown 	= false
		Stand()
		if not CheckingMag and not reloading and WeaponData and WeaponData.Type ~= "Grenade" and (GunStance == 0 or GunStance == 2 or GunStance == 3) then
			GunStance = 0
			Evt.GunStance:FireServer(GunStance,AnimData)
			IdleAnim()
			SetWalkSpeed(char:GetAttribute("WalkSpeed"))
		end
	end
end

function resetMods()

	ModTable.camRecoilMod.RecoilUp 		= 1
	ModTable.camRecoilMod.RecoilLeft 	= 1
	ModTable.camRecoilMod.RecoilRight 	= 1
	ModTable.camRecoilMod.RecoilTilt 	= 1

	ModTable.gunRecoilMod.RecoilUp 		= 1
	ModTable.gunRecoilMod.RecoilTilt 	= 1
	ModTable.gunRecoilMod.RecoilLeft 	= 1
	ModTable.gunRecoilMod.RecoilRight 	= 1

	ModTable.AimRM			= 1
	ModTable.SpreadRM 		= 1
	ModTable.DamageMod 		= 1
	ModTable.minDamageMod 	= 1

	ModTable.MinRecoilPower 		= 1
	ModTable.MaxRecoilPower 		= 1
	ModTable.RecoilPowerStepAmount 	= 1

	ModTable.MinSpread 					= 1
	ModTable.MaxSpread 					= 1
	ModTable.AimInaccuracyStepAmount 	= 1
	ModTable.AimInaccuracyDecrease 		= 1
	ModTable.WalkMult 					= 1
	ModTable.MuzzleVelocity 			= 1

end

function setMods(ModData)

	ModTable.camRecoilMod.RecoilUp 		= ModTable.camRecoilMod.RecoilUp * ModData.camRecoil.RecoilUp
	ModTable.camRecoilMod.RecoilLeft 	= ModTable.camRecoilMod.RecoilLeft * ModData.camRecoil.RecoilLeft
	ModTable.camRecoilMod.RecoilRight 	= ModTable.camRecoilMod.RecoilRight * ModData.camRecoil.RecoilRight
	ModTable.camRecoilMod.RecoilTilt 	= ModTable.camRecoilMod.RecoilTilt * ModData.camRecoil.RecoilTilt

	ModTable.gunRecoilMod.RecoilUp 		= ModTable.gunRecoilMod.RecoilUp * ModData.gunRecoil.RecoilUp
	ModTable.gunRecoilMod.RecoilTilt 	= ModTable.gunRecoilMod.RecoilTilt * ModData.gunRecoil.RecoilTilt
	ModTable.gunRecoilMod.RecoilLeft 	= ModTable.gunRecoilMod.RecoilLeft * ModData.gunRecoil.RecoilLeft
	ModTable.gunRecoilMod.RecoilRight 	= ModTable.gunRecoilMod.RecoilRight * ModData.gunRecoil.RecoilRight

	ModTable.AimRM						= ModTable.AimRM * ModData.AimRecoilReduction
	ModTable.SpreadRM 					= ModTable.SpreadRM * ModData.AimSpreadReduction
	ModTable.DamageMod 					= ModTable.DamageMod * ModData.DamageMod
	ModTable.minDamageMod 				= ModTable.minDamageMod * ModData.minDamageMod

	ModTable.MinRecoilPower 			= ModTable.MinRecoilPower * ModData.MinRecoilPower
	ModTable.MaxRecoilPower 			= ModTable.MaxRecoilPower * ModData.MaxRecoilPower
	ModTable.RecoilPowerStepAmount 		= ModTable.RecoilPowerStepAmount * ModData.RecoilPowerStepAmount

	ModTable.MinSpread 					= ModTable.MinSpread * ModData.MinSpread
	ModTable.MaxSpread 					= ModTable.MaxSpread * ModData.MaxSpread
	ModTable.AimInaccuracyStepAmount 	= ModTable.AimInaccuracyStepAmount * ModData.AimInaccuracyStepAmount
	ModTable.AimInaccuracyDecrease 		= ModTable.AimInaccuracyDecrease * ModData.AimInaccuracyDecrease
	ModTable.WalkMult 					= ModTable.WalkMult * ModData.WalkMult
	ModTable.MuzzleVelocity 			= ModTable.MuzzleVelocity * ModData.MuzzleVelocityMod
end

function loadAttachment(weapon)
	if not weapon or not weapon:FindFirstChild("Nodes") then return; end;
	--load sight Att
	if weapon.Nodes:FindFirstChild("Sight") and WeaponData.SightAtt ~= "" then

		SightData =  require(AttModules[WeaponData.SightAtt])

		SightAtt = AttModels[WeaponData.SightAtt]:Clone()
		SightAtt.Parent = weapon
		SightAtt:SetPrimaryPartCFrame(weapon.Nodes.Sight.CFrame)
		weapon.AimPart.CFrame = SightAtt.AimPos.CFrame

		reticle = SightAtt.SightMark.SurfaceGui.Border.Scope	
		if SightData.SightZoom > 0 then
			ModTable.ZoomValue = SightData.SightZoom
		end
		if SightData.SightZoom2 > 0 then
			ModTable.Zoom2Value = SightData.SightZoom2
		end
		setMods(SightData)


		for index, key in pairs(weapon:GetChildren()) do
			if key.Name ~= "IS" then continue; end;
			key.Transparency = 1
		end

		for index, key in pairs(SightAtt:GetChildren()) do
			if not key:IsA('BasePart') then continue; end;
			Ultil.Weld(weapon:WaitForChild("Handle"), key )
			key.Anchored = false
			key.CanCollide = false
		end

	end

	--load Barrel Att
	if weapon.Nodes:FindFirstChild("Barrel") ~= nil and WeaponData.BarrelAtt ~= "" then

		BarrelData =  require(AttModules[WeaponData.BarrelAtt])

		BarrelAtt = AttModels[WeaponData.BarrelAtt]:Clone()
		BarrelAtt.Parent = weapon
		BarrelAtt:SetPrimaryPartCFrame(weapon.Nodes.Barrel.CFrame)


		if BarrelAtt:FindFirstChild("BarrelPos") ~= nil then
			weapon.Handle.Muzzle.WorldCFrame = BarrelAtt.BarrelPos.CFrame
		end

		Suppressor 		= BarrelData.IsSuppressor
		FlashHider 		= BarrelData.IsFlashHider

		setMods(BarrelData)

		for index, key in pairs(BarrelAtt:GetChildren()) do
			if not key:IsA('BasePart') then continue; end;
			Ultil.Weld(weapon:WaitForChild("Handle"), key )
			key.Anchored = false
			key.CanCollide = false
		end
	end

	--load Under Barrel Att
	if weapon.Nodes:FindFirstChild("UnderBarrel") ~= nil and WeaponData.UnderBarrelAtt ~= "" then

		UnderBarrelData =  require(AttModules[WeaponData.UnderBarrelAtt])

		UnderBarrelAtt = AttModels[WeaponData.UnderBarrelAtt]:Clone()
		UnderBarrelAtt.Parent = weapon
		UnderBarrelAtt:SetPrimaryPartCFrame(weapon.Nodes.UnderBarrel.CFrame)


		setMods(UnderBarrelData)
		BipodAtt = UnderBarrelData.IsBipod

		if BipodAtt then
			CAS:BindAction("ToggleBipod", handleAction, true, gameRules.ToggleBipod)
		end

		for index, key in pairs(UnderBarrelAtt:GetChildren()) do
			if not key:IsA('BasePart') then continue; end;
			Ultil.Weld(weapon:WaitForChild("Handle"), key )
			key.Anchored = false
			key.CanCollide = false
		end
	end

	if weapon.Nodes:FindFirstChild("Other") ~= nil and WeaponData.OtherAtt ~= "" then

		OtherData =  require(AttModules[WeaponData.OtherAtt])

		OtherAtt = AttModels[WeaponData.OtherAtt]:Clone()
		OtherAtt.Parent = weapon
		OtherAtt:SetPrimaryPartCFrame(weapon.Nodes.Other.CFrame)


		setMods(OtherData)
		LaserAtt = OtherData.EnableLaser
		TorchAtt = OtherData.EnableFlashlight

		if OtherData.InfraRed then
			IREnable = true
		end

		for index, key in pairs(OtherAtt:GetChildren()) do
			if not key:IsA('BasePart') then continue; end;
			Ultil.Weld(weapon:WaitForChild("Handle"), key )
			key.Anchored = false
			key.CanCollide = false
		end
	end
end

function SetLaser()
	if gameRules.RealisticLaser and IREnable then
		if not LaserActive and not IRmode then
			LaserActive = true
			IRmode 		= true

		elseif LaserActive and IRmode then
			IRmode 		= false
		else
			LaserActive = false
			IRmode 		= false
		end
	else
		LaserActive = not LaserActive
	end

	WeaponInHand.Handle.Click:play()
	UpdateGui()

	if LaserActive then
		if Pointer then return; end;
		for index, Key in pairs(WeaponInHand:GetDescendants()) do
			if not Key:IsA("BasePart") or Key.Name ~= "LaserPoint" then continue; end;
			local LaserPointer = Instance.new('Part',Key)
			LaserPointer.Shape = 'Ball'
			LaserPointer.Size = Vector3.new(0.2, 0.2, 0.2)
			LaserPointer.CanCollide = false
			LaserPointer.Color = Key.Color
			LaserPointer.Material = Enum.Material.Neon

			local LaserSP = Instance.new('Attachment',Key)			
			local LaserEP = Instance.new('Attachment',LaserPointer)

			local Laser = Instance.new('Beam',LaserPointer)
			Laser.Transparency = NumberSequence.new(0)
			Laser.LightEmission = 1
			Laser.LightInfluence = 1
			Laser.Attachment0 = LaserSP
			Laser.Attachment1 = LaserEP
			Laser.Color = ColorSequence.new(Key.Color)
			Laser.FaceCamera = true
			Laser.Width0 = 0.01
			Laser.Width1 = 0.01

			if gameRules.RealisticLaser then
				Laser.Enabled = false
			end

			Pointer = LaserPointer
			break
		end
	else
		for index, Key in pairs(WeaponInHand:GetDescendants()) do
			if not Key:IsA("BasePart") or Key.Name ~= "LaserPoint" then continue; end;
			Key:ClearAllChildren()
			break
		end
		Pointer = nil
		if gameRules.ReplicatedLaser then
			Evt.SVLaser:FireServer(nil,2,nil,false,WeaponTool)
		end
	end
end

function SetTorch()

	TorchActive = not TorchActive

	for index, Key in pairs(WeaponInHand:GetDescendants()) do
		if not Key:IsA("BasePart") or Key.Name ~= "FlashPoint" then continue; end;
		Key.Light.Enabled = TorchActive
	end

	Evt.SVFlash:FireServer(WeaponTool,TorchActive)
	WeaponInHand.Handle.Click:play()
	UpdateGui()
end

function ToggleADS(Type)
	local ADSTween
	if WeaponData.adsTime then
		ADSTween = TweenInfo.new(WeaponData.adsTime / 20,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,WeaponData.adsTime / 10)
	else
		ADSTween = TweenInfo.new(0.2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0.2)
	end
	if Type == "REG" then
		for _, child in pairs(WeaponInHand:GetChildren()) do
			if child.Name == "REG" then
				TS:Create(child, ADSTween, {Transparency = 0}):Play()
			elseif child.Name == "ADS" then
				TS:Create(child, ADSTween, {Transparency = 1}):Play()
			end
		end
	elseif Type == "ADS" then
		for _, child in pairs(WeaponInHand:GetChildren()) do
			if child.Name == "REG" then
				TS:Create(child, ADSTween, {Transparency = 1}):Play()
			elseif child.Name == "ADS" then
				TS:Create(child, ADSTween, {Transparency = 0}):Play()
			end
		end
	end
end

function ADS(aimming)
	
	if not WeaponData or not WeaponInHand then return; end;
	if aimming then

		if SafeMode then
			SafeMode = false
			GunStance = 0
			IdleAnim()
			UpdateGui()
		end

		game:GetService('UserInputService').MouseDeltaSensitivity = (Sens/100)

		WeaponInHand.Handle.AimDown:Play()
		
		--for index, Part in pairs(WeaponInHand:GetDescendants()) do
		--	if Part:IsA("BasePart") and Part.Name == "SightMark" then
		--		Part.SurfaceGui.Enabled = true
		--	end
		--end
		
		if WeaponInHand:FindFirstChild("SightMark") then
			WeaponInHand.SightMark.SurfaceGui.Enabled = true
		end
		
		if WeaponData.ADSEnabled then
			if WeaponData.ADSEnabled[AimPartMode] then
				ToggleADS("ADS")
			end
		else
			ToggleADS("ADS")
		end

		GunStance = 2
		Evt.GunStance:FireServer(GunStance,AnimData)

		TS:Create(Crosshair.Up, baseTween, {BackgroundTransparency = 1}):Play()
		TS:Create(Crosshair.Down, baseTween, {BackgroundTransparency = 1}):Play()
		TS:Create(Crosshair.Left, baseTween, {BackgroundTransparency = 1}):Play()
		TS:Create(Crosshair.Right, baseTween, {BackgroundTransparency = 1}):Play()
		TS:Create(Crosshair.Center, baseTween, {ImageTransparency = 1}):Play()

	else
		
		if WeaponInHand:FindFirstChild("SightMark") then
			WeaponInHand.SightMark.SurfaceGui.Enabled = false
		end
		
		game:GetService('UserInputService').MouseDeltaSensitivity = 1
		WeaponInHand.Handle.AimUp:Play()
		
		ToggleADS("REG")

		GunStance = 0
		Evt.GunStance:FireServer(GunStance,AnimData)

		if  WeaponData.CrossHair then
			TS:Create(Crosshair.Up, baseTween, {BackgroundTransparency = 0}):Play()
			TS:Create(Crosshair.Down, baseTween, {BackgroundTransparency = 0}):Play()
			TS:Create(Crosshair.Left, baseTween, {BackgroundTransparency = 0}):Play()
			TS:Create(Crosshair.Right, baseTween, {BackgroundTransparency = 0}):Play()
		end

		if  WeaponData.CenterDot then
			TS:Create(Crosshair.Center, baseTween, {ImageTransparency = 0}):Play()
		else
			TS:Create(Crosshair.Center, baseTween, {ImageTransparency = 1}):Play()
		end
	end
end

function SetAimpart()
	if aimming then
		if not holdingMiddleMouse then
			if AimPartMode == 1 then
				AimPartMode = 2
				oldAimPartMode = 2
				if WeaponInHand:FindFirstChild('AimPart2') then
					CurAimpart = WeaponInHand:FindFirstChild('AimPart2')
				end 
			elseif AimPartMode == 2 then
				AimPartMode = 1
				oldAimPartMode = 1
				CurAimpart = WeaponInHand:FindFirstChild('AimPart')
			end
		end
		if WeaponData.ADSEnabled then
			if WeaponData.ADSEnabled[AimPartMode] then
				ToggleADS("ADS")
			else
				ToggleADS("REG")
			end
		end
	end
end

function Firemode()

	WeaponInHand.Handle.SafetyClick:Play()
	mouse1down = false

	---Semi Settings---		
	if WeaponData.ShootType == 1 and WeaponData.FireModes.Burst == true then
		WeaponData.ShootType = 2
	elseif WeaponData.ShootType == 1 and WeaponData.FireModes.Burst == false and WeaponData.FireModes.Auto == true then
		WeaponData.ShootType = 3
		---Burst Settings---
	elseif WeaponData.ShootType == 2 and WeaponData.FireModes.Auto == true then
		WeaponData.ShootType = 3
	elseif WeaponData.ShootType == 2 and WeaponData.FireModes.Semi == true and WeaponData.FireModes.Auto == false then
		WeaponData.ShootType = 1
		---Auto Settings---
	elseif WeaponData.ShootType == 3 and WeaponData.FireModes.Semi == true then
		WeaponData.ShootType = 1
	elseif WeaponData.ShootType == 3 and WeaponData.FireModes.Semi == false and WeaponData.FireModes.Burst == true then
		WeaponData.ShootType = 2
		---Explosive Settings---
	end
	UpdateGui()

end

function weld(model,person)
	local m = model:Clone()
	m.Parent = person
	local m2 = m.Middle
	local p = m:GetChildren()
	for i = 1, #p do
		local w = Instance.new("Weld",m2)
		w.Part0 = m2
		w.Part1 = p[i]
		w.C0 = m2.CFrame:inverse()*CFrame.new(m2.Position)
		w.C1 = p[i].CFrame:inverse()*CFrame.new(m2.Position)
	end
	local w2 = Instance.new("Weld",person[model.Name])
	w2.Part0 = person[model.Name]
	w2.Part1 = m2
	w2.C0 = CFrame.new(0,0,0)
	for i = 1, #p do
		p[i].Anchored = false
	end
	m.Name = "MorphModel"..model.Name
end


function setup(Tool)

	if not char or not Tool or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then return; end;
	if not canEquip then return end
	for i,v in pairs(char:FindFirstChild("Humanoid"):GetChildren()) do if v:IsA("IKControl") then v:Destroy() end end
	
	
	local ToolCheck 		= Tool
	local GunModelCheck 	= GunModels:FindFirstChild(Tool.Name)

	if not ToolCheck or not GunModelCheck then warn("Tool Or Gun Model Doesn't Exist") return; end;

	ToolEquip = true
	User.MouseIconEnabled 	= false
	plr.CameraMode 			= Enum.CameraMode.LockFirstPerson

	WeaponTool 		= ToolCheck
	if WeaponTool then
		PreviousTool = WeaponTool
		canDrop = true
	end
	WeaponData 		= require(Tool:FindFirstChild("ACS_Settings"))
	AnimData 		= require(Tool:FindFirstChild("ACS_Animations"))
	WeaponInHand 	= GunModelCheck:Clone()
	WeaponInHand.PrimaryPart = WeaponInHand:WaitForChild("Handle")
	
	Evt.Equip:FireServer(Tool,1,WeaponData,AnimData)
	if WeaponData.Type == "Gun" then
		WeaponInHand.Handle.AimDown:Play()
		RepValues = Tool:WaitForChild("RepValues")
	end
	ViewModel = ArmModel:WaitForChild("Arms"):Clone()
	ViewModel.Name = "Viewmodel"

	if char:WaitForChild("Body Colors") then
		local Colors = char:WaitForChild("Body Colors"):Clone()
		Colors.Parent = ViewModel
	end

	if char:FindFirstChild("Shirt") then
		local Shirt = char:FindFirstChild("Shirt"):Clone()
		Shirt.Parent = ViewModel
	end

	AnimPart = Instance.new("Part",ViewModel)
	AnimPart.Size = Vector3.new(0.1,0.1,0.1)
	AnimPart.Anchored = true
	AnimPart.CanCollide = false
	AnimPart.Transparency = 1

	ViewModel.PrimaryPart = AnimPart

	LArmWeld = Instance.new("Motor6D",AnimPart)
	LArmWeld.Name = "LeftArm"
	LArmWeld.Part0 = AnimPart

	RArmWeld = Instance.new("Motor6D",AnimPart)
	RArmWeld.Name = "RightArm"
	RArmWeld.Part0 = AnimPart

	GunWeld = Instance.new("Motor6D",AnimPart)
	GunWeld.Name = "Handle"

	--setup arms to camera

	ViewModel.Parent = cam

	if not AnimData then warn(Tool:GetFullName()) end
	maincf = AnimData.MainCFrame
	guncf = AnimData.GunCFrame

	larmcf = AnimData.LArmCFrame
	rarmcf = AnimData.RArmCFrame

	if  WeaponData.CrossHair then
		TS:Create(Crosshair.Up, baseTween, {BackgroundTransparency = 0}):Play()
		TS:Create(Crosshair.Down, baseTween, {BackgroundTransparency = 0}):Play()
		TS:Create(Crosshair.Left, baseTween, {BackgroundTransparency = 0}):Play()
		TS:Create(Crosshair.Right, baseTween, {BackgroundTransparency = 0}):Play()	

		if WeaponData.Bullets > 1 then
			Crosshair.Up.Rotation = 90
			Crosshair.Down.Rotation = 90
			Crosshair.Left.Rotation = 90
			Crosshair.Right.Rotation = 90
		else
			Crosshair.Up.Rotation = 0
			Crosshair.Down.Rotation = 0
			Crosshair.Left.Rotation = 0
			Crosshair.Right.Rotation = 0
		end

	else
		TS:Create(Crosshair.Up, baseTween, {BackgroundTransparency = 1}):Play()
		TS:Create(Crosshair.Down, baseTween, {BackgroundTransparency = 1}):Play()
		TS:Create(Crosshair.Left, baseTween, {BackgroundTransparency = 1}):Play()
		TS:Create(Crosshair.Right, baseTween, {BackgroundTransparency = 1}):Play()
	end

	if  WeaponData.CenterDot then
		TS:Create(Crosshair.Center, baseTween, {ImageTransparency = 0}):Play()
	else
		TS:Create(Crosshair.Center, baseTween, {ImageTransparency = 1}):Play()
	end

	LArm = ViewModel:WaitForChild("Left Arm")
	LArmWeld.Part1 = LArm
	LArmWeld.C0 = CFrame.new()
	LArmWeld.C1 = CFrame.new(1,-1,-5) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0)):inverse()

	RArm = ViewModel:WaitForChild("Right Arm")
	RArmWeld.Part1 = RArm
	RArmWeld.C0 = CFrame.new()
	RArmWeld.C1 = CFrame.new(-1,-1,-5) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0)):inverse()
	GunWeld.Part0 = RArm

	LArm.Anchored = false
	RArm.Anchored = false

	--setup weapon to camera
	ModTable.ZoomValue 		= WeaponData.Zoom
	ModTable.Zoom2Value 	= WeaponData.Zoom2
	ModTable.Zoom3Value 	= WeaponData.Zoom
	IREnable 				= WeaponData.InfraRed


	CAS:BindAction("Fire", handleAction, true, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)
	CAS:BindAction("ADS", handleAction, true, Enum.UserInputType.MouseButton2, Enum.KeyCode.ButtonL2) 
	CAS:BindAction("Reload", handleAction, true, gameRules.Reload, Enum.KeyCode.ButtonB)
	CAS:BindAction("CycleAimpart", handleAction, false, gameRules.SwitchSights)

	CAS:BindAction("CycleLaser", handleAction, true, gameRules.ToggleLaser)
	CAS:BindAction("CycleLight", handleAction, true, gameRules.ToggleLight)

	CAS:BindAction("CycleFiremode", handleAction, false, gameRules.FireMode)
	--CAS:BindAction("CheckMag", handleAction, false, gameRules.CheckMag)

	CAS:BindAction("ZeroDown", handleAction, false, gameRules.ZeroDown)
	CAS:BindAction("ZeroUp", handleAction, false, gameRules.ZeroUp)

	CAS:BindAction("DropWeapon", handleAction, true, gameRules.DropGun)

	loadAttachment(WeaponInHand)

	BSpread				= math.min(WeaponData.MinSpread * ModTable.MinSpread, WeaponData.MaxSpread * ModTable.MaxSpread)
	RecoilPower 		= math.min(WeaponData.MinRecoilPower * ModTable.MinRecoilPower, WeaponData.MaxRecoilPower * ModTable.MaxRecoilPower)
	
	if RepValues and RepValues.Mag and RepValues.StoredAmmo then
		Ammo = RepValues.Mag.Value
		StoredAmmo = RepValues.StoredAmmo.Value
	else
		Ammo = WeaponData.Ammo
		StoredAmmo = WeaponData.StoredAmmo
	end
	CurAimpart = WeaponInHand:FindFirstChild("AimPart")
	
	for _, cPart in pairs(WeaponInHand:GetChildren()) do
		if cPart.Name == "Warhead" and Ammo < 1 then
			cPart.Transparency = 1
		end
	end

	for index, Key in pairs(WeaponInHand:GetDescendants()) do
		if Key:IsA("BasePart") and Key.Name == "FlashPoint" then
			TorchAtt = true
		end
		if Key:IsA("BasePart") and Key.Name == "LaserPoint" then
			LaserAtt = true
		end
	end
	
	if WeaponData.Type == "Gun" and WeaponData.ShellEjectionMod then
		WeaponInHand.Bolt.SlidePull.Played:Connect(function()
			if Ammo > 0 or canPump then
				CreateShell(WeaponData.BulletType,WeaponInHand.Handle.Chamber)
				WeaponInHand.Handle.Chamber.Smoke:Emit(10)
				canPump = false
			end
		end)
	end

	if WeaponData.EnableHUD then
		SE_GUI.GunHUD.Visible = true
	end
	UpdateGui()

	for index, key in pairs(WeaponInHand:GetChildren()) do
		if key:IsA('BasePart') and key.Name ~= 'Handle' then

			if key.Name ~= "Bolt" and key.Name ~= 'Lid' and key.Name ~= "Slide" then
				Ultil.Weld(WeaponInHand:WaitForChild("Handle"), key)
			end

			if key.Name == "Bolt" or key.Name == "Slide" then
				Ultil.WeldComplex(WeaponInHand:WaitForChild("Handle"), key, key.Name)
			end;

			if key.Name == "Lid" then
				if WeaponInHand:FindFirstChild('LidHinge') then
					Ultil.Weld(key, WeaponInHand:WaitForChild("LidHinge"))
				else
					Ultil.Weld(key, WeaponInHand:WaitForChild("Handle"))
				end
			end
		end
	end;

	for L_213_forvar1, L_214_forvar2 in pairs(WeaponInHand:GetChildren()) do
		if L_214_forvar2:IsA('BasePart') then
			L_214_forvar2.Anchored = false
			L_214_forvar2.CanCollide = false
		end
	end;

	if WeaponInHand:FindFirstChild("Nodes") then
		for L_213_forvar1, L_214_forvar2 in pairs(WeaponInHand.Nodes:GetChildren()) do
			if L_214_forvar2:IsA('BasePart') then
				Ultil.Weld(WeaponInHand:WaitForChild("Handle"), L_214_forvar2)
				L_214_forvar2.Anchored = false
				L_214_forvar2.CanCollide = false
			end
		end;
	end
	if WeaponInHand and char:FindFirstChild("S"..WeaponInHand.Name) then
		for _,v in pairs(char:FindFirstChild("S"..WeaponInHand.Name):GetDescendants()) do
			if v:IsA('SurfaceGui') then
				v.Enabled = false
			end
		end
	end

	GunWeld.Part1 = WeaponInHand:WaitForChild("Handle")
	GunWeld.C1 = guncf

	--WeaponInHand:SetPrimaryPartCFrame( RArm.CFrame * guncf)

	WeaponInHand.Parent = ViewModel	
	if Ammo <= 0 and WeaponData.Type == "Gun" then
		WeaponInHand.Handle.Slide.C0 = WeaponData.SlideEx:inverse()
	end
	
	if WeaponInHand:FindFirstChild('Mag') then
		HUDs:WaitForChild('AmmoUI',10):Clone().Parent = WeaponInHand.Mag
	end
	
	if WeaponInHand:FindFirstChild("SightMark") then
		WeaponInHand.SightMark.SurfaceGui.Enabled = false
	end
	
	EquipAnim()
	if WeaponData and WeaponData.Type ~= "Grenade" then
		RunCheck()
	end
	
	if WeaponInHand and WeaponInHand:FindFirstChild('AmmoDisplay') then
		WeaponInHand:FindFirstChild('AmmoDisplay').SurfaceGui.Frame.Ammo.Text = tostring(char:WaitForChild(Tool.Name).RepValues.Mag.Value)
		WeaponInHand:FindFirstChild('AmmoDisplay').SurfaceGui.Frame.Mag.Text = math.ceil(StoredAmmo/WeaponData.Ammo)
		
		WeaponInHand:FindFirstChild('AmmoDisplay').SurfaceGui.Enabled = true
	end
	
	if WeaponInHand and char:FindFirstChild("S"..WeaponInHand.Name) then
		for _,v in pairs(char:FindFirstChild("S"..WeaponInHand.Name):GetDescendants()) do
			if v:IsA('SurfaceGui') then
				v.Enabled = false
			end
		end
	end
end

function unset()
	ToolEquip = false
	Evt.Equip:FireServer(WeaponTool,2)
	--unsetup weapon data module
	CAS:UnbindAction("Fire")
	CAS:UnbindAction("ADS")
	CAS:UnbindAction("Reload")
	CAS:UnbindAction("CycleLaser")
	CAS:UnbindAction("CycleLight")
	CAS:UnbindAction("CycleFiremode")
	CAS:UnbindAction("CycleAimpart")
	CAS:UnbindAction("ZeroUp")
	CAS:UnbindAction("ZeroDown")
	--CAS:UnbindAction("CheckMag")
	mouse1down = false
	aimming = false
	Power = 100
	TS:Create(cam,AimTween,{FieldOfView = fov}):Play()
	TS:Create(Crosshair.Up, baseTween, {BackgroundTransparency = 1}):Play()
	TS:Create(Crosshair.Down, baseTween, {BackgroundTransparency = 1}):Play()
	TS:Create(Crosshair.Left, baseTween, {BackgroundTransparency = 1}):Play()
	TS:Create(Crosshair.Right, baseTween, {BackgroundTransparency = 1}):Play()
	TS:Create(Crosshair.Center, baseTween, {ImageTransparency = 1}):Play()
	User.MouseIconEnabled = true
	game:GetService('UserInputService').MouseDeltaSensitivity = 1
	cam.CameraType = Enum.CameraType.Custom
	if game.ReplicatedStorage.PermaDeath.Value == true then
		plr.CameraMode 			= Enum.CameraMode.LockFirstPerson
	else
		plr.CameraMode 			= Enum.CameraMode.Classic
	end

	if WeaponInHand then
		
		if WeaponData.Type == "Gun" then
			local chambered = true
			if WeaponData and Ammo then
				if WeaponData.Jammed or Ammo < 1 then chambered = false end
				Evt.RepAmmo:FireServer(WeaponTool,Ammo,StoredAmmo,WeaponData.Jammed)
				--WeaponData.AmmoInGun = Ammo
				--WeaponData.StoredAmmo = StoredAmmo
			end
		end

		if ViewModel then ViewModel:Destroy() end
		ViewModel 		= nil
		WeaponInHand	= nil
		WeaponTool		= nil
		LArm 			= nil
		RArm 			= nil
		LArmWeld 		= nil
		RArmWeld 		= nil
		WeaponData 		= nil
		AnimData		= nil
		SightAtt		= nil
		reticle			= nil
		BarrelAtt 		= nil
		UnderBarrelAtt 	= nil
		OtherAtt 		= nil
		LaserAtt 		= false
		LaserActive		= false
		IRmode			= false
		TorchAtt 		= false
		TorchActive 	= false
		BipodAtt 		= false
		BipodActive 	= false
		LaserDist 		= 0
		Pointer 		= nil
		BSpread 		= nil
		RecoilPower 	= nil
		Suppressor 		= false
		FlashHider 		= false
		CancelReload 	= false
		reloading 		= false
		SafeMode		= false
		CheckingMag		= false
		GRDebounce 		= false
		CookGrenade 	= false
		GunStance 		= 0
		resetMods()
		generateBullet 	= 1
		AimPartMode 	= 1

		SE_GUI.GunHUD.Visible = false
		SE_GUI.GrenadeForce.Visible = false
		BipodCF = CFrame.new()
		if gameRules.ReplicatedLaser then
			Evt.SVLaser:FireServer(nil,2,nil,false,WeaponTool)
		end
	end

	
	RepValues = nil
end

local HalfStep = false
function HeadMovement()
	if char.Humanoid.Health > 0 and char:FindFirstChild("HumanoidRootPart") then
		local CameraDirection = char.HumanoidRootPart.CFrame:toObjectSpace(cam.CFrame).lookVector
		if Neck then
			if char.Humanoid.RigType == Enum.HumanoidRigType.R15 and char.Humanoid.Health > 0 and char.Humanoid.PlatformStand == false then
				HalfStep = not HalfStep
				local neckCFrame = CFNew(0, YOffset, 0) * CFAng(-Asin(char.UpperTorso.CFrame.lookVector.Y), -Asin(CameraDirection.X/1.15), 0) * CFAng(Asin(CameraDirection.Y), 0, 0)
				TS:Create(Neck, TweenInfo.new(.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {C0 = neckCFrame}):Play()
				if HalfStep and script:GetAttribute("Collasped") == false then
					Evt.HeadRot:FireServer(neckCFrame)
				end
			end
		end
	end
end



function renderCam()			
	cam.CFrame = cam.CFrame*CFrame.Angles(cameraspring.p.x,cameraspring.p.y,cameraspring.p.z)
end

function renderGunRecoil()			
	recoilcf = recoilcf*CFrame.Angles(RecoilSpring.p.x,RecoilSpring.p.y,RecoilSpring.p.z)
end

function Recoil()
	local vr = (math.random(WeaponData.camRecoil.camRecoilUp[1], WeaponData.camRecoil.camRecoilUp[2])/2) * ModTable.camRecoilMod.RecoilUp
	local lr = (math.random(WeaponData.camRecoil.camRecoilLeft[1], WeaponData.camRecoil.camRecoilLeft[2])) * ModTable.camRecoilMod.RecoilLeft
	local rr = (math.random(WeaponData.camRecoil.camRecoilRight[1], WeaponData.camRecoil.camRecoilRight[2])) * ModTable.camRecoilMod.RecoilRight
	local hr = (math.random(-rr, lr)/2)
	local tr = (math.random(WeaponData.camRecoil.camRecoilTilt[1], WeaponData.camRecoil.camRecoilTilt[2])/2) * ModTable.camRecoilMod.RecoilTilt

	local RecoilX = math.rad(vr * RAND( 1, 1, .1))
	local RecoilY = math.rad(hr * RAND(-1, 1, .1))
	local RecoilZ = math.rad(tr * RAND(-1, 1, .1))

	local gvr = (math.random(WeaponData.gunRecoil.gunRecoilUp[1], WeaponData.gunRecoil.gunRecoilUp[2]) /10) * ModTable.gunRecoilMod.RecoilUp
	local gdr = (math.random(1,1) * math.random(WeaponData.gunRecoil.gunRecoilTilt[1], WeaponData.gunRecoil.gunRecoilTilt[2]) /10) * ModTable.gunRecoilMod.RecoilTilt
	local glr = (math.random(WeaponData.gunRecoil.gunRecoilLeft[1], WeaponData.gunRecoil.gunRecoilLeft[2])) * ModTable.gunRecoilMod.RecoilLeft
	local grr = (math.random(WeaponData.gunRecoil.gunRecoilRight[1], WeaponData.gunRecoil.gunRecoilRight[2])) * ModTable.gunRecoilMod.RecoilRight

	local ghr = (math.random(-grr, glr)/10)	

	local ARR = WeaponData.AimRecoilReduction * ModTable.AimRM
	if jogKeyDown then gvr = gvr*1.05 end
	if BipodActive then
		cameraspring:accelerate(Vector3.new( RecoilX, RecoilY/2, 0 ))

		if not aimming then
			RecoilSpring:accelerate(Vector3.new( math.rad(.25 * gvr * RecoilPower), math.rad(.25 * ghr * RecoilPower), math.rad(.25 * gdr)))
			recoilcf = recoilcf * CFrame.new(0,0,.1) * CFrame.Angles( math.rad(.25 * gvr * RecoilPower ),math.rad(.25 * ghr * RecoilPower ),math.rad(.25 * gdr * RecoilPower ))

		else
			RecoilSpring:accelerate(Vector3.new( math.rad( .25 * gvr * RecoilPower/ARR) , math.rad(.25 * ghr * RecoilPower/ARR), math.rad(.25 * gdr/ ARR)))
			recoilcf = recoilcf * CFrame.new(0,0,.1) * CFrame.Angles( math.rad(.25 * gvr * RecoilPower/ARR ),math.rad(.25 * ghr * RecoilPower/ARR ),math.rad(.25 * gdr * RecoilPower/ARR ))
		end

		Thread:Wait(0.05)
		cameraspring:accelerate(Vector3.new(-RecoilX, -RecoilY/2, 0))

	else
		cameraspring:accelerate(Vector3.new( RecoilX , RecoilY, RecoilZ ))
		if not aimming then
			RecoilSpring:accelerate(Vector3.new( math.rad(gvr * RecoilPower), math.rad(ghr * RecoilPower), math.rad(gdr)))
			recoilcf = recoilcf * CFrame.new(0,-0.05,.1) * CFrame.Angles( math.rad( gvr * RecoilPower ),math.rad( ghr * RecoilPower ),math.rad( gdr * RecoilPower ))

		else
			RecoilSpring:accelerate(Vector3.new( math.rad(gvr * RecoilPower/ARR) , math.rad(ghr * RecoilPower/ARR), math.rad(gdr/ ARR)))
			recoilcf = recoilcf * CFrame.new(0,0,.1) * CFrame.Angles( math.rad( gvr * RecoilPower/ARR ),math.rad( ghr * RecoilPower/ARR ),math.rad( gdr * RecoilPower/ARR ))
		end
	end
end

function CheckForHumanoid(L_225_arg1)
	local L_226_ = false
	local L_227_ = nil
	if L_225_arg1 then
		if (L_225_arg1.Parent:FindFirstChildOfClass("Humanoid") or L_225_arg1.Parent.Parent:FindFirstChildOfClass("Humanoid")) then
			L_226_ = true
			if L_225_arg1.Parent:FindFirstChildOfClass('Humanoid') then
				L_227_ = L_225_arg1.Parent:FindFirstChildOfClass('Humanoid')
			elseif L_225_arg1.Parent.Parent:FindFirstChildOfClass('Humanoid') then
				L_227_ = L_225_arg1.Parent.Parent:FindFirstChildOfClass('Humanoid')
			end
		else
			L_226_ = false
		end	
	end
	return L_226_, L_227_
end

function CastRay(Bullet, Origin)
	if not Bullet then return; end;

	local Bpos = Bullet.Position
	local Bpos2 = cam.CFrame.Position

	local recast = false
	local TotalDistTraveled = 0
	local Debounce = false
	local raycastResult

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = Ignore_Model
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true

	while Bullet do
		Run.Heartbeat:Wait()
		if not Bullet.Parent then break; end;

		Bpos = Bullet.Position
		TotalDistTraveled = (Bullet.Position - Origin).Magnitude

		if TotalDistTraveled > 7000 then
			Bullet:Destroy()
			Debounce = true
			break
		end

		for _, plyr in pairs(game.Players:GetPlayers()) do
			if Debounce or plyr == plr or not plyr.Character or not plyr.Character:FindFirstChild('Head') or (plyr.Character.Head.Position - Bpos).magnitude > 25 then continue end
			--Evt.Whizz:FireServer(plyr)
			Evt.Suppression:FireServer(plyr,1,nil,nil)
			Debounce = true
		end

		-- Set an origin and directional vector
		raycastResult = workspace:Raycast(Bpos2, (Bpos - Bpos2) * 1, raycastParams)

		recast = false

		if raycastResult then
			local Hit2 = raycastResult.Instance

			if Hit2 and Hit2.Parent:IsA('Accessory') or Hit2.Parent:IsA('Hat') then
				for _,players in pairs(game.Players:GetPlayers()) do
					if players.Character then
						for i, hats in pairs(players.Character:GetChildren()) do
							if hats:IsA("Accessory") then
								table.insert(Ignore_Model, hats)
							end
						end
					end
				end
				recast = true
				CastRay(Bullet, Origin)
				break
			end

			if Hit2 and Hit2.Name == "Ignorable" or Hit2.Name == "Ignore" or Hit2.Parent.Name == "Top" or Hit2.Parent.Name == "Helmet" or Hit2.Parent.Name == "Up" or Hit2.Parent.Name == "Down" or Hit2.Parent.Name == "Face" or Hit2.Parent.Name == "Olho" or Hit2.Parent.Name == "Headset" or Hit2.Parent.Name == "Numero" or Hit2.Parent.Name == "Vest" or Hit2.Parent.Name == "Chest" or Hit2.Parent.Name == "Waist" or Hit2.Parent.Name == "Back" or Hit2.Parent.Name == "Belt" or Hit2.Parent.Name == "Leg1" or Hit2.Parent.Name == "Leg2" or Hit2.Parent.Name == "Arm1"  or Hit2.Parent.Name == "Arm2" then
				table.insert(Ignore_Model, Hit2)
				recast = true
				CastRay(Bullet, Origin)
				break
			end

			if Hit2 and Hit2.Parent.Name == "Top" or Hit2.Parent.Name == "Helmet" or Hit2.Parent.Name == "Up" or Hit2.Parent.Name == "Down" or Hit2.Parent.Name == "Face" or Hit2.Parent.Name == "Olho" or Hit2.Parent.Name == "Headset" or Hit2.Parent.Name == "Numero" or Hit2.Parent.Name == "Vest" or Hit2.Parent.Name == "Chest" or Hit2.Parent.Name == "Waist" or Hit2.Parent.Name == "Back" or Hit2.Parent.Name == "Belt" or Hit2.Parent.Name == "Leg1" or Hit2.Parent.Name == "Leg2" or Hit2.Parent.Name == "Arm1"  or Hit2.Parent.Name == "Arm2" then
				table.insert(Ignore_Model, Hit2.Parent)
				recast = true
				CastRay(Bullet, Origin)
				break
			end

			--if Hit2 and (Hit2.Transparency >= 1 or (Hit2.CanCollide == false and Hit2.CanQuery == false and not ((Hit2.Parent:FindFirstChild('Settings') or (Hit2.Parent.Parent and Hit2.Parent.Parent:FindFirstChild('Settings')))))) and Hit2.Name ~= 'Head' and Hit2.Name ~= 'Right Arm' and Hit2.Name ~= 'Left Arm' and Hit2.Name ~= 'Right Leg' and Hit2.Name ~= 'Left Leg' and Hit2.Name ~= "UpperTorso" and Hit2.Name ~= "LowerTorso" and Hit2.Name ~= "Torso" and Hit2.Name ~= "RightUpperArm" and Hit2.Name ~= "RightLowerArm" and Hit2.Name ~= "RightHand" and Hit2.Name ~= "LeftUpperArm" and Hit2.Name ~= "LeftLowerArm" and Hit2.Name ~= "LeftHand" and Hit2.Name ~= "RightUpperLeg" and Hit2.Name ~= "RightLowerLeg" and Hit2.Name ~= "RightFoot" and Hit2.Name ~= "LeftUpperLeg" and Hit2.Name ~= "LeftLowerLeg" and Hit2.Name ~= "LeftFoot" and Hit2.Name ~= 'Armor' and Hit2.Name ~= 'EShield' then
			--	print("Ignoring")
			--	table.insert(Ignore_Model, Hit2)
			--	recast = true
			--	CastRay(Bullet, Origin)
			--	break
			--end
			if Hit2 and (Hit2.Transparency >= 1 or (Hit2.CanCollide == false and Hit2.CanTouch == false)) and Hit2.Name ~= 'Head' and Hit2.Name ~= 'Right Arm' and Hit2.Name ~= 'Left Arm' and Hit2.Name ~= 'Right Leg' and Hit2.Name ~= 'Left Leg' and Hit2.Name ~= "UpperTorso" and Hit2.Name ~= "LowerTorso" and Hit2.Name ~= "Torso" and Hit2.Name ~= "RightUpperArm" and Hit2.Name ~= "RightLowerArm" and Hit2.Name ~= "RightHand" and Hit2.Name ~= "LeftUpperArm" and Hit2.Name ~= "LeftLowerArm" and Hit2.Name ~= "LeftHand" and Hit2.Name ~= "RightUpperLeg" and Hit2.Name ~= "RightLowerLeg" and Hit2.Name ~= "RightFoot" and Hit2.Name ~= "LeftUpperLeg" and Hit2.Name ~= "LeftLowerLeg" and Hit2.Name ~= "LeftFoot" and Hit2.Name ~= 'Armor' and Hit2.Name ~= 'EShield' then
				table.insert(Ignore_Model, Hit2)
				recast = true
				CastRay(Bullet, Origin)
				break
			end
			
			if Hit2 and string.sub(Hit2.Parent.Name,1,2) == "S_" then
				table.insert(Ignore_Model, Hit2)
				recast = true
				CastRay(Bullet, Origin)
				break
			end
			
			if Hit2 and Hit2.Parent.Parent:FindFirstChildOfClass('Tool') and Hit2.Parent.Name == "S"..Hit2.Parent.Parent:FindFirstChildOfClass('Tool').Name then
				table.insert(Ignore_Model, Hit2)
				recast = true
				CastRay(Bullet, Origin)
				break
			end

			if not recast then
				Bullet:Destroy()
				Debounce = true
				local FoundHuman,VitimaHuman = CheckForHumanoid(raycastResult.Instance)
				
				if WeaponData.BulletType ~= "Flame" then
					HitMod.HitEffect(Ignore_Model, raycastResult.Position, raycastResult.Instance , raycastResult.Normal, raycastResult.Material, WeaponData)
				end
				
				Evt.HitEffect:FireServer(raycastResult.Position, raycastResult.Instance , raycastResult.Normal, raycastResult.Material, WeaponData)
				
				local HitPart = raycastResult.Instance
				print(HitPart)
				TotalDistTraveled = (raycastResult.Position - Origin).Magnitude
				local vecHealth = raycastResult.Instance.Parent:FindFirstChild('VecHealth')
				if ((FoundHuman == true and VitimaHuman.Health > 0) or vecHealth) and WeaponData then
					local SKP_02 = SKP_01.."-"..plr.UserId
					if vecHealth then
						VitimaHuman = vecHealth
					end
					print(HitPart.Name)
					if HitPart.Name == "Head" or HitPart.Parent.Name == "Top" or HitPart.Parent.Name == "Headset" or HitPart.Parent.Name == "Olho" or HitPart.Parent.Name == "Face" or HitPart.Parent.Name == "Numero" then
						Evt.Damage:InvokeServer(WeaponTool, VitimaHuman, TotalDistTraveled, 1, WeaponData, ModTable, nil, nil, SKP_02,HitPart)
					elseif HitPart.Name == "Torso" or HitPart.Name == "UpperTorso" or HitPart.Name == "LowerTorso" or HitPart.Parent.Name == "Chest" or HitPart.Parent.Name == "Waist" or HitPart.Name == "Right Arm" or HitPart.Name == "Left Arm" or HitPart.Name == "RightUpperArm" or HitPart.Name == "RightLowerArm" or HitPart.Name == "RightHand" or HitPart.Name == "LeftUpperArm" or HitPart.Name == "LeftLowerArm" or HitPart.Name == "LeftHand" then				
						Evt.Damage:InvokeServer(WeaponTool, VitimaHuman, TotalDistTraveled, 2, WeaponData, ModTable, nil, nil, SKP_02,HitPart)
					elseif HitPart.Name == "Right Leg" or HitPart.Name == "Left Leg" or HitPart.Name == "RightUpperLeg" or HitPart.Name == "RightLowerLeg" or HitPart.Name == "RightFoot" or HitPart.Name == "LeftUpperLeg" or HitPart.Name == "LeftLowerLeg" or HitPart.Name == "LeftFoot" then
						Evt.Damage:InvokeServer(WeaponTool, VitimaHuman, TotalDistTraveled, 3, WeaponData, ModTable, nil, nil, SKP_02,HitPart)	
					else
						Evt.Damage:InvokeServer(WeaponTool, VitimaHuman, TotalDistTraveled, 3, WeaponData, ModTable, nil, nil, SKP_02,HitPart)	
					end	
				end
			end
			break
		end

		Bpos2 = Bpos
	end
end

local Tracers = 0
function TracerCalculation()
	if not WeaponData.Tracer and not WeaponData.BulletFlare then return false; end;

	if WeaponData.RandomTracer.Enabled then
		if math.random(1, 100) <= WeaponData.RandomTracer.Chance then return true; end;
		return false;
	end;

	if Tracers >= WeaponData.TracerEveryXShots then
		Tracers = 0;
		return true;
	end;
	Tracers = Tracers + 1;
	return false;
end;

tracerModels = Engine.TracerModels

function CreateBullet()

	local Bullet

	if WeaponData.TracerType then
		Bullet = tracerModels:FindFirstChild(WeaponData.TracerType):Clone()
		Bullet.Parent = ACS_Workspace.Client
	else
		Bullet = Instance.new("Part",ACS_Workspace.Client)
		Bullet.CanCollide = false
		Bullet.Shape = Enum.PartType.Ball
		Bullet.Transparency = 1
		Bullet.Size = Vector3.new(1,1,1)
	end

	Bullet.Name = plr.Name.."_Bullet"

	local Origin 		= WeaponInHand.Handle.Muzzle.WorldPosition
	local Direction 	= WeaponInHand.Handle.Muzzle.WorldCFrame.LookVector + (WeaponInHand.Handle.Muzzle.WorldCFrame.UpVector * (((WeaponData.BulletDrop * WeaponData.CurrentZero/4)/WeaponData.MuzzleVelocity))/2)
	local BulletCF 		= CFrame.new(Origin, Direction) 
	local WalkMul 		= WeaponData.WalkMult * ModTable.WalkMult
	local BColor 		= Color3.fromRGB(255,255,255)
	local balaspread

	if aimming and WeaponData.Bullets <= 1 then
		balaspread = CFrame.Angles(
			math.rad(RAND(-BSpread - (charspeed/1) * WalkMul, BSpread + (charspeed/1) * WalkMul) / (10 * WeaponData.AimSpreadReduction)),
			math.rad(RAND(-BSpread - (charspeed/1) * WalkMul, BSpread + (charspeed/1) * WalkMul) / (10 * WeaponData.AimSpreadReduction)),
			math.rad(RAND(-BSpread - (charspeed/1) * WalkMul, BSpread + (charspeed/1) * WalkMul) / (10 * WeaponData.AimSpreadReduction))
		)
	else
		balaspread = CFrame.Angles(
			math.rad(RAND(-BSpread - (charspeed/1) * WalkMul, BSpread + (charspeed/1) * WalkMul) / 10),
			math.rad(RAND(-BSpread - (charspeed/1) * WalkMul, BSpread + (charspeed/1) * WalkMul) / 10),
			math.rad(RAND(-BSpread - (charspeed/1) * WalkMul, BSpread + (charspeed/1) * WalkMul) / 10)
		)
	end

	Direction = balaspread * Direction

	local Visivel = TracerCalculation()

	if WeaponData.RainbowMode then
		BColor = Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))
	else
		BColor = WeaponData.TracerColor
	end

	if Visivel then
		if gameRules.ReplicatedBullets then
			Evt.ServerBullet:FireServer(Origin,Direction,WeaponData,ModTable)
		end

		if WeaponData.Tracer == true and not WeaponData.TracerType then
			local At1 = Instance.new("Attachment")
			At1.Name = "At1"
			At1.Position = Vector3.new(-(1), 0, 0)
			At1.Parent = Bullet

			local At2 = Instance.new("Attachment")
			At2.Name = "At2"
			At2.Position = Vector3.new((1), 0, 0)
			At2.Parent = Bullet

			-- First Trail (Colored)

			local Particles1 = Instance.new("Trail")
			Particles1.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0, 0);
				NumberSequenceKeypoint.new(1, 1);
			}
			)
			Particles1.WidthScale = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 25, 0);
				NumberSequenceKeypoint.new(1, 1);
			}
			)

			Particles1.Color = ColorSequence.new(BColor)
			Particles1.Texture = "rbxassetid://18822151210"
			Particles1.TextureMode = Enum.TextureMode.Stretch
			Particles1.FaceCamera = true
			Particles1.LightEmission = 1
			Particles1.MaxLength = 35
			Particles1.LightInfluence = 0
			Particles1.Lifetime = 30
			Particles1.Attachment0 = At1
			Particles1.Attachment1 = At2
			Particles1.Parent = Bullet

			-- Second Trail (White)
			local At3 = Instance.new("Attachment")
			At3.Name = "At3"
			At3.Position = Vector3.new(-(1), 0, 0)
			At3.Parent = Bullet

			local At4 = Instance.new("Attachment")
			At4.Name = "At4"
			At4.Position = Vector3.new((1), 0, 0)
			At4.Parent = Bullet

			local Particles2 = Instance.new("Trail")

			Particles2.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0, 0);
				NumberSequenceKeypoint.new(1, 1);
			}
			)

			Particles2.WidthScale = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.2, 0);
				NumberSequenceKeypoint.new(1, 1);
			}
			)

			Particles2.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
			Particles2.Texture = "rbxassetid://18822151210"
			Particles2.TextureMode = Enum.TextureMode.Stretch
			Particles2.FaceCamera = true
			Particles2.LightEmission = 1
			Particles2.MaxLength = 35
			Particles2.LightInfluence = 0
			Particles2.Lifetime = 30
			Particles2.Attachment0 = At3
			Particles2.Attachment1 = At4
			Particles2.Parent = Bullet
		end

		if WeaponData.BulletFlare == true then
			local bg = Instance.new("BillboardGui", Bullet)
			bg.Adornee = Bullet
			bg.Enabled = false
			local flashsize = math.random(275, 375)/10
			bg.Size = UDim2.new(flashsize, 0, flashsize, 0)
			bg.LightInfluence = 0
			local flash = Instance.new("ImageLabel", bg)
			flash.BackgroundTransparency = 1
			flash.Size = UDim2.new(1, 0, 1, 0)
			flash.Position = UDim2.new(0, 0, 0, 0)
			flash.Image = "http://www.roblox.com/asset/?id=1047066405"
			flash.ImageTransparency = math.random(2, 5)/15
			flash.ImageColor3 = BColor

			spawn(function()
				wait(.1)
				if Bullet:FindFirstChild("BillboardGui") ~= nil then
					Bullet.BillboardGui.Enabled = true
				end
			end)
		end

	end

	local BulletMass = Bullet:GetMass()
	local Force = Vector3.new(0,BulletMass * (196.2) - (WeaponData.BulletDrop) * (196.2), 0)
	local BF = Instance.new("BodyForce",Bullet)

	Bullet.CFrame = BulletCF
	Bullet:ApplyImpulse(Direction * WeaponData.MuzzleVelocity * ModTable.MuzzleVelocity)
	BF.Force = Force

	game.Debris:AddItem(Bullet, 5)

	CastRay(Bullet, Origin)
end


function meleeCast()

	local recast
	-- Set an origin and directional vector
	local rayOrigin 	= cam.CFrame.Position
	local rayDirection 	= cam.CFrame.LookVector * WeaponData.BladeRange

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = Ignore_Model
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true
	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)


	if raycastResult then
		local Hit2 = raycastResult.Instance

		--Check if it's a hat or accessory
		if Hit2 and Hit2.Parent:IsA('Accessory') then
			for _,players in pairs(game.Players:GetPlayers()) do
				if not players.Character then continue; end;
				for i, hats in pairs(players.Character:GetChildren()) do
					if not hats:IsA("Accessory") then continue; end;
					table.insert(Ignore_Model, hats)
				end
			end
			return meleeCast()
		end

		if Hit2 and Hit2.Name == "Ignorable" or Hit2.Name == "Ignore" or Hit2.Parent.Name == "Top" or Hit2.Parent.Name == "Helmet" or Hit2.Parent.Name == "Up" or Hit2.Parent.Name == "Down" or Hit2.Parent.Name == "Face" or Hit2.Parent.Name == "Olho" or Hit2.Parent.Name == "Headset" or Hit2.Parent.Name == "Numero" or Hit2.Parent.Name == "Vest" or Hit2.Parent.Name == "Chest" or Hit2.Parent.Name == "Waist" or Hit2.Parent.Name == "Back" or Hit2.Parent.Name == "Belt" or Hit2.Parent.Name == "Leg1" or Hit2.Parent.Name == "Leg2" or Hit2.Parent.Name == "Arm1"  or Hit2.Parent.Name == "Arm2" then
			table.insert(Ignore_Model, Hit2)
			return meleeCast()
		end

		if Hit2 and Hit2.Parent.Name == "Top" or Hit2.Parent.Name == "Helmet" or Hit2.Parent.Name == "Up" or Hit2.Parent.Name == "Down" or Hit2.Parent.Name == "Face" or Hit2.Parent.Name == "Olho" or Hit2.Parent.Name == "Headset" or Hit2.Parent.Name == "Numero" or Hit2.Parent.Name == "Vest" or Hit2.Parent.Name == "Chest" or Hit2.Parent.Name == "Waist" or Hit2.Parent.Name == "Back" or Hit2.Parent.Name == "Belt" or Hit2.Parent.Name == "Leg1" or Hit2.Parent.Name == "Leg2" or Hit2.Parent.Name == "Arm1"  or Hit2.Parent.Name == "Arm2" then
			table.insert(Ignore_Model, Hit2.Parent)
			return meleeCast()
		end

		if Hit2 and (Hit2.Transparency >= 1 or (Hit2.CanCollide == false and Hit2.CanQuery == false)) and Hit2.Name ~= 'Head' and Hit2.Name ~= 'Right Arm' and Hit2.Name ~= 'Left Arm' and Hit2.Name ~= 'Right Leg' and Hit2.Name ~= 'Left Leg' and Hit2.Name ~= "UpperTorso" and Hit2.Name ~= "LowerTorso" and Hit2.Name ~= "Torso" and Hit2.Name ~= "RightUpperArm" and Hit2.Name ~= "RightLowerArm" and Hit2.Name ~= "RightHand" and Hit2.Name ~= "LeftUpperArm" and Hit2.Name ~= "LeftLowerArm" and Hit2.Name ~= "LeftHand" and Hit2.Name ~= "RightUpperLeg" and Hit2.Name ~= "RightLowerLeg" and Hit2.Name ~= "RightFoot" and Hit2.Name ~= "LeftUpperLeg" and Hit2.Name ~= "LeftLowerLeg" and Hit2.Name ~= "LeftFoot" and Hit2.Name ~= 'Armor' and Hit2.Name ~= 'EShield' then
			table.insert(Ignore_Model, Hit2)
			return meleeCast()
		end
	end


	if not raycastResult then return; end;
	local FoundHuman,VitimaHuman = CheckForHumanoid(raycastResult.Instance)
	if WeaponData.BulletType ~= "Flame" then
		HitMod.HitEffect(Ignore_Model, raycastResult.Position, raycastResult.Instance , raycastResult.Normal, raycastResult.Material, WeaponData)
	end
	
	Evt.HitEffect:FireServer(raycastResult.Position, raycastResult.Instance , raycastResult.Normal, raycastResult.Material, WeaponData)

	local HitPart = raycastResult.Instance

	if not FoundHuman or VitimaHuman.Health <= 0 then return; end;
	local SKP_02 = SKP_01.."-"..plr.UserId

	if HitPart.Name == "Head" or HitPart.Parent.Name == "Top" or HitPart.Parent.Name == "Headset" or HitPart.Parent.Name == "Olho" or HitPart.Parent.Name == "Face" or HitPart.Parent.Name == "Numero" then
		Thread:Spawn(function()
			Evt.Damage:InvokeServer(WeaponTool, VitimaHuman, 0, 1, WeaponData, ModTable, nil, nil, SKP_02)	
		end)

	elseif HitPart.Name == "Torso" or HitPart.Name == "UpperTorso" or HitPart.Name == "LowerTorso" or HitPart.Parent.Name == "Chest" or HitPart.Parent.Name == "Waist" or HitPart.Name == "RightUpperArm" or HitPart.Name == "RightLowerArm" or HitPart.Name == "RightHand" or HitPart.Name == "LeftUpperArm" or HitPart.Name == "LeftLowerArm" or HitPart.Name == "LeftHand" then
		Thread:Spawn(function()
			Evt.Damage:InvokeServer(WeaponTool, VitimaHuman, 0, 2, WeaponData, ModTable, nil, nil, SKP_02)	
		end)

	elseif HitPart.Name == "Right Arm" or HitPart.Name == "Right Leg" or HitPart.Name == "Left Leg" or HitPart.Name == "Left Arm" or HitPart.Name == "RightUpperLeg" or HitPart.Name == "RightLowerLeg" or HitPart.Name == "RightFoot" or HitPart.Name == "LeftUpperLeg" or HitPart.Name == "LeftLowerLeg" or HitPart.Name == "LeftFoot" then
		Thread:Spawn(function()
			Evt.Damage:InvokeServer(WeaponTool, VitimaHuman, 0, 3, WeaponData, ModTable, nil, nil, SKP_02)	
		end)
	end;		
end;

function UpdateGui()
	if WeaponInHand and WeaponInHand:FindFirstChild('AmmoDisplay') then
		WeaponInHand:FindFirstChild('AmmoDisplay').SurfaceGui.Frame.Mag.Text = math.ceil(StoredAmmo/WeaponData.Ammo)
	end
	
	if not SE_GUI or not WeaponData then return; end;
	local HUD = SE_GUI.GunHUD

	HUD.NText.Text = WeaponData.gunName
	HUD.BText.Text = WeaponData.BulletType
	HUD.A.Visible = SafeMode
	HUD.Att.Silencer.Visible = Suppressor
	HUD.Att.Bipod.Visible = BipodAtt
	HUD.Sens.Text = (Sens/100)

	if WeaponData.Jammed then
		HUD.B.BackgroundColor3 = Color3.fromRGB(255,0,0)
	else
		HUD.B.BackgroundColor3 = Color3.fromRGB(255,255,255)
	end

	if Ammo > 0 then
		HUD.B.Visible = true
	else
		HUD.B.Visible = false
	end

	if WeaponData.ShootType == 1 then
		HUD.FText.Text = "Semi"
	elseif WeaponData.ShootType == 2 then
		HUD.FText.Text = "Burst"
	elseif WeaponData.ShootType == 3 then
		HUD.FText.Text = "Auto"
	elseif WeaponData.ShootType == 4 then
		HUD.FText.Text = "Pump-Action"
	elseif WeaponData.ShootType == 5 then
		HUD.FText.Text = "Bolt-Action"
	end

	if WeaponData.EnableZeroing then
		HUD.ZeText.Visible = true
		HUD.ZeText.Text = WeaponData.CurrentZero .." m"
	else
		HUD.ZeText.Visible = false
	end

	if WeaponData.MagCount then
		HUD.SAText.Text = math.ceil(StoredAmmo/WeaponData.Ammo)
		HUD.Magazines.Visible = true
		HUD.Bullets.Visible = false
	else
		HUD.SAText.Text = StoredAmmo
		HUD.Magazines.Visible = false
		HUD.Bullets.Visible = true
	end

	if LaserAtt then
		HUD.Att.Laser.Visible = true
		if LaserActive then
			if IRmode then
				TS:Create(HUD.Att.Laser, TweenInfo.new(.1,Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(0,255,0), ImageTransparency = .123}):Play()
			else
				TS:Create(HUD.Att.Laser, TweenInfo.new(.1,Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(255,255,255), ImageTransparency = .123}):Play()
			end
		else
			TS:Create(HUD.Att.Laser, TweenInfo.new(.1,Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(255,0,0), ImageTransparency = .5}):Play()
		end
	else
		HUD.Att.Laser.Visible = false
	end

	if TorchAtt then
		HUD.Att.Flash.Visible = true
		if TorchActive then
			TS:Create(HUD.Att.Flash, TweenInfo.new(.1,Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(255,255,255), ImageTransparency = .123}):Play()
		else
			TS:Create(HUD.Att.Flash, TweenInfo.new(.1,Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(255,0,0), ImageTransparency = .5}):Play()
		end
	else
		HUD.Att.Flash.Visible = false
	end

	if WeaponData.Type == "Grenade" then
		SE_GUI.GrenadeForce.Visible = true
	else
		SE_GUI.GrenadeForce.Visible = false
	end
	
end

function CheckMagFunction()

	if aimming then
		aimming = false
		ADS(aimming)
	end
	if WeaponInHand:FindFirstChild('Mag') then
		
		WeaponInHand.Mag.AmmoUI.CMText.TextTransparency = 1
		TS:Create(WeaponInHand.Mag.AmmoUI.CMText,TweenInfo.new(.25,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0),{TextTransparency = 0,TextStrokeTransparency = 0.75}):Play()
		if Ammo >= WeaponData.Ammo then
			WeaponInHand.Mag.AmmoUI.CMText.Text = "Full"
		elseif Ammo > math.floor((WeaponData.Ammo)*.75) and Ammo < WeaponData.Ammo then
			WeaponInHand.Mag.AmmoUI.CMText.Text = "Nearly full"
		elseif Ammo < math.floor((WeaponData.Ammo)*.75) and Ammo > math.floor((WeaponData.Ammo)*.5) then
			WeaponInHand.Mag.AmmoUI.CMText.Text = "Almost half"
		elseif Ammo == math.floor((WeaponData.Ammo)*.5) then
			WeaponInHand.Mag.AmmoUI.CMText.Text = "Half"
		elseif Ammo > math.ceil((WeaponData.Ammo)*.25) and Ammo <  math.floor((WeaponData.Ammo)*.5) then
			WeaponInHand.Mag.AmmoUI.CMText.Text = "Less than half"
		elseif Ammo < math.ceil((WeaponData.Ammo)*.25) and Ammo > 0 then
			WeaponInHand.Mag.AmmoUI.CMText.Text = "Almost empty"
		elseif Ammo == 0 then
			WeaponInHand.Mag.AmmoUI.CMText.Text = "Empty"
		end

		delay(.75,function()
			TS:Create(WeaponInHand.Mag.AmmoUI.CMText,TweenInfo.new(.25,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,2),{TextTransparency = 1,TextStrokeTransparency = 1}):Play()
		end)
	end
	--if SE_GUI then
	--	local HUD = SE_GUI.GunHUD

	--	TS:Create(HUD.CMText,TweenInfo.new(.25,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0),{TextTransparency = 0,TextStrokeTransparency = 0.75}):Play()

	--	if Ammo >= WeaponData.Ammo then
	--		HUD.CMText.Text = "Full"
	--	elseif Ammo > math.floor((WeaponData.Ammo)*.75) and Ammo < WeaponData.Ammo then
	--		HUD.CMText.Text = "Nearly full"
	--	elseif Ammo < math.floor((WeaponData.Ammo)*.75) and Ammo > math.floor((WeaponData.Ammo)*.5) then
	--		HUD.CMText.Text = "Almost half"
	--	elseif Ammo == math.floor((WeaponData.Ammo)*.5) then
	--		HUD.CMText.Text = "Half"
	--	elseif Ammo > math.ceil((WeaponData.Ammo)*.25) and Ammo <  math.floor((WeaponData.Ammo)*.5) then
	--		HUD.CMText.Text = "Less than half"
	--	elseif Ammo < math.ceil((WeaponData.Ammo)*.25) and Ammo > 0 then
	--		HUD.CMText.Text = "Almost empty"
	--	elseif Ammo == 0 then
	--		HUD.CMText.Text = "Empty"
	--	end

	--	delay(.25,function()
	--		TS:Create(HUD.CMText,TweenInfo.new(.25,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,5),{TextTransparency = 1,TextStrokeTransparency = 1}):Play()
	--	end)
	--end
	mouse1down 	= false
	SafeMode 	= false
	GunStance 	= 0
	Evt.GunStance:FireServer(GunStance,AnimData)
	UpdateGui()
	MagCheckAnim()
	RunCheck()
end

function Grenade()
	if GRDebounce then return; end;
	GRDebounce = true;
	GrenadeReady()

	repeat wait() until not CookGrenade;
	TossGrenade()
end

function TossGrenade()
	if not WeaponTool or not WeaponData or not GRDebounce then return; end;
	local SKP_02 = SKP_01.."-"..plr.UserId
	GrenadeThrow()
	if not WeaponTool or not WeaponData then return; end;
	if WeaponTool.Name == "Ammo Box" then Power = Power/10 end
	Evt.Grenade:FireServer(WeaponTool,WeaponData,cam.CFrame,cam.CFrame.LookVector,Power,SKP_02)
	unset()
end

function GrenadeMode()
	if Power >= 150 then
		Power = 100
		SE_GUI.GrenadeForce.Text = "Mid Throw"
		TS:Create(RArmWeld, TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = CFrame.new(-0.45, 0, -1.25) * CFrame.Angles(math.rad(-75),math.rad(130),math.rad(100)):Inverse()}):Play()
	elseif Power >= 100 then
		Power = 50
		SE_GUI.GrenadeForce.Text = "Low Throw"
		TS:Create(RArmWeld, TweenInfo.new(.2,Enum.EasingStyle.Linear), {C1 = (CFrame.new(1,-.85,-.25) * CFrame.Angles(math.rad(40),math.rad(0),math.rad(0))):inverse() }):Play()
	elseif Power >= 50 then
		Power = 150
		SE_GUI.GrenadeForce.Text = "High Throw"
		TS:Create(RArmWeld, TweenInfo.new(.2,Enum.EasingStyle.Linear), {C1 = (CFrame.new(1,-.85,-1) * CFrame.Angles(math.rad(175),math.rad(0),math.rad(0))):inverse() }):Play()
	end
end

function JamChance()
	if not WeaponData or not WeaponData.CanBreak or WeaponData.Jammed or Ammo - 1 <= 0 then return; end;
	local Jam = math.random(1000)
	if Jam > 2 then return; end;
	WeaponData.Jammed = true
	WeaponInHand.Handle.Click:Play()
end

function Jammed()
	if not WeaponData or WeaponData.Type ~= "Gun" or not WeaponData.Jammed then return; end;
	mouse1down = false
	reloading = true
	SafeMode = false
	GunStance = 0
	Evt.GunStance:FireServer(GunStance,AnimData)
	UpdateGui()

	JammedAnim()
	WeaponData.Jammed = false
	UpdateGui()
	reloading = false
	RunCheck()
end

function Reload()
	if WeaponData.Type == "Gun" and StoredAmmo > 0 and (Ammo < WeaponData.Ammo or WeaponData.IncludeChamberedBullet and Ammo < WeaponData.Ammo + 1) then

		mouse1down = false
		reloading = true
		SafeMode = false
		GunStance = 0
		Evt.GunStance:FireServer(GunStance,AnimData)
		UpdateGui()

		if WeaponData and WeaponData.ShellInsert then
			if Ammo > 0 and WeaponData then
				for i = 1,WeaponData.Ammo - Ammo do
					if StoredAmmo > 0 and Ammo < WeaponData.Ammo then
						if CancelReload then
							break
						end
						ReloadAnim()
						Ammo = Ammo + 1
						StoredAmmo = StoredAmmo - 1
						UpdateGui()
					end
				end
			else
				TacticalReloadAnim()
				Ammo = Ammo + 1
				StoredAmmo = StoredAmmo - 1
				UpdateGui()
				for i = 1,WeaponData.Ammo - Ammo do
					if StoredAmmo > 0 and WeaponData and Ammo < WeaponData.Ammo then
						if CancelReload then
							break
						end
						ReloadAnim()
						Ammo = Ammo + 1
						StoredAmmo = StoredAmmo - 1
						UpdateGui()
					end
				end

			end
		else
			if Ammo > 0 then
				ReloadAnim()
			else
				TacticalReloadAnim()
			end
			
			if WeaponData then
				if (Ammo - (WeaponData.Ammo - StoredAmmo)) < 0 then
					Ammo = Ammo + StoredAmmo
					StoredAmmo = 0

				elseif Ammo <= 0 then
					StoredAmmo = StoredAmmo - (WeaponData.Ammo - Ammo)
					Ammo = WeaponData.Ammo

				elseif Ammo > 0 and WeaponData.IncludeChamberedBullet then
					StoredAmmo = StoredAmmo - (WeaponData.Ammo - Ammo) - 1
					Ammo = WeaponData.Ammo + 1

				elseif Ammo > 0 and not WeaponData.IncludeChamberedBullet then
					StoredAmmo = StoredAmmo - (WeaponData.Ammo - Ammo)
					Ammo = WeaponData.Ammo
				end
			end
		end
		
		for _,v in pairs(workspace.CurrentCamera:WaitForChild('Viewmodel',3):GetDescendants()) do
			if v:IsA('BasePart') and v.Name == "AmmoDisplay" and v:FindFirstChild('SurfaceGui') then
				v.SurfaceGui.Frame.Ammo.Text = tostring(Ammo)
			end
		end
		
		if WeaponData.Type == "Gun" and WeaponData.IsLauncher then
			Evt.RepAmmo:FireServer(WeaponTool,Ammo,StoredAmmo,WeaponData.Jammed)
		end
		
		CancelReload = false
		reloading = false
		RunCheck()
		UpdateGui()
		
		Evt.RepAmmo:FireServer(WeaponTool,Ammo,StoredAmmo,WeaponData.Jammed)
	end
end


function GunFx()

	-- Clone and play muzzle sound
	local Muzzle = WeaponInHand.Handle.Muzzle
	
	if WeaponData.ShootType > 3 then
		canPump = true
	end

	if Suppressor then
		local newSound = Muzzle.Supressor:Clone()
		newSound.PlaybackSpeed = newSound.PlaybackSpeed + math.random(-20,20) / 1000
		newSound.Parent = Muzzle
		newSound.Name = "Firing"
		newSound:Play()
		newSound.PlayOnRemove = true
		newSound:Destroy()
	else
		local newSound = Muzzle.Fire:Clone()
		newSound.PlaybackSpeed = newSound.PlaybackSpeed + math.random(-20,20) / 1000
		newSound.Parent = Muzzle
		newSound.Name = "Firing"
		newSound:Play()
		newSound.PlayOnRemove = true
		newSound:Destroy()
	end

	if Muzzle:FindFirstChild("Echo") then
		local newSound = Muzzle.Echo:Clone()
		newSound.PlaybackSpeed = newSound.PlaybackSpeed + math.random(-20,20) / 1000
		newSound.Parent = Muzzle
		newSound.Name = "FireEcho"
		newSound:Play()
		newSound.PlayOnRemove = true
		newSound:Destroy()
	end

	if WeaponData.FlashChance and math.random(1,10) <= WeaponData.FlashChance and not FlashHider then
		if Muzzle:FindFirstChild("FlashFX") then
			Muzzle["FlashFX"].Enabled = true
			delay(0.1,function()
				if Muzzle:FindFirstChild("FlashFX") then
					Muzzle["FlashFX"].Enabled = false
				end
			end)
		end
		WeaponInHand.Handle.Muzzle["FlashFX[Flash]"]:Emit(10)
	end
	WeaponInHand.Handle.Muzzle["Smoke"]:Emit(10)

	if BSpread then
		BSpread = math.min(WeaponData.MaxSpread * ModTable.MaxSpread, BSpread + WeaponData.AimInaccuracyStepAmount * ModTable.AimInaccuracyStepAmount)
		RecoilPower =  math.min(WeaponData.MaxRecoilPower * ModTable.MaxRecoilPower, RecoilPower + WeaponData.RecoilPowerStepAmount * ModTable.RecoilPowerStepAmount)
	end

	generateBullet = generateBullet + 1
	LastSpreadUpdate = time()

	if Ammo > 0 or not WeaponData.SlideLock then
		TS:Create( WeaponInHand.Handle.Slide, TweenInfo.new(30/WeaponData.ShootRate,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,true,0), {C0 =  WeaponData.SlideEx:inverse() }):Play()
	elseif Ammo <= 0 and WeaponData.SlideLock then
		TS:Create( WeaponInHand.Handle.Slide, TweenInfo.new(30/WeaponData.ShootRate,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0), {C0 =  WeaponData.SlideEx:inverse() }):Play()
	end
	
	if WeaponData.ShootType < 4 then
		WeaponInHand.Handle.Chamber.Smoke:Emit(10)
	end

	for _, effect in pairs(WeaponInHand.Handle.Chamber:GetChildren()) do
		if effect.Name == "Shell" then
			effect:Emit(1)
		end
	end
	
end

function ShellCheck()
	if WeaponData.ShellEjectionMod and WeaponData.ShootType < 4 then
		if Engine.AmmoModels:FindFirstChild(WeaponData.BulletType) then
			CreateShell(WeaponData.BulletType,WeaponInHand.Handle.Chamber)
		else
			CreateShell("Default",WeaponInHand.Handle.Chamber)
		end
	end
end

function Shoot()
	
	if WeaponData and WeaponData.Type == "Gun" and not shooting and not reloading then

		if reloading or runKeyDown or SafeMode or CheckingMag then
			mouse1down = false
			return
		end

		if Ammo <= 0 or WeaponData.Jammed then
			WeaponInHand.Handle.Click:Play()
			mouse1down = false
			return
		end

		mouse1down = true

		delay(0, function()
			if WeaponData and WeaponData.ShootType == 1 then
				
				task.spawn(function()
					GunBlur.Enabled = true
					task.wait(0.10)
					GunBlur.Enabled = false
				end) 
				
				shooting = true	
				Evt.Atirar:FireServer(WeaponTool,Suppressor,FlashHider)
				ShellCheck()
				for _ =  1, WeaponData.Bullets do
					Thread:Spawn(CreateBullet)
				end
				Ammo = Ammo - 1
				
				for _,v in pairs(workspace.CurrentCamera:WaitForChild('Viewmodel',3):GetDescendants()) do
					if v:IsA('BasePart') and v.Name == "AmmoDisplay" and v:FindFirstChild('SurfaceGui') then
						v.SurfaceGui.Frame.Ammo.Text = tostring(Ammo)
					end
				end
				
				GunFx()
				JamChance()
				UpdateGui()
				Thread:Spawn(Recoil)
				task.wait(60/WeaponData.ShootRate)
				shooting = false

			elseif WeaponData and WeaponData.ShootType == 2 then
				for i = 1, WeaponData.BurstShot do
					if shooting or Ammo <= 0 or mouse1down == false or WeaponData.Jammed then
						break
					end
					
					task.spawn(function()
						GunBlur.Enabled = true
						task.wait(0.05)
						GunBlur.Enabled = false
					end) 
					
					shooting = true	
					Evt.Atirar:FireServer(WeaponTool,Suppressor,FlashHider)
					ShellCheck()
					for _ =  1, WeaponData.Bullets do
						Thread:Spawn(CreateBullet)
					end
					Ammo = Ammo - 1
					
					for _,v in pairs(workspace.CurrentCamera:WaitForChild('Viewmodel',3):GetDescendants()) do
						if v:IsA('BasePart') and v.Name == "AmmoDisplay" and v:FindFirstChild('SurfaceGui') then
							v.SurfaceGui.Frame.Ammo.Text = tostring(Ammo)
						end
					end
					
					GunFx()
					JamChance()
					UpdateGui()
					Thread:Spawn(Recoil)
					wait(60/WeaponData.ShootRate)
					shooting = false

				end
			elseif WeaponData and WeaponData.ShootType == 3 then
				while mouse1down do
					if shooting or Ammo <= 0 or WeaponData.Jammed then
						break
					end
					
					task.spawn(function()
						GunBlur.Enabled = true
						task.wait(0.05)
						GunBlur.Enabled = false
					end) 
					
					shooting = true	
					Evt.Atirar:FireServer(WeaponTool,Suppressor,FlashHider)
					ShellCheck()
					for _ =  1, WeaponData.Bullets do
						Thread:Spawn(CreateBullet)
					end
					Ammo = Ammo - 1
					
					for _,v in pairs(workspace.CurrentCamera:WaitForChild('Viewmodel',3):GetDescendants()) do
						if v:IsA('BasePart') and v.Name == "AmmoDisplay" and v:FindFirstChild('SurfaceGui') then
							v.SurfaceGui.Frame.Ammo.Text = tostring(Ammo)
						end
					end
					
					GunFx()
					JamChance()
					UpdateGui()
					Thread:Spawn(Recoil)
					wait(60/WeaponData.ShootRate)
					shooting = false

				end
			elseif WeaponData and WeaponData.ShootType == 4 or WeaponData and WeaponData.ShootType == 5 then
				shooting = true	
				Evt.Atirar:FireServer(WeaponTool,Suppressor,FlashHider)
				for _ =  1, WeaponData.Bullets do
					Thread:Spawn(CreateBullet)
				end
				
				task.spawn(function()
					GunBlur.Enabled = true
					task.wait(0.05)
					GunBlur.Enabled = false
				end) 
				
				Ammo = Ammo - 1
				
				for _,v in pairs(workspace.CurrentCamera:WaitForChild('Viewmodel',3):GetDescendants()) do
					if v:IsA('BasePart') and v.Name == "AmmoDisplay" and v:FindFirstChild('SurfaceGui') then
						v.SurfaceGui.Frame.Ammo.Text = tostring(Ammo)
					end
				end
				
				GunFx()
				UpdateGui()
				Thread:Spawn(Recoil)
				PumpAnim()
				RunCheck()
				shooting = false

			end
			
			if WeaponData and WeaponData.Type == "Gun" and WeaponData.IsLauncher then
				Evt.RepAmmo:FireServer(WeaponTool,Ammo,StoredAmmo,WeaponData.Jammed)
			end
		end)

	elseif WeaponData and WeaponData.Type == "Melee" and not runKeyDown then
		if not shooting then
			shooting = true
			meleeCast()
			meleeAttack()
			RunCheck()
			shooting = false
		end
	end
	
end

local L_150_ = {}

local LeanSpring = {}
LeanSpring.cornerPeek = SpringMod.new(0)
LeanSpring.cornerPeek.d = 1
LeanSpring.cornerPeek.s = 20
LeanSpring.peekFactor = math.rad(-15)
LeanSpring.dirPeek = 0

function L_150_.Update()

	LeanSpring.cornerPeek.t = LeanSpring.peekFactor * Virar
	local NewLeanCF = CFrame.fromAxisAngle(Vector3.new(0, 0, 1), LeanSpring.cornerPeek.p)
	cam.CFrame = cam.CFrame * NewLeanCF
end

game:GetService("RunService"):BindToRenderStep("Camera Update", 200, L_150_.Update)

function RunCheck()
	if runKeyDown then
		mouse1down = false
		GunStance = 3
		Evt.GunStance:FireServer(GunStance,AnimData)
		SprintAnim()
	else
		if aimming then
			GunStance = 2
			Evt.GunStance:FireServer(GunStance,AnimData)
		else
			GunStance = 0
			Evt.GunStance:FireServer(GunStance,AnimData)
		end
		IdleAnim()
	end
end

--local crouchAnim = plr.Character.Humanoid:LoadAnimation(script:WaitForChild('Crouch',3))
--local proneAnim = plr.Character.Humanoid:LoadAnimation(script:WaitForChild('Prone',3))
--local proneCrawlAnim = plr.Character.Humanoid:LoadAnimation(script:WaitForChild('ProneCrawl',3))
--local leanLeftAnim = plr.Character.Humanoid:LoadAnimation(script:WaitForChild('LeanLeft',3))
--local leanRightAnim = plr.Character.Humanoid:LoadAnimation(script:WaitForChild('LeanRight',3))
local crawling = false
local crawlLoop = nil

local movementConn = nil


function Stand()
	Stance:FireServer(Stances,Virar)
	TS:Create(char.Humanoid, TweenInfo.new(.3), {CameraOffset = Vector3.new(CameraX,CameraY,char.Humanoid.CameraOffset.Z)} ):Play()
	--crouchAnim:Stop()
	--proneAnim:Stop()
	if movementConn then
		movementConn:Disconnect()
		movementConn = nil
	end
	crawling = false
	--proneCrawlAnim:Stop()
	SE_GUI.MainFrame.Poses.Levantado.Visible = true
	SE_GUI.MainFrame.Poses.Agaixado.Visible = false
	SE_GUI.MainFrame.Poses.Deitado.Visible = false
	--Stances = 0
	--Virar = 0
	--CameraX = 0
	--CameraY = 0
	--Lean()

	if Steady then
		SetWalkSpeed(char:GetAttribute("WalkSpeed") / 2)
	else
		if script.Parent:GetAttribute("Injured") then
			SetWalkSpeed(char:GetAttribute("WalkSpeed") / 2)
		else
			SetWalkSpeed(char:GetAttribute("WalkSpeed"))
		end
	end
	char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	--IsStanced = false	

end

function Crouch()
	if ACS_Client:GetAttribute("Collapsed") then return end
	Stance:FireServer(Stances,Virar)
	TS:Create(char.Humanoid, TweenInfo.new(.3), {CameraOffset = Vector3.new(CameraX,CameraY,char.Humanoid.CameraOffset.Z)} ):Play()
	if movementConn then
		movementConn:Disconnect()
		movementConn = nil
	end
	crawling = false
	SE_GUI.MainFrame.Poses.Levantado.Visible = false
	SE_GUI.MainFrame.Poses.Agaixado.Visible = true
	SE_GUI.MainFrame.Poses.Deitado.Visible = false
	--crouchAnim:Play()
	--proneAnim:Stop()
	--proneCrawlAnim:Stop()


	if script.Parent:GetAttribute("Injured") then
		SetWalkSpeed(char:GetAttribute("WalkSpeed") / 4)
	else
		SetWalkSpeed(char:GetAttribute("WalkSpeed") / 2)
	end
	char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	--IsStanced = true	
end

function Prone()
	if ACS_Client:GetAttribute("Collapsed") then return end
	Stance:FireServer(Stances,Virar)
	TS:Create(char.Humanoid, TweenInfo.new(.3), {CameraOffset = Vector3.new(CameraX,CameraY,char.Humanoid.CameraOffset.Z)} ):Play()
	--crouchAnim:Stop()
	--proneAnim:Play()
	SE_GUI.MainFrame.Poses.Levantado.Visible = false
	SE_GUI.MainFrame.Poses.Agaixado.Visible = false
	SE_GUI.MainFrame.Poses.Deitado.Visible = true
	crawling = false
	if ACS_Client:GetAttribute("Surrender") then
		char.Humanoid.WalkSpeed = 0
	else
		SetWalkSpeed(char:GetAttribute("WalkSpeed") / 4)
	end

	char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	movementConn = char.Humanoid:GetPropertyChangedSignal('MoveDirection'):Connect(function(inp)
		if char.Humanoid.MoveDirection == Vector3.zero then
			crawling = false
		elseif not crawling then
			crawling = true
		end
	end)

	--IsStanced = true
end

function Lean()
	if ACS_Client:GetAttribute("Collapsed") then return end
	TS:Create(char.Humanoid, TweenInfo.new(.3), {CameraOffset = Vector3.new(CameraX,CameraY,char.Humanoid.CameraOffset.Z)} ):Play()
	Stance:FireServer(Stances,Virar)

	--leanRightAnim:Stop()
	--leanLeftAnim:Stop()

	if Virar == 0 then
		--leanRightAnim:Stop()
		--leanLeftAnim:Stop()
		SE_GUI.MainFrame.Poses.Esg_Left.Visible = false
		SE_GUI.MainFrame.Poses.Esg_Right.Visible = false
	elseif Virar == 1 then
		--leanRightAnim:Play()
		SE_GUI.MainFrame.Poses.Esg_Left.Visible = false
		SE_GUI.MainFrame.Poses.Esg_Right.Visible = true
	elseif Virar == -1 then
		--leanLeftAnim:Play()
		SE_GUI.MainFrame.Poses.Esg_Left.Visible = true
		SE_GUI.MainFrame.Poses.Esg_Right.Visible = false
	end
end

----------//Animation Loader\\----------

function EquipAnim()
	AnimDebounce = false
	pcall(function()
		AnimData.EquipAnim({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
	AnimDebounce = true
end


function IdleAnim()
	pcall(function()
		AnimData.IdleAnim({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
	AnimDebounce = true
end

function SprintAnim()
	AnimDebounce = false
	pcall(function()
		AnimData.SprintAnim({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

function HighReady()
	pcall(function()
		AnimData.HighReady({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

function LowReady()
	pcall(function()
		AnimData.LowReady({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

function Patrol()
	pcall(function()
		AnimData.Patrol({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

function ReloadAnim()
	pcall(function()
		AnimData.ReloadAnim({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

function TacticalReloadAnim()
	--pcall(function()
		AnimData.TacticalReloadAnim({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	--end)
end

function JammedAnim()
	pcall(function()
		AnimData.JammedAnim({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

function PumpAnim()
	reloading = true
	pcall(function()
		AnimData.PumpAnim({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
	reloading = false
end

function MagCheckAnim()
	CheckingMag = true
	pcall(function()
		AnimData.MagCheck({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
	CheckingMag = false
end

function meleeAttack()
	pcall(function()
		AnimData.meleeAttack({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

function GrenadeReady()
	pcall(function()
		AnimData.GrenadeReady({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

function GrenadeThrow()
	pcall(function()
		AnimData.GrenadeThrow({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end
----------//Animation Loader\\----------

----------//KeyBinds\\----------
--CAS:BindAction("NVG", handleAction, false, gameRules.ToggleNVG)

function BindActions()
	--CAS:BindAction("Run", handleAction, false, gameRules.Sprint)
	CAS:BindAction("Jog", handleAction, false, gameRules.Jog)
	CAS:BindAction("Stand", handleAction, false, gameRules.StandUp)
	CAS:BindAction("Crouch", handleAction, false, gameRules.Crouch)

	CAS:BindAction("ToggleWalk", handleAction, false, gameRules.SlowWalk)
	CAS:BindAction("LeanLeft", handleAction, false, gameRules.LeanLeft)
	CAS:BindAction("LeanRight", handleAction, false, gameRules.LeanRight)
end

function UnBindActions()
	CAS:UnbindAction("Run")
	--CAS:UnbindAction("Jog")
	CAS:UnbindAction("Stand")
	CAS:UnbindAction("Crouch")

	CAS:UnbindAction("ToggleWalk")
	CAS:UnbindAction("LeanLeft")
	CAS:UnbindAction("LeanRight")
end
BindActions()
----------//KeyBinds\\----------

----------//Gun System\\----------

char.ChildAdded:connect(function(Tool)
	
	if Tool:IsA("Tool") and not Tool:FindFirstChild("ACS_Settings") then
		PreviousTool = nil
		canDrop = false
	end
	
	if Tool:IsA('Tool') and Humanoid.Health > 0 and not ToolEquip and Tool:FindFirstChild("ACS_Settings") ~= nil and (require(Tool.ACS_Settings).Type == 'Gun' or require(Tool.ACS_Settings).Type == 'Melee' or require(Tool.ACS_Settings).Type == 'Grenade') then
		local L_370_ = true
		for i,v in pairs(char:FindFirstChild("Humanoid"):GetChildren()) do if v:IsA("IKControl") then v:Destroy() end end
		if char:WaitForChild("Humanoid").Sit then
			if char.Humanoid.SeatPart:IsA("VehicleSeat") and not gameRules.EquipInVehicleSeat and char:WaitForChild("Humanoid").SeatPart.Name ~= "Hoverboard" then 
				L_370_ = false
			elseif char.Humanoid.SeatPart:IsA("Seat") and not gameRules.EquipInSeat then
				L_370_ = false
			end
		end

		if L_370_ then
			if not ToolEquip then
				--pcall(function()
				setup(Tool)
				--end)

			elseif ToolEquip then
				pcall(function()
					unset()
					setup(Tool)
				end)
			end;
		end;
		
		for _,v in pairs(Tool:GetDescendants()) do
			if not v:IsA('SurfaceGui') then continue end
			v.Enabled = false
		end
	end
	if char:GetAttribute("WalkSpeed") then
		SetWalkSpeed(char:GetAttribute("WalkSpeed"))
	end
end)

char.PrimaryPart.ChildAdded:Connect(function(child)
	if child:IsA('AlignPosition') and child.Name == "ADONIS_FLIGHT_POSITION" then
		UnBindActions()
	end
end)

char.PrimaryPart.ChildRemoved:Connect(function(child)
	if child:IsA('AlignPosition') and child.Name == "ADONIS_FLIGHT_POSITION" then
		BindActions()
	end
end)

char.ChildRemoved:connect(function(Tool)
	if Tool == WeaponTool then
		if ToolEquip then
			unset()
		end
	end
end)

Humanoid.Running:Connect(function(speed)
	charspeed = speed
	if speed > 0.1 then
		running = true
	else
		running = false
	end
end)

--Humanoid.Swimming:Connect(function(speed)
--	if Swimming then
--		charspeed = speed
--		if speed > 0.1 then
--			running = true
--		else
--			running = false
--		end
--	end
--end)

Humanoid.Died:Connect(function(speed)
	TS:Create(char.Humanoid, TweenInfo.new(1), {CameraOffset = Vector3.new(0,0,0)} ):Play()
	ChangeStance = false
	Stand()
	Stances = 0
	Virar = 0
	CameraX = 0
	CameraY = 0
	Lean()
	Equipped = 0
	unset()
	Evt.Down:FireServer()
	Evt.NVG:Fire(false)
end)

Humanoid.Seated:Connect(function(IsSeated, Seat)

	if IsSeated and Seat and (Seat:IsA("VehicleSeat") or Seat:IsA("Seat")) then
		if not gameRules.EquipInVehicleSeat and Seat.Name ~= "Hoverboard" then
			unset()
			UnBindActions()
			Humanoid:UnequipTools()
			--AimBlur.Enabled = false
		end
		CanLean = false
		--plr.CameraMaxZoomDistance = gameRules.VehicleMaxZoom
		
		if gameRules.DisableInSeat then
			UnBindActions()
		end
	else
		if gameRules.DisableInSeat then
			BindActions()
		end
		Proned = false
		Crouched = false
		--plr.CameraMaxZoomDistance = gameRules.RegularMaxZoom
	end

	if IsSeated  then
		Sentado = true
		Stances = 0
		Virar = 0
		CameraX = 0
		CameraY = 0
		Stand()
		Lean()
	else
		Sentado = false
		CanLean = true
	end
end)

Humanoid.Changed:connect(function(Property)
	if not  gameRules.AntiBunnyHop then return; end;
	if Property == "Jump" and Humanoid.Sit == true and Humanoid.SeatPart ~= nil then
		Humanoid.Sit = false
		BindActions()
	elseif Property == "Jump" and Humanoid.Sit == false then
		if JumpDelay then
			Humanoid.Jump = false
			return false
		end
		JumpDelay = true
		delay(0, function()
			wait(gameRules.JumpCoolDown)
			JumpDelay = false
		end)
	end
end)

Humanoid.StateChanged:connect(function(Old,state)
	if state == Enum.HumanoidStateType.Swimming then
		Swimming = true
		Stances = 0
		Virar = 0
		CameraX = 0
		CameraY = 0
		Stand()
		Lean()
	else
		Swimming = false
	end
	
	if state == Enum.HumanoidStateType.Climbing then
		canEquip = false
		--unset()
	else
		canEquip = true
	end
	
	if gameRules.EnableFallDamage then
		if state == Enum.HumanoidStateType.Freefall and not falling then
			canEquip = false
			falling = true
			local curVel = 0
			local peak = 0

			while falling do
				curVel = HumanoidRootPart.Velocity.magnitude
				peak = peak + 1
				Thread:Wait()
			end
			local damMult = gameRules.DamageMult
			if plr.Character and plr.Character:GetAttribute('Rapelling') == true then
				damMult = damMult/10
			end
			local damage = (curVel - (gameRules.MaxVelocity)) * damMult
			if plr.Character:GetAttribute("Body") == "Spartan" then
				damage = (curVel - (gameRules.MaxVelocity) * (damMult/4))
			end
			if damage > 5 and peak > 20 then
				local SKP_02 = SKP_01.."-"..plr.UserId

				cameraspring:accelerate(Vector3.new(-damage/20, 0, math.random(-damage, damage)/5))
				SwaySpring:accelerate(Vector3.new( math.random(-damage, damage)/5, damage/5,0))

				local hurtSound = PastaFx.FallDamage:Clone()
				hurtSound.Parent = plr.PlayerGui
				hurtSound.Volume = damage/Humanoid.MaxHealth
				hurtSound:Play()
				Debris:AddItem(hurtSound,hurtSound.TimeLength)

				Evt.Damage:InvokeServer(nil, nil, nil, nil, nil, nil, true, damage, SKP_02)

			end
		elseif state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.Dead then
			falling = false
			SwaySpring:accelerate(Vector3.new(0, 2.5, 0))
		end
	end

end)

mouse.WheelBackward:Connect(function() -- fires when the wheel goes forwards

	if ToolEquip and not CheckingMag and not aimming and not reloading and not runKeyDown and AnimDebounce and WeaponData.Type == "Gun" then
		mouse1down = false
		if GunStance == 0 then
			SafeMode = true
			GunStance = -1
			UpdateGui()
			Evt.GunStance:FireServer(GunStance,AnimData)
			LowReady()
		elseif GunStance == -1 then
			SafeMode = true
			GunStance = -2
			UpdateGui()
			Evt.GunStance:FireServer(GunStance,AnimData)
			Patrol()
		elseif GunStance == 1 then
			SafeMode = false
			GunStance = 0
			UpdateGui()
			Evt.GunStance:FireServer(GunStance,AnimData)
			IdleAnim()
		end
	end
	if ToolEquip and aimming then
		if holdingMiddleMouse then
			AimPartMode = 3
			ModTable.Zoom3Value = math.clamp(ModTable.Zoom3Value + 8,math.min(ModTable.ZoomValue,ModTable.Zoom2Value),fov)
		end
		if Sens > 5 and not holdingMiddleMouse then
			Sens = Sens - 5
			UpdateGui()
			game:GetService('UserInputService').MouseDeltaSensitivity = (Sens/100)
		end
	end

end)


mouse.WheelForward:Connect(function() -- fires when the wheel goes backwards

	if ToolEquip and not CheckingMag and not aimming and not reloading and not runKeyDown and AnimDebounce and WeaponData.Type == "Gun" then
		mouse1down = false
		if GunStance == 0 then
			SafeMode = true
			GunStance = 1
			UpdateGui()
			Evt.GunStance:FireServer(GunStance,AnimData)
			HighReady()
		elseif GunStance == -1 then
			SafeMode = false
			GunStance = 0
			UpdateGui()
			Evt.GunStance:FireServer(GunStance,AnimData)
			IdleAnim()
		elseif GunStance == -2 then
			SafeMode = true
			GunStance = -1
			UpdateGui()
			Evt.GunStance:FireServer(GunStance,AnimData)
			LowReady()
		end
	end

	if ToolEquip and aimming then
		if holdingMiddleMouse then
			AimPartMode = 3
			ModTable.Zoom3Value = math.clamp(ModTable.Zoom3Value - 8,math.min(ModTable.ZoomValue,ModTable.Zoom2Value),fov)
		end
		if Sens < 100 and not holdingMiddleMouse then
			Sens = Sens + 5
			UpdateGui()
			game:GetService('UserInputService').MouseDeltaSensitivity = (Sens/100)
		end
	end

end)

script.Parent:GetAttributeChangedSignal("Injured"):Connect(function()
	local valor = script.Parent:GetAttribute("Injured")

	if valor and runKeyDown then
		runKeyDown 	= false
		Stand()
		if not CheckingMag and not reloading and WeaponData and WeaponData.Type ~= "Grenade" and (GunStance == 0 or GunStance == 2 or GunStance == 3) then
			GunStance = 0
			Evt.GunStance:FireServer(GunStance,AnimData)
			IdleAnim()
		end
	end

	if Stances == 0 then
		Stand()
	elseif Stances == 1 then
		Crouch()
	end

end)

----------//Gun System\\----------

----------//Collapse\\----------
ACS_Client:GetAttributeChangedSignal("Collapsed"):Connect(function()
	if not ACS_Client:GetAttribute("Collapsed") then return; end;
	runKeyDown 	= true
	Stand()
	Stances = 0
	Virar = 0
	CameraX = 0
	CameraY = 0
	Lean()
end)

----------//Collapse\\----------

----------//Health HUD\\----------
BloodScreen:Play()
BloodScreenLowHP:Play()
Humanoid.HealthChanged:Connect(function(Health)
	SE_GUI.Efeitos.Health.ImageTransparency = ((Health - (Humanoid.MaxHealth/2))/(Humanoid.MaxHealth/2))
	SE_GUI.Efeitos.LowHealth.ImageTransparency = (Health /(Humanoid.MaxHealth/2))
end)
----------//Health HUD\\----------

----------//Render Functions\\----------
Run.RenderStepped:Connect(function(step)
	-- HeadMovement()
	renderGunRecoil()
	renderCam()
	
	script.Parent:SetAttribute("Injured",script.Parent.Stances.Ferido.Value)
	script.Parent:SetAttribute("Collapsed",script.Parent.Stances.Caido.Value)

	if ViewModel and LArm and RArm and WeaponInHand then --Check if the weapon and arms are loaded

		local mouseDelta = User:GetMouseDelta()
		SwaySpring:accelerate(Vector3.new(mouseDelta.x/60, mouseDelta.y/60, 0))

		local swayVec = SwaySpring.p
		local TSWAY = swayVec.z
		local XSSWY = swayVec.X
		local YSSWY = swayVec.Y
		local Sway = CFrame.Angles(YSSWY,XSSWY,XSSWY)

		if BipodAtt then

			local BipodRay = Ray.new(UnderBarrelAtt.Main.Position, Vector3.new(0,-1.75,0))
			local BipodHit, BipodPos, BipodNorm = workspace:FindPartOnRayWithIgnoreList(BipodRay, Ignore_Model, false, true)

			if BipodHit then
				CanBipod = true
				if CanBipod and BipodActive and not runKeyDown and (GunStance == 0 or GunStance == 2) then
					TS:Create(SE_GUI.GunHUD.Att.Bipod, TweenInfo.new(.1,Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(255,255,255), ImageTransparency = .123}):Play()
					if not aimming then
						BipodCF = BipodCF:Lerp(CFrame.new(0,(((UnderBarrelAtt.Main.Position - BipodPos).magnitude)-1) * (-1.5), 0),.2)
					else
						BipodCF = BipodCF:Lerp(CFrame.new(),.2)
					end				

				else
					BipodActive = false
					BipodCF = BipodCF:Lerp(CFrame.new(),.2)
					TS:Create(SE_GUI.GunHUD.Att.Bipod, TweenInfo.new(.1,Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(255,255,0), ImageTransparency = .5}):Play()
				end
			else
				BipodActive = false
				CanBipod = false
				BipodCF = BipodCF:Lerp(CFrame.new(),.2)
				TS:Create(SE_GUI.GunHUD.Att.Bipod, TweenInfo.new(.1,Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(255,0,0), ImageTransparency = .5}):Play()
			end

		end

		AnimPart.CFrame = cam.CFrame * NearZ * BipodCF * maincf * gunbobcf * aimcf

		if not AnimData.GunModelFixed then
			WeaponInHand:SetPrimaryPartCFrame(
				ViewModel.PrimaryPart.CFrame
					* guncf
			)
		end

		if running then
			gunbobcf = gunbobcf:Lerp(CFrame.new(
				0.025 * (charspeed/10) * math.sin(tick() * 8),
				0.025 * (charspeed/10) * math.cos(tick() * 16),
				0
				) * CFrame.Angles(
					math.rad( 1 * (charspeed/10) * math.sin(tick() * 16) ), 
					math.rad( 1 * (charspeed/10) * math.cos(tick() * 8) ), 
					math.rad(0)
				), 0.1)
		else
			gunbobcf = gunbobcf:Lerp(CFrame.new(
				0.005 * math.sin(tick() * 1.5),
				0.005 * math.cos(tick() * 2.5),
				0 
				), 1)
		end
		
		local AimTiming = 0
		if WeaponData.adsTime then
			AimTiming += step / (WeaponData.adsTime * 0.1)
		else
			AimTiming = 0.2
		end
		if CurAimpart and aimming and AnimDebounce and not CheckingMag then
			if not NVG or WeaponInHand.AimPart:FindFirstChild("NVAim") == nil then
				if AimPartMode == 1 then
					TS:Create(cam,AimTween,{FieldOfView = ModTable.ZoomValue}):Play()
					maincf = maincf:Lerp(maincf * CFrame.new(0,0,-.5) * recoilcf * Sway:inverse() * CurAimpart.CFrame:toObjectSpace(cam.CFrame), AimTiming)
				elseif AimPartMode == 2 then
					TS:Create(cam,AimTween,{FieldOfView = ModTable.Zoom2Value}):Play()
					maincf = maincf:Lerp(maincf * CFrame.new(0,0,-.5) * recoilcf * Sway:inverse() * CurAimpart.CFrame:toObjectSpace(cam.CFrame), AimTiming)
				else
					TS:Create(cam,AimTween,{FieldOfView = ModTable.Zoom3Value}):Play()
					maincf = maincf:Lerp(maincf * CFrame.new(0,0,-.5) * recoilcf * Sway:inverse() * CurAimpart.CFrame:toObjectSpace(cam.CFrame), AimTiming)
				end
			else
				TS:Create(cam,AimTween,{FieldOfView = fov}):Play()
				maincf = maincf:Lerp(maincf * CFrame.new(0,0,-.5) * recoilcf * Sway:inverse() * (WeaponInHand.AimPart.CFrame * WeaponInHand.AimPart.NVAim.CFrame):toObjectSpace(cam.CFrame), AimTiming)
			end

		else
			TS:Create(cam,AimTween,{FieldOfView = fov}):Play()
			maincf = maincf:Lerp(AnimData.MainCFrame * recoilcf * Sway:inverse(), AimTiming)   
		end

		for index, Part in pairs(WeaponInHand:GetDescendants()) do
			if Part:IsA("BasePart") and Part.Name == "SightMark" then
				local dist_scale = Part.CFrame:pointToObjectSpace(cam.CFrame.Position)/Part.Size
				local reticle = Part.SurfaceGui.Border.Scope	
				--reticle.Position=UDim2.new(.5,0,.5,0)	
				--reticle.Position=UDim2.new(.5+dist_scale.x,0,.5,0+dist_scale.y)	
				reticle.Position=UDim2.new(.5,0+dist_scale.x,.5,0+dist_scale.y)
				if Part.SurfaceGui.Border:FindFirstChild("Vignette") then
					Part.SurfaceGui.Border.Vignette.Position = reticle.Position
				end
			end
		end

		recoilcf = recoilcf:Lerp(CFrame.new() * CFrame.Angles( math.rad(RecoilSpring.p.X), math.rad(RecoilSpring.p.Y), math.rad(RecoilSpring.p.z)), AimTiming)


		if WeaponData.CrossHair then
			if aimming then
				CHup = CHup:Lerp(UDim2.new(.5,0,.5,0),AimTiming)
				CHdown = CHdown:Lerp(UDim2.new(.5,0,.5,0),AimTiming)
				CHleft = CHleft:Lerp(UDim2.new(.5,0,.5,0),AimTiming)
				CHright = CHright:Lerp(UDim2.new(.5,0,.5,0),AimTiming)
			else
				local Normalized = ((WeaponData.CrosshairOffset + BSpread + (charspeed * WeaponData.WalkMult * ModTable.WalkMult) ) / 50)/10

				CHup = CHup:Lerp(UDim2.new(0.5, 0, 0.5 - Normalized,0),0.5)
				CHdown = CHdown:Lerp(UDim2.new(.5, 0, 0.5 + Normalized,0),0.5)
				CHleft = CHleft:Lerp(UDim2.new(.5 - Normalized, 0, 0.5, 0),0.5)
				CHright = CHright:Lerp(UDim2.new(.5 + Normalized, 0, 0.5, 0),0.5)
			end

			Crosshair.Position = UDim2.new(0,mouse.X,0,mouse.Y)

			Crosshair.Up.Position = CHup
			Crosshair.Down.Position = CHdown
			Crosshair.Left.Position = CHleft
			Crosshair.Right.Position = CHright

		else

			CHup = CHup:Lerp(UDim2.new(.5,0,.5,0),AimTiming)
			CHdown = CHdown:Lerp(UDim2.new(.5,0,.5,0),AimTiming)
			CHleft = CHleft:Lerp(UDim2.new(.5,0,.5,0),AimTiming)
			CHright = CHright:Lerp(UDim2.new(.5,0,.5,0),AimTiming)

			Crosshair.Position = UDim2.new(0,mouse.X,0,mouse.Y)

			Crosshair.Up.Position = CHup
			Crosshair.Down.Position = CHdown
			Crosshair.Left.Position = CHleft
			Crosshair.Right.Position = CHright

		end

		if BSpread then
			local currTime = time()
			if currTime - LastSpreadUpdate > (60/WeaponData.ShootRate) * 2 and not shooting and BSpread > WeaponData.MinSpread * ModTable.MinSpread then
				BSpread = math.max(WeaponData.MinSpread * ModTable.MinSpread, BSpread - WeaponData.AimInaccuracyDecrease * ModTable.AimInaccuracyDecrease)
			end
			if currTime - LastSpreadUpdate > (60/WeaponData.ShootRate) * 1.5 and not shooting and RecoilPower > WeaponData.MinRecoilPower * ModTable.MinRecoilPower then
				RecoilPower =  math.max(WeaponData.MinRecoilPower * ModTable.MinRecoilPower, RecoilPower - WeaponData.RecoilPowerStepAmount * ModTable.RecoilPowerStepAmount)
			end
		end

		if LaserActive and Pointer ~= nil then

			if NVG then
				Pointer.Transparency = 0
				Pointer.Beam.Enabled = true
			else
				if not gameRules.RealisticLaser then
					Pointer.Beam.Enabled = true
				else
					Pointer.Beam.Enabled = false
				end
				if IRmode then
					Pointer.Transparency = 1
				else
					Pointer.Transparency = 0
				end
			end

			for index, Key in pairs(WeaponInHand:GetDescendants()) do
				if Key:IsA("BasePart") and Key.Name == "LaserPoint" then
					local L_361_ = Ray.new(Key.CFrame.Position, Key.CFrame.LookVector * 1000)
					local Hit, Pos, Normal = workspace:FindPartOnRayWithIgnoreList(L_361_, Ignore_Model, false, true)

					if Hit then
						Pointer.CFrame =  CFrame.new(Pos, Pos + Normal)
					else
						Pointer.CFrame =  CFrame.new(cam.CFrame.Position + Key.CFrame.LookVector * 2000, Key.CFrame.LookVector)
					end

					if gameRules.ReplicatedLaser then --and HalfStep
						Evt.SVLaser:FireServer(Pos,1,Pointer.Color,IRmode,WeaponTool)
					end
					break
				end
			end
		end
		if char:FindFirstChild("S"..WeaponInHand.Name) then
			for _,v in pairs(char:FindFirstChild("S"..WeaponInHand.Name):GetDescendants()) do
				if v:IsA('SurfaceGui') then
					v.Enabled = false
				end
			end
		end
		
	end
end)
----------//Render Functions\\----------


----------//Events\\----------
Evt.Refil.OnClientEvent:Connect(function(Tool, Infinite, Stored)
	local data = require(Tool.ACS_Settings)
	Evt.Refil:FireServer(Tool, Infinite, Stored, data.MaxStoredAmmo, StoredAmmo)
end)

Evt.AmmoRefilled.OnClientEvent:Connect(function(plr)
	StoredAmmo = RepValues.StoredAmmo.Value
	UpdateGui()
end)

----------//Kuma\\----------

User.InputBegan:Connect(function(input,gpe)
	if gpe then return end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.LeftAlt then
			holdingMiddleMouse = true
			AimPartMode = 3
		end
	end
end)

User.InputEnded:Connect(function(input,gpe)
	if gpe then return end
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.LeftAlt then
		holdingMiddleMouse = false
	end
end)

plr:GetAttributeChangedSignal('Zeus'):Connect(function()
	if plr:GetAttribute('Zeus') == true then
		UnBindActions()
	else
		BindActions()
	end
end)