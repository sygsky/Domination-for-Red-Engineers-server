/*
    x_missions\common\sideradar\radio_menu.sqf
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

private ["_ids"];

#include "sideradio_vars.sqf"

_cmd = _this select 3; // must be "LOAD", "UNLOAD", "INSTALL"
_veh = _this select 0;
_pl  = _this select 1;
_txt = "";


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
if (true) then {

	if ((vehicle _pl == _pl) ) exitWith  { _txt = "STR_RADAR_TRUCK_NOT_DRIVER" };
	if (_pl != driver (vehicle _pl) ) exitWith  { _txt = "STR_RADAR_TRUCK_NOT_DRIVER" };

	if (locked _veh) exitWith {
		_veh say "radio_0";
		_txt = "STR_RADAR_NO";
	};

	if (!alive d_radar) exitWith {
		_txt = "STR_RADAR_MAST_DEAD";
		_ids = d_radar call _remove_ids; // remove all menus
	};

	switch (_cmd) do {

		case "LOAD": {
			_asl = getPosASL d_radar;
			if ((_asl select 2) < 0 ) exitWith { // already loaded into this vehicle, so change all menu items
				_txt = "STR_RADAR_MAST_ALREADY_LOADED";
				_ids = d_radar call _remove_ids;
				_ids resize 0;
				_ids set [0, _veh addAction[localize "STR_INSPECT", "x_missions\common\sideradar\radio_inspect.sqf"]]; // Inspect
				_ids set [1, _veh addAction[localize  "STR_UNLOAD", "x_missions\common\sideradar\radio_menu.sqf","UNLOAD"]]; // load
			};
			_asl resize 2;
			if (([_truck, d_radar] call SYG_distance2D) > DIST_MAST_TO_TRUCK) exitWith {
				_txt = "STR_RADAR_MAST_NOT_FOUND";
			};
			_txt = "STR_RADAR_MAST_LOADED";
			_radar setPosASL [_asl select 0, _asl select 1, -50];
		};

		case "UNLOAD": {
			_asl = getPosASL d_radar;
			if ((_asl select 2) > 0 ) exitWith {
				// already unloaded into this vehicle, so change all menu items
				_txt = "STR_RADAR_MAST_ALREADY_UNLOADED";
				_ids = d_radar call _remove_ids;
				_ids resize 0;
				_ids set [0, _veh addAction[localize "STR_INSPECT","x_missions\common\sideradar\radio_inspect.sqf"]]; // Inspect
				_ids set [1, _veh addAction[localize "STR_LOAD","x_missions\common\sideradar\radio_menu.sqf","LOAD"]]; // load
				_ids set [1, _veh addAction[localize "STR_INSTALL","x_missions\common\sideradar\radio_menu.sqf","INSTALLD"]]; // Install
				// STR_INSTALL
			};


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
				_dist = [_radar, _truck] call SYG_distance2D;
				_exit = _dist > DIST_MAST_TO_TRUCK;
				if ( _exit ) exitWith { // too far from truck
					// "Mast further than %1 meters (%2)"
					( format[localize "STR_RADAR_MAST_FAR_AWAY", DIST_MAST_TO_TRUCK, ceil _dist]) call XfGlobalChat;
				};
			};
			if (_exit) exitWith {};

			// Mast can't be installed on the base
			if ( _truck call SYG_pointNearBase ) exitWith {
				[vehicle player, localize "STR_RADAR_MAST_NEAR_BASE"] call XfVehicleChat;
			};

			_mast_pos = if (_mast_loaded) then { _truck modelToWorld [0, -DIST_MAST_TO_INSTALL,0] }
						else {getPos d_radar};

			// Mast in range, test it to be in good position (height ASL, slope) for the installation
			_slope = [_mast_pos, 3] call XfGetSlope;
			if (_slope >= 0.3) exitWith {
				// "The mast cannot be installed at this position"
				( format[localize "STR_RADAR_MAST_BAD_SLOPE", DIST_MAST_TO_TRUCK, ceil _dist]) call XfGlobalChat;
			};

			// mast may be installed here!
			if (_mast_loaded) then { // set mast to the terrain as it is still not unloaded
				d_radar setPos _mast_pos;
			};
			_logic = "Logic" createVehicle [0,0,0];
			_logic setPos _mast_pos;
			if (((getPos(_logic)) select 2) < INSTALL_MIN_ALTITUDE) exitWith {
				_txt = "STR_RADAR_MAST_TOO_LOW";
			};
			deleteVehicle _logic;

			// complete the mission itself
			sideradio_status = 1; // finished
			publicVariable "sideradio_status";

		};
		default {hint localize format["--- radio_menu.sqf: Expected command '%1' not parsed, must be LOAD, UNLOAD, INSTALL", _cmd]};
	};

};

if (_txt != "") then { (localize _txt) call XfGlobalChat };

