-- @ScriptType: Script
local cs = game:GetService('CollectionService')

task.wait(script:GetAttribute('SpawnFF'))
local suc,err = pcall(function()
	script.Parent.Parent:AddTag("Airzac")
end)
if not suc then warn("Error tagging ",script.Parent.Parent.Name) end
repeat task.wait() until script.Parent.Parent:FindFirstChildOfClass('Humanoid')
script.Parent.Parent.Humanoid.Died:Connect(function()
	cs:RemoveTag(script.Parent.Parent,"Airzac")
end)