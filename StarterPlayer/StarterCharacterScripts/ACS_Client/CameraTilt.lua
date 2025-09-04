-- @ScriptType: LocalScript
-- << Variables >> --

local Player = game:GetService("Players").LocalPlayer
local rn = game:GetService('RunService')
local Mouse = Player:GetMouse()
local Camera = game:GetService("Workspace").CurrentCamera
local UserInputService = game:GetService("UserInputService")
local bobbing = nil
local func1 = 0
local func2 = 0
local func3 = 0
local func4 = 0
local val = 0
local val2 = 0
local int = 1
local int2 = 1
local vect3 = Vector3.new()

local teams = game:GetService("Teams")
local Humanoid = Player.Character:WaitForChild("Humanoid")

-- << Functions >> --

function lerp(a, b, c)
	return a + (b - a) * c
end

local zoom = false

local conn = nil

local function renderFunction(deltaTime)
	deltaTime = deltaTime * 25
	if Humanoid.Health <= 0 then
		bobbing:Disconnect()
		return
	end
	local rootMagnitude = Humanoid.RootPart and Vector3.new(Humanoid.RootPart.Velocity.X, 0, Humanoid.RootPart.Velocity.Z).Magnitude or 0
	local calcRootMagnitude = math.min(rootMagnitude, 50)

	Camera.CFrame = Camera.CFrame * (CFrame.fromEulerAnglesXYZ(0, 0, math.rad(func3)) * CFrame.fromEulerAnglesXYZ(math.rad(func4 * deltaTime), math.rad(val * deltaTime), val2) * CFrame.Angles(0, 0, math.rad(func4 * deltaTime * (calcRootMagnitude / 2))) * CFrame.fromEulerAnglesXYZ(math.rad(func1), math.rad(func2), math.rad(func2 * 0)))

	func3 = lerp(func3, math.clamp(UserInputService:GetMouseDelta().X, -3, 3), 0.1 * deltaTime)
	-- Humanoid.SeatPart == nil and
	if not Player:GetAttribute('Recon') and not Player.Character:GetAttribute('Dreadnaught') and zoom then
		--if zoom then
		Player.CameraMaxZoomDistance = 0.5
		--else
		--Player.CameraMaxZoomDistance = 14
		--end
	elseif not zoom or (zoom and (Humanoid.SeatPart ~= nil or Player:GetAttribute('Recon') == true or Player.Character:GetAttribute('Dreadnaught') == true)) then
		Player.CameraMaxZoomDistance = 14
	end
end

Player:GetAttributeChangedSignal("InMenu"):Connect(function()
	if Player:GetAttribute('InMenu') == false then
		conn = rn.RenderStepped:Connect(renderFunction)
		Player:GetAttributeChangedSignal('Zeus'):Connect(function()
			if Player:GetAttribute('Zeus') == true then
				if zoom then Player.CameraMaxZoomDistance = 0.5 end
				conn:Disconnect()
				conn = nil
			else
				Player.CameraMaxZoomDistance = 14
				if conn == nil then
					conn = rn.RenderStepped:Connect(renderFunction)
				end
			end
		end)
	end
end)

local perma = game:GetService('ReplicatedStorage'):WaitForChild('PermaDeath')

perma.Changed:Connect(function()
	if perma.Value == true then
		zoom = true
		-- Humanoid.SeatPart == nil and
		if Player.Team.Name ~= "Zeus" and not Player:GetAttribute('Recon') and not Player.Character:GetAttribute('Dreadnaught') and not Player.Character:FindFirstChild('Fishing Rod') then
			Player.CameraMaxZoomDistance = 0.5
		end
	else
		zoom = false
		Player.CameraMaxZoomDistance = 14
	end
end)
