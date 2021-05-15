// by Sygsky, x_missions\common\x_sidearti2.sqf - extended artillery side mission (on San-Esteban of Sahrani). Created 09-MAY-2021
private [ "_count_arti" ];
if (!isServer) exitWith {};

#include "x_setup.sqf"
// #include "x_macros.sqf"

#define __DEBUG__

dead_arti = 0;

#ifdef __TT__
sm_points_west = 0;
sm_points_racs = 0;
#endif

_count_arti = count _this;
{
	_arti addEventHandler ["killed",
		{
		/*
			Passed array: [unit, killer]
			unit: Object - Object the event handler is assigned to
			killer: Object - Object that killed the unit
			Contains the unit itself in case of collisions.
		*/
			dead_arti = dead_arti + 1;
		#ifdef __DEBUG__
			hint localize format ["+++ x_sidearti2.sqf: %1 killed by %2(%3), dead cnt %4", typeOf (_this select 0),  name (_this select 1), typeOf (_this select 1), dead_arti];
		#endif
			_this spawn x_removevehi
		}
		];
	#ifdef __TT__
	_arti addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
	#endif
} forEach _this; // all arti array
hint localize "+++ x_sidearti2.sqf started";
while {dead_arti < _count_arti} do {
	sleep 4.631;
};
hint localize "+++ x_sidearti2.sqf finished";

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
