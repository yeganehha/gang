Config = {}
--[[
--       =======================================================
--       ===================== IMPORTANT ! =====================
--       ===================== IMPORTANT ! =====================
--       ===================== IMPORTANT ! =====================
--       =======================================================
--       Add bellow line to server.cfg if this resource name is gang :
--       		add_ace resource.gang command.add_ace allow
--       
--       or if this resource name is NOT gang change [RESOURCENAME] to name of this resource and then add to server.cfg
--       		add_ace resource.[RESOURCENAME] command.add_ace allow
--
--
--
--       For Check is Vehicle For Player's Gang use:
--			   exports['gang']:isOwnGangVehicle([vehicle])
--       or if this resource name is NOT gang change {RESOURCENAME} to name of this resource
--			   exports[{RESOURCENAME}]:isOwnGangVehicle([vehicle])
--
--
--       Other exports maybe use :
--			   exports['gang']:getGangID()
--			   exports['gang']:getGangGrade()
--			   exports['gang']:getGangName()
--			   exports['gang']:getGangGradeName()
--]]


Config.Locale = 'en'

Config.adminCommand = 'gangs' -- command that open gang data for admin
Config.adminGroup   = 'gangManager' -- ace group to access admin command



Config.gangAreaBlipsColor = 9  -- color of blips that show on map which area of gang area ( https://docs.fivem.net/docs/game-references/blips/ )
Config.garageGangBlips = 524  -- type of blips that show on map for impound vehicle ( https://docs.fivem.net/docs/game-references/blips/ )
Config.garageGangBlipsColor = 47  -- color of blips that show on map for impound vehicle ( https://docs.fivem.net/docs/game-references/blips/ )
Config.playerGangBlips = 310  -- type of blips that show on map for member of gang ( https://docs.fivem.net/docs/game-references/blips/ )
Config.playerGangBlipsColor = 1  -- color of blips that show on map for member of gang ( https://docs.fivem.net/docs/game-references/blips/ )



Config.MarkerType = {
	boss = 31 , -- type of Marker that show to member of gang for boss action( https://docs.fivem.net/docs/game-references/markers/ )
	locker = 20 , -- type of Marker that show to member of gang for change cloths( https://docs.fivem.net/docs/game-references/markers/ )
	armory = 21 , -- type of Marker that show to member of gang for armory and inventory ( https://docs.fivem.net/docs/game-references/markers/ )
	vehicle = 36 , -- type of Marker that show to member of gang for vehicle spawner ( https://docs.fivem.net/docs/game-references/markers/ )
	helicopter = 34 , -- type of Marker that show to member of gang for helicopter spawner ( https://docs.fivem.net/docs/game-references/markers/ )
	boat = 35 , -- type of Marker that show to member of gang for boat spawner ( https://docs.fivem.net/docs/game-references/markers/ )
	vehicleConvertor = 24 , -- type of Marker that show to member of gang for change own vehicle to gang vehicle ( https://docs.fivem.net/docs/game-references/markers/ )
}
Config.MarkerColor = {r = 50, g = 50, b = 204} -- color of marker
Config.MarkerSize = {x = 1.5, y = 1.5, z = 1.5} -- size of marker
Config.DrawDistance = 10 -- Distance of player and Marker to draw Marker for player



Config.Bulletproof = { typeNumber = 10, colorNumber = 1 } -- color and type of Bulletproof


Config.OpenActionMenu = 166 -- Button on keyboard that press, the gang action menu opend ( https://docs.fivem.net/docs/game-references/controls/ )
Config.MaxGangActionDistance = 3 -- max distance beatween Gang Memeber and player(vehicle) for drag , cuff , search and ....
Config.handCuffAnimation = false -- hand cuff/uncuff show with animation


Config.vehicleConvertor = { -- coords of place that is for impound and add vehicle to gang
	{ x = 55.27 , y = 3714.27 , z = 39.75 , typeVehicle = {'car','helicopter'} },
	{ x = 147.4 , y = 3820.09 , z = 30.33 , typeVehicle = 'boat' },
}

Config.impoundPrice = 5000 -- price for re spawn vehicle
Config.impoundReSpawnTime = 10 * 60 -- how meny time lenght too player can get vehicle from impound ( second )
Config.fixSpawnVehicle = false -- fix vehicle when spawn from garage
Config.PlateUseSpace = false -- use space in vehicle plate 
Config.PlateLetters = 3 -- how meny letters use in vehicle plate
Config.PlateNumbers = 3 -- how meny numbers use in vehicle plate
Config.ParkVehicles = false -- true = Automatically Park all Vehicles in Garage on Server/Script Restart | false = Opposite of true but players will have to go to Pound to get their Vehicle Back.

Config.PaySalaryInterval = 10 -- how meny time lenght too pay salary

Config.activeDiscordHook = true  -- send log of gang armory action to discord
Config.discordHookStartWith = '**Server Name**' -- Start Discord Log with 
Config.discordHookSignature = 'Have good time in Server Name' -- Signature of discord log