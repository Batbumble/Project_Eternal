-- @ScriptType: Script
local GlobalNavigation = game.ReplicatedStorage.GlobalNavigation
local WaypointEvent = GlobalNavigation.WaypointEvent
local DeletionEvent = GlobalNavigation.DeleteWaypointEvent

WaypointEvent.OnServerEvent:Connect(function(player, position, size, rotation, image, color, name)
	WaypointEvent:FireAllClients(player, position, size, rotation, image, color, name)
	print("BFT: " .. player.Name .. " placed waypoint" .. name)
end)

DeletionEvent.OnServerEvent:Connect(function(player, waypointID, allPoints)
	DeletionEvent:FireAllClients(player, waypointID, allPoints)
	if allPoints == true then
		print("BFT: " .. player.Name .. " deleted all waypoints")
	else
		print("BFT: " .. player.Name .. " deleted waypoint " .. waypointID)
	end
end)