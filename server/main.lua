
RegisterNetEvent('Erfan:gang:handcuff')
AddEventHandler('Erfan:gang:handcuff', function(target)
	local _Source = source
	for k,v in ipairs(GetPlayerIdentifiers(_Source)) do
		if string.match(v, Config.IdentifiersPlayerWith ) then
			identifier = v
			break
		end
	end
	local gang = selectFromDB("SELECT gm.playerIdentifiers , g.canCuff FROM gangs_member gm Left Join gangs g on (g.id = gm.gangId ) WHERE gm.playerIdentifiers = @playerIdentifiers and  g.expireTime > NOW()", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier and gang[1].canCuff then
		TriggerClientEvent('Erfan:gang:handcuff', target)
	else
		print(('^1[GNAG SYSTEM]: %s or ID: %s attempted to handcuff a player (not Gang)!'):format(identifier,_Source))
	end
end)

RegisterNetEvent('Erfan:gang:drag')
AddEventHandler('Erfan:gang:drag', function(target)
	local _Source = source
	for k,v in ipairs(GetPlayerIdentifiers(_Source)) do
		if string.match(v, Config.IdentifiersPlayerWith ) then
			identifier = v
			break
		end
	end
	local gang = selectFromDB("SELECT gm.playerIdentifiers , g.canMove FROM gangs_member gm Left Join gangs g on (g.id = gm.gangId ) WHERE gm.playerIdentifiers = @playerIdentifiers and  g.expireTime > NOW()", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier and gang[1].canMove then
		TriggerClientEvent('Erfan:gang:drag', target , _Source)
	else
		print(('^1[GNAG SYSTEM]: %s or ID: %s attempted to drag a player (not Gang)!'):format(identifier,_Source))
	end
end)

RegisterNetEvent('Erfan:gang:putInVehicle')
AddEventHandler('Erfan:gang:putInVehicle', function(target)
	local _Source = source
	for k,v in ipairs(GetPlayerIdentifiers(_Source)) do
		if string.match(v, Config.IdentifiersPlayerWith ) then
			identifier = v
			break
		end
	end
	local gang = selectFromDB("SELECT gm.playerIdentifiers , g.canMove FROM gangs_member gm Left Join gangs g on (g.id = gm.gangId ) WHERE gm.playerIdentifiers = @playerIdentifiers and  g.expireTime > NOW()", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier and gang[1].canMove then
		TriggerClientEvent('Erfan:gang:putInVehicle', target)
	else
		print(('^1[GNAG SYSTEM]: %s or ID: %s attempted to put a player in vehicle (not Gang)!'):format(identifier,_Source))
	end
end)

RegisterNetEvent('Erfan:gang:OutVehicle')
AddEventHandler('Erfan:gang:OutVehicle', function(target)
	local _Source = source
	for k,v in ipairs(GetPlayerIdentifiers(_Source)) do
		if string.match(v, Config.IdentifiersPlayerWith ) then
			identifier = v
			break
		end
	end
	local gang = selectFromDB("SELECT gm.playerIdentifiers , g.canMove FROM gangs_member gm Left Join gangs g on (g.id = gm.gangId ) WHERE gm.playerIdentifiers = @playerIdentifiers and  g.expireTime > NOW()", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier and gang[1].canMove then
		TriggerClientEvent('Erfan:gang:OutVehicle',target)
	else
		print(('^1[GNAG SYSTEM]: %s or ID: %s attempted to put a player in vehicle (not Gang)!'):format(identifier,_Source))
	end
end)





RegisterServerEvent('Erfan:gang:searchBody')
AddEventHandler('Erfan:gang:searchBody', function(target)
	local _Source = source
	for k,v in ipairs(GetPlayerIdentifiers(_Source)) do
		if string.match(v, Config.IdentifiersPlayerWith ) then
			identifier = v
			break
		end
	end
	local gang = selectFromDB("SELECT gm.playerIdentifiers , g.canSearch FROM gangs_member gm Left Join gangs g on (g.id = gm.gangId ) WHERE gm.playerIdentifiers = @playerIdentifiers and  g.expireTime > NOW()", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier and gang[1].canSearch then
		TriggerClientEvent('Erfan:gang:sendNotficationFromPlayer',target,_Source,'', ''  , _U('you_have_been_robberd') , 'CHAR_SOCIAL_CLUB' , 2 )
		TriggerClientEvent('Erfan:gang:searchBody',_Source, OpenPlayerInventory(target) , target )
	else
		print(('^1[GNAG SYSTEM]: %s or ID: %s attempted to search a player that ID:%s (not Gang)!'):format(identifier,_Source,target))
	end
end)





RegisterServerEvent('Erfan:gang:searchBodyGetItem')
AddEventHandler('Erfan:gang:searchBodyGetItem', function(item , amount,TargetId)
	local _Source = source
	for k,v in ipairs(GetPlayerIdentifiers(_Source)) do
		if string.match(v, Config.IdentifiersPlayerWith ) then
			identifier = v
			break
		end
	end
	local gang = selectFromDB("SELECT gm.playerIdentifiers , g.canSearch FROM gangs_member gm Left Join gangs g on (g.id = gm.gangId )  WHERE gm.playerIdentifiers = @playerIdentifiers and  g.expireTime > NOW()", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier and gang[1].canSearch  then
		local IsItemGet = PlayerInventoryGetItem(TargetId, item.itemType, item.value, amount)
		if IsItemGet then
			local IsItemGive = PlayerInventoryGiveItem(_Source, item.itemType, item.value, amount)
			if IsItemGive then
				TriggerClientEvent('Erfan:gang:sendNotficationFromPlayer',_Source,TargetId,'', ''  , _U('armory_withdrawn',item.label ..amount ) , 'CHAR_SOCIAL_CLUB' , 2 )
				TriggerClientEvent('Erfan:gang:sendNotficationFromPlayer',TargetId,_Source,'', ''  , _U('armory_withdrawn',item.label ..amount ) , 'CHAR_SOCIAL_CLUB' , 2 )
			else 
				PlayerInventoryGiveItem(TargetId, item.itemType, item.value, amount)
			end
		end
	else
		print(('^1[GNAG SYSTEM]: %s or ID: %s attempted to get Item from a player that ID:%s (not Gang)!'):format(identifier,_Source,TargetId))
	end
end)