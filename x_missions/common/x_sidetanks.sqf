// by Xeno: x_missions\common\x_sidetanks.sqf
private ["_posi_array","_tank1","_tank2","_tank3","_tank4","_tank5","_tank6","_dirs","_m_nr","_tank_type"];
if (!isServer) exitWith {};

#include "x_setup.sqf"

_posi_array = _this select 0;
_m_nr = _this select 1;

_dirs = d_sm_tanks_dir_array select _m_nr;

_tank_type = (
#ifdef __ACE__
	if (d_enemy_side == "EAST") then {"ACE_T90A"} else {"ACE_M1A2_SEP_TUSK_Desert"}
#else
	if (d_enemy_side == "EAST") then {"T72"} else {"M1Abrams"}
#endif
);

dead_tanks = 0;

#ifdef __TT__
sm_points_west = 0;
sm_points_racs = 0;
#endif

{
	_tank = _tank_type createVehicle (_posi_array select _x);
	_tank setDir (_dirs select (_x -1 ));
	_tank addEventHandler ["killed", {dead_tanks = dead_tanks + 1;_this spawn x_removevehiextra;}];
#ifndef __TT_
    #ifdef __RANKED__
    (_vehicles select 0) addEventHandler ["killed", { _this execVM "x_missions\common\eventKilledAtSM.sqf" } ]; // mark neighbouring users to be at SM
    #endif
#endif
	#ifdef __TT__
	_tank addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1;};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
	#endif
	_tank lock true;
	sleep 0.512;
} forEach [ 1, 2, 3, 4, 5, 6];
/*
_tank1 = _tank_type createVehicle (_posi_array select 1);
_tank1 setDir (_dirs select 0);
_tank1 addEventHandler ["killed", {dead_tanks = dead_tanks + 1;_this spawn x_removevehiextra;}];
#ifdef __TT__
_tank1 addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1;};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
#endif
_tank1 lock true;
sleep 0.512;

_tank2 = _tank_type createVehicle (_posi_array select 2);
_tank2 setDir (_dirs select 1);
_tank2 addEventHandler ["killed", {dead_tanks = dead_tanks + 1;_this spawn x_removevehiextra;}];
#ifdef __TT__
_tank2 addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
#endif
_tank2 lock true;
sleep 0.512;

_tank3 = _tank_type createVehicle (_posi_array select 3);
_tank3 setDir (_dirs select 2);
_tank3 addEventHandler ["killed", {dead_tanks = dead_tanks + 1;_this spawn x_removevehiextra;}];
#ifdef __TT__
_tank3 addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
#endif
_tank3 lock true;
sleep 0.512;

_tank4 = _tank_type createVehicle (_posi_array select 4);
_tank4 setDir (_dirs select 3);
_tank4 addEventHandler ["killed", {dead_tanks = dead_tanks + 1;_this spawn x_removevehiextra;}];
#ifdef __TT__
_tank4 addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
#endif
_tank4 lock true;
sleep 0.512;

_tank5 = _tank_type createVehicle (_posi_array select 5);
_tank5 setDir (_dirs select 4);
_tank5 addEventHandler ["killed", {dead_tanks = dead_tanks + 1;_this spawn x_removevehiextra;}];
#ifdef __TT__
_tank5 addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
#endif
_tank5 lock true;
sleep 0.512;

_tank6 = _tank_type createVehicle (_posi_array select 6);
_tank6 setDir (_dirs select 5);
_tank6 addEventHandler ["killed", {dead_tanks = dead_tanks + 1;_this spawn x_removevehiextra;}];
#ifdef __TT__
_tank6 addEventHandler ["killed", {switch (side (_this select 1)) do {case west: {sm_points_west = sm_points_west + 1};case resistance: {sm_points_racs = sm_points_racs + 1}}}];
#endif
_tank6 lock true;
*/
sleep 2.333;
["specops", 1, "basic", 2, _posi_array select 0,150,true] spawn XCreateInf;
sleep 2.333;
["shilka", 1, "bmp", 1, "tank", 2, _posi_array select 0,2,200,true] spawn XCreateArmor;

_tank_type = nil;
_dirs = nil;
_posi_array = nil;
_m_nr = nil;

sleep 15.321;

_play_sound = true;
while { dead_tanks < 6 } do {
	if ( _play_sound ) then {
		if (dead_tanks > 0) then {
			_play_sound = false;
			sleep (2 + (random 2));
			_sound = SYG_tanks_sounds call XfRandomArrayVal;
			["say_sound", "PLAY", _sound] call XSendNetStartScriptClient; // playSound on all players compters
		};
	};
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
