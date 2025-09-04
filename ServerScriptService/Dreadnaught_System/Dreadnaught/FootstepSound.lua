-- @ScriptType: Script
local rig = script.Parent
local humanoid = rig:WaitForChild('Humanoid',10)

if not humanoid.RootPart then
	humanoid:GetPropertyChangedSignal("RootPart"):Wait()
end

local sound = rig:WaitForChild('Torso',10):WaitForChild('Footstep',10)

humanoid.Running:Connect(function(speed)
	if speed > 7 then
		if sound.IsPaused then
			sound:Resume()
		else
			sound:Play()
		end
	else
		sound:Pause()
	end
end)