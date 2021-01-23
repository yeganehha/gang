local bossMenu = nil
local subMenu = {}
local gradeMenu = nil
local gradeSubMenu = {}
local memberMenu = nil
local memberSubMenu = {}
local lockerMenu = nil
local i = 0

RegisterNetEvent('Erfan:gang:toggleMenu_boss')
AddEventHandler('Erfan:gang:toggleMenu_boss', function()
	if myGangId ~= nil and activeGangs[myGangId] ~= nil and myGangGrade == 0 then
		openBossMenu()
	end
end)
function openBossMenu() 
	
	bossMenu = RageUI.CreateMenu(_U('boss_menu'), _U('boss_menu'))
	bossMenu:DisplayGlare(true)
	bossMenu:DisplayPageCounter(true)
	bossMenu.EnableMouse = false
	
	subMenu.account = RageUI.CreateMenu(_U('money_management'), _U('money_management'))
	subMenu.account:DisplayGlare(true)
	subMenu.account:DisplayPageCounter(true)
	
	subMenu.ranks = RageUI.CreateMenu(_U('ranks_management'), _U('ranks_management'))
	subMenu.ranks:DisplayGlare(true)
	subMenu.ranks:DisplayPageCounter(true)
	
	subMenu.employes = RageUI.CreateMenu(_U('employee_list'), _U('employee_list'))
	subMenu.employes:DisplayGlare(true)
	subMenu.employes:DisplayPageCounter(true)

	Citizen.CreateThread(function()
		local whileGo = true 
		while whileGo do
			Citizen.Wait(1.0)
			bossMenu.Closed = function()
				whileGo = false
			end
			RageUI.IsVisible(bossMenu, function()
				RageUI.Button( _U('money_management'), _U('account_management_help') , {}, true, {
					onHovered = function()
						Visual.Subtitle(  _U('account_money',activeGangs[myGangId].accountMoney) , 5000)
					end,
					onSelected = function()
						openAccountMenu()
					end,
				},subMenu.account);
				RageUI.Button( _U('ranks_management'), _U('ranks_management_help') , {}, true, {
					onSelected = function()
						whileGo = false
						TriggerServerEvent('Erfan:gang:getRanksOfmyGang')
						--RageUI.Visible(bossMenu, false)
					end,
				},subMenu.ranks);
				RageUI.Button( _U('employee_list'), _U('employee_management') , {}, true, {
					onSelected = function()
						whileGo = false
						TriggerServerEvent('Erfan:gang:getMembersOfmyGang')
					end,
				},subMenu.employes);
				RageUI.Button( _U('edit_discord_webHook'), _U('discord_webHook_help') , {}, true, {
					onSelected = function()
						TriggerEvent('Erfan:gang:sendNotfication','[Gang System]', ''  , _U('sendWebHookinChatBox') , 'CHAR_SOCIAL_CLUB' , 2 )
					end,
				});
			end, function() end)
		end
	end)
	RageUI.Visible(bossMenu, not RageUI.Visible(bossMenu))
end

