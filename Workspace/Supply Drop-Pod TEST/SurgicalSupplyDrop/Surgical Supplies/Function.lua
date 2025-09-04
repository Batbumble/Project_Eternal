-- @ScriptType: Script
script.Parent.ProximityPrompt.Triggered:Connect(function(player)

game:GetService("ServerStorage"):WaitForChild(script.Parent.Name):Clone().Parent = player.Backpack
script.Parent.PickUp:Destroy()
script.Parent:Destroy()

end)