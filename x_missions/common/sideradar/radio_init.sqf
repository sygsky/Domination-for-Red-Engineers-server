/*
    x_missions\common\sideradar\radio_init.sqf, created at JUN 2022
    created 2022.06.01
	author: Sygsky, on #410 request by Rokse

	description: handles object/vehicles for radar-on-hills SM type on the vehicle (radar or one of two trucks) init
	1. Add the radio SM trucks actions "Inspect", "Install", "Load"/"Unload".
	2. Add "killed" event handling to the first truck only, second one not need this as its death leads to the failure of the mission itself.

    params: [ _veh, _id ]

	changed:

	returns: nothing
*/
private ["_ids"];
hint localize format["+++ radio_init.sqf: %1, _this = %2", if (X_Client) then {"Client"} else {"Server"},typeOf _this];

_remove_ids = {
	private ["_veh","_last","_id","_i","_ids"];
	_veh = _this;
	_ids = _veh getVariable "IDS"; // get all id from menu
	_last = (count _ids) - 1;
	for "_i" from _last to 0 do {
		_id = _ids select _i;
		_veh removeAction _id;
	};
	_ids
};

// _veh call _unload_menu;
_unload_menu = {
	private ["_ids","_veh"];
	_veh = _this;
	_ids = _veh call _remove_ids;
	_ids resize 0;
	_ids set [0, _veh addAction[localize "STR_INSPECT", "x_missions\common\sideradar\radio_inspect.sqf"]]; // Inspect
	_ids set [1, _veh addAction[localize  "STR_UNLOAD", "x_missions\common\sideradar\radio_menu.sqf","UNLOAD"]]; // load
//	_veh setVariable ["IDS", _ids];
};

// _veh call _unload_menu;
_load_menu = {
	private ["_ids","_veh"];
	_veh = _this;
	_ids = _veh call _remove_ids;
	_ids resize 0;
	_ids set [0, _veh addAction[localize "STR_INSPECT", "x_missions\common\sideradar\radio_inspect.sqf"]]; // Inspect
	_ids set [1, _veh addAction[localize    "STR_LOAD", "x_missions\common\sideradar\radio_menu.sqf","LOAD"]]; // load
	_ids set [2, _veh addAction[localize "STR_INSTALL", "x_missions\common\sideradar\radio_menu.sqf","INSTALL"]]; // load
//	_veh setVariable ["IDS", _ids];
};

_veh = _this;
if (typeOf _veh  == "Land_radar") exitWith { // Radar itself
	if (alive _veh) then {
		_ids = [_veh addAction[localize "STR_INSPECT","x_missions\common\sideradar\radio_inspect.sqf",0]]; // Inspect
		_veh setVariable ["IDS", _ids];
	};
};

_ids = [];
if (_veh isKindOf "Truck" ) exitWith { // first truck, second is in reserve
	if (!alive d_radar) exitWith{};
	if (!alive _veh) exitWith {};
	if ( locked _veh ) exitWith {}; // vehicle locked and can't be used directly now

	_asl = getPosAsl d_radar;
	if ((_asl select 2) < 0 ) then {
		// radar is loaded to this truck
		_veh call _unload_menu;
	} else  {
		// radar is not loaded in this truck
		_veh call _load_menu;
	};
//	_veh setVariable ["IDS", _ids];

	// ++++++++++++++++++++++++ KILLED EVENT ++++++++++++++++++++
	_veh addEventHandler ["killed",{
		private [""];
		_veh = _this select 0;
		if (!alive d_radar) exitWith {};
		_asl = getPosASL _veh;
		if ((_asl select 2) < 0) then {
			_pos = _veh modelToWorld [0, -DIST_MAST_TO_INSTALL, 0];
			d_radar setPos _pos;
		};
		_vehs = sideradio_vehs;
		_veh1 = _vehs select 1;
		if (alive _veh1) then {
			_veh1 lock false;
			_vah call _load_menu;
			// "There's only one truck left. Take care of it, it's our last chance to complete the mission!"
			["msg_to_user", "",  [ ["STR_RADAR_TRUCK_UNLOCK"]], 0, 2, false, "losing_patience" ] call XSendNetStartScriptClientAll;
		} else {
			// "Last track destroyed, task failed!"
			["msg_to_user", "",  [ ["STR_RADAR_TRUCK_FAILED"]], 0, 2, false, "losing_patience" ] call XSendNetStartScriptClientAll;
			d_radar setDamage 1.1;
			[d_radar, _veh] execVM "x_missions\common\sideradar\radio_delete.sqf";
		};
	}]; // unlock 2nd vehicle if alive

};
player groupChat format["--- radio_init.sqf: expected vehicle must by Truck of Land_radar. Found %3, exit ", typeOf _veh];