function openAccountMenu()
	Citizen.CreateThread(function()
		local whileGoSubMenuAccount = true
		while whileGoSubMenuAccount do
			Citizen.Wait(1.0)
			RageUI.IsVisible(subMenu.account, function()
				RageUI.Separator(_U('account_money',activeGangs[myGangId].accountMoney));
				RageUI.Button(_U('withdraw_money' ) , ''  , {}, true, {
					onSelected = function()
						AddTextEntry('enter_pric_to_withdraw', _U('enter_pric_to_withdraw'))
						DisplayOnscreenKeyboard(1, "enter_pric_to_withdraw", "", "" , "", "", "", 10)
						while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
							Citizen.Wait(7)
						end
						local withdraw = GetOnscreenKeyboardResult()
						if ( withdraw ~= nil ) then
							withdraw = tonumber(withdraw)
							if withdraw ~= '' and withdraw >= 0  then 
								whileGoSubMenuAccount = false
								TriggerServerEvent("Erfan:gang:withdrawMoney", withdraw )
								Citizen.Wait(50)
								openAccountMenu()
							end
						end
					end,
				});
				RageUI.Button(_U('deposit_money' ) , ''  , {}, true, {
					onSelected = function()
						AddTextEntry('enter_pric_to_deposit', _U('enter_pric_to_deposit'))
						DisplayOnscreenKeyboard(1, "enter_pric_to_deposit", "", "" , "", "", "", 10)
						while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
							Citizen.Wait(7)
						end
						local deposit = GetOnscreenKeyboardResult()
						if ( deposit ~= nil ) then
							deposit = tonumber(deposit)
							if deposit ~= '' and deposit >= 0  then 
								whileGoSubMenuAccount = false
								TriggerServerEvent("Erfan:gang:depositMoney", deposit )
								Citizen.Wait(50)
								openAccountMenu()
							end
						end
					end,
				});
			end, function() end)
		end
	end)
end













RegisterNetEvent('Erfan:gang:openBossActionMembersMenu')
AddEventHandler('Erfan:gang:openBossActionMembersMenu', function(members,grades)
	if myGangId ~= nil and activeGangs[myGangId] ~= nil then
		openMembersMenu(members,grades)
	end
end)
	
function openMembersMenu(members,grades)
	memberMenu = nil
	collectgarbage()
		
	memberMenu = RageUI.CreateMenu(_U('employee_list'), _U('employee_list'))
	memberMenu:DisplayGlare(true)
	memberMenu:DisplayPageCounter(true)
	memberMenu.EnableMouse = false
	
	for _key, member in pairs(members) do
		memberSubMenu[_key] = RageUI.CreateSubMenu(memberMenu , _U('employee_management'), member.name)
		memberSubMenu[_key]:DisplayGlare(true)
		memberSubMenu[_key]:DisplayPageCounter(true)
	end
				
	Citizen.CreateThread(function()
		local whileGoGrade = true 
		while whileGoGrade do
			Citizen.Wait(1.0)
			memberMenu.Closed = function()
				whileGoGrade = false
			end
			RageUI.IsVisible(memberMenu, function()
					local numberOfCanGet = activeGangs[myGangId].slotPlayer
					local numberOfMember = #members
					RageUI.Separator(_U('number_of_player',numberOfMember ,numberOfCanGet ));
					RageUI.Button( _U('add_new_member'), '' , {}, ( numberOfMember >=  numberOfCanGet and false or true ), {
						onSelected = function()
							if numberOfMember <  numberOfCanGet then
								AddTextEntry('playerID', _U('playerID'))
								DisplayOnscreenKeyboard(1, "playerID", "", "" , "", "", "", 16)
								while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
									Citizen.Wait(7)
								end
								local playerID = GetOnscreenKeyboardResult()
								if ( playerID ~= nil ) then
									playerID = string.gsub(playerID, "^%s*(.-)%s*$", "%1")
									if playerID ~= ''  then 
										local id = GetPlayerFromServerId(tonumber(playerID))
										if NetworkIsPlayerActive(id) and GetPlayerPed(id) ~= PlayerPedId()  and #(GetEntityCoords(GetPlayerPed(id)) - GetEntityCoords(PlayerPedId())) < 20 then
											openGradeMenuForAddMember(grades,tonumber(playerID))
										else
											TriggerEvent('Erfan:gang:sendNotfication','[Gang System]', ''  , _U('inCorrectId') , 'CHAR_SOCIAL_CLUB' , 2 )
										end	
									end
								end
							end
						end,
					});
					RageUI.Separator(_U('employee_list' ));
				for _key, member in pairs(members) do
					RageUI.Button(member.name, _U('edit_player'), {}, true, {
						onSelected = function()
							openMemberSubMenu(grades,member,members,_key)
						end,
					},memberSubMenu[_key]);
				end
			end, function() end)
		end
	end)
	RageUI.Visible(memberMenu, not RageUI.Visible(memberMenu))
