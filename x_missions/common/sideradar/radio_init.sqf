/*
    x_missions\common\sideradar\radio_init.sqf, created at JUN 2022
    created 2022.06.01
	author: Sygsky, on #410 request by Rokse

	description: handles object/vehicles for radar-on-hills SM type on any vehicle (radar or one of two trucks) init on
		the client when conection
	1. Add the radio SM trucks actions "Inspect", "Install", "Load"/"Unload".
	2. Add "killed" event handling to the first truck only, second one not need this as its death leads to the failure of the mission itself.

    params: [ _veh, _id ]

	changed:

	returns: nothing
*/
private ["_ids"];
hint localize format["+++ radio_init.sqf: %1, _this = %2", if (X_Client) then {"Client"} else {"Server"},typeOf _this];

_veh = _this;
if (typeOf _veh  == "Land_radar") exitWith { // Radar itself
	if (alive _veh) then {
		_veh addAction[localize "STR_INSPECT","x_missions\common\sideradar\radio_inspect.sqf"]; // Inspect
		_veh addAction[localize "STR_INSTALL", "x_missions\common\sideradar\radio_menu.sqf","INSTALL"]; // Install
	};
};

_ids = [];
if (_veh isKindOf "Truck" ) exitWith { // first truck, second is in reserve
	if (!alive d_radar) exitWith{};
	if (!alive _veh) exitWith {};
	_veh addAction[localize "STR_INSPECT","x_missions\common\sideradar\radio_inspect.sqf"]; // Inspect
	_veh addAction[localize    "STR_LOAD", "x_missions\common\sideradar\radio_menu.sqf","LOAD"]; // Load
	_veh addAction[localize  "STR_UNLOAD", "x_missions\common\sideradar\radio_menu.sqf","UNLOAD"]; // Unload

	// ++++++++++++++++++++++++ KILLED EVENT ++++++++++++++++++++
	_veh addEventHandler ["killed", {
		private ["_veh","_asl","_pos","_vehs","_veh1"];
		_veh = _this select 0;
		if (!alive d_radar) exitWith {};
		_asl = getPosASL d_radar;
		if ((_asl select 2) < 0) then { // unload must if veh0 is killed
			_pos = _veh modelToWorld [0, -DIST_MAST_TO_INSTALL, 0];
			d_radar setPos _pos;
			["say_sound", _veh, call SYG_rustyMastSound] call XSendNetStartScriptClientAll;
		};
		// now prepare next alive truck for operation
		_vehs = sideradio_vehs;
		_veh = _vehs select 1;
		if (alive _veh) then {
			_veh lock false; // unlock 2nd vehicle if alive
			// "There's only one truck left. Take care of it, it's our last chance to complete the mission!"
			["msg_to_user", "",  [ ["STR_RADAR_TRUCK_UNLOCK"]], 0, 2, false, "losing_patience" ] call XSendNetStartScriptClientAll;
		} else {
			// "Last track destroyed, task failed!"
			["msg_to_user", "",  [ ["STR_RADAR_TRUCK_FAILED"]], 0, 2, false, "losing_patience" ] call XSendNetStartScriptClientAll;
			d_radar setDamage 1.1;
			[d_radar, _veh] execVM "x_missions\common\sideradar\radio_delete.sqf";
		};
	}];

};
player groupChat format["--- radio_init.sqf: expected vehicle must by Truck or Land_radar. Found %1, exit!!!", typeOf _veh];