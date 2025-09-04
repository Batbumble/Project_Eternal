-- @ScriptType: Script
task.wait(0.5)
local ts = game:GetService('TweenService')
local main = script.Parent
local pod = main.Parent
local botAtt = main:WaitForChild('AttachmentMain')
local topAtt = main:WaitForChild('AttachmentTop')
--local seats = pod:WaitForChild('Seats')

local landed = false
local launched = false

local green = Color3.fromRGB(0,170,0)
local zero = Vector3.new(0,0,0)
local ti = TweenInfo.new(1)
local ti2 = TweenInfo.new(300)

local whiteList = {}

local function openAllDoors()
	ts:Create(pod.Light.PointLight,ti,{Color = green}):Play()
	topAtt.PrepareSound:Play()
	task.wait(3)
	topAtt.DoorOpenSound:Play()
	for _,v in pairs(main:GetChildren()) do
		if not v:IsA('WeldConstraint') then continue end
		v:Destroy()
	end
	for _,v in pairs(pod.Doors:GetChildren()) do
		v.CanTouch = true
		local vTouch = v.Touched:Connect(function(hit)
			if not hit.Parent then return end
			if hit.Parent:FindFirstChildOfClass('Humanoid') then
				if table.find(whiteList,hit.Parent) then return end
				hit.Parent.Humanoid.Health = 0
			end
		end)
		task.delay(1,function()
			vTouch:Disconnect()
			v.CanTouch = false
		end)
	end
	ts:Create(pod.Light.PointLight,ti2,{Brightness = 0}):Play()
	--seats:Destroy()
	task.wait(1)
	for _,v in pairs(main:GetChildren()) do
		if not v:IsA('HingeConstraint') then continue end
		v.ActuatorType = Enum.ActuatorType.None
	end
	task.wait(1)
	for _,v in pairs(pod.Doors:GetChildren()) do
		v.Anchored = true
	end
end

local function launchPod()
	if launched then return end 
	launched = true
	--for _,v in pairs(seats:GetChildren()) do
	--	if v:FindFirstChild('SeatWeld') then
	--		table.insert(whiteList,v.SeatWeld.Part1.Parent)
	--		v.SeatWeld.Part1.Parent.Humanoid:SetAttribute('StoredValue',v.SeatWeld.Part1.Parent.Humanoid.JumpPower)
	--		v.SeatWeld.Part1.Parent.Humanoid.JumpPower = 0
	--	end
	--end
	main.Anchored = false
	main.CanTouch = true
	topAtt.IgniteSound:Play()
	topAtt.Flame.Enabled = true
	task.delay(0.8,function() topAtt.BurnSound:Play() topAtt.Backburner:Play() task.wait(1) if topAtt.SubsonicSound then topAtt.SubsonicSound:Play() topAtt.WindSound:Play() end end)
end

local function downTree(tree)
	if tree:GetAttribute('Downing') then return end
	tree:SetAttribute('Downing',true)
	for _,v in pairs(tree:GetChildren()) do
		v.CanTouch = false
		v.CanCollide = false
		v.CanQuery = false
		ts:Create(v,TweenInfo.new(0.3),{Position = v.Position - Vector3.new(0,100,0)}):Play()
	end
	task.wait(0.3)
	tree:Destroy()
end

main.Touched:Connect(function(hit)
	if not hit.Parent then return end
	if hit:HasTag('Tree') then hit.Parent:Destroy() return end
	--if hit:HasTag('Tree') then downTree(hit.Parent) return end
	if hit.Parent:FindFirstChildOfClass('Humanoid') then return end
	if landed then return end
	landed = true
	main.CanTouch = false
	main.AngularVelocity:Destroy()
	topAtt.Flame:Destroy()
	main.LinearVelocity.Enabled = true
	botAtt.CrashSound:Play()
	botAtt.EchoSound:Play()
	for _,v in pairs(pod:GetChildren()) do
		if not v:IsA('BasePart') then continue end
		v.AssemblyLinearVelocity = zero
		v.AssemblyAngularVelocity = zero
	end
	local e = Instance.new('Explosion',main)
	e.Position = main.AttachmentMain.WorldPosition
	e.Visible = false
	e.BlastPressure = 0
	e.DestroyJointRadiusPercent = 0
	e.BlastRadius = 10
	e.Hit:Connect(function(hit,dist)
		if hit.Parent:FindFirstChildOfClass('Humanoid') then
			if table.find(whiteList,hit.Parent) then return end
			hit.Parent.Humanoid.Health = 0
		end
	end)
	for _,v in pairs(pod:GetChildren()) do
		if not v:IsA('BasePart') then continue end
		v.AssemblyLinearVelocity = zero
		v.AssemblyAngularVelocity = zero
	end
	for _,v in pairs(topAtt:GetChildren()) do
		if v.Name == "DoorOpenSound" then continue end
		if v.Name == "PrepareSound" then continue end
		v:Destroy()
	end
	task.wait(1.5)
	main.LinearVelocity:Destroy()
	main.Anchored = true
	for _,v in pairs(pod:GetChildren()) do
		if not v:IsA('BasePart') then continue end
		v.AssemblyLinearVelocity = zero
		v.AssemblyAngularVelocity = zero
	end
	openAllDoors()
	for _,v in pairs(main:GetChildren()) do
		if v.Name == "SupplyWeld" then
			v:Destroy()
		end
	end
end)

launchPod()