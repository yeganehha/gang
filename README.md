# Fivem Stand A Lone Gang System

This stand a lone resource adds Gang System with armories, vehicle garages and ability for gang members to search, handcuff people and much more.
Developed by [Erfan Ebrahimi](http://erfanebrahimi.ir)

## Demo
you can sea video of this script in [YouTube](https://www.youtube.com/watch?v=7YaAn2Q8k2A)

### Requirements
* This stand a lone resource and nothing required

* Pay attention! If you want to use armories, search and salary system of gang, you should sync resource with your FiveM core like ESX.
  * For syncing this resource with your core just need too add your core function to esxBaseFunction.lua or other core you use.
  * We add ESX and QBus core as default to this resource(Do not forget change your baseFunction file in the end of `__resource.lua`).
  
## Download & Installation

### Using [fvm](https://github.com/qlaffont/fvm-installer)
```
fvm install --save --folder=gang yeganehha/gang
```

### Using Git
```
cd resources
git clone https://github.com/yeganehha/gang [gang]/gang
```

### Manually
- Download https://github.com/yeganehha/gang/archive/master.zip
- Put it in the resource directory


## Installation
- Import `gang.sql` in your database
- Sync BaseFunction.lua with your core (If your core is not ESX or QBus)
   * If your core is not ESX or QBus replace 
		```
		server_script 'esxBaseFunction.lua'
		client_script 'esxBaseFunction.lua'
		```
		with 
		```
		server_script 'BaseFunction.lua'
		client_script 'BaseFunction.lua'
		```
		in end of `__resource.lua`

   * If your core is QBus replace
		```
		server_script 'esxBaseFunction.lua'
		client_script 'esxBaseFunction.lua'
		```
		with 
		```
		server_script 'BaseFunction.lua'
		client_script 'BaseFunction.lua'
		```
		in end of `__resource.lua`

- Add this to your server.cfg:

```
add_principal identifier.steam:xxxxxxxxxx group.gangManager
add_ace resource.gang command.add_ace allow
start gang
```
change `xxxxxxxxxx` to your steam hex to access manage gangs 

- If you want change config you should modify `config.lua` file

- Restart your Fivem Server

- go in your server and use `/gangs` command (if not change from `config.lua`) to open admin menu

- in creat gang, dont forget add expire time and other configuration

- palyer can use `/gang` command to refresh gang data in client


## exports
you can use bellow exports in other client files

 | export	                      	| description                  			| usage 						| Example 																|
 |------------------------------	|---------------------------------------|-------------------------------|-----------------------------------------------------------------------|
 | isOwnGangVehicle                 | check is vehicle related Player Gang	| for lock or unlock cars door. If you use esx_carlock , you can download file from [here](https://forum.cfx.re/t/fivem-gang-system-script/2086523/227).	| local vehicle = GetVehiclePedIsIn(PlayerPedId()) exports['gang']:isOwnGangVehicle(vehicle)	|
 | getGangID					 	| Get Playr Gang ID						| Any Where You Want      		| exports['gang']:getGangID()											|
 | getGangGrade                     | Get Playr Gang Grade (0 for boss)		| Any Where You Want        	| exports['gang']:getGangGrade()										|
 | getGangName                    	| Get Playr Gang Name 					| in HUD or Any Where You Want	| exports['gang']:getGangName()											|
 | getGangGradeName                 | Get Playr Gang Grade Name 			| in HUD or Any Where You Want	| exports['gang']:getGangGradeName()									|


## Special thank
- [iTexZoz](https://github.com/iTexZoz/RageUI) for creat menu

### Thank you for contributing to the progress and well-being of the project 🖤


# Legal
### License
gang - gang script for Fivem

Copyright (C) 2020-2020 Erfan Ebrahimi

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.
