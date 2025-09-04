-- @ScriptType: LocalScript
local Camera = workspace.CurrentCamera
local Player = game.Players.LocalPlayer
local character = Player.Character
local head = character:WaitForChild("Head")
local terrain = workspace:FindFirstChildWhichIsA("Terrain")

local SS = game:GetService("SoundService")	

local raycastParams = RaycastParams.new()
local IgnoreTable = {character}

for i, obj in pairs(script:WaitForChild("Ignore"):GetChildren()) do
	local targ = obj.Value
	if targ ~= nil then
		table.insert(IgnoreTable, targ)
	end
end

raycastParams.FilterDescendantsInstances = IgnoreTable
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local CastHeight = script:WaitForChild("CastHeight").Value

game:GetService("RunService").RenderStepped:connect(function()
	
	if terrain then
		local headLoc = terrain:WorldToCell(head.Position)
		--local m, o = terrain:ReadVoxels(Region3.new(headLoc - Vector3.one * 2, headLoc + Vector3.one * 2):ExpandToGrid(4), 4)
		--local hasAnyWater = (m[1][1][1] == Enum.Material.Water and o[1][1][1] >= 0.5)
		local hasAnyWater = terrain:GetWaterCell(headLoc.x, headLoc.y, headLoc.z)
		
		if hasAnyWater then
			SS.AmbientReverb = Enum.ReverbType.UnderWater
			return
		end
	end
	
	local raycastResult = workspace:Raycast(head.Position, Vector3.new(0, CastHeight, 0), raycastParams)
	if raycastResult then
		local hitPart = raycastResult.Instance
		if hitPart == terrain then

			local material = raycastResult.Material
			if material == Enum.Material.Rock or material == Enum.Material.Basalt then

				SS.AmbientReverb = Enum.ReverbType.ParkingLot
			else
				SS.AmbientReverb = Enum.ReverbType.City
			end

		elseif hitPart.Material == Enum.Material.Fabric then
			SS.AmbientReverb = Enum.ReverbType.CarpettedHallway
		elseif hitPart:IsDescendantOf(workspace) and hitPart.Transparency < 0.9 then
			SS.AmbientReverb = Enum.ReverbType.City
		else
			SS.AmbientReverb = Enum.ReverbType.NoReverb
		end
	else
		SS.AmbientReverb = Enum.ReverbType.NoReverb
	end
end)

Camera.ChildAdded:Connect(function(addedModel)
	table.insert(IgnoreTable,addedModel)
	raycastParams.FilterDescendantsInstances = IgnoreTable
end)

Camera.ChildRemoved:Connect(function(removedModel)
	local index = table.find(IgnoreTable,removedModel)
	if index then
		table.remove(IgnoreTable,index)
		raycastParams.FilterDescendantsInstances = IgnoreTable
	end
end)

character.ChildAdded:Connect(function(child)
	if child:IsA("BasePart") or child:IsA("Model") then
		table.insert(IgnoreTable, child)
		raycastParams.FilterDescendantsInstances = IgnoreTable
	end
end)

character.ChildRemoved:Connect(function(child)
	local index = table.find(IgnoreTable,child)
	if index then
		table.remove(IgnoreTable,index)
		raycastParams.FilterDescendantsInstances = IgnoreTable
	end
end)