-- @ScriptType: Script
--------------------------------------------------------------------------------
local PlayersService = game:GetService("Players")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local BillBoardUi_I = game.ReplicatedStorage:WaitForChild("Main"):WaitForChild("UiAssets"):WaitForChild("InfiltratorHudUi")
local BillBoardUi_T = game.ReplicatedStorage:WaitForChild("Main"):WaitForChild("UiAssets"):WaitForChild("TeleportGui")
local BillBoardUi_K = game.ReplicatedStorage:WaitForChild("Main"):WaitForChild("UiAssets"):WaitForChild("KnightHud")
local Sound_K = game.ReplicatedStorage:WaitForChild("Main"):WaitForChild("UiAssets"):WaitForChild("KnightHorn")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeamsService = game:GetService("Teams")
local rs = game:GetService('RunService')

local UpdateTagEvent = ReplicatedStorage.NametagEvent

local MainFolder = ReplicatedStorage:FindFirstChild("Main")
local RemoteEventsFolder = MainFolder["Remote Events"]
local ModulesFolder = MainFolder.Modules

local SpawnWithHorn = false

game:WaitForChild('ReplicatedStorage'):WaitForChild('ColorEvent',10).OnServerEvent:Connect(function(Player,color,ai)
	if not ai then
		Player:SetAttribute('color',color)
	else
		game:GetService('ReplicatedStorage'):WaitForChild("ENPGS — Storage"):WaitForChild('Factions'):WaitForChild('Imperium of Man'):WaitForChild('Custom'):SetAttribute('color',color)
	end
end)

local Config = require(MainFolder.Config)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
local ServerLoadoutsData = {}

local function PlayerDeployed(Player,Loadout)
	if Player then
		for I,V in pairs(ServerLoadoutsData) do
			if V[1] == Player then
				table.remove(ServerLoadoutsData,I)
			end
		end

		wait()

		table.insert(ServerLoadoutsData,{Player,Loadout})	

		Player:SetAttribute("InMenu",false)
		Player:LoadCharacter()
	end
end
--------------------------------------------------------------------------------
local function recursive(parent,root)
	for k,v in pairs(parent:GetChildren()) do
		if v:IsA("BasePart") then
			local w = Instance.new("Weld")
			w.Part0 = root
			w.Part1 = v
			w.C1 = v.CFrame:toObjectSpace(root.CFrame)
			w.Parent = root
			v.Anchored = false
			v.CanCollide = false
			v.CanQuery = true
			v.CanTouch = false
		elseif v:IsA("Model") and v.Name ~= "Up" then
			recursive(v,root)
		end
	end
end

local attachpts = {
	R15 = {
		Vest = "UpperTorso",
		Face = "Head",
		Helmet = "Head",
		Belt = "LowerTorso",
	},
	R6 = {
		Vest = "Torso",
		Face = "Head",
		Helmet = "Head",
		Belt = "Torso",
	}
}


