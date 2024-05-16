/*
	scripts\patrol\sea_patrol.sqf:
	author: Sygsky
	description:
		Support ships patrolling around all isles of Sahrani archipeligo

		Description of the info item for the patrol.
											   _id is index in array
			[ _boat, _grp, [_wp_arr (points)], _id, _state ]

		_state = [_last_pos, _time, _units, status]:
			off 0: _last position as [x,y<,z>] of last stored position ,
			off 1: _time is last position getting time,
			off 2: _units are all units in the intial group, we need it to remove bodies
			TODO: still not used, 3: absent or 0 = unknown, 1 = ready and active, -1 = waiting resque boat, -2 waiting reset

			Algorithm is very clear:
			1. Boat starts and go through his WPs, last WP is circular, state = 1.
			2. If script detects that boat is empty, state == -1.
				While at last 2 units are in crew, sea devil continue his patrol.
				If crew count == 1, sea devil goes to the ocean and is removed, state = 0.
			3. Special script sends some small rescue boat to the sea devil.
				If boat is successful, new command is populated in the devil
				and devil try to continue its trip or to move out of island boundaries and after is removed from the list, state = 0
			4. if resque boat is failed during designated period (stoped during 5 mins, killed etc), devil also is marked to be deleted, state = 0;

	returns: nothing
*/

#define OFFSET_BOAT 0
#define OFFSET_GRP  1
#define OFFSET_WPA  2
#define OFFSET_ID   3
#define OFFSET_STAT 4

#define OFFSET_STAT_LAST_POS  0
#define OFFSET_STAT_LAST_TIME 1
#define OFFSET_STAT_UNITS     2

#define BOAT_STATUS_UNKNOWN 0
#define BOAT_STATUS_READY   1
#define BOAT_STATUS_RESCUE  2

// Time to create a new vehicle to replace the captured one in seconds (600 == 10 mins)
#define TIME_TO_REPLACE_CAPTURED_VEH 600

// Time to create a new vehicle to replace the killed one in seconds (600 == 10 mins)
#define TIME_TO_REPLACE_KIA_VEH 600

#define MAX_DIST_TO_ENEMY 2500
#define DIST_TO_REVEAL 10000

//#define __DEBUG__	// Debug settings with shortened delays etc
#define __INFO__ // Print info about each patrol status
#define __STOP_IF_NO_PLAYERS__	// only delete patrols if no players, not restore them

// Comment to prevent boats to be unlocked by owner radars
// #define __CAPTURED_BOATS___
#include "x_setup.sqf"

#include "sea\ships_wp_array.sqf"

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

hint localize format["+++ sea_patrol.sqf: STARTED, crewman type = ""%1""", BOAT_UNIT];
_known_enemy_arr = []; // Array for known enemies

#define DIST_TO_BE_STUCK 10

//
//
//
_is_boat_captured = {
    private [ "_boat" ];
	_boat = _this select OFFSET_BOAT;
    if ((side _boat) == d_side_player) exitWith { true };

    // Check vehicle to be empty, if yes, continue check procedure
    if ( ( { alive _x } count (crew _boat)) ==  0 ) exitWith {
        if ( (count ([_boat, 20] call SYG_findNearestPlayers)) > 0 ) exitWith {true}; // Player[s] found nearby

        // Find nearest circle of any type near the boat and SPPM center ("RoadCone")
//s        !isNull (nearestObject [ _boat, "HeliH"]) // Heli circle is found (true) or not (false)
        (count (nearestObjects [_boat, ["HeliH","RoadCone"], 20])) > 0
    };
    false
};
// #639: allow boat capture
// Move boat from script serviced list to the common server vehicles list
//
_capture_boat = {
	_boat = _this select OFFSET_BOAT;
	_crew = [];
	{
		if (isPlayer _x) then { _crew set [count _crew, name _x]};
	} forEach crew _boat;
	_boat setVariable ["CAPTURED_ITEM", "SEA_PATROL"];
	_boat setVariable ["PATROL_ITEM", nil];
	[_boat] call XAddCheckDead;
	hint localize format[ "+++ sea_patrol.sqf boat_%1 captured by %2 (%3) at %4, will be re-created after %5 sec.",
		_this select OFFSET_ID,
		side _boat,
		_crew,
		[_boat,10] call SYG_MsgOnPosE0,
		TIME_TO_REPLACE_CAPTURED_VEH
	];
	_this set [OFFSET_BOAT, objNull]; // mark boat be absent
	 (_this select OFFSET_STAT) set [OFFSET_STAT_LAST_TIME, time + TIME_TO_REPLACE_CAPTURED_VEH];
	["msg_to_user", _boat,  [ ["STR_GRU_46_6"]], 0, 2, false, "good_news" ] call XSendNetStartScriptClient; // "You have captured this vehicle from the patrol. Use it to your advantage!"
};

