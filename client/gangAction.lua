local entityEnumerator = {
	__gc = function(enum)
		if enum.destructor and enum.handle then
			enum.destructor(enum.handle)
		end

		enum.destructor = nil
		enum.handle = nil
	end
}
local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end

		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, entityEnumerator)
		local next = true

		repeat
			coroutine.yield(id)
			next, id = moveFunc(iter)
		until not next

		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
	end)
end

function getClosetPlayer()
	local closestEntity, closestEntityDistance = -1, -1
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)

	local players, myPlayer = {}, PlayerId()

	print(json.encode(GetActivePlayers()))
	for k,player in ipairs(GetActivePlayers()) do
		local ped = GetPlayerPed(player)
		if player ~= myPlayer then
			if DoesEntityExist(ped) then
				local distance = #(coords - GetEntityCoords(ped))

				if closestEntityDistance == -1 or distance < closestEntityDistance then
					closestEntity, closestEntityDistance =  player , distance
				end
			end
		end
	end
	return closestEntity, closestEntityDistance
end

function getClosetVehicle1()
	local closestEntity, closestEntityDistance = -1, -1
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	for vehicle in EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle) do
		local distance = #(coords - GetEntityCoords(vehicle))

		if closestEntityDistance == -1 or distance < closestEntityDistance then
			closestEntity, closestEntityDistance =  vehicle , distance
		end
	end
	return closestEntity, closestEntityDistance
end

function getClosetVehicle()
	local playerPed    = PlayerPedId()
	local playerCoords = GetEntityCoords(playerPed)
	local inDirection  = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
	local rayHandle    = StartShapeTestRay(playerCoords, inDirection, 10, playerPed, 0)
	local numRayHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

	if hit == 1 and GetEntityType(entityHit) == 2 then
		return entityHit
	end

	return nil
end


local TempIAction = 0 
function checkActionMenuPressed()
	if myGangId ~= nil and myGangId > 0 and activeGangs[myGangId] ~= nil and ( activeGangs[myGangId].canSearch == 1 or activeGangs[myGangId].canCuff == 1 or activeGangs[myGangId].canMove == 1 or activeGangs[myGangId].canOpenCarsDoor == 1 )  then
		TempIAction = TempIAction + 1
		local playerId = PlayerPedId() 
		Citizen.CreateThread(function()
			local TempCheckIAction = TempIAction 
			while activeGangs == nil and activeGangs[1] == nil do
				Citizen.Wait(1000)
			end
			while TempCheckIAction == TempIAction do
				if IsControlJustReleased(0, Config.OpenActionMenu) and GetEntityHealth(playerId) then
					local player , distance = getClosetPlayer()
					openGangAction(player , distance)
				end
				Citizen.Wait(0)
			end
		end)
	end 
end

