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

if (true) then {

	if ((vehicle _pl == _pl) ) exitWith  { _txt = localize "STR_RADAR_TRUCK_NOT_DRIVER" };
	if (_pl != driver (vehicle _pl) ) exitWith  { _txt = localize "STR_RADAR_TRUCK_NOT_DRIVER" };

	if (locked _veh) exitWith {
		(call SYG_randomRadioNoise) call SYG_receiveRadio;
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
				_txt = localize "STR_RADAR_MAST_ALREADY_LOADED";
			};
			// todo: remove msg "STR_RADAR_MAST_FAR_AWAY"
			_txt = localize "STR_RADAR_MAST_LOADED";
			["say_sound", _veh, call SYG_rustyMastSound] call XSendNetStartScriptClientAll;
			d_radar setPosASL [_asl select 0, _asl select 1, -50];
			d_radar setVectorUp [0,0,1];
			sleep 0.2;
			hint localize format["+++ LOAD: mast pos %1, vUp %2", getPosASL d_radar, vectorUp d_radar];
		};

		case "UNLOAD": {
			_asl = getPosASL d_radar;
			if ((_asl select 2) > 0 ) exitWith {
				// already unloaded into this vehicle, so change all menu items
				_txt = localize "STR_RADAR_MAST_ALREADY_UNLOADED";
			};
			_pos = _veh modelToWorld [0, -DIST_MAST_TO_INSTALL, 0];
			d_radar setPos [_pos select 0, _pos select 1];
			d_radar setVectorUp [0,0,1];
			["say_sound", d_radar, call SYG_rustyMastSound] call XSendNetStartScriptClientAll;
			hint localize format["+++ UNLOAD: mast pos %1, vUp %2", getPosASL d_radar, vectorUp d_radar];
		};

		// Install radio mast on terrain behind truck current position to truck.
		// Mast is already standing on the ground to be able to execute this command
		case "INSTALL": {
			// ++++++++++++++++++++++++++++++++++++++++
			// +      check conditions to install     +
			// ++++++++++++++++++++++++++++++++++++++++
// TODO: remove msg "STR_RADAR_MAST_FAR_AWAY";
			_mast_pos = getPos d_radar;
			if (surfaceIsWater _mast_pos) exitWith {
				[vehicle player, localize "STR_RADAR_MAST_IN_WATER"] call XfVehicleChat;
			};

			// Mast can't be installed on the base
			if ( _veh call SYG_pointNearBase ) exitWith {
				[vehicle player, localize "STR_RADAR_MAST_NEAR_BASE"] call XfVehicleChat;
			};

			// Mast in range, test it to be in good position (height ASL, slope) for the installation
			hint localize format["+++ mast (%1) pos : %2", if (_mast_loaded) then {"Loaded"} else {"UnLoaded"},_mast_pos];
			_slope = [_mast_pos, 3] call XfGetSlope;
			hint localize format["+++ INSTALL: slope(in 3 m.) = %1 ",_slope];
			if (_slope >= 0.2) exitWith {
				// "The mast cannot be installed at this position"
				( format[localize "Der Mast kann auf einer so unebenen Fläche nicht wirkenThe mast cannot act on such an uneven surface", DIST_MAST_TO_TRUCK, ceil _dist]) call XfGlobalChat;
			};

			// TODO: show animation of installing mast

			// measure height ASL
			_logic = "Logic" createVehicle [0,0,0];
			_logic setPos _mast_pos;
			_asl = getPosAsl _logic;
				deleteVehicle _logic;
			if ( (_pos select 2) < INSTALL_MIN_ALTITUDE ) exitWith {
				_txt = format[localize "STR_RADAR_MAST_TOO_LOW", INSTALL_MIN_ALTITUDE, ceil ((getPosAsl(_logic)) select 2)];
				["say_radio", call SYG_randomRadioNoise] call XSendNetStartScriptClientAll;
			};

			if ( ([d_radar, RADAR_POINT] call SYG_distance2D) > INSTALL_RADIUS) exitWith {
				_txt = localize "STR_RADAR_BAD_SIGNAL";
				["say_radio", call SYG_randomRadioNoise] call XSendNetStartScriptClientAll;
			};

			// complete the mission itself
			sideradio_status = 1; // finished
			publicVariable "sideradio_status";
			// TODO: play radio signal from "Mayak" radiostation
			["say_radio", call SYG_randomRadio] call XSendNetStartScriptClientAll;
		};
		default {hint localize format["--- radio_menu.sqf: Expected command '%1' not parsed, must be LOAD, UNLOAD, INSTALL", _cmd]};
	};
};

if (_txt != "") then { _txt call XfGlobalChat };

