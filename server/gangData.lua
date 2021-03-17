activeGangMember = {}

RegisterServerEvent('Erfan:gang:getActiveGang')
AddEventHandler('Erfan:gang:getActiveGang', function()
	local _Source = source
	local gangs = selectFromDB("SELECT * , DATE_FORMAT(expireTime, '%Y/%m/%d') as expireTimeFormat FROM gangs where expireTime > NOW()", {})
	local identifier = getPlayerIdentifier(_Source)
	local gang = selectFromDB("SELECT * FROM gangs_member WHERE playerIdentifiers = @playerIdentifiers", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier then
		TriggerClientEvent('Erfan:gang:setGangData',_Source,gangs , gang[1].gangId , gang[1].grade )
		if activeGangMember['g_'..gang[1].gangId] then
			table.insert( activeGangMember['g_'..gang[1].gangId] , _Source )
		else
			activeGangMember['g_'..gang[1].gangId] = {}
			table.insert( activeGangMember['g_'..gang[1].gangId] , _Source )
		end
		TriggerClientEvent('Erfan:gang:forceBlipGangMember', -1 , activeGangMember['g_'..gang[1].gangId] , gang[1].gangId )
	else
		TriggerClientEvent('Erfan:gang:setGangData',_Source,gangs , -1 , -1 )
	end
	
end)

RegisterServerEvent('Erfan:gang:forceBlipGangMemberGet')
AddEventHandler('Erfan:gang:forceBlipGangMemberGet', function(gangId)
	TriggerClientEvent('Erfan:gang:forceBlipGangMember', -1 , activeGangMember['g_'..gangId] , gangId )
end)

AddEventHandler('playerDropped', function (reason)
	local _Source = source
	local findPlayer = false
	for _key1,GangMember in ipairs(activeGangMember) do
		for _key2,Member in ipairs(GangMember) do
			if Member == _Source then
				table.remove(activeGangMember['g_'.._key1], _key2)
				TriggerClientEvent('Erfan:gang:forceBlipGangMember', -1 , activeGangMember['g_'.._key1] , GangMember.gangId )
				findPlayer = true
				break
			end
		end
		if findPlayer then break end
	end
end)



RegisterCommand("sethook", function(src, args, rawCommand)
	if rawCommand:sub(9) then
		local _Source = src
		local identifier = getPlayerIdentifier(_Source)
		local gang = selectFromDB("SELECT * FROM gangs_member WHERE playerIdentifiers = @playerIdentifiers", { ['@playerIdentifiers']  = identifier })
		if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier and gang[1].grade == 0 then
			executeOnDB('UPDATE `gangs` SET `discordHook` = @discordHook  WHERE id = @gangId', { 
				['@discordHook'] 	 = rawCommand:sub(9),
				['@gangId']  =  gang[1].gangId
			} , function(e) 
				TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('updated_gang','') , 'CHAR_SOCIAL_CLUB' , 2 )
			end)
		else
			TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
		end
	end
end, true)
TriggerClientEvent("chat:addSuggestion", "/sethook", _U('discord_webHook') , {name = "url", _U('discord_webHook')})



RegisterServerEvent('Erfan:gang:depositMoney')
AddEventHandler('Erfan:gang:depositMoney', function(amount)
	local _Source = source
	amount = tonumber(amount)
	local identifier = getPlayerIdentifier(_Source)
	local gang = selectFromDB("SELECT * FROM gangs_member WHERE playerIdentifiers = @playerIdentifiers", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier and gang[1].grade == 0 then
		local setMoney = setPlayerMoney(_Source,amount,'remove') 
		if setMoney then
			executeOnDB('UPDATE `gangs` SET `accountMoney` = `accountMoney` + @accountMoney  WHERE id = @gangId', { 
				['@accountMoney'] 	 = amount,
				['@gangId']  =  gang[1].gangId
			} , function(e) 
				TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('have_deposited',amount) , 'CHAR_SOCIAL_CLUB' , 2 )
				if activeGangMember['g_'..gang[1].gangId] then
					for k,v in ipairs(activeGangMember['g_'..gang[1].gangId]) do
						TriggerClientEvent('Erfan:gang:setGangAccountMoney',v,gang[1].gangId,'add',amount)
					end
				end
			end)
		else
			TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('dont_have_enough_money') , 'CHAR_SOCIAL_CLUB' , 2 )
		end
	else
		TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
	end
	
end)


