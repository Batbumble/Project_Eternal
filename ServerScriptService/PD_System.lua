-- @ScriptType: Script
---------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------Variables-------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------
local Event = game:GetService("ReplicatedStorage"):WaitForChild("Dead",4)
local perma = game:GetService("ReplicatedStorage"):WaitForChild("perma")
local cam = game:GetService("ReplicatedStorage"):WaitForChild("Freecam")
local Players = game.Players
local rs = game:GetService('RunService')
local permadeathEnabled = false
local deadPlayers = {}
local DeadList = {}

local http = game:GetService("HttpService")
----------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------Whitelist-------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------
local allowedPlayers = {
	{35731003,7},{35741482,2},
}
----------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------Functions-------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------
local function onPlayerChatted(player, message)
	-- Check if the player is allowed to use commands
	local W = rs:IsStudio()
	
	for _,V in pairs(allowedPlayers) do
		if player:IsInGroup(V[1]) and player:GetRankInGroup(V[1]) >= V[2] then
			W = true
			break
		end
	end
	
	if W then
		-- Check if the message is a command
		if message:sub(1, 1) == "/" then
			-- Extract the command and arguments
			local parts = {}
			for part in message:sub(2):gmatch("%S+") do
				table.insert(parts, part)
			end
			
			-- Execute different commands based on the command name
			local command = parts[1]
			local NewMessage = ""

			for I,V in pairs(parts) do
				if I ~= 1 then
					NewMessage = NewMessage.." "..V
				end
			end
			
			if command == "permadeath" then
				-- Assuming the command is in the format: /permadeath [on/off]
				local option = parts[2]
				if option == "on" then
					permadeathEnabled = true
					
					game.ReplicatedStorage:WaitForChild("PermaDeath").Value = true
					
					perma:FireAllClients(true)
				elseif option == "off" then
					permadeathEnabled = false
					game.ReplicatedStorage:WaitForChild("PermaDeath").Value = false
					perma:FireAllClients(false)
					cam:FireAllClients(false)
					for _, v in ipairs(deadPlayers) do
						print(v)
						for _, p in ipairs(game.Players:GetPlayers()) do
							if string.find(p.Name, v) then
								p:LoadCharacter()
							end
						end
					end
				else
					-- Invalid option
					print("Invalid option for /permadeath. Use 'on' or 'off'.")
				end
			elseif command == "revive" then
				-- Assuming the command is in the format: /revive [playerName]
				local playerName = parts[2]
				local targetPlayer = nil

				-- Find the target player by matching the input with player names
				for _, p in ipairs(game.Players:GetPlayers()) do
					if string.find(p.Name:lower(), playerName:lower()) then
						targetPlayer = p
						break
					end
				end
			
				if targetPlayer then
					cam:FireClient(targetPlayer, false)
					targetPlayer:LoadCharacter()
					if permadeathEnabled then
						perma:FireClient(targetPlayer, true)
					end
					for i, name in ipairs(deadPlayers) do
						if name == targetPlayer.Name then
							table.remove(deadPlayers, i)
							break
						end
					end
					
					for I,V in pairs(DeadList) do
						if V[1] == targetPlayer.Name then
							table.remove(DeadList, I)
						end
					end
				end
			elseif command == "n" then -- NARRATIVE
				game.ReplicatedStorage:FindFirstChild("Story"):FireAllClients("Narrative",NewMessage) 
			elseif command == "d" then
				game.ReplicatedStorage:FindFirstChild("Story"):FireAllClients("Despair",NewMessage) 
			elseif command == "c" then
				game.ReplicatedStorage:FindFirstChild("Story"):FireAllClients("Chaos",NewMessage) 
			elseif command == "i" then
				game.ReplicatedStorage:FindFirstChild("Story"):FireAllClients("Hope",NewMessage) 
			elseif command == "s" then
				game.ReplicatedStorage:FindFirstChild("Story"):FireAllClients("Hope",NewMessage) 
			elseif command == "deadlist" then
				if parts[2] == "on" then
					game.ReplicatedStorage.Deadlist:FireClient(player,true,DeadList)
				elseif parts[2] == "off" then
					game.ReplicatedStorage.Deadlist:FireClient(player,false,nil)
				end
			end
		end
	end
end

--
game.ReplicatedStorage:WaitForChild("Main"):WaitForChild("Remote Events"):WaitForChild("Revive").OnServerEvent:Connect(function(Player,PlayerToRevive)
	pcall(function()
		local targetPlayer = PlayerToRevive

		if targetPlayer then
			cam:FireClient(targetPlayer, false)
			targetPlayer:LoadCharacter()
			targetPlayer.Character:SetPrimaryPartCFrame(Player.Character.PrimaryPart.CFrame * CFrame.new(0,0,-5))
			if permadeathEnabled then
				perma:FireClient(targetPlayer, true)
			end
			game.ReplicatedStorage.NametagEvent:FireAllClients()
			for i, name in ipairs(deadPlayers) do
				if name == targetPlayer.Name then
					table.remove(deadPlayers, i)
					break
				end
			end
		end
	end)
end)

-- Hook the onPlayerChatted function to the PlayerChatted event for each player
game.Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		onPlayerChatted(player, message)
	end)
end)

game:GetService('Players').PlayerAdded:Connect(function(player)
	game:GetService("Players").CharacterAutoLoads = true
	player.CharacterAdded:Connect(function(character)
		game:GetService("Players").CharacterAutoLoads = false
		character:WaitForChild("Humanoid").Died:Connect(function()
			if permadeathEnabled then
				table.insert(deadPlayers, character.Name)
				Event:FireClient(player)
				cam:FireClient(player, true)
				if player:FindFirstChild("TeamTags_Info") and player:FindFirstChild("TeamTags_Info"):FindFirstChild("TagNameTag") then
					table.insert(DeadList,{character.Name,player:FindFirstChild("TeamTags_Info"):FindFirstChild("TagNameTag").Value})
				end
			else
				task.wait(5)
				player:LoadCharacter()
			end
		end)
	end)
end)
