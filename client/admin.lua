local adminMenu = {}
local gradeMenu = nil
local subMenu = {}
local subMenuOfGang = {}
local gangs = {}
local i = 0

RegisterNetEvent('Erfan:gang:openAdminMenu')
AddEventHandler('Erfan:gang:openAdminMenu', function(gangsData)
	openAdminMenu(gangsData)
end)

RegisterNetEvent('Erfan:gang:openGradeMenu')
AddEventHandler('Erfan:gang:openGradeMenu', function(gangData , grades , playerId , PlayerName )
	openGradeMenuAdmin(gangData , grades , playerId , PlayerName)
end)

RegisterNetEvent('Erfan:gang:changeGangData')
AddEventHandler('Erfan:gang:changeGangData', function(gangsData , id)
	if  gangs[id] and gangs[id] ~= nil then
		gangs[id] = gangsData
	end
end)

	
function openGradeMenuAdmin(gangData , grades , playerId , PlayerName)
	gradeMenu = nil

	gradeMenu = RageUI.CreateMenu(PlayerName, _U('selectGradeToAdd',gangData.gangName))
	gradeMenu:DisplayGlare(true)
	gradeMenu:DisplayPageCounter(true)
	gradeMenu.EnableMouse = false
				
	Citizen.CreateThread(function()
		local whileGo = true 
		while whileGo do
			Citizen.Wait(1.0)
			gradeMenu.Closed = function()
				whileGo = false
			end
			RageUI.IsVisible(gradeMenu, function()
				for _key, grade in pairs(grades) do
					RageUI.Button(grade.name, '', {}, true, {
						onSelected = function()
							whileGo = false
							TriggerServerEvent("Erfan:gang:addPlayerToGang", gangData.id , playerId , grade.grade  )
						end,
					});
				end
			end, function() end)
		end
	end)
	RageUI.Visible(gradeMenu, not RageUI.Visible(gradeMenu))
end
	
function openAdminMenu(gangsData)
	i = i +1 
	for _key, adminM in pairs(adminMenu) do
		if _key ~= i then
			adminMenu[_key] = nil
			collectgarbage()
		end
	end
	adminMenu[i] = RageUI.CreateMenu(_U('admin_menu_title'), _U('admin_menu_sub_title'))
	adminMenu[i]:DisplayGlare(true)
	adminMenu[i]:DisplayPageCounter(true)
	adminMenu[i].EnableMouse = false
	
	for _key, gang in pairs(gangsData) do
		gangs[gang.id] = gang
		subMenu[_key] =  RageUI.CreateSubMenu(adminMenu[i], gang.gangName , _U('admin_menu_sub_title2'))
		subMenu[_key]:DisplayGlare(true)
		subMenu[_key]:DisplayPageCounter(true)
		
		subMenuOfGang[_key] = {} 
		subMenuOfGang[_key].blips =  RageUI.CreateSubMenu(subMenu[_key], gang.gangName , _U('admin_menu_sub_title2'))
		subMenuOfGang[_key].blips:DisplayGlare(true)
		subMenuOfGang[_key].blips:DisplayPageCounter(true)
		subMenuOfGang[_key].coords =  RageUI.CreateSubMenu(subMenu[_key], gang.gangName , _U('admin_menu_sub_title2'))
		subMenuOfGang[_key].coords:DisplayGlare(true)
		subMenuOfGang[_key].coords:DisplayPageCounter(true)
		subMenuOfGang[_key].setting =  RageUI.CreateSubMenu(subMenu[_key], gang.gangName , _U('admin_menu_sub_title2'))
		subMenuOfGang[_key].setting:DisplayGlare(true)
		subMenuOfGang[_key].setting:DisplayPageCounter(true)
		subMenuOfGang[_key].Delete =  RageUI.CreateSubMenu(subMenu[_key], gang.gangName , _U('admin_menu_sub_title2'))
		subMenuOfGang[_key].Delete:DisplayGlare(true)
		subMenuOfGang[_key].Delete:DisplayPageCounter(true)
	end
				
	Citizen.CreateThread(function()
		local whileGo = true 
		while whileGo do
			Citizen.Wait(1.0)
			adminMenu[i].Closed = function()
				whileGo = false
			end
			RageUI.IsVisible(adminMenu[i], function()
					RageUI.Button( _U('admin_add_new_gang'), '' , {}, true, {
						onHovered = function()
							Visual.Subtitle("onHovered", 100)
						end,
						onSelected = function()
							Visual.Subtitle("onSelected", 100)
							AddTextEntry('gang_name', _U('gang_name'))
							DisplayOnscreenKeyboard(1, "gang_name", "", "" , "", "", "", 16)
							while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
								Citizen.Wait(7)
							end
							local name = GetOnscreenKeyboardResult()
							if ( name ~= nil ) then
								name = string.gsub(name, "^%s*(.-)%s*$", "%1")
								if name ~= ''  then 
									whileGo = false
									TriggerServerEvent("Erfan:gang:creatNewGang", name )
								end
							end
						end,
					});
				for _key, gang in pairs(gangsData) do
					RageUI.Button(gang.gangName, _U('edit_show_gang_data'), {}, true, {
						onHovered = function()
							Visual.Subtitle("onHovered", 100)
						end,
						onSelected = function()
							openGangDataSubMenu(gang.id,_key , gangsData )
						end,
					},subMenu[_key]);
				end
			end, function() end)
		end
	end)
	RageUI.Visible(adminMenu[i], not RageUI.Visible(adminMenu[i]))
