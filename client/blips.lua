local blipGangPlace = nil
local radiusBlipGangPlaces = {}
local blipsMembers = {}
local blipsVehicelImpound = {}
local tempI = 0 
local tempImpoundBlips = 0 

function redrawBlips()
	Citizen.CreateThread(function()
		while activeGangs == nil and activeGangs[1] == nil do
			Citizen.Wait(1000)
		end
		RemoveBlip(blipGangPlace)
		for _key, radiusBlipGangPlace in pairs(radiusBlipGangPlaces) do
			RemoveBlip(radiusBlipGangPlace)
		end
		for _key, blipVehicelImpound in pairs(blipsVehicelImpound) do
			RemoveBlip(blipVehicelImpound)
		end
		tempI = -1 
		for _key, activeGang in pairs(activeGangs) do
			local gangCoords = json.decode(activeGang.coords)
			if gangCoords ~= nil and gangCoords.blip and gangCoords.blip ~= nil then
				if activeGang.gangColor  and tonumber(activeGang.blipRadius) > 0 then
					if math.type(activeGang.blipRadius) ~= 'float' then activeGang.blipRadius = tonumber(activeGang.blipRadius) + 0.1 end
					radiusBlipGangPlaces[activeGang.id] = AddBlipForRadius(gangCoords.blip.x, gangCoords.blip.y, gangCoords.blip.z, activeGang.blipRadius)
					SetBlipAlpha(radiusBlipGangPlaces[activeGang.id] , 80)
					SetBlipColour(radiusBlipGangPlaces[activeGang.id] , Config.gangAreaBlipsColor )
				end
				if myGangId ~= nil and myGangId == activeGang.id then
					blipGangPlace = AddBlipForCoord(gangCoords.blip.x, gangCoords.blip.y, gangCoords.blip.z)
					SetBlipSprite(blipGangPlace, Config.playerGangBlips )
					SetBlipAsShortRange(blipGangPlace, true)
					SetBlipColour(blipGangPlace, Config.playerGangBlipsColor)
					SetBlipScale(blipGangPlace, 1.0)
					BeginTextCommandSetBlipName('STRING')
					AddTextComponentString(activeGang.gangName)
					EndTextCommandSetBlipName(blipGangPlace)
					redrawMarker(gangCoords)
					redrawMarkerAndBlipsForImpound()
					if activeGang.haveGPS == 0 then
						-- Refresh all blips
						for k, existingBlip in pairs(blipsMembers) do
							RemoveBlip(existingBlip)
							blipsMembers = {}
						end
					end
				end
			end
		end
	end)
end

