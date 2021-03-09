ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('jeserfcore:GetObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function getPlayerIdentifier(playerId)
	local Player = ESX.Functions.GetPlayer(playerId)
	if Player and  Player.PlayerData then
		return Player.PlayerData.citizenid
	else
		for k,v in ipairs(GetPlayerIdentifiers(playerId)) do
			return v
		end
	end
end

function GetRealPlayerName(playerId)
	local Player = ESX.Functions.GetPlayer(playerId)

	if Player then
		return Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
	else
		return GetPlayerName(playerId)
	end
end

function GetOOCPlayerName(playerId)
	return GetPlayerName(playerId)
end

function citizenWear()
	--[[ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
		TriggerEvent('skinchanger:loadSkin', skin)
	end)]]
	TriggerServerEvent("jeserf-clothes:loadPlayerSkin")
end

function isPlayerPedMale()
	local Player = ESX.Functions.GetPlayerData()

	if Player then
		return ( Player.charinfo.gender == 0 and true or false )
	else
		return true
	end
end

function getPlayerSkin()
	skins = {}
	local Player =  ESX.Functions.GetPlayerData()
	ESX.Functions.TriggerCallback('jeserf-multicharacter:server:getSkin', function(model, data)
		data = json.decode(data)
		table.insert(skins , { c = 8 , d = data['t-shirt'].item, t = data['t-shirt'].texture })
		table.insert(skins , { c = 11 , d = data['torso2'].item, t = data['torso2'].texture })
		table.insert(skins , { c = 3 , d = data['arms'].item, t = data['arms'].texture })
		table.insert(skins , { c = 10 , d = data['decals'].item, t = data['decals'].texture })
		table.insert(skins , { c = 4 , d = data['pants'].item, t = data['pants'].texture })
		table.insert(skins , { c = 6 , d = data['shoes'].item, t = data['shoes'].texture })
		table.insert(skins , { c = 1 , d = data['mask'].item, t = data['mask'].texture })
		table.insert(skins , { c = 5 , d = data['bag'].item, t = data['bag'].texture })
	end, Player.citizenid)
	while #skins ~= 8 do
		Citizen.Wait(0)
	end
	return skins
end


function setPlayerMoney(playerId,amount,typeTransaction)
	local xPlayer = ESX.Functions.GetPlayer(playerId)

	if xPlayer then
		if typeTransaction == 'add' then
			xPlayer.Functions.AddMoney('cash', amount)
			return true
		elseif typeTransaction == 'remove' then
			return xPlayer.Functions.RemoveMoney('cash', amount)
		end
	else
		return false
	end
end

function addSalary(playerId,amount)
	local xPlayer = ESX.Functions.GetPlayer(playerId)
	if xPlayer then
		xPlayer.Functions.AddMoney('bank', amount)
		return true
	else
		return false
	end
end

function OpenPlayerInventory(player)
	local xPlayer = ESX.Functions.GetPlayer(player)
	if xPlayer then
		local data = {}
		if  xPlayer.PlayerData.money['cash'] > 0 then
			table.insert(data, {
				label    = _U('money'),
				value    = 'money',
				itemType = 'account',
				amount   = xPlayer.PlayerData.money['cash']
			})
		end
		local inventory = xPlayer.PlayerData.items
		for i=1, #inventory, 1 do
			if inventory[i].amount > 0  and inventory[i].type  == 'weapon'  then
				if inventory[i].info.ammo == nil then
					inventory[i].info.ammo = 0 
				end
				table.insert(data, {
					label    = _U('confiscate_weapon', inventory[i].label),
					value    = inventory[i].name,
					itemType = inventory[i].type ,
					amount   = inventory[i].info.ammo
				})
			end
		end
		for i=1, #inventory, 1 do
			if inventory[i].amount > 0 and inventory[i].type  == 'item'  then
				table.insert(data, {
					label    = _U('confiscate_inv', inventory[i].label),
					value    = inventory[i].name,
					itemType = inventory[i].type ,
					amount   = inventory[i].amount
				})
			end
		end
		return data 
	end
	return {}
end

function PlayerInventoryGetItem(player, itemType, itemName, amount)
	local XPlayer = ESX.Functions.GetPlayer(player)
	if XPlayer then 
		if itemType == 'item' then
			return XPlayer.Functions.RemoveItem(itemName, amount)
		elseif itemType == 'account' then
			if itemName == 'money' then
				return XPlayer.Functions.RemoveMoney('cash', amount)
			end
		elseif itemType == 'weapon' then
			return XPlayer.Functions.RemoveItem(itemName, 1)
		end
	end
	return false
end

function PlayerInventoryGiveItem(player, itemType, itemName, amount)
	local XPlayer = ESX.Functions.GetPlayer(player)
	if XPlayer then 
		if itemType == 'item' then
			return XPlayer.Functions.AddItem(itemName, amount)
		elseif itemType == 'account' then
			if itemName == 'money' then
				return XPlayer.Functions.AddMoney('cash', amount)
			end
		elseif itemType == 'weapon' then
			return XPlayer.Functions.AddItem(itemName, amount)
		end
	end
	return false
end

function isOwnedvehicle(source , vehicleProps)
	local pData = ESX.Functions.GetPlayer(source)
	local result = exports['ghmattimysql']:executeSync( "SELECT * FROM `player_vehicles` WHERE citizenid = @citizenid AND  `plate` = @plate ", {['@citizenid'] = pData.PlayerData.citizenid , ['plate'] = vehicleProps.plate }, function(result) end)
	if result[1] ~= nil then
		return true
	end
	return false
end

function deleteOwnedvehicle(source , vehicleProps)
	local pData = ESX.Functions.GetPlayer(source)
	exports['ghmattimysql']:execute( "DELETE FROM `player_vehicles` WHERE citizenid = @citizenid AND  `plate` = @plate ", {['@citizenid'] = pData.PlayerData.citizenid , ['plate'] = vehicleProps.plate }, function(result) end)
	return true
end



function selectFromDB(query , params)
	local data = {}
	local result = exports['ghmattimysql']:executeSync(query, params )
	if result ~= nil then data = result end	
	return data
end

function executeOnDB(query , params , cb)
	exports['ghmattimysql']:execute(query, params , function(e) cb(e) end)
end