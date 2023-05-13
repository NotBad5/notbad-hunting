ESX = nil

local currentZone = nil
local LimitOfSpawnedAnimals = 0

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()			 
	while true do
		local sleep = 500
		if Config.DevMode then
			sleep = 0
		end
		local playerPed = GetPlayerPed(-1)
		local playerCoords = GetEntityCoords(playerPed)

		for k,v in pairs(Config.HuntZones) do
			local dist = #(playerCoords - v.position)

			if Config.DevMode then
				DrawMarker(28, v.position.x, v.position.y, v.position.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 275.0, 275.0, 275.0, 255, 128, 0, 50, false, true, 2, nil, nil, false)
			end

			if currentZone == nil and dist < v.radius then
				currentZone = k
				TriggerServerEvent('NS_hunting:updateInZone', "S4F6SD56A644", k)
				ESX.ShowNotification(_U('inZone'))
			end
			
			if currentZone ~= nil then
				local dist = #(playerCoords - Config.HuntZones[currentZone].position)

				if dist > Config.HuntZones[currentZone].radius then			
					TriggerServerEvent('NS_hunting:updateOutOfTheZone', "S4F6SD56A644", currentZone)
					currentZone = nil
					ESX.ShowNotification(_U('outOfTheZone'))
				end
			end
		end
		Citizen.Wait(sleep)
	end
end)

local spawnedAnimals = {}

