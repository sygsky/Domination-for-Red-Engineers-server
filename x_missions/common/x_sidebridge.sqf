// by Xeno
private ["_b1_down","_b2_down","_b3_down","_bridge_1_ids","_bridge_2_ids","_bridge_3_ids","_bridges_down","_pos_array"];
if (!isServer) exitWith {};

#include "x_setup.sqf"

_pos_array = _this select 0;

_bridge_1_ids = [169212,169216,161633,161638];
_bridge_2_ids = [169241,169246,161373,161429];
_bridge_3_ids = [74148,161188,74149,161258];

_bridges_down = 0;
_b1_down = false;
_b2_down = false;
_b3_down = false;

["shilka", 2, "bmp", 2, "tank", 2, (_pos_array select 0),1,150,true] spawn XCreateArmor;
sleep 2.132;
["specops", 1, "basic", 0, (_pos_array select 1),100,true] spawn XCreateInf;

sleep 2.132;
["specops", 0, "basic", 1, (_pos_array select 2),100,true] spawn XCreateInf;

sleep 2.132;
["specops", 1, "basic", 1, (_pos_array select 3),100,true] spawn XCreateInf;

sleep 10.321;

#ifdef __TT__
sm_points_west = 0;
sm_points_racs = 0;
{
	((_pos_array select 1) nearestObject _x) addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
} forEach (_bridge_1_ids + _bridge_2_ids + _bridge_3_ids);
#endif

while {_bridges_down < 3} do {
	if (X_MP) then {
		waitUntil {sleep (1.012 + random 1);(call XPlayersNumber) > 0};
	};
	if (!_b1_down) then {
		{
			if (!alive ((_pos_array select 1) nearestObject _x)) then {
				_b1_down = true;
				_bridges_down = _bridges_down + 1;
			};
		} forEach _bridge_1_ids;
	};
	sleep 0.532;
	if (!_b2_down) then {
		{
			if (!alive ((_pos_array select 2) nearestObject _x)) then {
				_b2_down = true;
				_bridges_down = _bridges_down + 1;
			};
		} forEach _bridge_2_ids;
	};
	sleep 0.532;
	if (!_b3_down) then {
		{
			if (!alive ((_pos_array select 3) nearestObject _x)) then {
				_b3_down = true;
				_bridges_down = _bridges_down + 1;
			};
		} forEach _bridge_3_ids;
	};
	sleep 5.123;
};

_bridge_1_ids = nil;
_bridge_2_ids = nil;
_bridge_3_ids = nil;

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
