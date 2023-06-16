/*
	scripts/intro/sea_patrol.sqf
	author: Sygsky
	description:
		Support ships patrolling around all isles

		Description of the info item for the patrol.
											   _id is index in array
			[ _boat, _grp, [_wp_arr (points)], _id, _state ]

		State if: [last_pos, _time]: last position as [x,y<,z>], time is last position getting time

	returns: nothing
*/

#define OFFSET_BOAT 0
#define OFFSET_GRP  1
#define OFFSET_WPA  2
#define OFFSET_ID   3
#define OFFSET_STAT 4

// #define __DEBUG__
#define __INFO__

#include "x_setup.sqf"

#include "ships_wp_array.sqf"

#define BOAT_TYPE "RHIB2Turret"
#ifdef __DEBUG__
	#define PATROL_CHECK_DELAY 15
	#define POS_DIST 20
	#define PATROL_STALL_DELAY 60
#else
	#define PATROL_CHECK_DELAY 120 // Full check cycle delay
	#define POS_DIST 180  		   // Distance to previous position to regard the boat as stalled in place
	#define PATROL_STALL_DELAY 360 // Max time to decide stalled or not
#endif


#ifdef __OWN_SIDE_EAST__
	#define BOAT_UNIT d_crewman_E
#else
	#define BOAT_UNIT d_crewman_W
#endif

hint localize "+++ sea_patrol.sqf: STARTED";

#define DIST_TO_BE_STUCK 10

//
// Checks ship to be stuck or on shore
// Call: _good = [_ship, _grp, _wp_arr, _id, _state...] call _is_ship_stuck;
//
_is_ship_stuck = {
	private [ "_boat", "_stat", "_dist", "_res", "_beh", "_pos", "_time" ];
	// Check to be stucked
	_boat = _this select OFFSET_BOAT;
	if (!alive _boat) exitWith { true };
	_stat = _this select OFFSET_STAT;
	_res = false;
	if ( true  ) then {
		_beh = behaviour (driver _ship);
		if (_beh == "COMBAT") exitWith {}; // In combat - can't be stalled during battle
		_pos  = _stat select 0;
		_dist = _pos distance _boat;
		if ( _dist > POS_DIST) exitWith {}; // Distance from last point is far enought for boat to be not stalled
		_time = _stat select 1;
		if ( _time < time ) exitWith {}; // Time still not out to be stalled
#ifdef __INFO__
//		player groupChat format["+++ boat#%1 stuck", _this select OFFSET_ID];
		hint localize format[ "+++ sea_patrol.sqf _is_ship_stuck: the boat#1 is stuck, dist = %2, behaviour = %3, delay = %4",
			_this select OFFSET_ID,
			round _dist,
			_beh,
			round(time - _time)
		];
#endif
		_res = true
	};
	// Not stuck, update  check next time
	if ( !_res ) then { _stat set[ 0, getPosASL _boat ]; _stat set [1, time + PATROL_STALL_DELAY ] }; // Update status for the next loop
	_res
};