end

function openGangDataSubMenu(gangId,_key , gangsData )
	Citizen.CreateThread(function()
		local whileGoSubMenu = true
		while whileGoSubMenu do
			local gang = gangs[gangId]
			Citizen.Wait(1.0)
			RageUI.IsVisible(subMenu[_key], function()
				RageUI.Button(_U('echo_gang_name' , gang.gangName) , _U('edit_gang_name'), {}, true, {
					onSelected = function()
						AddTextEntry('gang_name', _U('gang_name'))
						DisplayOnscreenKeyboard(1, "gang_name", "", "" , "", "", "", 16)
						while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
							Citizen.Wait(7)
						end
						local name = GetOnscreenKeyboardResult()
						if ( name ~= nil ) then
							name = string.gsub(name, "^%s*(.-)%s*$", "%1")
							if name ~= ''  then 
								whileGoSubMenu = false
								TriggerServerEvent("Erfan:gang:updateGangData", gang.id , 'gangName' , name )
								Citizen.Wait(50)
								openGangDataSubMenu(gang.id,_key )
							end
						end
					end,
				});
				RageUI.Button(_U('echo_gang_money' , gang.accountMoney) , _U('edit_gang_money'), {}, true, {
					onSelected = function()
						AddTextEntry('gang_account_money', _U('new_gang_account_money'))
						DisplayOnscreenKeyboard(1, "gang_account_money", "", gang.accountMoney , "", "", "", 16)
						while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
							Citizen.Wait(7)
						end
						local accountMoney = GetOnscreenKeyboardResult()
						if ( accountMoney ~= nil ) then
							accountMoney = tonumber(accountMoney)
							if accountMoney ~= '' and accountMoney ~= nil and accountMoney >= 0  then 
								whileGoSubMenu = false
								TriggerServerEvent("Erfan:gang:updateGangData", gang.id , 'accountMoney' , accountMoney )
								Citizen.Wait(50)
								openGangDataSubMenu(gang.id,_key )
							end
						end
					end,
				});
				RageUI.Button(_U('echo_gang_expire' , gang.expireTimeFormat) , _U('edit_gang_expire'), {}, true, {
					onSelected = function()
						AddTextEntry('gang_expire', _U('add_gang_expire_day'))
						DisplayOnscreenKeyboard(1, "gang_expire", "", "" , "", "", "", 16)
						while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
							Citizen.Wait(7)
						end
						local expireTime = GetOnscreenKeyboardResult()
						if ( expireTime ~= nil ) then
							expireTime = tonumber(expireTime)
							if expireTime ~= '' and expireTime ~= nil and expireTime >= 0  then 
								whileGoSubMenu = false
								TriggerServerEvent("Erfan:gang:updateGangData", gang.id , 'expireTime' , expireTime )
								Citizen.Wait(50)
								openGangDataSubMenu(gang.id,_key )
							end
						end
					end,
				});
				RageUI.Button(_U('addMember') , _U('addPlayerToGang'), {}, true, {
					onSelected = function()
						while true do
							AddTextEntry('gang_playerID', _U('playerID'))
							DisplayOnscreenKeyboard(1, "gang_playerID", "", "" , "", "", "", 16)
							while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
								Citizen.Wait(7)
							end
							local playerID = GetOnscreenKeyboardResult()
							if ( playerID ~= nil ) then
								playerID = tonumber(playerID)
								if playerID ~= '' and playerID ~= nil and playerID >= 0 and GetPlayerFromServerId(playerID) ~= -1 then 
									whileGoSubMenu = false
									TriggerServerEvent("Erfan:gang:getRankForPlayer", gang.id , playerID )
									break
								else
									TriggerEvent('Erfan:gang:sendNotfication','[Gang System]', ''  , _U('inCorrectId') , 'CHAR_BLOCKED' , 2 )
								end
							end
						end
					end,
				});
				RageUI.Button(_U('Blips_settting') , _U('edit_Blips_settting'), {}, true,{
					onSelected = function()
						openGangBlipsSubMenu(gangId,_key )
					end
				} , subMenuOfGang[_key].blips );
				RageUI.Button(_U('coords_settting') , _U('edit_coords_settting'), {}, true,{
					onSelected = function()
						openGangcoordsSubMenu(gangId,_key )
					end
				} , subMenuOfGang[_key].coords );
				RageUI.Button(_U('settting') , _U('edit_settting'), {}, true,{
					onSelected = function()
						openGangsSetttingSubMenu(gangId,_key )
					end
				} , subMenuOfGang[_key].setting );
				RageUI.Button(_U('delete_gang'), _U('delete_gang'), { Color = { HightLightColor = { 255, 0, 0, 150 }, BackgroundColor = { 150, 0, 0, 160 } }}, true, {
					onSelected = function() 
						deleteGangDataSubMenu(gangId,_key , gangsData)
					end
				} , subMenuOfGang[_key].Delete);
			end, function() end)
		end
	end)
