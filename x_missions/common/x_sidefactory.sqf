// by Xeno
private ["_b1","_b1_down","_b2","_b2_down"];
if (!isServer) exitWith {};

#include "x_setup.sqf"

_b1 = _this select 0;
_b2 = _this select 1;

_b1_down = false;
_b2_down = false;

#ifdef __TT__
sm_points_west = 0;
sm_points_racs = 0;
_b1 addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
_b2 addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
#endif

while {(!_b1_down) /*&&*/ || (!_b2_down)} do { //+++ Sygsky: impove logic to end mission when BOTH buildings are down, not one of them
	if (X_MP) then {
		waitUntil {sleep (1.012 + random 1);(call XPlayersNumber) > 0};
	};
	if ( (!(alive  _b1)) && (!_b1_down)) then {_b1_down = true;}; //+++ Sygsky: excessive (IMHO) logical check in if second part. Todo
	if ( (!(alive  _b2)) && (!_b2_down)) then {_b2_down = true;}; //+++ Sygsky: excessive (IMHO) logical check in if second part. Todo
	sleep 5.321;
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
