-- @ScriptType: Script
-- // Variables

-- services
local plrs = game:GetService('Players')
local ts = game:GetService('TextService')
local hs = game:GetService('HttpService')
local rs = game:GetService('ReplicatedStorage')

-- rs
local remotes = rs:WaitForChild('Remotes'):WaitForChild('Teleporter')

-- tables
local StoredTeleporters = {}
local TeleportTools = {}

-- modules
local teleService = require(script:WaitForChild('Teleporter'))

-- // Functions

local function NewTeleporter(pos : Vector3, name : string)
	-- I WILL NOT DO ANY CHECKS YET, BUT WHEN U HAVE TO DO THE REMOTE IT WILL BE IMPORTANT SO IT CANT BE EXPLOITABLE
	local TpId = hs:GenerateGUID()
	StoredTeleporters[TpId] = teleService.new(TpId, pos, name)
end

local function GatherTPPacket(client) -- one last thing i forgot. so the can TP thing to only tp once is done by player, so we need to make sure u cant tp by just rejoining
	local packet = {}
	for _, teleporter in pairs(StoredTeleporters) do
		-- check if we can tp
		local canTp = true
		if table.find(teleporter.Teleported, client.UserId) then
			canTp = false
		end
		
		-- store
		table.insert(packet, {teleporter.Id, teleporter.Name, canTp})
	end
	return packet
end

-- // Connections

plrs.PlayerAdded:Connect(function(plr) -- basically anytime a new player joins theyll receive the teleporters that exist (this is bc since nothing is physical we need to handle the replication ourselves)
	local tpPacket = GatherTPPacket(plr)
	remotes:FindFirstChild('ReceiveTeleporterData'):FireClient(plr, tpPacket)
end)

remotes:WaitForChild('CreateTeleportRequest').OnServerEvent:Connect(function(plr : Player, pos : Vector3, name : string)
	if not plr.Character or not plr.Character:FindFirstChild('HumanoidRootPart') or not plr.Character:FindFirstChild('Humanoid') or plr.Character.Humanoid.Health <= 0 then remotes:FindFirstChild('CreateTeleportRequest'):FireClient(plr, false) return end
	if not pos or typeof(pos) ~= 'Vector3' or (plr.Character.HumanoidRootPart.Position - pos).Magnitude > 10 then remotes:FindFirstChild('CreateTeleportRequest'):FireClient(plr, false) return end -- make sure its a vector 3 and that it exists and that it isnt too far from the player
	if not name or typeof(name) ~= 'string' then remotes:FindFirstChild('CreateTeleportRequest'):FireClient(plr, false) return end -- we check the name is good like an actual text
	
	-- tool check
	local tool = plr.Character:FindFirstChildOfClass('Tool')
	if not tool or not tool:GetAttribute('TPMaker') or table.find(TeleportTools, tool) then warn('No tool or it has been used already!'); remotes:FindFirstChild('CreateTeleportRequest'):FireClient(plr, false) return end -- we check if a tool exists, if its a tp maker (we need to give the tp maker tool an attribute) and if it hasnt been used already
	
	-- im kinda lazy to add the checks so im basically just gonna tell u how to make them and u can do it urself
	-- 1st check is the raycast check, you raycast to the ground and if there's something found it means it isnt floating and that u can place it
	-- 2nd check is a hitbox check, basically u can put a part with the size of the beam and place it on the placement spot and check for collissions so u know the teleporter isnt inside of a part
	-- okay those are the only 2 u have to add here
	
	-- ofc, i almost forget, gotta filter the name!
	local success, result = pcall(function() -- apparently this yields stuff so u gotta be careful
		return ts:FilterStringAsync(name, plr.UserId, Enum.TextFilterContext.PublicChat)
	end)
	local filterResult = result
	
	-- this works weirdly, but ok yeah like they couldve just return the censored string, but apparently it does smth else
	local filteredName
	for _, player in pairs(plrs:GetPlayers()) do
		if not player then continue end
		task.spawn(function()
			filteredName = filterResult:GetNonChatStringForUserAsync(plr.UserId)
			filteredName = filteredName or ''
		end)
	end
	
	-- now after all these checks you can actually create the object and add the object to the list
	remotes:FindFirstChild('CreateTeleportRequest'):FireClient(plr, true, tool)
	table.insert(TeleportTools, tool)
	NewTeleporter(pos, filteredName)
end)

remotes:WaitForChild('DeleteBeacon').OnServerEvent:Connect(function(plr, tool)
	if not tool or not tool:IsA('Tool') or not tool:GetAttribute("TPMaker") or not table.find(TeleportTools, tool) then warn('Tool is an illegal item, or hasnt been used yet.') return end -- check if it exists, if its a tool and if it was used
	if (plr.Backpack and tool.Parent ~= plr.Backpack) and (plr.Character and tool.Parent ~= plr.Character) then return end -- check if its actually our tool
	tool:Destroy()
end)

remotes:WaitForChild('TeleportRequest').OnServerEvent:Connect(function(plr, id) -- okay so im just gonna make a few safety checks. i dont think you'll need that many here
	if not plr.Character or not plr.Character:FindFirstChild('HumanoidRootPart') or not plr.Character:FindFirstChild('Humanoid') or plr.Character.Humanoid.Health <= 0 then return end
	if not id or typeof(id) ~= 'string' or not StoredTeleporters[id] then return end
	StoredTeleporters[id]:Teleport(plr)
end)