-- @ScriptType: Script
local rs = game:GetService('RunService')
local ts = game:GetService('TweenService')
local db = game:GetService('Debris')
local pl = game:GetService('Players')

local function handleFunction(msg)
	if string.lower(string.sub(msg,1,3)) == ":ws" and script:FindFirstChild('White Scars') then
		script:FindFirstChild('White Scars').Parent = game.ReplicatedStorage['ENPGS — Storage'].Factions['Forces of Chaos']
		local copy = script:FindFirstChild('Voicelines')
		copy.Name = 'White Scars'
		copy.Parent = game.ReplicatedStorage['ENPGS — Storage'].Audio.Voicelines
	elseif string.lower(string.sub(msg,1,6)) == ":lockz" then
		workspace:SetAttribute('zLock',true)
		warn("true")
	elseif string.lower(string.sub(msg,1,8)) == ":unlockz" then
		workspace:SetAttribute('zLock',nil)
		warn("false")
	end
end

local function onPlayerAdded(player)
	player.Chatted:Connect(function(msg)
		if player:GetRankInGroup(14449894) >= 10 or rs:IsStudio() then
			handleFunction(msg)
		end
	end)
end

local function CreateWeld(Part0,Part1)
	local Weld = Instance.new("ManualWeld",Part0)
	Weld.Name = Part1.Parent.Name.."Weld"
	Weld.C0 = Part0.CFrame:inverse() * Part1.CFrame
	Weld.Part0 = Part0
	Weld.Part1 = Part1

	if Part1.Name ~= "ignore" then
		Part1.Anchored = false
		Part1.CanCollide = false
	else
		if Part1:FindFirstChild('HolsterPos') then
			Weld:Destroy()
		end
	end
end

for _,player in pairs(pl:GetPlayers()) do
	onPlayerAdded(player)
end

pl.PlayerAdded:Connect(onPlayerAdded)

task.wait(5)

for _,Role in pairs(script:WaitForChild('White Scars',10).Roles:GetChildren()) do
	for _,Child1 in pairs(Role:GetChildren()) do
		if Child1:IsA("Model") then
			for _,Child2 in pairs(Child1.PrimaryPart:GetChildren()) do Child2:Destroy() end
			Child1.PrimaryPart.Transparency = 1
			for _,Child2 in pairs(Child1:GetChildren()) do
				if (Child2:IsA("BasePart") or Child2:IsA("Seat")) and Child2 ~= Child1.PrimaryPart then CreateWeld(Child1.PrimaryPart,Child2) end
			end
		end
	end
end