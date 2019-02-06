// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[17739.78,12371.70,0], [17710.70,12422.76,0]]; // index: 16,   Radio tower near Cabo Valiente/Tres Valles
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	// "Недалеко от %1 расположен вражеский пост. Ваша задача: уничтожение радио башни на нём."
	current_mission_text = format[localize "STR_SYS_211", "Tres Valles"];
	// "Задание выполнено! Радио башня уничтожена."
	current_mission_resolved_text = localize "STR_SYS_212";
};

if (isServer) then {
	__PossAndOther
	_vehicle = "Land_telek1" createVehicle (_poss);
	_vehicle setVectorUp [0,0,1];
	[_vehicle] spawn XCheckSMHardTarget;
	sleep 2.22;
	["shilka", 1, "bmp", 1, "tank", 1, _pos_other,1,110,true] spawn XCreateArmor;
	sleep 2.333;
	["specops", 1, "basic", 2, _poss,120,true] spawn XCreateInf;
	__AddToExtraVec(_vehicle)
};

if (true) exitWith {};