//  [_ship, _grp, _wp_arr, _id, _state...] call _create_patrol
_create_patrol = {
	private [ "_boat", "_grp", "_x", "_i", "_wpa", "_arr", "_last", "_wp","_cnt1","_ex_cnt"];
	_boat = createVehicle [BOAT_TYPE, [0,0,0], [], 0, "NONE"];

	if ( _boat call SYG_rearmVehicleA ) then {
		hint localize format["+++ _create_patrol: %1 created and rearmed", typeOf _boat];
	} else {
		hint localize format["+++ _create_patrol: %1 created but not rearmed", typeOf _boat];
	}; // try to rearm  upgraded vehicle

	_boat lock true;
	_this set [OFFSET_BOAT, _boat];
	_grp = call SYG_createEnemyGroup;
	_this set [OFFSET_GRP, _grp];
	[_boat, _grp, BOAT_UNIT, 1.0] call SYG_populateVehicle;
	_grp setSpeedMode "FULL";
	_cnt1 = count (crew _boat);
	_ex_cnt = (_boat emptyPositions "Cargo") min 3; // Only 3 cargo allowed here, config value is 7
	for "_i" from 1 to _ex_cnt do { // add some cargo to replace killed units in need
		_unit = _grp createUnit [ BOAT_UNIT, [0,0,0], [], 0, "NONE"];
		_unit assignAsCargo _boat;
		_unit moveInCargo _boat; // load cargo also, for the future replacement crew members procedure
	};
	_wpa = _this select OFFSET_WPA; // waypoint description array
	_boat setPos (_wpa select 0); // 1st WP position
//	hint localize format["+++ sea_patrol.sqf _create_patrol: WPA[%1] of %2 points, crew cnt %3, cargo %4 assigned", _this select OFFSET_ID,  count _wpa, _cnt1, _ex_cnt];
	_last = (count _wpa) - 1;
	for "_i" from 0 to _last do {
		_wp = _grp addWaypoint [_wpa select _i, 20];
		_wp setWaypointType "MOVE";
		_wp setWaypointBehaviour "SAFE";
		_wp setWaypointCombatMode "YELLOW";
		_wp setWaypointSpeed "FULL";
	}; // forEach _waterPatrolWPS select (_this select 3);
	_wp setWaypointType "CYCLE"; // loop it now from last to the first WP!

	_grp setBehaviour "SAFE";
	_grp setCombatMode "RED";

#ifdef __INFO__
	hint localize format["+++ sea_patrol.sqf _create_patrol: ship#%1, driver %2, gunner %3, commander %4",
		_this select OFFSET_ID,
		assignedVehicleRole ( driver _boat),
		assignedVehicleRole ( gunner _boat),
		assignedVehicleRole ( commander _boat)
		];
#endif
};

//
// [_ship, _grp, _wp_arr, _id, _state...] call _remove_patrol;
// Returns the same array as input one
//
_remove_patrol = {
	private [ "_boat", "_grp", "_x" ];
	_boat = _this select OFFSET_BOAT;
	_grp = _this select OFFSET_GRP;
	if (!isNull _grp) then {
		{
			if (!isNull _x) then {
				deleteVehicle _x;
				sleep 0.05;
			};
		} forEach (units _grp);
		_this set [OFFSET_GRP, grpNull];
	};
	if (alive _ship) then {
		_boat setDamage 1;
		sleep 2;
	};
	if (!isNull _ship) then {deleteVehicle _boat};
	_this set [OFFSET_BOAT, objNull];
	_this
};

// [_ship, _grp, _wp_arr, _id, _state...] call _replace_patrol
_replace_patrol = {

#ifdef __INFO__
//	player groupCHat format["+++ boat#%1 replaced", _this select OFFSET_ID];
	hint localize format[ "+++ sea_patrol.sqf _replace_patrol: %1 ship#%2(%3) (alive crew %4), _this = %5",
		if (alive (_this select OFFSET_BOAT)) then {"alive"} else {"dead"},
		_this select OFFSET_ID,
		typeOf (_this select OFFSET_BOAT),
	 	{alive _x} count (crew (_this select OFFSET_BOAT)),
	 	_this call _item2str];
#endif
	_this call _remove_patrol;

	if (X_MP && ((call XPlayersNumber) == 0) ) exitWith {}; // Do nothing if no players
	_this call _create_patrol;
};

_patrol_arr = [];

#ifdef __INFO__
// _str = [_ship, _grp, _wp_arr, _id, _state...] call _item2str;
_item2str = {
//	if (typeName _this != "ARRAY") exitWith { format["--- Expected _item2str _this <> ""ARRAY"" (%1)", typeName _this] };
//	if (count _this != 5) exitWith { format["--- Expected _item2str _this count <> 5 (%1)", count _this] };
	format["[%1, %2, _wpa[%3], %4, %5]", typeOf (_this select 0), side (_this select 1), count (_this select 2), _this select 3, _this select 4];
};
#endif

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// +          fill initial array with empty patrol description items                  +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#ifdef __INFO__
hint localize  "+++ sea_patrol.sqf fill initial  patrols +++";
#endif

