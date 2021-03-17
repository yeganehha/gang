
function sendToDiscord(DiscordLog,source,title,des,color)
	if Config.activeDiscordHook then
		local nick = GetPlayerName(source) or "Gang System"
		
		-----------------------------------------------------
		-----------------------------------------------------
		----  DO NOT Change Copy Right Of Erfan Ebrahimi ----
		----  DO NOT Change Copy Right Of Erfan Ebrahimi ----
		-----------------------------------------------------
		-----------------------------------------------------
		
		local embed = {{["color"] = color,["title"] = title,["description"] = des,["footer"] = {["text"] = "Dev: http://ErfanEbrahimi.ir"}}}
		Wait(100)
		PerformHttpRequest(DiscordLog, function(err, text, headers) end, 'POST', json.encode({username = nick, embeds = embed}), { ['Content-Type'] = 'application/json' })
	end
end

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		
	end
end)

ExecuteCommand(('add_ace group.%s %s allow'):format( Config.adminGroup ,  "gang.admin" ))
RegisterCommand( Config.adminCommand , function (source, args, rawCommand)
		if IsPlayerAceAllowed(source, "gang.admin") then
			local gangs = selectFromDB("SELECT * , DATE_FORMAT(expireTime, '%Y/%m/%d') as expireTimeFormat FROM gangs", {})
			TriggerClientEvent('Erfan:gang:openAdminMenu',source,gangs)
		else
			TriggerClientEvent('Erfan:gang:sendNotfication',source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
		end
end, false)


RegisterServerEvent('Erfan:gang:creatNewGang')
AddEventHandler('Erfan:gang:creatNewGang', function(gangName)
	local _Source = source
	if IsPlayerAceAllowed(_Source, "gang.admin") then
		executeOnDB('INSERT INTO `gangs` (`gangName`,`expireTime`,`coords`,`inventory`) VALUES (@gangName,NOW(),"{}","{}")', { ['@gangName'] 	 = gangName } , function(e)
			local gangs = selectFromDB("SELECT * , DATE_FORMAT(expireTime, '%Y/%m/%d') as expireTimeFormat FROM gangs", {})
			executeOnDB('INSERT INTO `gangs_grade` (`gangId`,`grade`,`name`,`salary`,`maleSkin`,`femaleSkin`) VALUES (@gangId,0,"boss","100","{}","{}")', {
				['@gangId'] 	 = gangs[#gangs].id 
			} , function(e)end)
			TriggerClientEvent('Erfan:gang:openAdminMenu',_Source,gangs)
			TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('admin_gang_created',gangName) , 'CHAR_SOCIAL_CLUB' , 2 )
		end)
		
	else
		TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
	end
end)


RegisterServerEvent('Erfan:gang:updateGangData')
AddEventHandler('Erfan:gang:updateGangData', function(gangId , variable , value)
	local _Source = source
	if IsPlayerAceAllowed(_Source, "gang.admin") then
		local query = 'UPDATE `gangs` SET `'..variable..'` = @value WHERE id = @gangId'
		if ( variable == "expireTime" ) then 
			query = 'UPDATE `gangs` SET `expireTime` = (NOW() + INTERVAL @value DAY)  WHERE id = @gangId'
		end
		executeOnDB(query, { 
			['@value'] 	 = value,
			['@gangId']  = gangId
		} , function(e) 
			local gang = selectFromDB("SELECT * , DATE_FORMAT(expireTime, '%Y/%m/%d') as expireTimeFormat FROM gangs WHERE id = @gangId", { ['@gangId']  = gangId })
			if ( variable == "expireTime" ) then 
				local gangs = selectFromDB("SELECT * , DATE_FORMAT(expireTime, '%Y/%m/%d') as expireTimeFormat FROM gangs where expireTime > NOW()", {})
				TriggerClientEvent('Erfan:gang:setGangData',-1,gangs , -2 , -2 )
			end
			if gang ~= nil and gang[1] ~= nil and gang[1].id == gangId then
				TriggerClientEvent('Erfan:gang:changeGangData',-1,gang[1] , gangId )
			end
			TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('updated_gang',variable) , 'CHAR_SOCIAL_CLUB' , 2 )
			
		end)
	else
		TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
	end
end)


