// by Xeno, x_scripts\x_groupsm.sqf
// 	example: _grp_array = [_paragrp, [position _leader select 0, position _leader select 1, 0], 0,[d_base_array select 0,d_base_array select 1,d_base_array select 2,0],[],-1,1,[],300,1];
// Parameters indexes (max index 10, from 0 to 10):
// at 0: group to rule; _paragrp
// at 1: [] some initial position before script calling; [position _leader select 0, position _leader select 1, 0]
// at 2: initial mode of group, will be changed in progress of group engaging; 0
// at 3: patrol rectangle [_center_pos, rx, ry, dir] or circle [_center_pos, radius]; [d_base_array select 0,d_base_array select 1,d_base_array select 2,0]
// at 4: current assigned wp;[]
// at 5: current time when wp assigned;-1
// at 6: if ((_grp_array select 6) == 0) then {[_grp,_grp_array select 9] call XNormalPatrol;} else {_grp call XCombatPatrol;}; ;1
// at 7: start position before assigning wp; []
// at 8: some distance to react for enemy found (may be 300 meters); 300 // TODO: not used, may be remove it?
// at 9: can be -1 (for guard static) ->"no patrol", 0 and +1 -> "patrol"; XNormalPatrol: if ((_this select 1) == 0) then {["COLUMN","STAG COLUMN","FILE"]} else {["COLUMN"]}; 1
//
// at 10: [] with some additional parameters by Sygsky, optional
// at 10.0: number of stand units to try rejoin them. Optional. Set 0 or negative value to disable rejoin. Default 0
// at 10.1: debug print any new waypoints if TRUE and not if FALSE. Optional. Default FALSE
// at 10.2: prevent new wp be on islet (TRUE) or not (FALSE). Optional.  Default FALSE, i.e. not prevent WP be on Islet
// at 10.3: distance to detect hill near new wp. Optional.  Default 0, i.e. not seek for hills near WP
//-----------------------------------------------------------------------------------------------------------------------

private ["_grp_array", "_grp", "_enemy_array", "_reached_wp", "_time_at_wp", "_next_wp_time", "_units", 
         "_checktime", "_flank_pos_a",/*  "_make_normal",  */"_leader", "_start_pos", "_wp_array", "_wp_one", 
		 "_wp_pos", "_counter", "_stime","_had_towait", "_side", "_joingrp","_leader1","_rejoin_num","_i","_debug_print","_skip_islets","_hills_seek_dist","_all_grp_list"];
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

// try to re-join each 10 minutes (600 secs)
#define REJOIN_RERIOD 600
// try to re-join only to groups not far then 1000 meters
#define REJOIN_DISTANCE 1000
#define __DEBUG__

_grp_array = _this;

_grp = _grp_array select 0;

// _rejoin_num means if group allowed to rejoin to bigger one is nearly destroyed (1 man in group canMove only)
_rejoin_num      = 0;
_rejoin_time     = 0; // time for next re-join
_debug_print     = false;
_skip_islets     = false;
_hills_seek_dist = 0;
if ( count _grp_array > 10 && (typeNAME (_grp_array select 10) == "ARRAY") ) then
{
	_wp_array = _grp_array select 10;
	if ( count _wp_array > 0) then {    _rejoin_num  = _wp_array select 0;};
	if ( count _wp_array > 1) then {    _debug_print = _wp_array select 1;};
	if ( count _wp_array > 2) then {    _skip_islets = _wp_array select 2;};
	if ( count _wp_array > 3) then {_hills_seek_dist = _wp_array select 3;};
};

_enemy_array = [];
_reached_wp = true;
_time_at_wp = 15 + random 15;
_next_wp_time = 0;

_units = units _grp;
if ( count _units == 0) exitWith {};

sleep (20 + random 20);

_grp_array set [2,0];
_checktime = 0;
_flank_pos_a = [];

_start_pos =  _grp_array select 4;
if (count _start_pos < 3 ) then {_grp_array set[4, position (leader _grp)]};
_wp_pos = _start_pos;