// Call as:
// _modes = _unit call _get_modes;
// Or:
// _modes = _group call _get_modes;
_get_modes = {
	private ["_modes"];
	if ( typeName _this == "OBJECT" ) exitWith {
		[behaviour _this, combatMode (group _this), _this findNearestEnemy _this]
	};
	_modes = ["<UNKN/TYPE", typeName _this, objNull];
	if ( typeName _this == "GROUP" ) exitWith {
		{ if (alive _x) exitWith { _modes = [behaviour _x, combatMode _this, _x findNearestEnemy _x] } } forEach units _this;
		_modes
	};
	_modes
};

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Checks ship to be stuck or on shore or be catured by players
// Call: _good = [_boat, _grp, _wp_arr, _id, _state...] call _is_ship_stuck;
// Use SYG_isNearLand method to detect if boat near land
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
_is_ship_stuck = {
	private [ "_boat", "_stat", "_dist", "_stucked", "_pos", "_time", "_enemy", "_beh", "_unit" ];
	// Check to be stucked
	_boat = _this select OFFSET_BOAT;
	if (!alive _boat) exitWith {
	 	hint localize format[ "+++ sea_patrol.sqf is_ship_stuck: the boat_%1 is dead (%2), damage %3, return TRUE",
			_this select OFFSET_ID,
			if (isNull _boat) then {"<null>"} else {_boat call SYG_MsgOnPosE0},
			damage _boat
		];

		if ( (!isNull _boat) ) then {
			if ( (damage _boat) >= 1) then { // Mark killed in action vehicle to replace
				(_this select OFFSET_STAT) set [OFFSET_STAT_LAST_TIME, time + TIME_TO_REPLACE_KIA_VEH];
			};
		};
		true
	};

	// #639: Allow naval boat capturing
	// #677: check yellow circle or player nearby to count boat as hijacked
	if ( _this call _is_boat_captured ) exitWith {
		// Move boat from serviced list to the common vehicle list
		_this call _capture_boat;
//		_this call _remove_patrol; // this method will be called in main loop directly after returning from _is_ship_stuck with result true
		true
	};

	_grp = _this select OFFSET_GRP;
	if (isNull _grp) exitWith {
		hint localize format[ "+++ sea_patrol.sqf is_ship_stuck: the boat_%1 group is null, return TRUE", _this select OFFSET_ID ];
		true
	};
	_stat = _this select OFFSET_STAT;
	_pos  = _stat select OFFSET_STAT_LAST_POS;
	_time = _stat select OFFSET_STAT_LAST_TIME;
	_dist = _pos distance _boat;
	_stucked = false;

#ifdef __DEBUG__
		hint localize format[ "+++ sea_patrol.sqf is_ship_stuck: the boat_%1, params real(crit): dist %2(%3), time %4(%5), alive crew/units %6(%7)",
		_this select OFFSET_ID,
		_dist, POS_DIST,
		 time, _time,
		{alive _x} count crew _boat, {alive _x} count units _grp
		];
#endif

	//+++++++++++++++++++++++++++++++++++++++++++++++++++
	//++++++++++++ Check to be in battle ++++++++++++++++
	//+++++++++++++++++++++++++++++++++++++++++++++++++++
	if ( true ) then {

		_modes = _grp call _get_modes;
		_beh = _modes select 0;
		_enemy = _modes select 2;

		if ( !isNull _enemy) then {	if (_enemy isKindOf "Building") exitWith { _enemy = objNull }};
		_edist = round (_boat distance _enemy);
		if ( (alive _enemy) && (_edist < MAX_DIST_TO_ENEMY) ) exitWith { // If in battle, can't be stucked
#ifdef __INFO__
			if (isPlayer _enemy) then { _modes set [2, name _enemy] } else {
				_modes set [2, typeOf _enemy];
			};
			hint localize format[ "+++ sea_patrol.sqf is_ship_stuck: the boat_%1 in battle at %2, enemy dist %3, modes %4; return FALSE",
			_this select OFFSET_ID,
			[_boat, 10] call SYG_MsgOnPosE0,
			_edist,
			_modes
			];
#endif
			if ( _dist > POS_DIST ) exitWith {
				_stat set[ OFFSET_STAT_LAST_POS, getPosASL _boat ];
				_stat set [OFFSET_STAT_LAST_TIME, time + COMBAT_STALL_DELAY ]; // in battle time-out is longer
			};
			if (! (_enemy in _known_enemy_arr)) then {
				hint localize format[ "+++ sea_patrol.sqf is_ship_stuck: enemy %1 added to the reveal list (size after is %2)", typeOf _enemy, count _known_enemy_arr ];
				_known_enemy_arr set [count _known_enemy_arr, _enemy]
			};
			["say_sound", _boat, "naval"] call XSendNetStartScriptClientAll; // Say fear sound to the player )))
		}; // Some near enemy detected, not stuacked

		if ( _dist > POS_DIST ) exitWith {
		    _stat set[ OFFSET_STAT_LAST_POS, getPosASL _boat ];
		    _stat set [OFFSET_STAT_LAST_TIME, time + PATROL_STALL_DELAY ];
		}; // Distance from last point is far enough for boat to be not stalled

		if ( time > _time ) exitWith {
			// check if boat is near land
			if (_boat call SYG_isNearLand) exitWith {
#ifdef __INFO__
				hint localize format[ "+++ sea_patrol.sqf is_ship_stuck: the boat_%1 is stuck by timeout at %2, dist %3, land is NEAR, return TRUE",
					_this select OFFSET_ID,
					[_boat,10] call SYG_MsgOnPosE0,
					_dist
				];
#endif
				_stucked = true
			};
			// Not near land/shore
			_next_wp = _this call _get_next_wp;
			[_boat, _next_wp, 10] call _push_boat; // Push boat with speed 10 mps to the next point
#ifdef __INFO__
			hint localize format[ "+++ sea_patrol.sqf is_ship_stuck: the boat_%1 stuck by tmo at %2, dist %3, modes %4, expected dest %5, driver is %6ready, pushed speed %7 mph, dir %8",
				_this select OFFSET_ID,
				[_boat,10] call SYG_MsgOnPosE0,
				_dist,
				_modes,
				expectedDestination (driver _boat),
				if (unitReady (driver _boat)) then {""} else {"not "},
				round(speed _boat),
				round(getDir _boat)
			];
#endif
		};
	};
	_stucked
};

