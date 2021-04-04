
Citizen.CreateThread(function()
    print("[^1"..GetCurrentResourceName().."^7] Started!")
    if GetCurrentResourceName() ~= 'gang' then
		print("[^1"..GetCurrentResourceName().."^7] !!^3WARNING^7!! Please rename the resource from "..GetCurrentResourceName().." to 'gang'")
    end
    print("[^1"..GetCurrentResourceName().."^7] Performing version check...")
    PerformHttpRequest("http://erfanebrahimi.ir/fivem/resources/checkupdates.php", function(status,result,c)
        if status~=200 then
            print("[^1"..GetCurrentResourceName().."^7] Version check failed!")
        else
            local data = json.decode(result)
            if data and data.updateNeeded then
                print("[^1"..GetCurrentResourceName().."^7] Outdated!")
                print("[^1"..GetCurrentResourceName().."^7] Current version: 0.0.3.3 | New version: "..data.newVersion.." | Versions behind: "..data.versionsBehind)
                print("[^1"..GetCurrentResourceName().."^7] Changelog:")
                for k,v in ipairs(data.update.changelog) do
                    print("- "..v)
                end
                print("[^1"..GetCurrentResourceName().."^7] Database update needed: "..(data.update.dbUpdateNeeded and "^4Yes^7" or "^1No^7"))
                print("[^1"..GetCurrentResourceName().."^7] Config update needed: "..(data.update.configUpdateNeeded and "^4Yes^7" or "^1No^7"))
                print("[^1"..GetCurrentResourceName().."^7] Update url: ^4"..data.update.releaseUrl.."^7")
                if (type(data.versionsBehind)=="string" or data.versionsBehind>1) and data.update.dbUpdateNeeded then
                    print("[^1"..GetCurrentResourceName().."^7] ^1!!^7 You are multiple versions behind, make sure you run update sql files (if any) from all new versions in order of release ^1!!^7")
                end
            else
                print("[^1"..GetCurrentResourceName().."^7] No updates found!")
            end
        end
    end, "POST", "resname=gang&ver=0.0.3.3")
end)

RegisterNetEvent('Erfan:gang:handcuffAnimation')
AddEventHandler('Erfan:gang:handcuffAnimation', function(target)
	TriggerClientEvent('Erfan:gang:handcuffAnimation', target, source)
	TriggerClientEvent('Erfan:gang:handcuffAnimation', source , nil )
end)

RegisterNetEvent('Erfan:gang:handcuff')
AddEventHandler('Erfan:gang:handcuff', function(target)
	local _Source = source
	local identifier = getPlayerIdentifier(_Source)
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
	local identifier = getPlayerIdentifier(_Source)
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
	local identifier = getPlayerIdentifier(_Source)
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
	local identifier = getPlayerIdentifier(_Source)
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
	local identifier = getPlayerIdentifier(_Source)
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
	local identifier = getPlayerIdentifier(_Source)
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




function getGangID(playerId)
	local identifier = getPlayerIdentifier(playerId)
	local gang = selectFromDB("SELECT gm.playerIdentifiers , g.id FROM gangs_member gm Left Join gangs g on (g.id = gm.gangId ) WHERE gm.playerIdentifiers = @playerIdentifiers and  g.expireTime > NOW()", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier then
		return gang[1].id
	else
		return nil
	end
end
function getGangGrade(playerId)
	local identifier = getPlayerIdentifier(playerId)
	local gang = selectFromDB("SELECT gm.playerIdentifiers , gm.grade FROM gangs_member gm Left Join gangs g on (g.id = gm.gangId ) WHERE gm.playerIdentifiers = @playerIdentifiers and  g.expireTime > NOW()", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier then
		return gang[1].grade
	else
		return nil
	end
end
function getGangName(playerId)
	local identifier = getPlayerIdentifier(playerId)
	local gang = selectFromDB("SELECT gm.playerIdentifiers , g.gangName FROM gangs_member gm Left Join gangs g on (g.id = gm.gangId ) WHERE gm.playerIdentifiers = @playerIdentifiers and  g.expireTime > NOW()", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier then
		return gang[1].gangName
	else
		return nil
	end
end
function getGangGradeName(playerId)
	local identifier = getPlayerIdentifier(playerId)
	local gang = selectFromDB("SELECT gm.playerIdentifiers , gg.name FROM gangs_member gm Left Join gangs g on (g.id = gm.gangId ) Left Join gangs_grade gg on ( gg.gangId = gm.gangId and gg.grade = gm.grade ) WHERE gm.playerIdentifiers = @playerIdentifiers and  g.expireTime > NOW()", { ['@playerIdentifiers']  = identifier })
	if gang ~= nil and gang[1] ~= nil and gang[1].playerIdentifiers == identifier then
		return gang[1].name
	else
		return nil
	end
end