end

function openGangBlipsSubMenu(gangId,_key )
	Citizen.CreateThread(function()
		local whileGoSubMenuBlips = true
		while whileGoSubMenuBlips do
			local gang = gangs[gangId]
			Citizen.Wait(1.0)
			RageUI.IsVisible(subMenuOfGang[_key].blips, function()
				RageUI.Button(_U('set_blips_location') , _U('edit_blips_location'), {}, true, {
					onSelected = function()
						local coords = GetEntityCoords(GetPlayerPed(-1), true) 
						TriggerServerEvent("Erfan:gang:updateGangcoords", gang.id , 'blip' , coords  )
					end,
				});
				RageUI.Button(_U('set_blips_radius' , gang.blipRadius ) , _U('edit_blips_radius'), {}, true, {
					onSelected = function()
						AddTextEntry('gang_blips_radiu', _U('enter_blips_radius'))
						DisplayOnscreenKeyboard(1, "gang_blips_radiu", "", "" , "", "", "", 6)
						while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
							Citizen.Wait(7)
						end
						local blipRadius = GetOnscreenKeyboardResult()
						if ( blipRadius ~= nil ) then
							blipRadius = tonumber(blipRadius)
							if blipRadius ~= '' and blipRadius ~= nil and blipRadius >= 0  then 
								whileGoSubMenuBlips = false
								TriggerServerEvent("Erfan:gang:updateGangData", gang.id , 'blipRadius' , blipRadius )
								Citizen.Wait(50)
								openGangBlipsSubMenu(gang.id,_key )
							end
						end
					end,
				});
				RageUI.Checkbox(_U('enable_gang_area' ), '', gang.gangColor , {}, {
					onChecked = function()
						whileGoSubMenuBlips = false
						TriggerServerEvent("Erfan:gang:updateGangData",  gang.id , 'gangColor' , '1' )
						Citizen.Wait(50)
						openGangBlipsSubMenu(gang.id,_key )
					end,
					onUnChecked = function()
						whileGoSubMenuBlips = false
						TriggerServerEvent("Erfan:gang:updateGangData",  gang.id , 'gangColor' , '0' )
						Citizen.Wait(50)
						openGangBlipsSubMenu(gang.id,_key )
					end,
					onSelected = function(Index)
						--gang.gangColor = (Index and  1 or  0  )
					end
				});
			end, function() end)
		end
	end)
end