function weld(A,Player)
	local g = A:clone()	
	
	local ReplaceBodyParts = A.Parent:FindFirstChild("ReplaceBodyParts")

	if ReplaceBodyParts then
		pcall(function()
			Player.Character:FindFirstChild(A.Name).Transparency = 1

			for _,V in pairs(g:GetChildren()) do
				if V.Name ~= "DontColor" then
					V.Color = Player.Character:FindFirstChild(A.Name).Color
				end
			end
		end)
	end
	
	if A:FindFirstChild("HideBodyPart") and A:FindFirstChild("HideBodyPart").Value then
		if Player.Character:FindFirstChild(A.Name) then
			Player.Character:FindFirstChild(A.Name).Transparency = 1
		end
	end
	
	g.Name = A.Parent.Name.."_"..A.Name
	Player.Character:SetAttribute('Morph',A.Parent.Name)
	--g.Name = "MorphModel"..A.Name
	
	if not g:FindFirstChild("suporte_ovn") then
		local C = g:GetChildren()
		for i=1, #C do
			if C[i].className == "Part" or C[i].className == "UnionOperation" or C[i].className == "MeshPart" then
				if not C[i]:FindFirstChild("DoNotWeld") then
					local W = Instance.new("Weld")
					W.Part0 = g.Middle
					W.Part1 = C[i]
					local CJ = CFrame.new(g.Middle.Position)
					local C0 = g.Middle.CFrame:inverse()*CJ
					local C1 = C[i].CFrame:inverse()*CJ
					W.C0 = C0
					W.C1 = C1
					W.Parent = g.Middle
				end
			end
			local Y = Instance.new("Weld")
			Y.Part0 = Player.Character:FindFirstChild(A.Name)
			Y.Part1 = g.Middle
			Y.C0 = CFrame.new(0, 0, 0)
			Y.Parent = Y.Part0
		end

		local h = g:GetChildren()
		for i = 1, # h do
			if h[i]:IsA("BasePart") then
				h[i].Anchored = false
				h[i].CanCollide = false
				h[i].CanQuery = true
				h[i].CanTouch = false
			end
		end
	elseif g:FindFirstChild("suporte_ovn") then
		for _,ToBeDeleted in pairs(g:GetChildren()) do
			if ToBeDeleted:FindFirstChild("Delete") then
				ToBeDeleted:Destroy()
			end
		end
		
		g.Name = "Helmet"
		
		local model = g

		local upnvg = model:FindFirstChild("Up")
		local downnvg = model:FindFirstChild("Down")
		if upnvg and downnvg then
			recursive(upnvg,upnvg.PrimaryPart)
			local nvgjoint = Instance.new("Motor6D")
			nvgjoint.Part0 = model.Middle
			nvgjoint.Part1 = upnvg.PrimaryPart

			local upvalue = Instance.new("CFrameValue")
			local downvalue = Instance.new("CFrameValue")

			upvalue.Name = "upvalue"
			downvalue.Name = "downvalue"

			upvalue.Value = model.Middle.CFrame:inverse()*upnvg.PrimaryPart.CFrame
			downvalue.Value = model.Middle.CFrame:inverse()*downnvg.PrimaryPart.CFrame

			upvalue.Parent = upnvg
			downvalue.Parent = upnvg

			nvgjoint.Name = "twistjoint"
			nvgjoint.C0 = upvalue.Value
			nvgjoint.Parent = upnvg

			downnvg:Destroy()
		end	
		
		local attachtype = g.Name
		
		local char = Player.Character
		local oldmodel = char:FindFirstChild(attachtype)
		if oldmodel then
			oldmodel:Remove()
		end

		recursive(g,g.Middle)

		local Y = Instance.new("Weld")
		Y.Part0 = char[attachpts[char.Humanoid.RigType.Name][attachtype]]
		Y.Part1 = g.Middle
		Y.Parent = Y.Part0

		g.Parent = char
	end
	
	g.Parent = Player.Character
end
--------------------------------------------------------------------------------
local ArmorTable = {"HeadArmor","TorsoArmor","LeftLegArmor","LeftArmArmor","RightLegArmor","RightArmArmor"}

