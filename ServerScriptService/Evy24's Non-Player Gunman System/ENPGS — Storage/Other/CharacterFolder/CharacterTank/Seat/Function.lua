-- @ScriptType: Script
local proximityPrompt = script.Parent.Prompt
local seat = script.Parent

seat:GetPropertyChangedSignal("Occupant"):Connect(function()
	if seat.Occupant then
		proximityPrompt.Enabled = false
	else
		task.wait(1)
		proximityPrompt.Enabled = true
	end
end)

proximityPrompt.Triggered:Connect(function(player)
	seat:Sit(player.Character.Humanoid)
end)

function added(child)
	script.Parent.Enter:Play()
	if (child.className=="Weld") then
		local human = child.part1.Parent:FindFirstChild("Humanoid")
		if human ~= nil then
			--local animation = Instance.new("Animation")
			--animation.AnimationId = "rbxassetid://15812564256"
			--animation.Parent = human
			--anim = human:LoadAnimation(animation)
			--anim:Play()
			human:SetAttribute('StoredValue',human.JumpHeight)
			human.JumpHeight = 0
		end
	 end
end

function removed(child2)
	script.Parent.Exit:Play()
	--if anim ~= nil then
	--	anim:Stop()
	--	anim:Remove()
	--end
end

seat.ChildAdded:connect(added)
seat.ChildRemoved:connect(removed)