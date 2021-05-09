// by Sygsky, x_missions\common\x_sidearti2.sqf - extended artillery side mission (on San-Esteban of Sahrani). Created 09-MAY-2021
private [ "_count_arti" ];
if (!isServer) exitWith {};

#include "x_setup.sqf"
// #include "x_macros.sqf"

dead_arti = 0;

#ifdef __TT__
sm_points_west = 0;
sm_points_racs = 0;
#endif

_count_arti = count _this;
{
	_arti addEventHandler ["killed", {dead_arti = dead_arti + 1;_this spawn x_removevehi}];
	#ifdef __TT__
	_arti addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
	#endif
} forEach _this; // all arti array

while {dead_arti < _count_arti} do {
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

if (true) exitWith {};