local function GiveLoadout(Player)
	local Loadout = nil
	local HelmetIsOff = Player:FindFirstChild("HelmetIsOff")
	
	SpawnWithHorn = false
	
	for I,V in pairs(ServerLoadoutsData) do 
		if V[1] == Player then
			Loadout = V[2]
			break
		end
	end
		
	local Tools = {}
		
	for _,Gear in pairs(Loadout) do	
		if Gear[2]:FindFirstChild("Config") then
			for _,Child in pairs(Gear[2]:FindFirstChild("Config"):GetChildren()) do
				if Child:IsA("Tool") then
					Child:Clone().Parent = Player.Backpack
				elseif Child.Name == "ACS_Rappel" then 
					Player.Character:FindFirstChild("ACS_Client"):FindFirstChild("Stances"):FindFirstChild("Can_Rappel").Value = true
				end
			end
		end
		
		if Gear[2]:IsA("Tool") then
			if Gear[1] == "Primary" then
				table.insert(Tools,1,Gear[2])
			elseif Gear[1] == "Secondary" then
				table.insert(Tools,2,Gear[2])
			elseif Gear[1] == "Equipment 1" then
				table.insert(Tools,3,Gear[2])
			elseif Gear[1] == "Equipment 2" then
				table.insert(Tools,4,Gear[2])
			elseif Gear[1] == "Equipment 3" then
				table.insert(Tools,5,Gear[2])
			end
		elseif Gear[2]:IsA("Model") then	
			if Gear[2]:FindFirstChildWhichIsA("Shirt") or Gear[2]:FindFirstChildWhichIsA("Pants") then
				if Player.Character:FindFirstChildWhichIsA("Shirt") and Gear[2]:FindFirstChildWhichIsA("Shirt") then
					Player.Character:FindFirstChildWhichIsA("Shirt").ShirtTemplate = Gear[2]:FindFirstChildWhichIsA("Shirt").ShirtTemplate
				else
					local Shirt = Instance.new("Shirt")
					Shirt.ShirtTemplate = Gear[2]:FindFirstChildWhichIsA("Shirt").ShirtTemplate
					Shirt.Parent = Player.Character
				end

				if Player.Character:FindFirstChildWhichIsA("Pants") and Gear[2]:FindFirstChildWhichIsA("Pants") then
					Player.Character:FindFirstChildWhichIsA("Pants").PantsTemplate =  Gear[2]:FindFirstChildWhichIsA("Pants").PantsTemplate
				else
					local Pants = Instance.new("Pants")
					Pants.PantsTemplate = Gear[2]:FindFirstChildWhichIsA("Pants").PantsTemplate
					Pants.Parent = Player.Character
				end
				
			else
				-- ARMOR
				local CharacterArmor = Player.Character:WaitForChild("Armor")
				for _,ArmorPart in pairs(ArmorTable) do
					if CharacterArmor:FindFirstChild(ArmorPart) then
						CharacterArmor:FindFirstChild(ArmorPart).MaxValue =CharacterArmor:FindFirstChild(ArmorPart).MaxValue + Gear[2]:GetAttribute(ArmorPart)
						CharacterArmor:FindFirstChild(ArmorPart).Value = CharacterArmor:FindFirstChild(ArmorPart).Value + Gear[2]:GetAttribute(ArmorPart)
					end
				end
				
				local GearConfig = require(Gear[2].Config)

				if Gear[1] == "Helmet" and not GearConfig.DontDisplayHud then
					HelmetIsOff.Value = false
				end
				--if Gear[2]:GetAttribute("Speed") then
				--	Player.Character:SetAttribute("Speed", Gear[2]:GetAttribute("Speed"))
				--	Player.Character.Humanoid.WalkSpeed = Gear[2]:GetAttribute("Speed")
				--end
				--if Gear[2]:GetAttribute("RunSpeed") then
				--	Player.Character:SetAttribute("RunSpeed", Gear[2]:GetAttribute("RunSpeed"))
				--end
				if Gear[2]:GetAttribute("Speed") then
					Player.Character:SetAttribute("WalkSpeed", Gear[2]:GetAttribute("Speed"))
				else
					Player.Character:SetAttribute('WalkSpeed', 16)
				end
				if Gear[2]:GetAttribute("RunSpeed") then
					Player.Character:SetAttribute("RunSpeed", Gear[2]:GetAttribute("RunSpeed"))
				else
					Player.Character:SetAttribute('RunSpeed', 25)
				end
				if Gear[2]:GetAttribute("BodyScale") then
					Player.Character.Humanoid:WaitForChild('BodyDepthScale').Value = Gear[2]:GetAttribute("BodyScale")
					if Gear[2]:GetAttribute("HeightModifier") then
						Player.Character.Humanoid:WaitForChild('BodyHeightScale').Value = Gear[2]:GetAttribute("BodyScale") * Gear[2]:GetAttribute("HeightModifier")
					else
						Player.Character.Humanoid:WaitForChild('BodyHeightScale').Value = Gear[2]:GetAttribute("BodyScale")
					end
					Player.Character.Humanoid:WaitForChild('BodyWidthScale').Value = Gear[2]:GetAttribute("BodyScale")
					Player.Character.Humanoid:WaitForChild('HeadScale').Value = Gear[2]:GetAttribute("BodyScale")
				end
				if Gear[2]:GetAttribute("Health") then
					Player.Character.Humanoid.MaxHealth = Gear[2]:GetAttribute("Health")
					wait()
					Player.Character.Humanoid.Health = Gear[2]:GetAttribute("Health")
				end
				
				for I,B in pairs(Gear[2]:GetChildren()) do
					if B:IsA("Model") then
						for _,A in pairs(Player.Character:GetChildren()) do
							if GearConfig.HideHair then 
								if A:IsA("Accessory") then
									if GearConfig.DontHideHairOnStart then
										if A.AccessoryType == Enum.AccessoryType.Hair or A.AccessoryType == Enum.AccessoryType.Face then
											A.Handle.Transparency = 0
										end
									else
										if A.AccessoryType == Enum.AccessoryType.Hair or A.AccessoryType == Enum.AccessoryType.Face then
											A.Handle.Transparency = 1
										end
									end
								end
							elseif GearConfig.RemoveHeadAccessories then					
								if A:IsA("Accessory") then
									A:Destroy()
								end
							end
																	
							if GearConfig.RemoveBodyAccessories then
								if A:IsA("Accessory") then -- and A:FindFirstChild("Handle")
									if A.AccessoryType == Enum.AccessoryType.Hair or A.AccessoryType == Enum.AccessoryType.Face then
									
									else
										if A:GetAttribute("FromLoadout") and A:GetAttribute("FromLoadout") == true then
										else
											A:Destroy()
										end
									end
								end
								
								if A.Name == "LeftFoot" or A.Name == "RightFoot" then
									A.Transparency = 1
								end
							end
						end
						
						if B:FindFirstChild("HideHead") and B:FindFirstChild("HideHead").Value then
							Player.Character:FindFirstChild("Head").Transparency = 1
							if Player.Character:FindFirstChild("Head"):FindFirstChildWhichIsA("Decal") then
								Player.Character:FindFirstChild("Head"):FindFirstChildWhichIsA("Decal").Transparency = 1
							end
						end
						
	
						if B:HasTag("Jump Pack") then
							local Mod = require(ModulesFolder:FindFirstChild("GiveJetPack"))
						
							Mod.GiveJetPack(Player,B)
						else
							weld(B,Player)
						end
					elseif B:IsA("Folder") and B.Name == "ArmorImage" and Player.PlayerGui:FindFirstChild("PlayerHud") then
						local ArmorUI = Player.PlayerGui:FindFirstChild("PlayerHud"):FindFirstChild("Body")

						for _,ImageFrame in pairs(B:GetChildren()) do
							if ArmorUI:FindFirstChild(ImageFrame.Name) then
								ArmorUI:FindFirstChild(ImageFrame.Name).Image = ImageFrame.Image
							end
						end
					elseif B:IsA("BoolValue") and B.Name == "TechMarineHud" and Player.PlayerGui:FindFirstChild("PlayerHud") then
						Player.PlayerGui:FindFirstChild("PlayerHud"):SetAttribute("TechMarine",true)
					elseif B:IsA("BoolValue") and B.Name == "ApothecaryHud" and Player.PlayerGui:FindFirstChild("PlayerHud") then
						Player.PlayerGui:FindFirstChild("PlayerHud"):SetAttribute("Apothecary",true)
					elseif B:IsA("BoolValue") and B.Name == "CadiaHud" and Player.PlayerGui:FindFirstChild("PlayerHud") then
						Player.PlayerGui:FindFirstChild("PlayerHud"):SetAttribute("Cadian",true)
					elseif B:IsA("BoolValue") and B.Name == "InfiltratorHud" and Player.PlayerGui:FindFirstChild("PlayerHud") then
						Player.PlayerGui:FindFirstChild("PlayerHud"):SetAttribute("Infiltrator",true)

						local SI = BillBoardUi_I:Clone()
						SI.Parent = Player.PlayerGui:WaitForChild("PlayerHud")
						
					elseif B:IsA("BoolValue") and B.Name == "TerminatorHud" and Player.PlayerGui:FindFirstChild("PlayerHud") then
						Player.PlayerGui:FindFirstChild("PlayerHud"):SetAttribute("Terminator",true)

						local T = BillBoardUi_T:Clone()
						
						T.Parent = Player.PlayerGui:WaitForChild("PlayerHud")
					elseif B:IsA("BoolValue") and B.Name == "KnightHud" and Player.PlayerGui:FindFirstChild("PlayerHud") then
						Player.PlayerGui:FindFirstChild("PlayerHud"):SetAttribute("Knight",true)
						
						local K = BillBoardUi_K:Clone()

						Player.PlayerGui:WaitForChild("PlayerHud").Visor:Destroy()
						K.Parent = Player.PlayerGui:WaitForChild("PlayerHud")
						K.Name = "Visor"
						
						for i,v in pairs(Player.PlayerGui:FindFirstChild("PlayerHud").Compass:GetChildren()) do
							if v:IsA("TextLabel") then
								v.TextColor3 = K.Visuals.TopPattern.ImageColor3
							end
						end
						Player:SetAttribute("Stage", "Knight")
					elseif B:IsA("BoolValue") and B.Name == "KnightHorn" then
						local K = Sound_K:Clone()
						
						K.Parent = Player.Character.HumanoidRootPart
						K.LocalScript.Enabled = true
					elseif B:IsA("BoolValue") and B.Name == "SoloSurg"  then
						Player.Character:SetAttribute("SoloSurg",true)
					elseif B:IsA("BoolValue") and B.Name == "Cloaked"  then
						B:Clone().Parent = Player.Character
					elseif B:IsA("DoubleConstrainedValue") and B.Name == "SneakValue"  then
						B:Clone().Parent = Player.Character
					elseif B:IsA("Color3Value") and B.Name == "CamoColor"  then
						B:Clone().Parent = Player.Character
					elseif B:IsA("Accessory") then
						local Cln = B:Clone()
						Cln:SetAttribute("FromLoadout", true)
						Cln.Parent = Player.Character
					end
				end
			end
		end
	end

	if Player.Character:GetAttribute("Speed") then
	else
		Player.Character:SetAttribute('WalkSpeed', 16)
	end
	if Player.Character:GetAttribute("RunSpeed") then
	else
		Player.Character:SetAttribute('RunSpeed', 25)
	end

	for _,V in pairs(Tools) do
		local A = V:Clone()
		A.Config:Destroy()
		A.Parent = Player.Backpack
	end
