// by Xeno
private ["_boat1","_boat2","_boat3","_boat4","_pos_other","_pos_other2","_pos_other3","_pos_other4","_posi_array","_poss","_poss2","_poss3","_poss4","_boat_type"];
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

_posi_array = _this select 0;

_poss = _posi_array select 0;
_poss2 = _posi_array select 5;
_poss3 = _posi_array select 6;
_poss4 = _posi_array select 7;
_pos_other = _posi_array select 1;
_pos_other2 = _posi_array select 2;
_pos_other3 = _posi_array select 3;
_pos_other4 = _posi_array select 4;

_boat_type = (if (d_enemy_side == "EAST") then {"PBX"} else {"Zodiac"});

dead_boats = 0;

#ifdef __TT__
sm_points_west = 0;
sm_points_racs = 0;
#endif

_boat1 = _boat_type createvehicle (_poss);
_boat1 setDir 32;
_boat1 addEventHandler ["killed", {dead_boats = dead_boats + 1;_this spawn x_removevehiextra;}];
#ifdef __TT__
_boat1 addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
#endif
_boat1 lock true;
sleep 0.512;
_boat2 = _boat_type createvehicle (_poss2);
_boat2 setDir 336.274;
_boat2 addEventHandler ["killed", {dead_boats = dead_boats + 1;_this spawn x_removevehiextra;}];
#ifdef __TT__
_boat2 addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
#endif
_boat2 lock true;
sleep 0.512;
_boat3 = _boat_type createvehicle (_poss3);
_boat3 setDir 73.0341;
_boat3 addEventHandler ["killed", {dead_boats = dead_boats + 1;_this spawn x_removevehiextra;}];
#ifdef __TT__
_boat3 addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
#endif
_boat3 lock true;
sleep 0.512;
_boat4 = _boat_type createvehicle (_poss4);
_boat4 setDir 96.5422;
_boat4 addEventHandler ["killed", {dead_boats = dead_boats + 1;_this spawn x_removevehiextra;}];
#ifdef __TT__
_boat4 addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
#endif
_boat4 lock true;
sleep 2.333;
["specops", 0, "basic", 1, _pos_other4,100,true] spawn XCreateInf;
sleep 2.333;
["specops", 1, "basic", 0, _pos_other,100,true] spawn XCreateInf;
sleep 2.333;
["specops", 0, "basic", 1, _pos_other2,100,true] spawn XCreateInf;
sleep 2.333;
["specops", 1, "basic", 0, _pos_other3,100,true] spawn XCreateInf;

_poss = nil;
_poss2 = nil;
_poss3 = nil;
_poss4 = nil;
_pos_other = nil;
_pos_other2 = nil;
_pos_other3 = nil;
_pos_other4 = nil;
_boat_type = nil;

sleep 15.321;

while {dead_boats < 4} do {
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
