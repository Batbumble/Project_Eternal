-- @ScriptType: LocalScript
-- Reference to the TextLabel
local textLabel = script.Parent

-- Function to update the TextLabel with the distance
local function updateDistance()
	-- Get the local player and their character
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	-- Get the camera
	local camera = game.Workspace.CurrentCamera

	while true do
		-- Perform a raycast from the camera to the direction the player is looking
		local rayOrigin = camera.CFrame.Position
		local rayDirection = camera.CFrame.LookVector * 1000 -- Adjust the distance as needed
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {character}
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude

		local raycastResult = game.Workspace:Raycast(rayOrigin, rayDirection, raycastParams)

		if raycastResult then
			local distance = (raycastResult.Position - rayOrigin).Magnitude
			textLabel.Text = string.format("%.2f studs", distance)
		else
			textLabel.Text = "Distance: N/A"
		end

		-- Wait a bit before updating again
		wait(0.1)
	end
end

-- Call the function to start updating the distance
updateDistance()
