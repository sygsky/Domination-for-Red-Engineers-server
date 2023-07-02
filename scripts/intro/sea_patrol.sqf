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

#define __DEBUG__	// Debug settings with shortened delays etc

#define __INFO__ // Print info about each patrol status

//#define __STOP_IF_NO_PLAYERS__	// only delete patrols if no players, not restore them

#include "x_setup.sqf"

#include "ships_wp_array.sqf"

#define BOAT_TYPE "RHIB2Turret"
/*
#ifdef __DEBUG__
	#define PATROL_CHECK_DELAY 15
	#define POS_DIST 5
	#define PATROL_STALL_DELAY 60
	#define COMBAT_STALL_DELAY 120
#else
*/
	#define PATROL_CHECK_DELAY 120 // Full check cycle delay
	#define POS_DIST 5  		   // Distance to previous position to regard the boat as stalled in place
	#define PATROL_STALL_DELAY 360 // Max time to decide stalled or not
	#define COMBAT_STALL_DELAY 600 // Max time to decide stalled or not if in combat
//#endif


#ifdef __OWN_SIDE_EAST__
	#define BOAT_UNIT d_crewman_W
#else
	#define BOAT_UNIT d_crewman_E
#endif

hint localize format["+++ sea_patrol.sqf: STARTED, crewman %1", typeOf BOAT_UNIT];

#define DIST_TO_BE_STUCK 10

// Call as:
// _modes = _unit call _get_modes;
// Or:
// _modes = _group call _get_modes;
_get_modes = {
	private ["_modes"];
	if ( typeName _this == "OBJECT" ) exitWith {
		[behaviour _this, combatMode (group _this), _this findNearestEnemy _this]
	};
	if ( typeName _this == "GROUP" ) exitWith {
		_modes = ["NO", "UNIT","<NULL>"];
		{ if (alive _x) exitWith { _modes = [behaviour _x, combatMode _this, _x findNearestEnemy _this] } } forEach units _this;
		_modes
	};
	["<UNKN/TYPE", typeName _this, objNull]
};
//
// Checks ship to be stuck or on shore
// Call: _good = [_ship, _grp, _wp_arr, _id, _state...] call _is_ship_stuck;
//
_is_ship_stuck = {
	private [ "_boat", "_stat", "_dist", "_stucked", "_pos", "_time", "_near_enemy", "_beh", "_unit" ];
	// Check to be stucked
	_boat = _this select OFFSET_BOAT;
	if (!alive _boat) exitWith {
	 	hint localize format[ "+++ sea_patrol.sqf _is_ship_stuck: the boat_%1 is dead (%2), return TRUE",
			_this select OFFSET_ID,
			if (isNull _boat) then {"<null>"} else {_boat call SYG_MsgOnPosE0}
		];
		true
	};
	_grp = _this select OFFSET_GRP;
	if (isNull _grp) exitWith {
		hint localize format[ "+++ sea_patrol.sqf _is_ship_stuck: the boat_%1 group is null, return TRUE", _this select OFFSET_ID ];
		true
	};
	if ( ({alive _x} count units _grp) < 2) exitWith {
	 	hint localize format[ "+++ sea_patrol.sqf _is_ship_stuck: the boat_%1, the list of group members is too short (%2<2), return TRUE",
	 		_this select OFFSET_ID,
			{alive _x} count units _grp
		];
		true
	};
	_stat = _this select OFFSET_STAT;
	_pos  = _stat select 0;
	_time = _stat select 1;
	_dist = _pos distance _boat;
	_stucked = false;

#ifdef __DEBUG__
		hint localize format[ "+++ sea_patrol.sqf _is_ship_stuck: the boat_%1, params real(crit): dist %2(%3), time %4(%5), crew/units %6(%7)",
		_this select OFFSET_ID,
		_dist, POS_DIST,
		 time, _time,
		{alive _x} count crew _boat, {alive _x} count units _grp
		];
#endif

	if ( true ) then {

		//++++++++++++ Check to be in battle ++++++++++++++++
		_modes = _grp call _get_modes;
		_beh = _modes select 0;
		_in_combat = _beh in ["COMBAT","STEALTH"];
		if ( _in_combat ) exitWith { // If in battle, can't be stucked
#ifdef __INFO__
			_near_enemy = _modes select 2;
			if (isNull _near_enemy) then { _modes set [2, "<null>"]} else {_modes set [2, typeOf _near_enemy]};
			hint localize format[ "+++ sea_patrol.sqf _is_ship_stuck: the boat_%1 in battle at %2, modes %3; return FALSE",
			_this select OFFSET_ID,
			_boat call SYG_MsgOnPosE0,
			_modes
			];
#endif
			if ( _dist > POS_DIST ) exitWith {
				_stat set[ 0, getPosASL _boat ]; _stat set [1, time + COMBAT_STALL_DELAY ];
			};
		}; // Some enemy detected, not stuacked

		if ( _dist > POS_DIST ) exitWith { _stat set[ 0, getPosASL _boat ]; _stat set [1, time + PATROL_STALL_DELAY ]; }; // Distance from last point is far enough for boat to be not stalled

		if ( time > _time ) exitWith {
#ifdef __INFO__
			hint localize format[ "+++ sea_patrol.sqf _is_ship_stuck: the boat_%1 is stuck by timeout on dist at %2, return TRUE",
				_this select OFFSET_ID,
				_boat call SYG_MsgOnPosE0
			];
#endif
			_stucked = true
		};
	};
	_stucked
};

