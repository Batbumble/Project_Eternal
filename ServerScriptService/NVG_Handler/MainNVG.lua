-- @ScriptType: LocalScript
local plr = game.Players.LocalPlayer
local nvgevent = game.ReplicatedStorage:WaitForChild("nvg")
local nvgevent2 = game.ReplicatedStorage:WaitForChild("nvg2")
local actionservice = game:GetService("ContextActionService")
local tweenservice = game:GetService("TweenService")
--local colorcorrection = Instance.new("ColorCorrectionEffect")
local nvgPrefix = "NVG_"
local L = game:GetService('Lighting')
local dof = L[nvgPrefix.."DepthOfField"]
--local colorcorrection = L[nvgPrefix.."ColorCorrection"]
local bloom = L[nvgPrefix.."Bloom"]
local blur = L[nvgPrefix.."Blur"]
_G.FLIRActiv = false
--colorcorrection.Parent = game.Lighting


--//DEFAULT VALUES

local defexposure = game.Lighting.ExposureCompensation
local nvg
local onanim
local gui
local offanim
local config
local onremoved
local setting
local helmet
--misctoggle = false
local miscon
local miscoff

function removehelmet()
	if plr.Character and helmet then
		onremoved:Disconnect()
		animating = false
		togglenvg(false)
		actionservice:UnbindAction("nvgtoggle")
		actionservice:UnbindAction("NVGMisc")
		actionservice:UnbindAction("nvgremove")
		if gui then
			gui:Destroy()
		end
		_G.FLIRActiv = false
		if helmet then
			helmet:Destroy()
		end
		if plr.PlayerGui:FindFirstChild("flir") then
			wait(.1)
			plr.PlayerGui:FindFirstChild("flir"):Destroy()
		end
	end
end

