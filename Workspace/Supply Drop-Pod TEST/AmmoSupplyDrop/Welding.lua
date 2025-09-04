-- @ScriptType: Script
function Weld(x,y)
	local W = Instance.new("Weld")
	W.Part0 = x
	W.Part1 = y
	local CJ = CFrame.new(x.Position)
	local C0 = x.CFrame:inverse()*CJ
	local C1 = y.CFrame:inverse()*CJ
	W.C0 = C0
	W.C1 = C1
	W.Parent = x
end

function Get(A)
	if (A.className == "Part") or (A.className == "UnionOperation") or (A.className == "MeshPart") then
		Weld(script.Parent.Collision, A)
	else
		local C = A:GetChildren()
		for i=1, #C do
		Get(C[i])
		end
	end
end

function Finale()
	Get(script.Parent)
end

Finale()
