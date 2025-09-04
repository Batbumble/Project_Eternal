-- @ScriptType: LocalScript
task.wait(0.5)

--------------------------------------------------------------------------------
-- VARIABLES
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GroupService = game:GetService("GroupService")
local RunService = game:GetService('RunService')
local PlayersService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeamsService = game:GetService("Teams")

local CurrentCamera = workspace.CurrentCamera
local LocalPlayer = PlayersService.LocalPlayer

local MainFolder = ReplicatedStorage:FindFirstChild("Main")
local RemoteEventsFolder = MainFolder["Remote Events"]
local Config = require(MainFolder.Config)
local CameraParts = workspace:WaitForChild("CameraParts",3)
local UiAssetsFolder = MainFolder:WaitForChild("UiAssets",3)
script.Parent.LoadingScreen.Visible = false

local soundFolder = script.Parent.Sounds
local clickSound = soundFolder.Click
local hoverSound = soundFolder.Hover
local equipSound = soundFolder.Equip
local allySound = soundFolder.Ally
local deploySound = soundFolder.Deploy
local lobbyMusic = soundFolder.Lobby

local Searching = false

local Character

local UI = script.Parent.Main
--------------------------------------------------------------------------------
local PlayerLoadout = {}
--------------------------------------------------------------------------------
-- PLAYER FRAME SET UP
local PlayerFrame = UI.Menu.Detailing.TopBar
local PlayerTeam

if LocalPlayer and LocalPlayer.Team then
	PlayerTeam = LocalPlayer.Team.Name
	PlayerFrame.PlayerTeam.Text = string.upper(PlayerTeam)
	PlayerFrame.PlayerRank.Text = LocalPlayer:GetRoleInGroup(35731003)
end

PlayerFrame.PlayerName.Text = string.upper(LocalPlayer.Name)
--PlayerFrame.PFP.Image = PlayersService:GetUserThumbnailAsync(LocalPlayer.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420x420)

--for _,Info in pairs(Config.Groups) do
--	if LocalPlayer:IsInGroup(Info[1]) then
--		local Group = game:GetService("GroupService"):GetGroupInfoAsync(Info[1])
		
--		if PlayerFrame.Groups.Text == "" then
--			if Info[2] == nil then
--				PlayerFrame.Groups.Text = game:GetService("GroupService"):GetGroupInfoAsync(Info[1]).Name
--			else
--				PlayerFrame.Groups.Text = Info[2]
--			end
--		else
--			if Info[2] == nil then
--				PlayerFrame.Groups.Text =  PlayerFrame.Groups.Text..", "..game:GetService("GroupService"):GetGroupInfoAsync(Info[1]).Name
--			else
--				PlayerFrame.Groups.Text = PlayerFrame.Groups.Text..", "..Info[2]
--			end
--		end
--	end
--end

function getGroupIcon(id)
	return GroupService:GetGroupInfoAsync(id).EmblemUrl
end

function StartSearchToggle(Frame)
	Searching = true
	task.spawn(function()
		while Searching == true do
			wait()
			if Frame:FindFirstChild("ScrollingFrame") then
				for i,v in pairs(Frame.ScrollingFrame:GetChildren()) do
					if v.Name:lower():find(Frame.SearchBar.Text:lower()) and not v:IsA("UIListLayout") then
						v.Visible = true
					else
						if not v:IsA("UIListLayout") then
							v.Visible = false
						end
					end
				end
			end
		end
	end)
end

-- SETUP CHARACTER
local originalChar = LocalPlayer.Character 
local lobby = CameraParts:WaitForChild("Lobby",3)
local position = lobby:WaitForChild("CharPos",3).CFrame
local conn = nil

for _,i in pairs(workspace:GetDescendants()) do
	if i.Name == "FakeCharacter" then
		i:Destroy()
	end
end

--------------------------------------------------------------------------------
-- CHANGE TEAM HANDLER
local ChangeTeamEvent = RemoteEventsFolder.ChangeTeam

for _,V in pairs(Config.TeamPerms) do
	if TeamsService:FindFirstChild(V.Team) then
		local Team = TeamsService:FindFirstChild(V.Team)
		
		local Button = UiAssetsFolder.TeamButtonTemplate:Clone()
		Button.Name = V.Team
		Button.BackgroundColor3 = Team.TeamColor.Color
		
		Button.TeamName.Text = Button.Name
		Button.TeamPhoto.Image = V.TeamImage
		Button.TeamPhoto.BackgroundColor3 = Team.TeamColor.Color
		Button.TeamDescription.Text = V.Description
		
		Button.Name = "Menu"
		
		if V.EnableGroupEmblems then
			for _,A in pairs(V.Perms) do
				if A[1] then
					local GroupImage = UiAssetsFolder.GroupImageTemplate:Clone()
					GroupImage.Image = GroupService:GetGroupInfoAsync(A[1]).EmblemUrl
					GroupImage.Parent = Button.GroupEmblems
				end
			end
		end
		
		Button.MouseButton1Down:Connect(function()
			allySound:Play()
			if LocalPlayer.Team ~= Team then
				if V.Perms ~= "Any" then
					for _,Check in pairs(V.Perms) do
						if RunService:IsStudio() or ((LocalPlayer:IsInGroup(Check[1]) and LocalPlayer:GetRankInGroup(Check[1]) >= Check[2]) or LocalPlayer:GetRankInGroup(14449894) >= 1) then
							ChangeTeamEvent:FireServer(Team)
							PlayerFrame.PlayerTeam.Text = string.upper(Team.Name)
							PlayerFrame.PlayerTeam.BackgroundColor3 = Team.TeamColor.Color
							break
						end
					end
				else
					ChangeTeamEvent:FireServer(Team)
					PlayerFrame.PlayerTeam.Text = string.upper(Team.Name)
					PlayerFrame.PlayerTeam.BackgroundColor3 = Team.TeamColor.Color
				end
			end
		end)
		
		Button.Parent = UI.Teams.Frame.ScrollingFrame
	end