Citizen.CreateThread(function()
	while true do
		local sleep = 1000
		local playerPed = GetPlayerPed(-1)
		local playerCoords = GetEntityCoords(playerPed)
		local spawnPos

		if #spawnedAnimals < LimitOfSpawnedAnimals and currentZone ~= nil then
			sleep = 0

			local modelHash = GetHashKey(Config.HuntZones[currentZone].animalsToSpawn[math.random(#Config.HuntZones[currentZone].animalsToSpawn)])
			RequestModel(modelHash)
			while not HasModelLoaded(modelHash) do
				Wait(0)
			end

			spawnPos = Config.HuntZones[currentZone].position
			targetPosx = spawnPos.x + math.random(-250, 250)
			targetPosy = spawnPos.y + math.random(-250, 250)
			targetPosz = spawnPos.z
			spawnPos = vector3(targetPosx, targetPosy, targetPosz)
			local distance = #(playerCoords - spawnPos)

			while distance < 25.0 do
				spawnPos = Config.HuntZones[currentZone].position
				targetPosx = spawnPos.x + math.random(-250, 250)
				targetPosy = spawnPos.y + math.random(-250, 250)
				targetPosz = spawnPos.z
				spawnPos = vector3(targetPosx, targetPosy, targetPosz)
				distance = #(playerCoords - spawnPos)
				Wait(0)
			end

			local raycast, posZ = GetGroundZFor_3dCoord(spawnPos.x, spawnPos.y, 999.0, true)

			if raycast then
				local entity = CreatePed(4, modelHash, spawnPos.x, spawnPos.y, posZ, 0.0, true, true)

				local randomNumber = math.random(1, 3)
				
				if randomNumber == 1 then
					TaskCombatPed(entity, GetPlayerPed(-1), 0, 16)
				else
					TaskWanderStandard(entity, true, true)
					TaskStartScenarioInPlace(entity, "WORLD_DEER_GRAZING", 0, false)
				end

				table.insert(spawnedAnimals, entity)
			end
		end

		if currentZone == nil then
			for i = 1, #spawnedAnimals, 1 do
				local animalEntity = spawnedAnimals[i]
				if animalEntity ~= nil then
					SetEntityAsNoLongerNeeded(animalEntity)
					DeleteEntity(animalEntity)
					table.remove(spawnedAnimals, i)	
				end
			end
		end

		for i = 1, #spawnedAnimals, 1 do
			local animalEntity = spawnedAnimals[i]
			if animalEntity ~= nil and IsPedDeadOrDying(animalEntity, 1) then
			   SetEntityAsNoLongerNeeded(animalEntity)
			   table.remove(spawnedAnimals, i)
			end
		end

		for i = 1, #spawnedAnimals, 1 do
			local animalEntity = spawnedAnimals[i]
			local entityCoords = GetEntityCoords(animalEntity)
			if animalEntity ~= nil and entityCoords ~= nil and currentZone ~= nil then
				local distance = #(entityCoords - Config.HuntZones[currentZone].position)

				if distance > Config.HuntZones[currentZone].radius or IsEntityInWater(entity) then					
					SetEntityAsNoLongerNeeded(animalEntity)
					DeleteEntity(animalEntity)
					table.remove(spawnedAnimals, i)			
				end
			end
		end

		Citizen.Wait(sleep)
	end
end)

RegisterNetEvent('NS_hunting:zoneUpdate')
AddEventHandler('NS_hunting:zoneUpdate', function(amountOfPlayers)
	if currentZone == nil then return end
	LimitOfSpawnedAnimals = math.floor(Config.HuntZones[currentZone].maximumOfSpawnedAnimalsInZone / amountOfPlayers)
end)

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end
	
	for i = 1, #spawnedAnimals, 1 do
		local animalEntity = spawnedAnimals[i]
		if animalEntity ~= nil then
			SetEntityAsNoLongerNeeded(animalEntity)
			DeleteEntity(animalEntity)
			table.remove(spawnedAnimals, i)	
		end
	end
end)

function GetClosestPedNotBad()
    local closestPed = 0

	local pedsPool = GetGamePool("CPed")
	local playerCoords = GetEntityCoords(GetPlayerPed(-1))

	for i = 1, #pedsPool do
		local targetCoords = GetEntityCoords(pedsPool[i])
        local distanceCheck = #(playerCoords - targetCoords)

        if distanceCheck <= 1.5 and pedsPool[i] ~= GetPlayerPed(-1) then
            closestPed = pedsPool[i]
            break
        end
	end

    return closestPed
end

Citizen.CreateThread(function()
	while true do
		local sleep = 1000
		local playerPed = GetPlayerPed(-1)
		local playerCoords = GetEntityCoords(playerPed)
		
		if GetSelectedPedWeapon(playerPed) == GetHashKey(Config.ToolToProcessAnimals) and not IsPedInAnyVehicle(playerPed) then
			sleep = 100
			
			local animal = GetClosestPedNotBad()
			
			while animal == nil do
				animal = GetClosestPedNotBad()
				Citizen.Wait(500)
			end

			local animalPos = GetEntityCoords(animal)
			local distance = #(animalPos - playerCoords)

			if DoesEntityExist(animal) and IsPedDeadOrDying(animal) then
				sleep = 0
				local pedType = GetPedType(animal)
				if pedType == 28 and not IsPedAPlayer(animal) then
					for k, v in pairs(Config.AnimalModelsToProcess) do
						if GetEntityModel(animal) == GetHashKey(v)  then
							if distance <= 1.5 and animal ~= playerPed then
								DrawText3Ds(animalPos.x, animalPos.y, animalPos.z, _U('pressE'), 6)
								if IsControlJustPressed(1, 86) then
									LoadAnimDict('amb@medic@standing@kneel@base')
									LoadAnimDict('anim@gangops@facility@servers@bodysearch@')
									LoadAnimDict('anim@heists@prison_heiststation@')
									ClearPedTasksImmediately(PlayerPedId())

									Citizen.Wait(100)
									TaskPlayAnim(PlayerPedId(), "amb@medic@standing@kneel@base" ,"base" ,8.0, -8.0, -1, 1, 0, false, false, false )
									TaskPlayAnim(PlayerPedId(), "anim@gangops@facility@servers@bodysearch@" ,"player_search" ,8.0, -8.0, -1, 48, 0, false, false, false)

									Citizen.Wait(10000)

									TaskPlayAnim(PlayerPedId(), "anim@heists@prison_heiststation@" ,"pickup_bus_schedule" ,8.0, -8.0, -1, 48, 0, false, false, false)

									Citizen.Wait(6000)

									ClearPedTasksImmediately(PlayerPedId())
									
									TriggerServerEvent('NS_hunting:giveItems', "S4F6SD56A644", v)

									DeleteEntity(animal)
								end
							end
						end
					end
				end
			end
		end
		Citizen.Wait(sleep)
	end
end)

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())

    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 450
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 0, 0, 0, 80)
end

function LoadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(10)
    end
end

function LoadModel(model)
    while not HasModelLoaded(model) do
		RequestModel(model)
		Citizen.Wait(10)
    end
end