function openGangAction(closestPlayer , closestPlayerDistance)
	local gangActionMenu = RageUI.CreateMenu(_U('gang_action_menu'), _U('gang_action_menu'))
	gangActionMenu:DisplayGlare(true)
	gangActionMenu:DisplayPageCounter(true)
	gangActionMenu.EnableMouse = false
	Citizen.CreateThread(function()
		local whileGoActionMenu = true 
		while whileGoActionMenu do
			Citizen.Wait(1.0)
			gangActionMenu.Closed = function()
				whileGoActionMenu = false
			end
			RageUI.IsVisible(gangActionMenu, function()
				if activeGangs[myGangId].canSearch == 1 then
					RageUI.Button( _U('search_player'), _U('search_player_help') , {}, true, {
						onSelected = function()
							if ( closestPlayerDistance <= Config.MaxGangActionDistance ) then
								whileGoActionMenu = false
								TriggerServerEvent('Erfan:gang:searchBody',GetPlayerServerId(closestPlayer))
								RageUI.Visible(gangActionMenu, false)
							else
								TriggerEvent('Erfan:gang:sendNotfication', activeGangs[myGangId].gangName, ''  , _U('no_player_nearby') , 'CHAR_BLOCKED' , 2 )
							end
						end,
					});
				end
				if activeGangs[myGangId].canCuff == 1 then
					RageUI.Button( _U('cuff_uncuff'), _U('cuff_uncuff_help') , {}, true, {
						onSelected = function()
							if ( closestPlayerDistance <= Config.MaxGangActionDistance ) then
								RageUI.Visible(gangActionMenu, false)
								whileGoActionMenu = false
								if ( Config.handCuffAnimation ) then
									TriggerServerEvent('Erfan:gang:handcuffAnimation', GetPlayerServerId(closestPlayer))
									Citizen.Wait(3100)
								end
								TriggerServerEvent('Erfan:gang:handcuff',GetPlayerServerId(closestPlayer))
							else
								TriggerEvent('Erfan:gang:sendNotfication', activeGangs[myGangId].gangName, ''  , _U('no_player_nearby') , 'CHAR_BLOCKED' , 2 )
							end
						end,
					});
				end
				if activeGangs[myGangId].canMove == 1 then
					RageUI.Button( _U('drag_person'), _U('drag_person_help') , {}, true, {
						onSelected = function()
							if ( closestPlayerDistance <= Config.MaxGangActionDistance ) then
								whileGoActionMenu = false
								TriggerServerEvent('Erfan:gang:drag',GetPlayerServerId(closestPlayer))
								RageUI.Visible(gangActionMenu, false)
							else
								TriggerEvent('Erfan:gang:sendNotfication', activeGangs[myGangId].gangName, ''  , _U('no_player_nearby') , 'CHAR_BLOCKED' , 2 )
							end
						end,
					});
					RageUI.Button( _U('Put_in_vehicle'), _U('Put_in_vehicle_help') , {}, true, {
						onSelected = function()
							if ( closestPlayerDistance <= Config.MaxGangActionDistance ) then
								whileGoActionMenu = false
								TriggerServerEvent('Erfan:gang:putInVehicle',GetPlayerServerId(closestPlayer))
								RageUI.Visible(gangActionMenu, false)
							else
								TriggerEvent('Erfan:gang:sendNotfication', activeGangs[myGangId].gangName, ''  , _U('no_player_nearby') , 'CHAR_BLOCKED' , 2 )
							end
						end,
					});
					RageUI.Button( _U('Put_out_vehicle'), _U('Put_out_vehicle_help') , {}, true, {
						onSelected = function()
							if ( closestPlayerDistance <= Config.MaxGangActionDistance ) then
								whileGoActionMenu = false
								TriggerServerEvent('Erfan:gang:OutVehicle',GetPlayerServerId(closestPlayer))
								RageUI.Visible(gangActionMenu, false)
							else
								TriggerEvent('Erfan:gang:sendNotfication', activeGangs[myGangId].gangName, ''  , _U('no_player_nearby') , 'CHAR_BLOCKED' , 2 )
							end
						end,
					});
				end
				if activeGangs[myGangId].canOpenCarsDoor == 1 then
					RageUI.Button( _U('open_vehicle_door'), _U('open_vehicle_door_help') , {}, true, {
						onSelected = function()
							local playerPed  = PlayerPedId()
							local coords  = GetEntityCoords(playerPed)
							local vehicle = getClosetVehicle()
							if vehicle ~= nil then
								if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0) then
									whileGoActionMenu = false
									RageUI.Visible(gangActionMenu, false)
									TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
									Citizen.Wait(math.random(10000,25000))
									ClearPedTasksImmediately(playerPed)

									SetVehicleDoorsLocked(vehicle, 1)
									SetVehicleDoorsLockedForAllPlayers(vehicle, false)
									TriggerEvent('Erfan:gang:sendNotficationFromPlayer', GetPlayerServerId(playerPed) , activeGangs[myGangId].gangName, ''  , _U('vehicle_Unlocked') , 'CHAR_BLOCKED' , 1 )
								end
							else
								TriggerEvent('Erfan:gang:sendNotfication', activeGangs[myGangId].gangName, ''  , _U('no_vehicle_nearby') , 'CHAR_BLOCKED' , 2 )
							end
						end,
					});
				end
			end, function() end)
		end
	end)
	RageUI.Visible(gangActionMenu, not RageUI.Visible(gangActionMenu))
