-- @ScriptType: LocalScript
local cs = game:GetService("CollectionService")
local rs = game:GetService("RunService")

rs.RenderStepped:Connect(function()
	for _,v in pairs(cs:GetTagged("MatchingAttachment")) do
		local matchTo = v.Following.Value
		v.WorldPosition = matchTo.WorldPosition
	end
end)