// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[16197.8,10336.2,0]]; // index: 39,   Radio tower on top of Monte Valor
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = format[localize "STR_SM_8", "Monte Valor"]; //"На вершине горы Pico de Revolucion находится ТельаВизионная башня. Враг использует её для зомбирования общества. Простая задача, уничтожьте телебашню.";
	current_mission_resolved_text = localize "STR_SM_039"; //"Отличная работа! Местные жители больше не увидят ни Ксении Собчак, ни любимца её папаши.";
};

if (isServer) then {
	__Poss
	_vehicle = "Land_telek1" createvehicle (_poss);
	_vehicle setVectorUp [0,0,1];
	[_vehicle] spawn XCheckSMHardTarget;
	sleep 2.22;
	["shilka", 1, "bmp", 1, "tank", 1, _poss,1,110,true] spawn XCreateArmor;
	sleep 2.333;
	["specops", 1, "basic", 1, _poss,120,true] spawn XCreateInf;
	__AddToExtraVec(_vehicle)
};

if (true) exitWith {};