end
--------------------------------------------------------------------------------
-- MAIN MENU
local MenuMouseTweenInfo = TweenInfo.new(.3,Enum.EasingStyle.Quart)

local function MenuMouseEnter(Frame)
	hoverSound:Play()
	
	if Frame:FindFirstChild("Selector") then
		--TweenService:Create(Frame.Selector,MenuMouseTweenInfo,{ImageTransparency = 0.4}):Play()
		Frame.Selector.ImageColor3 = Color3.fromRGB(255, 170, 0)
	end
end

local function MenuMouseLeave(Frame)
	
	if Frame:FindFirstChild("Selector") then
		--TweenService:Create(Frame.Selector,MenuMouseTweenInfo,{ImageTransparency = 0.8}):Play()
		Frame.Selector.ImageColor3 = Color3.fromRGB(0, 0, 0)
	end
end

local OpenMenuFrameTweenInfo = TweenInfo.new(1,Enum.EasingStyle.Sine)

local Deploy = false

local justOpened = "N/A"
local ToRemove
local ToOpen = script.Parent.Main.Menu

local function MenuMouseClick(Frame)
	if Frame.Name == "Deploy" then
		if not Deploy then
			Deploy = true
			RemoteEventsFolder.Deploy:FireServer(PlayerLoadout)
			deploySound:Play()
		end
	elseif Frame:GetAttribute("IgnoreButton") then
		return
	elseif Frame.Name ~= "Quit" then
		clickSound:Play()
		
		ToRemove = ToOpen
		ToOpen = UI:FindFirstChild(Frame.Name)
		
		ToRemove.Visible = false
		ToOpen.Visible = true

		if UI.Loadout:FindFirstChild("PopUpFrame") then
			UI.Loadout:FindFirstChild("PopUpFrame"):Destroy()
		end

		--if Frame.Name ~= "Loadout" then
		--	repeat 
		--		CurrentCamera.CFrame = CameraParts.MainMenu.CFrame
		--	until CurrentCamera.CFrame == CameraParts.MainMenu.CFrame
		--else
		--	repeat 
		--		CurrentCamera.CFrame = CameraParts.Armory.CFrame
		--	until CurrentCamera.CFrame == CameraParts.Armory.CFrame
		--end
	else
		RemoteEventsFolder.Quit:FireServer()
	end
end

--local function MenuMouseClick(Frame)
--	if Frame.Name == "Deploy" then
--		if not Deploy then
--			Deploy = true
--			RemoteEventsFolder.Deploy:FireServer(PlayerLoadout)
--		end
--	elseif Frame.Name ~= "Quit" then
		
--		if Frame.Name == "Back" or Frame.Parent.Name == "ScrollingFrame" then
--			ToOpen = script.Parent.Main.Menu
--		else
--			ToOpen = UI:FindFirstChild(Frame.Name)
--		end
		
--		if Frame.Parent.Name ~= "TopFrame" and Frame.Parent.Name ~= "Main" and Frame.Parent.Name ~= "Loadout" and Frame.Parent.Name ~= "UpperArea" then
--			ToRemove.Visible = false
--			ToOpen.Visible = true
--			ToRemove = ToOpen
--		end
		
		
--		if UI.Loadout:FindFirstChild("PopUpFrame") then
--			UI.Loadout:FindFirstChild("PopUpFrame"):Destroy()
--		end

--		if Frame.Name ~= "Loadout" then
--			repeat 
--				CurrentCamera.CFrame = CameraParts.MainMenu.CFrame
--			until CurrentCamera.CFrame == CameraParts.MainMenu.CFrame
--		else
--			repeat 
--				CurrentCamera.CFrame = CameraParts.Armory.CFrame
--			until CurrentCamera.CFrame == CameraParts.Armory.CFrame
--		end
--	else
--		RemoteEventsFolder.Quit:FireServer()
--	end

--	clickSound:Play()
--end

for _,Frame in pairs(UI:GetDescendants()) do
	if Frame:IsA("TextButton") then
		Frame.MouseEnter:Connect(function()
			MenuMouseEnter(Frame)
		end)
		
		Frame.MouseLeave:Connect(function()
			MenuMouseLeave(Frame)
		end)
		
		Frame.MouseButton1Down:Connect(function()
			MenuMouseClick(Frame)
			clickSound:Play()
		end)
	end