end

local function CharacterSpawned(Character)
	local Player = PlayersService:GetPlayerFromCharacter(Character)

	if not Player:GetAttribute("InMenu") then
		task.wait(.5)
		
		local CharacterArmor = Instance.new("Folder")
		CharacterArmor.Name = "Armor"
		
		for _,ArmorPart in pairs(ArmorTable) do
			local ArmorValue = Instance.new("DoubleConstrainedValue")
			ArmorValue.Name = ArmorPart
			ArmorValue.MaxValue = 0
			ArmorValue.Value = 0
			ArmorValue.Parent = CharacterArmor
		end
		
		CharacterArmor.Parent = Character
		RemoteEventsFolder.NewTeamTag:FireAllClients(Player)
		
		if Player:FindFirstChild("HelmetIsOff") then
			Player.HelmetIsOff:Destroy()
		end
		
		local HelmetIsOff = Instance.new("BoolValue")
		HelmetIsOff.Name = "HelmetIsOff"
		HelmetIsOff.Value = true
		HelmetIsOff.Parent = Player
		
		GiveLoadout(Player)
	else
		Character:FindFirstChild("Humanoid").WalkSpeed = 0
		Character:FindFirstChild("Humanoid").JumpHeight = 0
		Player.Backpack:ClearAllChildren()
	end