_cnt = count _waterPatrolWPS; // how many patrols to implement
_i = 0;
{
	if (typeName _x == "ARRAY") then {
		_arr = [objNull, grpNull, _x, _i, [ [0,0,0], time] ];
		_patrol_arr set [ _i, _arr ]; // [_boat, _group, _wpa, _id, _state]
#ifdef __INFO__
		_str = format ["+++ sea_patrol.sqf patrol #%1 params = %2", _i, _arr call _item2str];
		hint localize  _str;
#endif
		_i = _i + 1;
	};
} forEach _waterPatrolWPS;

_waterPatrolWPS = nil;

// fill all patrols from the scratch

// _boat call _resupply_boat;
_resupply_boat = {
	if (!alive _this) exitWith {};
	_this setFuel 1;
	_this setDamage 0;
#ifdef __INFO__
	hint localize format[ "+++ sea_patrol.sqf _resupply_boat: ship crew count %1", {alive _x} count (crew _this) ];
#endif
	{
		if (alive _x) then { _x setDamage 0};
	} forEach crew _this;
	// TODO: reammo vehicle
};

// Returns first found cargo unit
// _unit = _boat call _get_cargo;
// if ( isNull unit) then ...
_get_cargo = {
	private ["_unit", "_role", "_x"];
	_unit = objNull;
	{
		_role = assignedVehicleRole _x;
		if (count _role == 0) exitWIth {};
		if ((_role select 0) == "CARGO") exitWith {_unit = _x;};
	} forEach crew _this;
	_unit
};

// As: _usable_ship = _ship call _reset_roles; // true is ship is good, else bad
// Try to fill driver and at least 1 gunner from cargo or driver from two gunners
_reset_roles = {
	if ( (alive (driver _this)) && (alive (gunner _this)) ) exitWith {true}; // Only the driver and the front gunner are needed, to reduce inspections
	_driver = objNull;
	_gun_empty_ids = [0,1]; // all gunners id in config
	_gunner_ids = [];
	_gunner_units = [];
	_no_cnt = 0;
	_cargo = [];
	// Detect all roles of the crew in vehicle
	_cnt = 0;
	{
		if (alive _x) then {
			_x setDamage 0;
			_role = assignedVehicleRole _x;
			if ( (count _role) > 0) then {
				if ( (_role select 0) == "Driver") exitWith {_driver = _x};
				if ( (_role select 0) == "Turret") exitWith {
					_id = (_role select 1) select 0;
					_gunner_ids set[count _gunner_ids, _id]; // Count seats occupied by gunner[s]
					_gunner_units set [count _gunner_units, _x]; // To handle seats occupied by gunner[s]
				};
				if ( (_role select 0) == "Cargo") exitWith {_cargo set [count _cargo, _x]};
				_no_cnt = _no_cnt + 1;
			};
			_cnt = _cnt + 1;
		};
	} forEach crew _this;

	// check too small crew, less then 2 (driver + gunner)
	if (  _cnt < 2 ) exitWith {
#ifdef __INFO__
		hint localize format[ "+++ sea_patrol.sqf _reset_roles: boat crew count (%1) < 2, exit...", _cnt ];
#endif
		false
	};
	_gun_empty_ids = _gun_empty_ids - _gunner_ids; // define not filled turrets from list [0,1]
#ifdef __INFO__
	hint localize format["+++ sea_patrol.sqf _reset_roles: common count (%1), gunner_ids %2, _gun_empty_ids %3 ...", _cnt, _gunner_ids, _gun_empty_ids ];
#endif
	_cargo_cnt = count _cargo;

	// Fill driver if absent
	if (!alive _driver) then {
		if (_cargo_cnt > 0) exitWith {
			_unit = _cargo select (_cargo_cnt -1);
			unassignVehicle _unit;
			_unit setPos [0,0,0];
			_unit moveInDriver _this;
			_cargo resize (_cargo_cnt - 1);
			sleep 0.1;
#ifdef __INFO__
			hint localize format["+++ sea_patrol.sqf _reset_roles: cargo [%1] assigned as driver (%2), ...", count _cargo, alive (driver _this)];
#endif
		};
		// no more cargo, try 2nd gunner of 2 available
		if ((count _gunner_ids) < 2) exitWith{}; // no 2nd gunner to use him as driver
		// put 2nd gunner as driver
		_unit = _gunner_units select 1;
		unassignVehicle _unit;
		_unit setPos [0,0,0];
		_unit moveInDriver _this;
		_gunner_units resize 1; // remove 2nd gunner
		sleep 0.1;
#ifdef __INFO__
		hint localize format["+++ sea_patrol.sqf _reset_roles: 2nd gunner assigned as driver (%1)...", assignedVehicleRole _unit ];
#endif
	};

	// turret fill from cargo...
	_cargo_ind =  (count _cargo) -1;
	if (_cargo_ind > -1) then {
		{
			_unit = _cargo select _cargo_ind;
			unassignVehicle _unit;
			_unit setPos [0,0,0];
			_unit moveInTurret [_this, [_x]];
			_gunner_ids set [count _gunner_ids, _x]; // to count seats occupied by gunner[s]];
			_gunner_units set [count _gunner_units, _unit]; // to handle seats occupied by gunner[s]];
			_cargo_ind = _cargo_ind - 1;
			if (_cargo_ind < 0) exitWith { };
			sleep 0.1;
#ifdef __INFO__
			hint localize format["+++ sea_patrol.sqf _reset_roles: cargo assigned as gunner#%1 (%2)...", _x, assignedVehicleRole _unit];
#endif
		} forEach _gun_empty_ids;
	};
	// check if single gunner is not a front one
	if ( (!alive (gunner _this)) &&  ((count _gunner_units) == 1) ) then {
		_unit = _gunner_units select 0;
		unassignVehicle _unit;
		_unit setPos [0,0,0];
		_unit moveInGunner _this;
		sleep 0.1;
#ifdef __INFO__
		hint localize format[ "+++ sea_patrol.sqf _reset_roles: gunner#1 moved to gunner#0 (%1)...", assignedVehicleRole _unit ];
#endif
	};

#ifdef __INFO__
	hint localize format["+++ sea_patrol.sqf _reset_roles: gunners %1, %2 driver...",
	count _gunner_units,
	if (alive driver _this) then {"alive"} else {"dead"}];
#endif
	(alive (driver _this)) && (alive (gunner _this)) // Good vehicle: alive driver and at last 1 gunner is alive
};

