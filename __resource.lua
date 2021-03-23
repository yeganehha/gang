resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'stand a lone gang system'
version '0.0.3.3'
author 'Erfan Ebrahimi'
url 'http://erfanebrahimi.ir'

server_scripts {
	'shared/locale.lua',
	'locales/*.lua',
	'config.lua',
	'server/admin.lua',
	'server/gangData.lua',
	'server/main.lua',
	'server/vehicle.lua',
	'server/salary.lua',
}

client_scripts {
	'shared/locale.lua',
	'locales/*.lua',
	'client/UI/RMenu.lua',
    'client/UI/menu/RageUI.lua',
    'client/UI/menu/Menu.lua',
    'client/UI/menu/MenuController.lua',
    'client/UI/components/*.lua',
    'client/UI/menu/elements/*.lua',
    'client/UI/menu/items/*.lua',
    'client/UI/menu/panels/*.lua',
    'client/UI/menu/windows/*.lua',
	'config.lua',
	'client/main.lua',
	'client/admin.lua',
	'client/blips.lua',
	'client/gangAction.lua',
	'client/markerAction.lua',
	'client/vehicle.lua'
}

export 'isOwnGangVehicle'
export 'getGangID'
export 'getGangGrade'
export 'getGangName'
export 'getGangGradeName'

server_exports {
	'getGangID',
	'getGangGrade',
	'getGangName',
	'getGangGradeName',
}


server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'esxBaseFunction.lua'
}
client_script 'esxBaseFunction.lua'