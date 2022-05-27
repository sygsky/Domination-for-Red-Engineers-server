// by Sygsky, radar installation mission. x_missions/m/x_m56.sqf
#include "x_setup.sqf"
#include "x_macros.sqf"

x_sm_pos = [[6981.0,16235.0, 0]]; // index: 52,   Shot down chopper
x_sm_type = "undefined"; // "normal", "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = format[localize "STR_SYS_504","Hunapu",13]; //"Our helicopter was shot down near %1..."
	current_mission_resolved_text = localize "STR_SYS_505"; //"Good job! The rescue of helicopter crew was successful"
};

if (isServer) then {
	_time_till_enemy = (15 * 60) + random 60; // 15 minutes + some random time
	[x_sm_pos,time + _time_till_enemy]  execVM "x_missions\common\x_sideevac.sqf";
};

if (true) exitWith {};