export, ESX = pcall(function()
	return exports.es_extended:getSharedObject()
end)
if not export then
	while not ESX do
		TriggerEvent("esx:getSharedObject", function(obj)
			ESX = obj
		end)
		Wait(800)
	end
end

local Zones = {}

RegisterServerEvent('NS_hunting:updateInZone')
AddEventHandler('NS_hunting:updateInZone', function(arg, zone)
    if arg ~= "S4F6SD56A644" then return end
	local src = source

	if Zones[zone] == nil then
		Zones[zone] = {}
		Zones[zone].players = {}
	end

    if Zones[zone].players[src] == nil then
        table.insert(Zones[zone].players, src)

		for i = 1, #Zones[zone].players do
			if Zones[zone].players[i] ~= nil then
        		TriggerClientEvent('NS_hunting:zoneUpdate', Zones[zone].players[i], #Zones[zone].players)
			end
		end
	end
end)

RegisterServerEvent('NS_hunting:updateOutOfTheZone')
AddEventHandler('NS_hunting:updateOutOfTheZone', function(arg, zone)
    if arg ~= "S4F6SD56A644" then return end
	local src = source

	for k,v in pairs(Zones) do
		for i = 1, #Zones[k].players do
			if Zones[k].players[i] == src then
				table.remove(Zones[k].players, i)

				for i = 1, #Zones[k].players do
					if Zones[k].players[i] ~= nil then
						TriggerClientEvent('NS_hunting:zoneUpdate', Zones[k].players[i], #Zones[k].players)
					end
				end
			end
		end
	end
end)

AddEventHandler('playerDropped', function ()
	local src = source
	for k,v in pairs(Zones) do
		for i = 1, #Zones[k].players do
			if Zones[k].players[i] == src then
				table.remove(Zones[k].players, i)

				for i = 1, #Zones[k].players do
					if Zones[k].players[i] ~= nil then
						TriggerClientEvent('NS_hunting:zoneUpdate', Zones[k].players[i], #Zones[k].players)
					end
				end
			end
		end
	end
end)

if Config.DevMode then
	Citizen.CreateThread(function()
		while true do
			for k,v in pairs(Zones) do
				print(k)

				for i = 1, #Zones[k].players do
					print(Zones[k].players[i])
				end
			end
		
			Citizen.Wait(5000)
		end
	end)
end

RegisterServerEvent('NS_hunting:giveItems')
AddEventHandler('NS_hunting:giveItems', function(arg, animal)
    if arg ~= "S4F6SD56A644" then return end

    local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	for k,v in pairs(Config.AnimalsReward) do
		if k == animal then
			for k2,v2 in pairs(v) do
				xPlayer.addInventoryItem(k2, v2)
			end
		end
	end

    TriggerClientEvent('esx:showNotification', src, _U('animalProcessed'))
end)
