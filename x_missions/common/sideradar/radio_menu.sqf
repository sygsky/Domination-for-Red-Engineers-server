/*
    x_missions\common\sideradar\radio_menu.sqf, created at JUN 2022
    created 2022.06.04
	author: Sygsky, on #410 request by Rokse
	description: Execute load/unload/install radiomast operation

	Parameters array passed to the script upon activation in _this  variable is: [target, caller, ID, arguments]
    target (_this select 0): Object  - the object which the action is assigned to
    caller (_this select 1): Object  - the unit that activated the action
    ID (_this select 2): Number  - ID of the activated action (same as ID returned by addAction)
    arguments (_this select 3): Anything  - arguments given to the script if you are using the extended syntax

	changed:
	returns: nothing
*/

#include "sideradio_vars.sqf"

_cmd = _this select 3; // must be "LOAD", "UNLOAD", "INSTALL"
_veh = _this select 0;
_pl  = _this select 1;
_txt = "";

_remove_ids = {
	private ["_veh","_ids","_x"];
	_veh = _this;
	_ids = _veh getVariable "IDS"; // get all id from menu
	if (isNil "_ids") exitWith {hint localize format["--- _remove_ids: ""IDS"" is nil"]};
	hint localize format["+++ _remove_ids: remove actions %1 from %2", _ids, typeOf _veh ];
	{
		_veh removeAction _x;
	} forEach _ids;
	sleep 0.1;
	_ids
};

// _veh call _unload_menu;
_unload_menu = {
	private ["_ids","_veh"];
	_veh = _this;
	_ids = _veh call _remove_ids;
	if (isNil "_ids") then {
		_ids = [];
	} else { _ids resize 0 };
	_ids set [0, _veh addAction[localize "STR_INSPECT", "x_missions\common\sideradar\radio_inspect.sqf"]]; // Inspect
	_ids set [1, _veh addAction[localize  "STR_UNLOAD", "x_missions\common\sideradar\radio_menu.sqf","UNLOAD"]]; // Load
	_veh setVariable ["IDS", _ids];
	hint localize format["+++ set UNLOAD menu: add actions %1 to %2", _ids, typeOf _veh ];
//	_veh setVariable ["IDS", _ids];
};

// _veh call _unload_menu;
_load_menu = {
	private ["_ids","_veh"];
	_veh = _this;
	_ids = _veh call _remove_ids;
	if (isNil "_ids") then {
		_ids = [];
	} else { _ids resize 0 };
	_ids set [0, _veh addAction[localize "STR_INSPECT", "x_missions\common\sideradar\radio_inspect.sqf"]]; // Inspect
	_ids set [1, _veh addAction[localize    "STR_LOAD", "x_missions\common\sideradar\radio_menu.sqf","LOAD"]]; // Load
	_ids set [2, _veh addAction[localize "STR_INSTALL", "x_missions\common\sideradar\radio_menu.sqf","INSTALL"]]; // Install
	_veh setVariable ["IDS", _ids];
	hint localize format["+++ set LOAD menu: add actions %1 to %2", _ids, typeOf _veh ];
//	_veh setVariable ["IDS", _ids];
};

