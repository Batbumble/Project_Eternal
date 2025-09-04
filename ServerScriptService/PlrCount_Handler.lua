-- @ScriptType: Script
local dss = game:GetService("DataStoreService")
local planetsStore = dss:GetDataStore("Planets")
planetsStore:SetAsync(game.PlaceId,#game.Players:GetChildren())

game.Players.PlayerAdded:Connect(function()
	planetsStore:SetAsync(game.PlaceId,#game.Players:GetChildren())
end)

game.Players.PlayerRemoving:Connect(function()
	planetsStore:SetAsync(game.PlaceId,#game.Players:GetChildren())
end)
game:BindToClose(function()
	planetsStore:SetAsync(game.PlaceId,0)
end)