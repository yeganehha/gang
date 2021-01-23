function payCheck()
	local members = {}
	print(json.encode(activeGangMember))
	for gangId,memmbersInGang in pairs(activeGangMember) do
		for _k,memmberId in pairs(memmbersInGang) do
			for k,v in pairs(GetPlayerIdentifiers(memmberId)) do
				if string.match(v, Config.IdentifiersPlayerWith ) then
					members[v] = memmberId
					break
				end
			end
		end
	end
	
	local gangAccountMoney = {}
	local query = ' and playerIdentifiers In ( 0 '
	local queryParameter = {}
	local _k = 1 
	for identifier,member in pairs(members) do
		query = query .. ' , @member'.._k
		queryParameter['@member'.._k] = identifier
		_k = _k + 1
	end
	query = query .. ' ) '
	
	
	
	local salaries = selectFromDB("SELECT g.accountMoney,gm.gangId,gm.playerIdentifiers,gg.salary FROM gangs_member gm Left Join gangs_grade gg on (gm.gangId = gg.gangId and gm.grade = gg.grade ) Left Join gangs g on (g.id = gm.gangId )  where g.expireTime > NOW() and gg.salary > 0 " .. query , queryParameter)
	local gradeSalary = {}
	for _k,salary in ipairs(salaries) do
		if not gradeSalary[salary.gangId] then
			gradeSalary[salary.gangId] = tonumber(salary.accountMoney)
		end
		if gradeSalary[salary.gangId] >= tonumber(salary.salary) then
			if addSalary(members[salary.playerIdentifiers] , tonumber(salary.salary)) then
				gradeSalary[salary.gangId] = gradeSalary[salary.gangId] - tonumber(salary.salary)
				TriggerClientEvent('Erfan:gang:sendNotfication',members[salary.playerIdentifiers],'[Gang System]', ''  , _U('calary_recived' , salary.salary) , 'CHAR_BANK_MAZE' , 9 )
			end
		else
			TriggerClientEvent('Erfan:gang:sendNotfication',members[salary.playerIdentifiers],'[Gang System]', ''  , _U('your_gang_is_poor') , 'CHAR_BANK_MAZE' , 1 )
		end
	end
	for gangId,accountMoney in pairs(gradeSalary) do
		executeOnDB('UPDATE `gangs` SET `accountMoney` = @accountMoney WHERE id = @gangId', { 
			['@accountMoney'] 	 = accountMoney,
			['@gangId']  = gangId
		}, function(e)
			if activeGangMember['g_'..gangId] then
				for k,v in ipairs(activeGangMember['g_'..gangId]) do
					TriggerClientEvent('Erfan:gang:setGangAccountMoney',v,gangId,'set',accountMoney)
				end
			end
		end)
	end
	SetTimeout(Config.PaySalaryInterval * 60000, payCheck)
end

SetTimeout(Config.PaySalaryInterval * 60000, payCheck)
