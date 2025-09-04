-- @ScriptType: LocalScript
-- params : ...

local smoothness = 10
wait(1)
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local dev = script.Parent
local lastY = 0
local units = {[dev.N] = -math.pi * 4 / 4, [dev["5"]] = -math.pi * 35 / 36, [dev["10"]] = -math.pi * 34 / 36, [dev["15"]] = -math.pi * 11 / 12, [dev["20"]] = -math.pi * 32 / 36, [dev["25"]] = -math.pi * 31 / 36, [dev["30"]] = -math.pi * 10 / 12, [dev["35"]] = -math.pi * 29 / 36, [dev["40"]] = -math.pi * 28 / 36, [dev.NE] = -math.pi * 3 / 4, [dev["50"]] = -math.pi * 26 / 36, [dev["55"]] = -math.pi * 25 / 36, [dev["60"]] = -math.pi * 8 / 12, [dev["65"]] = -math.pi * 23 / 36, [dev["70"]] = -math.pi * 22 / 36, [dev["75"]] = -math.pi * 7 / 12, [dev["80"]] = -math.pi * 20 / 36, [dev["85"]] = -math.pi * 19 / 36, [dev.E] = -math.pi * 2 / 4, [dev["95"]] = -math.pi * 17 / 36, [dev["100"]] = -math.pi * 16 / 36, [dev["105"]] = -math.pi * 5 / 12, [dev["110"]] = -math.pi * 14 / 36, [dev["115"]] = -math.pi * 13 / 36, [dev["120"]] = -math.pi * 4 / 12, [dev["125"]] = -math.pi * 11 / 36, [dev["130"]] = -math.pi * 10 / 36, [dev.SE] = -math.pi * 1 / 4, [dev["140"]] = -math.pi * 8 / 36, [dev["145"]] = -math.pi * 7 / 36, [dev["150"]] = -math.pi * 2 / 12, [dev["155"]] = -math.pi * 5 / 36, [dev["160"]] = -math.pi * 4 / 36, [dev["165"]] = -math.pi * 1 / 12, [dev["170"]] = -math.pi * 2 / 36, [dev["175"]] = -math.pi * 1 / 36, [dev.S] = math.pi * 0 / 4, [dev["185"]] = math.pi * 1 / 36, [dev["190"]] = math.pi * 2 / 36, [dev["195"]] = math.pi * 1 / 12, [dev["200"]] = math.pi * 4 / 36, [dev["205"]] = math.pi * 5 / 36, [dev["210"]] = math.pi * 2 / 12, [dev["215"]] = math.pi * 7 / 36, [dev["220"]] = math.pi * 8 / 36, [dev.SW] = math.pi * 1 / 4, [dev["230"]] = math.pi * 10 / 36, [dev["235"]] = math.pi * 11 / 36, [dev["240"]] = math.pi * 4 / 12, [dev["245"]] = math.pi * 13 / 36, [dev["250"]] = math.pi * 14 / 36, [dev["255"]] = math.pi * 5 / 12, [dev["260"]] = math.pi * 16 / 36, [dev["265"]] = math.pi * 17 / 36, [dev.W] = math.pi * 2 / 4, [dev["275"]] = math.pi * 19 / 36, [dev["280"]] = math.pi * 20 / 36, [dev["285"]] = math.pi * 7 / 12, [dev["290"]] = math.pi * 22 / 36, [dev["295"]] = math.pi * 23 / 36, [dev["300"]] = math.pi * 8 / 12, [dev["305"]] = math.pi * 25 / 36, [dev["310"]] = math.pi * 26 / 36, [dev.NW] = math.pi * 3 / 4, [dev["320"]] = math.pi * 28 / 36, [dev["325"]] = math.pi * 29 / 36, [dev["330"]] = math.pi * 10 / 12, [dev["335"]] = math.pi * 31 / 36, [dev["340"]] = math.pi * 32 / 36, [dev["345"]] = math.pi * 11 / 12, [dev["350"]] = math.pi * 34 / 36, [dev["355"]] = math.pi * 35 / 36}
local round = function(num, numDecimalPlaces)	
	local mult = 10 ^ (numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

restrictAngle = function(angle)	
	if angle < -math.pi then
		return angle + math.pi * 2
	else
		if math.pi < angle then
			return angle - math.pi * 2
		else
			return angle
		end
	end
end

game:GetService("RunService").RenderStepped:Connect(function(delta)
	local look = camera.CoordinateFrame.lookVector
	local look = Vector3.new(look.x, 0, look.z).unit
	local lookY = math.atan2(look.z, look.x)
	local difY = restrictAngle(lookY - lastY)
	lookY = restrictAngle(lastY + difY * delta * smoothness)
	lastY = lookY
	for unit,rot in pairs(units) do
		rot = restrictAngle(lookY - rot)
		if math.sin(rot) > 0 then
			local cosRot = math.cos(rot)
			local cosRot2 = cosRot * cosRot
			unit.Visible = true
			unit.Position = UDim2.new(0.5 + cosRot * 0.6, unit.Position.X.Offset, 0, 3)
			unit.TextTransparency = -0.25 + 1.25 * cosRot2
		else
			unit.Visible = false
		end
	end
end)
