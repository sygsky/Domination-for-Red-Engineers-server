// by Xeno: x_sideconvoy.sqf
private ["_c_array","_convoy_destroyed","_convoy_reached_dest","_leader","_newgroup","_nr_convoy","_pos_end","_pos_start","_side","_side1","_vehicles","_wp","_wps","_selector", "_veh_arr","_footmen_check_time","_str","_pos1","_pos2","_dist","_dir"];

#include "x_setup.sqf"
#include "x_macros.sqf"

// remove for normal playing
#define __DEBUG_PRINT__

#ifdef __DEBUG_PRINT__
#define PRINT_DELAY 120
#endif

//#define __SYG_OPTIMIZATION__
#define CHECK_DELAY 120

// call: _grp call _clearFeetmen;
_clearFeetmen = {
	if ( !isNull _this ) then
	{
		{
			if ( !isNull _x && alive _x && vehicle _x == _x ) then
			{	
				_x setDammage 1.1; sleep 0.01; [_x] call XAddDead;
			};
		}forEach units _this;
	};
};

// call: [_unit1, _unit2 ...] call _killFeetmen;
_killFeetmen = {
	if ( !isNull _this ) then
	{
		{
			if ( !isNull _x && alive _x && vehicle _x == _x ) then
			{	
				_x setDammage 1.1; sleep 0.01;
			};
		}forEach units _this;
	};
};


_pos_start = _this select 0;
_pos_end = _this select 1;
_nr_convoy = _this select 2;

_crew_member = "";

#ifdef __TT__
sm_points_west = 0;
sm_points_racs = 0;
#endif

#ifdef __RANKED__
d_sm_p_pos = nil;
#endif

_c_array = d_sm_convoy select _nr_convoy;

_side = d_enemy_side;
_side1 = if ( d_enemy_side == "WEST" ) then {west} else {east};
__WaitForGroup
_newgroup = [_side] call x_creategroup;
[d_sm_convoy_vehicles select 0, _side] call x_getunitliste;
_vehicles = [1, _c_array select 0, "", (d_sm_convoy_vehicles select 0), _newgroup, 0, _c_array select 1] call x_makevgroup;
(_vehicles select 0) lock true;
_veh_arr = [_vehicles select 0];
#ifdef __TT__
(_vehicles select 0) addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
#endif
extra_mission_vehicle_remover_array = extra_mission_vehicle_remover_array + _vehicles;
_leader = leader _newgroup;
_leader setRank "LIEUTENANT";
_newgroup allowFleeing 0;
_newgroup setCombatMode "GREEN";
_newgroup setFormation "COLUMN";
_newgroup setSpeedMode "LIMITED";
sleep 0.933;
_vehicles = nil;
for "_i" from 1 to (count d_sm_convoy_vehicles - 1) do {
	_vehicles = [1, _c_array select 0, "", (d_sm_convoy_vehicles select _i), _newgroup, 0, _c_array select 1] call x_makevgroup;
	(_vehicles select 0) lock true;
	_veh_arr = _veh_arr + [_vehicles select 0];
#ifdef __TT__
	(_vehicles select 0) addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
#endif
	extra_mission_vehicle_remover_array = extra_mission_vehicle_remover_array + _vehicles;
	sleep 0.933;
	_vehicles = nil;
};

#ifdef __DEBUG_PRINT__		
	_str = "";
	{
		if (!isNull _x) then
		{
			if ( _str != "" ) then {_str = _str + format[", %1", typeOf _x];} else {_str = _str + format["%1", typeOf _x];};
		};
	}forEach _veh_arr;
	hint localize format["x_sideconvoy.sqf: Конвой стартовал из %1, %2", text ((leader _newgroup) call SYG_nearestLocation), _str];
#endif							

//#ifdef __SYG_OPTIMIZATION__
//_selector = 3;
//#else
_selector = (if ((floor random 100) > 49) then {2} else {3});
//#endif
_wps = _c_array select _selector;
{
	_wp=_newgroup addWaypoint[_x, 0];
	_wp setWaypointBehaviour "SAFE";
	_wp setWaypointSpeed "NORMAL";
	_wp setwaypointtype "MOVE";
	_wp setWaypointFormation "COLUMN";
	_wp setWaypointTimeout [60,80,70];
	sleep 0.001;
} forEach _wps;

_wps = nil;
_c_array = nil;

sleep 20.123;

_convoy_reached_dest = false;
_convoy_destroyed = false;
_footmen_check_time = time + CHECK_DELAY;

