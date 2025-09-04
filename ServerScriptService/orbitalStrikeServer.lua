-- @ScriptType: Script
--written by BelugaAnaro
--12/19/17 20:09

--ORBITAL STRIKE CONFIGURATION--
local range = 40 -- max distance (in studs) that the shots can be from the player mouse's X and Z positions
local amt = 30 -- amount of shots to send
local timeToWaitAfterEvent = 1 -- time that passes between the player's mouse click and the orbital strike occuring (not accounting for server lag)
local timeToWaitInBetweenShots = .5 -- time that passes between each shot being fired

local MIN_DAMAGE = 20
local MAX_DAMAGE = 50

----------dont touch anything below this line----------
local rs = game:GetService('ReplicatedStorage')
local ts = game:GetService('TweenService')
local debris = game:GetService('Debris')

local orbitalStrike = rs:WaitForChild('orbitalStrike')

local shot = script:WaitForChild('a')
local goal = script:WaitForChild('Goal')


orbitalStrike.OnServerEvent:Connect(function(plr,coords,buff,cost)
	if game:GetService('ReplicatedStorage'):WaitForChild('ENPGS — Storage').Command.Resources.Value < cost then
		return
	end
	game:GetService('ReplicatedStorage'):WaitForChild('ENPGS — Storage').Command.Resources.Value -= cost
	task.wait(timeToWaitAfterEvent)
	local b = shot:Clone()
	local g = goal:Clone()
	
	g.Parent = workspace
	g.Position = coords.p
	
	local preNewCoords = coords.p+Vector3.new(math.random(-range,range),1000,math.random(-range,range))
	local _,newCoords = workspace:FindPartOnRay(Ray.new(preNewCoords,((preNewCoords-Vector3.new(0,1000,0))-preNewCoords).unit*2000))
	b.Parent = workspace
	b.Position = preNewCoords
	b.Bomb_Fall.Volume = 7.5
	if buff == "Astartes" then
		b.Bomb_Fall.PitchShiftSoundEffect.Octave = 0.8
	elseif buff == "Barrage" then
		b.Bomb_Fall.PitchShiftSoundEffect.Octave = 1.2
	elseif buff == "Laser" or buff == "Volcano" then
		g.Energy.Enabled = true
		b.Bomb_Fall.Volume = 0
		b.Orbital_Laser:Play()
	else
		g.Energy.Enabled = false
		g.DustUp.Enabled = false
	end
	b.Bomb_Fall:Play()
	b.Transparency = 1
	b.ParticleEmitter.Enabled = false
	wait(4)
	local tween2 = ts:Create(b,TweenInfo.new(.6,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0),{Position = newCoords})
	tween2:Play()
	local tamt = amt
	local tw = timeToWaitInBetweenShots
	if buff == "Astartes" then
		tamt = 4
		tw = 1
	elseif buff == "Barrage" then
		tamt = 500
		tw = 0.01
	elseif buff == "Laser" then
		tamt = 1
		tw = 0.01
		g.Energy.Enabled = false
		g.DustUp.Enabled = false
	elseif buff == "Volcano" then
		tamt = 7
		tw = 1
		g.Energy.Enabled = false
		g.DustUp.Enabled = false
	end
	for i = 1,tamt do
		wait(tw)
		local a = shot:Clone()
		if buff == "Astartes" then
			a.Bomb_Fall.PitchShiftSoundEffect.Octave = 0.8
			a.Echo.PitchShiftSoundEffect.Octave = 0.9
			a.Sound.PitchShiftSoundEffect.Octave = 0.8
			a.Sound.Volume = 4
			a.Echo.Volume = 4
		elseif buff == "Barrage" then
			a.Bomb_Fall.PitchShiftSoundEffect.Octave = 1.2
			a.Echo.PitchShiftSoundEffect.Octave = 1.1
			a.Sound.PitchShiftSoundEffect.Octave = 1.2
			a.Sound.Volume = 1
			a.Echo.Volume = 1
		end
		a.CollisionGroup = "Pod"
		local preNewCoords = coords.p+Vector3.new(math.random(-range,range),1000,math.random(-range,range))
		if buff == "Astartes" then
			preNewCoords = coords.p+Vector3.new(math.random(-range/10,range/10),1000,math.random(-range/10,range/10))
		elseif buff == "Barrage" then
			preNewCoords = coords.p+Vector3.new(math.random(-range*5,range*5),1000,math.random(-range*5,range*5))
		elseif buff == "Laser" or buff == "Volcano" then
			preNewCoords = coords.p+Vector3.new(0,1000,0)
			--a.Size = Vector3.new(2.2, 93, 2.2)
			a.Transparency = 1
			a.ParticleEmitter.Enabled = false
			g.Laser.Enabled = true
			g.Explosion.Enabled = true
			g.Shockwave.Enabled = true
			if buff == "Volcano" then
				g.Laser.Width0 = 50
				g.Laser.Width1 = 100
			end
		end
		local _,newCoords = workspace:FindPartOnRay(Ray.new(preNewCoords,((preNewCoords-Vector3.new(0,1000,0))-preNewCoords).unit*4000))
		a.Position = preNewCoords
		a.ParticleEmitter:Emit(a:GetMass())
		a.Parent = workspace:FindFirstChild('rayStorage') or workspace
		local tween = ts:Create(a,TweenInfo.new(.6,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0),{Position = newCoords})
		tween:Play()
		
		delay(.55,function() if a:FindFirstChild('Sound') then a.Sound:Play() end end)
		if buff == "Laser" or buff == "Volcano" then
			local tweenD = ts:Create(g.A,TweenInfo.new(.9,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0),{Position = Vector3.new(math.random(-5,5),0,math.random(-5,5))})
			tweenD:Play()
		else

		
		--if buff == "Laser" or buff == "Volcano" then
			--delay(.55,function() if a:FindFirstChild('Echo') then a.Shock:Play() end end)
			
		--else
			delay(.55,function() if a:FindFirstChild('Echo') then a.Echo:Play() end end)
		end
		debris:AddItem(a,.8)
		
		tween.Completed:Connect(function()
			local e = Instance.new('Explosion')
			e.ExplosionType = Enum.ExplosionType.NoCraters
			e.BlastPressure = 5
			e.BlastRadius = 10
			if buff == "Astartes" then
				e.BlastRadius = 50
			elseif buff == "Laser" then
				g.Laser.Enabled = false
				e.BlastRadius = 165
				e.Visible = false
			elseif buff == "Volcano" then
				e.BlastRadius = 100
				e.Visible = false
			end
			e.DestroyJointRadiusPercent = 0
			e.Position = newCoords
			e.Parent = workspace
			
			e.Hit:Connect(function(hit, distance)
				--print(hit)
				local hum = hit.Parent:FindFirstChildOfClass("Humanoid")
				if hum then
					local dam = (1 - distance / e.BlastRadius) * (MAX_DAMAGE - MIN_DAMAGE) + MIN_DAMAGE
					if buff == "Astartes" then
						dam = (1 - distance / e.BlastRadius) * (MAX_DAMAGE*100 - MIN_DAMAGE*100) + MIN_DAMAGE*100
					elseif buff == "Barrage" then
						dam = (1 - distance / e.BlastRadius) * (MAX_DAMAGE/3 - MIN_DAMAGE/2) + MIN_DAMAGE/2
					end
					dam = math.min(dam,5000)
					if buff == "Volcano" then
						dam = 400000
					end
					hum:TakeDamage(dam)
				end
				local hum = hit.Parent.Parent:FindFirstChildOfClass("Humanoid")
				if hum then
					local dam = (1 - distance / e.BlastRadius) * (MAX_DAMAGE - MIN_DAMAGE) + MIN_DAMAGE
					if buff == "Astartes" then
						dam = (1 - distance / e.BlastRadius) * (MAX_DAMAGE*100 - MIN_DAMAGE*100) + MIN_DAMAGE*100
					elseif buff == "Barrage" then
						dam = (1 - distance / e.BlastRadius) * (MAX_DAMAGE/3 - MIN_DAMAGE/2) + MIN_DAMAGE/2
					end
					dam = math.min(dam,5000)
					if buff == "Volcano" then
						dam = 400000
					end
					hum:TakeDamage(dam)
				end
			end)

		end)
		
	end
	b:Destroy()
	if buff == "Laser" then
		g.Energy.Enabled = false
		g.DustUp.Enabled = false
		task.wait(0.8)
		g.Explosion.Enabled = false
		g.Shockwave.Enabled = false
		task.wait(2)
	elseif buff == "Volcano" then
		g.Energy.Enabled = false
		g.DustUp.Enabled = false
		task.wait(2)
		g.Explosion.Enabled = false
		g.Shockwave.Enabled = false
		task.wait(1)
	end
	g:Destroy()
end)