RegisterServerEvent('Erfan:gang:withdrawMoney')
AddEventHandler('Erfan:gang:withdrawMoney', function(amount)
	local _Source = source
	amount = tonumber(amount)
	local identifier = getPlayerIdentifier(_Source)
	local gang = selectFromDB("SELECT * FROM gangs_member WHERE playerIdentifiers = @playerIdentifiers", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier and gang[1].grade == 0 then
		local gangData = selectFromDB("SELECT * FROM gangs WHERE id = @id", { ['@id']  =  gang[1].gangId })
		if gangData[1] and tonumber(gangData[1].accountMoney) >= amount then
			local setMoney = setPlayerMoney(_Source,amount,'add') 
			if setMoney then
				executeOnDB('UPDATE `gangs` SET `accountMoney` = @accountMoney  WHERE id = @gangId', { 
					['@accountMoney'] 	 = tonumber(gangData[1].accountMoney) - amount,
					['@gangId']  =  gang[1].gangId
				} , function(e) 
					TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('have_withdrawn',amount) , 'CHAR_SOCIAL_CLUB' , 2 )
					if activeGangMember['g_'..gang[1].gangId] then
						for k,v in ipairs(activeGangMember['g_'..gang[1].gangId]) do
							TriggerClientEvent('Erfan:gang:setGangAccountMoney',v,gang[1].gangId,'remove',amount)
						end
					end
				end)
			else
				TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('inCorrectId') , 'CHAR_SOCIAL_CLUB' , 2 )
			end
		else
			TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('gang_dont_have_enough_money') , 'CHAR_SOCIAL_CLUB' , 2 )
		end
	else
		TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
	end
	
end)