//  [_ship, _grp, _wp_arr, _id, _state...] call _create_patrol
_create_patrol = {
	private [ "_boat", "_grp", "_x", "_i", "_wpa", "_arr", "_last", "_wp","_cnt1","_ex_cnt"];
	_boat = createVehicle [BOAT_TYPE, [0,0,0], [], 25, "NONE"];

	if ( _boat call SYG_rearmVehicleA ) then {
		hint localize format["+++ sea_patrol.sqf _create_patrol: %1 recreated and rearmed", typeOf _boat];
	} else {
		hint localize format["--- sea_patrol.sqf _create_patrol: %1 recreated but NOT rearmed", typeOf _boat];
	}; // try to rearm  upgraded vehicle

	_boat lock true;
	_this set [OFFSET_BOAT, _boat];
	_grp = call SYG_createEnemyGroup;
	_this set [OFFSET_GRP, _grp];
	[_boat, _grp, BOAT_UNIT, 1.0] call SYG_populateVehicle;
	_grp setSpeedMode "FULL";
	_cnt1 = count (crew _boat);
	_ex_cnt = (_boat emptyPositions "Cargo") min 3; // Only 3 cargo allowed here, config value is 7
	_units = [];
	for "_i" from 1 to _ex_cnt do { // add some cargo to replace killed units in need
		_unit = _grp createUnit [ BOAT_UNIT, [0,0,0], [], 0, "NONE"];
		[_unit] joinSilent _grp;
		_unit assignAsCargo _boat;
		_unit moveInCargo _boat; // load cargo also, for the future replacement crew members procedure
	};
	_wpa = _this select OFFSET_WPA; // waypoint description array
	_boat setPos (_wpa select 0); // 1st WP position
	hint localize format["+++ sea_patrol.sqf _create_patrol: boat_%1 at %2", _this select OFFSET_ID, _boat call SYG_MsgOnPosE0];
	_last = (count _wpa) - 1;
	for "_i" from 1 to _last do {
		_wp = _grp addWaypoint [_wpa select _i, 50];
		_wp setWaypointType "MOVE";
		if (_i == 1) then {
			_wp setWaypointBehaviour "SAFE";
			_wp setWaypointCombatMode "YELLOW";
		} else {
			_wp setWaypointBehaviour "UNCHANGED";
			_wp setWaypointCombatMode "NO CHANGE";
		};
		_wp setWaypointSpeed "FULL";
	}; // forEach _waterPatrolWPS select (_this select 3);
	// for last WP set special type
	_wp setWaypointType "CYCLE"; // loop it now from last to the first WP!

	_grp setBehaviour "CARELESS"; // Start as careless, change on first WP to "SAFE"
	_grp setCombatMode "WHITE";
	_grp setSpeedMode "FULL";
	_this set [OFFSET_STAT,[getPosASL _boat, time + PATROL_STALL_DELAY]];
#ifdef __DEBUG__
	hint localize format["+++ sea_patrol.sqf _create_patrol: ship#%1 (%2), driver %3, gunner %4, %5",
		_this select OFFSET_ID,
		typeOf _boat,
		assignedVehicleRole ( driver _boat),
		assignedVehicleRole ( gunner _boat),
		_this call _item2str
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
//	player groupCHat format["+++ boat_%1 replacing", _this select OFFSET_ID];
	hint localize format[ "+++ sea_patrol.sqf _replace_patrol: %1 ship#%2(%3) (alive crew %4), _this = %5",
		if (alive (_this select OFFSET_BOAT)) then {"alive"} else {"dead"},
		_this select OFFSET_ID,
		typeOf (_this select OFFSET_BOAT),
	 	{alive _x} count (crew (_this select OFFSET_BOAT)),
	 	_this call _item2str];
#endif
	_this call _remove_patrol;

#ifdef __STOP_IF_NO_PLAYERS__
	if (X_MP && ((call XPlayersNumber) == 0) ) exitWith {}; // Do nothing if no players
#endif	

//	hint localize format[ "+++ sea_patrol.sqf _replace_patrol: _create_patrol proc type = %1",typeName _create_patrol];
	_this call _create_patrol; // The only point where patrol is created
};

_patrol_arr = [];

// _str = [_ship, _grp, _wp_arr, _id, _state...] call _item2str;
_item2str = {
//	if (typeName _this != "ARRAY") exitWith { format["--- Expected _item2str _this <> ""ARRAY"" (%1)", typeName _this] };
//	if (count _this != 5) exitWith { format["--- Expected _item2str _this count <> 5 (%1)", count _this] };
	format["[type %1, side %2, _wpa[%3], id %4, stat %5]", typeOf (_this select 0), side (_this select 1), count (_this select 2), _this select 3, _this select 4];
};

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// +          fill initial array with empty patrol description items                  +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#ifdef __INFO__
hint localize  "+++ sea_patrol.sqf fill initial  patrols +++";
#endif

// how many patrols to implement
_i = 0;
{
	if (typeName _x == "ARRAY") then {
		_arr = [objNull, grpNull, _x, _i, [ [0,0,0], time + PATROL_STALL_DELAY] ];
		_patrol_arr set [ _i, _arr ]; // [_boat, _group, _wpa, _id, _state]
#ifdef __DEBUG__
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
//#ifdef __INFO__
//	hint localize format[ "+++ sea_patrol.sqf _resupply_boat: ship crew count %1", {alive _x} count (crew _this) ];
//#endif
	{
		if (alive _x) then { _x setDamage 0};
	} forEach units (group driver _this);
	// TODO: reammo vehicle
};

// As: _usable_ship =[_ship, _grp, _wp_arr, _id, _state...] call _reset_roles; // true is ship is good, else bad
// Try to fill driver and at least 1 gunner from cargo or driver from two gunners
_reset_roles = {
	_ship = _this select OFFSET_BOAT;
	_grp = _this select OFFSET_GRP;
	_cnt = {alive _x} count units _grp; // Alive cnt (units, not crew)
	// Check if driver and gunner are in place and units count is 2
	if ( (alive (driver _ship)) && (alive (gunner _ship)) && (_cnt == 2) ) exitWith { true }; // Only the driver and the front gunner are needed, to reduce follow checks
	_grp = _this select OFFSET_GRP;
	_driver = objNull;
	_gun_empty_ids = [0,1]; // all gunners id in config
	_gunner_ids = [];
	_gunner_units = [];
	_cargo = []; // men in cargo + men of the group near ship
	_out_units = [];
	// Detect all roles of the crew in vehicle
	_cnt = 0;
#ifdef __INFO__
	_cargo_dists = []; // distances for alive units of the group not in ship
#endif
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
				// must be in cargo but may be out of ship!
				if ( (_role select 0) == "Cargo") exitWith { _cargo set [ count _cargo, _x ] };
			} else {
				if ( ! (_x in crew _ship) ) then {
					_cargo set [ count _cargo, _x ];
					_out_units set [ count _out_units, _x ];
#ifdef __INFO__
					_cargo_dists  set [ count _cargo_dists, round(_ship distance _x) ];
#endif
					unassignVehicle _x ;
					sleep 0.05;
					_x assignAsCargo _ship;
				};
			};
			_cnt = _cnt + 1; // Count alive units in the group
		};
	} forEach units _grp;
	if (count _out_units > 0) then { _out_units orderGetIn true };

	// check too small crew, less then 2 (driver + gunner)
	if (  _cnt < 2 ) exitWith {
#ifdef __INFO__
		hint localize format[ "+++ sea_patrol.sqf _reset_roles: boat_%1 grp units %2 < 2, dists %3 exit...", _this select OFFSET_ID, _cnt, _cargo_dists ];
#endif
		false
	};
	if ( (alive _driver) && ((count _gunner_ids) == 2)) exitWith { true }; // critical crew is on seats
	_gun_empty_ids = _gun_empty_ids - _gunner_ids; // define not filled turrets from list [0,1]