function openGangsSetttingSubMenu(gangId,_key )
	Citizen.CreateThread(function()
		local whileGoSubMenuSetting = true
		while whileGoSubMenuSetting do
			local gang = gangs[gangId]
			Citizen.Wait(1.0)
			RageUI.IsVisible(subMenuOfGang[_key].setting, function()
				RageUI.Button(_U('set_maximum_count_member' , gang.slotPlayer ) , _U('edit_count_member'), {}, true, {
					onSelected = function()
						AddTextEntry('gang_count_member', _U('enter_count_member'))
						DisplayOnscreenKeyboard(1, "gang_count_member", "", "" , "", "", "", 3)
						while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
							Citizen.Wait(7)
						end
						local slotPlayer = GetOnscreenKeyboardResult()
						if ( slotPlayer ~= nil ) then
							slotPlayer = tonumber(slotPlayer)
							if slotPlayer ~= '' and slotPlayer ~= nil and slotPlayer >= 0  then 
								whileGoSubMenuSetting = false
								TriggerServerEvent("Erfan:gang:updateGangData", gang.id , 'slotPlayer' , slotPlayer )
								Citizen.Wait(50)
								openGangsSetttingSubMenu(gang.id,_key )
							end
						end
					end,
				});
				RageUI.Button(_U('set_armor' , gang.maxArmor ) , _U('edit_armor'), {}, true, {
					onSelected = function()
						AddTextEntry('gang_armor', _U('enter_armor'))
						DisplayOnscreenKeyboard(1, "gang_armor", "", "" , "", "", "", 3)
						while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
							Citizen.Wait(7)
						end
						local maxArmor = GetOnscreenKeyboardResult()
						if ( maxArmor ~= nil ) then
							maxArmor = tonumber(maxArmor)
							if maxArmor ~= '' and maxArmor ~= nil and maxArmor >= 0  then 
								whileGoSubMenuSetting = false
								TriggerServerEvent("Erfan:gang:updateGangData", gang.id , 'maxArmor' , maxArmor )
								Citizen.Wait(50)
								openGangsSetttingSubMenu(gang.id,_key )
							end
						end
					end,
				});
				RageUI.Checkbox(_U('enable_search_player' ), _U('enable_search_player_info' ),  (gang.canSearch == 1 and  true or  false  ), {}, {
					onChecked = function()
						whileGoSubMenuSetting = false
						TriggerServerEvent("Erfan:gang:updateGangData", gang.id , 'canSearch' , '1' )
						Citizen.Wait(50)
						openGangsSetttingSubMenu(gang.id,_key )
					end,
					onUnChecked = function()
						whileGoSubMenuSetting = false
						TriggerServerEvent("Erfan:gang:updateGangData", gang.id , 'canSearch' , '0' )
						Citizen.Wait(50)
						openGangsSetttingSubMenu(gang.id,_key )
					end,
				});
				RageUI.Checkbox(_U('enable_cuff_player' ), _U('enable_cuff_player_info' ),  (gang.canCuff == 1 and  true or  false  ), {}, {
					onChecked = function()
						whileGoSubMenuSetting = false
						TriggerServerEvent("Erfan:gang:updateGangData", gang.id , 'canCuff' , '1' )
						Citizen.Wait(50)
						openGangsSetttingSubMenu(gang.id,_key )
					end,
					onUnChecked = function()
						whileGoSubMenuSetting = false
						TriggerServerEvent("Erfan:gang:updateGangData", gang.id , 'canCuff' , '0' )
						Citizen.Wait(50)
						openGangsSetttingSubMenu(gang.id,_key )
					end,
				});
				RageUI.Checkbox(_U('enable_move_player' ), _U('enable_move_player_info' ),  (gang.canMove == 1 and  true or  false  ), {}, {
					onChecked = function()
						whileGoSubMenuSetting = false
						TriggerServerEvent("Erfan:gang:updateGangData", gang.id , 'canMove' , '1' )
						Citizen.Wait(50)
						openGangsSetttingSubMenu(gang.id,_key )
					end,
					onUnChecked = function()
						whileGoSubMenuSetting = false
						TriggerServerEvent("Erfan:gang:updateGangData", gang.id , 'canMove' , '0' )
						Citizen.Wait(50)
						openGangsSetttingSubMenu(gang.id,_key )
					end,
				});
				RageUI.Checkbox(_U('enable_open_car' ), _U('enable_open_car_info' ),  (gang.canOpenCarsDoor == 1 and  true or  false  ), {}, {
					onChecked = function()
						whileGoSubMenuSetting = false
						TriggerServerEvent("Erfan:gang:updateGangData", gang.id , 'canOpenCarsDoor' , '1' )
						Citizen.Wait(50)
						openGangsSetttingSubMenu(gang.id,_key )
					end,
					onUnChecked = function()
						whileGoSubMenuSetting = false
						TriggerServerEvent("Erfan:gang:updateGangData", gang.id , 'canOpenCarsDoor' , '0' )
						Citizen.Wait(50)
						openGangsSetttingSubMenu(gang.id,_key )
					end,
				});
				RageUI.Checkbox(_U('enable_GPS' ), _U('enable_GPS_info' ),  (gang.haveGPS == 1 and  true or  false  ), {}, {
					onChecked = function()
						whileGoSubMenuSetting = false
						TriggerServerEvent("Erfan:gang:updateGangData", gang.id , 'haveGPS' , '1' )
						Citizen.Wait(50)
						openGangsSetttingSubMenu(gang.id,_key )
					end,
					onUnChecked = function()
						whileGoSubMenuSetting = false
						TriggerServerEvent("Erfan:gang:updateGangData", gang.id , 'haveGPS' , '0' )
						Citizen.Wait(50)
						openGangsSetttingSubMenu(gang.id,_key )
					end,
				});
			end, function() end)
		end
	end)
