/*
    x_missions\common\sideradar\radio_init.sqf, created at JUN 2022
    created 2022.06.01
	author: Sygsky, on #410 request by Rokse

	description: handles object/vehicles for radar-on-hills SM type on any vehicle (radar or one of two trucks) init on
		the client when conection
	1. Add the radio SM trucks actions "Inspect", "Install", "Load"/"Unload".
	2. Add "killed" event handling to the first truck only, second one not need this as its death leads to the failure of the mission itself.

    params: _veh

	changed:

	returns: nothing
*/

#include "sideradio_vars.sqf"

hint localize format["+++ radio_init.sqf: %1, _this = %2, d_radar %3", if (X_Client) then {"Client"} else {"Server"},typeOf _this,
	if (alive d_radar) then {"alive"} else {"NOT alive"}];

_veh = _this;
if (typeOf _veh  == RADAR_TYPE) exitWith { // Radar itself
	if (alive _veh) then {
		_veh addAction[localize "STR_INSPECT","x_missions\common\sideradar\radio_inspect.sqf"]; // Inspect
		_veh addAction[localize "STR_CHECK", "x_missions\common\sideradar\radio_menu.sqf","CHECK"]; // Check
		_veh addAction[localize "STR_INSTALL", "x_missions\common\sideradar\radio_menu.sqf","INSTALL"]; // Install
	};
};

if (_veh isKindOf "Truck" ) exitWith { // first truck, second is in reserve
	if (!alive d_radar) exitWith{};
	if (!alive _veh) exitWith {};
	_veh addAction[localize "STR_INSPECT","x_missions\common\sideradar\radio_inspect.sqf"]; // Inspect
	_veh addAction[localize    "STR_LOAD", "x_missions\common\sideradar\radio_menu.sqf","LOAD"]; // Load
	_veh addAction[localize  "STR_UNLOAD", "x_missions\common\sideradar\radio_menu.sqf","UNLOAD"]; // Unload
	hint localize "+++ radio_init.sqf: add 3 actions";
};
player groupChat format["--- radio_init.sqf: expected vehicle must by Truck or Land_radar. Found %1, exit!!!", typeOf _veh];