end

local function PlayerJoined(Player)
	if not Player:IsInGroup(35731003) and not rs:IsStudio() then
		Player:Kick("Join the group to gain access to the game!")
	end
	
	Player:SetAttribute("InMenu",true)
	
	Player.CharacterAdded:Connect(CharacterSpawned)
	
	local TeamTagsIndicator = Instance.new("BoolValue")
	TeamTagsIndicator.Name = "TeamTagsIndicator"
	TeamTagsIndicator.Parent = Player
	
	local TeamTagsInfo = Instance.new("Folder")
	TeamTagsInfo.Name = "TeamTags_Info"
	
	local TagColor = Instance.new("Color3Value")
	TagColor.Name = "TagColor"
	TagColor.Value = Color3.new(1,1,1)
	TagColor.Parent = TeamTagsInfo
	
	local TagIcon = Instance.new("StringValue")
	TagIcon.Name = "TagIcon"
	TagIcon.Value = "rbxassetid://15861888132"
	TagIcon.Parent = TeamTagsInfo
	
	local TagLoreName = Instance.new("StringValue")
	TagLoreName.Name = "TagNameTag"
	TagLoreName.Value = ""
	TagLoreName.Parent = TeamTagsInfo
	
	TeamTagsInfo.Parent = Player
	
	if Config.ShowRank then
		local LeaderStats = Instance.new("Folder")
		LeaderStats.Name = "leaderstats"

		local Kills = Instance.new("IntValue")
		Kills.Name = "Kills"
		Kills.Value = 0
		Kills.Parent = LeaderStats

		local GroupRank = Instance.new("StringValue")
		GroupRank.Name = "Rank"
		GroupRank.Value = Player:GetRoleInGroup(Config.MainGroupId)
		GroupRank.Parent = LeaderStats

		LeaderStats.Parent = Player
	end
end

PlayersService.PlayerAdded:Connect(PlayerJoined)