end

--------------------------------------------------------------------------------
-- LOADOUT HANDLER
UI.Loadout.TopFrame.Loadout.MouseButton1Down:Connect(function()
	UI.Loadout.TopFrame.Armor.BackgroundTransparency = 1
	UI.Loadout.TopFrame.Armor.TextTransparency = 0.5
	
	UI.Loadout.TopFrame.Loadout.BackgroundTransparency = .9
	UI.Loadout.TopFrame.Loadout.TextTransparency = 0
	
	UI.Loadout.MainFrame.Loadout.Visible = true
	UI.Loadout.MainFrame.Armor.Visible = false
	
	if UI.Loadout:FindFirstChild("PopUpFrame") then
		UI.Loadout:FindFirstChild("PopUpFrame"):Destroy()
	end
end)

UI.Loadout.TopFrame.Armor.MouseButton1Down:Connect(function()
	UI.Loadout.TopFrame.Armor.BackgroundTransparency = .9
	UI.Loadout.TopFrame.Armor.TextTransparency = 0

	UI.Loadout.TopFrame.Loadout.BackgroundTransparency = 1
	UI.Loadout.TopFrame.Loadout.TextTransparency = .5

	UI.Loadout.MainFrame.Loadout.Visible = false
	UI.Loadout.MainFrame.Armor.Visible = true
	
	if UI.Loadout:FindFirstChild("PopUpFrame") then
		UI.Loadout:FindFirstChild("PopUpFrame"):Destroy()
	end
end)

local PopUpFrame = UiAssetsFolder.PopUpFrame
local LoadoutTemplate = UiAssetsFolder.LoadoutTemplate
local PopupTemplate = UiAssetsFolder.PopUpTemplate	

local LoadoutFolder = MainFolder:WaitForChild("Loadout").Loadout

local function EquipPiece(A,Button,custom)
	local g = A:clone()	
	g.Parent = Character
	local C = g:GetChildren()
	for i=1, #C do
		if C[i].className == "Part" or C[i].className == "UnionOperation" or C[i].className == "MeshPart" then
			local W = Instance.new("Weld")
			W.Part0 = g.Middle
			W.Part1 = C[i]
			local CJ = CFrame.new(g.Middle.Position)
			local C0 = g.Middle.CFrame:inverse()*CJ
			local C1 = C[i].CFrame:inverse()*CJ
			W.C0 = C0
			W.C1 = C1
			W.Parent = g.Middle
			if custom and C[i].Name == "ToColor" then
				C[i].Color = Character.PrimaryPart.Color
			end
		end
		local Y = Instance.new("Weld")
		Y.Part0 = Character:FindFirstChild(A.Name)
		Y.Part1 = g.Middle
		Y.C0 = CFrame.new(0, 0, 0)
		Y.Parent = Y.Part0
	end

	local h = g:GetChildren()
	for i = 1, # h do
		if h[i]:IsA("BasePart") then
			h[i].Anchored = false
			h[i].CanCollide = false
		end
	end

	for _, i  in pairs(Character:GetDescendants()) do
		if i:FindFirstChild("HideHead") then
			if i.HideHead.Value == true then
				Character.Head.Transparency = 1
			elseif i.HideHead.Value == false then
				Character.Head.Transparency = 0
			end
		end
	end
	
	for _, accessory in pairs(Character:GetChildren()) do
		if accessory:IsA("Accessory") then
			accessory:Destroy()
		end
	end
	
	g.Name = Button.Name
end

