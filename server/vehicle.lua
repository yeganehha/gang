local vehicleImpoundSpawn = {}

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		if Config.ParkVehicles then
			executeOnDB('UPDATE `gangs_vehicle` SET  `stored` = true WHERE `stored` = @stored', {
				['@stored'] = false
			}, function(rowsChanged)
				if rowsChanged > 0 then
					print(('gang: %s vehicle(s) have been stored!'):format(rowsChanged))
				end
			end)
		end
	end
end)

RegisterServerEvent('Erfan:gang:openImpoundMenu')
AddEventHandler('Erfan:gang:openImpoundMenu', function(typeVehicle,vehicleProperties)
	local _Source = source
	local identifier = getPlayerIdentifier(_Source)
	local gang = selectFromDB("SELECT gm.playerIdentifiers , gg.accessVehicle , gm.gangId FROM gangs_member gm Left Join gangs_grade gg on (gg.gangId = gm.gangId and gg.grade = gm.grade ) WHERE gm.playerIdentifiers = @playerIdentifiers", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier and gang[1].accessVehicle then
		local canInsertToGarage = false
		if vehicleProperties ~= nil then
			canInsertToGarage = isOwnedvehicle(_Source , vehicleProperties)
		end
		local queryElement = { ['@gangId']  = gang[1].gangId } 
		local query = ''
		if type(typeVehicle) == 'table' then
			query = query .. ' and ( 0 '
			for k,v in ipairs(typeVehicle) do
				query = query .. ' or `type` = @vehType'..k
				queryElement['@vehType'..k]  = v
			end
			query = query .. ' )  '
		else
			query = query .. ' and `type` = @vehType'
			queryElement['@vehType' ]  = typeVehicle 
		end
		local Vehicles = selectFromDB("SELECT * FROM `gangs_vehicle` WHERE `stored` = 0 and `gangId` =  @gangId" .. query .. ' ORDER BY `type` DESC ' , queryElement)
		TriggerClientEvent('Erfan:gang:openImpoundMenu', _Source , Vehicles ,canInsertToGarage ,  vehicleProperties )
	else
		TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
	end
end)




function GetRandomNumber(length)
	Wait(0)
	math.randomseed(os.time())
	if length > 0 then
		local NumberCharset = {'0','1','2','3','4','5','6','7','8','9'}
		return GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
	else
		return ''
	end
end
function GetRandomLetter(length)
	Wait(0)
	math.randomseed(os.time())
	if length > 0 then
		local Charset = {'a','b','c','d','e','f','g','h','j','k','l','m','n','o','p','q','r','s','t','v','w','x','y','z','i','u'}
		return GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
	else
		return ''
	end
end

RegisterServerEvent('Erfan:gang:addVehicle')
AddEventHandler('Erfan:gang:addVehicle', function(vehicleProperties )
	local _Source = source
	local identifier = getPlayerIdentifier(_Source)
	local gang = selectFromDB("SELECT gm.playerIdentifiers , gg.accessVehicle , gm.gangId FROM gangs_member gm Left Join gangs_grade gg on (gg.gangId = gm.gangId and gg.grade = gm.grade ) WHERE gm.playerIdentifiers = @playerIdentifiers", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier and gang[1].accessVehicle then
		local isReapeted = true
		local lastVehicleProperties = vehicleProperties
		while isReapeted do
			local plate = selectFromDB("SELECT plate FROM gangs_vehicle WHERE plate = @plate", { ['@plate']  = vehicleProperties.plate })
			if plate ~= nil and plate[1] ~= nil and plate[1].plate == vehicleProperties.plate then
				Wait(2)
				math.randomseed(GetGameTimer())
				if Config.PlateUseSpace then
					vehicleProperties.plate = string.upper(GetRandomLetter(Config.PlateLetters) .. ' ' .. GetRandomNumber(Config.PlateNumbers))
				else
					vehicleProperties.plate = string.upper(GetRandomLetter(Config.PlateLetters) .. GetRandomNumber(Config.PlateNumbers))
				end
			else
				isReapeted = false
			end
		end
		executeOnDB('INSERT INTO `gangs_vehicle`(`gangId`, `plate`, `vehicle`, `type`, `stored`) VALUES (@gangId,@plate,@vehicle,@type,false)', {
			['@gangId'] 	 = gang[1].gangId,
			['@vehicle'] 	 = json.encode(vehicleProperties) , 
			['@plate'] 	 = vehicleProperties.plate , 
			['@type'] 	 = vehicleProperties.typeVehicle  
		} , function(e)
			deleteOwnedvehicle(_Source,lastVehicleProperties)
			TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('vehicle_add') , 'CHAR_SOCIAL_CLUB' , 2 )
			vehicleImpoundSpawn[vehicleProperties.plate] = os.time()
		end)
	else
		TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
	end
end)



RegisterServerEvent('Erfan:gang:setVehicleStatus')
AddEventHandler('Erfan:gang:setVehicleStatus', function(plate , status )
	executeOnDB('UPDATE `gangs_vehicle` SET  `stored` = @status WHERE `plate` = @plate', {['@plate'] 	 = plate , ['@status'] 	 = status } , function(e)end)
	if not status then
		vehicleImpoundSpawn[plate] = os.time()
	end
end)


RegisterServerEvent('Erfan:gang:setVehicleProperties')
AddEventHandler('Erfan:gang:setVehicleProperties', function(plate , vehicleProperties )
	executeOnDB('UPDATE `gangs_vehicle` SET  `vehicle` = @vehicle WHERE `plate` = @plate', {['@plate'] 	 = plate , ['@vehicle'] =  json.encode(vehicleProperties) } , function(e)end)
end)


RegisterServerEvent('Erfan:gang:payImpound')
AddEventHandler('Erfan:gang:payImpound', function(Vehicle ,Vehicles ,canInsertToGarage ,  vehicleProperties )
	local _Source = source
	if vehicleImpoundSpawn[Vehicle.plate] == nil or ( vehicleImpoundSpawn[Vehicle.plate] ~= nil and os.time() - vehicleImpoundSpawn[Vehicle.plate] > Config.impoundReSpawnTime ) then 
		if setPlayerMoney(_Source, Config.impoundPrice , 'remove') then
			TriggerClientEvent('Erfan:gang:spawnVehicle',_Source,Vehicle )
			vehicleImpoundSpawn[Vehicle.plate] = os.time()
			TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('pay_impound_price' , Config.impoundPrice ) , 'CHAR_SOCIAL_CLUB' , 2 )
		else
			TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('dont_have_enough_money') , 'CHAR_SOCIAL_CLUB' , 2 )
			Wait(50)
			TriggerClientEvent('Erfan:gang:openImpoundMenu', _Source , Vehicles ,canInsertToGarage ,  vehicleProperties )
		end
	else
		TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('cant_spawn_impound') , 'CHAR_SOCIAL_CLUB' , 2 )
		Wait(50)
		TriggerClientEvent('Erfan:gang:openImpoundMenu', _Source , Vehicles ,canInsertToGarage ,  vehicleProperties )
	end
