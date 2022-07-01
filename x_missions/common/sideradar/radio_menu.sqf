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

	if (sideradio_status != 0) exitWith {
		hint localize format["+++ radio_menu.sqf: sideradio_status %1, veh %2 ", sideradio_status, typeOf _veh];
		_veh removeAction (_this select 2); // remove this action
		(call SYG_randomRadioNoise) call SYG_receiveRadio;
		if (sideradio_status > 0) exitWith {_txt = localize "STR_RADAR_SUCCESSFUL"};
		if (sideradio_status < 0) exitWith {_txt = localize "STR_RADAR_FAILED"};
	};
	if (((vehicle _pl == _pl) || (_pl != driver (vehicle _pl))) && (_cmd in ["LOAD","UNLOAD"])) exitWith  { _txt = localize "STR_RADAR_TRUCK_NOT_DRIVER" };

	if (!alive _veh) exitWith {
		hint localize  format[ "+++ radio_menu.sqf: sideradio_status %1, veh %2 killed, remove action %3", sideradio_status, typeOf _veh, _this select 2 ];
		if (_veh isKindOf "Truck") then {
			_txt = localize "STR_RADAR_TRUCK_KILLED";
		} else {_txt = localize "STR_RADAR_MAST_DEAD";};
		_veh removeAction (_this select 2); // remove this action
	};
	if (locked _veh) exitWith {
		playSound "losing_patience";
		_txt = localize "STR_RADAR_NO";
	};

	if (!alive d_radar) exitWith {
		playSound "losing_patience";
		_txt = localize "STR_RADAR_MAST_DEAD";
	};

	switch (_cmd) do {

		case "LOAD": {
			_asl = getPosASL d_radar;
			if ((_asl select 2) < 0 ) exitWith { // already loaded into this vehicle, so change all menu items
				playSound "losing_patience";
				_txt = localize "STR_RADAR_MAST_ALREADY_LOADED";
			};
			if ( round (speed _veh) > 0 ) exitWith {
				playSound "losing_patience";
				_txt = localize "STR_RADAR_TRUCK_MOVING";
			};
			_dist = [d_radar, player] call SYG_distance2D;
			if ( _dist > DIST_MAST_TO_TRUCK ) exitWith {
				_txt = format [localize "STR_RADAR_MAST_FAR_AWAY", DIST_MAST_TO_TRUCK, ceil _dist ];
			};
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
				playSound "losing_patience";
				_txt = localize "STR_RADAR_MAST_ALREADY_UNLOADED";
			};
			_pos = _veh modelToWorld [0, -DIST_MAST_TO_INSTALL, 0];
			d_radar setPos [_pos select 0, _pos select 1];
			d_radar setVectorUp [0,0,1];
			["say_sound", d_radar, call SYG_rustyMastSound] call XSendNetStartScriptClientAll;
			hint localize format["+++ UNLOAD: mast pos %1, vUp %2", getPosASL d_radar, vectorUp d_radar];
		};

		// checks the radio-mast position
		case "CHECK": {
			_mast_pos = getPos d_radar;
			_bad = false;
			_str1 = if (surfaceIsWater _mast_pos) then { _bad = true;  "STR_RADAR_IN_WATER" } else {"STR_RADAR_ON_LAND"};
			_str2 = if ( _veh call SYG_pointNearBase ) then { _bad = true; "STR_RADAR_IN_BASE" } else {"STR_RADAR_OUT_BASE"};
			_slope = [_mast_pos, 3] call XfGetSlope;
			_str3 = if (_slope > MAX_SLOPE) then {_bad = true; "STR_RADAR_ON_SL	OPE"} else {"STR_RADAR_ON_HORIZONTAL"};
			hint localize format["+++ CHECK: slope(in 3 m.) = %1 ",_slope];
			_ht   = _mast_pos call SYG_getLandASL;
			_str4 = if ( _ht < INSTALL_MIN_ALTITUDE ) then { _bad = true; "STR_RADAR_MAST_TOO_LOW" } else {"STR_RADAR_MAST_HIGH"};

			_str = if (_bad) then {"STR_RADAR_NOT_READY"} else {"STR_RADAR_READY"};
			_txt = format[localize _str, localize _str1, localize _str2, localize _str3, format[localize _str4, INSTALL_MIN_ALTITUDE, ceil _ht]];
		};
		// Install radio mast on terrain behind truck current position to truck.
		// Mast must be standing on the ground to be able to execute this command
		case "INSTALL": {
			// ++++++++++++++++++++++++++++++++++++++++
			// +      check conditions to install     +
			// ++++++++++++++++++++++++++++++++++++++++
			_mast_pos = getPos d_radar;
			if (surfaceIsWater _mast_pos) exitWith {
				playSound "losing_patience";
				_txt = localize "STR_RADAR_MAST_IN_WATER";
			};

			// Mast can't be installed on the base
			if ( _veh call SYG_pointNearBase ) exitWith {
				playSound "losing_patience";
				_txt = localize "STR_RADAR_MAST_NEAR_BASE";
			};

			// Mast is out of base, test it to be in good position (height ASL, slope) for the installation
			_slope = [_mast_pos, 3] call XfGetSlope;
			hint localize format["+++ INSTALL: slope(in 3 m.) = %1 ",_slope];
			if (_slope >= MAX_SLOPE) exitWith {
				// "The mast cannot be installed at this position"
				playSound "losing_patience";
				_txt = localize "STR_RADAR_MAST_BAD_SLOPE";
			};

			player playMove "AinvPknlMstpSlayWrflDnon_medic";
			sleep 0.5;
			["say_sound", d_radar, "repair_short"] call XSendNetStartScriptClientAll;
            sleep 2.5;
            waitUntil {animationState player != "AinvPknlMstpSlayWrflDnon_medic"};
			sleep 0.25;
			playSound "button_1"; // click this button

			// measure ASL height of the mast;
			_asl = _mast_pos call SYG_getLandASL;
			if ( _asl < INSTALL_MIN_ALTITUDE ) exitWith {
				_txt = format[localize "STR_RADAR_MAST_TOO_LOW", INSTALL_MIN_ALTITUDE, ceil _asl];
				["say_radio", call SYG_randomRadioNoise] call XSendNetStartScriptClientAll;
			};

			if ( ([d_radar, RADAR_POINT] call SYG_distance2D) > INSTALL_RADIUS) exitWith {
				_txt = localize "STR_RADAR_BAD_SIGNAL";
				["say_radio", call SYG_randomRadioNoise] call XSendNetStartScriptClientAll;
			};

			// complete the mission itself
			sideradio_status = 1; // finished
			publicVariable "sideradio_status";
			// play random radio signal (including from "Mayak" radiostation etc)
			["say_radio", call SYG_randomRadio] call XSendNetStartScriptClientAll;
			_txt = localize "STR_RADAR_SUCCESSFUL";
		};
		default {hint localize format["--- radio_menu.sqf: Expected command '%1' not parsed, must be LOAD, UNLOAD, INSTALL", _cmd]};
	};
};

if (_txt != "") then { _txt call XfGlobalChat };