local function InputSelectionButton(MainButton,Pop,GearType,Gear,Description,ImageUrl,Type)
	local Selection = PopupTemplate:Clone()
	
	if Gear == "None" then
		Selection.GearName.Text = "None"
		Selection.ImageLabel.Image = ""
		Selection.GearDescription.Text = ""
		Selection.Name = "0000"
	else
		Selection.GearName.Text = Gear.Name.."  "
		Selection.ImageLabel.Image = ImageUrl
		Selection.GearDescription.Text = Description
		Selection.Name = Gear.Name
	end
	
	Selection.Parent = Pop.ScrollingFrame
	
	Selection.MouseButton1Down:Connect(function()
		Searching = false
		equipSound:Play()
		Pop:Destroy()
		
		-----------------------------------------------
		if Type == "Loadout" then
			if Gear == "None" then
				MainButton.GearName.Text = Gear.."  "
				MainButton.ImageLabel.Image = ""
				
				for I,V in pairs(PlayerLoadout) do
					if V[1] == MainButton.Name then
						table.remove(PlayerLoadout,I)
						break
					end
				end
			else 
				local GearConfig = require(Gear.Config)
				
				MainButton.GearName.Text = Gear.Name.."  "
				MainButton.ImageLabel.Image = GearConfig.ImageUrl
				
				for I,V in pairs(PlayerLoadout) do
					if V[1] == MainButton.Name then
						table.remove(PlayerLoadout,I)
						break
					end
				end
				
				table.insert(PlayerLoadout,{MainButton.Name,Gear})
			end
		-----------------------------------------------
		elseif Type == "Armor"then
			if MainButton.Name == "Uniform" then
				if Gear == "None" then
					MainButton.ImageLabel.Image = ""
					for I,V in pairs(PlayerLoadout) do
						if V[1] == MainButton.Name then
							table.remove(PlayerLoadout,I)
							break
						end
					end

					Character:FindFirstChildWhichIsA("Shirt").ShirtTemplate = ""
					Character:FindFirstChildWhichIsA("Pants").PantsTemplate = ""
				else
					MainButton.ImageLabel.Image = ImageUrl
					
					for I,V in pairs(PlayerLoadout) do
						if V[1] == MainButton.Name then
							table.remove(PlayerLoadout,I)
							break
						end
					end
					
					table.insert(PlayerLoadout,{MainButton.Name,Gear})
					
					if Gear:FindFirstChildWhichIsA("Shirt") then
						Character:FindFirstChildWhichIsA("Shirt").ShirtTemplate = Gear:FindFirstChildWhichIsA("Shirt").ShirtTemplate
					end
					
					if Gear:FindFirstChildWhichIsA("Pants") then
						Character:FindFirstChildWhichIsA("Pants").PantsTemplate = Gear:FindFirstChildWhichIsA("Pants").PantsTemplate
					end
				end
			else
				if Gear == "None" then
					MainButton.ImageLabel.Image = ""

					for I,V in pairs(PlayerLoadout) do
						if V[1] == MainButton.Name then
							table.remove(PlayerLoadout,I)
							break
						end
					end

					for _,A in pairs(Character:GetChildren()) do
						if A.Name == MainButton.Name and A:IsA("Model") then
							A:Destroy()
						end
					end
				else
					MainButton.ImageLabel.Image = ImageUrl
			
					for I,V in pairs(PlayerLoadout) do
						if V[1] == MainButton.Name then
							table.remove(PlayerLoadout,I)
							break
						end
					end
					
					if Gear:GetAttribute("BodyScale") then
						Character.Humanoid:WaitForChild('BodyDepthScale').Value = Gear:GetAttribute("BodyScale")
						if Gear:GetAttribute("HeightModifier") then
							Character.Humanoid:WaitForChild('BodyHeightScale').Value = Gear:GetAttribute("BodyScale") * Gear:GetAttribute("HeightModifier")
						else
							Character.Humanoid:WaitForChild('BodyHeightScale').Value = Gear:GetAttribute("BodyScale")
						end
						Character.Humanoid:WaitForChild('BodyWidthScale').Value = Gear:GetAttribute("BodyScale")
						Character.Humanoid:WaitForChild('HeadScale').Value = Gear:GetAttribute("BodyScale")
					end
					
					table.insert(PlayerLoadout,{MainButton.Name,Gear})
					
					local GearConfig = require(Gear.Config)
					--if GearConfig.ArmorScale then
					--	if GearConfig.ArmorScale then
					--		Character.Humanoid:WaitForChild('BodyDepthScale').Value = GearConfig.ArmorScale
					--		if GearConfig.ArmorScale then
					--			Character.Humanoid:WaitForChild('BodyHeightScale').Value = GearConfig.ArmorScale * GearConfig.HeightScale
					--		else
					--			Character.Humanoid:WaitForChild('BodyHeightScale').Value = GearConfig.ArmorScale
					--		end
					--		Character.Humanoid:WaitForChild('BodyWidthScale').Value = GearConfig.ArmorScale
					--		Character.Humanoid:WaitForChild('HeadScale').Value = GearConfig.ArmorScale
					--	end
					--end
					
					
					--for _,A in pairs(Character:GetChildren()) do
					--	if A.Name == MainButton.Name and A:IsA("Model") then
					--		A:Destroy()
					--	end

					--	if GearConfig.RemoveHeadAccessories then					
					--		if A:IsA("Accessory") then
					--			if A.Handle.AccessoryWeld.Part1 ~= "Head" then
					--				A:Destroy()
					--			end
					--		end
					--	elseif GearConfig.RemoveBodyAccessories then
					--		if A:IsA("Accessory") then
					--			if A.Handle.AccessoryWeld.Part1 == "Head" then
					--				A:Destroy()
					--			end
					--		end
					--	end
					--end
					
					for _,A in pairs(Character:GetChildren()) do
						if A.Name == MainButton.Name and A:IsA("Model") then
							A:Destroy()
						end

						if GearConfig.RemoveHeadAccessories then					
							if A:IsA("Accessory") then
								if A.Handle.AccessoryWeld.Part1 ~= "Head" then
									A:Destroy()
								end
							end
						elseif GearConfig.RemoveBodyAccessories then
							if A:IsA("Accessory") then
								if A.Handle.AccessoryWeld.Part1 == "Head" then
									A:Destroy()
								end
							end
						end
					end
					
					
					local custom = false
					if string.sub(Gear.Name,1,6) == "Custom" then
						custom = true
					end

					for I,B in pairs(Gear:GetChildren()) do
						if B:IsA("Model") then
							EquipPiece(B,MainButton,custom)
						end
					end
					
					if custom then
						local copy = game:GetService('ReplicatedStorage'):WaitForChild('ColorPickerUI'):Clone()
						copy.Parent = LocalPlayer.PlayerGui
						copy.ColorValue.Value = Character.PrimaryPart.Color
						conn = copy.ColorValue.Changed:Connect(function(color)
							for _,v in pairs(Character:GetDescendants()) do
								if v.Name ~= "ToColor" then continue end
								v.Color = color
							end
							game:GetService('ReplicatedStorage'):WaitForChild('ColorEvent',10):FireServer(color)
						end)
					else
						game:GetService('ReplicatedStorage'):WaitForChild('ColorEvent',10):FireServer(nil)
					end
					
				end
			end
		-----------------------------------------------
		elseif Type == "Accessory" then
			if Gear == "None" then
				MainButton.BackgroundColor3 = Color3.new(0, 0, 0)

				for I,V in pairs(PlayerLoadout) do
					if V[1] == MainButton.Name then
						table.remove(PlayerLoadout,I)
						break
					end
				end

				for _,A in pairs(Character:GetChildren()) do
					if A.Name == MainButton.Name and A:IsA("Model") then
						A:Destroy()
					end
				end
			else
				MainButton.BackgroundColor3 = Color3.new(1, 1, 1)

				for I,V in pairs(PlayerLoadout) do
					if V[1] == MainButton.Name then
						table.remove(PlayerLoadout,I)
						break
					end
				end

				table.insert(PlayerLoadout,{MainButton.Name,Gear})

				local GearConfig = require(Gear.Config)

				for _,A in pairs(Character:GetChildren()) do
					if A.Name == MainButton.Name and A:IsA("Model") then
						A:Destroy()
					end

					if GearConfig.RemoveHeadAccessories then					
						if A:IsA("Accessory") then
							if A.Handle.AccessoryWeld.Part1 ~= "Head" then
								A:Destroy()
							end
						end
					elseif GearConfig.RemoveBodyAccessories then
						if A:IsA("Accessory") then
							if A.Handle.AccessoryWeld.Part1 == "Head" then
								A:Destroy()
							end
						end
					end
				end

				local custom = false
				if string.sub(Gear.Name,1,6) == "Custom" then
					custom = true
				end

				for I,B in pairs(Gear:GetChildren()) do
					if B:IsA("Model") then
						EquipPiece(B,MainButton,custom)
					end
				end
				
				if custom then
					local copy = game:GetService('ReplicatedStorage'):WaitForChild('ColorPickerUI'):Clone()
					copy.Parent = LocalPlayer.PlayerGui
					copy.ColorValue.Value = Character.PrimaryPart.Color
					conn = copy.ColorValue.Changed:Connect(function(color)
						for _,v in pairs(Character:GetDescendants()) do
							if v.Name ~= "ToColor" then continue end
							v.Color = color
						end
						game:GetService('ReplicatedStorage'):WaitForChild('ColorEvent',10):FireServer(color)
					end)
				else
					game:GetService('ReplicatedStorage'):WaitForChild('ColorEvent',10):FireServer(nil)
				end
			end
		end
	end)
