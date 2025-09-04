-- @ScriptType: LocalScript
local SKP_1 = game.ReplicatedStorage.ACS_Engine.Events
local SKP_2 = game.Players.LocalPlayer
local SKP_3 = game:GetService("RunService")
local MD = game.ReplicatedStorage:WaitForChild("ACS_Engine")
local SKP_4 = SKP_1.MedSys
local SKP_5 = {"342190005"; "342190012"; "342190017"; "342190024";} -- Bullet Whizz
local SKP_00 = require(game.ReplicatedStorage.ACS_Engine.GameRules:WaitForChild("Config"))
game.Workspace.CurrentCamera:ClearAllChildren()

local SKP_6 = game:GetService("StarterGui")
SKP_6:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, SKP_00.CoreGuiPlayerList)
SKP_2.PlayerGui:SetTopbarTransparency(SKP_00.TopBarTransparency)
SKP_6:SetCoreGuiEnabled(Enum.CoreGuiType.Health,SKP_00.CoreGuiHealth)
local SKP_7 = script.Parent.Parent.Humanoid

if game.Workspace.CurrentCamera:FindFirstChild("BS") == nil then
	local SKP_8 = Instance.new("ColorCorrectionEffect")
	SKP_8.Parent = game.Workspace.CurrentCamera
	SKP_8.Name = "BS"
end

if game.Workspace.CurrentCamera:FindFirstChild("BO") == nil then
	local SKP_8 = Instance.new("ColorCorrectionEffect")
	SKP_8.Parent = game.Workspace.CurrentCamera
	SKP_8.Name = "BO"
end

if game.Workspace.CurrentCamera:FindFirstChild("DorFX") == nil then
	local SKP_9 = Instance.new("BlurEffect")
	SKP_9.Parent = game.Workspace.CurrentCamera
	SKP_9.Name = "DorFX"
end

local SKP_10 = game:GetService("TweenService")
local SKP_11 = game:GetService("Debris")


local SKP_12 = game.Workspace.CurrentCamera.BS
local SKP_13 = game.Workspace.CurrentCamera.BO
local SKP_14 = game.Workspace.CurrentCamera.DorFX

SKP_12.Saturation	= 0
local Tween = SKP_10:Create(SKP_12,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0),{Contrast = 0}):Play()
local Tween = SKP_10:Create(SKP_13,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0),{Brightness = 0}):Play()
SKP_13.Saturation 	= 0
local Tween = SKP_10:Create(SKP_14,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0),{Size = 0}):Play()
SKP_12.TintColor 		= Color3.new(1,1,1)
SKP_13.TintColor 	= Color3.new(1,1,1)


local SKP_15 = SKP_2.Character:WaitForChild("ACS_Client")
local Stances = SKP_15:WaitForChild("Stances")
local Vars = SKP_15:WaitForChild("Variaveis")
local SKP_16 = Stances:WaitForChild("Caido")
local SKP_17 = Vars:WaitForChild("Sangue")
local SKP_18 = Vars:WaitForChild("Dor")
local SKP_HC = Vars:WaitForChild("HitCount")
local Morto = false


local SKP_19 = true
local SKP_20 = SKP_7.Health
local SKP_21 = 0
--SKP_7:SetStateEnabled(Enum.HumanoidStateType.Dead, false)



SKP_7.Changed:Connect(function(Health)

	if SKP_7.Health < SKP_20 then

		local Hurt = ((SKP_7.Health/SKP_20) - 1) * -1

		local SKP_22 = script.FX.Blur:clone()
		SKP_22.Parent = game.Workspace.CurrentCamera

		local SKP_23 = script.FX.ColorCorrection:clone()
		SKP_23.Parent = game.Workspace.CurrentCamera

		SKP_22.Size 		= ((SKP_7.Health/SKP_20) - 1) * -50
		--SKP_23.TintColor 	= Color3.new(1,(math.ceil(SKP_7.Health/2)/math.ceil(SKP_20)),(math.ceil(SKP_7.Health/2)/math.ceil(SKP_20)))

		SKP_10:Create(SKP_22,TweenInfo.new(3 * Hurt,Enum.EasingStyle.Sine,Enum.EasingDirection.In,0,false,0),{Size = 0}):Play()
		--SKP_10:Create(SKP_23,TweenInfo.new(2.5 * Hurt,Enum.EasingStyle.Sine,Enum.EasingDirection.In,0,false,0),{TintColor = Color3.new(1,1,1)}):Play()

		SKP_11:AddItem(SKP_22, 3 * Hurt)
		SKP_11:AddItem(SKP_23, 2.5 * Hurt)
	end

	SKP_20 = SKP_7.Health
end)

local SKP_24 = false

SKP_18.Changed:Connect(function(Valor)

end)

