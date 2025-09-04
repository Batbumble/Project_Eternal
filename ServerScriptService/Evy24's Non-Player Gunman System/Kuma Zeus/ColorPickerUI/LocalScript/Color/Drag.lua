-- @ScriptType: ModuleScript
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local Drag = {}
Drag.__index = Drag

function Drag.New(window)
	local self = setmetatable({},Drag)
	self.Instance = window
	self.Active = false
	
	return self
end

function Drag:Start()
	if not self.Active then
		self.Active = true
		
		local startMousePos = uis:GetMouseLocation()
		local startWindowPos = self.Instance.Position
		self._dragFunc = runService.Heartbeat:Connect(function()
			local mousePos = uis:GetMouseLocation()
			local pos = (mousePos - startMousePos)
			self.Instance.Position = startWindowPos + UDim2.fromOffset(pos.X,pos.Y)
		end)
	end
end

function Drag:Stop()
	self.Active = false
	if self._dragFunc then
		self._dragFunc:Disconnect()
		self._dragFunc = nil
	end
end

return Drag