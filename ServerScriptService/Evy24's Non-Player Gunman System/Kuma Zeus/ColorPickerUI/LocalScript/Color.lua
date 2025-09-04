-- @ScriptType: ModuleScript
--[[

Circular Color Picker - by Trinkance

You are free to use this resource in any games or plugins

-------------------------------------------------------------------------

For more info:

https://devforum.roblox.com/t/1846195

--]]

--variables
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")

local Drag = require(script.Drag)

--module
local Color = {}
Color.__index = Color

--functions
function toPolar(v)
	return math.atan2(v.y,v.x),v.Magnitude
end

function radToDeg(x)
	return ((x + math.pi) / (2 * math.pi)) * 360;
end

function template(tab,template)
	tab = (tab and (typeof(tab) == "table")) and tab or {}
	for i,v in pairs(template) do
		if tab[i] == nil then
			tab[i] = v
		end
	end
	
	return tab
end

--rotate vector by degrees
function rotateVector(v,deg)
	local theta = math.rad(deg)
	local oldX,oldY = v.X,v.Y
	
	return Vector2.new(
		(oldX * math.cos(theta)) - (oldY * math.sin(theta)),
		(oldX * math.sin(theta)) + (oldY * math.cos(theta))
	)
end

--round number to nearest hundredths place
function roundToHundredths(num)
	return math.ceil(num * 100) / 100
end

