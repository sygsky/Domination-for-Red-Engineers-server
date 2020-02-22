// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

// TODO: change patrol area to rectangular instead  std round one
x_sm_pos = [[13978.5,15741.7,0]]; // index: 38,   Biological weapons near Passo Epone
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = format[localize "STR_SYS_520","Passo Epone"];// "По данным разведки, враг разместил где-то в районе Passo Epone располагается производство химического оружия. Ваша задача найти башню водохранилища и уничтожить её.";
	current_mission_resolved_text = localize "STR_SYS_521"; //"Задание выполнено! Химреактор уничтожен.";
};

if (isServer) then {
	__Poss
	_vehicle = "Land_watertower1" createVehicle (_poss);
	[_vehicle] spawn XCheckSMHardTarget;
	sleep 2.123;
	["specops", 1, "basic", 1, _poss,150,true] spawn XCreateInf;
	sleep 2.123;
	["shilka", 1, "bmp", 1, "tank", 1, _poss,1,100,true] spawn XCreateArmor;
	__AddToExtraVec(_vehicle)
};

if (true) exitWith {};