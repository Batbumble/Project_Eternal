-- @ScriptType: Script
local humanoid = script.Parent:WaitForChild('Humanoid')
local healthGui = script.Parent:WaitForChild('HealthGui')
local healthMeter = healthGui:WaitForChild('Background'):WaitForChild('Meter')

humanoid:GetPropertyChangedSignal('Health'):Connect(function()
	local healthChange = humanoid.Health / humanoid.MaxHealth
	local healthColor = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), healthChange)
	healthMeter:TweenSize(UDim2.new(healthChange, 0, 1, 0), 'Out', 'Sine', 0.1)
	healthMeter.BackgroundColor3 = healthColor
end)