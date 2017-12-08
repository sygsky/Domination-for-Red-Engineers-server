// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[10838.5,12636.7,0], [10886.6,12722.2,0]]; // index: 15,   Transformer station in Tlaloc
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SYS_318"; // "По данным разведки, где-то в Bagango расположена вражеская секретная научная лаборатория. Выша задача уничтожить трансформаторную подстанцию в Tlaloc, тем самым саботировать работу лаборатории.";
	current_mission_resolved_text = localize "STR_SYS_318_1"; //"Задание выполнено! Трансформаторная подстанция уничтожена.";
};

if (isServer) then {
	__PossAndOther
	_vehicle = "Land_trafostanica_velka" createvehicle (_poss);
	[_vehicle] spawn XCheckSMHardTarget;
	sleep 2.22;
	["shilka", 1, "bmp", 1, "tank", 1, _pos_other,1,110,true] spawn XCreateArmor;
	sleep 2.123;
	["specops", 1, "basic", 1, _poss,110,true] spawn XCreateInf;
	__AddToExtraVec(_vehicle)
};

if (true) exitWith {};