--methods
function Color.New(gui : ScreenGui,mouse : PlayerMouse,params : any)
	params = template(params,{
		--Position = UDim2.fromOffset(mouse.X + 16,mouse.Y + 16),
		--Position = UDim2.fromOffset(200,100),
		Position = UDim2.new(0.4,0,0.2,0),
		Draggable = true,
		RoundedCorners = true,
		
		PrimaryColor = Color3.fromRGB(26,26,36),
		SecondaryColor = Color3.fromRGB(36,36,46),
		TopbarColor = Color3.fromRGB(21,21,31),
		TextColor = Color3.fromRGB(255,255,255)
	})
	
	local self = setmetatable({
		Gui = gui,
		Mouse = mouse,
		Color = Color3.fromRGB(255,255,255),
		Params = params
	},Color)
	
	--create
	self:Create()

	--wheel
	self._wheelDownFunc = nil
	self._wheelUpFunc_uis = nil

	local function _resetWheelFunc()
		if self._wheelDownFunc then
			self._wheelDownFunc:Disconnect()
			self._wheelDownFunc = nil
		end

		if self._wheelUpFunc_uis then
			self._wheelUpFunc_uis:Disconnect()
			self._wheelUpFunc_uis = nil
		end
	end

	self.Instance.Wheel.Button.MouseButton1Down:Connect(function()
		self.Instance.Parent.Topbar.Button.Visible = false
		_resetWheelFunc()

		self._wheelDownFunc = runService.Heartbeat:Connect(function()
			local pos = self:GetMouseToWheelPos()
			self.Instance.Wheel.Image.Select.Position = UDim2.fromOffset(pos.X,pos.Y)
			
			self:SetColorFromPos(pos)
		end)

		self._wheelUpFunc_uis = uis.InputEnded:Connect(function(input,typing)
			if typing then return end

			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				_resetWheelFunc()
			end
		end)
	end)

	self.Instance.Wheel.Button.MouseButton1Up:Connect(function()
		self.Instance.Parent.Topbar.Button.Visible = true
		_resetWheelFunc()
	end)

	--value
	self._valueDownFunc = nil
	self._valueUpFunc_uis = nil

	local function _resetValueFunc()
		if self._valueDownFunc then
			self._valueDownFunc:Disconnect()
			self._valueDownFunc = nil
		end

		if self._valueUpFunc_uis then
			self._valueUpFunc_uis:Disconnect()
			self._valueUpFunc_uis = nil
		end
	end

	self.Instance.Right.Value.Button.MouseButton1Down:Connect(function()
		self.Instance.Parent.Topbar.Button.Visible = false
		
		_resetValueFunc()
		self._valueDownFunc = runService.Heartbeat:Connect(function()
			local pos = self:GetMouseToValuePos()
			self.Instance.Right.Value.Select.Position = UDim2.new(0,0,pos,0)

			local hue,saturation,value = self.Color:ToHSV()
			self.Color = Color3.fromHSV(self.CurrentHue or hue,self.CurrentSaturation or saturation,1 - pos)
			
			self:UpdateColor()
		end)

		self._valueUpFunc_uis = uis.InputEnded:Connect(function(input,typing)
			if typing then return end

			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				_resetValueFunc()
			end
		end)
	end)

	self.Instance.Right.Value.Button.MouseButton1Up:Connect(function()
		self.Instance.Parent.Topbar.Button.Visible = true
		_resetValueFunc()
	end)

	--update
	self:UpdateColor()

	--buttons
	self.Instance.Bottom.Buttons.Confirm.MouseButton1Down:Connect(function()
		self.Instance.Parent.FinishedEvent:Fire(self.Color)
		self:Destroy()
	end)

	self.Instance.Bottom.Buttons.Cancel.MouseButton1Down:Connect(function()
		self.Instance.Parent.CanceledEvent:Fire()
		self:Destroy()
	end)
	
	--self.Instance.Parent.Parent:FindFirstChild('CustomsFrame'):FindFirstChild('OptionsFrame'):FindFirstChild('ReturnButton').MouseButton1Down:Connect(function()
	--	if not self.Instance.Parent then return end
	--	self.Instance.Parent.CanceledEvent:Fire()
	--	self:Destroy()
	--end)
	
	--for _,v in pairs(self.Instance.Parent.Parent:FindFirstChild('MainFrame'):FindFirstChild('PartyFrame'):FindFirstChild('ScrollingFrame'):GetChildren()) do
	--	if not self.Instance.Parent then return end
	--	v.SelectButton.MouseButton1Click:Connect(function()
	--		self.Instance.Parent.CanceledEvent:Fire()
	--		self:Destroy()
	--	end)
	--end


	--properties
	for i,v in pairs(self.Instance.Parent.Properties.RGB:GetChildren()) do
		if v:IsA("Frame") then
			v.Frame.TextBox.FocusLost:Connect(function()
				local thisText = v.Frame.TextBox.Text
				if not tonumber(thisText) then
					v.Frame.TextBox.Text = "0"
				end

				local r = tonumber(self.Instance.Parent.Properties.RGB.R.Frame.TextBox.Text) or 0
				local g = tonumber(self.Instance.Parent.Properties.RGB.G.Frame.TextBox.Text) or 0
				local b = tonumber(self.Instance.Parent.Properties.RGB.B.Frame.TextBox.Text) or 0
				r,g,b = math.clamp(r,0,255),math.clamp(g,0,255),math.clamp(b,0,255)

				self:SetColor(Color3.fromRGB(r,g,b))
			end)
		end
	end

	for i,v in pairs(self.Instance.Parent.Properties.HSV:GetChildren()) do
		if v:IsA("Frame") then
			v.Frame.TextBox.FocusLost:Connect(function()
				local thisText = v.Frame.TextBox.Text
				if not tonumber(thisText) then
					v.Frame.TextBox.Text = "0"
				end

				local h = tonumber(self.Instance.Parent.Properties.HSV.H.Frame.TextBox.Text) or 0
				local s = tonumber(self.Instance.Parent.Properties.HSV.S.Frame.TextBox.Text) or 0
				local v = tonumber(self.Instance.Parent.Properties.HSV.V.Frame.TextBox.Text) or 0
				h,s,v = math.clamp(h,0,360),math.clamp(s,0,1),math.clamp(v,0,1)
				
				self:SetColor(Color3.fromHSV(h / 360,s,v))
			end)
		end
	end

	self.Instance.Parent.Content.Bottom.Hex.Frame.TextBox.FocusLost:Connect(function()
		local hex = self.Instance.Parent.Content.Bottom.Hex.Frame.TextBox.Text
		local success,errMsg = pcall(function()
			hex = Color3.fromHex(hex)
		end)

		if not success then
			hex = Color3.fromRGB(255,255,255)
		end

		self.Instance.Parent.Content.Bottom.Hex.Frame.TextBox.Text = hex:ToHex()
		self:SetColor(hex)
	end)
	
	--return
	return self