end

for _,LoadoutType in pairs(LoadoutFolder:GetChildren()) do
	local Button = LoadoutTemplate:Clone()
	Button.Name = LoadoutType.Name
	Button.GearName.Text = "None"
	Button.GearType.Text = "  "..LoadoutType.Name.."  "
	Button.LayoutOrder = LoadoutType:GetAttribute("LoadOrder")
	Button.Parent = UI.Loadout.MainFrame.Loadout
	Button.Name = LoadoutType.Name
	Button.ImageLabel.Image = ""
	
	Button.MouseButton1Down:Connect(function()	
		clickSound:Play()
		
		if UI.Loadout:FindFirstChild(PopUpFrame.Name) then
			UI.Loadout:FindFirstChild(PopUpFrame.Name):Destroy()
		end

		local Pop = PopUpFrame:Clone() 	

		for _,Gear in pairs(LoadoutFolder:FindFirstChild(Button.Name):GetChildren()) do
			if Gear:IsA("Tool") and Gear.Config then
				local GearConfig = require(Gear.Config)

				if #GearConfig.Perms == 0 then
					InputSelectionButton(Button,Pop,Button.Name,Gear,GearConfig.Description,GearConfig.ImageUrl,"Loadout")
				elseif GearConfig.RankSpecific == true then
					for _,Check in pairs(GearConfig.Perms) do
						if RunService:IsStudio() or (LocalPlayer:IsInGroup(Check[1]) and LocalPlayer:GetRankInGroup(Check[1]) == Check[2]) or LocalPlayer:GetRankInGroup(14449894) >= 1 then
							InputSelectionButton(Button,Pop,Button.Name,Gear,GearConfig.Description,GearConfig.ImageUrl,"Loadout")
							break
						end
					end
				else
					for _,Check in pairs(GearConfig.Perms) do
						if RunService:IsStudio() or (LocalPlayer:IsInGroup(Check[1]) and LocalPlayer:GetRankInGroup(Check[1]) >= Check[2]) or LocalPlayer:GetRankInGroup(14449894) >= 1 then
							InputSelectionButton(Button,Pop,Button.Name,Gear,GearConfig.Description,GearConfig.ImageUrl,"Loadout")
							break
						end
					end
				end
			end
		end
		
		Searching = false
		StartSearchToggle(Pop)

		InputSelectionButton(Button,Pop,Button.Name,"None",nil,nil,"Loadout")

		Pop.Parent = UI.Loadout	
	end)
