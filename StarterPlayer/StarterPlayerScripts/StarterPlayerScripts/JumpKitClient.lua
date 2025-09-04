-- @ScriptType: LocalScript
local Event = game.ReplicatedStorage:WaitForChild("ClientConnection")
local player = game.Players.LocalPlayer
local cframe, cframeXYZ, vector = CFrame.new, CFrame.fromEulerAnglesXYZ, Vector3.new
--local create = assert(LoadLibrary("RbxUtility")).Create
--local laser = create("Part"){Name = "Ray", Anchored = true, CanCollide = false, formFactor = 0, Size = vector(.5, .5, 1), Material='SmoothPlastic', Reflectance = 0.2, Transparency = 0.15}
--local mesh = create("BlockMesh"){Parent = laser, Name = "Mesh"}

local Players = game:GetService("Players")
 
function TweenJoint(Joint, newC0, newC1, Alpha, Duration)
	spawn(function()
		if Joint ~= nil then
			local newCode = math.random(-1e9, 1e9) --This creates a random code between -1000000000 and 1000000000
			local tweenIndicator = Joint:FindFirstChild("tweenCode") or Instance.new("IntValue")
				tweenIndicator.Name = "tweenCode"
				tweenIndicator.Parent = Joint
			if (not Joint:FindFirstChild("tweenCode")) then --If the joint isn't being tweened, then
				tweenIndicator.Value = newCode
				tweenIndicator.Parent = Joint
			else
				tweenIndicator.Value = newCode --If the joint is already being tweened, this will change the code, and the tween loop will stop
			end
			--[[if (not Joint:FindFirstChild("tweenCode")) then --If the joint isn't being tweened, then
				tweenIndicator = Instance.new("IntValue")
				tweenIndicator.Name = "tweenCode"
				tweenIndicator.Value = newCode
				tweenIndicator.Parent = Joint
			else
				tweenIndicator = Joint.tweenCode
				tweenIndicator.Value = newCode --If the joint is already being tweened, this will change the code, and the tween loop will stop
			end]]
			--local tweenIndicator = createTweenIndicator:InvokeServer(Joint, newCode)
			if Duration <= 0 then --If the duration is less than or equal to 0 then there's no need for a tweening loop
				if newC0 then Joint.C0 = newC0 end
				if newC1 then Joint.C1 = newC1 end
			else
				local Increment = 1.5 / Duration
				local startC0 = Joint.C0
				local startC1 = Joint.C1
				local X = 0
				local AnimChar = Joint.Parent.Parent
				local SizeOffset = 1
				if AnimChar:FindFirstChild("Torso") then
					SizeOffset = AnimChar.Torso.Size.Z
				end
				while true do
					game:GetService("RunService").RenderStepped:wait() --This makes the for loop step every 1/60th of a second
					local newX = X + Increment
					X = (newX > 90 and 90 or newX)
					if tweenIndicator.Value ~= newCode then break end --This makes sure that another tween wasn't called on the same joint
					if Joint == nil then break end --This stops the tween if the tool is deselected
					if newC0 then Joint.C0 = startC0:lerp(CFrame.new((newC0.p * SizeOffset)) * (newC0 - newC0.p), Alpha(X)) end
					if newC1 then Joint.C1 = startC1:lerp(CFrame.new((newC1.p * SizeOffset)) * (newC1 - newC1.p), Alpha(X)) end
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

local IgnoreList = {
	
}

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

function GetPlayer(hit)
	if hit and hit.Parent then
		if hit.Parent:FindFirstChild("Humanoid") then
			return hit.Parent.Humanoid
		elseif hit.Parent.Parent:FindFirstChild("Humanoid") then
			return hit.Parent.Parent.Humanoid
		end
	end
end

Event.OnClientEvent:connect(function(data)
	if data["Function"] == "EmitterBool" then
		data["TargetEmitter"].Enabled = data["Bool"]	
	elseif data["Client"] ~= player and data["Function"] == "MakePartInvis" then		
		MakePartInvis(data["TargetPart"])
	elseif data["Client"] ~= player and data["Function"] == "MakePartVis" then		
		MakePartVis(data["TargetPart"])
	elseif data["Client"] ~= player and data["Function"] == "MakePartCol" then		
		MakePartCol(data["TargetPart"],data["Bool"])
	elseif data["Client"] ~= player and data["Function"] == "MakeSpecificPartCol" then		
		MakeSpecificPartCol(data["TargetPart"],data["Bool"])	
	elseif data["Function"] == "EmitterBoolClient" then
		data["TargetParticleEmitter"].Enabled = data["Bool"]
	elseif data["Function"] == "ParticleEmitterBool" then
		if data["Client"] ~= player then
		data["TargetParticleEmitter"].Enabled = data["Bool"]
		end
	elseif data["Function"] == "ParticleEmitterBool2" then
		if data["Client"] ~= player and data["TargetParticleEmitter"] then
			data["TargetParticleEmitter"].Enabled = data["Bool"]
		end
	elseif data["Function"] == "TrailBool" then	
		
	elseif data["Function"] == "BeamBool" then
		
	elseif data["Function"] == "MakeGrenadeSmoke" then		
		
	elseif data["Function"] == "MakeGrenadeGas" then		
		
	elseif data["Function"] == "MakeGrenadeFlash" then	
	
	end
end)