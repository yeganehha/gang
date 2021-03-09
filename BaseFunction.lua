function GetRealPlayerName(playerId)
	-- return Ic Player Name 
	-- Like: return Player.GetName()
end

function getPlayerIdentifier(playerId)
	for k,v in ipairs(GetPlayerIdentifiers(playerId)) do
		return v
	end
	-- return identifier of player
end

function GetOOCPlayerName(playerId)
	return GetPlayerName(playerId)
end

function citizenWear()
	-- call function that chnage skin of player ped to default skin
end

function isPlayerPedMale()
	-- return true if player ped sex is male and return false if its female
end

function getPlayerSkin()
	-- this function get in real time player ped skin
	-- you should retuen array off object that creat in this format :  { c = 8 , d = tshirt_Model , t = tshirt_Color }
	-- for example :
	--[[
	skins = {}
	table.insert(skins , { c = 8 , d = tshirt_1, t = tshirt_2 })
	table.insert(skins , { c = 11 , d = torso_1, t =  torso_2 })
	table.insert(skins , { c = 3 , d = arms , t = arms_2 })
	table.insert(skins , { c = 10 , d = decals_1 , t = decals_2 })
	table.insert(skins , { c = 4 , d = pants_1 , t = pants_2 })
	table.insert(skins , { c = 6 , d = shoes_1 , t = shoes_2  })
	table.insert(skins , { c = 1 , d = mask_1 , t = mask_2 })
	table.insert(skins , { c = 7 , d = chain_1 , t = chain_2 })
	table.insert(skins , { c = 5 , d = bags_1 , t = bags_2 })
	return skins
	--]]
end


function setPlayerMoney(playerId,amount,typeTransaction)
	-- this function too add or rediuce player cash money
	-- typeTransaction is like `add` or `remove`
	-- you should return true if transaction done or return false if transaction failed.
end

function addSalary(playerId,amount)
	-- this function too add or rediuce player Salary
	-- you should return true if transaction done or return false if transaction failed.
end

function OpenPlayerInventory(player)
	-- this function for get player inventory,loadout and account money
	-- you should retuen array off object that creat in this format :  { label = `Item Label` , value = `Item Name` , itemType = ItemTypeEnum , amount = 5 }
	-- label is label of item that show to player
	-- value is name of item that save in DataBase
	-- ItemTypeEnum one of the : `account` , `weapon` , `item`
	-- amount is number of that item ( for weapon is ammo )
	-- for example :
	--[[
	local data = {}
	table.insert(data, {
		label    = _U('confiscate_dirty'),
		value    = 'black_money',
		itemType = 'account',
		amount   = account[i].money
	})
	table.insert(data, {
		label    = _U('confiscate_weapon', ESX.GetWeaponLabel(loadout[i].name)),
		value    = loadout[i].name,
		itemType = 'weapon',
		amount   = loadout[i].ammo
	})	
	table.insert(data, {
		label    = _U('confiscate_inv', inventory[i].label),
		value    = inventory[i].name,
		itemType = 'item',
		amount   = inventory[i].count
	})
	return data 
	--]]
end

function PlayerInventoryGetItem(playerId, itemType, itemName, amount)
	-- this function for rediuce player inventory item
	-- itemType one of the : `account` , `weapon` , `item`
	-- itemName is name of item that save in DataBase
	-- amount is number of that item to should rediuce from player inventory
	-- you should return true if transaction done or return false if transaction failed.
end

function PlayerInventoryGiveItem(playerId, itemType, itemName, amount)
	-- this function for add player inventory item
	-- itemType one of the : `account` , `weapon` , `item`
	-- itemName is name of item that save in DataBase
	-- amount is number of that item to should add to player inventory
	-- you should return true if transaction done or return false if transaction failed.
end

function isOwnedvehicle(playerId , vehicleProps)
	-- this function to check is vehicle owner is playerId
	-- vehicleProps array of vehicle property 
	-- you should return true if playerId is owner of vehicle or return false if not.
	-- for example:
	--[[
	local result = MySQL.Sync.fetchAll('SELECT plate FROM owned_vehicles WHERE owner = @owner AND plate = @plate AND ( job Is null or job = "" )', {
		['@owner'] = Player.identifier,
		['@plate'] = vehicleProps.plate
	})
	if result[1] then
		return true
	end
	return false
	]]
end

function deleteOwnedvehicle(playerId , vehicleProps)
	-- this function to delete owner of vehicle
	-- vehicleProps array of vehicle property 
	-- you should return true if transaction done or return false if transaction failed.
	-- for example:
	--[[
	MySQL.Async.execute('DELETE FROM owned_vehicles WHERE owner = @owner AND plate = @plate AND ( job Is null or job = "" )', {
		['@owner'] = Player.identifier,
		['@plate'] = vehicleProps.plate
	} , function(e)  end)
	return true
	]]
end


function selectFromDB(query , params)
	-- for get data from your database
	-- for example:
	-- return MySQL.Sync.fetchAll(query, params )
end

function executeOnDB(query , params , cb)
	-- for execute query on your database
	-- for example:
	-- MySQL.Async.execute(query, params , function(e) cb(e) end)
end