while {true} do {

	// check group to be empty or dead
	if (isNull _grp || ((_grp call XfGetAliveUnitsGrp) == 0)) exitWith { hint localize format["x_groupsm.sqf: group with WP near %1 is dead", text (_wp_pos call SYG_nearestLocation)];}; // exit if group is empty or dead

	if (X_MP) then {
		//hint localize format["x_groupsm.sqf: call XPlayersNumber == %1",(call XPlayersNumber)];
		sleep (1.012 + random 1);
		if ((call XPlayersNumber) == 0) then {
            waitUntil {sleep (5.012 + random 1);(call XPlayersNumber) > 0};
			_units = units _grp;
			// refuel all vehicles after player wait periods
            {
                if (alive _x) then
                {
                    if (vehicle _x != _x) then
                    {
                        (vehicle _x) setFuel 1;
                    };
                };
                sleep 0.01;
            } forEach _units;
		};
	};
	_units = units _grp;
	//__DEBUG_NET("x_groupsm.sqf",(call XPlayersNumber))
	// state is in _grp_array select 2
	switch (_grp_array select 2) do {
		case 0: { // quiet initial state, nothing unusual
			_enemy_array = _grp_array call x_get_nenemy; // returns array [enemy, enemy_pos, enemy_knowlege];
			if (count _enemy_array > 0) then 
			{
				if (_enemy_array select 2 >= 1.5) then // we knew about him!
				{
					if ((leader _grp) distance (_enemy_array select 1) > 20) then 
					{
						_grp_array set [2,3];
					} else 
					{
						_grp_array set [2,1];
					};
				} else 
				{
					_grp_array set [2,9];
				};
			} else {
				// if it is a patrol group then patrol
				if (_grp_array select 9 >= 0) then {
					_grp_array set [2,2];
				};
			};
		};
		case 1: { // targeting/attacking very close enemy ( <= 20 m. )directly during 2 next minutes
			_grp setCombatMode "YELLOW";
			_grp setSpeedMode "NORMAL";
			_grp setBehaviour "AWARE";
			_grp setFormation (["WEDGE","LINE"] call XfRandomArrayVal);
			_checktime = time + 120 + random 10;
			{
				_x doWatch (_enemy_array select 1);
				_x doTarget (_enemy_array select 0);
				sleep 0.012;
			} forEach _units;
			_grp_array set [2,8];
		};
		case 2: { // patrolling, setting new waypoint to follow
			_leader = leader _grp;
			if (isNull _leader) exitWith {_grp_array set [2,0]};
			sleep 0.01;
			if (_reached_wp) then {
				if (time < _next_wp_time) exitWith {_grp_array set [2,0]};
				_start_pos = position _leader;
				_reached_wp = false;
				sleep 0.01;
				if (!isNull _grp) then {
					if ((_grp call XfGetAliveUnitsGrp) > 0) then {
						_wp_array = _grp_array select 3;
						if ( (typeName _wp_array) == "ARRAY" ) then {
							if ((count _wp_array) == 2 || (count _wp_array) == 4) then { // 2 for circle (center+radius), 4 for rectangle (center, dx, dy, dir)
								_wp_one = _wp_array select 0;
								if (count _wp_one == 0) exitWith {_grp_array set [2,0]};
								_wp_pos = switch (count _wp_array) do {
									case 2: {[_wp_one, _wp_array select 1] call XfGetRanPointCircleOld};
									case 4: {[_wp_one, _wp_array select 1, _wp_array select 2, _wp_array select 3] call XfGetRanPointSquareOld};
									default {[]};
								};
								if (_skip_islets) then
								{
									// check if point is on some islet near main Sahrani Isle (Rahmadi is always allowed for patrolling)
									if (_wp_pos call SYG_pointOnIslet) then 
									{
#ifdef __DEBUG__
										hint localize format["%1 x_groupsm.sqf: grp %2, new wp %3 is on islet (code 1)",call SYG_nowTimeToStr,_grp, _wp_pos];
#endif							
										_wp_pos = [];
									};
								};
								if (count _wp_pos == 0) exitWith {_grp_array set [2,0]};
								_counter = 0;
								while {_wp_pos distance _start_pos < 20 && _counter < 50} do {
									_wp_pos = switch (count _wp_array) do {
										case 2: {[_wp_one, _wp_array select 1] call XfGetRanPointCircleOld};
										case 4: {[_wp_one, _wp_array select 1, _wp_array select 2, _wp_array select 3] call XfGetRanPointSquareOld};
									};
									// check if point is on some islet near main Sahrani Isle (Rahmadi is always allowed for patrolling)
									if (_skip_islets) then
									{
										
										if ( _wp_pos call SYG_pointOnIslet ) then 
										{
#ifdef __DEBUG__
											hint localize format["%1 x_groupsm.sqf: new wp %2 is on islet (code 2), counter %3",call SYG_nowTimeToStr,_wp_pos,_counter];
#endif							
											_wp_pos = _start_pos
										};
										_counter = _counter + 1;
										sleep 0.02;
									};
								};
								if (count _wp_pos == 0) exitWith {_grp_array set [2,0]};
								if ((_grp_array select 6) == 0) then {
									[_grp,_grp_array select 9] call XNormalPatrol;
								} else {
									_grp call XCombatPatrol;
								};
								(units _grp) doMove _wp_pos;
								if ( _debug_print ) then
								{
									hint localize format["%1 x_groupsm.sqf: group %2 - > set new WP %3 near %4",call SYG_nowTimeToStr,_grp, _wp_pos, text (_wp_pos call SYG_nearestLocation)];
								};
								_grp_array set [4, _wp_pos];
								_grp_array set [5, time];
								_grp_array set [7, _start_pos];
							};
						} else
						{
							hint localize format[ "--- x_groupsm: expected _wp_array not ARRAY => %1", _grp_array];
						}
					};
				};
			} else { // if (_reached_wp) then {
				if (isNull _grp || (_grp call XfGetAliveUnitsGrp) == 0) exitWith {};
#ifdef __DEBUG__			
				if ( count (_grp_array select 4) != 3 ) then
				{
					hint localize format["%1 x_groupsm.sqf: grp %2, count of next wp coords (_grp_array select 4) == %3 ",call SYG_nowTimeToStr, _grp,count (_grp_array select 4)];
				};
#endif				
				
				if ((position _leader) distance (_grp_array select 4) < 10) then {
					_reached_wp = true;
					_next_wp_time = time + _time_at_wp;
				} else { // timeout
					_stime = _grp_array select 5;
					if (time - _stime > 360) then {
						_reached_wp = true;
						_next_wp_time = 0;
					} else {
						if ((position _leader) distance (_grp_array select 7) < 5) then {
							_reached_wp = true;
							_next_wp_time = 0;
						} else {
							_grp_array set [7, position _leader];
						};
					};
				};
			};
			_grp_array set [2,0];
		};
		case 3: { // start flanking enemy. Time of processing is about 5 minutes
			_grp setCombatMode "YELLOW";
			_grp setSpeedMode "NORMAL";
			_grp setBehaviour "AWARE";
			_grp setFormation (["WEDGE","LINE"] call XfRandomArrayVal);
			{
				if (alive _x) then {
					_x setUnitPos "AUTO";
				};
				sleep 0.01;
			} forEach _units;
			_checktime = time + 300 + random 10;
			_flank_pos_a = [position (leader _grp),_enemy_array select 1] call XfGetFlankPos;
			sleep 0.1;
			_units doMove (_flank_pos_a select 0);
			_grp_array set [2,4];
		};
		case 4:
		{ // check flanking pos on X less than 20 meters to enemy
			if ((leader _grp) distance (_flank_pos_a select 0) < 20 || (time > _checktime)) then {
				_units doMove (_flank_pos_a select 1);
				_grp_array set [2,5];
				_checktime = time + 300 + random 10;
			};
		};
		case 5: {  // check flanking pos from _flankarray = [position player, position _enemy1]. On enemy close switch to case 6
			if ((leader _grp) distance (_flank_pos_a select 1) < 20 || (time > _checktime)) then {
				if (!isNull (_enemy_array select 0) && (leader _grp) knowsAbout (_enemy_array select 0) >= 1.5) then {
					_enemy_array set [1, position (_enemy_array select 0)];
				};
				_units doMove (_enemy_array select 1);
				_grp_array set [2,6];
				_checktime = time + 300 + random 10;
			};
		};
		case 6: { // if enemy closer than 20 meters, do case 7
			if ((leader _grp) distance (_enemy_array select 1) < 20 || (time > _checktime)) then {
				_checktime = time + 60 + random 10;
				_grp_array set [2,7];
			};
		};
		case 7: { // return to the start state after designated period (60-70 secs)
			if (time > _checktime) then {
				_grp_array set [2,0];
				_grp_array call xx_make_normal;
			};
		};
		case 8: { // return to patrol if out of time, or no more enemy
			if (time > _checktime || !([_enemy_array select 1,leader _grp] call x_get_nenemy2)) then {
				_grp_array set [2,0];
				_grp_array call xx_make_normal;
			};
		};
		case 9; { // case to watch some little known position during next 2 minutes
			_grp setCombatMode "YELLOW";
			_grp setSpeedMode "NORMAL";
			_grp setBehaviour "AWARE";
			_grp setFormation (["WEDGE","LINE"] call XfRandomArrayVal);
			_checktime = time + 120 + random 10;
			{
				_x doWatch (_enemy_array select 1); // watch enemy position
				sleep 0.012;
			} forEach _units;
			_grp_array set [2,8];
		};
	}; // switch (_grp_array select 2)
	
	// check group to be empty or dead
	if (isNull _grp || ((_grp call XfGetAliveUnitsGrp) == 0)) exitWith { hint localize format["x_groupsm.sqf: group with WP near %1 is dead", text (_wp_pos call SYG_nearestLocation)];}; // exit if group is empty or dead
	
	sleep (4 + random 4);
	//+++ Sygsky: OPTIMIZE small groups utilizing with time to time trying to rejoin with bigger ones
	if ( (_rejoin_num > 0) and (_rejoin_time <= time) ) then
	{
	    _rejoin_time = time + REJOIN_RERIOD;    // prepare next time to re-join attempt
		_counter = _grp call XfGetStandUnits;	// how many units can stand
		if ( (_counter <= _rejoin_num) AND (_counter > 0) ) then // try to join other group
		{
			_counter = _counter + 1; // size for bigger group to be rejoinable
			_leader = leader _grp;
			if ( (!isNull _leader) AND (vehicle _leader == _leader)) then // try re-join only for feet man group
			{
				_side = side _leader;
				_joingrp = grpNull;
				_any_grp = grpNull;
				// forEach SYG_grpList;
				scopeName "join";
				//waitUntil { !SYG_grpListEditing };
				//_all_grp_list = + SYG_grpList;
#ifdef __OWN_SIDE_EAST__
				_all_grp_list = + groups_west;
#else
				_all_grp_list = + groups_east;
#endif
				// find nearest good group  to rejoin
				_min_dist = REJOIN_DISTANCE;

				{
                    if (typeName _x == "ARRAY") then
                    {
                        _grp1 = _x select 0;
						if (isNull _grp1) exitWith{}; // dead group detected, skip it
                        if ( (_grp1 call XfGetStandUnits) > 0 ) then
                        {
                            _leader1 = leader _grp1;
                            if ( alive _leader1 ) then
                            {
                                if ( (vehicle _leader1 == _leader1) &&  (_grp != _grp1)  && (_side == side _grp1) ) then
                                {
									_dist = _leader distance _leader1;
									if ( _dist < _min_dist) then
									{
									    _stand_cnt = _grp1 call XfGetStandUnits;
									    if (_stand_cnt >= _rejoin_num ) then
									    {
                                            _joingrp = _grp1;
                                            _min_dist = _dist;
                                        }
                                        else
                                        {
                                            if ( _stand_cnt > 1) then {_any_grp = _grp1;};
                                        };
									};
                                };
                                sleep 0.01;
                            };
                        };
                    };
				} forEach _all_grp_list;
#ifdef __DEBUG__			
				hint localize format["%1 x_groupsm.sqf: Trying to re-join grp %2(of %3[%4]) at %5, leader %6",
				    call SYG_missionTimeInfoStr,
				    _grp,
				    count units _grp,
				    _rejoin_num,
//				    (getPos (leader _grp)) call SYG_nearestLocationName,
				    [leader _grp, "%1 m. to %2 from %3"] call SYG_MsgOnPosE,
				    typeOf (leader _grp)];
#endif				
                if ( (isNull _joingrp) && (!isNull _any_grp) ) then // use bad group if no good one found
                {
                    _joingrp = _any_grp;
                };

				if ( !isNull _joingrp ) then 
				{
#ifdef __DEBUG__			
					hint localize format["%5 x_groupsm.sqf: Re-join grp %1(of %2) to grp %3(of %4), leader %6, dist %7; %8", _grp, count units _grp, _joingrp, count units _joingrp, call SYG_missionTimeInfoStr, typeOf (leader _joingrp), round((leader _joingrp) distance (leader _grp)), [(leader _joingrp),"%1 m. to %2 from %3"] call SYG_MsgOnPosE];
#endif				
					if ( rank _leader != "PRIVATE" ) then {_leader setRank "PRIVATE"};
					(units _grp) join _joingrp; sleep 1.111;
				};
				
			}; // if ( vehicle _leader == _leader) then // try re-join only for feetman
			
		}; // if ( (_counter <= _rejoin_num) AND (_counter > 0) ) then
		
	}; // if ( _rejoin_num > 0 ) then
	
	//--- Sygsky
}; // while {true}

_grp_array = nil;

if (true) exitWith {};
