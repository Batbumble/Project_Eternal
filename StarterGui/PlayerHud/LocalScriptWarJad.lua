-- @ScriptType: LocalScript
local Lighting = game:GetService("Lighting")
local PlayersService = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = PlayersService.LocalPlayer
local Character = LocalPlayer.Character
local Humanoid = Character and Character:FindFirstChild("Humanoid")

local Hud = script.Parent.Hud
local Compass = script.Parent.Compass

local BillBoardUi_APOC = game.ReplicatedStorage:WaitForChild("Main"):WaitForChild("UiAssets"):WaitForChild("ApothecaryHudUi")
local BillBoardUi_TC = game.ReplicatedStorage:WaitForChild("Main"):WaitForChild("UiAssets"):WaitForChild("TechMarineHudUi")
local BillBoardUi_I = game.ReplicatedStorage:WaitForChild("Main"):WaitForChild("UiAssets"):WaitForChild("InfiltratorHudUi")

local exposureLevel = Lighting.ExposureCompensation
local exposureStep = 0.2 -- how much exposure changes per press

--local onAnim = Humanoid and Humanoid:LoadAnimation(script.HelmetOn)
--local offAnim = Humanoid and Humanoid:LoadAnimation(script.HelmetOff)

local UI = script.Parent.LocalArmor

local mouse = LocalPlayer:GetMouse()
mouse.Icon = 'rbxassetid://12389204093'

task.wait(1)