function redrawMarker(coords)
	tempI = tempI + 1
	for _key, coord in pairs(coords) do
		if _key ~= 'blip' and ( _key ~= 'boss' or ( _key == 'boss' and myGangGrade == 0 ) ) then
			Citizen.CreateThread(function()
				local TempICheck = tempI
				local inMarker , exitMarker = false , true
				while TempICheck == tempI  and ( _key ~= 'boss' or ( _key == 'boss' and myGangGrade == 0 ) ) do
					local sleep = 3000
					local playerPed = PlayerPedId()
					local playerCoords = GetEntityCoords(playerPed)
					local distance = #(playerCoords - vector3(coord.x , coord.y , coord.z) )
					if ( distance <= Config.DrawDistance * 3 ) then sleep = 250 end
					if ( distance <= Config.DrawDistance  ) then
						DrawMarker(Config.MarkerType[_key], coord.x , coord.y , coord.z , 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x , Config.MarkerSize.y , Config.MarkerSize.z , Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						sleep = 0

						if distance < Config.MarkerSize.x then
							if not inMarker then
								inMarker = true 
								TriggerEvent('Erfan:gang:showHelpNotfication', _U('help_enter_marker_'.._key ))
							end
							if IsControlJustReleased(0, 38) then
								exitMarker = false 
								TriggerEvent('Erfan:gang:toggleMenu_'.._key )
							end
						else
							if not exitMarker then
								exitMarker = true 
								RageUI.CloseAll()
							end
							inMarker = false 
						end
					end
					Citizen.Wait(sleep)
				end
			end)
		end
	end
end


-- Create blip for colleagues
function createBlip(id)
	local ped = GetPlayerPed(id)
	local blip = GetBlipFromEntity(ped)

	if not DoesBlipExist(blip) then -- Add blip and create head display on player
		blip = AddBlipForEntity(ped)
		SetBlipSprite(blip, 1)
		ShowHeadingIndicatorOnBlip(blip, true) -- Player Blip indicator
		SetBlipRotation(blip, math.ceil(GetEntityHeading(ped))) -- update rotation
		SetBlipNameToPlayerName(blip, id) -- update blip name
		SetBlipScale(blip, 0.85) -- set scale
		SetBlipAsShortRange(blip, true)

		table.insert(blipsMembers, blip) -- add blip to array so we can remove it later
	end
end

RegisterNetEvent('Erfan:gang:forceBlipGangMember')
AddEventHandler('Erfan:gang:forceBlipGangMember', function(gangMember , gangId )
	if myGangId ~= nil and gangId ~= nil and myGangId == gangId and activeGangs[gangId] ~= nil and activeGangs[gangId].haveGPS == 1 then
		-- Refresh all blips
		for k, existingBlip in pairs(blipsMembers) do
			RemoveBlip(existingBlip)
		end

		-- Clean the blip table
		blipsMembers = {}

		for k, member in pairs(gangMember) do
			local id = GetPlayerFromServerId(member)
			if NetworkIsPlayerActive(id) and GetPlayerPed(id) ~= PlayerPedId() then
				createBlip(id)
			end		
		end
	end
end)
RegisterNetEvent('Erfan:gang:forceDeleteBlipGangMember')
AddEventHandler('Erfan:gang:forceDeleteBlipGangMember', function(gangMember , gangId )
	for k, existingBlip in pairs(blipsMembers) do
		RemoveBlip(existingBlip)
	end
end)



function redrawMarkerAndBlipsForImpound()
	tempImpoundBlips = tempImpoundBlips + 1
	for _key, coords in pairs(Config.vehicleConvertor) do
		blipsVehicelImpound[_key] = AddBlipForCoord(coords.x, coords.y, coords.z)
		SetBlipSprite(blipsVehicelImpound[_key], Config.garageGangBlips )
		SetBlipAsShortRange(blipsVehicelImpound[_key], true)
		SetBlipColour(blipsVehicelImpound[_key], Config.garageGangBlipsColor)
		SetBlipScale(blipsVehicelImpound[_key], 1.0)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString(_U('impound'))
		EndTextCommandSetBlipName(blipsVehicelImpound[_key])
		Citizen.CreateThread(function()
			local tempImpoundBlipsCheck = tempImpoundBlips
			local inMarker , exitMarker = false , true
			while tempImpoundBlipsCheck == tempImpoundBlips  do
				local sleep = 3000
				local playerPed = PlayerPedId()
				local playerCoords = GetEntityCoords(playerPed)
				local distance = #(playerCoords - vector3(coords.x , coords.y , coords.z) )
				if ( distance <= Config.DrawDistance * 3 ) then sleep = 250 end
				if ( distance <= Config.DrawDistance  ) then
					DrawMarker(Config.MarkerType.vehicleConvertor , coords.x , coords.y , coords.z , 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x , Config.MarkerSize.y , Config.MarkerSize.z , Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
					sleep = 0

					if distance < Config.MarkerSize.x then
						if not inMarker then
							inMarker = true 
							TriggerEvent('Erfan:gang:showHelpNotfication', _U('help_enter_marker_impound' ))
						end
						if IsControlJustReleased(0, 38) then
							exitMarker = false 
							TriggerEvent('Erfan:gang:toggleMenu_impound' , coords.typeVehicle )
						end
					else
						if not exitMarker then
							exitMarker = true 
							RageUI.CloseAll()
						end
						inMarker = false 
					end
				end
				Citizen.Wait(sleep)
			end
		end)
	end
end