//
// Push boat to the 1st WP on speed 30 kph
// [_boat, _next_wp, _speed_meters_per_sec] call _push_boat
//
_push_boat = {
	private ["_boat", "_dir", "_speed_vec"];
	_boat  = _this select 0;
	if (!alive _boat) exitWith {false};
	_dir = [_boat,  _this select 1] call XfDirToObj;
	_boat setDir _dir;
	_speed_vec = [getPos _boat, _this select 1, 10] call SYG_speedBetweenPoints2D; // set speed 10 meters per second (36 kph)
	_boat setVelocity _speed_vec;
	true
};

//
// Finds next WP (not accurite)
// _wp = _arr call _get_next_wp;
//
_get_next_wp = {
	private [ "_boat", "_wpa", "_i", "_wp", "_pos", "_min_dist", "_min_i", "_wp","_dist",
			"_next_i","_pos_near_point","_next_dist","_next_line","_prev_dist","_prev_line", "_str"];
	_boat = _this select OFFSET_BOAT;
	_wpa = _this select OFFSET_WPA;
	_cnt = count _wpa;
	if (!alive _boat) exitWith {_wpa select 0};
	_min_dist = 100000;
	_min_i    = 0;
	_pos      = getPos _boat;
	for "_i" from 0 to (_cnt - 1) do {
		_wp = _wpa select _i;
		_dist = [_pos, _wp] call SYG_distance2D;
		if ( _dist < _min_dist ) then {
			_min_dist = _dist;
			_min_i = _i;
		}
	};
	// now detect if we already passes nearest point
	_next_i = 1; // 1st WP is next at start
	_prev_i = 0; // Spawn point is pevious on start
	_str = "";
	if (true) then {
		_prev_i = (_min_i -1) min 0;
		if ( _min_i == 0 ) exitWith { _next_i = 1 }; // On movement from 0 to 1.
		_next_i = ( ( _min_i + 1 ) mod _cnt ) min 1;
		if (_min_dist < 20) exitWith {}; // Assume the _min_i  point is already reached, skip it and go
		_pos_near_point = _wpa select _min_i;
		_next_dist = [ _wpa select _next_i, _pos ] call SYG_distance2D; 			// Dist from boat and next point
		_next_line = [ _wpa select _next_i, _pos_near_point ] call SYG_distance2D;	// Dist between min and next points
		if ( _next_dist < _next_line ) exitWith {};									// Used next point as current _next_i
		_prev_dist = [_wpa select _prev_i, _pos] call SYG_distance2D;				// Dist from boat and prev points
		_prev_line = [ _wpa select _prev_i, _pos_near_point ] call SYG_distance2D;	// Dist from min and prev points
		if ( _prev_dist < _prev_line ) exitWith { _next_i = _min_i }; // Next point as _min_i detected
		// No good difference found, use default _next_i as value to return
	};
#ifdef __DEBUG__
	hint localize format[ "+++ sea_patrol.sqf _get_next_wp: the boat_%1 at %2, wp next %3, near %4, prev %5",
		_this select OFFSET_ID,
		_boat call SYG_MsgOnPosE0,
		_next_i, _min_i, _prev_i
	];
#endif
	_wpa select _next_i
};

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+   [_boat, _grp, _wp_arr, _id, _state...] call _create_patrol  +
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
_create_patrol = {
	private [ "_boat", "_grp", "_x", "_i", "_wpa", "_arr", "_last", "_wp", "_cnt1", "_ex_cnt", "_speed_vec", "_dir"];
	_boat = createVehicle [BOAT_TYPE, [0,0,0], [], 50, "NONE"];
//	_boat setVehicleInit "this call SYG_rearmVehicleA";
	if ( _boat call SYG_rearmVehicleA ) then {
		hint localize format["+++ sea_patrol.sqf create_patrol: boat_%1 created and rearmed.", _this select OFFSET_ID, typeOf _boat];
	} else {
		hint localize format["--- sea_patrol.sqf create_patrol: boat_%1 created but NOT rearmed.", _this select OFFSET_ID, typeOf _boat];
	}; // try to rearm  upgraded vehicle

//+++ #639
//    _boat lock true;
	_boat setVariable ["PATROL_ITEM", _this select OFFSET_ID]; // Mark vehicle to be patrol one with some id
//--- #639
	_this set [OFFSET_BOAT, _boat];
	_grp = call SYG_createEnemyGroup;
	_this set [OFFSET_GRP, _grp];
	[_boat, _grp, BOAT_UNIT, 1.0] call SYG_populateVehicle;
	if ( alive (driver _boat) ) then { (driver _boat) setUnitRank "CORPORAL"}; // just in case

	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//+  Experimental setting to try to disable enemy radar targeting +
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	// Protect from radar on average 1 boat from the list if __CAPTURED_BOATS__ is defined
#ifndef __CAPTURED_BOATS__
    if ( (random (count _patrol_arr)) < 1 ) then {
#endif
	    _boat setCaptive true;
#ifndef __CAPTURED_BOATS__
    };
#endif

	_wpa = _this select OFFSET_WPA; // waypoint description array
	_boat setPos (_wpa select 0); // 1st WP position
	_this set [OFFSET_STAT,[getPosASL _boat, time + PATROL_STALL_DELAY, units _grp]];

//	_grp setBehaviour "YELLOW"; // Start as careless, change on first WP to "SAFE"
	_grp setBehaviour "SAFE"; // Start as careless, change on first WP to "SAFE"
	_grp setCombatMode "GREEN";
//	_grp setSpeedMode "FULL"; // "LIMITED", "NORMAL"
	_grp setSpeedMode "LIMITED"; //"FULL",  "NORMAL"
	_last = (count _wpa) - 1;

	for "_i" from 1 to _last do {
		_wp = _grp addWaypoint [_wpa select _i, 50];
		_wp setWaypointType "MOVE";
		if (_i == 1) then {
//			_wp setWaypointBehaviour "CARELESS";
			_wp setWaypointBehaviour "SAFE";
			_wp setWaypointCombatMode "GREEN";
			_wp setWaypointSpeed "LIMITED";
		} else {
			_wp setWaypointBehaviour "SAFE";
			_wp setWaypointCombatMode "YELLOW";
			_wp setWaypointSpeed "FULL";
		};
	}; // forEach _waterPatrolWPS select (_this select 3);
	// for last WP set special type
	_wp setWaypointType "CYCLE"; // Set last WP to be loop one, and cycle  to the 1st WP!

	// Push boat to the 1st WP on speed 30 kph
	_dir = round([_boat,  _wpa select 1] call XfDirToObj);
	_boat setDir _dir;
	_speed_vec = [getPos _boat, _wpa select 1, 5] call SYG_speedBetweenPoints2D; // set speed 10 meters per second (18 kph)
	_boat setVelocity _speed_vec;
	sleep 0.1;
#ifdef __INFO__
	if (_printInfo) then {
		hint localize format["*** sea_patrol.sqf create_patrol: boat_%1 at %2, speed = %3 kmh, dir %4, dest %5",
			_this select OFFSET_ID,
			_boat call SYG_MsgOnPosE0,
			round(speed _boat),
			round(_dir),
			expectedDestination (driver _boat)
		];
	};
#endif
};

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// [_boat, _grp, _wp_arr, _id, _state...] call _remove_patrol;
// Returns the same array as input one
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
_remove_patrol = {
	private [ "_boat", "_grp", "_x", "_pos", "_arr", "_del_arr", "_cnt_null", "_cnt_dead", "_cnt_alive", "_grp_state" ];
	_boat = _this select OFFSET_BOAT;
	_grp  = _this select OFFSET_GRP;
	_cnt_null = 0; _cnt_dead = 0; _cnt_alive = 0;
	_grp_state = if (!isNull _grp) then {"alive"} else {"null"};
	_units = (_this select OFFSET_STAT) select OFFSET_STAT_UNITS;
	{
		if (!isNull _x) then {
			if (alive _x) then {_cnt_alive = _cnt_alive + 1} else {_cnt_dead = _cnt_dead + 1};
			deleteVehicle _x;
			sleep 0.05;
		} else {_cnt_null = _cnt_null + 1};
	} forEach _units;
	_units resize 0;
	_this set [OFFSET_GRP, grpNull];
	if (_printInfo) then {
		hint localize format["+++ sea_patrol.sqf remove_patrol: boat_%1 (%2), units alive %3, dead %4, null %5; grp %6",
			_this select OFFSET_ID,
			if (isNull _boat) then {"<null>"} else { format["%1, at %2",if (alive _boat) then {"alive"} else {"dead"}, _boat call SYG_MsgOnPosE0] },
			_cnt_alive, _cnt_dead, _cnt_null,
			_grp_state
		];
	};
	if (alive _boat) then {
		_boat setDamage 1;
		sleep 3;
	};
	_pos = [];
	if (!isNull _boat) then {_pos = getPos _boat; deleteVehicle _boat};
	_this set [OFFSET_BOAT, objNull];
	sleep 0.3;
	// Check if dead bodies are still scattered around the last position
	_del_arr = [];
	if (count _pos > 0) then {
		_arr = _pos nearObjects [BOAT_UNIT, 100];
		if (count _arr > 0) then {
			{
				if (!isNull _x) then {
					if (surfaceIsWater (getPos _x)) then { _del_arr set [count _del_arr, _x]; };
				};
			} forEach _arr;
			if (count _del_arr > 0) then {
				//++++++++++++++++++++++++++++
				// remove after some delay
				//++++++++++++++++++++++++++++
				[_this select OFFSET_ID, _del_arr, _pos] spawn {
					hint localize format["--- sea_patrol.sqf remove_patrol: boat_%1 remove proc left %2 units not deleted, prepare to delete them after 60 seconds", _this select 0, count (_this select 1)];
					sleep 60;
					private ["_x","_cnt"];
					{
						if (!isNull _x) then { deleteVehicle _x };
					} forEach (_this select 1);
					_cnt = {!isNull _x} count (_this select 1);
					if (_cnt > 0 ) then {
						hint localize format["--- sea_patrol.sqf remove_patrol: boat_%1 clean proc still left %2 units in water not deleted", _this select 0, _cnt];
					} else {
						hint localize format["+++ sea_patrol.sqf remove_patrol: boat_%1 clean proc removed all left unis. Good job!", _this select 0];
					};
				};
			};
		};
	};
	_this
};

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// [_boat, _grp, _wp_arr, _id, _state...] call _replace_patrol
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
_replace_patrol = {

#ifdef __INFO__
//	player groupCHat format["+++ sea_patrol.sqf boat_%1 replacing", _this select OFFSET_ID];
	hint localize format[ "+++ sea_patrol.sqf replace_patrol: boat_%1 %2 (alive units %4), _this = %5",
		_this select OFFSET_ID,
		if (alive (_this select OFFSET_BOAT)) then {"alive"} else {"dead"},
	 	{alive _x} count ((_this select OFFSET_STAT) select OFFSET_STAT_UNITS),
	 	_this call _item2str];
#endif
	_this call _remove_patrol;

//	hint localize format[ "+++ sea_patrol.sqf _replace_patrol: _create_patrol proc type = %1",typeName _create_patrol];
	_this call _create_patrol; // The only point where patrol is created
};