function oncharadded(newchar)
	newchar:WaitForChild("Humanoid").Died:connect(function()
		removehelmet()
	end)
	newchar.ChildAdded:connect(function(child)
		local removebutton
		if child.Name == "Helmet" then
			helmet = child
			gui = Instance.new("ScreenGui")
			gui.IgnoreGuiInset = true

			removebutton = Instance.new("TextButton")
			removebutton.Text = "Helmet"
			removebutton.Size = UDim2.new(.05,0,.035,0)
			removebutton.TextColor3 = Color3.new(.75,.75,.75)
			removebutton.Position = UDim2.new(.1,0,.3,0)
			removebutton.BackgroundTransparency = .45
			removebutton.BackgroundColor3 = Color3.fromRGB(124, 52, 38)
			removebutton.Font = Enum.Font.SourceSansBold
			removebutton.TextScaled = true
			removebutton.MouseButton1Down:connect(removehelmet)

			removebutton.Parent = gui
			removebutton.Visible = false
			gui.Parent = plr.PlayerGui

			onremoved = child.AncestryChanged:Connect(function(_, parent)
				if not parent then
					removehelmet()
				end
			end)
		end
		local newnvg = child:WaitForChild("Up",.5)
		local gcc = game:GetService("Lighting"):FindFirstChild("GameColorCorrection")
		
		local oldTint = gcc.TintColor
		local oldContrast = gcc.Contrast
		local oldBright = gcc.Brightness
		local oldSatur = gcc.Saturation
		
		if newnvg then
			nvg = newnvg
			if nvg:FindFirstChild("AUTO_CONFIG") then
				config = require(nvg:WaitForChild("AUTO_CONFIG"))
				setting = nvg:WaitForChild("NVG_Settings")
				if setting:FindFirstChild("FLIR") and plr.PlayerGui:FindFirstChild("flir") == nil then
					local flirscript = script.flir:Clone()
					flirscript.Parent = plr.PlayerGui
					flirscript.Disabled = false

				end

				local noise = Instance.new("ImageLabel")
				noise.BackgroundTransparency = 1
				noise.ImageTransparency = 1

				local overlay = noise:Clone()
				overlay.Image = "rbxassetid://"..setting.OverlayImage.Value
				overlay.Size = UDim2.new(1,0,1,0)
				overlay.Name = "Overlay"

				local buttonpos = setting.RemoveButtonPosition.Value
				removebutton.Position = UDim2.new(buttonpos.X,0,buttonpos.Y,0)

				noise.Name = "Noise"
				noise.AnchorPoint = Vector2.new(.5,.5)
				noise.Position = UDim2.new(.5,0,.5,0)
				noise.Size = UDim2.new(2,0,2,0)


				overlay.Parent = gui
				noise.Parent = gui

				local info = config.tweeninfo

				local function addtweens(base,extra)
					if extra then
						for _,tween in pairs(extra)do
							table.insert(base,tween)
						end
					end
				end

				onanim = config.onanim
				offanim = config.offanim
				if config.miscon ~= nil then
					miscon = config.miscon
					miscoff = config.miscoff
				end

				on_overlayanim = {
					tweenservice:Create(game.Lighting,info,{ExposureCompensation = setting.Exposure.Value}),
					--tweenservice:Create(game:GetService("Lighting"):FindFirstChild("GameColorCorrection"),info,{Brightness = setting.OverlayBrightness.Value, Contrast = setting.OverlayContrast.Value,Saturation = -1, TintColor  = setting.OverlayColor.Value}),
					tweenservice:Create(game.Lighting.GameColorCorrection,info,{Brightness = setting.OverlayBrightness.Value,Contrast = setting.OverlayContrast.Value,Saturation = -1,TintColor = setting.OverlayColor.Value}),
					tweenservice:Create(gui.Overlay,info,{ImageTransparency = 0.1}),
					tweenservice:Create(gui.Noise,info,{ImageTransparency = 0}),
					tweenservice:Create(bloom,info,{Intensity = 5,Size = setting.OverlayBloomSize.Value,Threshold = 1.1}),
					tweenservice:Create(blur,info,{Size = 5}),
					tweenservice:Create(dof,info,{InFocusRadius = 465, NearIntensity = .3})
				}


				off_overlayanim = {
					tweenservice:Create(game.Lighting,info,{ExposureCompensation = defexposure}),
					--tweenservice:Create(game:GetService("Lighting"):FindFirstChild("GameColorCorrection"),info,{Brightness = oldBright, Contrast = oldContrast,Saturation = oldSatur, TintColor  = oldTint}),
					tweenservice:Create(game.Lighting.GameColorCorrection,info,{Brightness = oldBright, Contrast = oldContrast,Saturation = oldSatur,TintColor = oldTint}),
					tweenservice:Create(gui.Overlay,info,{ImageTransparency = 1}),
					tweenservice:Create(gui.Noise,info,{ImageTransparency = 1}),
					tweenservice:Create(bloom,info,{Intensity = .3,Size = 200,Threshold = 1.45}),
					tweenservice:Create(blur,info,{Size = 1}),
					tweenservice:Create(dof,info,{InFocusRadius = 470, NearIntensity = 0.1})
				}


				actionservice:BindAction("nvgtoggle",function() togglenvg(not nvgactive) return Enum.ContextActionResult.Pass end, true, Enum.KeyCode.N)
				actionservice:BindAction("nvgremove",function() removehelmet() return Enum.ContextActionResult.Pass end, true, Enum.KeyCode.Delete)
				if setting:FindFirstChild("Misc") ~= nil and miscon ~= nil and miscoff ~= nil then
					actionservice:BindAction("NVGMisc",function() togglemisc(not misctoggle) return Enum.ContextActionResult.Pass end, true, Enum.KeyCode.Y)
				end
			end
		end
	end)
end

plr.CharacterAdded:connect(oncharadded)

local oldchar = workspace:FindFirstChild(plr.Name)
if oldchar then
	oncharadded(oldchar)
end


function playtween(tweentbl)
	spawn(function()
		for _,step in pairs(tweentbl) do
			if typeof(step) == "number" then
				wait(step)
			else
				step:Play()
			end
		end
	end)
end

function applyprops(obj,props)
	for propname,val in pairs(props)do
		obj[propname] = val
	end
end

