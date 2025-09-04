-- @ScriptType: LocalScript
local TweenService = game:GetService('TweenService')
local text = script.Parent.TextLabel
local image = script.Parent.ImageLabel
local Event = game:GetService("ReplicatedStorage"):WaitForChild("Dead",4)
local perma = game:GetService("ReplicatedStorage"):WaitForChild("perma",5)
local unhide = game:GetService("ReplicatedStorage"):WaitForChild("unhide",5)
local blocker = script.Parent:WaitForChild('Blocker')

local StarterGui = game:GetService("StarterGui")
local tweenTime = 2.5
local twoSecTween = TweenInfo.new(tweenTime)

perma.OnClientEvent:Connect(function(value)
	if value then
		game.Lighting.ExposureCompensation = game.Lighting:GetAttribute('OES')
		game.Lighting.Ambient = game.Lighting:GetAttribute('OA')
		game.Lighting.Atmosphere.Density = game.Lighting:GetAttribute('OAD')
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
		script.Parent["Ominous Notification"]:Play()
		TweenService:Create(image, TweenInfo.new(3), {ImageTransparency = 0.26}):Play()
		TweenService:Create(text, TweenInfo.new(3), {TextTransparency = 0.26}):Play()
		wait(5)
		TweenService:Create(image, TweenInfo.new(3), {ImageTransparency = 0.9}):Play()
		TweenService:Create(text, TweenInfo.new(3), {TextTransparency = 0.9}):Play()
	else
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
		TweenService:Create(image, TweenInfo.new(3), {ImageTransparency = 1}):Play() 
		TweenService:Create(text, TweenInfo.new(3), {TextTransparency = 1}):Play()
		--blocker.Visible = false
	end
end)

Event.OnClientEvent:Connect(function(value)
	image.ImageTransparency = 1
	text.TextTransparency = 1
end)

unhide.OnClientEvent:Connect(function()
	
	--blocker.BackgroundTransparency = 1
	--blocker.Info.TextTransparency = 1
	--blocker.Visible = true
	--task.wait(1)
	--TweenService:Create(blocker,twoSecTween,{BackgroundTransparency = 0}):Play()
	--task.wait(tweenTime)
	--TweenService:Create(blocker.Info,twoSecTween,{TextTransparency = 0}):Play()
	--task.wait(tweenTime+5)
	--TweenService:Create(blocker.Info,twoSecTween,{TextTransparency = 1}):Play()
	--task.wait(tweenTime/3)
	--TweenService:Create(blocker,twoSecTween,{BackgroundTransparency = 1}):Play()
	
	--game.Lighting.ExposureCompensation = 0.5
	--game.Lighting.Ambient = Color3.new(0.7,0.7,0.7)
	--game.Lighting.Atmosphere.Density = 0
	game:GetService('Lighting').Atmosphere:GetPropertyChangedSignal('Density'):Connect(function()
		if not blocker.Visible then return end
		game.Lighting.Atmosphere.Density = 0
	end)
end)

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Tweening = nil

game.ReplicatedStorage:WaitForChild("Story").OnClientEvent:Connect(function(Tone,Text)
	if Tweening ~= nil then
		Tweening:Cancel()
		wait()
		Tweening = TweenService:Create(script.Parent.Story,TweenInfo.new(.5),{TextTransparency = 1})
		Tweening:Play()
		wait(.5)
	end
	wait()
	if Tone == "Narrative" then
		script.Parent.Story.TextSize = 40
		script.Parent.Story.TextColor3 = Color3.new(1, 1, 1)
		script.Parent.Story.Font = Enum.Font.Merriweather
	elseif Tone == "Despair" then
		script.Parent.Story.TextSize = 45
		script.Parent.Story.TextColor3 = Color3.new(1, 0.172549, 0.172549)
		script.Parent.Story.Font = Enum.Font.SpecialElite
	elseif Tone == "Chaos" then
		script.Parent.Story.TextSize = 40
		script.Parent.Story.TextColor3 = Color3.new(0.356863, 0, 0)
		script.Parent.Story.Font =  Enum.Font.SpecialElite
	elseif Tone == "Hope" then
		script.Parent.Story.TextSize = 40
		script.Parent.Story.TextColor3 = Color3.new(0.827451, 0.662745, 0)
		script.Parent.Story.Font = Enum.Font.Merriweather
	elseif Tone == "Sad" then
		script.Parent.Story.TextSize = 40
		script.Parent.Story.TextColor3 = Color3.new(1, 1, 1)
		script.Parent.Story.Font = Enum.Font.Merriweather
	end
	
	Tweening = TweenService:Create(script.Parent.Story,TweenInfo.new(1),{TextTransparency = 0})
	Tweening:Play()
	script.Parent.Story.Visible = true
	script.Parent.Story.Text = Text
	wait(5)
	Tweening = TweenService:Create(script.Parent.Story,TweenInfo.new(1),{TextTransparency = 1})
	Tweening:Play()
	wait(1)
	Tweening = nil
end)

game.ReplicatedStorage:WaitForChild("Deadlist").OnClientEvent:Connect(function(State,DeadList)
	script.Parent.Dead.Visible = State
	
	if State then
		for _,V in pairs(script.Parent.Dead.List:GetChildren()) do
			if not V:IsA("UIListLayout") then
				V:Destroy()
			end
		end
		
		for _,V in pairs(DeadList) do
			local Info = script.Template:Clone()
			Info.Text = " - " .. V[2] .." (@"..V[1]..")"
			Info.Parent = script.Parent.Dead.List
		end
	end
end)


RunService.Heartbeat:Connect(function()
	if game.ReplicatedStorage:WaitForChild("PermaDeath").Value then
		wait(1)

		if game.Players.LocalPlayer.Character:FindFirstChild("Revivable") and game.Players.LocalPlayer.Character:FindFirstChild("Revivable").Value > 0 then
			script.Parent.CouldBeRevived.Visible = true
			script.Parent.Enabled = true
			script.Parent.CouldBeRevived.Text = "Waiting for Apothecary: ".. tostring(game.Players.LocalPlayer.Character:FindFirstChild("Revivable").Value)
			script.Parent.CouldBeRevived.TextColor3 = Color3.new(0, 0, 0):Lerp(Color3.new(1, 0.854902, 0.32549),(game.Players.LocalPlayer.Character:FindFirstChild("Revivable").Value))
		else
			script.Parent.CouldBeRevived.Visible = false
			script.Parent.CouldBeRevived.Text = ""
		end
	end
end)