end

--create window
function Color:Create()
	local sample = script.ColorWindow:Clone()
	sample.Position = self.Params.Position
	sample.Parent = self.Gui
	sample.Visible = true

	self.Instance = sample.Content
	
	--colors
	for i,v in pairs(sample:GetDescendants()) do
		if not self.Params.RoundedCorners and v:IsA("UICorner") and v.Parent.Name ~= "Select" then
			v:Destroy()
		end
		
		if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("ImageButton") then
			v[(v:IsA("TextLabel") or v:IsA("TextBox")) and "TextColor3" or "ImageColor3"] = self.Params.TextColor
		end
	end
	
	sample.BackgroundColor3 = self.Params.PrimaryColor
	sample.Properties.BackgroundColor3 = self.Params.PrimaryColor
	
	sample.Properties.Line.BackgroundColor3 = self.Params.SecondaryColor
	sample.Content.Bottom.Hex.Frame.BackgroundColor3 = self.Params.SecondaryColor
	for i,v in pairs({sample.Properties.HSV,sample.Properties.RGB}) do
		for q,e in pairs(v:GetChildren()) do
			if e:IsA("Frame") then
				e.Frame.BackgroundColor3 = self.Params.SecondaryColor
			end
		end
	end
	
	sample.Topbar.BackgroundColor3 = self.Params.TopbarColor
	sample.Topbar.Frame.BackgroundColor3 = self.Params.TopbarColor

	--events
	self.Finished = sample.FinishedEvent.Event
	self.Canceled = sample.CanceledEvent.Event
	self.Updated = sample.UpdateEvent.Event

	--drag
	if self.Params.Draggable and not uis.TouchEnabled then
		self.Drag = Drag.New(self.Instance.Parent)

		local dragButton = self.Instance.Parent.Topbar.Button
		dragButton.MouseButton1Down:Connect(function()
			self.Drag:Start()
		end)

		dragButton.MouseButton1Up:Connect(function()
			self.Drag:Stop()
		end)

		self._dragStopFunc = uis.InputEnded:Connect(function(input,typing)
			if typing then return end

			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				if self.Drag.Active then
					self.Drag:Stop()
				end
			end
		end)
	end
end

--destroy
function Color:Destroy()
	if self.Instance and self.Instance.Parent then
		self.Instance.Parent:Destroy()
	end

	if self._dragStopFunc then
		self._dragStopFunc:Disconnect()
		self._dragStopFunc = nil
	end
	
	--value funcs
	if self._valueDownFunc then
		self._valueDownFunc:Disconnect()
		self._valueDownFunc = nil
	end

	if self._valueUpFunc_uis then
		self._valueUpFunc_uis:Disconnect()
		self._valueUpFunc_uis = nil
	end
end

--return position for wheel select based on mouse position
function Color:GetMouseToWheelPos()
	local mousePos = Vector2.new(self.Mouse.X,self.Mouse.Y)
	local wheelPosition = self.Instance.Wheel.Image.AbsolutePosition
	local wheelSize = self.Instance.Wheel.Image.AbsoluteSize
	
	local toWheelPos = (mousePos - wheelPosition)
	local wheelMidPos = wheelPosition + (wheelSize / 2)
	local maxDist = (wheelSize.X / 2)
	
	local toMidPos = (wheelMidPos - mousePos)
	if toMidPos.Magnitude > maxDist then
		return (wheelSize / 2) - (toMidPos.Unit * maxDist)
	else
		return toWheelPos
	end
