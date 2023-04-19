/*
	sea_patrol.sqf
	author: Sygsky
	description:
		Support ships patrolling around all isles

		Description of the info item for the patrol.
														_id is index in array
			[ _boat, _grp, [_wp_arr (points)], _id, _state ]

	returns: nothing
*/

#define OFFSET_BOAT 0
#define OFFSET_GRP  1
#define OFFSET_WPA  2
#define OFFSET_ID   3
#define OFFSET_STAT 4

#include "x_setup.sqf"

#include "ships_wp_array.sqf"

#define BOAT_TYPE "RHIB2Turret"
#define PATROL_DELAY 120

#ifdef __OWN_SIDE_EAST__
	#define BOAT_UNIT d_crewman_E
#else
	#define BOAT_UNIT d_crewman_W
#endif

// _new patrol_group = [_type, _wp_arr] call _create_patrol
// _new_patrol: [_ship, _grp, _wp_arr ...]
_create_patrol = {
	private [ "_boat", "_grp", "_x", "_i", "_wpa", "_arr", "_last", "_wp"];
	_boat = createVehicle [BOAT_TYPE, [0,0,0], [], 0, "NONE"];
	_boat call SYG_rearmVehicleA; // try to rearm  upgraded vehicle
	_boat lock true;
	_grp = call SYG_createEnemyGroup;
	[_boat, _grp, BOAT_UNIT, 1.0]  call SYG_populateVehicle;
	_ecnt = (_boat emptyPositions "Cargo") min 3;
	for "_i" from 1 to _ecnt do { // add some cargo to replace killed units in need
		_unit = _grp createUnit [ BOAT_UNIT, [0,0,0], [], 0, "NONE"];
		_unit assignAsCargo _boat; _unit moveInCargo _boat; // load cargo also, for the future replacement crew members procedure
	};
	_wpa = _this select OFFSET_WPA; // waypoint description array
	_arr = _wpa select 1;  // waypoints array
	_boat setPos (_arr select 0); // 1st WP position
	hint localize format["+++ _create_patrol: WPA[%1] of %2 points, caro cnt %3 assigned", _this select 3,  count _arr, _ecnt];
	_last = (count _arr) - 1;
	for "_i" from 0 to _last do {
		_wp = _grp addWaypoint [_arr select _i, 20];
		_wp setWaypointType "MOVE";
		_wp setWaypointBehaviour "SAFE";
		_wp setWaypointCombatMode "YELLOW";
		_wp setWaypointSpeed "FULL";
	}; // forEach _waterPatrolWPS select (_this select 3);
	_wp setWaypointType "CYCLE"; // loop it now from last to the first WP!

	_grp setBehaviour "SAFE";
	_grp setCombatMode "RED";
};

//
// [_ship, _grp ...] call _remove_patrol;
// Returns the same array as input one
//
_remove_patrol = {
	private [ "_ship", "_grp", "_x" ];
	_ship = _this select OFFSET_BOAT;
	_grp = _this select OFFSET_GRP;
	if (!isNull _grp) then {
		{
			if (!isNull _x) then {
				deleteVehicle _x;
				sleep 0.05;
			};
		} forEach (units _grp);
	};
	if (!isNull _ship) then {deleteVehicle _boat};
	_this
};

// [_ship, _group, _wp_arr] call _replace_patrol
_replace_patrol = {
	_this call _remove_patrol;
	_this call _create_patrol;
};

_patrol_arr = [];

_build_patrol_arr = {
	_cnt = count _waterPatrolWPS; // how many patrols to implement
	_i = 0;
	{
		_patrol_arr set [count _patrol_arr, [objNull, grpNull, nil, _i]];
		_i = _i + 1;
	} forEach _waterPatrolWPS
};
// fill all patrols from the scratch

// _bost call _refit_boat;
_refit_boat = {
	if (!alive _this) exitWith {};
	_this setFuel 1;
	// TODO: reammo vehicle
};

while {true} do {
	sleep _PATROL_DELAY; // step sleep
	{
//		_x = [_ship, _grp, _wp_arr, _id, _state...]
		_ship = _x select OFFSET_BOAT;
		_grp  = _x select OFFSET_GRP;
		if ( ({alive _x} count (crew _ship)) == 0 ) then {
			if (alive _ship) exitWith {
				// TODO: repair, populate, set next waypoint as active.
			};
			_x call _replace_patrol;
		} else { // There are alive crew in the boat
			// repair, exchange if neeeded
		};

	} forEach _patrol_arr;
};