_patrol_arr = []; // MAIN array to store all ships, alive or null

// _str = [_boat, _grp, _wp_arr, _id, _state...] call _item2str;
_item2str = {
//	if (typeName _this != "ARRAY") exitWith { format["--- Expected _item2str _this <> ""ARRAY"" (%1)", typeName _this] };
//	if (count _this != 5) exitWith { format["--- Expected _item2str _this count <> 5 (%1)", count _this] };
	format["[type %1, side %2, _wpa[%3], id %4, stat %5]", typeOf (_this select 0), side (_this select 1), count (_this select 2), _this select 3, _this select 4];
};

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// +          fill initial array with empty patrol description items                  +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sleep (80 + (random 20)); // sleep ~90 seconds (1.5 minutes) before to start, it is enought
["msg_to_user","",["STR_SEA_PATROL_START"], 0, 0, false, "naval"] call XSendNetStartScriptClient; // "GRU reports that the appearance of naval patrols is quite possible."

#ifdef __INFO__
hint localize  "+++ sea_patrol.sqf: fill initial patrols +++";
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

_printInfo = true; // Print info or net
// fill all patrols from the scratch

//++++++++++++++++++++++++++++++++++++++++++++
// _boat call _resupply_boat;
//+++++++++++++++++++++++++++++++++++++++++++
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

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// As: _usable_ship =[_boat, _grp, _wp_arr, _id, _state...] call _reset_roles; // true is ship is good, else bad
// Try to fill driver and at least 1 gunner from cargo or driver from any gunners
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
_reset_roles = {
	_stat = _this select OFFSET_STAT;
	_units = _stat select OFFSET_STAT_UNITS;
	if ( ( { alive _x } count _units ) == 0 ) exitWith {  // Nobody alive in crew, boat can't be supported more
#ifdef __DEBUG__
    	hint localize "+++ sea_patrol.sqf reset_roles: all units are dead, return FALSE";
#endif
		false
	};
    _boat = _this select OFFSET_BOAT;
    _grp = _this select OFFSET_GRP;
	_driver = objNull;
	_ind = ["RHIB2Turret","RHIB"] find (typeOf _boat);
	_gun_empty_ids = [[0,1],[0]] select _ind; // All gunner[s] id from the boat config
	   _gunner_cnt = count _gun_empty_ids; // Official gunner count in the config team
	   _gunner_ids = [];
	      _gunners = [];
	       _outers = []; // Men of team out of boat
	// Detect all roles of the crew in vehicle
	_cnt = 0;
	_i = 0;
	{
		if (alive _x) then {
			_x setDamage 0;
			_role = assignedVehicleRole _x;
			if ( ((count _role) > 0) && (_x in _boat)) then {
				if ( (_role select 0) == "Driver") exitWith {_driver = _x};
				if ( (_role select 0) == "Turret") exitWith {
					_id = (_role select 1) select 0;
					_gunner_ids set[count _gunner_ids, _id]; // Count seats occupied by gunners
					_gunners set [count _gunners, _x]; // To handle gunners on seats
				};
				// must be in cargo but may be out of ship!
			} else {
				_outers set [count _outers, _x]; // Crew out of boat
			};
			_cnt = _cnt + 1; // Count alive units in the group
		} else {
			// Remove dead unit of the team
			deleteVehicle _x;
		};
		_i = _i + 1;
	} forEach _units;

	if ( (alive (driver _boat)) && ( (count _gunner_ids) == _gunner_cnt) ) exitWith { true }; // Driver and 1 (RHIB) or 2 (RHIB2Turret) gunner[s] are on the place

	// check too small crew, less then 2 (driver + gunner)
	_gun_empty_ids = _gun_empty_ids - _gunner_ids; // define not filled turrets from list [0<,1>]
#ifdef __INFO__
	_beh = _grp call _get_modes;
	hint localize format["+++ sea_patrol.sqf reset_roles: cnt (alive %1/out %2), beh %3, gunner_ids %4, _gun_empty_ids %5 ...",
		_cnt, count _outers, _beh, _gunner_ids, _gun_empty_ids ];
#endif

	// Fill driver if absent
	_unit = objNull;
	if (!alive _driver) then {
		if ( (count _outers) > 0 ) then {
			_cnt = count _outers;
			_unit = _outers select (_cnt -1);
			unassignVehicle _unit;
			_unit setPos [0,0,0];
			_outers resize (_cnt - 1);
#ifdef __INFO__
			hint localize "+++ sea_patrol.sqf reset_roles: outer assigned as driver...";
#endif
		} else {
			_unit = _grp createUnit [ BOAT_UNIT, [0,0,0], [], 0, "NONE"];
			[_unit] joinSilent _grp;
#ifdef __INFO__
			hint localize "+++ sea_patrol.sqf reset_roles: new unit assigned as driver...";
#endif
		};
		_unit assignAsDriver _boat;
		_unit moveInDriver _boat; // load cargo also, for the future replacement crew members procedure
		_unit setUnitRank "CORPORAL";
	};
	sleep 0.1;

	// Turrets fill from outers or new units...
	{
		_str = "";
		if (count _outers > 0) then {
			_cnt  = count _outers;
			_unit = _outers select (_cnt - 1);
			_outers resize (_cnt - 1);
			_str = "outers";
		} else {
			_unit = _grp createUnit [ BOAT_UNIT, [0,0,0], [], 0, "NONE"];
			[_unit] joinSilent _grp;
			_str = "new unit";
		};
		unassignVehicle _unit;
		_unit setPos [0,0,0];
		_unit moveInTurret [_boat, [_x]];
#ifdef __INFO__
		hint localize format["+++ sea_patrol.sqf reset_roles: gunner#%1 (%2) assigned from %3", _x, assignedVehicleRole _unit, _str];
#endif
		sleep 0.1;
	} forEach _gun_empty_ids;

	{
		if ( !isNull _x )  then { deleteVehicle _x };
	} forEach _outers;
	_units = units _grp;
#ifdef __INFO__
	if ( (count _units)  != 3 ) then {
		hint localize format["+++ sea_patrol.sqf reset_roles: Expected units count = %1, must be 3", count _units];
	};
#endif

	_stat set [OFFSET_STAT_UNITS, _units];
	true
};

