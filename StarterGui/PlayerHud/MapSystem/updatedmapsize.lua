-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local playerHud = playerGui:WaitForChild("PlayerHud")
local mapSystem = playerHud:WaitForChild("MapSystem")
local map = mapSystem:WaitForChild("Map")

-- Map GUI setup
map.AnchorPoint = Vector2.new(0, 0.5)
map.Position = UDim2.new(0.01, 0, 0.5, 0)
map.Size = UDim2.new(0.3, 0, 0.6, 0)
map.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
map.Visible = true