#ifdef __DEBUG__
	_beh = _grp call _get_modes;
	hint localize format["+++ sea_patrol.sqf _reset_roles: common count (%1/out %2), beh %3, gunner_ids %4, _gun_empty_ids %5 ...",
		_cnt, count _out_units, _beh, _gunner_ids, _gun_empty_ids ];
#endif
	_cargo_cnt = count _cargo;

	// Fill driver if absent
	if (!alive _driver) then {
		if (_cargo_cnt > 0) exitWith {
			_unit = _cargo select (_cargo_cnt -1);
			unassignVehicle _unit;
			_unit setPos [0,0,0];
			_unit moveInDriver _ship;
			_cargo resize (_cargo_cnt - 1);
			sleep 0.1;
#ifdef __DEBUG__
			hint localize format["+++ sea_patrol.sqf _reset_roles: cargo [%1] assigned as driver (%2), ...", count _cargo, alive (driver _ship)];
#endif
		};
		// no more cargo, try 2nd gunner of 2 available
		if ( (count _gunner_ids) < 2 ) exitWith{}; // no 2nd gunner to use him as driver
		// put 2nd gunner as driver
		_unit = _gunner_units select 1;
		unassignVehicle _unit;
		_unit setPos [0,0,0];
		_unit moveInDriver _ship;
		_gunner_units resize 1; // remove 2nd gunner
		sleep 0.1;
#ifdef __DEBUG__
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
			_unit moveInTurret [_ship, [_x]];
			_gunner_ids set [count _gunner_ids, _x]; // to count seats occupied by gunner[s]];
			_gunner_units set [count _gunner_units, _unit]; // to handle seats occupied by gunner[s]];
			_cargo_ind = _cargo_ind - 1;
			if (_cargo_ind < 0) exitWith { };
			sleep 0.1;
#ifdef __DEBUG__
			hint localize format["+++ sea_patrol.sqf _reset_roles: cargo assigned as gunner#%1 (%2)...", _x, assignedVehicleRole _unit];
#endif
		} forEach _gun_empty_ids;
	};
	// check if single gunner is not a front one
	if ( (!alive (gunner _ship)) &&  ((count _gunner_units) == 1) ) then {
		_unit = _gunner_units select 0;
		unassignVehicle _unit;
		_unit setPos [0,0,0];
		_unit moveInGunner _ship;
		sleep 0.1;
#ifdef __DEBUG__
		hint localize format[ "+++ sea_patrol.sqf _reset_roles: gunner#1 moved to gunner#0 (%1)...", assignedVehicleRole _unit ];
#endif
	};

#ifdef __DEBUG__
	hint localize format["+++ sea_patrol.sqf _reset_roles: gunners %1, %2 driver...",
		count _gunner_units,
		if (alive driver _ship) then {"alive"} else {"dead"}
	];
#endif
	(alive (driver _ship)) && (alive (gunner _ship)) // Good vehicle: alive driver and at last 1 gunner is alive
};

//
// +++ MAIN SERVICE LOOP +++
//
while { true } do {
	{
//		_x = [_ship, _grp, _wp_arr, _id, _state...]
		_arr = _x;
		_ship = _arr select OFFSET_BOAT;

		// check last position
		// Repair, exchange seats from cargo to gunner or driver if possible
		// Driver and one of gunners are 2 obligatory seats
		if ( _arr call _is_ship_stuck) then {
			_arr call _replace_patrol;
		} else {
			// Check if all available crew are on duty
			if (_arr call _reset_roles) then {
				_ship call _resupply_boat; // reload, refuel, repair
			};
		};
		sleep 1;
	} forEach _patrol_arr;
	sleep PATROL_CHECK_DELAY; // step sleep
};