end

--return position for value select based on mouse position
function Color:GetMouseToValuePos()
	local mousePos = Vector2.new(self.Mouse.X,self.Mouse.Y)
	local valuePosition = self.Instance.Right.Value.AbsolutePosition
	local valueSize = self.Instance.Right.Value.AbsoluteSize
	
	return math.clamp((mousePos.Y - valuePosition.Y) / valueSize.Y,0,1)
end

--update colors
function Color:UpdateColor()
	self.Instance.Parent.UpdateEvent:Fire(self.Color)
	self.Instance.Bottom.Color.Frame.BackgroundColor3 = self.Color
	
	self.Instance.Parent.Properties.RGB.R.Frame.TextBox.Text = math.floor((self.Color.R * 255) + 0.5)
	self.Instance.Parent.Properties.RGB.G.Frame.TextBox.Text = math.floor((self.Color.G * 255) + 0.5)
	self.Instance.Parent.Properties.RGB.B.Frame.TextBox.Text = math.floor((self.Color.B * 255) + 0.5)
	
	local h,s,v = self.Color:ToHSV()
	self.Instance.Parent.Properties.HSV.H.Frame.TextBox.Text = math.floor((h * 360) + 0.5)
	self.Instance.Parent.Properties.HSV.S.Frame.TextBox.Text = roundToHundredths(s)
	self.Instance.Parent.Properties.HSV.V.Frame.TextBox.Text = roundToHundredths(v)
	
	local hex = self.Color:ToHex()
	self.Instance.Parent.Content.Bottom.Hex.Frame.TextBox.Text = string.format("#%s",string.lower(hex))
end

--set color from pos and update wheel and value selects
function Color:SetColorFromPos(pos : Vector2)
	local wheelSize = self.Instance.Wheel.Image.AbsoluteSize
	local wheelMidPos = (wheelSize / 2)
	
	local toMidPos = (wheelMidPos - pos)
	local maxDist = (wheelSize.X / 2)
	
	local dist = math.min(toMidPos.Magnitude,maxDist)
	
	--thanks for egomoose for the code on the roblox devforum
	local phi,len = toPolar(toMidPos * Vector2.new(-1,1));
	local hue,saturation = radToDeg(phi) / 360,len / maxDist;
	hue,saturation = math.clamp(hue,0,1),math.clamp(saturation,0,1)
	
	local _hue,_saturation,value = self.Color:ToHSV()
	self.Color = Color3.fromHSV(hue,saturation,value)
	
	self:UpdateColor()
	self:SetValueGradient(hue,saturation)
end

--set gradient for value slider
function Color:SetValueGradient(hue : number,saturation : number)
	self.CurrentSaturation = saturation
	self.CurrentHue = hue
	
	local color = Color3.fromHSV(hue,saturation,1)
	self.Instance.Right.Value.UIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,color),
		ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))
	})
end

--set color
function Color:SetColor(color : Color3)
	local hue,saturation,value = color:ToHSV()
	self.Color = color
	
	local wheelSize = self.Instance.Wheel.Image.AbsoluteSize
	local wheelMidPos = (wheelSize / 2)
	local maxDist = (wheelSize.X / 2)
	
	local vector = Vector2.new(0.5,0.5)
	
	local hueVector = Vector2.new(-1,0)
	hueVector = rotateVector(hueVector,hue * -360)
	hueVector = rotateVector(hueVector,180)
	
	vector -= hueVector * saturation * 0.5
	self.Instance.Wheel.Image.Select.Position = UDim2.fromScale(vector.X,vector.Y)
	self.Instance.Right.Value.Select.Position = UDim2.new(0,0,1 - value,0)
	
	self:UpdateColor()
	self:SetValueGradient(hue,saturation)
end

return Color