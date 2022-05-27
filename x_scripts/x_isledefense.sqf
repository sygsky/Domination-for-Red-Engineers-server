// by Xeno: x_isledefense.sqf
// Create and support vehicle patrols over island
//
private ["_i", "_j", "_ret", "_make_isle_grp", "_replace_grp", "_remove_grp",
        "_getFeetmen","_firstGoodVehicle","_aliveVehCount","_utilizeFeetmen",
		"_igrpa", "_igrp", "_make_new", "_units","_igrppos", "_leader",
		"_unit","_veh", "_count","_feetmen","_invalid_men","_str","_vtype",
		"_grp_array","_cnt","_cnt1","_delay","_goal_grp","_locname","_loc","_dir","_dist","_pos1","_pos2",
		"_show_absence","_patrol_cnt","_last_cnt", "_exit","_patrol_type"];
		
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "GRU_setup.sqf"
#include "x_macros.sqf"
#include "global_vars.sqf"

#ifdef __SYG_ISLEDEFENCE_DEBUG__
#define __DEBUG__
#endif

//#define __DEBUG__

#define __PRINT_ACTIVITY__

#define arrset(ARR,POS,VAL) ((ARR)set[(POS),(VAL)])

#ifdef __DEBUG__
#define DELAY_BEFORE_SCRIPT_START 120
#define DELAY_ON_PATROL_INIT 60
#define DELAY_RESPAWN_STOPPED 120
#define DELAY_RESPAWN_KILLED 240
#define DELAY_REMOVE_DEAD 120
#define DELAY_REMOVE_STOPPED 90
#define DELAY_REMOVE_STUCKED 30
#define DELAY_VERY_LONG_STOPPED 1800
#else
#define DELAY_BEFORE_SCRIPT_START (1200 + random 120)
#define DELAY_ON_PATROL_INIT 600
#define DELAY_RESPAWN_STOPPED 600
#define DELAY_RESPAWN_KILLED 3600
#define DELAY_REMOVE_DEAD 240           // delay to remove on dead (all vehicles are empty)
#define DELAY_REMOVE_STOPPED 180        // delay to be removed
#define DELAY_REMOVE_STUCKED 60         // delay to check for status stacked
#define DELAY_VERY_LONG_STOPPED 3600    // delay for check stacked status if enemy is near
#endif

// show absence with designated probability
#define SHOW_ABSENCE_PROBABILITY 0.8

#define DELAY_BETWEEN_EACH_PATROL_CHECK (5 + random 5)
#define DELAY_BETWEEN_CHECK_LOOP (25 + random 25)
 
//#define DELAY_FEETMEN_CHECK 120
#define DELAY_NOT_SET 0

//	[_agrp, _units, _last_pos, _vecs, time, _stat, _grp_array]
#define PARAM_GROUP 0       // group itself
#define PARAM_UNITS 1       // units of group
#define PARAM_LAST_POS 2    // last position of patrol leader
#define PARAM_VEHICLES 3    // vehicle of group
#define PARAM_TIMESTAMP 4   // last timestamp to check about
#define PARAM_STATUS 5      // state of patrol (normal, stacked, stopped, dead, wait to restore)
#define PARAM_GRP_ARRAY 6   // group array used by x_groupsm.sqf
#define PARAM_TYPE 7        // type of patrol "HP", "AP" etc

#define STATUS_STUB -1              // this patrol not processed anymore
#define STATUS_NORMAL 0             // normal patrol state
#define STATUS_DEAD 1               // patrol is dead (killed) after being stoped
#define STATUS_STOPPED 2            // patrol is stopped
#define STATUS_STOPPED1 3           // patrol is stopped in chasm. TODO: now not works, improve it
#define STATUS_WAIT_RESTORE 4       // patrol waits for restore
#define STATUS_DEAD_WAIT_RESTORE 5  // patrol waits for restore after being killed from player[s]

#define DISTANCE_TO_BE_STOPPED 5    // if patrol not moved atfor this distance during check period, it marked as probably STOPPED

//====================== delay before initial patrol creation ==================

#ifdef __DEBUG__
hint localize "+++ x_scripts\x_isledefense.sqf: __DEBUG__ is defined";
#endif

sleep DELAY_BEFORE_SCRIPT_START;

#ifdef __OWN_SIDE_EAST__

// TODO: the closer to the mission finish, the heavier must be patrols
// some patrol types are more frequently generated
#ifndef __VEHICLES_BEFORE_1985__
//                     HEAVY           AA     FLOATING         SPEED         LIGHT     patrol types
_patrol_types = [       "HP",        "AP",        "FP",         "SP",         "LP",        "HP",        "AP",        "HP",        "AP",         "FP"];
#endif
#ifdef __VEHICLES_BEFORE_1985__
//                     HEAVY     FLOATING         SPEED         LIGHT     patrol types
_patrol_types = [       "HP",        "FP",         "SP",         "LP",        "HP",        "HP",        "FP",         "FP"];
#endif

#endif