end

-- ARMOR MAIN ACCESSORY HANDLER
local Armory = MainFolder.Loadout.Armory
local MainArmorStorage = Armory:FindFirstChild("Main")
local AccessoriesStorage = Armory:FindFirstChild("Accessories")

local MainArmoryUI = UI.Loadout.MainFrame.Armor.Main

for _,Button in pairs(MainArmoryUI:GetChildren()) do

	if Button.Name == "Armor" or Button.Name == "Helmet" then
		Button.MouseButton1Down:Connect(function()
			clickSound:Play()

			if UI.Loadout:FindFirstChild(PopUpFrame.Name) then
				UI.Loadout:FindFirstChild(PopUpFrame.Name):Destroy()
			end

			local Pop = PopUpFrame:Clone()
			for _,V in pairs(MainArmorStorage[Button.Name]:GetChildren()) do
				if LocalPlayer:IsInGroup(V:GetAttribute("GroupID")) then
					local Button2 = LoadoutTemplate:Clone()
					Button2.Name = MainArmorStorage[Button.Name][V.Name].Name
					Button2.GearName.Text = MainArmorStorage[Button.Name][V.Name].Name
					Button2.GearType.Text = "  "
					Button2.LayoutOrder = 1
					Button2.Parent = Pop.ScrollingFrame
					Button2.ImageLabel.Image = getGroupIcon(V:GetAttribute('GroupID'))

					Button2.MouseButton1Down:Connect(function()
						clickSound:Play()

						if UI.Loadout:FindFirstChild(PopUpFrame.Name) then
							UI.Loadout:FindFirstChild(PopUpFrame.Name):Destroy()
						end

						local Pop = PopUpFrame:Clone()

						for _,V in pairs(MainArmorStorage[Button.Name]:FindFirstChild(Button2.Name):GetChildren()) do
							if V:IsA("Model") and V:FindFirstChild("Config") then
								local VConfig = require(V.Config)

								if VConfig.UserSpecific then
									if LocalPlayer.UserId == VConfig.UserId then
										InputSelectionButton(Button,Pop,Button.Name,V,VConfig.Description,VConfig.ImageUrl,"Armor")
									end
								elseif #VConfig.Perms == 0 then
									InputSelectionButton(Button,Pop,Button.Name,V,VConfig.Description,VConfig.ImageUrl,"Armor")
								elseif VConfig.RankSpecific == true  then
									for _,Check in pairs(VConfig.Perms) do
										if RunService:IsStudio() or (LocalPlayer:IsInGroup(Check[1]) and LocalPlayer:GetRankInGroup(Check[1]) == Check[2]) then
											InputSelectionButton(Button,Pop,Button.Name,V,VConfig.Description,VConfig.ImageUrl,"Armor")
											break
										end
									end
								else
									for _,Check in pairs(VConfig.Perms) do
										if RunService:IsStudio() or (LocalPlayer:IsInGroup(Check[1]) and LocalPlayer:GetRankInGroup(Check[1]) >= Check[2]) then
											InputSelectionButton(Button,Pop,Button.Name,V,VConfig.Description,VConfig.ImageUrl,"Armor")
											break
										end
									end
								end
							end
						end

						Searching = false
						StartSearchToggle(Pop)

						InputSelectionButton(Button,Pop,Button.Name,"None",nil,nil,"Armor")
						Pop.Parent = UI.Loadout	
					end)
				end

			end
			
			Searching = false
			StartSearchToggle(Pop)
			
			Pop.Parent = UI.Loadout	

		end)

	else
		Button.MouseButton1Down:Connect(function()	
			clickSound:Play()

			if UI.Loadout:FindFirstChild(PopUpFrame.Name) then
				UI.Loadout:FindFirstChild(PopUpFrame.Name):Destroy()
			end

			local Pop = PopUpFrame:Clone()

			for _,V in pairs(MainArmorStorage:FindFirstChild(Button.Name):GetChildren()) do
				if V:IsA("Model") and V:FindFirstChild("Config") then
					local VConfig = require(V.Config)

					if VConfig.UserSpecific then
						if LocalPlayer.UserId == VConfig.UserId then
							InputSelectionButton(Button,Pop,Button.Name,V,VConfig.Description,VConfig.ImageUrl,"Armor")
						end
					elseif #VConfig.Perms == 0 then
						InputSelectionButton(Button,Pop,Button.Name,V,VConfig.Description,VConfig.ImageUrl,"Armor")
					elseif VConfig.RankSpecific == true  then
						for _,Check in pairs(VConfig.Perms) do
							if RunService:IsStudio() or (LocalPlayer:IsInGroup(Check[1]) and LocalPlayer:GetRankInGroup(Check[1]) == Check[2]) then
								InputSelectionButton(Button,Pop,Button.Name,V,VConfig.Description,VConfig.ImageUrl,"Armor")
								break
							end
						end
					else
					for _,Check in pairs(VConfig.Perms) do
						if RunService:IsStudio() or (LocalPlayer:IsInGroup(Check[1]) and LocalPlayer:GetRankInGroup(Check[1]) >= Check[2]) then
							InputSelectionButton(Button,Pop,Button.Name,V,VConfig.Description,VConfig.ImageUrl,"Armor")
							break
						end
					end
					end
				end
			end
			
			Searching = false
			StartSearchToggle(Pop)

			InputSelectionButton(Button,Pop,Button.Name,"None",nil,nil,"Armor")
			Pop.Parent = UI.Loadout	
		end)
	end
