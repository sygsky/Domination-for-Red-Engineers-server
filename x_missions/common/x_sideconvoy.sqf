// by Xeno: [_poss, _pos_other, 0] execVM "x_sideconvoy.sqf"
private ["_c_array","_convoy_destroyed","_convoy_reached_dest","_leader","_convoyGroup",
         "_nr_convoy","_pos_end","_pos_start","_vehicles","_wp","_wps","_last_ctrl_point","_pos",
         "_way_id", "_veh_arr","_footmen_check_time","_str","_pos1","_pos2","_dist","_dir","_vecnum"];

#include "x_setup.sqf"
#include "x_macros.sqf"

// remove for normal playing
#define __DEBUG_PRINT__

#ifdef __DEBUG_PRINT__
#define PRINT_DELAY 120
#endif

//#define __SYG_OPTIMIZATION__
#define CHECK_DELAY 120

#define DISTANCE_BETWEEN_CTRL_POINT 1000 // distance in meters between control points

// call: _grp call _clearFootmen;
_clearFootmen = {
	if ( !isNull _this ) then {
	    if (typeName _this == "GROUP") then { _this = units _this };
	    if (typeName _this != "ARRAY") exitWith { false };

		{
			if ( alive _x && (vehicle _x == _x) ) then
			{	
				_x setDammage 1.1; sleep 0.01; _x call XAddDead0;
			};
		}forEach _this;
	};
};

