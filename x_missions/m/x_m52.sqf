// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

x_sm_pos = [[10146.6,16968.6,0]]; // index: 52,   Shot down chopper
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = format[localize "STR_SYS_504","Mataredo",15];// "Our helicopter was shot down near %1. Your task to move forward as quickly as possible and search of the crew of the helicopter. The enemy troops also sent their forces in the area of the crash. You have approximately %2 minutes before their arrival. (The mission can be accomplished only by a player in the role of rescuer)"
	current_mission_resolved_text = localize "STR_SYS_505"; // "Good job! The rescue of helicopter crew was successful","Gute Arbeit! Die Rettung der Hubschrauber-crew erfolgreich war","Задание выполнено! Операция по спасению экипажа вертолёта прошла успешно"
};

if (isServer) then {
	_time_till_enemy = (15 * 60) + random 60; // 15 minutes + some random time
	[x_sm_pos,time + _time_till_enemy]  execVM "x_missions\common\x_sideevac.sqf";
};

if (true) exitWith {};