end
function openGradeMenuForAddMember(grades,playerId)
	gradeMenu = nil
	collectgarbage()
		
	gradeMenu = RageUI.CreateMenu(_U('grade'), _U('grade'))
	gradeMenu:DisplayGlare(true)
	gradeMenu:DisplayPageCounter(true)
	gradeMenu.EnableMouse = false
				
	Citizen.CreateThread(function()
		local whileGoGradeAdd = true 
		while whileGoGradeAdd do
			Citizen.Wait(1.0)
			gradeMenu.Closed = function()
				whileGoGradeAdd = false
			end
			RageUI.IsVisible(gradeMenu, function()
				for _key, grade in pairs(grades) do
					RageUI.Button(grade.name, _U('edit_grade'), {}, true, {
						onSelected = function()
							whileGoGradeAdd = false
							TriggerServerEvent("Erfan:gang:addNewMember", grade.grade , playerId )
						end,
					});
				end
			end, function() end)
		end
	end)
	RageUI.Visible(gradeMenu, not RageUI.Visible(gradeMenu))
end
function openMemberSubMenu(grades,member,members,_key)
	Citizen.CreateThread(function()
		local whileGoSubMenuMember = true
		while whileGoSubMenuMember do
			Citizen.Wait(1.0)
			RageUI.IsVisible(memberSubMenu[_key], function()
				RageUI.Button(_U('fire') , '', {}, true, {
					onSelected = function()
						whileGoSubMenuMember = false
						RageUI.Visible(memberSubMenu[_key], false)
						TriggerServerEvent("Erfan:gang:deleteMemberFromGang", member.playerIdentifiers  )
					end,
				});
				RageUI.Separator(_U('grade' ));
				for _key, grade in pairs(grades) do
					RageUI.Button(grade.name, '', {}, true, {
						onSelected = function()
							whileGoSubMenuMember = false
							TriggerServerEvent("Erfan:gang:changeGradeMemberFromGang", member.playerIdentifiers , grade.grade )
						end,
					});
				end
			end, function() end)
		end
	end)
end











RegisterNetEvent('Erfan:gang:openBossActionGradeMenu')
AddEventHandler('Erfan:gang:openBossActionGradeMenu', function(grades)
	if myGangId ~= nil and activeGangs[myGangId] ~= nil then
		openGradeMenu(grades)
	end
end)
	
function openGradeMenu(grades)
	gradeMenu = nil
	collectgarbage()
		
	gradeMenu = RageUI.CreateMenu(_U('ranks_management'), _U('ranks_management'))
	gradeMenu:DisplayGlare(true)
	gradeMenu:DisplayPageCounter(true)
	gradeMenu.EnableMouse = false
	
	for _key, grade in pairs(grades) do
		gradeSubMenu[_key] =  RageUI.CreateSubMenu(gradeMenu, grade.name , _U('ranks_management'))
		gradeSubMenu[_key]:DisplayGlare(true)
		gradeSubMenu[_key]:DisplayPageCounter(true)
	end
				
	Citizen.CreateThread(function()
		local whileGoGrade1 = true 
		while whileGoGrade1 do
			Citizen.Wait(1.0)
			gradeMenu.Closed = function()
				whileGoGrade1 = false
			end
			RageUI.IsVisible(gradeMenu, function()
					RageUI.Button( _U('add_new_grade'), '' , {}, true, {
						onSelected = function()
							Visual.Subtitle("onSelected", 100)
							AddTextEntry('enter_grade_name', _U('enter_grade_name'))
							DisplayOnscreenKeyboard(1, "enter_grade_name", "", "" , "", "", "", 16)
							while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
								Citizen.Wait(7)
							end
							local name = GetOnscreenKeyboardResult()
							if ( name ~= nil ) then
								name = string.gsub(name, "^%s*(.-)%s*$", "%1")
								if name ~= ''  then 
									whileGoGrade1 = false
									RageUI.Visible(gradeMenu, false)
									TriggerServerEvent("Erfan:gang:creatNewGrade", name )
								end
							end
						end,
					});
				for _key, grade in pairs(grades) do
					RageUI.Button(grade.name, _U('edit_grade'), {}, true, {
						onSelected = function()
							openGradeSubMenu(grade,_key)
						end,
					},gradeSubMenu[_key]);
				end
			end, function() end)
		end
	end)
	RageUI.Visible(gradeMenu, not RageUI.Visible(gradeMenu))
