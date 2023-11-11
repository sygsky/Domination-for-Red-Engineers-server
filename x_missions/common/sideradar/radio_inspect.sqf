/*
    x_missions/common/sideradar/radio_inspect.sqf, created at JUN 2022
    created 2022.06.01
	author: Sygsky, on #410 request by Rokse
	description: Inspect event handler for radio re-install SM, may be used on 2 trucks and 1 radiomast, called on client only

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
			// Print message on the server now
			_str = format["hint localize ""+++ radio_service: radar truck detected by ""%1"" at %2""", name player, [_veh,10] call SYG_MsgOnPosE0];
			["remote_execute", format["%1;d_radar_truck setVariable[""DETECTED"", true];", _str]] call XSendNetStartScriptServer;
		} else {
			_str = format["hint localize ""+++ radio_service: radar mast detected by ""%1"" at %2""", name player, [_veh,10] call SYG_MsgOnPosE0];
			["remote_execute", format["%1;d_radar setVariable[""DETECTED"", true];", _str]] call XSendNetStartScriptServer;
		};
		true
	};
	false
};

_veh = _this select 0;
_txt = (if (_veh isKindOf "Truck") then {
	if (!alive _veh) exitWith {
//		_veh removeAction (_this select 2);
		"STR_RADAR_TRUCK_KILLED"  // "This truck isn't going anywhere anymore. Maybe there's another one somewhere?"
	};
	if (locked _veh) then {
		_veh lock false;
		_veh call _set_detected;
		("STR_RADAR_TRUCK_LOCKED_NUM" call SYG_getRandomText) // "A truck adapted to carry radio mast. You're in luck!" etc
	} else {
		if (alive d_radar) then {
			_asl = getPosASL d_radar;
			// "Active truck for transporting a radio mast, mast is loaded"
			if ((_asl select 2) < 0 ) then { "STR_RADAR_TRUCK_LOADED" } else {
				// 0 - mission not finished, 1 - mast installed, 2 - truck is on the way to the base, 3 - completed
				switch (sideradio_status) do {
					case 0: { "STR_RADAR_TRUCK_NOT_LOADED" };
					case 1: { "STR_RADAR_TRUCK_MAST_INSTALLED" };
					case 2: { "STR_RADAR_TRUCK_NOT_NEEDED" };
				};
			};
		} else { // radar is dead
			"STR_RADAR_TRUCK_MAST_FAILED"
		};
	};
} else { // it is radar
	if (!alive d_radar) exitWith {"STR_RADAR_MAST_DEAD"};

	d_radar call _set_detected;
	switch (sideradio_status) do {
		case 0: { "STR_RADAR_MAST_UNLOADED" };
		case 1: {
			["say_radio", call SYG_randomRadio] call XSendNetStartScriptClientAll;
			"STR_RADAR_MAST_INSTALLED"
		};
		case 2: {
			["say_radio", call SYG_randomRadio] call XSendNetStartScriptClientAll;
			"STR_RADAR_SUCCESSFUL"
		};
		default { "STR_RADAR_MAST" };
	};
});
if (_txt == "") then {
//	hint localize format["+++ radio_inspect.sqf: d_radar %1 (%2) ", if (alive d_radar) then {"alive"} else {"not alive"}, if (isNil "d_radar") then {"isNil"} else {"not isNil"}];
	["say_radio", call SYG_randomRadioNoise] call XSendNetStartScriptClientAll;
	(localize "STR_RADAR_NO") call XfGlobalChat; // Unknown message
};
(localize _txt) call XfGlobalChat; // _txt is already localized
