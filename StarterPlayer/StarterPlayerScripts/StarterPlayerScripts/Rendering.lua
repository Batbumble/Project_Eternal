-- @ScriptType: LocalScript
-- services
local rs = game:GetService('ReplicatedStorage')

-- rs
local common, remotes = rs:WaitForChild('Common'), rs:WaitForChild('Remotes')
local resources = common:WaitForChild('Resources')
local rModules = resources:WaitForChild('RenderingModules')

-- tables
local Rendering = {}

-- // Init
for index, module in pairs(rModules:GetChildren()) do
	Rendering[module.Name] = require(module)
end

-- // Connections

remotes:WaitForChild('RenderRequest').OnClientEvent:Connect(function(...)
	local data = {...}
	if not Rendering[data[1]] then warn('The rendering module you\'re looking for doesn\'t exist!') return end
	Rendering[data[1]].Fire(data)
end)