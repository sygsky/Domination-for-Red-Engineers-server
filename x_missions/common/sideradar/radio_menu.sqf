/*
    x_missions\common\sideradar\radio_menu.sqf, created at JUN 2022
    created 2022.06.04
	author: Sygsky, on #410 request by Rokse
	description: Execute inspect/check/install on mast and inspect/load/unload on truck operation

	Parameters array passed to the script upon activation in _this  variable is: [target, caller, ID, arguments]
    target (_this select 0): Object  - the object which the action is assigned to
    caller (_this select 1): Object  - the unit that activated the action
    ID (_this select 2): Number  - ID of the activated action (same as ID returned by addAction)
    arguments (_this select 3): Anything  - arguments given to the script if you are using the extended syntax

	changed:
	returns: nothing
*/

#include "sideradio_vars.sqf"

// try to change radar detected status
_set_detected = {
	private ["_detected","_veh"];
	_veh = _this;
	_detected = _veh getVariable "DETECTED";
	if (isNil "_detected") exitWith {
		_veh setVariable ["DETECTED", true];
		// copy detected status to the server
		if (_veh isKindOf "Truck") then {
			["remote_execute", "d_radar_truck setVariable[""DETECTED"", true];"] call XSendNetStartScriptServer;
		} else {
			["remote_execute", "d_radar setVariable[""DETECTED"", true];"] call XSendNetStartScriptServer;
		};
		true
	};
	false
};

_cmd = _this select 3; // must be "LOAD", "UNLOAD", "INSTALL", "CHECK"
_veh = _this select 0;
_pl  = _this select 1;
_txt = "";
_send_was_at_sm = false;
_locked = false;
_truck = _veh isKindOf "Truck";

hint localize format["+++ radio_menu.sqf: sideradio_status %1, veh %2, truck = %3 ", sideradio_status, typeOf _veh, _truck];

if (_truck) then { // check truck for detection
	if (locked _veh) then {
		_veh lock false;
		_locked = true;
		_veh call _set_detected;
	};
} else { // check radar for detection
	if (([0,0,1] distance (vectorUp d_radar )) > 0.05) then { d_radar call _set_detected; }; // if angle between radar and vertical is > 3 degrees
};

