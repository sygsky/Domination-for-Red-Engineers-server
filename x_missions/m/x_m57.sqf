// by Sygsky, radar installation mission (#410, request by Rokse). x_missions/m/x_m56.sqf
#include "x_setup.sqf"
#include "x_macros.sqf"

// #define BOAT_TYPE "RHIB2Turret"
#define POINT_TYPE "Heli_H_civil"

#define __DEBUG_SM_57__

x_sm_pos = [[8586.3,10103.2,0]]; // index: 57,   Capturing the sea devil boat, point near base shore on the west side of airbase
x_sm_type = "normal"; // "normal", "convoy", "undefined"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

_circle_pos = x_sm_pos select 0;

if (call SYG_isSMPosRequest) exitWith {_circle_pos}; // it is request for pos, not SM execution

if (X_Client) then {
	_name = _circle_pos call SYG_nearestSettlementName;
	// "Capture a sea devil (sea patrol boat) and drive it to a given point on the coast (see map near %1) to pass it to the GRU.
	// \nKeep in mind, the GRU is only interested in the newest vehicle!"
	current_mission_text = format[localize "STR_SM_57", _name];
	current_mission_resolved_text = localize "STR_SM_057"; // "Mission accomplished, the boat has been handed over to the GRU for study"
};

if (!isServer) exitWith {};

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Start the service of sea devil capture

// Find all empty sea devils and block them for the duration of this sidemission

_cnt = 0;
_cnt_boat = 0;
_list = [];
{
	if (typeOf _x == BOAT_TYPE) then {
		if (alive _x) then {
			if ( (side _x) != d_side_enemy ) then { // If empty or friendly, remember it as vehicle that can't be used to finish SM
				_list set [count _list, _x];
			};
		};
		_cnt_boat  = _cnt_boat + 1; // Count patrol boats only
		sleep 0.3;
	};
	_cnt = _cnt + 1; // Vehicles (and objects created im mission) count
	if ( (_cnt mod 20) == 0) then { sleep 0.3}; // Just in case of a very long vehicle list sleep on each 20th vehicle
} forEach vehicles;
hint localize format["+++ x_m57.sqf: global coll vehicles (size %1) scanned for '%2', found %3 and set is old alive %4", _cnt, BOAT_TYPE, _cnt_boat, count _list ];
["say_sound","PLAY", "sea_devil1", 15] call call XSendNetStartScriptClient;

_pos    = + _circle_pos;
_sites = [
#ifdef __DEBUG_SM_57__
	[[(_pos select 0) - 10, (_pos select 1) - 3,0], 0, BOAT_TYPE], // create debug vehicle
#endif
	[              _pos,   0, POINT_TYPE],
	[[8573.7,10073.6,0], 325, "WarfareBEastContructionSite1"],
	[[8598.9,10070.5,0],  70, "WarfareBEastContructionSite"],
	[[8613.1,10102.8,0],   0, "WarfareBEastAircraftFactory"]
];

for "_i" from 0 to ((count _sites) - 1) do {
	_x = _sites select _i;
	_pos = _x select 0;
	_item = createVehicle [ _x select 2, _pos, [], 0, "NONE" ]; // [_type, _pos, [markers],_rad, "HOW_TO_POS"]
	_item setDir (_x select 1);
	_pos = getPos _item;
	_pos set [2,0];
	_item setPos _pos;
	_sites set [_i, _item]; // Store created item in the place of its data
	hint localize format["+++ x_m57.sqf: %1 created, pos %2", typeOf _item, getPos _item];
};
// Await end of this SM
_do = true;
_pos = + _circle_pos; // Check for the circle position, not any other object
while { _do } do {
	sleep 5;
	_arr = _pos nearObjects [ BOAT_TYPE, 2 ];
	{
		if (alive _x) then {
			if (  (side _x) != d_side_enemy  ) then {
				_arr1 = [];
				// Prepare list of alive crew in SM finished boat
				{
					if (alive _x) then { _arr1 set [count _arr1, name _x] };
				} forEach crew _x;

				if ( !(_x in _list) ) then { // New alive non-enemy vehicle is on circle, mission completed!!!
					[ "msg_to_user", "*", [["STR_SM_57_INFO", _arr1]], 0, 0, false, "sea_devil2" ] call XSendNetStartScriptClientAll; // "OUR boat crew: %1"
					[] spawn {	// Wait 1st message shown
						sleep 5;
						side_mission_winner = 2;
						side_mission_resolved = true;
					};
					hint localize format["+++ x_m57.sqf completed, captured %1 with crew of %2 unit[s]", count _arr1];
					_do = false
				} else { // This boat is in older list, refuse it now. Inform all players closer 50 meters to the circle pos
					[ "msg_to_user", [50, _circle_pos], [["STR_SM_57_BAD_INFO"]], 0, 0, false, "losing_patience" ] call XSendNetStartScriptClientAll; // "The GRU is not interested in this boat, we need a newer one!"
				};
			};
		};
		if (!_do) exitWith {};
		sleep 1;
	} forEach _arr;
};

_list resize 0;
_list = nil;

["say_sound","PLAY", "sea_devil2"] call call XSendNetStartScriptClient;

// Delete all created vehicles
{ deleteVehicle _x; sleep 1 } forEach _sites;
_sites = nil;

if (true) exitWith {};