RegisterServerEvent('Erfan:gang:updateGangcoords')
AddEventHandler('Erfan:gang:updateGangcoords', function(gangId , variable , value)
	local _Source = source
	if IsPlayerAceAllowed(_Source, "gang.admin") then
		local gang = selectFromDB("SELECT * , DATE_FORMAT(expireTime, '%Y/%m/%d') as expireTimeFormat FROM gangs WHERE id = @gangId", { ['@gangId']  = gangId })
		if gang ~= nil and gang[1] ~= nil and gang[1].id == gangId then
			local coords = json.decode(gang[1].coords)
			if type(value) == 'vector3' then
				local x1,y1,z1 = table.unpack(value)
				value = { x = x1 , y =y1 , z = z1 }
			end
			coords[variable] = value
			local coordsStr = json.encode(coords)
			gang[1].coords = coordsStr
			executeOnDB('UPDATE `gangs` SET `coords` = @coords WHERE id = @gangId', { 
				['@coords'] 	 = coordsStr,
				['@gangId']  = gangId
			}, function(e)
				TriggerClientEvent('Erfan:gang:changeGangData',-1,gang[1] , gangId )
				TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('updated_gang',gang[1].gangName) , 'CHAR_SOCIAL_CLUB' , 2 )
			end)			
		else
			TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
		end
	else
		TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
	end
end)


RegisterServerEvent('Erfan:gang:deleteGang')
AddEventHandler('Erfan:gang:deleteGang', function(gangId)
	local _Source = source
	if IsPlayerAceAllowed(_Source, "gang.admin") then
		executeOnDB("DELETE FROM `gangs` WHERE `id` = @gangId", { 
			['@gangId']  = gangId
		} , function(e) 
			local gangs = selectFromDB("SELECT * , DATE_FORMAT(expireTime, '%Y/%m/%d') as expireTimeFormat FROM gangs", {})
			TriggerClientEvent('Erfan:gang:openAdminMenu',_Source,gangs)
			TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('deleted_gang') , 'CHAR_SOCIAL_CLUB' , 2 )
			
			local gangs = selectFromDB("SELECT * , DATE_FORMAT(expireTime, '%Y/%m/%d') as expireTimeFormat FROM gangs where expireTime > NOW()", {})
			TriggerClientEvent('Erfan:gang:setGangData',-1,gangs , -2 , -2 )
		end)
	else
		TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
	end
end)


RegisterServerEvent('Erfan:gang:getRankForPlayer')
AddEventHandler('Erfan:gang:getRankForPlayer', function(gangId , playerId)
	local _Source = source
	if IsPlayerAceAllowed(_Source, "gang.admin") then
		local gang = selectFromDB("SELECT * , DATE_FORMAT(expireTime, '%Y/%m/%d') as expireTimeFormat FROM gangs WHERE id = @gangId", { ['@gangId']  = gangId })
		if gang ~= nil and gang[1] ~= nil and gang[1].id == gangId then
			local grades = selectFromDB("SELECT * FROM gangs_grade WHERE gangId = @gangId", { ['@gangId']  = gangId })
			TriggerClientEvent('Erfan:gang:openGradeMenu',_Source,gang[1] , grades , playerId , GetOOCPlayerName(playerId)  )
						
		else
			TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
		end
	else
		TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
	end
end)

RegisterServerEvent('Erfan:gang:addPlayerToGang')
AddEventHandler('Erfan:gang:addPlayerToGang', function(gangId , playerId , gradeId)
	local _Source = source
	if IsPlayerAceAllowed(_Source, "gang.admin") then
		local identifier = getPlayerIdentifier(playerId)
		if identifier ~= nil then
			executeOnDB("DELETE FROM `gangs_member` WHERE `playerIdentifiers` = @playerIdentifiers", { 
				['@playerIdentifiers']  = identifier
			} , function(e) 
				executeOnDB("INSERT INTO `gangs_member` (`playerIdentifiers`,`gangId`,`grade`,`name`) VALUES (@playerIdentifiers,@gangId,@grade,@name)", { 
					['@playerIdentifiers']  = identifier,
					['@gangId']  = gangId,
					['@grade']  = gradeId,
					['@name']  = GetRealPlayerName(playerId),
				} , function(e) 
					TriggerClientEvent('Erfan:gang:setGang',playerId,gangId,gradeId)
					TriggerEvent('Erfan:gang:setGang', playerId,gangId,gradeId)
					if activeGangMember['g_'..gangId] then
						table.insert( activeGangMember['g_'..gangId] , _Source )
					else
						activeGangMember['g_'..gangId] = {}
						table.insert( activeGangMember['g_'..gangId] , _Source )
					end
					TriggerClientEvent('Erfan:gang:forceBlipGangMember', -1 , activeGangMember['g_'..gangId] , gangId )
					TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('memberAdded') , 'CHAR_SOCIAL_CLUB' , 2 )
					TriggerClientEvent('Erfan:gang:sendNotfication',playerId,'[Gang System]', ''  , _U('youAdded') , 'CHAR_SOCIAL_CLUB' , 2 )
				end)
			end)
		end
		
	else
		TriggerClientEvent('Erfan:gang:sendNotfication',_Source,'[Gang System]', ''  , _U('not_acces') , 'CHAR_BLOCKED' , 2 )
	end
end)



