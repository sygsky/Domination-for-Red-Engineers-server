/*
    x_missions/common/sideradar/radio_inspect.sqf, created at JUN 2022
    created 2022.06.01
	author: Sygsky, on #410 request by Rokse
	description: Inspect event handler for radio install SM, may be used on 2 trucks and 1 radiomast

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
	private ["_detected"];
	_detected = d_radar getVariable "DETECTED";
	if (isNil "_detected") then {
		d_radar setVariable ["DETECTED", true];
		// copy detected status to the server
		["remote_execute", "d_radar setVariable[""DETECTED"", true];"] call XSendNetStartScriptServer;
	};
};

_veh = _this select 0;
_txt = (if (_veh isKindOf "Truck") then {
	if (!alive _veh) exitWith {"STR_RADAR_TRUCK_KILLED"}; // "This truck isn't going anywhere anymore. Maybe there's another one somewhere?"
	if (locked _veh) then {_veh lock false;  "STR_RADAR_TRUCK_LOCKED"} // "A truck adapted to carry radio mast. You're in luck!"
	else {
		if (isNil "sideradio_vehs") then {
			"STR_RADAR_TRUCK"; // Active truck for transporting a radio mast
		} else {
			if (alive d_radar) then {
				_asl = getPosASL d_radar;
				// "Active truck for transporting a radio mast, mast is loaded"
				if ((_asl select 2) < 0 ) then { "STR_RADAR_TRUCK_LOADED" } else {
					// 0 - mission not finished, 1 - mast installed, 2 - truck is on the way to the base, 3 - completed
					switch (sideradio_status) do {
						case 0: { "STR_RADAR_TRUCK_LOADED" };
						case 1: { "STR_RADAR_TRUCK_MAST_INSTALLED" };
						case 2: { "STR_RADAR_SUCCESSFUL" };
					};
				};
			} else { // radar is dead
				"STR_RADAR_TRUCK_MAST_FAILED"
			};
		};
	};
} else {
	if (!alive d_radar) exitWith {"STR_RADAR_MAST_DEAD"};

	call _set_detected;
	switch (sideradio_status) do {
		case 0: { "STR_RADAR_MAST_UNLOADED" };
		case 2;
		case 1: {
			["say_radio", call SYG_randomRadio] call XSendNetStartScriptClientAll;
			"STR_RADAR_MAST_INSTALLED"
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