end















local isHandcuffed = false
RegisterNetEvent('Erfan:gang:handcuffAnimation')
AddEventHandler('Erfan:gang:handcuffAnimation', function(gangMemberId)
	if gangMemberId ~= nil then
		local playerPed = GetPlayerPed(-1)
		local targetPed = GetPlayerPed(GetPlayerFromServerId(gangMemberId))
		RequestAnimDict('mp_arrest_paired')
		while not HasAnimDictLoaded('mp_arrest_paired') do
			Citizen.Wait(10)
		end

		AttachEntityToEntity(GetPlayerPed(-1), targetPed, 11816, -0.1, 0.45, 0.0, 0.0, 0.0, 20.0, false, false, false, false, 20, false)
		TaskPlayAnim(playerPed, 'mp_arrest_paired', 'crook_p2_back_left', 8.0, -8.0, 5500, 33, 0, false, false, false)

		Citizen.Wait(950)
		DetachEntity(GetPlayerPed(-1), true, false)
	else
		local playerPed = GetPlayerPed(-1)
		RequestAnimDict('mp_arrest_paired')
		while not HasAnimDictLoaded('mp_arrest_paired') do
			Citizen.Wait(10)
		end
		TaskPlayAnim(playerPed, 'mp_arrest_paired', 'cop_p2_back_left', 8.0, -8.0, 5500, 33, 0, false, false, false)
	end
end)

RegisterNetEvent('Erfan:gang:handcuff')
AddEventHandler('Erfan:gang:handcuff', function()
	isHandcuffed = not isHandcuffed
	local playerPed = PlayerPedId()
	if isHandcuffed then
		RequestAnimDict('mp_arresting')
		while not HasAnimDictLoaded('mp_arresting') do
			Citizen.Wait(100)
		end
		TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
		SetEnableHandcuffs(playerPed, true)
		DisablePlayerFiring(playerPed, true)
		SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
		SetPedCanPlayGestureAnims(playerPed, false)
		FreezeEntityPosition(playerPed, true)
		DisplayRadar(false)
		Citizen.CreateThread(function()
			while isHandcuffed do
				Citizen.Wait(0)
				DisableAllControlActions(0)
				EnableControlAction(0, 47, true)
				EnableControlAction(0, 245, true)
				EnableControlAction(0, 38, true)
			end
		end)
	else
		ClearPedSecondaryTask(playerPed)
		SetEnableHandcuffs(playerPed, false)
		DisablePlayerFiring(playerPed, false)
		SetPedCanPlayGestureAnims(playerPed, true)
		FreezeEntityPosition(playerPed, false)
		DisplayRadar(true)
		isDraged = false
		DetachEntity(playerPed, true, false)
	end
end)


