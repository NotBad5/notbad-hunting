Config = {}

Config.DevMode = false

Config.Locale = 'en'

Config.ToolToProcessAnimals = 'WEAPON_KNIFE'

Config.HuntZones = { 
	mount_gordo = {
		position = vector3(2457.0774, 6333.5449, 87.3123),
		animalsToSpawn = {'a_c_deer', 'a_c_boar', 'a_c_mtlion'},
		maximumOfSpawnedAnimalsInZone = 20,
		radius = 280.0
	},
	chiliad_mountain_state_wilderness = {
		position = vector3(-1431.7155, 4640.4985, 65.2060),
		animalsToSpawn = {'a_c_deer', 'a_c_boar'},
		maximumOfSpawnedAnimalsInZone = 20,
		radius = 280.0
	},
}

Config.AnimalsReward = {
	a_c_deer = {
		meat = 2,
		leather = 3,
	},
	a_c_boar = {
		meat = 6,
		leather = 2,
	},
	a_c_mtlion = {
		meat = 4,
		leather = 2,
	},
}

Config.AnimalAttackChance = {
	a_c_deer = {
		chance = 50, -- 50% chance that this animal will attack you
	},
	a_c_boar = {
		chance = 50, -- 50% chance that this animal will attack you
	},
	a_c_mtlion = {
		chance = 80, -- 80% chance that this animal will attack you
	},
}

Config.AnimalModelsToProcess = {'a_c_deer', 'a_c_boar', 'a_c_mtlion'}