#ifdef __STOP_IF_NO_PLAYERS__
_check_empty_server = {
    if (!X_MP) exitWith {}; // Only for MP server
	if ( (call XPlayersNumber) > 0 ) exitWith { }; // Server has players, skip this method body
    // Not recreate patrol if no players
    _printInfo = false;
    _time = time;
    // Wait for the server to be empty for at least 30 minutes
    _time_to_clear = _time + 1800;
    while {( (call XPlayersNumber) == 0 ) && (time < _time_to_clear)} do {sleep 60};
    if ( (call XPlayersNumber) != 0 ) exitWith {
        hint localize format[ "*** sea_patrol.sqf: mission was empty too short period of %1 secs, no boats removed", round(time - _time) ];
    };
    hint localize format[ "*** sea_patrol.sqf: MAIN loop suspended due to players absent, all %1 patrols removed", count _patrol_arr ];
    { sleep 1; _x call _remove_patrol } forEach _patrol_arr;

    while {((call XPlayersNumber) == 0)} do { sleep 60 };
    _time = (round (time - _time)) call SYG_secondsToStr; // "hh:mm:ss"
    hint localize format[ "*** sea_patrol.sqf: MAIN loop resumed after players absent during %1. All %2 boat[s] will be re-created", _time, count _patrol_arr ];
    _printInfo = true;
};
 #endif