//
//
//
_make_isle_grp = {
	private ["_units", "_start_point", "_dummycounter", "_agrp", "_elist", "_vecs", "_veh_arr", "_rand", "_leader", "_grp_array","_params","_x"];
	_params = [d_with_isledefense select 0,d_with_isledefense select 1,d_with_isledefense select 2,d_with_isledefense select 3];
	_start_point = []; //_params call XfGetRanPointSquare;
	while {(count _start_point) == 0} do {
		_start_point = _params call XfGetRanPointSquare;
		if ( _start_point call SYG_pointOnIslet ) then {_start_point = [];};  // try next, skip islet point
		sleep 0.4;
	};
#ifdef __PRINT_ACTIVITY__
    hint localize format["+++ x_isledefense.sqf: make isle group, start point %1", _start_point];
#endif
#ifdef __TT__
	sleep 0.753;
#else
	_dummycounter = 0;
	while {_start_point distance FLAG_BASE < 1200 && _dummycounter < 99} do  { // TODO - find start points far from active war zones (airbase, targets etc)
		_start_point = []; //_params call XfGetRanPointSquare;
		 while {count _start_point == 0} do {
			_start_point = _params call XfGetRanPointSquare;
			// check point be on any islet
			if ( _start_point call SYG_pointOnIslet ) then {_start_point = [];}; // try next, skip islet point
			sleep 0.1;
		 };
		sleep 0.753;
		_dummycounter = _dummycounter + 1;
	};
#endif

#ifdef __PRINT_ACTIVITY__
	if ( count _start_point == 0) then {
		hint localize format["+++ %1 x_isledefense.sqf: _start_point %2 is empty []", call SYG_missionTimeInfoStr, _i + 1];
	};
#endif							

	_agrp = grpNull;
    _agrp = call SYG_createGroup;

	_vecs = [];

#ifdef __OWN_SIDE_EAST__
    _type_id      = _patrol_types call XfRandomFloorArray;
    _patrol_type  = _patrol_types select _type_id; // random patrol type selection
    _crew_type    = _patrol_type call SYG_crewTypeByPatrolW;
    _elist        = _patrol_type call SYG_generatePatrolList; // list of vehicle type names
#ifdef __DEBUG__
    hint localize format["+++ patrol veh list %1 created at %2", _elist, [_start_point,"%1 m. to %2 from %3"] call SYG_MsgOnPosE];
#endif

// if in desert region, replace  tanks with desert camouflage
    if (_patrol_type == "HP") then{
        if (_start_point call SYG_isDesert) then { // in desert regions replace ordinal Abrams of patrol to desert ones
            sleep 0.01;
            _elist = _elist call SYG_makeDesertAbrams;
#ifdef __DEBUG__
            hint localize format["+++ HP patrol (vehs %1) created with desert camouflaged Abrams at %2", count _elist, [_start_point,"%1 m. to %2 from %3"] call SYG_MsgOnPosE];
#endif
        };
    };

//#ifdef __PRINT_ACTIVITY__
//    hint localize format["+++ x_isledefense.sqf: crew %1, veh. list %2", _crew_type, _elist];
//#endif

    {
        _veh_arr = [1, _start_point, _crew_type, _x, _agrp, 0, -1.111] call x_makevgroup; // _veh_arr is an array with the vehicle type strings, count is 1st parameneter value (here is 1)
        sleep 0.73; // Magic)))
        [_vecs, _veh_arr] call SYG_addArrayInPlace;
    } forEach _elist;

#else
	_elist = [d_enemy_side] call x_getmixedliste;

	{
		_rand = floor random 3; // 0..2 vehicles to create
		if (_rand > 0) then  {
			_veh_arr = ([_rand,_start_point,_x select 1,_x select 0,_agrp,0,-1.111] call x_makevgroup);
			sleep 0.73;
			//{ _x lock true; } forEach _veh_arr;
			[_vecs, _veh_arr] call SYG_addArrayInPlace;
		};
	} forEach _elist;
//    hint localize format["+++ x_isledefense.sqf: %1 vehicles created", count _vecs];
#endif

	_elist = nil;
	sleep 0.31;
	_units = units _agrp;
    hint localize format["+++ x_isledefense.sqf: %1 vehicle[s] created for patrol type %2, group %3, men %4", count _vecs, _patrol_type, _agrp, count _units]; // _pos call SYG_nearestLocationName

	if ( !(isNull (leader _agrp))) then {
        _leader = leader _agrp;
        _leader setRank "LIEUTENANT";
        _leader setSkill (d_skill_array select 0) + (random (d_skill_array select 1));
        _agrp setFormation "COLUMN";
        _agrp setBehaviour "SAFE";
        _agrp setCombatMode "YELLOW";
        _agrp setSpeedMode "NORMAL";
	};
	_grp_array = [_agrp, _start_point, 0,_params,[],-1,0,[],400 + (random 100),1, [0,false,true,200,true]]; // param 10: [no rejoin,no debug print,prevent wp on islet generation, hills  dist 200, skip in base WP]
	_grp_array execVM "x_scripts\x_groupsm.sqf";
	[_agrp, _units, [0,0,0], _vecs, DELAY_NOT_SET, STATUS_NORMAL, _grp_array, _patrol_type]
}; // _make_isle_grp = {...};

