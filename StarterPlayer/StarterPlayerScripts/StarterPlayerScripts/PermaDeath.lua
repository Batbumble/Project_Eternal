-- @ScriptType: LocalScript
local RunService = game:GetService("RunService")



RunService.Heartbeat:Connect(function()
	pcall(function()
		if game.ReplicatedStorage:FindFirstChild("PermaDeath").Value then
			task.wait(1)

			if game.Players.LocalPlayer.PlayerGui:WaitForChild("PlayerHud"):GetAttribute("Apothecary") and not game.Players.LocalPlayer:FindFirstChild("HelmetIsOff").Value then
				for _,Player in pairs(game.Players:GetChildren()) do
					if Player.Character:FindFirstChild("Revivable") and Player.Character:FindFirstChild("Revivable").Value > 0 then
						if Player.Character:FindFirstChild("UpperTorso")then
							-- REVIVE UI
							if not Player.Character:FindFirstChild("UpperTorso"):FindFirstChild(script.ReviveCounterUi.Name) then
								local UI = script.ReviveCounterUi:Clone()
								UI.Enabled = true
								UI.TextLabel.Text = Player.Character:FindFirstChild("Revivable").Value
								UI.TextLabel.TextColor3= Color3.new(0, 0, 0):Lerp(Color3.new(1, 0.854902, 0.32549),(Player.Character:FindFirstChild("Revivable").Value / 80))
								UI.Revi.TextColor3= Color3.new(0, 0, 0):Lerp(Color3.new(1, 0.854902, 0.32549),(Player.Character:FindFirstChild("Revivable").Value / 80))
								UI.Parent = Player.Character:FindFirstChild("UpperTorso")
							else
								local UI = Player.Character:FindFirstChild("UpperTorso"):FindFirstChild(script.ReviveCounterUi.Name)
								UI.TextLabel.Text = Player.Character:FindFirstChild("Revivable").Value
								UI.TextLabel.TextColor3= Color3.new(0, 0, 0):Lerp(Color3.new(1, 0.854902, 0.32549),(Player.Character:FindFirstChild("Revivable").Value / 80))
								UI.Revi.TextColor3= Color3.new(0, 0, 0):Lerp(Color3.new(1, 0.854902, 0.32549),(Player.Character:FindFirstChild("Revivable").Value / 80))
							end 
							-- PROXIMITY PROMPT
							if not Player.Character:FindFirstChild("UpperTorso"):FindFirstChild("Revive Prompt") and game.Players.LocalPlayer.Character:FindFirstChild("Narthecium") then
								local Prompt =  Instance.new("ProximityPrompt")
								Prompt.Name = "Revive Prompt"
								Prompt.KeyboardKeyCode = Enum.KeyCode.R
								Prompt.Style = "Custom"
								Prompt.HoldDuration = 8
								Prompt.MaxActivationDistance = 10
								Prompt.RequiresLineOfSight = false
								Prompt.ActionText = "Revive"
								Prompt.ObjectText = Player.TeamTags_Info.TagNameTag.Value
								Prompt.Parent = Player.Character:FindFirstChild("UpperTorso")
								Prompt.Enabled = true
								--print(Prompt.Parent.Name)
								--print(Prompt.Enabled)

								Prompt.Triggered:Connect(function()
									if Player.Character:FindFirstChild("Revivable").Value > 0 then
										game.ReplicatedStorage:WaitForChild("Main"):WaitForChild("Remote Events"):WaitForChild("Revive"):FireServer(Player)
									end
								end)
							elseif not Player.Character:FindFirstChild("UpperTorso"):FindFirstChild("Revive Prompt") and game.Players.LocalPlayer.Character:FindFirstChild("Relic Narthecium") then
								local Prompt =  Instance.new("ProximityPrompt")
								Prompt.Name = "Revive Prompt"
								Prompt.KeyboardKeyCode = Enum.KeyCode.R
								Prompt.Style = "Custom"
								Prompt.HoldDuration = 4
								Prompt.MaxActivationDistance = 20
								Prompt.RequiresLineOfSight = false
								Prompt.ActionText = "Revive"
								Prompt.ObjectText = Player.TeamTags_Info.TagNameTag.Value
								Prompt.Parent = Player.Character:FindFirstChild("UpperTorso")
								Prompt.Enabled = true
								--print(Prompt.Parent.Name)
								--print(Prompt.Enabled)

								Prompt.Triggered:Connect(function()
									if Player.Character:FindFirstChild("Revivable").Value > 0 then
										game.ReplicatedStorage:WaitForChild("Main"):WaitForChild("Remote Events"):WaitForChild("Revive"):FireServer(Player)
									end
								end)
							elseif not game.Players.LocalPlayer.Character:FindFirstChild("Narthecium") and not game.Players.LocalPlayer.Character:FindFirstChild("Relic Narthecium") then
								if Player.Character:FindFirstChild("UpperTorso"):FindFirstChild("Revive Prompt") then
									Player.Character:FindFirstChild("UpperTorso"):FindFirstChild("Revive Prompt"):Destroy()
								end 
							end 
						end
					end
				end
			else
				for _,Player in pairs(game.Players:GetChildren()) do
					if Player.Character:FindFirstChild("Revivable") then
						if Player.Character:FindFirstChild("UpperTorso")then
							if Player.Character:FindFirstChild("UpperTorso"):FindFirstChild("Revive Prompt") then
								Player.Character:FindFirstChild("UpperTorso"):FindFirstChild("Revive Prompt"):Destroy()
							end 

							if Player.Character:FindFirstChild("UpperTorso"):FindFirstChild(script.ReviveCounterUi.Name) then
								Player.Character:FindFirstChild("UpperTorso"):FindFirstChild(script.ReviveCounterUi.Name):Destroy()
							end
						end
					end
				end
			end
		end
	end)
end)