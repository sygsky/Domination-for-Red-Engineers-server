// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[10673.1,8980.08,0]]; // index: 46,   Destroy factory building in Paraiso, attention, uses nearestObject ID
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (X_Client) then {
	current_mission_text = "На заводе вблизи Paraiso враг наладил производство шарикоподшипников. Уничтожьте два главных здания для остановки производства";
	current_mission_resolved_text = "Задание выполнено! Все здания уничтожены.";
};

if (isServer) then {
	__Poss
	_building = _poss nearestObject 53337;
	_building2 = _poss nearestObject 178822;
	sleep 2.123;
	["specops", 1, "basic", 1, _poss,80,true] spawn XCreateInf;
	sleep 2.221;
	["shilka", 1, "bmp", 1, "tank", 1, _poss,1,100,true] spawn XCreateArmor;
	[_building, _building2] execVM "x_missions\common\x_sidefactory.sqf";
};

if (true) exitWith {};