/**
 * ====================================================
 * call: _index call _replace_grp;
 *
 */
_replace_grp =  {
	private ["_igrpa","_i","_x"];
	_i = _this;
#ifdef __PRINT_ACTIVITY__
	hint localize format["+++ %1 x_isledefense.sqf: create/replace patrol group id #%2", call SYG_missionTimeInfoStr, _i];
#endif							
	_igrpa = argp(SYG_isle_grps, _i);
	_igrpa call _remove_grp;
    _igrpa = call _make_isle_grp; // create new group
	SYG_isle_grps set [_i, _igrpa]; // put it to the array

	// mark each vehicle with its patrol group id, later replace integer id with x_smgroup id
	{_x setVariable ["PATROL_ITEM", _i]} forEach argp(_igrpa,PARAM_VEHICLES);

#ifdef __PRINT_ACTIVITY__
    hint localize format["+++ x_isledefense.sqf: group created"];
#endif

	_show_absence = true; // enable patrol absence message
	sleep 3.012;
};

// ====================================================
// call: 
// _ret = _igrpa call remove_grp;
// Returns: nothing
//
_remove_grp = {
	private ["_igrpa","_vecs","_igrp","_units","_crew","_plist","_x"];
	_igrpa = _this;
	_igrp  = argp(_igrpa,PARAM_GROUP);
//	if ( !isNull _igrp ) then
//	{
		_vecs  = argp(_igrpa,PARAM_VEHICLES);
		_units = argp(_igrpa, PARAM_UNITS);
#ifdef __PRINT_ACTIVITY__
		hint localize format["+++ %1 x_isledefense.sqf: remove patrol group %2, vecs %3, men %4", call SYG_missionTimeInfoStr, _igrp, count _vecs, count _units];
#endif						
		
		// clean vehicles
#ifdef __PRINT_ACTIVITY__
		_vec_removed_cnt = 0;
//		_crew_removed_cnt  = 0;
#endif
		{ // forEach _vecs;
			if ( !isNull _x ) then {
			    _xside =  format["%1", side _x];
				if ( alive _x && (!(_x call SYG_vehIsUpsideDown)) &&
				    (
					 (_xside == d_own_side ) ||
					 ( (_xside != d_enemy_side) && ( (getPos _x) call SYG_pointIsOnBase ) && ((getDammage _x) < 0.000001) )
				    ) 
				   )  then { // vehicle was captured by player
					// re-assign vehicle to be ordinal ones
#ifdef __PRINT_ACTIVITY__
					hint localize format["+++ x_isledefense: vec %1 is captured by Russians! Now side is %2, pos on base %3, damage %4", typeOf _x, side _x, (getPos _x) call SYG_pointIsOnBase, damage _x];
#endif
					// put vehicle under system control
					[_x] call XAddCheckDead;
//					_x setVariable ["PATROL_ITEM", nil]; // don't clear patrol flag to keep trophy vehicle in town during clearing procedure
					// added on #434 - inform players in trophy vehicles about
//					_plist = []; // players list for vehicle
//					{ if (isPLayer _x) then { _plist set [count _plist, _x] } } forEach (crew _x);
//					if (count _plist > 0) then { // inform player about
//					    ["msg_to_user", _plist,  [ ["STR_GRU_46_6"]], 0, 2, false, "good_news" ] call XSendNetStartScriptClient; // "You have seized this car from the patrol. Make good use of it!"
					["msg_to_user", _x,  [ ["STR_GRU_46_6"]], 0, 2, false, "good_news" ] call XSendNetStartScriptClient; // "You have seized this car from the patrol. Make good use of it!"
					_x setVariable ["CAPTURED_ITEM","PATROL"]; // #535 - don't clear captured  vehicle in the liberated town. Request by Rokse.
//					};
				} else { // remove all units in vehicles. Todo: Why not delete them? May be they will append to any enemy group nearby?
					{
						_x action["Eject", vehicle _x]; 
//						sleep 0.33;
//						_x setDammage 1.1;
//						sleep 0.1;
//						deleteVehicle _x;
//#ifdef __PRINT_ACTIVITY__
//						_crew_removed_cnt = _crew_removed_cnt + 1;
//#endif
					} forEach crew _x;
					sleep 0.3;
					deleteVehicle _x;
#ifdef __PRINT_ACTIVITY__
					_vec_removed_cnt = _vec_removed_cnt + 1;
#endif
				};
			};
			sleep 0.1;
		} forEach _vecs;
		_vecs = nil;
		sleep 1.06;
#ifdef __PRINT_ACTIVITY__
    _str = "isNull";
    if ( !isNull _igrp) then { _str = format["is active and has %1(%2 not null) units", count units _igrp, {!(isNull _x)} count (units _igrp)] }
    else { _str = format["isNull, had %1(%2 not null) units", count _units, {!(isNull _x)} count _units] };
		hint localize format["+++ x_isledefense: start remove group: removed vecs %1, remained _units %2, grp %3", _vec_removed_cnt, count _units, _str];
#endif
		// clean units
#ifdef __PRINT_ACTIVITY__
		_units_removed_cnt     = 0;
		_grp_units_removed_cnt = 0;
#endif
		{ // forEach _units;
			if (!isNull _x) then {
				if (alive _x) then {_x setDammage 1.1; sleep 0.3;};
				deleteVehicle _x;
	//			[_x] call XAddDead;
				sleep 0.1;
#ifdef __PRINT_ACTIVITY__
                _units_removed_cnt = _units_removed_cnt + 1;
#endif
			};
		} forEach _units;
		sleep 1.04;
		_units = nil;
		
		// clean group
		{ // forEach units _igrp;
			if (!isNull _x) then {
				if (alive _x) then {_x setDammage 1.1; sleep 0.3;};
				deleteVehicle _x;
	//			[_x] call XAddDead;
				sleep 0.1;
#ifdef __PRINT_ACTIVITY__
                _grp_units_removed_cnt = _grp_units_removed_cnt + 1;
#endif

			};
		} forEach units _igrp;
		sleep 0.1;
#ifdef __PRINT_ACTIVITY__
        hint localize format["+++ x_isledefense: finish remove group: count units grp %1, removed _units %2, removed grp units %3",count units _igrp, _units_removed_cnt,  _grp_units_removed_cnt];
#endif

		_igrp = nil;
		_igrpa set [PARAM_GROUP, grpNull]; // mark it removed
//	};
};