// _footmen = [_footmen, _vehicles] call _checkOverturnedVehicles;
_checkOverturnedVehicles = {
    _footmen  = + _this select 0;
    _vehicles =  + _this select 1;
    if (count _footmen == 0) exitWith {
        hint localize "+++ Convoy checkOverturnedVehicles called with empty footmen array";
        []
    };

    if (count _vehicles == 0) exitWith {
        hint localize "+++ Convoy checkOverturnedVehicles called with empty vehicles array";
        _this select 0
    };
    hint localize format["+++ Convoy checkOverturnedVehicles: footmen %1, vehs %2", count _footmen, count _vehicles];
    _populateVehCnt = 0;
    _pos      = (count _footmen) - 1;
    {
        _initPos = _pos;
        if ( _pos < 0 ) exitWith { _footmen = []};
        if ( (alive _x) && (side _x == d_side_enemy) && (_x call SYG_vehIsUpsideDown) && ( (_x distance (_footmen select _pos) ) < 100) ) then {
        	// near overturned vehicle
            hint localize format["+++ Convoy checkOverturnedVehicles: found overturned %1, dmg %2, fuel %3, dist %4", typeOf _x, damage _x, fuel _x, _x distance (_footmen select _pos)];
            // repair, refuel , overturned
            _x setFuel 1;
            _x setDamage 0;
            _x setVectorUp [0,0,1];

            // first always assign driver
            if (_x emptyPositions "Driver" > 0) then {
                _man = _footmen select _pos;
                _man assignAsDriver _x;
                [_man] orderGetIn true;
                _pos = _pos - 1;
            };
            if ( _pos < 0 ) exitWith { _footmen = []};

            // secondary try to assign gunner
            if (_x emptyPositions "Gunner" > 0) then {
                _man = _footmen select _pos;
                _man assignAsGunner _x;
                [_man] orderGetIn true;
                _pos = _pos - 1;
            };
            if ( _pos < 0 ) exitWith { _footmen = []};

            // last try fit commander
            if (_x emptyPositions "Commander"  > 0) then {
                _man = _footmen select _pos;
                _man assignAsCommander _x;
                [_man] orderGetIn true;
                _pos = _pos - 1;
            };
            if ( _pos < 0 ) exitWith { _footmen = []};

            // and some cargo too
            _cargoCnt = (_x emptyPositions "Cargo") min ( _pos + 1);
            if (_cargoCnt  > 0) then {
                for "_i" from 0 to _cargoCnt - 1 do {
                    _man = _footmen select _i;
                    _man assignAsCargo _x;
                    [_man] orderGetIn true;
                    _pos = _pos - 1;
                };
            };
            if ( _pos != _initPos) then {
                hint localize format["+++ Convoy checkOverturnedVehicles: vehicle %1 populated with %2 men of %3", typeOf _x, _initPos - _pos, count _footMan];
                _populateVehCnt = _populateVehCnt + 1;
            };
            sleep 1;
        };
    } forEach _vehicles;
    if ( _pos < 0) exitWith {
        hint localize format["+++ Convoy checkOverturnedVehicles: all footmen are populated among %1 vehicles", _populateVehCnt];
        []
    } else {
        if ( (_pos + 1) != (count _footmen) ) then {
            hint localize format["+++ Convoy checkOverturnedVehicles: %1 footmen are populated among %1 vehicles", (count _footmen) - _pos - 1, _populateVehCnt];
            _footmen resize (_pos + 1);
        };
    };
    _footmen
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

_c_array = d_sm_convoy select _nr_convoy; // convoy waypoints

_convoyGroup = call SYG_createEnemyGroup;

//[d_sm_convoy_vehicles select 0, _side] call x_getunitliste;

// first vehicle created separatedly, to assign the leader correctly
_vehicles = [1, _c_array select 0, "", (d_sm_convoy_vehicles select 0), _convoyGroup, 0, _c_array select 1] call x_makevgroup; // vehicle type
(_vehicles select 0) lock true;
_veh_arr = [_vehicles select 0];

#ifdef __TT__
(_vehicles select 0) addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
#endif

#ifndef __TT_
    #ifdef __RANKED__
    (_vehicles select 0) addEventHandler ["killed", { _this execVM "x_missions\common\eventKilledAtSM.sqf" } ]; // mark neighbouring users to be at SM
    #endif
#endif

extra_mission_vehicle_remover_array set [ count extra_mission_vehicle_remover_array, _vehicles select 0 ];

_leader = leader _convoyGroup;
_leader setRank "LIEUTENANT";
_convoyGroup allowFleeing 0;
_convoyGroup setCombatMode "GREEN";
_convoyGroup setFormation "COLUMN";
_convoyGroup setSpeedMode "LIMITED";
sleep 0.933;
_vehicles = nil;
dead_items = 0;

//+++++++++++++++++++++++++++++++++++++++
//          create vehicles
//+++++++++++++++++++++++++++++++++++++++
for "_i" from 1 to (count d_sm_convoy_vehicles - 1) do {
	_vehicles = [1, _c_array select 0, "", (d_sm_convoy_vehicles select _i), _convoyGroup, 0, _c_array select 1] call x_makevgroup;
	(_vehicles select 0) lock true;
	_veh_arr set [count _veh_arr, _vehicles select 0];
#ifdef __TT__
	(_vehicles select 0) addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
#endif

#ifndef __TT_
    #ifdef __RANKED__
    // mark neighbouring users to be at SM
   	/* Passed array: [unit, killer] */
    (_vehicles select 0) addEventHandler ["killed", {
            dead_items = dead_items + 1;
            _this execVM "x_missions\common\eventKilledAtSM.sqf";
            // send info about next vehicle death to all players
            private ["_killer"];
            _killer = _this select 1;
            if (isNull _killer) then {" (NULL)"} else {
				_killer = gunner( _this select 1);
				_killer = if (isNull _killer) then {" (?)"} else { if ( isPLayer _killer) then { format[" (%1)", name _killer] } else { " (?)" } };
            };
            [ "msg_to_user", "", [ ["STR_SM_CONVOY_1", dead_items, _killer, (count d_sm_convoy_vehicles) - dead_items, count d_sm_convoy_vehicles] ], 0, 2, false ] call XSendNetStartScriptClientAll; // "Destroyed vehicles %1%2, left %3, total %4"
            hint localize format["+++ x_sideconvoy.sqf: veh #%1 (of %2%3) destroyed.", dead_items, count d_sm_convoy_vehicles, _killer];
        }
    ];
    #endif
#endif

	extra_mission_vehicle_remover_array set [ count extra_mission_vehicle_remover_array, _vehicles select 0];
	sleep 0.933;
	_vehicles = nil;
};
_vecnum = 0;

#ifdef __DEBUG_PRINT__		
	_str = "";
	{
		if (!isNull _x) then {
			if ( _str != "" ) then {_str = _str + format[", %1", typeOf _x];} else {_str = _str + format["%1", typeOf _x];};
		};
	} forEach _veh_arr;
	hint localize format[ "+++ x_sideconvoy.sqf: Convoy moves from %1 to %2, %3", text (_pos_start call SYG_nearestSettlement), text (_pos_end call SYG_nearestSettlement), _str];
#endif							

//#ifdef __SYG_OPTIMIZATION__
//_way_id = 3;
//#else
_way_id = 2 + floor(random ((count _c_array) - 2)); // 2 .. n  - the ways id variants, may be more then 2 ways in a happy future, now only 2 different ways are available
//#endif

_wps = _c_array select _way_id;
{
	_wp=_convoyGroup addWaypoint[_x, 0];
	_wp setWaypointBehaviour "SAFE";
	_wp setWaypointSpeed "NORMAL";
	_wp setWaypointType "MOVE";
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

_last_ctrl_point = getPos (_convoyGroup call SYG_getLeader);

while {!_convoy_reached_dest && !_convoy_destroyed} do {
	if (X_MP) then {
		waitUntil {
            if ( _time2print <= time ) then {
                if (!isNull (_convoyGroup call SYG_getLeader)) then {
                    _loc = (_convoyGroup call SYG_getLeader) call SYG_nearestLocation;
                    _pos1 = position _loc;
                    _pos1 set [2,0];
                    _pos2 = position _leader;
                    _pos2 set [2,0];
                    _dist = (round ((_pos1 distance _pos2)/100)) * 100;
                    _dir = ([_loc,_leader] call XfDirToObj) call SYG_getDirNameEng;
                    hint localize format["%6 x_sideconvoy.sqf (wait players): alive vecs %1/%5(%7), pos. %3 m to %4 from %2", {alive _x} count _veh_arr, text _loc, (round (_dist/50))*50, _dir, count _veh_arr, call SYG_nowTimeToStr, typeOf (vehicle _leader) ];
                } else {
                		hint localize format["--- x_sideconvoy.sqf (wait players): no leader exists, %1 units ", {alive _x } count (units _convoyGroup)];
                };
                // TODO: check for any overturned vehicles and turn it on while no players on island
                _time2print = time + PRINT_DELAY;
            };
		    sleep (10.012 + random 1);
		    (call XPlayersNumber) > 0
		};
	};

#ifdef __DEBUG_PRINT__
	if ( _time2print <= time ) then {
		if (!isNull (_convoyGroup call SYG_getLeader)) then {
			_loc = (_convoyGroup call SYG_getLeader) call SYG_nearestLocation;
			_pos1 = position _loc;
			_pos1 set [2,0];
			_pos2 = position _leader;
			_pos2 set [2,0];
			_dist = (round ((_pos1 distance _pos2)/100)) * 100;
			_dir = ([_loc,_leader] call XfDirToObj) call SYG_getDirNameEng;
//					hint localize format["+++ %1 x_groupsm.sqf: grp %2, count (_grp_array select 4) == %3 ",call SYG_nowTimeToStr, _grp,count (_grp_array select 4)];

			hint localize format["+++ %6 x_sideconvoy.sqf: vecs a%1/m%8/c%5(%7), pos. %3 m to %4 from %2",
				{alive _x} count _veh_arr,
				text _loc,
				(round (_dist/10))*10,
				_dir,
				count _veh_arr,
				call SYG_nowTimeToStr,
				typeOf (vehicle _leader),
				{alive driver _x}  count _veh_arr
			];
		} else { hint localize format["--- x_sideconvoy.sqf: no leader exists, %1 alive units ", {alive _x } count (units _convoyGroup)]; };
		_time2print = time + PRINT_DELAY;
		// check new convoy vehicle state
		_newcnt = {({alive _x} count crew _x) > 0} count _veh_arr;
		if ( _newcnt != _vecnum) then {
			if ( _newcnt == 0) then {
				_msg = ["STR_SYS_500_2"]; // "All the vehicles in the convoy lost crew!"
				hint localize "*** x_sideconvoy.sqf: All the vehicles in the convoy lost crew!";
			} else {
				_msg = ["STR_SYS_500_1",_newcnt ]; // "Moving vehicles in the convoy: %1"
			};
			// send message to users about
			["msg_to_user","",[_msg],4,4] call XSendNetStartScriptClient;
			_vecnum = _newcnt;
		};
	};
#endif							
	if ( ({ !isNull _x && alive _x } count _veh_arr) == 0 ) then {
		_convoy_destroyed = true;
		//_convoyGroup call _clearFeetmen;
	} else {
		_leader = leader _convoyGroup;
		if ((position _leader) distance _pos_end < 20) then {
			_convoy_reached_dest = true;
		} else {
			if ( time > _footmen_check_time ) then {
				_footmen = [];
				{ //  forEach units _convoyGroup;
					if ( (alive _x) && (vehicle _x == _x)) then { // unit on feet
						if ( !(_x call SYG_ACEUnitUnconscious ) ) then { _footmen set [count _footmen, _x]; }; // unit is conscious
						if ( _x == leader _convoyGroup ) then {
							// select other leader in a good vehicle
							_veh = objNull;
							{  if ( !isNull _x && canMove _x && !isNull driver _x)  exitWith {_veh = _x} } forEach _veh_arr;
							if (!isNull _veh) then {
								_x setRank "PRIVATE";
								sleep 0.01;
								_leader = _convoyGroup selectLeader (effectiveCommander _veh);
								if (!isNull _leader && alive _leader ) then
								{
									sleep 0.01;
									_leader setRank "LIEUTENANT";
									sleep 0.01;
#ifdef __DEBUG_PRINT__							
									hint localize format["+++ x_sideconvoy.sqf: Re-assign leadership from feetman %1 to a crewmen %2 [%3]", _x, _leader, typeOf _veh];
#endif							
								};
							};
						};
						// kill all man now
//							_x setDammage 1.1; sleep 0.3; [_unit] call XAddDead;
#ifdef __DEBUG_PRINT__
//							hint localize format["+++ x_sideconvoy.sqf: feetman unit %1 is deleted",_unit];
#endif
					};
				} forEach units _convoyGroup;

				if ( count _footmen > 0 ) then { // try to assign as cargo in other moveable vehicle
#ifdef __DEBUG_PRINT__
					_cnt = count _footmen;
#endif
					_footmen = [_footmen, _veh_arr] call SYG_findAndAssignAsCargo;
#ifdef __DEBUG_PRINT__
					if ( count _footmen > 0 ) then {
						if ( (count _footmen) < _cnt ) then {
							hint localize format["+++ x_sideconvoy.sqf: %1 walking units of total %2 were reassigned to other vehicle[s]",_cnt - (count _footmen), _cnt];
						};
					} else {
						hint localize "+++ x_sideconvoy.sqf: all walking units were reassigned to other vehicle[s]";
					};
#endif
				};
				_footmen_check_time = time + CHECK_DELAY;
			};
		};
	};
#ifdef __RANKED__
	["d_sm_p_pos", position _leader] call XSendNetVarClient;
#endif
	sleep 5.123;
	// Сheck if it is time to change control point or not
	_pos = getPos (_convoyGroup call  SYG_getLeader);
	if ( ( _pos distance _last_ctrl_point ) > DISTANCE_BETWEEN_CTRL_POINT ) then {
		private ["_msg"];
		_last_ctrl_point = _pos;
		// send info to all players
		_msg = if ((_pos distance _pos_end ) >= DISTANCE_BETWEEN_CTRL_POINT * 2) then {"STR_SYS_500_3"} else {"STR_SYS_500_4"};
		// "Islanders report about convoy movement spotted" or
		// "Islanders report about convoy movement spotted near the target"
		["msg_to_user", _this,  [[_msg]], 0, 2, false, "message_received" ] call XSendNetStartScriptClientAll;
	};
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
if (_convoy_reached_dest) then {
	hint localize "x_sideconvoy.sqf: Конвой достиг пункта назначения! Вы проиграли!";
} else {
	hint localize "x_sideconvoy.sqf: Конвой уничтожен бойцами Советской Армии!";
};
#endif


side_mission_resolved = true;

// remove all footmen
sleep 120;
_convoyGroup call _clearFootmen;

if (true) exitWith {};
