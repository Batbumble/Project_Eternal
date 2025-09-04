-- @ScriptType: LocalScript
local colorModule = require(script:WaitForChild('Color'))
local mouse = game.Players.LocalPlayer:GetMouse()
local data = {}


local self = colorModule.New(script.Parent,mouse)
--local toBeColored = script.Parent.ToColor.Value
--local originalColor = Color3.new(toBeColored.VertexColor.X,toBeColored.VertexColor.Y,toBeColored.VertexColor.Z)

local toBeColored = game:GetService('Lighting'):WaitForChild('Atmosphere')
local originalColor = toBeColored.Color

self:SetColor(originalColor)

self.Finished:Connect(function(color)
	toBeColored.Color = color
	--menuEvents:WaitForChild('ColorEvent',3):FireServer({color.R,color.G,color.B})
	data.Color = color
	game:GetService('ReplicatedStorage'):WaitForChild('Fog'):FireServer(data)
	script.Parent:Destroy()
end)

self.Updated:Connect(function(color)
	toBeColored.Color = color
end)