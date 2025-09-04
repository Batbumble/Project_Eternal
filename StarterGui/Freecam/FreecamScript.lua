-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local groupId = 35741482 -- Replace with your group ID

-- Function to enable Freecam for the player
local function enableFreecam(player)
	local PlayerGui = player:WaitForChild("PlayerGui")
	local freecamGui = PlayerGui:FindFirstChild("Freecam")

	if freecamGui then
		freecamGui.Enabled = true -- Show the Freecam GUI
	else
		warn("Freecam GUI not found in PlayerGui for " .. player.Name)
	end
end

-- Function to disable Freecam for the player
local function disableFreecam(player)
	local PlayerGui = player:WaitForChild("PlayerGui")
	local freecamGui = PlayerGui:FindFirstChild("Freecam")

	if freecamGui then
		freecamGui.Enabled = false -- Hide the Freecam GUI
	else
		warn("Freecam GUI not found in PlayerGui for " .. player.Name)
	end
end

-- Handle chat commands for Freecam
local function handleFreecamCommand(player, message)
	if message == "/freecam on" then
		if player:IsInGroup(groupId) then
			enableFreecam(player)
			player.CharacterAdded:Connect(function()
				enableFreecam(player)
			end)
			print(player.Name .. " has enabled Freecam.")
		else
			warn(player.Name .. " is not in the group and cannot access Freecam.")
		end
	elseif message == "/freecam off" then
		disableFreecam(player)
		print(player.Name .. " has disabled Freecam.")
	end
end

-- Handle when a player joins the game
local function playerJoin(player)
	player.Chatted:Connect(function(message)
		handleFreecamCommand(player, message)
	end)
end

-- Connect existing players
for _, player in ipairs(Players:GetChildren()) do
	task.spawn(playerJoin, player)
end

-- Connect new players as they join
Players.PlayerAdded:Connect(playerJoin)
