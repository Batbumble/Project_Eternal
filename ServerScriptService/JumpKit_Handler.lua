-- @ScriptType: Script
local Event = Instance.new("RemoteEvent", game.ReplicatedStorage)
Event.Name = "ClientConnection"
local Event2 = Instance.new("RemoteEvent", game.ReplicatedStorage)
Event2.Name = "RayCreation"
local remote = Instance.new("RemoteFunction", game.ReplicatedStorage)
remote.Name = "ReloadConnection"

--[[VehicleSoundHandler.OnServerEvent:Connect(function(Player, data)
	data["TargetSound"].Volume = data["LatestVolume"]	
	data["TargetSound"].PlaybackSpeed = data["LatestPitch"]	
	data["TargetSound"].EmitterSize = data["LatestEmitterSize"]	
	data["TargetSound"].MaxDistance = data["LatestDistance"]
end)]]

--local create = assert(LoadLibrary("RbxUtility")).Create
local cframe, cframeXYZ, vector = CFrame.new, CFrame.fromEulerAnglesXYZ, Vector3.new
function convertToCFrameDegrees(xa, ya, za)
	return CFrame.Angles(math.rad(xa), math.rad(ya), math.rad(za))
end

--Weld = create("Weld"){}

--Motor6D = create("Motor6D"){}

function TweenJoint(Joint, newC0, newC1, Alpha, Duration)
	spawn(function()
		if Joint ~= nil then
			local newCode = math.random(-1e9, 1e9) --This creates a random code between -1000000000 and 1000000000
			local tweenIndicator = nil
			if (not Joint:findFirstChild("tweenCode")) then --If the joint isn't being tweened, then
				tweenIndicator = Instance.new("IntValue")
				tweenIndicator.Name = "tweenCode"
				tweenIndicator.Value = newCode
				tweenIndicator.Parent = Joint
			else
				tweenIndicator = Joint.tweenCode
				tweenIndicator.Value = newCode --If the joint is already being tweened, this will change the code, and the tween loop will stop
			end
			--local tweenIndicator = createTweenIndicator:InvokeServer(Joint, newCode)
			if Duration <= 0 then --If the duration is less than or equal to 0 then there's no need for a tweening loop
				if newC0 then Joint.C0 = newC0 end
				if newC1 then Joint.C1 = newC1 end
			else
				local Increment = 1.5 / Duration
				local startC0 = Joint.C0
				local startC1 = Joint.C1
				local X = 0
				while true do
					game:GetService("RunService").Heartbeat:wait() --This makes the for loop step every 1/60th of a second
					local newX = X + Increment
					X = (newX > 90 and 90 or newX)
					if tweenIndicator.Value ~= newCode then break end --This makes sure that another tween wasn't called on the same joint
					if Joint == nil then break end --This stops the tween if the tool is deselected
					if newC0 then Joint.C0 = startC0:lerp(newC0, Alpha(X)) end
					if newC1 then Joint.C1 = startC1:lerp(newC1, Alpha(X)) end
					--if newC0 then lerpCF:InvokeServer(Joint, "C0", startC0, newC0, Alpha(X)) end
					--if newC1 then lerpCF:InvokeServer(Joint, "C1", startC1, newC1, Alpha(X)) end
					if X == 90 then break end
				end
			end
			if tweenIndicator.Value == newCode then --If this tween functions was the last one called on a joint then it will remove the code
				tweenIndicator:Destroy()
			end
		--deleteTweenIndicator:InvokeServer(tweenIndicator, newCode)
		end
	end)
end

function CorrectCharSize(Target,HeadSize,BodySize)
	local LastGrowth = time()
	
	local HeadPercentage = HeadSize
	local Percentage = BodySize

	local Player = game.Players:GetPlayerFromCharacter(Target)
	
	if Player and Player.Character:FindFirstChild("AppliedGrowth") == nil then
		local Motors = {}
		local NewMotors = {}
		local NewVal = Instance.new("BoolValue")
		NewVal.Name = "AppliedGrowth"
		NewVal.Parent = Player.Character
		
		
		for i,v in pairs(Player.Character.Torso:GetChildren()) do
			if v:IsA("Motor6D") then
				table.insert(Motors, v)
			end
		end
		table.insert(Motors, Player.Character.HumanoidRootPart.RootJoint)
		
		local HatWelds = {}
		for i,v in pairs(Player.Character:GetChildren()) do
			if v:IsA("Accessory") then
				v.Handle.AccessoryWeld.C0 = CFrame.new((v.Handle.AccessoryWeld.C0.p * HeadPercentage)) * (v.Handle.AccessoryWeld.C0 - v.Handle.AccessoryWeld.C0.p)
				v.Handle.AccessoryWeld.C1 = CFrame.new((v.Handle.AccessoryWeld.C1.p * HeadPercentage)) * (v.Handle.AccessoryWeld.C1 - v.Handle.AccessoryWeld.C1.p)
				table.insert(HatWelds, {v.Handle.AccessoryWeld:Clone(), v.Handle})
				v.Handle.Mesh.Scale = v.Handle.Mesh.Scale * HeadPercentage
				v.Handle.Mesh.Offset = v.Handle.Mesh.Offset * HeadPercentage
			end
		end
		
			for i,v in pairs(Motors) do
			local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = v.C0:components()
			X = X * Percentage
			Y = Y * Percentage
			Z = Z * Percentage
			R00 = R00 * Percentage
			R01 = R01 * Percentage
			R02 = R02 * Percentage
			R10 = R10 * Percentage
			R11 = R11 * Percentage
			R12 = R12 * Percentage
			R20 = R20 * Percentage
			R21 = R21 * Percentage
			R22 = R22 * Percentage
			v.C0 = CFrame.new(X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22)
			
			local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = v.C1:components()
			X = X * Percentage
			Y = Y * Percentage
			Z = Z * Percentage
			R00 = R00 * Percentage
			R01 = R01 * Percentage
			R02 = R02 * Percentage
			R10 = R10 * Percentage
			R11 = R11 * Percentage
			R12 = R12 * Percentage
			R20 = R20 * Percentage
			R21 = R21 * Percentage
			R22 = R22 * Percentage
			v.C1 = CFrame.new(X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22)
			
			table.insert(NewMotors, {v:Clone(), v.Parent})
			v:Destroy()
		end
		
		for i,v in pairs(Player.Character:GetChildren()) do
			if v:IsA("BasePart") then
				if v.Name == "Head" then
					v.Size = v.Size * HeadPercentage
					--v.CFrame = Player.Character.Torso.CFrame * CFrame.new(0,1.2,0)
				else
					v.Size = v.Size * Percentage
				end
			end
		end
		
		--Player.Character.Head.CFrame = Player.Character.Head.CFrame
		
		for i,v in pairs(NewMotors) do
			v[1].Parent = v[2]
		end
		
		for i,v in pairs(HatWelds) do
			--v[1].Part1 = Player.Character.Head
			--v[1].Parent = v[2]
		end
	end