SKP_17.Changed:Connect(function(Valor)
	if Valor >= SKP_17.MaxValue/2 then
		SKP_12.Saturation	= ((Valor*2)/SKP_17.MaxValue) - 2
	elseif Valor < SKP_17.MaxValue/2 then
		SKP_12.Saturation = -1
	elseif Valor <= 0 then
		SKP_12.Saturation = -1
	end
end)

SKP_HC.Changed:Connect(function(Valor)
	if Valor >= 3 then
		SKP_4.Render:FireServer(true,"N/A")
	end
end)

local SKP_25 = script.Parent.Parent.Humanoid
local SKP_26 = SKP_1.MedSys.Collapse

SKP_16.Changed:Connect(function(Valor)
	if Valor == true then
		--SKP_2.PlayerGui.StatusUI.Pain.Visible = true
		SKP_13.Brightness = -0.2
		SKP_25:UnequipTools()
		SKP_6:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)
	else
		--SKP_2.PlayerGui.StatusUI.Pain.Visible = false
		SKP_6:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,true)
		SKP_13.Brightness = 0
	end
end)


SKP_7.Died:Connect(function()

	Morto = true

	SKP_7.AutoRotate = false

	SKP_13.TintColor = Color3.new(1,1,1)

	SKP_13.Brightness = 0

	SKP_12.Saturation = 0

	SKP_12.Contrast = 0

	SKP_14.Size = 0

	SKP_12.Saturation = 0

	SKP_12.Contrast = 0

	SKP_15.Variaveis.Dor.Value = 0

	if SKP_19 == true then
		Tween = SKP_10:Create(SKP_13,TweenInfo.new(game.Players.RespawnTime/1.25,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0),{Brightness = 0, Contrast = 0,TintColor = Color3.new(0,0,0)}):Play()
	end	
end)

function onChanged()
	SKP_26:FireServer()
	if (SKP_17.Value <= 3500) or (SKP_18.Value >= 200)  or (SKP_16.Value == true) then
		SKP_6:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)
		SKP_25:UnequipTools()
	elseif (SKP_17.Value > 3500) and (SKP_18.Value < 200) and (SKP_16.Value == false) and SKP_15.Stances.Rendido.Value == false then -- YAY A MEDIC ARRIVED! =D
		SKP_6:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,true)	
	end
end

onChanged()

--SKP_15.Stances.Rendido.Changed:Connect(function(Valor)
--	if Valor == true then
--		SKP_25:UnequipTools()
--		SKP_6:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)
--	else
--		SKP_6:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,true)
--	end
--end)

--local RS = game:GetService("RunService")
--RS.RenderStepped:connect(function(Update)
--	if Morto and SKP_2.Character then

--		SKP_2.Character:FindFirstChild("RightUpperArm").LocalTransparencyModifier = 0
--		SKP_2.Character:FindFirstChild("RightLowerArm").LocalTransparencyModifier = 0
--		SKP_2.Character:FindFirstChild("RightHand").LocalTransparencyModifier = 0

--		SKP_2.Character:FindFirstChild("LeftUpperArm").LocalTransparencyModifier = 0
--		SKP_2.Character:FindFirstChild("LeftLowerArm").LocalTransparencyModifier = 0
--		SKP_2.Character:FindFirstChild("LeftHand").LocalTransparencyModifier = 0

--		SKP_2.Character:FindFirstChild("RightUpperLeg").LocalTransparencyModifier = 0
--		SKP_2.Character:FindFirstChild("RightLowerLeg").LocalTransparencyModifier = 0

--		SKP_2.Character:FindFirstChild("LeftUpperLeg").LocalTransparencyModifier = 0
--		SKP_2.Character:FindFirstChild("LeftLowerLeg").LocalTransparencyModifier = 0

--		SKP_2.Character:FindFirstChild("UpperTorso").LocalTransparencyModifier = 0	
--		SKP_2.Character:FindFirstChild("LowerTorso").LocalTransparencyModifier = 0	

--		--game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
--		--game.Workspace.CurrentCamera.CFrame = SKP_15.Parent:WaitForChild('Head').CFrame
--	end
--end)

while true do
	SKP_10:Create(SKP_14,TweenInfo.new(3,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0),{Size = 0}):Play()
	wait(3)
	SKP_10:Create(SKP_14,TweenInfo.new(2,Enum.EasingStyle.Elastic,Enum.EasingDirection.InOut,0,false,0),{Size = (SKP_15.Variaveis.Dor.Value/SKP_15.Variaveis.Dor.MaxValue) * 15}):Play()
	wait(3)
end

SKP_17.Changed:Connect(onChanged)
SKP_18.Changed:Connect(onChanged)
SKP_16.Changed:Connect(onChanged)