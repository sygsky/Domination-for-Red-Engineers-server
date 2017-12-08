// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[10245.7,15784.9,0],[10276.6,15813.6,0],[10269.1,15751,0],[10287.4,15719.9,0]]; // index: 28,   Radio Tower at bunker near Mataredo
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	// "Недалеко от %1 расположен вражеский пост. Ваша задача: уничтожение радио башни на нём."
	current_mission_text = format[localize "STR_SYS_211", "Passo Paradiso"];
	// "Задание выполнено! Радио башня уничтожена."
	current_mission_resolved_text = localize "STR_SYS_212";
};

if (isServer) then {
	__PossAndOther
	_vehicle = "Land_telek1" createvehicle (_poss);
	_vehicle setVectorUp [0,0,1];
	[_vehicle] spawn XCheckSMHardTarget;
	sleep 2.22;
	["shilka", 1, "bmp", 0, "tank", 0, _pos_other,1,0,false] spawn XCreateArmor;
	sleep 2.333;
	_poss_other = x_sm_pos select 2;
	["specops", 1, "basic", 2, _poss_other,80,true] spawn XCreateInf;
	sleep 2.333;
	_poss_other = x_sm_pos select 3;
	["shilka", 0, "bmp", 1, "tank", 1, _poss_other,1,100,true] spawn XCreateArmor;
	__AddToExtraVec(_vehicle)
};

if (true) exitWith {};