------------------------------------- initialization function made by warjad
local function createStartupGui()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "HelmetStartupHUD"
	screenGui.ResetOnSpawn = true
	screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Position = UDim2.new(0, 0, 0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(0, 194, 0)
	textLabel.TextStrokeTransparency = 0.7
	textLabel.Font = Enum.Font.Code
	textLabel.TextSize = 14
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Top
	textLabel.TextWrapped = true
	textLabel.Text = ""
	textLabel.Parent = screenGui

	local lines = {
		".", ".", ".", 
		"++++ SYSTEM INITIALIZING ++++",
		"",
		"LIFE SUPPORT: ACTIVE",
		"ARMOR: ACTIVE",
		"NAVIGATION: ACTIVE",
		"REQUISITION: ACTIVE",
		"CORE SYSTEMS: ACTIVE",
		"",
		"Black Carapace Synthesization",
		"Device  Device [] Device Close",
		"",
		"-------------------------------------",
		"23		2F79C Theta 7  Auspex Scanner Array",
		"56		4DSEF Alpha 9  Neural Network Module",
		"78     9G497 Beta 4   Thermal Sensory Array",
		"34     6H834 Gamma 6  Gyro Stablization Unit",
		"26		7J759 Zeta 4   Plasma Reactor Unit",
		"+By the Omnissiah's grace+",
		">> Initializating Armor Boot-Up Sequence <<",
		"",
		"",
		"Astartes Designation: Identified",
		"Astartes Chapter: Identified",
		"Power Armor Mark: X Tacticus ",
		"",
		"",
		"PLASMA REACTOR: STABLE",
		"",
		"-- SYSTEMS CHECK: CLASSIFIED MODULES --",
		"Servo Amplifier: Nominal",
		"Actuator Tuning: Verified",
		"Load Management: Stable",
		"Auxiliary Port Sync: Complete",
		"Magneto Induction: Ready",
		"Armor Compression: Engaged",
		"Neural Feedback Loop: Online",
		"Diagnostics Relay: Active",
		"Environmental Regulator: Operational",
		"Regional Indicators: Assigned",
		"",
		"Activating Armor Actuatres",
		"Right Leg Actuatre : Ready",
		"Left Leg Actuatre : Ready",
		"Torso Actuatre : Ready",
		"Neck Actuatre : Ready",
		"Left Arm Actuatre : Ready",
		"Right Arm Actuatre : Ready",
		"Astartes Armor Movement Assist [ACTIVE]",
		"This has truly been, my Eternal Conquest",
	}


	coroutine.wrap(function()
		for _, line in ipairs(lines) do
			textLabel.Text = textLabel.Text .. line .. "\n"

			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://515150941"
			sound.Volume = 1
			sound.Parent = screenGui
			sound:Play()

			task.wait(0.15)
		end

		task.wait(2)
		screenGui:Destroy()
	end)()
end

local function helmetExists(character)
	for _, item in ipairs(character:GetDescendants()) do
		if (item:IsA("Accessory") or item:IsA("MeshPart") or item:IsA("Part")) and string.lower(item.Name):find("helmet") then
			return true
		end
	end
	return false
end

-- Prevent repeat trigger
local shownForThisLife = false

local function checkHelmetAndStart(character)
	if shownForThisLife then return end
	if not character then return end
	
	for _,Plr in pairs(game.Players:GetChildren()) do
		local Char = Plr.Character
		if Char and Char:FindFirstChild("Head") and Char.Head:FindFirstChild(BillBoardUi_APOC.Name) then
			Char.Head:FindFirstChild(BillBoardUi_APOC.Name):Destroy()
		elseif Char and Char:FindFirstChild("Head") and Char.Head:FindFirstChild(BillBoardUi_TC.Name) then
			Char.Head:FindFirstChild(BillBoardUi_TC.Name):Destroy()
		elseif Char and Char:FindFirstChild("Head") and Char.Head:FindFirstChild(BillBoardUi_I.Name) then
			Char.Head:FindFirstChild(BillBoardUi_I.Name):Destroy()
		end
	end
	
	-- First check (immediate)
	if not helmetExists(character) then return end

	-- Second check after 1s (to confirm it stays)
	task.delay(1, function()
		if helmetExists(character) then
			shownForThisLife = true
			createStartupGui()
		end
	end)
end

-- Handle current character
if LocalPlayer.Character then
	checkHelmetAndStart(LocalPlayer.Character)
end

-- Handle future spawns
LocalPlayer.CharacterAdded:Connect(function(char)
	shownForThisLife = false
	checkHelmetAndStart(char)
end)

------------------------------------------------------------
local HelmetIsOff = LocalPlayer:FindFirstChild("HelmetIsOff")
local UIsThatRequireHelmet = {"PlayerHud","GPShud"}

local shownForThisLife = false
-- print("[Helmet] Initial shownForThisLife value:", shownForThisLife)

local MapCycle = 1
local MapVisible = false

if script.Parent:GetAttribute("Cadian") then
	CadiaHud = not CadiaHud
	LocalPlayer.PlayerGui.PlayerHud.Visor.Visible = false
	LocalPlayer.PlayerGui.PlayerHud.Hud.Visible = false
	LocalPlayer.PlayerGui.PlayerHud.LocalArmor.Visible = false
end

if HelmetIsOff then
	local function ToggleUIs()
		for _, UIName in pairs(UIsThatRequireHelmet) do
			for _, V in pairs(LocalPlayer.PlayerGui:GetChildren()) do
				if V.Name == UIName then
					-- Enable UI only if helmet is ON (HelmetIsOff == false)
					V.Enabled = not HelmetIsOff.Value
					-- print(string.format("[Helmet] Toggling UI '%s' to Enabled: %s (HelmetIsOff = %s)", UIName, tostring(V.Enabled), tostring(HelmetIsOff.Value)))
				end
			end
		end
	end

	local lastHelmetState = HelmetIsOff.Value
	-- print("[Helmet] Initial HelmetIsOff value:", lastHelmetState)
	-- print("[Helmet] Initial shownForThisLife:", shownForThisLife)

	HelmetIsOff.Changed:Connect(function()
		-- print("[Helmet] HelmetIsOff changed! New value:", HelmetIsOff.Value)
		-- print("[Helmet] shownForThisLife before toggle:", shownForThisLife)

		ToggleUIs()

		-- Force disable UI immediately when helmet is OFF
		if HelmetIsOff.Value == true then -- Helmet OFF
			for _, UIName in pairs(UIsThatRequireHelmet) do
				local ui = LocalPlayer.PlayerGui:FindFirstChild(UIName)
				if ui then
					ui.Enabled = false
					-- print("[Helmet] Forced disabling UI:", UIName)
				end
			end
		end

		-- Detect helmet ON transition (true -> false)
		if lastHelmetState == true and HelmetIsOff.Value == false then
			-- print("[Helmet] Detected helmet ON transition (true -> false)")
			if not shownForThisLife then
				shownForThisLife = true
				-- print("[Helmet] Running createStartupGui()")
				createStartupGui()
			else
				-- print("[Helmet] Startup GUI already shown this life, skipping")
			end
		end

		lastHelmetState = HelmetIsOff.Value
		-- print("[Helmet] New lastHelmetState:", lastHelmetState)
		-- print("[Helmet] shownForThisLife after toggle:", shownForThisLife)
	end)

	-- Initial toggle on spawn
	ToggleUIs()

	-- Run startup GUI only if helmet is ON on spawn
	if HelmetIsOff.Value == false then
		-- print("[Helmet] Helmet ON at start")
		if not shownForThisLife then
			shownForThisLife = true
			-- print("[Helmet] Running createStartupGui() at start")
			createStartupGui()
		else
			-- print("[Helmet] Startup GUI already shown this life at start, skipping")
		end
	end
end

---------------------------------------------------------------------
local CheckCloak = false
local CheckHood = false
local CheckMask = false
local Helmet = false

for _,V in pairs(Character:GetDescendants()) do
	if V.Name == "CamoF" then
		CheckCloak = true
	elseif V.Name == "HoodUp" then
		CheckHood = true
	elseif V.Name == "HideHead" and not string.match(V.Parent.Name,"Scout Suitlink") then
		Helmet = V.Parent
	elseif V.Name == "MaskUp" then
		CheckMask = true
	end
end
	
local HeadToggle = false
local HelmDebounce = false
---------------------------------------------------------------------
local ApothecaryHud = false
local TechmarineHud = false
local InfiltratorHud = false

UserInputService.InputBegan:Connect(function(Key, GPE)
	if not GPE then
		-- P Key
		if Key.KeyCode == Enum.KeyCode.P and HelmetIsOff and not HelmetIsOff.Value then
			if script.Parent:GetAttribute("TechMarine") then
				TechmarineHud = not TechmarineHud
				script.Sound:Play()
			elseif script.Parent:GetAttribute("Apothecary") then
				ApothecaryHud = not ApothecaryHud
				script.Sound:Play()
			elseif script.Parent:GetAttribute("Infiltrator") then
				InfiltratorHud = not InfiltratorHud
				script.Sound:Play()
			elseif CheckCloak then
				game.ReplicatedStorage["Main"]["Remote Events"].Cloak:FireServer()
			end	
		end

		-- H Key
		if Key.KeyCode == Enum.KeyCode.H and HelmDebounce == false then
			HelmDebounce = true
			HeadToggle = not HeadToggle

			if HeadToggle then
				createStartupGui()
			end

			if CheckHood then
				game.ReplicatedStorage["Main"]["Remote Events"].Hood:FireServer(HeadToggle)
			elseif Helmet then
				game.ReplicatedStorage["Main"]["Remote Events"]["ToggleHelmet"]:FireServer(Helmet, HeadToggle)
			elseif CheckMask then
				game.ReplicatedStorage["Main"]["Remote Events"].Mask:FireServer(HeadToggle)
			end

			task.delay(1.25, function()
				HelmDebounce = false
			end)
		end

		-- B Key
		if Key.KeyCode == Enum.KeyCode.B then
			exposureLevel = math.clamp(exposureLevel - exposureStep, -5, 5)
			Lighting.ExposureCompensation = exposureLevel
			script.Sound:Play()
		end

		-- G Key
		if Key.KeyCode == Enum.KeyCode.G then
			exposureLevel = math.clamp(exposureLevel + exposureStep, -5, 5)
			Lighting.ExposureCompensation = exposureLevel
			script.Sound:Play()
		end

		-- M Key
		if Key.KeyCode == Enum.KeyCode.M and not HelmetIsOff.Value then
			MapVisible = not MapVisible
			script.Parent.MapSystem.Visible = MapVisible

			if MapVisible then
				script.Map:Play()
			end
		end

		--[[
		-- K Key (commented out)
		if Key.KeyCode == Enum.KeyCode.K and not HelmetIsOff.Value then
			script.Parent.MapSystem:GetChildren()[MapCycle].Visible = false

			if MapCycle == #script.Parent.MapSystem:GetChildren() then
				MapCycle = 1
			else
				MapCycle = MapCycle + 1 
			end

			script.Parent.MapSystem:GetChildren()[MapCycle].Visible = true
		end
		]]
	end
end)

---------------------------------------------------------------------
local PlayersService = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local LocalPlayer = PlayersService.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- UI for damage message
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local MessageGui = Instance.new("ScreenGui")
MessageGui.Name = "DamageMessageGui"
MessageGui.ResetOnSpawn = false
MessageGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MessageLabel = Instance.new("TextLabel")
MessageLabel.Size = UDim2.new(0.3, 0, 0.1, 0) -- 30% width, 10% height
MessageLabel.Position = UDim2.new(1, -35, 0.59, 0)
MessageLabel.AnchorPoint = Vector2.new(1, 0.5) -- Aligns to middle right
MessageLabel.BackgroundTransparency = 1
MessageLabel.TextColor3 = Color3.fromRGB(0, 194, 0)
MessageLabel.TextStrokeTransparency = 0.7
MessageLabel.Font = Enum.Font.Code
MessageLabel.TextSize = 14
MessageLabel.TextXAlignment = Enum.TextXAlignment.Right
MessageLabel.TextYAlignment = Enum.TextYAlignment.Center
MessageLabel.TextWrapped = true
MessageLabel.Text = ""
MessageLabel.Visible = false
MessageLabel.Parent = MessageGui

local previousArmorValues = {}

local function showLimbDamageMessage(limbName)
	MessageLabel.Text = string.upper(limbName) .. " HAS TAKEN DAMAGE"
	MessageLabel.Visible = true
	
	task.spawn(function()
		task.wait(2)
		MessageLabel.Visible = false
	end)
end


RunService.RenderStepped:Connect(function()
	pcall(function()
		if HelmetIsOff and not HelmetIsOff.Value then
			for _,Player in pairs(PlayersService:GetPlayers()) do
				if Player ~= LocalPlayer and Player.Team == LocalPlayer.Team and Player.Character then
					local Char = Player.Character

					-- APOC HUD
					if ApothecaryHud then
						local ACS_Client = Char:FindFirstChild("ACS_Client")
						if ACS_Client and Char:FindFirstChild("Head") then
							local BB_APOC = Char.Head:FindFirstChild(BillBoardUi_APOC.Name) or BillBoardUi_APOC:Clone()
							BB_APOC.Parent = Char.Head

							local Sang = ACS_Client.Variaveis.Sangue
							local Humanoid = Char:FindFirstChild("Humanoid")

							if Sang and Humanoid then
								BB_APOC.Overhaul.Vitality.Content.Size = UDim2.new(1, 0, Sang.Value / Sang.MaxValue, 0)
								BB_APOC.Overhaul.Health.Content.Size = UDim2.new(1, 0, Humanoid.Health / Humanoid.MaxHealth, 0)
							end

							local Dor = ACS_Client.Variaveis.Dor.Value
							if Dor <= 0 then
								BB_APOC.Overhaul.Pain.ImageColor3 = Color3.fromRGB(255,255,255)
							elseif Dor <= 25 then
								BB_APOC.Overhaul.Pain.ImageColor3 = Color3.fromRGB(255,255,255)
							elseif Dor < 100 then
								BB_APOC.Overhaul.Pain.ImageColor3 = Color3.fromRGB(255,255,0)
							else
								BB_APOC.Overhaul.Pain.ImageColor3 = Color3.fromRGB(255,0,0)
							end

							BB_APOC.Overhaul.Injured.Visible = ACS_Client.Stances.Ferido.Value
							BB_APOC.Overhaul.Bleeding.Visible = ACS_Client.Stances.Sangrando.Value

							if ACS_Client.Stances.surg2.Value then
								BB_APOC.Overhaul.Surgical.Visible = true
								BB_APOC.Overhaul.Surgical.ImageColor3 = Color3.new(1, 0.917647, 0)
							elseif ACS_Client.Stances.bbleeding.Value then
								BB_APOC.Overhaul.Surgical.Visible = true
								BB_APOC.Overhaul.Surgical.ImageColor3 = Color3.new(1, 0, 0)
							else
								BB_APOC.Overhaul.Surgical.Visible = false
							end

							BB_APOC.Overhaul.Dead.Visible = ACS_Client.Stances.rodeath.Value
							if ACS_Client.Stances.rodeath.Value then
								BB_APOC.Overhaul.Dead.ImageColor3 = Color3.fromRGB(255,0,0)
							end
						end

					elseif TechmarineHud and Char:FindFirstChild("Armor") then
						local ArmorFolder = Char:FindFirstChild("Armor")
						local BBClone = Char.Head:FindFirstChild(BillBoardUi_TC.Name) or BillBoardUi_TC:Clone()
						BBClone.Parent = Char.Head

						for _, ArmorValue in pairs(ArmorFolder:GetChildren()) do
							local ArmorUI = BBClone.Body:FindFirstChild(ArmorValue.Name)
							if ArmorUI and ArmorValue.MaxValue ~= 0 then
								ArmorUI.Visible = true
								local ratio = ArmorValue.Value / ArmorValue.MaxValue
								if ratio < 0.1 then
									ArmorUI.ImageColor3 = Color3.new(0, 0, 0)
								elseif ratio == 1 then
									ArmorUI.ImageColor3 = Color3.new(0.333333, 1, 1)
								else
									ArmorUI.ImageColor3 = Color3.new(1, 0, 0):Lerp(Color3.new(1, 0.854902, 0.32549), ratio)
								end
							end
						end

					elseif InfiltratorHud and Char:FindFirstChild("Armor") then
						local ArmorFolder = Char:FindFirstChild("Armor")
						local playerGui = Player:FindFirstChild("PlayerGui")
						if playerGui and playerGui:FindFirstChild("PlayerHud") then
							local IClone = playerGui.PlayerHud:FindFirstChild(BillBoardUi_I.Name) or BillBoardUi_I:Clone()
							IClone.Parent = playerGui.PlayerHud

							for _, ArmorValue in pairs(ArmorFolder:GetChildren()) do
								local ArmorUI = IClone.Body:FindFirstChild(ArmorValue.Name)
								if ArmorUI and ArmorValue.MaxValue ~= 0 then
									ArmorUI.Visible = true
								end
							end
						end
					elseif not ApothecaryHud then
						if Char.Head:FindFirstChild(BillBoardUi_APOC.Name) then
							Char.Head:FindFirstChild(BillBoardUi_APOC.Name):Destroy()
						end
					elseif not TechmarineHud then
						if Char.Head:FindFirstChild(BillBoardUi_TC.Name) then
							Char.Head:FindFirstChild(BillBoardUi_TC.Name):Destroy()
						end
					elseif not InfiltratorHud then
						local playerGui = Player:FindFirstChild("PlayerGui")
						if playerGui.PlayerHud:FindFirstChild(BillBoardUi_I.Name) then
							playerGui.PlayerHud:FindFirstChild(BillBoardUi_I.Name):Destroy()
						end
					end
				end
			end

			-- Local Player Armor HUD + Damage Message
			if LocalPlayer:GetAttribute("InMenu") == false and UI and Character:FindFirstChild("Armor") then
				UI.Visible = true
				for _, Armor in pairs(Character.Armor:GetChildren()) do
					local Frame = UI:FindFirstChild(Armor.Name)
					if Frame and Armor.MaxValue > 0 then
						local ratio = Armor.Value / Armor.MaxValue
						Frame.Visible = true

						if ratio <= 0.1 then
							Frame.ImageColor3 = Color3.new(0, 0, 0)
						elseif ratio == 1 then
							Frame.ImageColor3 = Color3.new(0.333333, 1, 1)
						else
							Frame.ImageColor3 = Color3.new(1, 0, 0):Lerp(Color3.new(1, 0.854902, 0.32549), ratio)
						end

						local previous = previousArmorValues[Armor.Name]
						if previous and Armor.Value < previous then
							showLimbDamageMessage(Armor.Name)
						end
						previousArmorValues[Armor.Name] = Armor.Value
					end
				end
			end
		else
			-- Helmet is off, clear all teammate UIs
			for _,Player in pairs(PlayersService:GetPlayers()) do
				if Player ~= LocalPlayer and Player.Team == LocalPlayer.Team and Player.Character then
					local Char = Player.Character
					for _,name in pairs({BillBoardUi_TC.Name, BillBoardUi_APOC.Name, BillBoardUi_I.Name}) do
						local UI = Char:FindFirstChild("Head") and Char.Head:FindFirstChild(name)
						if UI then UI:Destroy() end
					end
				end
			end
		end
	end)
end)