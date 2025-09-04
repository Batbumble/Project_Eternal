-- @ScriptType: LocalScript
local Player = game:GetService("Players").LocalPlayer
local rn = game:GetService('RunService')
local Char = Player.Character;
script:WaitForChild("SwayMult");
function SwayAmount(p1)
	return (p1 / 8 + 0.2) ^ 2;
end;
local u1 = false;
Char.ChildAdded:Connect(function(p2)
	if p2:IsA("Tool") then
		u1 = true;
	end;
end);
Char.ChildRemoved:Connect(function(p3)
	if p3:IsA("Tool") then
		u1 = false;
	end;
end);
local l__Value__2 = script.MinimumWalkSpeed.Value;
game.Players.LocalPlayer.Character.Humanoid.Running:Connect(function(p4)
	if l__Value__2 <= p4 then
		walking = true;
		return;
	end;
	walking = false;
end);
game.Players.LocalPlayer.Character.Humanoid.Seated:Connect(function()
	walking = false;
end);
local u3 = CFrame.new();
local u4 = 0;
local MaximumHorizontal = script.MaximumSway.Horizontal.Value;
local MultHorizontal = script.SwayMult.Horizontal.Value;
local MaximumVertical = script.MaximumSway.Vertical.Value;
local MultVertical = script.SwayMult.Vertical.Value;
local MaximumTilt = script.MaximumSway.Tilt.Value;
local MultTilt = script.SwayMult.Tilt.Value;
local SwayStepRate = script.SwayStepRate.Value;
local SwayRecoverRate = script.SwayRecoverRate.Value;

local conn = nil

local function renderFunction(p5)
	workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * u3;
	local v2 = game.Players.LocalPlayer.Character.Humanoid.WalkSpeed / 2;
	u4 = u4 + p5 * v2;
	if not walking then
		u3 = u3:lerp(CFrame.new(), math.min(1, SwayRecoverRate * p5 * 60));
		return;
	end;
	u3 = u3:lerp(CFrame.new(math.min(SwayAmount(v2), MaximumHorizontal) * MultHorizontal * math.sin(u4), math.min(SwayAmount(v2), MaximumVertical) * MultVertical * -math.cos(u4 * 2), 0) * CFrame.Angles(0, 0, math.min(SwayAmount(v2), MaximumTilt) * MultTilt * -math.sin(u4)), math.min(1, SwayStepRate * p5 * 60));
end

conn = rn.RenderStepped:Connect(renderFunction)

Player:GetAttributeChangedSignal('Zeus'):Connect(function()
	if Player:GetAttribute('Zeus') == true then
		conn:Disconnect()
		conn = nil
	elseif conn == nil then
		conn = rn.RenderStepped:Connect(renderFunction)
	end
end)