function cycle(grain)
	local label = gui.Noise
	local source = grain.src
	local newframe
	repeat newframe = source[math.random(1, #source)]; 
	until newframe ~= grain.last 
	label.Image = 'rbxassetid://'..newframe
	local rand = math.random(230,255)
	label.Position = UDim2.new(math.random(.4,.6),0,math.random(.4,.6),0)
	label.ImageColor3 = Color3.fromRGB(rand,rand,rand)
	grain.last = newframe
end

local Wew

function togglenvg(bool)	
	local As_Check = true
	Wew = game.Players.LocalPlayer:FindFirstChild("HelmetIsOff")
	
	if Wew and Wew.Value then
		As_Check = false
	end
	
	if not animating and nvg and gui:FindFirstChild("TextButton") ~= nil and As_Check then
		nvgevent:FireServer()
		--gui.TextButton.Visible = false
		animating = true
		nvgactive = bool
		
		
		if config.lens then
			config.lens.Material = bool and "Neon" or "Glass"
			config.lens2.Material = bool and "Neon" or "Glass"
			config.lens3.Material = bool and "Neon" or "Glass"
			config.lens4.Material = bool and "Neon" or "Glass"
		end
		if bool then
			playtween(onanim)
			
			delay(.75,function()
			if misctoggle == true or miscon == nil and miscoff == nil then
				playtween(on_overlayanim)
				if setting:FindFirstChild("FLIR") then
					setting.FLIR.Value = true
					_G.FLIRActiv = true
				end
				config.lens.ON2:Play()
				config.lens.ON:Play()
				spawn(function()
					while nvgactive do 
						cycle(config.dark)
						cycle(config.light)
						wait(0.05)
					end
					end)
				end
				animating = false
			end)
		else
			playtween(offanim)
			delay(.5,function()
				playtween(off_overlayanim)
				if setting:FindFirstChild("FLIR") then
					setting.FLIR.Value = false
					_G.FLIRActiv = false
				end
				animating = false
			end)
		end
	end	
end

function togglemisc(bool)
	if not animating and nvg and gui:FindFirstChild("TextButton") ~= nil and setting:FindFirstChild("Misc") ~= nil then
		nvgevent2:FireServer()
		--gui.TextButton.Visible = not bool
		animating = true
		misctoggle = bool
		if bool and miscon ~= nil and miscoff ~= nil then
			playtween(miscon)
			delay(.75,function()
				if nvgactive == true and misctoggle == true then
					playtween(on_overlayanim)
					if setting:FindFirstChild("FLIR") then
						setting.FLIR.Value = true
						_G.FLIRActiv = true
					end
					config.lens.ON2:Play()
					config.lens.ON:Play()
					spawn(function()
						while nvgactive do 
							cycle(config.dark)
							cycle(config.light)
							wait(0.05)
						end
					end)
				end
				animating = false
			end)
		else
			playtween(miscoff)
			delay(.5,function()
				--nvgactive = false
				playtween(off_overlayanim)
				if setting:FindFirstChild("FLIR") then
					setting.FLIR.Value = false
					_G.FLIRActiv = false
				end
				animating = false
			end)
		end
	end	
end

nvgevent.OnClientEvent:connect(function(nvg,activate)
	if nvg:FindFirstChild("twistjoint") then
		local twistjoint = nvg:FindFirstChild("twistjoint")
		
		local success, config = pcall(function()
			return require(nvg.AUTO_CONFIG)
		end)
		
		if success then
			local lens = config.lens
			local lens2 = config.lens2
			local lens3 = config.lens3
			local lens4 = config.lens4
			if lens then
				lens.Material = activate and "Neon" or "Glass"
				lens2.Material = activate and "Neon" or "Glass"
				lens3.Material = activate and "Neon" or "Glass"
				lens4.Material = activate and "Neon" or "Glass"
				
			end
			playtween(config[activate and "onanim" or "offanim"])
		end
	end
end)

nvgevent2.OnClientEvent:connect(function(nvg,activate)
	local twistjoint = nvg:WaitForChild("twistjoint")
	local config = require(nvg.AUTO_CONFIG)
	local lens = config.lens
	local lens2 = config.lens2
	local lens3 = config.lens3
	local lens4 = config.lens4
	
	if lens then
		lens.Material = activate and "Neon" or "Glass"
		lens2.Material = activate and "Neon" or "Glass"
		lens3.Material = activate and "Neon" or "Glass"
		lens4.Material = activate and "Neon" or "Glass"
	end
	playtween(config[activate and "miscon" or "miscoff"])
end)

local lighting = game.Lighting
local rs = game.ReplicatedStorage

local autolighting = rs:WaitForChild("EnableAutoLighting")

if autolighting.Value then
	
	function llerp(a,b,t)
		return a*(1-t)+b*t
	end
	
	local minbrightness = rs:WaitForChild("MinBrightness").Value
	local maxbrightness = rs:WaitForChild("MaxBrightness").Value
	local minambient = rs:WaitForChild("MinAmbient").Value
	local maxambient = rs:WaitForChild("MaxAmbient").Value
	local minoutdoor = rs:WaitForChild("MinOutdoorAmbient").Value
	local maxoutdoor = rs:WaitForChild("MaxOutdoorAmbient").Value

	function setdaytime()
		local newtime = lighting.ClockTime
		local middaydiff = math.abs(newtime-12)
		local f = (1-middaydiff/12)
		lighting.Brightness = llerp(minbrightness,maxbrightness,f)
		lighting.Ambient = minambient:lerp(maxambient,f)
		lighting.OutdoorAmbient = minoutdoor:lerp(maxoutdoor,f)
	end
	
	game:GetService("RunService").RenderStepped:connect(setdaytime)

end