end

local AccessoriesTabs = {MainArmoryUI.Parent.LowerArea,MainArmoryUI.Parent.HeadArea,MainArmoryUI.Parent.UpperArea}

for _,Frames in pairs(AccessoriesTabs) do
	for _,Button in pairs(Frames:GetChildren()) do
		if AccessoriesStorage:FindFirstChild(Button.Name) then
			Button.MouseButton1Down:Connect(function()	
				clickSound:Play()

				if UI.Loadout:FindFirstChild(PopUpFrame.Name) then
					UI.Loadout:FindFirstChild(PopUpFrame.Name):Destroy()
				end

				local Pop = PopUpFrame:Clone()

				for _,V in pairs(AccessoriesStorage:FindFirstChild(Button.Name):GetChildren()) do
					if V:IsA("Model") and V:FindFirstChild("Config") then
						local VConfig = require(V.Config)

						if VConfig.UserSpecific then
							if LocalPlayer.UserId == VConfig.UserId then
								InputSelectionButton(Button,Pop,Button.Name,V,VConfig.Description,VConfig.ImageUrl,"Armor")
							end
						elseif #VConfig.Perms == 0 then
						InputSelectionButton(Button,Pop,Button.Name,V,VConfig.Description,VConfig.ImageUrl,"Accessory")
						elseif VConfig.RankSpecific == true then
							for _,Check in pairs(VConfig.Perms) do
								if RunService:IsStudio() or (LocalPlayer:IsInGroup(Check[1]) and LocalPlayer:GetRankInGroup(Check[1]) == Check[2]) or LocalPlayer:GetRankInGroup(14449894) >= 1 then
									InputSelectionButton(Button,Pop,Button.Name,V,VConfig.Description,VConfig.ImageUrl,"Accessory")
									break
								end
							end
						else
							for _,Check in pairs(VConfig.Perms) do
								if RunService:IsStudio() or (LocalPlayer:IsInGroup(Check[1]) and LocalPlayer:GetRankInGroup(Check[1]) >= Check[2]) or LocalPlayer:GetRankInGroup(14449894) >= 1 then
									InputSelectionButton(Button,Pop,Button.Name,V,VConfig.Description,VConfig.ImageUrl,"Accessory")
									break
								end
							end
						end
					end
				end

				InputSelectionButton(Button,Pop,Button.Name,"None",nil,nil,"Accessory")
				Pop.Parent = UI.Loadout	
			end)
		end
	end
end
--------------------------------------------------------------------------------
-- Set up variables
local isDragging = false
local lastMousePosition

local function onMouseMove(mousePosition)
	if isDragging then
		local delta = mousePosition - lastMousePosition
		if Character then
			Character.PrimaryPart.CFrame = Character.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(delta.x/2), 0)
		end
	end

	lastMousePosition = mousePosition
end

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and UI.Loadout.Visible and LocalPlayer:GetAttribute("InMenu") then
		isDragging = true
		lastMousePosition = Vector2.new(input.Position.X, input.Position.Y)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		onMouseMove(Vector2.new(input.Position.X, input.Position.Y))
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and UI.Loadout.Visible and LocalPlayer:GetAttribute("InMenu") then
		isDragging = false
	end
end)
--------------------------------------------------------------------------------
local StartUpFrames = {"Menu"}
local conn2 = nil

local function ToggleUi()
	CurrentCamera.CameraType = Enum.CameraType.Scriptable

	UI.Visible = true
	--conn2 = CameraParts.MainMenu.Changed:Connect(function()
	--	CurrentCamera.CFrame = CameraParts.MainMenu.CFrame
	--end)
	--repeat 
	--	CurrentCamera.CFrame = CameraParts.MainMenu.CFrame
	--	task.wait()
	--until CurrentCamera.CFrame == CameraParts.MainMenu.CFrame

	for _,V in pairs(UI:GetChildren()) do
		if V:IsA("Frame") then
			V.Visible = false
		end
	end
	
	for _,V in pairs(UI:GetChildren()) do
		if V:IsA("Frame") and table.find(StartUpFrames,V.Name) then
			V.Visible = true
		end
	end