/*
 * call:
 *     _arr2 = [_igrp,_vecs] call _getFeetmen;
 * Where:
 *     _arr2 == [_feetmen,_invalid_men]; // _feetmen == [_unit1, _unit2 ...]; _invalid_men = [_unitN,_unitN1 ...];
 */
_getFeetmen = {
	private ["_igrp","_units","_vecs","_feetmen","_invalid_men","_veh","_leader","_x"];
	_igrp  = arg(0);
	_units = units _igrp;
	_vecs  = arg(1);
	if ( typeName _units == "GROUP" ) then {_units = units _this;}; // else it is already unit array
	_feetmen = []; _invalid_men = [];
	{ // forEach _this;
		if ( !isNull _x && vehicle _x == _x) then
		{
			if ( alive _x && canStand _x ) then { _feetmen = _feetmen + [_x];} else {_invalid_men = _invalid_men + [_x];};  // count as feetman
			
			if ( _x == leader _igrp ) then 
			{
				// select other leader in moveable vehicle
				_veh = objNull;
				
				{  if ( (!isNull _x) && (canMove _x) && (count crew _x > 0) && (!isNull driver _x ) && (canStand driver _x) ) exitWith {_veh = _x;}; } forEach _vecs;
				
				if (!isNull _veh) then
				{	
					_x setRank "PRIVATE";
					sleep 0.01;
					_leader = effectiveCommander _veh;
					_x setRank "PRIVATE";
					_igrp selectLeader _leader;
					sleep 0.01;
					_leader setRank "LIEUTENANT";
					sleep 0.01;
#ifdef __PRINT_ACTIVITY__
					hint localize format["+++ %4 x_isledefense.sqf: Move leadership from feetman %1 to the crewman %2 (%3)", _x, _leader, typeOf _veh, call SYG_missionTimeInfoStr];
#endif									
				};
			};
		};
	} forEach _units;
	
	[_feetmen,_invalid_men]
};

//
// call: 
// ...
// _veh = [_veh1,_veh2 ...] call _firstGoodVehicle;
// if ( !isNull _veh) then {player hint format["First alive vehicle is %1",_veh];} else {player hint "No alive vehicle detected";}
//...
//
_firstGoodVehicle = {
	private ["_veh", "_crew_not_east_or_zero","_x"];
	_veh = objNull;
	{
		_crew_not_east_or_zero = if (!isNull _x) then { if ( ({alive _x} count (crew _x)) > 0 ) then { (side _x) != east } else {true} } else {true};
		if ( (!isNull _x && alive _x) && ({alive _x} count (crew _x) > 0) && _crew_not_east_or_zero && (!isNull driver _x ) && (canMove driver _x) ) exitWith {_veh = _x;};
	} forEach _this;
	_veh
};

//
// call: _vehCnt = [_veh1,_veh2 ...] call _countNonEmptyVehicles;
//
_countNonEmptyVehicles = {
	private ["_cnt","_x"];
	_cnt = 0;
	{
		if ( ({alive _x} count (crew _x)) > 0 ) then {_cnt  = _cnt + 1; } ;
	} forEach _this;
	_cnt
};

/*
 _aliveVehCount = {
	{ (!isNull _x) && (canMove _x) && (!isNull driver _x)} count _this
};
 */
// call: nul = _igrpa call _setStateNormal;

_setStateNormal = {
	_this set [PARAM_STATUS, STATUS_NORMAL];
	_this set [PARAM_TIMESTAMP, DELAY_NOT_SET];
};

/**
 * call: [ [_feetmen1,...], [_invalid_man1,...], [_vec1,...]] call _utilizeFeetmen;
 * returns: nothing
 */
