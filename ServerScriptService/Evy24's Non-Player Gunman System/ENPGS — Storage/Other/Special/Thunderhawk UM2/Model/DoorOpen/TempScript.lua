-- @ScriptType: Script
task.wait(20)
local weld = Instance.new("WeldConstraint",script.Parent)
weld.Name = "TempWeld"
weld.Part0 = script.Parent.Parent.PrimaryPart
weld.Part1 = script.Parent
script:Destroy()