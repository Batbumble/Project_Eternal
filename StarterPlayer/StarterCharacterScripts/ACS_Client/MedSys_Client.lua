-- @ScriptType: Script
local Char = script.Parent.Parent

local human = Char.Humanoid
local PastaVar = script.Parent.Variaveis
local PastasStan = script.Parent.Stances
local ultimavida = human.MaxHealth
local Sangrando = PastasStan.Sangrando
local Sang = PastaVar.Sangue
local UltimoSang = Sang.MaxValue
local Dor = PastaVar.Dor
local Doer = PastaVar.Doer
local MLs = PastaVar.MLs
local bbleeding = PastasStan.bbleeding
--local Energia = PastaVar.Energia
local Ferido = PastasStan.Ferido
local Caido = PastasStan.Caido
local ouch = Caido
local rodeath = PastasStan.rodeath
local cpr = PastasStan.cpr
local balloonbleed = PastasStan.balloonbleed
local clamped = PastasStan.clamped
local repaired = PastasStan.repaired
local o2 = PastasStan.o2
local dead = PastasStan.dead
local life = PastasStan.life
local surg2 = PastasStan.surg2
local cutopen = PastasStan.cutopen



local Ragdoll = require(game.ReplicatedStorage.ACS_Engine.Modules.Ragdoll)
local configuracao = require(game.ReplicatedStorage.ACS_Engine.GameRules.Config)

local debounce = false
life.Value = true
cutopen.Value = false
clamped.Value = false
--script.Parent.Parent.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)


--Char.Humanoid.BreakJointsOnDeath = false

if configuracao.EnableRagdoll == true then
	if human.Health <= 1 then
		Ragdoll(Char)
	end
end


human.HealthChanged:Connect(function (newhealth)
	if dead.Value == false and Sang.Value >= 10 then


		human.Health = math.clamp(newhealth, 0.1, human.MaxHealth)

		if newhealth <= 0.1 or human.Health <= 0.1 then
			Caido.Value = true
		end

		if (rodeath.Value == true or life.Value == false) and newhealth <= -25 then
			local loss = newhealth * 40
			Sang.Value = Sang.Value + loss
			human.PlatformStand = true
			human.AutoRotate = false	

		end



	else
		human.PlatformStand = false
		human.AutoRotate = true

		human.Health = 0

	end
end)


--[[
game.Workspace.Player.Humanoid.Running:Connect(function(speed)
    if speed > 1 and Sangrando.Value == true then
		 Sang.Value = (Sang.Value - (MLs.Value/30))	
	end
		
	if speed > 1 and bbleeding.Value == true then
		 Sang.Value = (Sang.Value - (MLs.Value/30))	
	end
	
	end)

]]--



while configuracao.EnableMedSys do
	wait()

	if Sangrando.Value == true then
		if PastasStan.Tourniquet.Value == false then
			Sang.Value = (Sang.Value - (MLs.Value/60))
			MLs.Value = MLs.Value + 0.025
			if PastasStan.skit.Value == true then
				Sang.Value = Sang.Value - (MLs.Value/500)


			end	
			UltimoSang = Sang.Value
		end
	end

	if bbleeding.Value == true then
		if PastasStan.Tourniquet.Value == false then
			Sang.Value = (Sang.Value - (MLs.Value/100))

		elseif PastasStan.Tourniquet.Value == true then
			Sang.Value = (Sang.Value - (MLs.Value/220))

		end
		MLs.Value = MLs.Value + 0.025
		if PastasStan.skit.Value == true then
			Sang.Value = Sang.Value - (MLs.Value/500)


		end	
		UltimoSang = Sang.Value

	end

	if balloonbleed.Value == true then
		Sang.Value = (Sang.Value - (MLs.Value/10000))

		MLs.Value = MLs.Value + 0.025
		if PastasStan.skit.Value == true then
			Sang.Value = Sang.Value - (MLs.Value/300)


		end	
		UltimoSang = Sang.Value

	end

	if surg2.Value == true then
		Sang.Value = (Sang.Value - (MLs.Value/110))

		MLs.Value = MLs.Value + 0.025
		if PastasStan.skit.Value == true then
			Sang.Value = Sang.Value - (MLs.Value/300)


		end	
		UltimoSang = Sang.Value

	end

	if clamped.Value == true then
		Sang.Value = (Sang.Value - (MLs.Value/1000))

		MLs.Value = MLs.Value + 0.025




		UltimoSang = Sang.Value

	end

	if cutopen.Value == true then

		Sang.Value = (Sang.Value - (MLs.Value/600))

		MLs.Value = MLs.Value + 0.025

		UltimoSang = Sang.Value

	end



	--hey mop removed o2 if you see this hah--




	if PastasStan.Tourniquet.Value == true then
		Dor.Value = Dor.Value + 0.1
	end



	if (human.Health - ultimavida < 0) then
		Dor.Value = math.ceil(Dor.Value + (human.Health - ultimavida)*(-configuracao.PainMult))
		--Energia.Value = math.ceil(Energia.Value + (human.Health - ultimavida)*(5))
	end	


	if (human.Health - ultimavida < 0) --[[and (Sangrando.Value == true)]] then
		MLs.Value = MLs.Value + ((ultimavida - human.Health)* (configuracao.BloodMult))
	end

	if script.Parent.Parent.Humanoid.Health < ultimavida - (configuracao.BleedDamage) then
		Sangrando.Value = true

		if script.Parent.Parent.Humanoid.Health < ultimavida - (configuracao.InjuredDamage) then
			Ferido.Value = true
			bbleeding.Value = true
			Sangrando.Value = true
			if script.Parent.Parent.Humanoid.Health < ultimavida -(configuracao.KODamage) then
				Caido.Value = true
				local bruh = math.random(1,2)
				if bruh == 2 then
					surg2.Value = true
				else
					surg2.Value = false
				end
				Sangrando.Value = true
				bbleeding.Value = true

			end	
		end
	end

	if script.Parent.Parent.Humanoid.Health <= 2 then
		rodeath.Value = true
		human.PlatformStand = true
		human.AutoRotate = false
		Caido.Value = true	
		--cpr.Value = false
		life.Value = false
		--Sangrando.Value = true
		bbleeding.Value = true
	end










	if human.Health >= human.MaxHealth and Sangrando.Value == false then
		Sang.Value = Sang.Value + 0.5	
		Dor.Value = Dor.Value - 0.025
		MLs.Value = MLs.Value - 0.025		

	end

	task.wait()

	ultimavida = script.Parent.Parent.Humanoid.Health


	spawn(function(timer)
		if Sang.Value >= 3500 and Dor.Value < 200 and Caido.Value == true and debounce == false then
			debounce = true
			wait(60)
			debounce = false
		end	
	end)

	local currhealth = 100



	if life.Value == false or Caido.Value == true then

		human.PlatformStand = true
		human.AutoRotate = false	
		Caido.Value = true	

		local bruh = math.clamp(MLs.Value/8000, 0.1, 0.14)
		if o2.Value == true then
			bruh = 0.005
			MLs.Value = 0
		end
		human.Health = human.Health - bruh
		if PastasStan.Tourniquet.Value == false then
			Sang.Value = (Sang.Value - (MLs.Value/90))
			MLs.Value = MLs.Value + 0.025
		else
			Sang.Value = (Sang.Value - (MLs.Value/210))
			MLs.Value = MLs.Value + 0.025
		end
	end






end




-- Quero um pouco de credito,plox :P --
--  FEITO 100% POR SCORPION --
-- Oficial Release 1.5 --