end

function openGradeSubMenu(grade,_key)
	Citizen.CreateThread(function()
		local whileGoSubMenuGrade = true
		while whileGoSubMenuGrade do
			Citizen.Wait(1.0)
			RageUI.IsVisible(gradeSubMenu[_key], function()
				RageUI.Button(_U('echo_grade_name' , grade.name) , _U('edit_grade_name'), {}, true, {
					onSelected = function()
						AddTextEntry('enter_grade_name', _U('enter_grade_name'))
						DisplayOnscreenKeyboard(1, "enter_grade_name", "", "" , "", "", "", 16)
						while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
							Citizen.Wait(7)
						end
						local name = GetOnscreenKeyboardResult()
						if ( name ~= nil ) then
							name = string.gsub(name, "^%s*(.-)%s*$", "%1")
							if name ~= ''  then 
								whileGoSubMenuGrade = false
								TriggerServerEvent("Erfan:gang:updateGradeData", grade.gradeId , 'name' , name )
								Citizen.Wait(50)
								grade.name = name
								openGradeSubMenu(grade,_key )
							end
						end
					end,
				});
				RageUI.Button(_U('echo_grade_salary' , grade.salary) , _U('edit_grade_salary'), {}, true, {
					onSelected = function()
						AddTextEntry('enter_grade_salary', _U('enter_grade_salary'))
						DisplayOnscreenKeyboard(1, "enter_grade_salary", "", grade.accountMoney , "", "", "", 16)
						while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
							Citizen.Wait(7)
						end
						local accountMoney = GetOnscreenKeyboardResult()
						if ( accountMoney ~= nil ) then
							accountMoney = tonumber(accountMoney)
							if accountMoney ~= '' and accountMoney >= 0  then 
								whileGoSubMenuGrade = false
								TriggerServerEvent("Erfan:gang:updateGradeData", grade.gradeId  , 'salary' , accountMoney )
								Citizen.Wait(50)
								grade.salary = accountMoney
								openGradeSubMenu(grade,_key )
							end
						end
					end,
				});
				RageUI.Checkbox(_U('access_vehicle' ), _U('access_vehicle_help' ),  (grade.accessVehicle  and  true or  false  ), {}, {
					onChecked = function()
						whileGoSubMenuGrade = false
						RageUI.Visible(gradeSubMenu[_key], false)
						TriggerServerEvent("Erfan:gang:updateGradeData", grade.gradeId , 'accessVehicle' , '1' )
						Citizen.Wait(50)
						grade.accessVehicle = true
						RageUI.Visible(gradeSubMenu[_key], true)
						openGradeSubMenu(grade,_key )
					end,
					onUnChecked = function()
						whileGoSubMenuGrade = false
						RageUI.Visible(gradeSubMenu[_key], false)
						TriggerServerEvent("Erfan:gang:updateGradeData", grade.gradeId , 'accessVehicle' , '0' )
						Citizen.Wait(50)
						grade.accessVehicle = false
						RageUI.Visible(gradeSubMenu[_key], true)
						openGradeSubMenu(grade,_key )
					end,
					onSelected = function() end,
				});
				RageUI.Checkbox(_U('access_armory' ), _U('access_armory_help' ),  (grade.accessArmory and  true or  false  ), {}, {
					onChecked = function()
						whileGoSubMenuGrade = false
						RageUI.Visible(gradeSubMenu[_key], false)
						TriggerServerEvent("Erfan:gang:updateGradeData", grade.gradeId , 'accessArmory' , '1' )
						Citizen.Wait(50)
						grade.accessArmory = true
						RageUI.Visible(gradeSubMenu[_key], true)
						openGradeSubMenu(grade,_key )
					end,
					onUnChecked = function()
						whileGoSubMenuGrade = false
						RageUI.Visible(gradeSubMenu[_key], false)
						TriggerServerEvent("Erfan:gang:updateGradeData", grade.gradeId , 'accessArmory' , '0' )
						Citizen.Wait(50)
						grade.accessArmory = false
						RageUI.Visible(gradeSubMenu[_key], true)
						openGradeSubMenu(grade,_key )
					end,
					onSelected = function() end,
				});
				RageUI.Button(_U('set_male_skin') , _U('set_male_skin_help'), {}, true, {
					onSelected = function()
						TriggerServerEvent("Erfan:gang:updateGradeData", grade.gradeId , 'maleSkin' , json.encode(getPlayerSkin()) )		
					end,
				});
				RageUI.Button(_U('set_female_skin') , _U('set_female_skin_help'), {}, true, {
					onSelected = function()
						TriggerServerEvent("Erfan:gang:updateGradeData", grade.gradeId , 'femaleSkin' , json.encode(getPlayerSkin()) )		
					end,
				});
			end, function() end)
		end
	end)