end

function remote.OnServerInvoke(Player)
	local char = Player.Character
	if char and char:FindFirstChild("Torso") and char.Torso:FindFirstChild("Weld1") and char.Torso:FindFirstChild("Weld2") then
		return true
	else
		return false
	end
end

function Lights(bool,target)
local list = target:GetChildren()
	for i = 1, #list do
		if list[i].Name == "HeadLight" or list[i].Name == "RedLight" then	
			if list[i]:FindFirstChild("Light") then		
				if bool then
					list[i].Light.Enabled = true
					list[i].Material = Enum.Material.Neon
				else
					list[i].Light.Enabled = false
					list[i].Material = Enum.Material.Metal	
				end
			end
		elseif list[i].ClassName == "Model" then
			Lights(bool,list[i])
		end
	end		
end

function RemovePartWelds(targety)
	local listy = targety:GetChildren()
	for i = 1, #listy do		
		if (listy[i].className == "Weld") then --If its a brick
			listy[i]:Destroy()
		end
	end
end

function MakePartInvis(targety)
	local listy = targety:GetChildren()
	for i = 1, #listy do		
		if (listy[i].className == "Part" or listy[i].className == "VehicleSeat" or listy[i].className == "WedgePart" or listy[i].className == "UnionOperation" or listy[i].className == "MeshPart") then --If its a brick
			listy[i].Transparency = 1
		end
	end
end

function MakePartVis(target)
	local list = target:GetChildren()
	for i = 1, #list do		
		if (list[i].className == "Part" or list[i].className == "VehicleSeat" or list[i].className == "WedgePart" or list[i].className == "UnionOperation" or list[i].className == "MeshPart") then --If its a brick
			if list[i].Name ~= "FakeRightArm" and list[i].Name ~= "FakeLeftArm" then
				list[i].Transparency = 0
			end
		end
	end
end

function MakePartCol(target,bool)
	local list = target:GetChildren()
	for i = 1, #list do		
		if (list[i].className == "Part" or list[i].className == "VehicleSeat" or list[i].className == "WedgePart" or list[i].className == "UnionOperation" or list[i].className == "MeshPart") then --If its a brick
			if list[i].Name ~= "FakeRightArm" or list[i].Name ~= "FakeLeftArm" then
				list[i].CanCollide = bool
			end
		end
	end
end

function MakeSpecificPartCol(target,bool)
	if target.className == "Part"
	or target.className == "VehicleSeat"
	or target.className == "WedgePart"
	or target.className == "UnionOperation"
	or target.className == "MeshPart" then --If its a brick
	target.CanCollide = bool
	end
end

function UpdatePartTransparency(target,transparency)
	if target.className == "Part"
	or target.className == "VehicleSeat"
	or target.className == "WedgePart"
	or target.className == "UnionOperation"
	or target.className == "MeshPart" then --If its a brick
	target.Transparency = transparency
	end
end

function ReviveAddMorph(TargetPart,NewPart)
	local WeldList = TargetPart:GetChildren()
	for i = 1, #WeldList do		
		if WeldList[i].className == "Weld" and WeldList[i].Name == "Weld" then
			WeldList[i].Parent = NewPart
			WeldList[i].Part0 = NewPart
		end
	end
end

Event.OnServerEvent:Connect(function(Player, data)
	if data["Function"] == "EmitterBoolClient" then
		Event:FireAllClients(data)
	elseif data["Function"] == "ParticleEmitterBool" then
		data["TargetParticleEmitter"].Enabled = data["Bool"]
		Event:FireAllClients(data)
	elseif data["Function"] == "ParticleEmitterBool2" then
		Event:FireAllClients(data)
	elseif data["Function"] == "TrailBool" then	
		data["TargetTrail"].Enabled = data["Bool"]
		Event:FireAllClients(data)
	elseif data["Function"] == "BeamBool" then
		data["TargetBeam"].Enabled = data["Bool"]
		Event:FireAllClients(data)
	elseif data["Function"] == "UpdateSound" then
		Event:FireAllClients(data)
	end
end)

Event2.OnServerEvent:Connect(function(Player, data)
	
end)