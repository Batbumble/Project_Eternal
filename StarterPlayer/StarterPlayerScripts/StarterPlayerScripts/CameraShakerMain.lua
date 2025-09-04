-- @ScriptType: LocalScript
repeat wait() until game.ReplicatedStorage:FindFirstChild("Dead")
local ShakeDist = 50

local cameraShaker = require(game.ReplicatedStorage.Dead.CameraShaker)
local camera = workspace.CurrentCamera

local camShake = cameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
	camera.CFrame = camera.CFrame * shakeCFrame
end)

local function onDescendantAdded(desc)
	if desc:IsA("Explosion") and not desc:GetAttribute('Ignore') then
		if game.Players.LocalPlayer:GetAttribute("Stage") ~= "Knight" then
			local ExDist = (game.Players.LocalPlayer.Character.Head.Position - desc.Position).magnitude
			local ShakeMagnitude = ExDist/(desc.BlastRadius/12)
			local roughness = 5
			local divider = 5
			if desc:GetAttribute('Sorcerer') then
				roughness = 0
				divider = 0
			end
			if ShakeMagnitude < ShakeDist then
				camShake:Start()
				camShake:ShakeOnce(desc.BlastRadius/divider, roughness, 0, 1)
			end
		end
	end
end

game.Workspace.DescendantAdded:Connect(onDescendantAdded)