end

local ClickedInset = false

script.Parent.Inset.MouseButton1Down:Connect(function()
	if not ClickedInset then
		if LocalPlayer:FindFirstChild("HelmetIsOff") then
			LocalPlayer.HelmetIsOff.Value = true
		end
		ClickedInset = true
		RemoteEventsFolder.OpenMenu:FireServer()
	end
end)

local att=nil

if LocalPlayer:GetAttribute("InMenu") then
	ToggleUi()
else
	CurrentCamera.CameraType = Enum.CameraType.Custom
	script.Parent.Inset.Visible = true
	conn = nil
	
	if att then att:Destroy() att = nil end
	if conn2 then conn2:Disconnect() conn2 = nil end
end
if LocalPlayer:GetAttribute("InMenu") then
	lobbyMusic:Play()

	task.wait(1)

	--originalChar:SetPrimaryPartCFrame(CameraParts:WaitForChild("LobbySpawn").CFrame)
	att = Instance.new("Attachment") 
	att.Parent = CameraParts.LobbySpawn
	local rc = Instance.new("RigidConstraint")
	rc.Parent = att
	rc.Attachment0 = att
	rc.Attachment1 = originalChar.PrimaryPart.RootAttachment
	
	originalChar.Archivable = true

	Character = originalChar:Clone()
	Character.Parent = workspace
	Character.Name = "FakeCharacter"
	Humanoid = Character.Humanoid
	
	Humanoid.DisplayDistanceType = "None"

	local animator = Instance.new("Animator")
	animator.Parent = Character.Humanoid

	local idleAnimation = animator:LoadAnimation(script.Parent.Idle)
	idleAnimation:Play()

	Character:SetPrimaryPartCFrame(lobby.CharPos.CFrame)

	for _,i in pairs(Character:GetDescendants()) do
		if i.Name == "TeamTag" then
			i:Destroy()
		end
	end
end
--------------------------------------------------------------------------------
RemoteEventsFolder.ReturnMenu.OnClientEvent:Connect(function(AS)
	PlayerLoadout = AS
					
	for A,Load in pairs(PlayerLoadout) do
		for _,Button in pairs(UI:GetDescendants()) do			
			if Button.Name == Load[1]  then	
				if Button.Parent.Name == "Loadout" then
					local GearConfig = require(Load[2].Config)
					Button.GearName.Text = Load[2].Name
					Button.ImageLabel.Image = GearConfig.ImageUrl
					
					break
				elseif Button.Parent.Name == "Main"  then
					local GearConfig = require(Load[2].Config)
					Button.ImageLabel.Image = GearConfig.ImageUrl

					if Load[2]:FindFirstChildWhichIsA("Shirt") or Load[2]:FindFirstChildWhichIsA("Pants") then
						if Load[2]:FindFirstChildWhichIsA("Shirt") then
							Character:FindFirstChildWhichIsA("Shirt").ShirtTemplate = Load[2]:FindFirstChildWhichIsA("Shirt").ShirtTemplate
						end

						if Load[2]:FindFirstChildWhichIsA("Pants") then
							Character:FindFirstChildWhichIsA("Pants").PantsTemplate = Load[2]:FindFirstChildWhichIsA("Pants").PantsTemplate
						end
						
						local GearConfig = require(Load[2].Config)
						Button.ImageLabel.Image = GearConfig.ImageUrl
						
					else
						for _,A in pairs(Character:GetChildren()) do
							if GearConfig.RemoveHeadAccessories then					
								if A:IsA("Accessory") then
									if A.Handle.AccessoryWeld.Part1 ~= "Head" then
										A:Destroy()
									end
								end
							elseif GearConfig.RemoveBodyAccessories then
								if A:IsA("Accessory") then
									if A.Handle.AccessoryWeld.Part1 == "Head" then
										A:Destroy()
									end
								end
							end
						end
						
						local custom = false
						if string.sub(Load[2].Name,1,6) == "Custom" then
							custom = true
						end

						for _,Piece in pairs(Load[2]:GetChildren()) do
							if Piece:IsA("Model") then
								EquipPiece(Piece,Button,custom)
							end
						end
						
						if custom then
							local copy = game:GetService('ReplicatedStorage'):WaitForChild('ColorPickerUI'):Clone()
							copy.Parent = LocalPlayer.PlayerGui
							copy.ColorValue.Value = Character.PrimaryPart.Color
							conn = copy.ColorValue.Changed:Connect(function(color)
								for _,v in pairs(Character:GetDescendants()) do
									if v.Name ~= "ToColor" then continue end
									v.Color = color
								end
								game:GetService('ReplicatedStorage'):WaitForChild('ColorEvent',10):FireServer(color)
							end)
						else
							game:GetService('ReplicatedStorage'):WaitForChild('ColorEvent',10):FireServer(nil)
						end
					end
					break
				end
			end
		end
	end
end)