end






RegisterNetEvent('Erfan:gang:toggleMenu_locker')
AddEventHandler('Erfan:gang:toggleMenu_locker', function()
	if myGangId ~= nil and activeGangs[myGangId] ~= nil then
		openlockerMenu()
	end
end)

RegisterNetEvent('Erfan:gang:wearGang')
AddEventHandler('Erfan:gang:wearGang', function(cloths)
	local allCloths = {}
	if isPlayerPedMale() then
		allCloths = json.decode(cloths.maleSkin)
	else
		allCloths = json.decode(cloths.femaleSkin)
	end
	local playerPed = PlayerPedId()
	SetPedArmour(playerPed, 0 )
	ClearPedProp(playerPed, 9 )	
	for _key, cloth in pairs(allCloths) do
		
		if cloth.d == -1 then
			ClearPedProp(playerPed, cloth.c )
		else
			if cloth.d  and 	cloth.t and 	cloth.t >= 0 and cloth.d >= 0 then
				SetPedComponentVariation(playerPed, cloth.c , cloth.d ,	cloth.t , 2)
			end
		end
	end
	SetPedComponentVariation(playerPed, 9 , 0 ,	0 , 2)
end)

function openlockerMenu() 
	lockerMenu = nil
	collectgarbage()
	lockerMenu = RageUI.CreateMenu(_U('locker_room'), _U('locker_room'))
	lockerMenu:DisplayGlare(true)
	lockerMenu:DisplayPageCounter(true)
	lockerMenu.EnableMouse = false
	
	Citizen.CreateThread(function()
		local whileGoCloths = true 
		while whileGoCloths do
			Citizen.Wait(1.0)
			lockerMenu.Closed = function()
				whileGoCloths = false
			end
			RageUI.IsVisible(lockerMenu, function()
				RageUI.Button( _U('citizen_wear'), '' , {}, true, {
					onSelected = function()
						local playerPed = PlayerPedId()
						SetPedArmour(playerPed, 0 )
						ClearPedProp(playerPed, 9 )
						citizenWear()
					end,
				});
				RageUI.Button( _U('gang_wear'),'' , {}, true, {
					onSelected = function()
						local playerPed = PlayerPedId()
						TriggerServerEvent("Erfan:gang:wearGang")	
						SetPedArmour(playerPed, 0 )
						ClearPedProp(playerPed, 9 )	
					end,
				});
				if  activeGangs[myGangId].maxArmor > 0 then
					RageUI.Button( _U('Bulletproof'), '' , {}, true, {
						onSelected = function()
							local playerPed = PlayerPedId()
							SetPedArmour(playerPed, activeGangs[myGangId].maxArmor )
							SetPedComponentVariation(playerPed, 9 , Config.Bulletproof.typeNumber , Config.Bulletproof.colorNumber , 2)
							Citizen.CreateThread(function()
								local playerPed = PlayerPedId()
								while GetPedArmour(playerPed) > 0 do
									Citizen.Wait(1000)
								end
								ClearPedProp(playerPed, 9 )
								SetPedComponentVariation(playerPed, 9 , 0 ,	0 , 2)
							end)
						end,
					});
				end
			end, function() end)
		end
	end)
	RageUI.Visible(lockerMenu, not RageUI.Visible(lockerMenu))