local isDraged = false
RegisterNetEvent('Erfan:gang:drag')
AddEventHandler('Erfan:gang:drag', function(gangId)
	if isHandcuffed then
		isDraged = not isDraged
		Citizen.CreateThread(function()
			local wasDragged = false
			local playerPed = PlayerPedId()
			local targetPed = GetPlayerPed(GetPlayerFromServerId(gangId))
			while isHandcuffed and isDraged do
				Citizen.Wait(1)

				if DoesEntityExist(targetPed) and IsPedOnFoot(targetPed) and not IsPedDeadOrDying(targetPed, true) then
					if not wasDragged then
						AttachEntityToEntity(playerPed, targetPed, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
						wasDragged = true
					else
						Citizen.Wait(1000)
					end
				else
					wasDragged = false
					isDraged = false
					DetachEntity(playerPed, true, false)
				end
				
			end
			
			wasDragged = false
			isDraged = false
			DetachEntity(playerPed, true, false)
		end)
	end
end)


RegisterNetEvent('Erfan:gang:putInVehicle')
AddEventHandler('Erfan:gang:putInVehicle', function(gangId)
	if isHandcuffed then
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		if IsAnyVehicleNearPoint(coords, 5.0) then
			local vehicle = GetClosestVehicle(coords, 5.0, 0, 71)

			if DoesEntityExist(vehicle) then
				local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

				for i=maxSeats - 1, 0, -1 do
					if IsVehicleSeatFree(vehicle, i) then
						freeSeat = i
						break
					end
				end

				if freeSeat then
					TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
					isDraged = false
				end
			end
		end
	end
end)

RegisterNetEvent('Erfan:gang:OutVehicle')
AddEventHandler('Erfan:gang:OutVehicle', function()
	local playerPed = PlayerPedId()

	if IsPedSittingInAnyVehicle(playerPed) then
		local vehicle = GetVehiclePedIsIn(playerPed, false)
		TaskLeaveVehicle(playerPed, vehicle, 64)
	end
end)








RegisterNetEvent('Erfan:gang:searchBody')
AddEventHandler('Erfan:gang:searchBody', function(inventois,TargetId)
	if myGangId ~= nil and activeGangs[myGangId] ~= nil then

		local searchBody = RageUI.CreateMenu(_U('search_player'), _U('search_player'))
		searchBody:DisplayGlare(true)
		searchBody:DisplayPageCounter(true)
		searchBody.EnableMouse = false
		Citizen.CreateThread(function()
			local whileGoSearchBody = true 
			while whileGoSearchBody do
				Citizen.Wait(1.0)
				searchBody.Closed = function()
					whileGoSearchBody = false
				end
				RageUI.IsVisible(searchBody, function()
					local typeItem = nil
					for _key, inventory in pairs(inventois) do
						if typeItem ~= inventory.itemType then
							RageUI.Separator(_U('list_of_'..inventory.itemType ))
							typeItem = inventory.itemType
						end
						RageUI.Button(inventory.label .. inventory.amount , '', {}, true, {
							onSelected = function()
								if inventory.itemType ~= 'weapon' then
									AddTextEntry('withdraw_amount', _U('withdraw_amount'))
									DisplayOnscreenKeyboard(1, "withdraw_amount", "", "" , "", "", "", 16)
									while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
										Citizen.Wait(7)
									end
									local number = GetOnscreenKeyboardResult()
									if ( number ~= nil ) then
										number = string.gsub(number, "^%s*(.-)%s*$", "%1")
										if number ~= ''  then 
											number = tonumber(number)
											if number <= inventory.amount then
												whileGoSearchBody = false
												RageUI.Visible(searchBody, false)
												TriggerServerEvent("Erfan:gang:searchBodyGetItem" , inventory , number ,TargetId )
												Citizen.Wait(500)
												TriggerServerEvent("Erfan:gang:searchBody",TargetId)
											else
												TriggerEvent('Erfan:gang:sendNotfication','[Gang System]', ''  , _U('invalid_amount') , 'CHAR_SOCIAL_CLUB' , 2 )
											end	
										end
									end
								else
									whileGoSearchBody = false
									RageUI.Visible(searchBody, false)
									TriggerServerEvent("Erfan:gang:searchBodyGetItem" , inventory , inventory.amount , TargetId )
									Citizen.Wait(500)
									TriggerServerEvent("Erfan:gang:searchBody",TargetId)
								end
							end,
						});
					end
				end, function() end)
			end
		end)
		RageUI.Visible(searchBody, not RageUI.Visible(searchBody))
	end
end)
