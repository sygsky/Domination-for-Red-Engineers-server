// by Sygsky, radar installation mission (#410, request by Rokse). x_missions/m/x_m56.sqf
#include "x_setup.sqf"
#include "x_macros.sqf"

#define BOAT_TYPE "RHIB2Turret"
#define POINT_TYPE "Heli_H_civil"

#define __DEBUG__

x_sm_pos = [[8586.3,10103.2,0]]; // index: 57,   Capturing the sea devil boat, point near base shore on the west side of airbase
x_sm_type = "normal"; // "normal", "convoy", "undefined"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {x_sm_pos select 0}; // it is request for pos, not SM execution

if (X_Client) then {
	_name = (x_sm_pos select 0) call SYG_nearestSettlementName;
	current_mission_text = format[localize "STR_SM_57", _name]; // "Capture a sea devil (large sea boat) and drive it to a given point on the coast (see map near %1) to pass it to the GRU"
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
			if ( { alive _x } count crew _x == 0) then { // If empty, lock it during this sidemission execution
				_list set [count _list, _x];
				_x lock true;
			};
		};
		_cnt_boat  = _cnt_boat + 1; // Count patrol boats only
		sleep 0.3;
	};
	_cnt = _cnt + 1; // Vehicles (and objects created im mission) count
	if ( (_cnt mod 25) == 0) then { sleep 0.3}; // Just in case of a very long vehicle list sleep on each 25th vehicle
} forEach vehicles;
hint localize format["+++ x_m57.sqf: global coll vehicles (size %1) scanned for '%2', found %3 and set empty alive locked %4", _cnt, BOAT_TYPE, _cnt_boat, count _list ];
["say_sound","PLAY", "sea_devil1", 15] call call XSendNetStartScriptClient;

_pos    = x_sm_pos select 0;
_sites = [
#ifdef __DEBUG__
	[[(_pos select 0) - 10, (_pos select 1) - 3,0], 0, BOAT_TYPE], // create debug vehicle
#endif
	[              _pos,   0, POINT_TYPE],
	[[8573.7,10073.6,0], 325, "WarfareBEastContructionSite1"],
	[[8598.9,10070.5,0],  70, "WarfareBEastContructionSite"],
	[[8613.1,10102.8,0],   0, "WarfareBEastAircraftFactory"]
];

_pos = x_sm_pos select 0; // Check for circle position, not any other object
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
while { _do } do {
	sleep 5;
	_arr = _pos nearObjects [ BOAT_TYPE, 2 ];
	{
		if (alive _x) then {
			if ( !(locked _x)) then {
				if ((side _x) != d_side_enemy) exitWith { _do = false };
			};
		};
		if (!_do) exitWith {};
		sleep 1;
	} forEach _arr;
};

// Unlock all locked sea devils
{ _x lock false } forEach _list;
_list resize 0;
_list = nil;

["say_sound","PLAY", "sea_devil2"] call call XSendNetStartScriptClient;

// Delete all created vehicles
{ deleteVehicle _x; sleep 1 } forEach _sites;
_sites = nil;

if (true) exitWith {};