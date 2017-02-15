// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[13113,16509.7,0]]; // index: 8,   Radio tower at Pico de Revolucion
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (X_Client) then {
	current_mission_text = localize "STR_SYS_510"; //"На вершине горы Pico de Revolucion находится ТельаВизионная башня. Враг использует её для зомбирования общества. Простая задача, уничтожьте телебашню.";
	current_mission_resolved_text = localize "STR_SYS_511"; //"Отличная работа! Местные жители больше не увидят ни Ксении Собчак, ни любимца её папаши.";
};

if (isServer) then {
	__Poss
	_vehicle = "Land_telek1" createvehicle (_poss);
	_vehicle setVectorUp [0,0,1];
	[_vehicle] spawn XCheckSMHardTarget;
	sleep 2.22;
	["specops", 1, "basic", 1, _poss,0] spawn XCreateInf;
};

if (true) exitWith {};