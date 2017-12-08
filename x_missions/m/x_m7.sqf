// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[6400.09,7472.16,0], [6611.5,7652.1,0]]; // index: 7,   Training facility in San Peregrino
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = "Обнаружен вражеский лагерь по подготовке солдат в San Peregrino. Ваша задача - уничтожить офицерский клуб.";
	current_mission_resolved_text = "Задание выполнено! Здание для разврата офицеров уничтожено.";
};

if (isServer) then {
	__PossAndOther
	_vehicle = "Land_OrlHot" createvehicle (_poss);
	[_vehicle] spawn XCheckSMHardTarget;
	_vehicle setDir 270;
	sleep 2.132;
	["specops", 1, "basic", 1, _poss,80,true] spawn XCreateInf;
	sleep 2.234;
	["shilka", 1, "bmp", 1, "tank", 1, _poss,1,110,true] spawn XCreateArmor;
	__AddToExtraVec(_vehicle)
};

if (true) exitWith {};