_exit_patrol_system = {
    hint localize "*** sea_patrol.sqf: stop sea patrols (move them out) due to the all towns are liberated !!!";
    ["msg_to_user","",["STR_SEA_PATROL_LEAVE"], 0, 0, false, "no_more_waiting"] call XSendNetStartScriptClient; // "GRU reports that enemy naval patrols are heading away from Sahrani."
    // set last WP to the big distance from island center
    {
        _boat = _x select OFFSET_BOAT;
        // For not null boat
        if (!isNull _boat) then {
            _grp  = _x select OFFSET_GRP;
            _units = (_x select OFFSET_STAT) select OFFSET_STAT_UNITS;
            // If patrol is not alive, skip it directly now
            if ( (isNull _grp) || ( ({alive _x} count _units) == 0 ) || (!alive (driver _boat))) exitWith {
                _x call _remove_patrol;
            };
            _last = (count (waypoints _grp)) - 1;
            for "_i" from _last to 0 step -1 do {
                deleteWaypoint [_grp, _i];
            };
            _pos = [d_island_center, _boat, 10000] call SYG_elongate2; // get pos 10 km out of boat pos in direction from island center
            (driver _boat) moveTo _pos;
            _grp setSpeedMode "FULL";
        };
    } forEach _patrol_arr;
    //
    sleep 600; // Wait 10 minutes
    {
        _x call _remove_patrol;
    } forEach _patrol_arr;
};

