ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)


function GetRealPlayerName(playerId)
	local xPlayer = ESX.GetPlayerFromId(playerId)

	if xPlayer then
		return xPlayer.getName()
	else
		return GetPlayerName(playerId)
	end
end

function GetOOCPlayerName(playerId)
	return GetPlayerName(playerId)
end

function citizenWear()
	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
		TriggerEvent('skinchanger:loadSkin', skin)
	end)
end

function isPlayerPedMale()
	isMale = -1
	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
		isMale = skin.sex == 0
	end)
	while isMale == -1 do
		Citizen.Wait(0)
	end
	return isMale
end

function getPlayerSkin()
	skins = {}
	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
		table.insert(skins , { c = 8 , d = skin.tshirt_1, t = skin.tshirt_2 })
		table.insert(skins , { c = 11 , d = skin.torso_1, t =  skin.torso_2 })
		table.insert(skins , { c = 3 , d = skin.arms , t = skin.arms_2 })
		table.insert(skins , { c = 10 , d = skin.decals_1 , t = skin.decals_2 })
		table.insert(skins , { c = 4 , d = skin.pants_1 , t = skin.pants_2 })
		table.insert(skins , { c = 6 , d = skin.shoes_1 , t = skin.shoes_2  })
		table.insert(skins , { c = 1 , d = skin.mask_1 , t = skin.mask_2 })
		table.insert(skins , { c = 7 , d = skin.chain_1 , t = skin.chain_2 })
		table.insert(skins , { c = 5 , d = skin.bags_1 , t = skin.bags_2 })
	end)
	while #skins ~= 9 do
		Citizen.Wait(0)
	end
	return skins
end


function setPlayerMoney(playerId,amount,typeTransaction)
	local xPlayer = ESX.GetPlayerFromId(playerId)

	if xPlayer then
		if typeTransaction == 'add' then
			xPlayer.addMoney(amount)
			return true
		elseif typeTransaction == 'remove' and xPlayer.getMoney() >= amount then
			xPlayer.removeMoney(amount)
			return true
		elseif typeTransaction == 'remove' and xPlayer.getMoney() < amount then
			return false
		end
	else
		return false
	end
end

function addSalary(playerId,amount)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	if xPlayer then
		xPlayer.addAccountMoney('bank', amount)
		return true
	else
		return false
	end
end

function OpenPlayerInventory(player)
	local xPlayer = ESX.GetPlayerFromId(player)
	if xPlayer then
		local data = {}
		local account = xPlayer.getAccounts()
		for i=1, #account, 1 do
			if account[i].name == 'black_money' and account[i].money > 0 then
				table.insert(data, {
					label    = _U('confiscate_dirty'),
					value    = 'black_money',
					itemType = 'account',
					amount   = account[i].money
				})

				break
			end
		end
		if  xPlayer.getMoney() > 0 then
			table.insert(data, {
				label    = _U('money'),
				value    = 'money',
				itemType = 'account',
				amount   = xPlayer.getMoney()
			})
		end
		
		local loadout = xPlayer.getLoadout()
		for i=1, #loadout , 1 do
			table.insert(data, {
				label    = _U('confiscate_weapon', ESX.GetWeaponLabel(loadout[i].name)),
				value    = loadout[i].name,
				itemType = 'weapon',
				amount   = loadout[i].ammo
			})
		end
		local inventory = xPlayer.getInventory()
		for i=1, #inventory, 1 do
			if inventory[i].count > 0 then
				table.insert(data, {
					label    = _U('confiscate_inv', inventory[i].label),
					value    = inventory[i].name,
					itemType = 'item',
					amount   = inventory[i].count
				})
			end
		end
		return data 
	end
	return {}
end

function PlayerInventoryGetItem(player, itemType, itemName, amount)
	local XPlayer = ESX.GetPlayerFromId(player)
	if XPlayer then 
		if itemType == 'item' then
			local Item = XPlayer.getInventoryItem(itemName)
			if Item.count > 0 and Item.count >= amount then
				XPlayer.removeInventoryItem(itemName, amount)
				return true
			end
		elseif itemType == 'account' then
			if itemName == 'money' then
				if XPlayer.getMoney() >= amount then
					XPlayer.removeMoney(amount)
					return true
				end
			else
				if XPlayer.getAccount(itemName).money >= amount then
					XPlayer.removeAccountMoney(itemName, amount)
					return true
				end
			end
		elseif itemType == 'weapon' then
			if amount == nil then amount = 0 end
			XPlayer.removeWeapon(itemName, amount)
			return true
		end
	end
	return false
end

function PlayerInventoryGiveItem(player, itemType, itemName, amount)
	local XPlayer = ESX.GetPlayerFromId(player)
	if XPlayer then 
		if itemType == 'item' then
			if XPlayer.canCarryItem(itemName, amount) then
				XPlayer.addInventoryItem(itemName, amount)
				return true
			end
		elseif itemType == 'account' then
			if itemName == 'money' then
				XPlayer.addMoney(amount)
				return true
			else
				XPlayer.addAccountMoney(itemName, amount)
				return true
			end
		elseif itemType == 'weapon' then
			if amount == nil then amount = 0 end
			XPlayer.addWeapon(itemName, amount)
			return true
		end
	end
	return false
end

function isOwnedvehicle(source , vehicleProps)
	local xPlayer = ESX.GetPlayerFromId(source)
	local result = MySQL.Sync.fetchAll('SELECT plate FROM owned_vehicles WHERE owner = @owner AND plate = @plate AND ( job Is null or job = "" or job = "civ" )', {
		['@owner'] = xPlayer.identifier,
		['@plate'] = vehicleProps.plate
	})

	if result[1] then
		return true
	end
	return false
end

function deleteOwnedvehicle(source , vehicleProps)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.execute('DELETE FROM owned_vehicles WHERE owner = @owner AND plate = @plate AND ( job Is null or job = "" or job = "civ" )', {
		['@owner'] = xPlayer.identifier,
		['@plate'] = vehicleProps.plate
	} , function(e)  end)
	return true
end


function selectFromDB(query , params)
	return MySQL.Sync.fetchAll(query, params )
end

function executeOnDB(query , params , cb)
	MySQL.Async.execute(query, params , function(e) cb(e) end)
end