end

















RegisterNetEvent('Erfan:gang:toggleMenu_armory')
AddEventHandler('Erfan:gang:toggleMenu_armory', function()
	if myGangId ~= nil and activeGangs[myGangId] ~= nil then

		local armoryMenu = RageUI.CreateMenu(_U('armory'), _U('armory'))
		armoryMenu:DisplayGlare(true)
		armoryMenu:DisplayPageCounter(true)
		armoryMenu.EnableMouse = false
		Citizen.CreateThread(function()
			local whileGoArmoryMenu = true 
			while whileGoArmoryMenu do
				Citizen.Wait(1.0)
				armoryMenu.Closed = function()
					whileGoArmoryMenu = false
				end
				RageUI.IsVisible(armoryMenu, function()
					RageUI.Button( _U('armory_deposit'), '' , {}, true, {
						onSelected = function()
							whileGoArmoryMenu = false
							RageUI.Visible(armoryMenu, false)
							TriggerServerEvent("Erfan:gang:armory_deposit")
						end,
					});
					RageUI.Button( _U('armory_withdraw'),'' , {}, true, {
						onSelected = function()
							whileGoArmoryMenu = false
							RageUI.Visible(armoryMenu, false)
							TriggerServerEvent("Erfan:gang:armory_withdraw")
						end,
					});
				end, function() end)
			end
		end)
		RageUI.Visible(armoryMenu, not RageUI.Visible(armoryMenu))
	end
end)


RegisterNetEvent('Erfan:gang:armory_deposit_open')
AddEventHandler('Erfan:gang:armory_deposit_open', function(inventois)
	if myGangId ~= nil and activeGangs[myGangId] ~= nil then

		local depositMenu = RageUI.CreateMenu(_U('armory_deposit'), _U('armory_deposit'))
		depositMenu:DisplayGlare(true)
		depositMenu:DisplayPageCounter(true)
		depositMenu.EnableMouse = false
		Citizen.CreateThread(function()
			local whileGodepositMenu = true 
			while whileGodepositMenu do
				Citizen.Wait(1.0)
				depositMenu.Closed = function()
					whileGodepositMenu = false
				end
				RageUI.IsVisible(depositMenu, function()
					local typeItem = nil
					for _key, inventory in pairs(inventois) do
						if typeItem ~= inventory.itemType then
							RageUI.Separator(_U('list_of_'..inventory.itemType ))
							typeItem = inventory.itemType
						end
						RageUI.Button(inventory.label .. inventory.amount , _U('armory_deposit_help'), {}, true, {
							onSelected = function()
								if inventory.itemType ~= 'weapon' then
									AddTextEntry('deposit_amount', _U('deposit_amount'))
									DisplayOnscreenKeyboard(1, "deposit_amount", "", "" , "", "", "", 16)
									while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
										Citizen.Wait(7)
									end
									local number = GetOnscreenKeyboardResult()
									if ( number ~= nil ) then
										number = string.gsub(number, "^%s*(.-)%s*$", "%1")
										if number ~= ''  then 
											number = tonumber(number)
											if number <= inventory.amount then
												whileGodepositMenu = false
												RageUI.Visible(depositMenu, false)
												TriggerServerEvent("Erfan:gang:armory_depositing" , inventory , number )
												Citizen.Wait(500)
												TriggerServerEvent("Erfan:gang:armory_deposit")
											else
												TriggerEvent('Erfan:gang:sendNotfication','[Gang System]', ''  , _U('invalid_amount') , 'CHAR_SOCIAL_CLUB' , 2 )
											end	
										end
									end
								else
									whileGodepositMenu = false
									RageUI.Visible(depositMenu, false)
									TriggerServerEvent("Erfan:gang:armory_depositing" , inventory , inventory.amount )
									Citizen.Wait(500)
									TriggerServerEvent("Erfan:gang:armory_deposit")
								end
							end,
						});
					end
				end, function() end)
			end
		end)
		RageUI.Visible(depositMenu, not RageUI.Visible(depositMenu))
	end
end)