RegisterServerEvent('Erfan:gang:getRanksOfmyGang')
AddEventHandler('Erfan:gang:getRanksOfmyGang', function()
	local _Source = source
	local identifier = getPlayerIdentifier(_Source)
	local gang = selectFromDB("SELECT * FROM gangs_member WHERE playerIdentifiers = @playerIdentifiers", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier and gang[1].grade == 0 then
		local grades = selectFromDB("SELECT * FROM gangs_grade WHERE gangId = @gangId", { ['@gangId']  = gang[1].gangId })
		TriggerClientEvent('Erfan:gang:openBossActionGradeMenu',_Source, grades   )
	else
		TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
	end
end)



RegisterServerEvent('Erfan:gang:creatNewGrade')
AddEventHandler('Erfan:gang:creatNewGrade', function(name)
	local _Source = source
	amount = tonumber(amount)
	local identifier = getPlayerIdentifier(_Source)
	local gang = selectFromDB("SELECT * FROM gangs_member WHERE playerIdentifiers = @playerIdentifiers", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier and gang[1].grade == 0 then
		local maxGrade = selectFromDB("SELECT MAX(grade) + 1  as garde FROM `gangs_grade` WHERE `gangId` = @gangId", { ['@gangId']  = gang[1].gangId })
		local insertGrade = 0 
		if maxGrade ~= nil and maxGrade[1] ~= nil and maxGrade[1].garde ~= nil then insertGrade =  maxGrade[1].garde end
		executeOnDB('INSERT INTO `gangs_grade` (`gangId`,`grade`,`name`,`salary`,`maleSkin`,`femaleSkin`) VALUES (@gangId,@grade,@name,"100","{}","{}")', {
				['@gangId'] 	 = gang[1].gangId,
				['@name'] 	 = name , 
				['@grade'] 	 = insertGrade , 
			} , function(e)
				local grades = selectFromDB("SELECT * FROM gangs_grade WHERE gangId = @gangId", { ['@gangId']  = gang[1].gangId })
				TriggerClientEvent('Erfan:gang:openBossActionGradeMenu',_Source, grades   )
				TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('grade_created',name) , 'CHAR_SOCIAL_CLUB' , 2 )
			end)
	else
		TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
	end
	
end)




RegisterServerEvent('Erfan:gang:updateGradeData')
AddEventHandler('Erfan:gang:updateGradeData', function(gradeId , variabel , value)
	local _Source = source
	amount = tonumber(amount)
	local identifier = getPlayerIdentifier(_Source)
	local gang = selectFromDB("SELECT * FROM gangs_member WHERE playerIdentifiers = @playerIdentifiers", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier and gang[1].grade == 0 then
		executeOnDB('UPDATE `gangs_grade` set `'..variabel..'` = @value where gradeId = @gradeId and `gangId` = @gangId', {
				['@gradeId'] 	 = gradeId,
				['@gangId'] 	 = gang[1].gangId , 
				['@value'] 	 = value , 
			} , function(e)
				TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('updated_gang','') , 'CHAR_SOCIAL_CLUB' , 2 )
			end)
	else
		TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
	end
end)




RegisterServerEvent('Erfan:gang:getMembersOfmyGang')
AddEventHandler('Erfan:gang:getMembersOfmyGang', function()
	local _Source = source
	local identifier = getPlayerIdentifier(_Source)
	local gang = selectFromDB("SELECT * FROM gangs_member WHERE playerIdentifiers = @playerIdentifiers", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier and gang[1].grade == 0 then
		local members = selectFromDB("SELECT * FROM gangs_member WHERE gangId = @gangId", { ['@gangId']  = gang[1].gangId })
		local grades = selectFromDB("SELECT * FROM gangs_grade WHERE gangId = @gangId", { ['@gangId']  = gang[1].gangId })
		TriggerClientEvent('Erfan:gang:openBossActionMembersMenu',_Source,members , grades   )
	else
		TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
	end
end)





RegisterServerEvent('Erfan:gang:addNewMember')
AddEventHandler('Erfan:gang:addNewMember', function(gradeId , playerId)
	local _Source = source
	local identifier = getPlayerIdentifier(_Source)
	local gang = selectFromDB("SELECT * FROM gangs_member WHERE playerIdentifiers = @playerIdentifiers", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier and gang[1].grade == 0 then
		local identifier = nil
		identifier = getPlayerIdentifier(playerId)
		if identifier ~= nil then
			executeOnDB("DELETE FROM `gangs_member` WHERE `playerIdentifiers` = @playerIdentifiers", { 
				['@playerIdentifiers']  = identifier
			} , function(e) 
				executeOnDB("INSERT INTO `gangs_member` (`playerIdentifiers`,`gangId`,`grade`,`name`) VALUES (@playerIdentifiers,@gangId,@grade,@name)", { 
					['@playerIdentifiers']  = identifier,
					['@gangId']  = gang[1].gangId,
					['@grade']  = gradeId,
					['@name']  = GetRealPlayerName(playerId),
				} , function(e) 
					TriggerClientEvent('Erfan:gang:setGang',playerId,gangId,gradeId)
					TriggerEvent('Erfan:gang:setGang', playerId,gangId,gradeId)
					if activeGangMember['g_'..gang[1].gangId] then
						table.insert( activeGangMember['g_'..gang[1].gangId] , playerId )
					else
						activeGangMember['g_'..gang[1].gangId] = {}
						table.insert( activeGangMember['g_'..gang[1].gangId] , playerId )
					end
					TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('memberAdded') , 'CHAR_SOCIAL_CLUB' , 2 )
					TriggerClientEvent('Erfan:gang:sendNotfication',playerId,'[Gang System]', ''  , _U('youAdded') , 'CHAR_SOCIAL_CLUB' , 2 )
					TriggerClientEvent('Erfan:gang:setGang',playerId,gang[1].gangId,gradeId)
					TriggerClientEvent('Erfan:gang:forceBlipGangMember', -1 , activeGangMember['g_'..gang[1].gangId] , gang[1].gangId )
				end)
			end)
		end
	else
		TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
	end
end)

RegisterServerEvent('Erfan:gang:changeGradeMemberFromGang')
AddEventHandler('Erfan:gang:changeGradeMemberFromGang', function( playerId , gradeId)
	local _Source = source
	local identifier = getPlayerIdentifier(_Source)
	local gang = selectFromDB("SELECT * FROM gangs_member WHERE playerIdentifiers = @playerIdentifiers", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier and gang[1].grade == 0 then
		executeOnDB("UPDATE `gangs_member` set `grade` = @grade where playerIdentifiers = @playerIdentifiers and gangId = @gangId ", { 
			['@playerIdentifiers']  = playerId,
			['@gangId']  = gang[1].gangId,
			['@grade']  = gradeId,
		} , function(e) 
			if activeGangMember['g_'..gang[1].gangId] then
				for _key1,gangMemberSRC in ipairs(activeGangMember['g_'..gang[1].gangId]) do
					local identifierCheck = getPlayerIdentifier(gangMemberSRC)
					if identifierCheck == playerId then
						playerId = gangMemberSRC
						break
					end
				end
			end
			TriggerClientEvent('Erfan:gang:setGang',playerId,gang[1].gangId,gradeId)
			TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('change_member_grade') , 'CHAR_SOCIAL_CLUB' , 2 )
			TriggerClientEvent('Erfan:gang:sendNotfication',playerId,'[Gang System]', ''  , _U('change_your_grade') , 'CHAR_SOCIAL_CLUB' , 2 )
		end)
	else
		TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
	end
end)

RegisterServerEvent('Erfan:gang:deleteMemberFromGang')
AddEventHandler('Erfan:gang:deleteMemberFromGang', function(playerId)
	local _Source = source
	local identifier = getPlayerIdentifier(_Source)
	local gang = selectFromDB("SELECT * FROM gangs_member WHERE playerIdentifiers = @playerIdentifiers", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier and gang[1].grade == 0 then
		local identifier = playerId
		executeOnDB("DELETE FROM `gangs_member` WHERE `playerIdentifiers` = @playerIdentifiers", { 
			['@playerIdentifiers']  = identifier
		} , function(e) 
			if activeGangMember['g_'..gang[1].gangId] then
				for _key1,gangMemberSRC in ipairs(activeGangMember['g_'..gang[1].gangId]) do
					local identifierCheck = getPlayerIdentifier(gangMemberSRC)
					if identifierCheck == identifier then
						table.remove( activeGangMember['g_'..gang[1].gangId] , _key1 )
						playerId = gangMemberSRC
						break
					end
				end
			end
			TriggerClientEvent('Erfan:gang:setGang',playerId,-1,-1)
			TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('player_fired') , 'CHAR_SOCIAL_CLUB' , 2 )
			TriggerClientEvent('Erfan:gang:sendNotfication',playerId,'[Gang System]', ''  , _U('you_fired') , 'CHAR_SOCIAL_CLUB' , 2 )
			
			TriggerClientEvent('Erfan:gang:forceBlipGangMember', -1 , activeGangMember['g_'..gang[1].gangId] , gang[1].gangId )
			TriggerClientEvent('Erfan:gang:forceDeleteBlipGangMember',playerId)
		end)
	else
		TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
	end
end)

RegisterServerEvent('Erfan:gang:wearGang')
AddEventHandler('Erfan:gang:wearGang', function()
	local _Source = source
	local identifier = getPlayerIdentifier(_Source)
	local gang = selectFromDB("SELECT * FROM gangs_member WHERE playerIdentifiers = @playerIdentifiers", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier then
		local grade = selectFromDB("SELECT * FROM gangs_grade WHERE gangId = @gangId and grade = @grade ", { ['@gangId']  = gang[1].gangId , ['@grade']  = gang[1].grade })
		if grade ~= nil and grade[1] ~= nil and grade[1].gangId == gang[1].gangId  then
			TriggerClientEvent('Erfan:gang:wearGang',_Source,grade[1] )
		end
	else
		TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
	end
end)



RegisterServerEvent('Erfan:gang:armory_deposit')
AddEventHandler('Erfan:gang:armory_deposit', function()
	local _Source = source
	local identifier = getPlayerIdentifier(_Source)
	local gang = selectFromDB("SELECT gm.playerIdentifiers , gg.accessArmory FROM gangs_member gm Left Join gangs_grade gg on (gg.gangId = gm.gangId and gg.grade = gm.grade )  WHERE gm.playerIdentifiers = @playerIdentifiers", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier and gang[1].accessArmory then
		TriggerClientEvent('Erfan:gang:armory_deposit_open',_Source, OpenPlayerInventory(_Source) )
	else
		TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
	end
end)

RegisterServerEvent('Erfan:gang:armory_withdraw')
AddEventHandler('Erfan:gang:armory_withdraw', function()
	local _Source = source
	local identifier = getPlayerIdentifier(_Source)
	local gang = selectFromDB("SELECT gm.playerIdentifiers , gg.accessArmory , g.inventory FROM gangs_member gm Left Join gangs_grade gg on (gg.gangId = gm.gangId and gg.grade = gm.grade ) Left Join gangs g on (g.id = gm.gangId )  WHERE gm.playerIdentifiers = @playerIdentifiers", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier and gang[1].accessArmory then
		TriggerClientEvent('Erfan:gang:armory_withdraw_open',_Source, json.decode(gang[1].inventory)		)
	else
		TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
	end
end)

RegisterServerEvent('Erfan:gang:armory_depositing')
AddEventHandler('Erfan:gang:armory_depositing', function(item , amount)
	local _Source = source
	local identifier = getPlayerIdentifier(_Source)
	local gang = selectFromDB("SELECT gm.playerIdentifiers , gg.accessArmory , gm.gangId, g.inventory, g.discordHook FROM gangs_member gm Left Join gangs_grade gg on (gg.gangId = gm.gangId and gg.grade = gm.grade ) Left Join gangs g on (g.id = gm.gangId )  WHERE gm.playerIdentifiers = @playerIdentifiers", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier and gang[1].accessArmory  then
		local IsItemGet = PlayerInventoryGetItem(_Source, item.itemType, item.value, amount)
		if IsItemGet then
			local gangInventory = json.decode(gang[1].inventory) 
			local gangAmount = 0
			for k,v in ipairs(gangInventory) do
				if v.value == item.value and  v.itemType == item.itemType then
					if  item.itemType ~= 'weapon' then
						table.remove(gangInventory, k)
					end
					gangAmount = v.amount
					break
				end
			end
			if  item.itemType ~= 'weapon' then
				item.amount = amount +  gangAmount ;
			end
			table.insert(gangInventory,item)
			executeOnDB('UPDATE `gangs` SET `inventory` = @inventory  WHERE id = @gangId', { 
				['@inventory'] 	 = json.encode(gangInventory),
				['@gangId']  = gang[1].gangId
			}, function(e)
				TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('armory_deposited',item.label ..amount ) , 'CHAR_SOCIAL_CLUB' , 2 )
				if gang[1].discordHook ~= nil or gang[1].discordHook ~= ''  then
					sendToDiscord(gang[1].discordHook,_Source,_U('discord_deposit_title'),_U('discord_deposit_des',Config.discordHookStartWith,GetOOCPlayerName(_Source) , item.label ..amount , Config.discordHookSignature),3066993)
				end
			end)
		else
			TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
		end
	else
		TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
	end
end)

RegisterServerEvent('Erfan:gang:armory_withdrawing')
AddEventHandler('Erfan:gang:armory_withdrawing', function(item , amount)
	local _Source = source
	local identifier = getPlayerIdentifier(_Source)
	local gang = selectFromDB("SELECT gm.playerIdentifiers , gg.accessArmory , gm.gangId, g.inventory, g.discordHook FROM gangs_member gm Left Join gangs_grade gg on (gg.gangId = gm.gangId and gg.grade = gm.grade ) Left Join gangs g on (g.id = gm.gangId )  WHERE gm.playerIdentifiers = @playerIdentifiers", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier and gang[1].accessArmory  then
		local gangInventory = json.decode(gang[1].inventory) 
		local gangAmount = 0
		local gangItemKey = nil
		for k,v in ipairs(gangInventory) do
			if v.value == item.value and  v.itemType == item.itemType then
				gangItemKey = k
				gangAmount = v.amount
				break
			end
		end
		if gangAmount >= amount then
			local IsItemGive = PlayerInventoryGiveItem(_Source, item.itemType, item.value, amount)
			if IsItemGive then
				table.remove(gangInventory, gangItemKey)
				if  item.itemType ~= 'weapon' then
					item.amount = gangAmount - amount
					table.insert(gangInventory,item)
				end
				executeOnDB('UPDATE `gangs` SET `inventory` = @inventory  WHERE id = @gangId', { 
					['@inventory'] 	 = json.encode(gangInventory),
					['@gangId']  = gang[1].gangId
				}, function(e)
					TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('armory_withdrawn',item.label ..amount ) , 'CHAR_SOCIAL_CLUB' , 2 )
					if gang[1].discordHook ~= nil or gang[1].discordHook ~= ''  then
						sendToDiscord(gang[1].discordHook,_Source,_U('discord_witdraw_title'),_U('discord_witdraw_des',Config.discordHookStartWith,GetOOCPlayerName(_Source) , item.label ..amount , Config.discordHookSignature),15105570)
					end
				end)
			end
		end
	else
		TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
	end
end)

RegisterServerEvent('Erfan:gang:getGangGradeName')
AddEventHandler('Erfan:gang:getGangGradeName', function(gangId , grade)
	local _Source = source
	local gang = selectFromDB("SELECT name FROM gangs_grade Where gangId = @gangId and grade = @grade ", { ['@gangId']  = gangId , ['@grade'] = grade })
	if gang ~= nil and gang[1] ~= nil then
		TriggerClientEvent('Erfan:gang:getGangGradeName',_Source,gang[1].name )
	else
		TriggerClientEvent('Erfan:gang:getGangGradeName',_Source,'' )
	end
end)