_utilizeFeetmen = {
	private  ["_feetmen","_invalid_men","_vecs","_goal_grp"];
	_feetmen = arg(0);
	_invalid_men = arg(1);
	_vecs = arg(2);

	// remove invalid men directly now
	if ( count _invalid_men > 0 ) then {
#ifdef __PRINT_ACTIVITY__
		hint localize format["%+++ %1 x_isledefense.sqf: invalid %2 are killed", call SYG_missionTimeInfoStr, _invalid_men];
#endif								
		{ 
			if ( !isNull _x ) then {
				if ( alive _x) then {_x setDammage 1.1; sleep 1.1;};  // let them lay down while removing with whole patrol
//						deleteVehicle _x;
//						[_x] call XAddDead;
				sleep 0.01;
			};
		} forEach _invalid_men;
		_invalid_men = [];
	};
	
	if ( count _feetmen > 0) then // handle with men on feet
	{
		// try to re-join to some near target (target town, airbase, re-occupied town)
		_goal_grp = [_feetmen select 0, 500, 5] call SYG_findGroupAtTargets;
		if ( !isNull _goal_grp ) then {// assign all feetmen to this group
#ifdef __PRINT_ACTIVITY__
			hint localize format["+++ %1 x_isledefense.sqf: %2 joined to a target group %3 (%4 men) at dist %5", call SYG_missionTimeInfoStr, _feetmen, _goal_grp, count units _goal_grp, (_feetmen select 0) distance (leader _goal_grp)];
#endif								
			_feetmen join _goal_grp;
			sleep 0.203;
			_feetmen = [];
		} else {// try to board feetmen into available vehicles
			_feetmen = [_feetmen, _vecs] call SYG_findAndAssignAsCargo;
		};
	};
	
	if ( count _feetmen > 0) then { // kill surplus men on feet
#ifdef __PRINT_ACTIVITY__
		hint localize format["+++ %1 x_isledefense.sqf: surplus feetmen %2 are killed", call SYG_missionTimeInfoStr,_feetmen];
#endif								
		{
			if ( !isNull _x && alive _x ) then { _x setDammage 1.1; sleep 1.1 }; 
//					deleteVehicle _x; // Let them to lay down. They will be removed later
//					[_x] call XAddDead;
			sleep 0.01;
		} forEach _feetmen;
		_feetmen = [];
	};
};

SYG_isle_grps = []; // array for isledefence groups

SYG_patrolGroupNumber = {
	{!isNull (_x select PARAM_GROUP)} count SYG_isle_grps;
};

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++ START OF PATROLS ++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// if this is re-run of script, count already existing patrol groups
_patrol_cnt = d_with_isledefense select 4;
_patrol_cnt = (_patrol_cnt - (count SYG_isle_grps)) max 0; // how many patrol to add to normal count
if ( _patrol_cnt > 0) then {
    for "_i" from 1 to _patrol_cnt do {
        SYG_isle_grps set [count SYG_isle_grps, [ grpNull, [], [0,0,0], [], time + DELAY_ON_PATROL_INIT * _i, STATUS_WAIT_RESTORE, [] ]]; // initiate new patrols creation after some sequential time-out
        sleep 3.012;
    };
};
_dead_patrols = 0; // how many patrols are currently dead
_show_absence = false; // disable patrol absence message at start as patrol are still absent

// send info about starting of patrolling of island
["msg_to_user","",[["STR_SYS_1146"]],0, 10 + random 10] call XSendNetStartScriptClient; // "GRU reports that the enemy began patrolling the island with armored forces"

