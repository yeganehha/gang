activeGangs = {}
myGangId = nil
myGangGrade = nil

function getGangID()
	return myGangId
end
function getGangGrade()
	return myGangGrade
end
function getGangName()
	if myGangId ~= nil and activeGangs[myGangId] then
		return activeGangs[myGangId].gangName
	else
		return ''
	end
end



myGangGradeName = ''
RegisterNetEvent('Erfan:gang:getGangGradeName')
AddEventHandler('Erfan:gang:getGangGradeName', function(name)
	myGangGradeName = name
end)
function getGangGradeName()
	return myGangGradeName 
end

function getMugshot(ped)
	local mugshot = RegisterPedheadshot(ped)

	while not IsPedheadshotReady(mugshot) do
		Citizen.Wait(0)
	end

	return mugshot, GetPedheadshotTxdString(mugshot)
end

RegisterNetEvent('Erfan:gang:sendNotfication')
AddEventHandler('Erfan:gang:sendNotfication', function(title, subject, msg, icon, iconType)
	SetNotificationTextEntry('STRING')
	AddTextComponentSubstringPlayerName(msg)
	SetNotificationMessage(icon, icon, false, iconType, title, subject)
	DrawNotification(false, false)	
end)

RegisterNetEvent('Erfan:gang:sendNotficationFromPlayer')
AddEventHandler('Erfan:gang:sendNotficationFromPlayer', function( target , title, subject, msg, iconType)
	target = GetPlayerFromServerId(target)
	local targetPed = GetPlayerPed(target)
	local mugshot, mugshotStr = getMugshot(targetPed)
	SetNotificationTextEntry('STRING') 
	AddTextComponentSubstringPlayerName(msg)
	SetNotificationMessage(mugshotStr, mugshotStr, false, iconType, title, subject)
	DrawNotification(false, false)	
	UnregisterPedheadshot(mugshot)
end)

RegisterNetEvent('Erfan:gang:showHelpNotfication')
AddEventHandler('Erfan:gang:showHelpNotfication', function(msg)
	BeginTextCommandDisplayHelp('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandDisplayHelp(0, false, true, -1)
end)


Citizen.CreateThread(function()
	while myGangId == nil do
		TriggerServerEvent("Erfan:gang:getActiveGang")
		Citizen.Wait(500)
	end
end)


RegisterCommand("gang", function()
	TriggerServerEvent("Erfan:gang:getActiveGang")
end)


RegisterNetEvent('Erfan:gang:setGang')
AddEventHandler('Erfan:gang:setGang', function(gangId , gradeId)
	myGangId = gangId
	myGangGrade = gradeId
	if activeGangs[gangId] ~= nil and activeGangs[gangId].haveGPS == 1 then
		TriggerServerEvent("Erfan:gang:forceBlipGangMemberGet",gangId)
	end
	TriggerServerEvent('Erfan:gang:getGangGradeName', myGangId,myGangGrade)
	checkActionMenuPressed()
	redrawBlips()
end)

RegisterNetEvent('Erfan:gang:changeGangData')
AddEventHandler('Erfan:gang:changeGangData', function(gangsData , id)
	if  activeGangs[id] and activeGangs[id] ~= nil then
		activeGangs[id] = gangsData
		if activeGangs[id].haveGPS == 1 then
			TriggerServerEvent("Erfan:gang:forceBlipGangMemberGet",id)
		end
	end 
	
	redrawBlips()
end)

RegisterNetEvent('Erfan:gang:setGangData')
AddEventHandler('Erfan:gang:setGangData', function(gangsData , gangId , gradeId )
	activeGangs = {}
	for _key, gang in pairs(gangsData) do
		activeGangs[gang.id] = gang
	end
	if gangId > -2 and gradeId > -2 then
		myGangId = gangId
		myGangGrade = gradeId
		TriggerServerEvent('Erfan:gang:getGangGradeName', myGangId,myGangGrade)
	end
	checkActionMenuPressed()
	redrawBlips()
end)

RegisterNetEvent('Erfan:gang:setGangAccountMoney')
AddEventHandler('Erfan:gang:setGangAccountMoney', function( gangId , typeTransaction , amount )
	if  activeGangs[gangId] and activeGangs[gangId] ~= nil then
		if typeTransaction == 'add' then
			activeGangs[gangId].accountMoney = math.floor(activeGangs[gangId].accountMoney + amount)
		elseif typeTransaction == 'set' then
			activeGangs[gangId].accountMoney = amount
		else
			activeGangs[gangId].accountMoney = math.floor(activeGangs[gangId].accountMoney - amount)
		end
	end 
end)