PlayersService.PlayerRemoving:Connect(function(Player)
	for I,V in pairs(ServerLoadoutsData) do
		if V[1] == Player.Name then
			table.remove(ServerLoadoutsData,I)
			break
		end
	end
end)
--------------------------------------------------------------------------------
RemoteEventsFolder.Deploy.OnServerEvent:Connect(PlayerDeployed)

RemoteEventsFolder.ChangeTeam.OnServerEvent:Connect(function(Player,Team)
	Player.Team = TeamsService:FindFirstChild(Team.Name)
end)

RemoteEventsFolder.OpenMenu.OnServerEvent:Connect(function(Player)
	Player:SetAttribute("InMenu",true)
	Player:LoadCharacter()
	
	wait(.5)
	
	for I,V in pairs(ServerLoadoutsData) do
		if V[1] == Player then
			RemoteEventsFolder.ReturnMenu:FireClient(Player,V[2])
			break
		end
	end
end)

RemoteEventsFolder.Quit.OnServerEvent:Connect(function(Player)
	Player:Kick(Config.QuitMessages[math.random(1,#Config.QuitMessages)])
end)

RemoteEventsFolder.Repair.OnServerEvent:Connect(function(Player,ToBeRepaired)
	if ToBeRepaired:IsA('Humanoid') then
		ToBeRepaired.Health += math.random(50,200)
	else
		ToBeRepaired.Value = ToBeRepaired.Value + 100
	end
end)

RemoteEventsFolder.Cloak.OnServerEvent:Connect(function(Player)
	local Character = Player.Character
	local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
	
	local C2 = Character
	
	if Character:FindFirstChild("CamoColor") then
		if C2.Humanoid.FloorMaterial == Enum.Material.Asphalt or C2.Humanoid.FloorMaterial == Enum.Material.Basalt or C2.Humanoid.FloorMaterial == Enum.Material.Brick or C2.Humanoid.FloorMaterial == Enum.Material.Cobblestone or C2.Humanoid.FloorMaterial == Enum.Material.Concrete or C2.Humanoid.FloorMaterial == Enum.Material.CrackedLava or C2.Humanoid.FloorMaterial == Enum.Material.Glacier or C2.Humanoid.FloorMaterial == Enum.Material.Grass or C2.Humanoid.FloorMaterial == Enum.Material.LeafyGrass or C2.Humanoid.FloorMaterial == Enum.Material.Ground or C2.Humanoid.FloorMaterial == Enum.Material.Limestone or C2.Humanoid.FloorMaterial == Enum.Material.Ice or C2.Humanoid.FloorMaterial == Enum.Material.Mud or C2.Humanoid.FloorMaterial == Enum.Material.Rock or C2.Humanoid.FloorMaterial == Enum.Material.Salt or C2.Humanoid.FloorMaterial == Enum.Material.Sand or C2.Humanoid.FloorMaterial == Enum.Material.Sandstone or C2.Humanoid.FloorMaterial == Enum.Material.Slate or C2.Humanoid.FloorMaterial == Enum.Material.Snow or C2.Humanoid.FloorMaterial == Enum.Material.WoodPlanks then
			Character:FindFirstChild("CamoColor").Value = workspace.Terrain:GetMaterialColor(Humanoid.FloorMaterial)
		end
	end
	
	pcall(function()
		for _,W in pairs(Character:GetDescendants()) do
			if W.Name == "CamoF" or W.Name == "HoodDown" or W.Name == "HoodUp" then
				local AA = workspace.Terrain:GetMaterialColor(Humanoid.FloorMaterial)
				local H,S,V = AA:ToHSV()
				W.Color = AA
			end
		end
	end)
end)

RemoteEventsFolder.Hood.OnServerEvent:Connect(function(Player,Toggle)
	local Character = Player.Character
	local Humanoid = Character.Humanoid
	local onAnim = Humanoid:LoadAnimation(script.HelmetOn)
	local offAnim = Humanoid:LoadAnimation(script.HelmetOff)
	
	if Player.Character:FindFirstChild("Cloaked") then
		Player.Character:FindFirstChild("Cloaked").Value = Toggle
		Player.Character:FindFirstChild("SneakValue").Value = Player.Character:FindFirstChild("SneakValue").MaxValue/4
	end
	
	if Toggle then
		onAnim:Play()
		
		task.wait(0.5)
		
		local hood = script.Hood:Clone()
		hood.Parent = Player.Character:FindFirstChild("Head")
		hood:Destroy()
		
		for _,V in pairs(Character:GetDescendants()) do
			if V.Name == "HoodUp" then
				V.Transparency = 0
			elseif V.Name == "HoodDown" then
				V.Transparency = 1
			elseif V:IsA("Accessory") then
				if V.AccessoryType == Enum.AccessoryType.Hair then
					V.Handle.Transparency = 1
				end
			end
		end
	else
		offAnim:Play()
		
		task.wait(0.5)
		
		local hood = script.Hood:Clone()
		hood.Parent = Player.Character:FindFirstChild("Head")
		hood.PlaybackSpeed = 0.85
		hood:Destroy()
		
		for _,V in pairs(Character:GetDescendants()) do
			if V.Name == "HoodUp" then
				V.Transparency = 1
			elseif V.Name == "HoodDown" then
				V.Transparency = 0
			elseif V:IsA("Accessory") then
				if V.AccessoryType == Enum.AccessoryType.Hair then
					V.Handle.Transparency = 0
				end
			end
		end
	end
end)

RemoteEventsFolder.Mask.OnServerEvent:Connect(function(Player,Toggle)
	local Character = Player.Character
	local Humanoid = Character.Humanoid
	local onAnim = Humanoid:LoadAnimation(script.HelmetOn)
	local offAnim = Humanoid:LoadAnimation(script.HelmetOff)

	if not Toggle then
		offAnim:Play()

		task.wait(0.5)

		local hood = script.Hood:Clone()
		hood.Parent = Player.Character:FindFirstChild("Head")
		hood:Destroy()

		for _,V in pairs(Character:GetDescendants()) do
			if V.Name == "MaskUp" then
				V.Transparency = 0
			elseif V.Name == "MaskDown" then
				V.Transparency = 1
			end
		end
	else
		onAnim:Play()
	
		task.wait(0.5)

		local hood = script.Hood:Clone()
		hood.Parent = Player.Character:FindFirstChild("Head")
		hood.PlaybackSpeed = 0.85
		hood:Destroy()

		for _,V in pairs(Character:GetDescendants()) do
			for _,V in pairs(Character:GetDescendants()) do
				if V.Name == "MaskUp" then
					V.Transparency = 1
				elseif V.Name == "MaskDown" then
					V.Transparency = 0
				end
			end
		end
	end
end)
--------------------------------------------------------------------------------
RemoteEventsFolder.ChangedPlayerStance.OnServerEvent:Connect(function(Player,Stance)
	if Player:FindFirstChild("Character") then
		if Player.Character:FindFirstChild("SneakValue") and Player.Character:FindFirstChild("Cloaked") then
			if Player.Character:FindFirstChild("Cloaked").Value then
				if Stance == 0 then
					Player.Character:FindFirstChild("SneakValue").Value = Player.Character:FindFirstChild("SneakValue").MaxValue/4
				elseif Stance == 1 then
					Player.Character:FindFirstChild("SneakValue").Value = Player.Character:FindFirstChild("SneakValue").MaxValue/3
				elseif Stance == 2 then
					Player.Character:FindFirstChild("SneakValue").Value = Player.Character:FindFirstChild("SneakValue").MaxValue
				end
			else
				Player.Character:FindFirstChild("SneakValue").Value = 0	
			end
		elseif Player.Character:FindFirstChild("SneakValue") and not Player.Character:FindFirstChild("Camo") then
			if Stance == 0 then
				Player.Character:FindFirstChild("SneakValue").Value = 0
			elseif Stance == 1 then
				Player.Character:FindFirstChild("SneakValue").Value = Player.Character:FindFirstChild("SneakValue").MaxValue/3
			elseif Stance == 2 then
				Player.Character:FindFirstChild("SneakValue").Value = Player.Character:FindFirstChild("SneakValue").MaxValue
			end
		end
	end
end)
--------------------------------------------------------------------------------
local TextService = game:GetService("TextService")

RemoteEventsFolder:FindFirstChild("SetTeamTag").OnServerEvent:Connect(function(Player,ToSet,NewValue)
	if ToSet == "TagNameTag" then
		if NewValue ~= "" then
			local FilteredTextResult,Check
			local Success,Error = pcall(function()
				FilteredTextResult = TextService:FilterStringAsync(NewValue,Player.UserId)
				FilteredTextResult = FilteredTextResult:GetNonChatStringForBroadcastAsync()
			end)
			
			if Success then
				Player:FindFirstChild("TeamTags_Info"):FindFirstChild(ToSet).Value = FilteredTextResult
				UpdateTagEvent:FireAllClients()
			end
		end
	else
		Player:FindFirstChild("TeamTags_Info"):FindFirstChild(ToSet).Value = NewValue
		UpdateTagEvent:FireAllClients()
	end
end)

RemoteEventsFolder:FindFirstChild("ToggleTeamTags").OnServerEvent:Connect(function(Player)
	Player:FindFirstChild("TeamTagsIndicator").Value = not Player:FindFirstChild("TeamTagsIndicator").Value
end)

local db = false

RemoteEventsFolder:FindFirstChild("ToggleHelmet").OnServerEvent:Connect(function(Player,Helmet,Toggle)
	local HelmetIsOff = Player:FindFirstChild("HelmetIsOff")
	local Humanoid = Player.Character.Humanoid
	local onAnim = Humanoid:LoadAnimation(script.HelmetOn)
	local offAnim = Humanoid:LoadAnimation(script.HelmetOff)
	
	if HelmetIsOff then
		HelmetIsOff.Value = Toggle
	end
	
	if Toggle then
		local HeadArmorValue = Instance.new("IntValue")
		HeadArmorValue.Value = Player.Character:FindFirstChild("Armor"):FindFirstChild("HeadArmor").Value
		Player.Character:FindFirstChild("Armor"):FindFirstChild("HeadArmor").Value = 0
		HeadArmorValue.Name = "HeadArmorValue"
		HeadArmorValue.Parent = Helmet
		
		local offSound = script.Off:Clone()
		offSound.Parent = Player.Character:FindFirstChild("Head")
		offSound:Destroy()
		
		offAnim:Play()
		
		task.wait(0.5)
		
		Player.Character:FindFirstChild("Head").Transparency = 0
		if Player.Character:FindFirstChild("Head"):FindFirstChildWhichIsA("Decal") then
			Player.Character:FindFirstChild("Head"):FindFirstChildWhichIsA("Decal").Transparency = 0
		end
		
		for _,V in pairs(Player.Character:GetChildren()) do
			if V:IsA("Accessory") and V.AccessoryType == Enum.AccessoryType.Hair then
				V.Handle.Transparency = 0
			elseif V:IsA("Accessory") and V.AccessoryType == Enum.AccessoryType.Face then
				V.Handle.Transparency = 0
			end
		end
		
		
		for _,V in pairs(Helmet:GetDescendants()) do
			if V.Name ~= "Middle" then
				pcall(function()
					V.Transparency = 1
				end)
			end
		end
	else
		local HeadArmorValue = Helmet:FindFirstChild("HeadArmorValue")
		if HeadArmorValue then
			Player.Character:FindFirstChild("Armor"):FindFirstChild("HeadArmor").Value = Helmet:FindFirstChild("HeadArmorValue").Value
			HeadArmorValue:Destroy()
		end
		

		onAnim:Play()
		
		task.wait(0.5)
		
		local onSound = script.On:Clone()
		onSound.Parent = Player.Character:FindFirstChild("Head")
		onSound:Destroy()

		local metal = script.Metal:Clone()
		metal.Parent = Player.Character:FindFirstChild("Head")
		metal:Destroy()
		
		Player.Character:FindFirstChild("Head").Transparency = 1
		if Player.Character:FindFirstChild("Head"):FindFirstChildWhichIsA("Decal") then
			Player.Character:FindFirstChild("Head"):FindFirstChildWhichIsA("Decal").Transparency = 1
		end
		
		for _,V in pairs(Player.Character:GetChildren()) do
			if V:IsA("Accessory") then
				if V.AccessoryType == Enum.AccessoryType.Hair or V.AccessoryType == Enum.AccessoryType.Face then
					V.Handle.Transparency = 1
				end
			end
		end

		for _,V in pairs(Helmet:GetDescendants()) do
			if V.Name ~= "Middle"  then
				pcall(function()
					V.Transparency = 0
				end)
			end
		end
	end
end)

repeat wait() until workspace:FindFirstChild("CameraParts")

for _,V in pairs(workspace:FindFirstChild("CameraParts"):GetChildren()) do
	pcall(function()
		V.Anchored = true
		V.Transparency = 1
		V.CanCollide = false
		V.CastShadow = false
	end)
end