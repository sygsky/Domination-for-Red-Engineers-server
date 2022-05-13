// by Xeno, x_missions\common\x_sidearti.sqf - no more observers after end of this mission
private ["_angle","_angle_plus","_arti","_arti_pos_dir","_arti_type","_center_x","_center_y","_crewman","_grp","_i","_pos_array","_poss","_radius","_this","_truck","_trackType","_unit","_x1","_y1"];
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

//#define __DEBUG__

_poss = _this select 0;

_arti_type = (
	if (d_enemy_side == "EAST") then {"D30"} else {"M119"}
);

_crewman = (
	if (d_enemy_side == "EAST") then {d_crewman2_E} else {d_crewman2_W}
);

_trackType =
#ifdef __ACE
	if (d_enemy_side == "EAST") then {"ACE_Ural_Reammo"} else {"ACE_Truck5t_Reammo"};
#else
	if (d_enemy_side == "EAST") then {"UralReammo"} else {"Truck5tReammo"};
#endif


// calc positions
_center_x = _poss select 0;
_center_y = _poss select 1;
_radius = 40;
_angle = 0;
_pos_array = [];
#ifdef __DEBUG__
count_items = 3;
#else
count_items = 5 + (ceil 3);
#endif
_angle_plus = 360 / count_items;

for "_i" from 1 to count_items do {
	_x1 = _center_x - (_radius * sin _angle);
	_y1 = _center_y - (_radius * cos _angle);
	_pos_array = _pos_array + [[[_x1,_y1,0], _angle]];
	_angle = _angle + _angle_plus;
};

dead_items = 0;
_grp = call SYG_createEnemyGroup;

#ifdef __TT__
sm_points_west = 0;
sm_points_racs = 0;
#endif

for "_i" from 0 to (count_items - 1) do {
	_arti_pos_dir = _pos_array select _i;
	_arti = _arti_type createVehicle (_arti_pos_dir select 0);
	_arti setDir (_arti_pos_dir select 1);
	_arti addEventHandler [ "killed", {
	        dead_items = dead_items + 1;
	        _this execVM "x_missions\common\eventKilledAtSM.sqf"; _this spawn x_removevehi;
            // send info about next canon death to all players
            sleep 1;
            private ["killer"];
            _killer = gunner( _this select 1);
            _killer = if (isNull _killer) then {" (?)"} else { if ( isPlayer _killer) then { format[" (%1)", name _killer] } else { " (?)" } };
            [ "msg_to_user", "", [ ["STR_SM_50_CNT", dead_items, _killer, count_items - dead_items, count_items] ], 0, 2, false ] call XSendNetStartScriptClientAll; // "Guns destroyed %1%2, guns left %3, total was %4"
			hint localize format["+++ x_sidearti.sqf: Gun Nr. %1 (of %2%3) destroyed.", dead_items, count_items, _killer];
	    }
	];
	#ifdef __TT__
	_arti addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
	#endif
	_arti lock true;
    // populate each arti gun with the gunner
	_unit = _grp createUnit [_crewman, (_arti_pos_dir select 0), [], 0, "NONE"];[_unit] join _grp;_unit setSkill 1;_unit assignAsGunner _arti;_unit moveInGunner _arti;
	extra_mission_remover_array set [ count extra_mission_remover_array, _unit ];

	//__addDead(_unit)
	sleep 0.5321;
};
_grp call XCombatPatrol;

_pos_array = nil;

for "_i" from 1 to 3 do {
	_truck = _trackType createVehicle _poss;
	_truck lock true;
	extra_mission_vehicle_remover_array set [count extra_mission_vehicle_remover_array, _truck];
//	_truck addEventHandler ["killed", {_this spawn x_removevehi}]; // #err313, remove trucks from server after this SM completion
	sleep 0.523;
};

#ifdef __DEBUG__
sleep 2.123;
["specops", 0, "basic", 1, _poss, 400,true] spawn XCreateInf; // Please, put such SM in very open areas!!!
sleep 4.123;
["shilka", 0, "bmp", 1, "tank", 0, _poss, 1, 250,true] spawn XCreateArmor;
#else
sleep 2.123;
["specops", 2, "basic", 4, _poss, 400,true] spawn XCreateInf; // Please, put such SM in very open areas!!!
sleep 4.123;
["shilka", 2, "bmp", 2, "tank", 2, _poss, 1, 250,true] spawn XCreateArmor;
#endif

hint localize "+++ x_sidearti.sqf started";
while { dead_items < count_items } do {
	sleep 4.631;
};
hint localize "+++ x_sidearti.sqf finished";

#ifndef __TT__
side_mission_winner=2;
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
side_mission_resolved = true;
no_more_observers = true;

if (true) exitWith {};
