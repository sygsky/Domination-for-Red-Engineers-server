// by Sygsky, x_missions\common\x_sidearti2.sqf - extended artillery side mission (on San-Esteban of Sahrani). Created 09-MAY-2021
private [ "count_items" ];
if (!isServer) exitWith {};

#include "x_setup.sqf"
// #include "x_macros.sqf"

dead_items = 0;

#ifdef __TT__
sm_points_west = 0;
sm_points_racs = 0;
#endif

count_items = count _this;
{
	/* Passed array: [unit, killer] */
	_x addEventHandler ["killed", {
			dead_items = dead_items + 1; _this spawn x_removevehi;
			_this execVM "x_missions\common\eventKilledAtSM.sqf";
			sleep 1;
			// send info about next canon death to all players
            private ["killer"];
            _killer = gunner( _this select 1);
            _killer = if (isNull _killer) then {" (?)"} else { if ( isPLayer _killer) then { format[" (%1)", name _killer] } else { " (?)" } };
            [ "msg_to_user", "", [ ["STR_SM_50_CNT", dead_items, _killer, count_items - dead_items, count_items] ], 0, 2, false ] call XSendNetStartScriptClientAll; // "Guns destroyed %1%2, guns left %3, total was %4"
			hint localize format["+++ x_sidearti2.sqf: Gun Nr. %1 (of %2%3) destroyed.", dead_items, count_items, _killer];
		}
	];
	#ifdef __TT__
	_x addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
	#endif
} forEach _this; // all arti array

hint localize "+++ x_sidearti2.sqf started";
while {dead_items < count_items} do {
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
