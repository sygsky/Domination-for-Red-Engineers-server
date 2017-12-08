// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[8975.58,8437.76,0]]; // index: 47,   Destroy factory building in Somato, attention, uses nearestObject ID
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = "Возле Somato действует завод по производству боеприпасов. Уничтожьте склад и трубу, для полной остановки производства.";
	current_mission_resolved_text = "Задание выполнено! Работа завода остановленна.";
};

if (isServer) then {
	__Poss
	_building = _poss nearestObject 568305;
	_building2 = _poss nearestObject 180160;
	sleep 2.123;
	["specops", 1, "basic", 1, _poss,90,true] spawn XCreateInf;
	sleep 2.221;
	["shilka", 1, "bmp", 1, "tank", 1, _poss,1,150,true] spawn XCreateArmor;
	sleep 5.123;
	[_building, _building2] execVM "x_missions\common\x_sidefactory.sqf";
};

if (true) exitWith {};