end)



RegisterServerEvent('Erfan:gang:openGarage')
AddEventHandler('Erfan:gang:openGarage', function(typeVehicle , vehicleProperties)
	local _Source = source
	local identifier = getPlayerIdentifier(_Source)
	local gang = selectFromDB("SELECT gm.playerIdentifiers , gg.accessVehicle , gm.gangId FROM gangs_member gm Left Join gangs_grade gg on (gg.gangId = gm.gangId and gg.grade = gm.grade ) WHERE gm.playerIdentifiers = @playerIdentifiers", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier and gang[1].accessVehicle then
		local canInsertToGarage = false
		if vehicleProperties ~= nil then
			local plate = selectFromDB("SELECT plate FROM gangs_vehicle WHERE plate = @plate", { ['@plate']  = vehicleProperties.plate })
			if plate ~= nil and plate[1] ~= nil and plate[1].plate == vehicleProperties.plate then
				canInsertToGarage = true
			end
		end
		
		local Vehicles = selectFromDB("SELECT * FROM `gangs_vehicle` WHERE `gangId` =  @gangId and `type` = @vehType ORDER BY `stored` DESC " , { ['@gangId']  = gang[1].gangId , ['@vehType' ]  = typeVehicle  } )
		TriggerClientEvent('Erfan:gang:openGarageMenu', _Source , Vehicles ,canInsertToGarage ,  vehicleProperties )
	else
		TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
	end
end)


RegisterServerEvent('Erfan:gang:isOwnVehicle')
AddEventHandler('Erfan:gang:isOwnVehicle', function(plate,cb)
	local _Source = source
	local identifier = getPlayerIdentifier(_Source)
	local gang = selectFromDB("SELECT gm.playerIdentifiers , gm.gangId, gv.plate FROM gangs_member gm Left Join gangs_vehicle gv on (gv.gangId = gm.gangId ) WHERE gm.playerIdentifiers = @playerIdentifiers and  gv.plate = @plate ", { ['@playerIdentifiers']  = identifier , ['@plate']  = plate })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier and gang[1].plate == plate then
		TriggerClientEvent('Erfan:gang:isOwnGangVehicle', _Source , true )
	else
		TriggerClientEvent('Erfan:gang:isOwnGangVehicle', _Source , false )
	end
end)