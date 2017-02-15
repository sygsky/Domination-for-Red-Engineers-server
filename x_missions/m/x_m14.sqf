// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[15681.9,11384.6,0], [15851.6,11431.2,0]]; // index: 14,   Radio tower at Monte Liberacion
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (X_Client) then {
	current_mission_text = "На вершине горы Monte Liberacion построена телебашня. Враг разместил на ней своё радиопередающее оборудование. Задача: уничтожить источник дезинформации.";
	current_mission_resolved_text = "Задание выполнено! Вражеская телеигла уничтожена. На очереди - Останкинская...";
};

if (isServer) then {
	__PossAndOther
	_vehicle = "Land_telek1" createvehicle (_poss);
	_vehicle setVectorUp [0,0,1];
	[_vehicle] spawn XCheckSMHardTarget;
	sleep 2.22;
	["shilka", 3, "bmp", 1, "tank", 0, _pos_other,1,110,true] spawn XCreateArmor;
	sleep 2.333;
	["specops", 1, "basic", 1, _poss,70,true] spawn XCreateInf;
	__AddToExtraVec(_vehicle)
};

if (true) exitWith {};