_exit = false; // exit from nearly eternal loop
//_patrol_cnt = 0; // active patrol counter
//
//=============================== M A I N   L O O P  O N  P A T R O L S =========================
//
//  if( current_counter > number_targets ) exitWith {"All towns complated, no more patrols"}
_last_cnt = 0; // patrol counter detected during last loop
while { true } do {

    _time = time; // mark time just in case
	if (X_MP) then { if ((call XPlayersNumber) == 0) then {waitUntil { sleep 15; (call XPlayersNumber) > 0 }; } };
	if ( (time - _time) >= DELAY_RESPAWN_STOPPED ) then {// mission returned after first player waiting
	    _delta = time - _time;  // how many time mission was sleeping without movement
	    hint localize format["+++ x_isledefense: after sleeping during %1 sec. next player entered and respawn patrols timeouts updated.", round(_delta)];
	    {
	        _new_timestamp = argp(_x, PARAM_TIMESTAMP) + _delta;
            _x set [PARAM_TIMESTAMP, _new_timestamp]; // increment timestamp to continue same behaviur as before sleep
	    } forEach SYG_isle_grps;
	};

	//__DEBUG_NET("x_isledefense.sqf",(call XPlayersNumber))
//#ifdef __PRINT_ACTIVITY__
//    hint localize "+++ x_isledefense.sqf: loop start";
//#endif
	//
	// ===================== MAIN LOOP ON EACH PATROL ===========================
	//
	for "_i" from 0 to (count SYG_isle_grps - 1) do {
		scopeName "main_loop";
		_enemy_near     = false;
		_may_be_stucked = false;
		_vecs = [];
		
		_igrpa         = argp( SYG_isle_grps, _i ); // array of group parameters
		_igrp          = argp( _igrpa, PARAM_GROUP ); // group itself
		if ( !isNull _igrp ) then {// alive patrol detected
			_grp_array      = argp(_igrpa,PARAM_GRP_ARRAY); // group array used by x_groupsm.sqf
			_enemy_near     = !((_grp_array select 2) in [0,2]);
			_may_be_stucked = ((_grp_array select 2) == 9); // some strange stuck state produced in x_groupsm.sqf
		};	
		_stat          = argp(_igrpa, PARAM_STATUS); // status of patrol group
		_timestamp     = argp(_igrpa, PARAM_TIMESTAMP); // time to wait before create new patrol
		_igrppos       = argp(_igrpa, PARAM_LAST_POS); // last stored position of the group
//#ifdef __PRINT_ACTIVITY__
//        hint localize format["+++ x_isledefense.sqf: loop id %1, grp %2, stat %3, timestamp %4, pos %5 ", _i, _igrp, _stat, _timestamp, _igrppos];
//#endif

		for "_j" from 0 to 0 do {// dummy cycle only for main scope creation

            // replace group waiting for restore with new one if wait time is out
			if ( _stat == STATUS_WAIT_RESTORE  || _stat == STATUS_DEAD_WAIT_RESTORE) then {
			    if ( (current_counter >= number_targets) /* && (!main_target_ready)*/ ) then {
			        // not replace dead group as enemy is fled
                #ifdef __PRINT_ACTIVITY__
                    hint localize format["+++ x_isledefense: patrol #%1 will not be restored as all main targets completed", _i];
                #endif
   					_igrpa set [PARAM_STATUS, STATUS_STUB];
			        // TODO: Send remaining  groups to a certain point on the coast, with the goal of transporting them back to the United States
			        // TODO: select this point from predefined ones set manually in the editor
			        breakTo "main_loop";
			    };

				if (time > _timestamp) then {
					_i call  _replace_grp;
					//_dead_cnt = _dead_cnt - 1; // one more patrol added
					if ((random 10) > 3) then  {// inform user about new patrol with probability 0.7
                        _igrpa = argp(SYG_isle_grps, _i); // get this group
                        {
                            if ( alive _x ) exitWith {
                                _witness = call SYG_getLocalManRandomName;
                                _pos     = position _x;
                                _size    = count argp(_igrpa, PARAM_VEHICLES);
                                _pattype = argp(_igrpa, PARAM_TYPE); // get patrol type for colonel

                                ["GRU_msg_patrol_detected", GRU_MSG_INFO_TO_USER, GRU_MSG_INFO_KIND_PATROL_DETECTED, [_witness, _pos, _size, _pattype]] call XSendNetStartScriptClient;
                            };
                        } forEach argp(_igrpa, PARAM_VEHICLES); // this lopp check if patrol created has at least one vehicle
					};
    				if (_stat == STATUS_DEAD_WAIT_RESTORE) then {_dead_patrols = (_dead_patrols -1) max 0;};
				};

				breakTo "main_loop";
			};
			
			if ( _stat == STATUS_DEAD ) then { // set new time-out for restore procedure after dead, nothing more to do
				if (time > _timestamp) then { // set dynamical restore delay
					_igrpa call  _remove_grp; // they disappeared, but patrol be restored later, after designated delay
					_igrpa set [PARAM_STATUS, STATUS_DEAD_WAIT_RESTORE];
					_dead_cnt =  ((_dead_patrols max 1) min (_patrol_cnt - 1));
					_delay = DELAY_RESPAWN_KILLED * _dead_cnt; // delay multiplied by 1..4
#ifdef	__PRINT_ACTIVITY__
					hint localize format["+++ x_isledefense.sqf: DEAD GROUP restore delay %1 * %2 = %3", DELAY_RESPAWN_KILLED, _dead_cnt, _delay];
#endif
					_igrpa set [PARAM_TIMESTAMP, time + _delay];
				};
				breakTo "main_loop";
			};

            if ( _stat == STATUS_STUB ) then { breakTo "main_loop"};

			_vecs = argp(_igrpa, PARAM_VEHICLES);

			// define real status of current patrol. According to previous state patrol was not dead
			_dead = false;
			_veh = objNull;
			
			// check group men
			if (  isNull _igrp ) then {
				_dead = true;
			} else {
				if ( ((_igrp call XfGetHealthyUnits) == 0) && (_vecs call _countNonEmptyVehicles) == 0 ) then {
					_dead = true; 
				} else {// check vehicles
					_veh =  _vecs call _firstGoodVehicle;
					if ( isNull _veh ) then {
						_dead = true;
					};
				};
			};
			//_dead_cnt = _dead_cnt + 1; // one more patrol is dead
			if ( _dead ) then {// set new status dead && loop next patrol
				// the more dead the larger interval to restore
				_igrpa set [   PARAM_STATUS, STATUS_DEAD];
				_igrpa set [PARAM_TIMESTAMP, time + DELAY_REMOVE_DEAD];
				_dead_patrols = (_dead_patrols + 1) min (_patrol_cnt - 1);
				breakTo "main_loop"; // wait until patrol removed && replaced
			};
			
			_ret              = [_igrp,_vecs] call _getFeetmen;
			_feetmen          = argp(_ret,0);
			_invalid_men      = argp(_ret,1);
			
			if ( isNull _veh ) then {// no more vehicles
				if ( count _feetmen > 0 ) then {
					if ( !_enemy_near ) then {
						[_feetmen, _invalid_men, _vecs] call _utilizeFeetmen;
						_igrpa set [   PARAM_STATUS, STATUS_DEAD];
						_igrpa set [PARAM_TIMESTAMP, time + DELAY_REMOVE_DEAD];
						_dead_patrols = (_dead_patrols + 1) min (_patrol_cnt - 1);
					} else  {// let them to kill enemy
						_igrpa call _setStateNormal;
					};
				};
				breakTo "main_loop";
			};
			
			if ( _enemy_near  && (!_may_be_stucked)) then {
				_igrpa call _setStateNormal;
				breakTo "main_loop";
			};
			
			//
			// ====== NO ENEMY NEAR THIS PATROL AND THERE ARE SOME BATTLEWORTHY VEHICLES ======
			//
			
			if ( _stat == STATUS_STOPPED  || _stat == STATUS_STOPPED1) then {
				if ( time > _timestamp ) then {// patrol is near same point during long period of time, check around now
				    if ( _stat == STATUS_STOPPED) then {// patrol is stopped, but may be in chasm
                        // check patrol leader to be in chasm
                        _pos = getPos (leader _igrp);
                        _exitWP =  _pos call SYG_chasmExitWP;
                        if ( (count _exitWP) == 3 ) then {// yes we are in chasm, try to find way out
#ifdef __PRINT_ACTIVITY__
                            hint localize format[ "+++ %1 x_groupsm.sqf: %2 group %3 in chasm at %4, finding exit", call SYG_nowTimeToStr, argp(_igrpa,PARAM_TYPE), _igrp, _pos call SYG_nearestLocationName ];
#endif
                            // redirect patrol to exit from the chasm
                            // Let's get the hell out of here.
                   			_igrp setCombatMode "GREEN";
							_igrp setFormation "COLUMN";
							_igrp setSpeedMode "FULL"; // go-go-go
							_igrp setBehaviour "CARELESS";
                            (units _igrp) doMove _exitWP;
                            _grp_array set [4, _exitWP]; // current assigned wp
                            _grp_array set [5, time];  // current time when wp was assigned
                            _grp_array set [7, _pos]; // start position before assigning wp
                            _grp_array set [2, 0]; // initial mode of group, will be changed in progress of group engaging
               				_igrpa set [ PARAM_STATUS, STATUS_STOPPED1 ];
	    					_igrpa set [ PARAM_TIMESTAMP, time + DELAY_REMOVE_STOPPED ];
    						breakTo "main_loop";
                        };
				    };
					if ( (_igrppos distance (leader _igrp)) > DISTANCE_TO_BE_STOPPED ) then {// clear stopped state as patrol move far enough from stop point
						// stop status is broken by good movement
						_igrpa call _setStateNormal;
					} else {// it is really stopped, but if enemy near, let fun continue
						if ( _enemy_near && (time < (_timestamp + DELAY_VERY_LONG_STOPPED) )) then {
							breakTo "main_loop"; // let him more time to handle with players
						};
						_igrpa call  _remove_grp; // let them to disappear and restore in new patrol group later after designated delay
						// TODO: send info to users about
						
						_igrpa set [PARAM_STATUS, STATUS_WAIT_RESTORE];
						_igrpa set [PARAM_TIMESTAMP, time + DELAY_RESPAWN_STOPPED];
			
						breakTo "main_loop";
					};
				};
			};
			
			//
			//========== Some vehicles with alive driver can move. Play with feetmen =============
			//
			
			[_feetmen, _invalid_men, _vecs] call _utilizeFeetmen;
			
		}; // for "_j" from 0 to 0 do - temp loop to allow external scope usage

		if ( _stat == STATUS_NORMAL ) then {
			if ( ((leader _igrp) distance _igrppos) < DISTANCE_TO_BE_STOPPED ) then {
				_igrpa set [PARAM_STATUS, STATUS_STOPPED];
				if ( _may_be_stucked ) then {
					_igrpa set [PARAM_TIMESTAMP, time + DELAY_REMOVE_STUCKED];
				} else {
					_igrpa set [PARAM_TIMESTAMP, time + DELAY_REMOVE_STOPPED];
				};
			} else {
				_igrpa set [PARAM_LAST_POS, position leader _igrp] 
			};// update last position
		};

		sleep DELAY_BETWEEN_EACH_PATROL_CHECK;
	}; // for "_i" from 0 to (count SYG_isle_grps - 1) do

	sleep DELAY_BETWEEN_CHECK_LOOP;

	// ==================================== END OF LOOP ON PATROLS ======================================
#ifdef __PRINT_ACTIVITY__
	// igrpa: [_agrp, _units, [0,0,0], _vecs]
    _groups_arr_side = compile toLower (format["groups_%1", d_enemy_side]);
	hint localize format["+++ x_isledefense.sqf: %1, target ""%2""(%3), groups on isle count %4(%5)",
	    call SYG_missionTimeInfoStr,
	    call SYG_getTargetTownName,
	    current_counter,
	    d_side_enemy call SYG_sideGroupsCount,
	    count groups_west
	];
	_str = "";
	_cnt = 0; // number of active patrols
	for "_i" from 0 to (count SYG_isle_grps - 1) do {
		_igrpa = SYG_isle_grps select _i; // patrolling group 
		_igrp  = argp(_igrpa,PARAM_GROUP); 
		if ( isNull _igrp ) then {
    		_stat = argp( _igrpa, PARAM_STATUS ); // status of patrol group
            if ( (_stat  == STATUS_DEAD) || (_stat  == STATUS_DEAD_WAIT_RESTORE)) then {_str  = _str + "<DEAD>; ";}
            else {
                if ( _stat  == STATUS_STUB ) then { _str  = _str + "<EXPIRE>; "}
                else {
                    //  if (_stat == STATUS_WAIT_RESTORE) ...
                    _str  = _str + "<EMPTY>; ";
                };
            }; // group/vehicles not exist more
		} else {
			_vecs = argp(_igrpa, PARAM_VEHICLES); // vehicles
			_veccnt = count _vecs;
			_veccnta = 0; // count of alive vehicles with some crew on board
			{
				if (!isNull _x) then {
					if ( ( count crew _x ) > 0 ) then { _veccnta = _veccnta + 1; };
				};
			} forEach _vecs;
			
    		_stat = argp( _igrpa, PARAM_STATUS ); // status of patrol group
			if ( _veccnta == 0 ) then {
	    		if ( (_stat  == STATUS_DEAD) || (_stat  == STATUS_DEAD_WAIT_RESTORE)) then {_str  = _str + "<DEAD>; ";}
	    		else {_str  = _str + "<EMPTY>; ";}; // group/vehicles not exist more
			} else {
				_locname = "";
	 		    _leader = _igrp call SYG_getLeader;
				_men_info = "";
				_pos_msg = "";
				if ( isNull _leader) then {
					_pos_msg = "(<no leader>)";
				} else {
					_units = units _igrp;
					// initial  units, conscious units, out of vehicles alive
					_men_info = format["{%1/%2/%3}",_units call XfGetAliveUnits, _units call SYG_getAllConsciousUnits, _units call XfGetUnitsOnFeet ];
					_pos_msg = [_leader,"%1 m. to %2 from %3"] call SYG_MsgOnPosE;
				};
				_grp_array   = argp(_igrpa,PARAM_GRP_ARRAY);
				_enemy_near  = if ((_grp_array select 2) in [0,2]) then {""} else { if ((_grp_array select 2) == 9) then {"!"} else {"*"}};
				_patrol_type = argp(_igrpa,PARAM_TYPE);
				_str = _str + format["(%1) %2/%3/%4%5%6; ", _pos_msg, _patrol_type, _veccnt, _veccnta,  _enemy_near, _men_info];
				_cnt = _cnt + 1;
			};
		};
	};  // while {true} do
	if ( _cnt > 0) then {
#undef __SHOW_PATROL_CHANGE_INFO__ // not show lower message
#ifdef __SHOW_PATROL_CHANGE_INFO__
	    if ( _cnt != _last_cnt ) then {
	        if ( random 2 < 1) then {
	            // show message about some patrol activity
                // "The guerrillas said some of the changes in the number of patrols"
                ["msg_to_user","",[["STR_SYS_1145"]],4,4 + round(random 4)] call XSendNetStartScriptClient;
	        };
	    };
#endif
        hint localize format[ "+++ %1 +++", _str ];
	} else  { // send info about patrol absence
	    if ( _show_absence && (_last_cnt != 0)) then {
	        if ((random 1) <= SHOW_ABSENCE_PROBABILITY ) then { // inform users about patrol absence
                ["GRU_msg_patrol_detected", GRU_MSG_INFO_TO_USER, GRU_MSG_INFO_KIND_PATROL_ABSENCE ] call XSendNetStartScriptClient;
        	    if ( (current_counter >= number_targets) /** && (!main_target_ready) */ ) then { _exit = true };
	        };
            _show_absence = false; // disable patrol absence message
	    };
	};
	if (_last_cnt != _cnt ) then {
	    _last_cnt = _cnt;
        __SetGVar(PATROL_COUNT, _cnt);
	};
#endif
    if ( _exit ) exitWith {
        sleep 10;
        // "The GRU reports that the enemy abandoned his plans to patrol the island! This is our victory!"
        ["msg_to_user","",[["STR_SYS_1147"]],0,4 + round(random 4), false, "fanfare"] call XSendNetStartScriptClient;
        hint localize "+++ x_isledefense.sqf: stop isle defence system as all target towns are liberated !!!";
    };
}; // while