// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[16582.7,4690.99,0], [16430.9,4617.28,0]]; // index: 11,   Lighthouse on Isla del Zorra
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (X_Client) then {
	current_mission_text = "На острове Isla del Zorra враг установил на маяк радиолокатор. Задача - уничтожить здание маяка. Авиаторы будут вам благодарны.";
	current_mission_resolved_text = "Задание выполнено! Маяк уничтожен.";
};

if (isServer) then {
	__PossAndOther
	_vehicle = "Land_majak2" createvehicle (_poss);
	[_vehicle] spawn XCheckSMHardTarget;
	sleep 2.022;
	["specops", 1, "basic", 2, _poss,100,true] spawn XCreateInf;
	sleep 2.123;
	["shilka", 3, "bmp", 1, "tank", 1, _poss,1,110,true] spawn XCreateArmor;
	__AddToExtraVec(_vehicle)
};

if (true) exitWith {};