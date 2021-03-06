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

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = format[localize "STR_SM_8", "Pico de Revolucion"]; //"На вершине горы Pico de Revolucion находится ТельаВизионная башня. Враг использует её для зомбирования общества. Простая задача, уничтожьте телебашню.";
	current_mission_resolved_text = localize "STR_SM_08"; //"Отличная работа! Местные жители больше не увидят ни Ксении Собчак, ни любимца её папаши.";
};

if (isServer) then {
	__Poss
	_vehicle = "Land_telek1" createVehicle (_poss);
	_vehicle setVectorUp [0,0,1];
	[_vehicle] spawn XCheckSMHardTarget;
	sleep 2.22;
	["specops", 1, "basic", 1, _poss,0] spawn XCreateInf;
};

if (true) exitWith {};