//
// +++ MAIN SERVICE LOOP +++
//
while { true } do {
	{
//		_x = [_ship, _grp, _wp_arr, _id, _state...]
		_arr = _x;
		_ship = _arr select OFFSET_BOAT;
		if (alive _ship) then {
/**
#ifdef __INFO__
			hint localize format["+++ sea_patrol.sqf BOAT LOOP: ship#%1 has crew %2, at %3",
				_arr select OFFSET_ID,
				{alive _x} count (crew _ship),
				[_ship, "%1 m. to %2 from %3"] call SYG_MsgOnPosE
			];
#endif
*/
			if ( ({alive _x} count (crew _ship)) < 2 ) then { // crew is not ready to struggle
				_arr call _replace_patrol;
#ifdef __INFO__
				hint localize format["+++ sea_patrol.sqf BOAT LOOP: replaced patrol, ship#%1, driver %2, gunner1 %3",
					_arr select OFFSET_ID,
					if (alive (driver _ship)) then {"alive"} else {"dead"},
					if (alive (gunner _ship)) then {"alive"} else {"dead"} ];
#endif

			} else { // There are alive crew in the boat
				// check last position
				// Repair, exchange seats from cargo to gunner or driver if possible
				// Driver and one of gunners are 2 obligatory seats
				if ( _arr call _is_ship_stuck) exitWith {
					_arr call _replace_patrol;
				};
				if (_ship call _reset_roles) then {
					_ship call _resupply_boat; // reload, refuel, repair
				} else { // replace this boat
#ifdef __INFO__
			hint localize format["+++ sea_patrol.sqf BOAT LOOP: ship#%1 crew not fit!",_arr select OFFSET_ID ];
#endif
					_arr call _replace_patrol;
				};
			};
		} else {
#ifdef __INFO__
			hint localize format["+++ sea_patrol.sqf BOAT LOOP: ship#%1 is dead!",_arr select OFFSET_ID ];
#endif
			_arr call _replace_patrol;
		};
		sleep 1;
	} forEach _patrol_arr;
	sleep PATROL_CHECK_DELAY; // step sleep
};