RegisterNetEvent('Erfan:gang:armory_withdraw_open')
AddEventHandler('Erfan:gang:armory_withdraw_open', function(inventois)
	if myGangId ~= nil and activeGangs[myGangId] ~= nil then

		local withdrawMenu = RageUI.CreateMenu(_U('armory_withdraw'), _U('armory_withdraw'))
		withdrawMenu:DisplayGlare(true)
		withdrawMenu:DisplayPageCounter(true)
		withdrawMenu.EnableMouse = false
		
		local allItemType = {'account' , 'weapon' , 'item'}
		local allItemsSorted = {}
		for k, ItemType in pairs(allItemType) do
			for _key, inventoy in pairs(inventois) do
				if ( inventoy.itemType == ItemType ) then	
					table.insert(allItemsSorted,inventoy)
					--table.remove(inventois,_key)
				end
			end
		end
		Citizen.CreateThread(function()
			local whileGoWithdrawMenu = true 
			while whileGoWithdrawMenu do
				Citizen.Wait(1.0)
				withdrawMenu.Closed = function()
					whileGoWithdrawMenu = false
				end
				RageUI.IsVisible(withdrawMenu, function()
					local typeItem = nil
					for _key, inventoy in pairs(allItemsSorted) do
						if typeItem ~= inventoy.itemType then
							RageUI.Separator(_U('list_of_'..inventoy.itemType ))
							typeItem = inventoy.itemType
						end
						RageUI.Button(inventoy.label .. inventoy.amount , _U('armory_withdraw_help'), {}, true, {
							onSelected = function()
								if inventoy.itemType ~= 'weapon' then
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
											if number <= inventoy.amount then
												whileGoWithdrawMenu = false
												RageUI.Visible(withdrawMenu, false)
												TriggerServerEvent("Erfan:gang:armory_withdrawing" , inventoy , number )
												Citizen.Wait(500)
												TriggerServerEvent("Erfan:gang:armory_withdraw")
											else
												TriggerEvent('Erfan:gang:sendNotfication','[Gang System]', ''  , _U('invalid_amount') , 'CHAR_SOCIAL_CLUB' , 2 )
											end	
										end
									end
								else
									whileGoWithdrawMenu = false
									RageUI.Visible(withdrawMenu, false)
									TriggerServerEvent("Erfan:gang:armory_withdrawing" , inventoy , inventoy.amount )
									Citizen.Wait(500)
									TriggerServerEvent("Erfan:gang:armory_withdraw")
								end
							end,
						});
					end
				end, function() end)
			end
		end)
		RageUI.Visible(withdrawMenu, not RageUI.Visible(withdrawMenu))
	end
end)
