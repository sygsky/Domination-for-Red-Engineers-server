// by Xeno
private ["_angle","_angle_plus","_arti","_arti_pos_dir","_arti_type","_center_x","_center_y","_count_arti","_crewman","_grp","_i","_pos_array","_poss","_radius","_this","_truck","_trucks","_unit","_x1","_y1"];
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

_poss = _this select 0;

_arti_type = (
	if (d_enemy_side == "EAST") then {"D30"} else {"M119"}
);

_crewman = (
	if (d_enemy_side == "EAST") then {d_crewman2_E} else {d_crewman2_W}
);

_trucks = (
	if (d_enemy_side == "EAST") then {"UralReammo"} else {"Truck5tReammo"}
);

// calc positions
_center_x = _poss select 0;
_center_y = _poss select 1;
_radius = 30;
_angle = 0;
_pos_array = [];
_count_arti = 8;
_angle_plus = 360 / 8;

for "_i" from 1 to _count_arti do {
	_x1 = _center_x - (_radius * sin _angle);
	_y1 = _center_y - (_radius * cos _angle);
	_pos_array = _pos_array + [[[_x1,_y1,0], _angle]];
	_angle = _angle + _angle_plus;
};

dead_arti = 0;
__GetEGrp(_grp)

#ifdef __TT__
sm_points_west = 0;
sm_points_racs = 0;
#endif

for "_i" from 0 to (_count_arti - 1) do {
	_arti_pos_dir = _pos_array select _i;
	_arti = _arti_type createvehicle (_arti_pos_dir select 0);
	_arti setDir (_arti_pos_dir select 1);
	_arti addEventHandler ["killed", {dead_arti = dead_arti + 1;_this spawn x_removevehi;}];
	#ifdef __TT__
	_arti addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
	#endif
	_arti lock true;
	_unit = _grp createUnit [_crewman, (_arti_pos_dir select 0), [], 0, "NONE"];[_unit] join _grp;_unit setSkill 1;_unit assignAsGunner _arti;_unit moveInGunner _arti;
	__addDead(_unit)
	sleep 0.5321;
};

_pos_array = nil;

for "_i" from 1 to 3 do {
	_truck = _trucks createvehicle _poss;
	_truck lock true;
	sleep 0.523;
};

sleep 2.123;
["specops", 1, "basic", 2, _poss, 150,true] spawn XCreateInf;
sleep 4.123;
["shilka", 1, "bmp", 2, "tank", 1, _poss,1,200,true] spawn XCreateArmor;

while {dead_arti != _count_arti} do {
	sleep 4.631;
};

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