if (true) then {
	//
	// is vehicle alive or not?
	//
	if (!alive _veh) exitWith {
		// "This truck isn't going anywhere anymore. Maybe there's another one somewhere?"
		_txt = if (_truck) then { "STR_RADAR_TRUCK_KILLED" } else {"STR_RADAR_MAST_DEAD"}; // "Radio mast destroyed"
		_veh removeAction (_this select 2); // remove this action
	};

	// vehicle is alive and mission completed
	if (sideradio_status == 2) exitWith {
//		don't remove action as it can be used next time if radio mast again killed
//		_veh removeAction (_this select 2); // remove this action

		if (_truck) then {
			{ _x action ["Eject", _veh] } forEach (crew _x);
			_txt = localize "STR_RADAR_TRUCK_NOT_NEEDED"; // "The mast is installed and working"
		} else {
			(call SYG_randomRadioNoise) call SYG_receiveRadio;
			_txt = localize "STR_RADAR_SUCCESSFUL"; // "The mast is installed and working"
		};

	};

	if ( _truck && ( (_pl != driver (vehicle _pl)) && (_cmd in ["LOAD","UNLOAD"]) ) ) exitWith  {
		// LOAD and UNLOAD must be oredered only by driver
		_txt = localize "STR_RADAR_TRUCK_NOT_DRIVER" // "You are not driver"
	};

	switch (_cmd) do {
		case "INSPECT": { // TODO: remove as not used anywhere
			//
			// Truck
			//
			if ( _truck ) exitWith {
				if ( _locked ) exitWith {	_txt = localize ("STR_RADAR_TRUCK_LOCKED_NUM"  call SYG_getRandomText ) }; // "A truck adapted to carry radio mast. You're in luck!"
				// not locked, check mast status
				if ( alive d_radar ) exitWith {
					if ( ((getPosASL d_radar) select 2)  < 0 ) exitWith { _txt = localize "STR_RADAR_TRUCK_LOADED" }; // "The truck for transporting a radio mast, mast is loaded"
					_txt = localize format["STR_RADAR_TRUCK_NOT_LOADED", d_radar call SYG_nearestLocationName ]; // "Active truck for transporting a radio mast, which is  near ""%1"""
				};
			} else { // radio-relay mast
				_txt = localize "STR_RADAR_MAST_UNLOADED"; // "Rusty radio mast, what junkyard did you find it in?"
			};
		};

		case "LOAD": { // truck command
			if (!alive d_radar) exitWith {
				playSound "losing_patience";
				_txt = localize "STR_RADAR_MAST_DEAD";
			};
			_asl = getPosASL d_radar;
			if ((_asl select 2) < 0 ) exitWith { // already loaded into this vehicle, so change all menu items
				playSound "losing_patience";
				_txt = localize "STR_RADAR_MAST_ALREADY_LOADED";
			};
			if ( round (speed _veh) > 0.5 ) exitWith {
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
			_send_was_at_sm = (_veh distance RADAR_INSTALL_POINT) < INSTALL_RADIUS;
		};

		case "UNLOAD": { // truck command
			if (!alive d_radar) exitWith {
				playSound "losing_patience";
				_txt = localize "STR_RADAR_MAST_DEAD";
			};
			_asl = getPosASL d_radar;
			if ((_asl select 2) > 0 ) exitWith {
				// already unloaded into this vehicle, so change all menu items
				playSound "losing_patience";
				_txt = localize "STR_RADAR_MAST_ALREADY_UNLOADED";
			};
			if ( round (speed _veh) > 0.5 ) exitWith {
				playSound "losing_patience";
				_txt = localize "STR_RADAR_TRUCK_MOVING";
			};
			_pos = _veh modelToWorld [0, -DIST_MAST_TO_INSTALL, 0];
			d_radar setPos [_pos select 0, _pos select 1];
			d_radar setVectorUp [0,0,1];
			["say_sound", d_radar, call SYG_rustyMastSound] call XSendNetStartScriptClientAll;
			hint localize format["+++ UNLOAD: mast pos %1, vUp %2", getPosASL d_radar, vectorUp d_radar];
			_send_was_at_sm = (_veh distance RADAR_INSTALL_POINT) < INSTALL_RADIUS;
		};

		// checks the radio-mast position
		case "CHECK": { // radar command
			if (sideradio_status == 1) exitWith { _txt = localize "STR_RADAR_TRUCK_MAST_INSTALLED" }; // "The mast is installed and working. It only remains to bring the truck to the PC GRU."
			if (sideradio_status == 2) exitWith { _txt = localize "STR_RADAR_MAST_INSTALLED" }; // "Installed radio repeater mast. The motherland will hear us!"
			_mast_pos = getPos d_radar;
			_bad = false;
			_str1 = if (surfaceIsWater _mast_pos) then { _bad = true;  "STR_RADAR_IN_WATER" } else {"STR_RADAR_ON_LAND"};
			_str2 = if ( _veh call SYG_pointNearBase ) then { _bad = true; "STR_RADAR_IN_BASE" } else {"STR_RADAR_OUT_BASE"};
			_slope = [_mast_pos, 3] call XfGetSlope;
			hint localize format["+++ CHECK: slope(in 3 m.) = %1 ",_slope];
			_str3 = if (_slope > MAX_SLOPE) then {
				_bad = true;
				"STR_RADAR_ON_SLOPE"
			} else {
				"STR_RADAR_ON_HORIZONTAL"
			};
			_ht   = _mast_pos call SYG_getLandASL;
			_str4 = if ( _ht < INSTALL_MIN_ALTITUDE ) then { _bad = true; "STR_RADAR_MAST_TOO_LOW" } else {"STR_RADAR_MAST_HIGH"};

			_str = if (_bad) then {"STR_RADAR_NOT_READY"} else {"STR_RADAR_READY"};
			_txt = format[localize _str, localize _str1, localize _str2,
				format[localize _str3, round(_slope*100)],
				format[localize _str4, INSTALL_MIN_ALTITUDE, round _ht]
			];
			_send_was_at_sm = (_veh distance RADAR_INSTALL_POINT) < INSTALL_RADIUS;
		};
		// Install radio mast on terrain behind truck current position to truck.
		// Mast must be standing on the ground to be able to execute this command
		case "INSTALL": { // // radar command
			if (sideradio_status == 1) exitWith { _txt = localize "STR_RADAR_TRUCK_MAST_INSTALLED" }; // "The mast is installed and working. It only remains to bring the truck to the PC GRU."
			if (sideradio_status == 2) exitWith { _txt = localize "STR_RADAR_MAST_INSTALLED" }; // "Installed radio repeater mast. The motherland will hear us!"
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

			if ( ([d_radar, RADAR_INSTALL_POINT] call SYG_distance2D) > INSTALL_RADIUS) exitWith {
				_txt = localize "STR_RADAR_BAD_SIGNAL";
				["say_radio", call SYG_randomRadioNoise] call XSendNetStartScriptClientAll;
			};

			// complete the mission itself
			sideradio_status = 1; // installation done
			publicVariable "sideradio_status";
			// play random radio signal (including from "Mayak" radiostation etc)
			[ "say_radio", call SYG_randomRadio, [ "msg_to_user","", [["STR_RADAR_TRUCK_MAST_INSTALLED"]] ] ] call XSendNetStartScriptClientAll;
			_send_was_at_sm = (_veh distance RADAR_INSTALL_POINT) < INSTALL_RADIUS;
		};
		default {hint localize format["--- radio_menu.sqf: Expected command '%1' not parsed, must be LOAD, UNLOAD, INSTALL", _cmd]};
	};
};

if (_txt != "") then { _txt call XfGlobalChat };

if (_send_was_at_sm) then {
	_plist = [RADAR_INSTALL_POINT, INSTALL_RADIUS] call SYG_findNearestPlayers;
	if (count _plist > 0) then {
		["was_at_sm", _plist, "good_news"] call XSendNetStartScriptClientAll;
	};
};
