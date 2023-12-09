/*
    x_missions\common\sideradar\radio_init.sqf, created at JUN 2022
    works only on client computers
	author: Sygsky, on #410 request by Rokse

	description: handles object/vehicles for radar-on-hills SM type on any vehicle (radar or truck) init on
		the client when conection
	1. Add SM radar and truck actions "Inspect", "Install", "Load"/"Unload".

    params: _veh

	changed:

	returns: nothing
*/

if (!X_Client) exitWith {hint localize "--- radio_init.sqf called not on client, exit" };

#include "sideradio_vars.sqf"

hint localize format[ "+++ radio_init.sqf: Client, _this = %1, d_radar %2",
	typeOf _this,
	if (alive d_radar) then {"alive"} else {"NOT alive"}
];

_veh = _this;
if (typeOf _veh  == RADAR_TYPE) exitWith { // Radar itself
	if (!alive _veh) exitWith {};
	_veh addAction[localize "STR_INSPECT","x_missions\common\sideradar\radio_inspect.sqf","INSPECT"]; // Inspect
	_veh addAction[localize "STR_CHECK", "x_missions\common\sideradar\radio_menu.sqf","CHECK"]; // Check
	_veh addAction[localize "STR_INSTALL", "x_missions\common\sideradar\radio_menu.sqf","INSTALL"]; // Install
	hint localize "+++ radio_init.sqf: add 3 actions to the radar";
};

if (_veh isKindOf "Truck" ) exitWith { // first truck, second is in reserve
	if (!alive _veh) exitWith {};
	_veh addAction[localize "STR_INSPECT","x_missions\common\sideradar\radio_inspect.sqf","INSPECT"]; // Inspect
	_veh addAction[localize    "STR_LOAD", "x_missions\common\sideradar\radio_menu.sqf","LOAD"]; // Load
	_veh addAction[localize  "STR_UNLOAD", "x_missions\common\sideradar\radio_menu.sqf","UNLOAD"]; // Unload
/* Don't need lower code as "killed" is event already assigned on server truck copy too
	if (!X_SPE) then {
		_veh addEventHandler ["killed", { ["remote_execute","[d_radar_truck, objNull] execVM ""x_missions\common\sideradar\truck_killed.sqf"""] call XSendNetStartScriptServer }]; // _this = [_killed, _killer];
		hint localize "+++ radio_init.sqf: add remote killed event to the server";
	};
*/
	hint localize "+++ radio_init.sqf: add 3 actions to the truck";
};