end

function openGangcoordsSubMenu(gangId,_key )
	Citizen.CreateThread(function()
		local whileGoSubMenucoords = true
		while whileGoSubMenucoords do
			local gang = gangs[gangId]
			Citizen.Wait(1.0)
			RageUI.IsVisible(subMenuOfGang[_key].coords, function()
				RageUI.Button(_U('set_boss_action') , _U('edit_boss_action'), {}, true, {
					onSelected = function()
						local coords = GetEntityCoords(GetPlayerPed(-1), true) 
						TriggerServerEvent("Erfan:gang:updateGangcoords", gang.id , 'boss' , coords  )
					end,
				});
				RageUI.Button(_U('set_locker') , _U('edit_locker'), {}, true, {
					onSelected = function()
						local coords = GetEntityCoords(GetPlayerPed(-1), true) 
						TriggerServerEvent("Erfan:gang:updateGangcoords", gang.id , 'locker' , coords  )
					end,
				});
				RageUI.Button(_U('set_armory') , _U('edit_armory'), {}, true, {
					onSelected = function()
						local coords = GetEntityCoords(GetPlayerPed(-1), true) 
						TriggerServerEvent("Erfan:gang:updateGangcoords", gang.id , 'armory' , coords  )
					end,
				});
				RageUI.Button(_U('set_vehicle') , _U('edit_vehicle'), {}, true, {
					onSelected = function()
						local coords = GetEntityCoords(GetPlayerPed(-1), true) 
						TriggerServerEvent("Erfan:gang:updateGangcoords", gang.id , 'vehicle' , coords  )
					end,
				});
				RageUI.Button(_U('set_helicopter') , _U('edit_helicopter'), {}, true, {
					onSelected = function()
						local coords = GetEntityCoords(GetPlayerPed(-1), true) 
						TriggerServerEvent("Erfan:gang:updateGangcoords", gang.id , 'helicopter' , coords  )
					end,
				});
				RageUI.Button(_U('set_boat') , _U('edit_boat'), {}, true, {
					onSelected = function()
						local coords = GetEntityCoords(GetPlayerPed(-1), true) 
						TriggerServerEvent("Erfan:gang:updateGangcoords", gang.id , 'boat' , coords  )
					end,
				});
			end, function() end)
		end
	end)
end



function deleteGangDataSubMenu(gangId,_key , gangsData)
	Citizen.CreateThread(function()
		local whileGoDeleteMenu = true
		while whileGoDeleteMenu do
			local gang = gangs[gangId]
			Citizen.Wait(1.0)
			RageUI.IsVisible(subMenuOfGang[_key].Delete, function()
				RageUI.Separator(_U('sure_to_delete' , gang.gangName))
				RageUI.Button(_U('cancel') , '', {}, true, {
					onSelected = function()
						whileGoDeleteMenu = false
						openAdminMenu(gangsData)
					end,
				});
				RageUI.Button(_U('delete_gang'), _U('delete_gang'), { Color = { HightLightColor = { 255, 0, 0, 150 }, BackgroundColor = { 150, 0, 0, 160 } }}, true, {
					onSelected = function() 
						whileGoDeleteMenu = false
						TriggerServerEvent("Erfan:gang:deleteGang", gang.id )
						RageUI.Visible(adminMenu[i], false)
						RageUI.CloseAll()
					end
				});
			end, function() end)
		end
	end)
end

