-- @ScriptType: Script
local main = script.Parent.PrimaryPart

for _,v in pairs(script.Parent:GetChildren()) do
	if not v:IsA('BasePart') then continue end
	if v.Name == "Door" then continue end
	if v.Name == "Main" then continue end
	local weld = Instance.new('WeldConstraint',v)
	weld.Part0 = main
	weld.Part1 = v
	v.Anchored = false
end