#ifdef __DEBUG_PRINT__
_time2print = time + PRINT_DELAY;
#endif
while {!_convoy_reached_dest && !_convoy_destroyed} do {
	if (X_MP) then {
		waitUntil {sleep (1.012 + random 1);(call XPlayersNumber) > 0};
	};
	if ( true ) then
	{
#ifdef __DEBUG_PRINT__							
		if ( _time2print <= time ) then
		{
			if (!isNull leader _newgroup) then
			{
				_loc = (leader _newgroup) call SYG_nearestLocation;
				_pos1 = position _loc;
				_pos1 set [2,0];
				_pos2 = position _leader;
				_pos2 set [2,0];
				_dist = (round ((_pos1 distance _pos2)/100)) * 100;
				_dir = ([_loc,_leader] call XfDirToObj) call SYG_getDirNameEng;
//					hint localize format["%1 x_groupsm.sqf: grp %2, count (_grp_array select 4) == %3 ",call SYG_nowTimeToStr, _grp,count (_grp_array select 4)];

				hint localize format["%6 x_sideconvoy.sqf: alive vecs %1/%5, pos. %3 m to %4 from %2", {alive _x} count _veh_arr, text _loc, (round (_dist/50))*50, _dir, count _veh_arr, call SYG_nowTimeToStr ];
			}
			else
			{
				hint localize "x_sideconvoy.sqf: no leader exists";
			};
			_time2print = time + PRINT_DELAY;
		};
#endif							
		if ( ({ !isNull _x && alive _x } count _veh_arr) == 0 ) then
		{
			_convoy_destroyed = true;
			//_newgroup call _clearFeetmen;
		} 
		else 
		{
			_leader = leader _newgroup;
			if ((position _leader) distance _pos_end < 20) then {
				_convoy_reached_dest = true;
			}
			else
			{
				if ( time > _footmen_check_time ) then
				{
					_footmen = [];
					{ //  forEach units _newgroup;
						if ( (!isNull _x) AND (vehicle _x == _x)) then // unit on feet
						{
							if ( !(_x call SYG_ACEUnitUnconscious ) ) then { _footmen = _footmen + [_x]; }; // unit is conscious
							if ( _x == leader _newgroup ) then
							{
								// select other leader in a good vehicle
								_veh = objNull;
								{  if ( !isNull _x AND canMove _x AND !isNull driver _x)  exitWith {_veh = _x} } forEach _veh_arr;
								if (!isNull _veh) then
								{	
									_x setRank "PRIVATE";
									sleep 0.01;
									_leader = _newgroup selectLeader (effectiveCommander _veh);
									if (!isNull _leader AND alive _leader ) then
									{
										sleep 0.01;
										_leader setRank "LIEUTENANT";
										sleep 0.01;
#ifdef __DEBUG_PRINT__							
										hint localize format["x_sideconvoy.sqf: Re-assign leadership from feetman %1 to a crewmen %2 from %3", _x, _leader, typeOf _veh];
#endif							
									};
								};
							};
							// kill all man now
//							_x setDammage 1.1; sleep 0.3; [_unit] call XAddDead;
#ifdef __DEBUG_PRINT__
//							hint localize format["x_sideconvoy.sqf: feetman unit %1 is deleted",_unit];
#endif
						};
					} forEach units _newgroup;
					
					if ( count _footmen > 0 ) then // try to assign as cargo in other moveable vehicle
					{
						_footmen = [_footmen, _vehicles] call SYG_findAndAssignAsCargo;
#ifdef __DEBUG_PRINT__
						if ( count _footmen > 0 ) then // kill remained
						{
							hint localize format["x_sideconvoy.sqf: %1 units still walking by feet", count _footmen];
						}
						else
						{
							hint localize "x_sideconvoy.sqf: all walking units are reassigned to other vehicles";
						};
#endif
					};
					_footmen_check_time = time + CHECK_DELAY;
				};
			};
		};
	};
/* 	else // old version
	{
		if (isNull _newgroup || ({alive _x} count (units _newgroup)) == 0) then {
			_convoy_destroyed = true;
		} else {
			_leader = leader _newgroup;
			if ((position _leader) distance _pos_end < 20) then {
				_convoy_reached_dest = true;
			};
		};
	};
 */
#ifdef __RANKED__
	["d_sm_p_pos", position _leader] call XSendNetVarClient;
#endif
	sleep 5.123;
};

if (_convoy_reached_dest) then {
	side_mission_winner = -300;
} else {
#ifndef __TT__
	if (_convoy_destroyed) then {
		side_mission_winner=2;
	};
#endif
#ifdef __TT__
	if (sm_points_west > sm_points_racs) then {
		side_mission_winner = 2;
	} else {
		if (sm_points_racs > sm_points_west) then {
			side_mission_winner = 1;
		} else {
			if (sm_points_racs == sm_points_west) then {
				side_mission_winner = 123;
			};
		};
	};
#endif
};

#ifdef __DEBUG_PRINT__
if (_convoy_reached_dest) then 
{
	hint localize "x_sideconvoy.sqf: Конвой достиг пункта назначения! Вы проиграли!";
}
else
{
	hint localize "x_sideconvoy.sqf: Конвой уничтожен бойцами Советской Армии!";
};
#endif

_newgroup spawn {sleep 120; _this call _clearFeetmen};

side_mission_resolved = true;

if (true) exitWith {};