if (true) then {

	if ((vehicle _pl == _pl) ) exitWith  { _txt = localize "STR_RADAR_TRUCK_NOT_DRIVER" };
	if (_pl != driver (vehicle _pl) ) exitWith  { _txt = localize "STR_RADAR_TRUCK_NOT_DRIVER" };

	if (locked _veh) exitWith {
		"radio_0" call SYG_receiveRadio;
		_txt = localize "STR_RADAR_NO";
	};

	if (!alive d_radar) exitWith {
		_txt = localize "STR_RADAR_MAST_DEAD";
		_ids = d_radar call _remove_ids; // remove all menus
	};

	switch (_cmd) do {

		case "LOAD": {
			_asl = getPosASL d_radar;
			if ((_asl select 2) < 0 ) exitWith { // already loaded into this vehicle, so change all menu items
				_veh call _unload_menu;
				_txt = localize "STR_RADAR_MAST_ALREADY_LOADED";
			};
			_dist = [_veh, d_radar] call SYG_distance2D;
			if (_dist > DIST_MAST_TO_TRUCK) exitWith {
				_txt = format[localize "STR_RADAR_MAST_FAR_AWAY", DIST_MAST_TO_TRUCK, ceil _dist];
			};
			_veh call _unload_menu;
			_txt = localize "STR_RADAR_MAST_LOADED";
			["say_sound", _veh, call SYG_rustyMastSound] call XSendNetStartScriptClientAll;
			d_radar setPosASL [_asl select 0, _asl select 1, -50];
			d_radar setVectorUp [0,0,1];
			sleep 0.2;
			hint localize format["+++ LOAD: mast pos %1, vUp %2", getPosASL d_radar, vectorUp d_radar];
		};

		case "UNLOAD": {
			_veh call _load_menu;
			_asl = getPosASL d_radar;
			if ((_asl select 2) > 0 ) exitWith {
				// already unloaded into this vehicle, so change all menu items
				_txt = localize "STR_RADAR_MAST_ALREADY_UNLOADED";
			};
			d_radar setPos [_asl select 0, _asl select 1];
			d_radar setVectorUp [0,0,1];
			["say_sound", _veh, call SYG_rustyMastSound] call XSendNetStartScriptClientAll;
			sleep 0.2;
			hint localize format["+++ UNLOAD: mast pos %1, vUp %2", getPosASL d_radar, vectorUp d_radar];
		};

		// Install radio mast on terrain behind truck current position to truck. Mast
		case "INSTALL": {
			_asl = getPosASL d_radar;
			_mast_loaded = (_asl select 2) < 0;

			// ++++++++++++++++++++++++++++++++++++++++
			// +      check conditions to install     +
			// ++++++++++++++++++++++++++++++++++++++++

			_exit = false;
			if ( !_mast_loaded ) then {
				// test if mast is near truck
				_dist = [d_radar, _veh] call SYG_distance2D;
				_exit = _dist > DIST_MAST_TO_TRUCK;
				if ( _exit ) exitWith { // too far from truck
					// "Mast further than %1 meters (%2)"
					( format[localize "STR_RADAR_MAST_FAR_AWAY", DIST_MAST_TO_TRUCK, ceil _dist]) call XfGlobalChat;
				};
			};
			if (_exit) exitWith {};

			// Mast can't be installed on the base
			if ( _veh call SYG_pointNearBase ) exitWith {
				[vehicle player, localize "STR_RADAR_MAST_NEAR_BASE"] call XfVehicleChat;
			};

			_mast_pos = if (_mast_loaded) then { _veh modelToWorld [0, -DIST_MAST_TO_INSTALL,0] }
						else {getPos d_radar};

			// Mast in range, test it to be in good position (height ASL, slope) for the installation
			hint localize format["+++ mast (%1) pos : %2", if (_mast_loaded) then {"Loaded"} else {"UnLoaded"},_mast_pos];
			_slope = [_mast_pos, 3] call XfGetSlope;
			hint localize format["+++ INSTALL: slope(3) = %1 ",_slope];
			if (_slope >= 0.3) exitWith {
				// "The mast cannot be installed at this position"
				( format[localize "STR_RADAR_MAST_BAD_SLOPE", DIST_MAST_TO_TRUCK, ceil _dist]) call XfGlobalChat;
			};

			// mast may be installed here!
			if (_mast_loaded) then { // set mast to the terrain (ubload) as it is still not unloaded
				d_radar setPos _mast_pos;
				["say_sound", _veh, call SYG_rustyMastSound] call XSendNetStartScriptClientAll;
			};
			// measure height ASL
			_logic = "Logic" createVehicle [0,0,0];
			_logic setPos _mast_pos;
			if (((getPosAsl(_logic)) select 2) < INSTALL_MIN_ALTITUDE) exitWith {
				_txt = format[localize "STR_RADAR_MAST_TOO_LOW", INSTALL_MIN_ALTITUDE, ceil ((getPosAsl(_logic)) select 2)];
				deleteVehicle _logic;
			};
			deleteVehicle _logic;
			// complete the mission itself
			sideradio_status = 1; // finished
			publicVariable "sideradio_status";
			_veh call _remove_ids;
			_veh addAction[localize "STR_INSPECT", "x_missions\common\sideradar\radio_inspect.sqf"]; // Last option - "Inspect"
		};
		default {hint localize format["--- radio_menu.sqf: Expected command '%1' not parsed, must be LOAD, UNLOAD, INSTALL", _cmd]};
	};
};

if (_txt != "") then { _txt call XfGlobalChat };

