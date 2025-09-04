-- @ScriptType: LocalScript
-- made by warjad

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

local highlights = {}
local highlightingEnabled = false

local function findRootPart(model)
	local root = model:FindFirstChild("HumanoidRootPart")
	if root then return root end
	for _, part in pairs(model:GetChildren()) do
		if part:IsA("BasePart") and part.Name:match("RootPart") then
			return part
		end
	end
	return nil
end

local function hasLineOfSight(rootPart)
	local origin = Camera.CFrame.Position
	local direction = (rootPart.Position - origin)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.IgnoreWater = true

	local raycastResult = Workspace:Raycast(origin, direction, raycastParams)

	if raycastResult then
		if raycastResult.Instance and raycastResult.Instance:IsDescendantOf(rootPart.Parent) then
			return true
		else
			return false
		end
	else
		return true
	end
end

local function getRangeByRole()
	if not LocalPlayer.Character then return 450, 50 end
	local hasEliminator = false
	local hasReiverOrInfiltrator = false

	for _, descendant in ipairs(LocalPlayer.Character:GetDescendants()) do
		if descendant:IsA("Model") then
			local name = descendant.Name:lower()
			if name:find("eliminator") then
				hasEliminator = true
			elseif name:find("reiver") or name:find("infiltrator") then
				hasReiverOrInfiltrator = true
			end
		end
	end

	if hasEliminator then
		return 1000, 25
	elseif hasReiverOrInfiltrator then
		return 650, 105
	else
		return 450, 50
	end
end

local function toggleHighlights()
	local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.MaxHealth < 300 then
		warn("Highlighting requires at least 300 MaxHealth.")
		return
	end

	highlightingEnabled = not highlightingEnabled

	if not highlightingEnabled then
		for model, highlight in pairs(highlights) do
			highlight:Destroy()
		end
		highlights = {}
		-- print("Highlighting OFF")
		return
	end

	-- print("Highlighting ON")
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.J then
		toggleHighlights()
	end
end)

RunService.RenderStepped:Connect(function()
	if not highlightingEnabled then return end

	local longRangeDistance, closeRangeDistance = getRangeByRole()

	for _, model in pairs(Workspace:GetChildren()) do
		local rootPart = findRootPart(model)
		if rootPart then
			local humanoid = model:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				local isAlly = false
				local modelPlayer = Players:GetPlayerFromCharacter(model)
				if modelPlayer and modelPlayer.Team == LocalPlayer.Team then
					isAlly = true
				end

				local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
				local visible = hasLineOfSight(rootPart)

				if distance <= closeRangeDistance or (distance <= longRangeDistance and visible) then
					local color
					if not visible then
						color = Color3.fromRGB(255, 255, 100)
					else
						color = isAlly and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
					end

					if not highlights[model] then
						local highlight = Instance.new("Highlight")
						highlight.Adornee = model
						highlight.FillColor = color
						highlight.FillTransparency = 0.8
						highlight.OutlineColor = Color3.new(1, 1, 1)
						highlight.OutlineTransparency = 1
						highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						highlight.Parent = PlayerGui
						highlights[model] = highlight
					else
						highlights[model].FillColor = color
					end
				else
					if highlights[model] then
						highlights[model]:Destroy()
						highlights[model] = nil
					end
				end
			else
				if highlights[model] then
					highlights[model]:Destroy()
					highlights[model] = nil
				end
			end
		else
			if highlights[model] then
				highlights[model]:Destroy()
				highlights[model] = nil
			end
		end
	end

	for model, highlight in pairs(highlights) do
		if not model or not model.Parent then
			highlight:Destroy()
			highlights[model] = nil
		end
	end
end)
