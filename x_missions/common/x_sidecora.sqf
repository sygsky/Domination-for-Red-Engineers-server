// by Xeno
if (!isServer) exitWith {};

#include "x_setup.sqf"

_poss = _this select 0;

_objs = [(_poss nearestObject 488815),(_poss nearestObject 488837),(_poss nearestObject 488838),(_poss nearestObject 291972),(_poss nearestObject 288075)];

#ifdef __TT__
sm_points_west = 0;
sm_points_racs = 0;
{
	_x addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
} forEach _objs;
#endif

sleep 2.123;
["specops", 1, "basic", 1, _poss,100,true] spawn XCreateInf;
sleep 2.221;
["shilka", 1, "bmp", 1, "tank", 1, _poss,1,150,true] spawn XCreateArmor;

while {({alive _x} count _objs) > 0} do {
	sleep 5.326;
};

_objs = nil;

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