//===============================================================================
//                      +++ MAIN SERVICE LOOP +++
//===============================================================================
while { true } do {

    #ifdef __STOP_IF_NO_PLAYERS__

    call _check_empty_server;

    #endif

	// stop sea patrol system on the end of mission
	if ( current_counter > number_targets ) exitWith {
	    call _exit_patrol_system;
	};

	if ( {alive _x } count _known_enemy_arr == 0) then { // No enemies detected
		_known_enemy_arr resize 0;
	};

	{
		_arr = _x; // _x = [_boat, _grp, _wp_arr, _id, _state...]
		_boat = _arr select OFFSET_BOAT;
		if (isNull _boat ) then {
			_time = (_x select OFFSET_STAT) select OFFSET_STAT_LAST_TIME;
			if (time >= _time) then {
				_arr call _create_patrol // create now as time is out
			};
		} else {
			// Check last position
			// Repair, exchange seats from cargo to driver and at last first gunner if possible
			// Driver and one of gunners are 2 obligatory seats
			if ( _arr call _is_ship_stuck) then {
				_arr call _remove_patrol; // remove veh this step, to re-create it on the next step
			} else {
				// Check if crew is still operable and on duty
				if (_arr call _reset_roles) then {
					_boat call _resupply_boat; // reload, refuel, repair

					// Inform all boats  about possible enemy around
					_cnt = count _known_enemy_arr - 1;
					if (_cnt >= 0 ) then {
						_changed = false;
						for "_i" from 0 to _cnt do {
							_enemy = _known_enemy_arr select _i;
							if (alive _enemy) then {
								if ( (_enemy distance _boat) < DIST_TO_REVEAL) then {(_arr select OFFSET_GRP) reveal _enemy};
							} else  {
								_known_enemy_arr set [_i, "RM_ME"];
								_changed = true;
							};
						};
						if (_changed) then {
							_cnt = count _known_enemy_arr;
							_known_enemy_arr call SYG_clearArray;
							hint localize format[ "+++ sea_patrol.sqf: reveal list resized down from %1 to %2", _cnt, count _known_enemy_arr ];
						};
					};
					// TODO: remove time-out

				} else {
					// This boat is inoperable, so remove it now
					_arr call _remove_patrol; // remove this step, to re-create it on the next step
				};
			};
			sleep 1;
		};

	} forEach _patrol_arr;
	_printInfo = true;
	sleep PATROL_CHECK_DELAY; // step sleep
};

hint localize "*** sea_patrol.sqf: all boats are removed, service is finished";

