-- @ScriptType: LocalScript
-- Reference to the TextLabel
local textLabel = script.Parent

-- Function to update the TextLabel with the player's facing direction
local function updateDirection()
	-- Get the local player and their character
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	-- Calculate the direction
	while true do
		local lookVector = humanoidRootPart.CFrame.LookVector
		local angle = math.atan2(lookVector.X, lookVector.Z)
		local degrees = math.deg(angle)
		degrees = (degrees + 360) % 360  -- Ensure degrees are between 0 and 360

		-- Update the TextLabel
		textLabel.Text = string.format("%.0f°", degrees)

		-- Wait a bit before updating again
		wait(0.1)
	end
end

-- Call the function to start updating the direction
updateDirection()
