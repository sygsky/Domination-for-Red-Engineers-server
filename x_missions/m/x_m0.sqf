// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[14807.74,12753.15,0]]; // radar tower near Passo de Marco (Bagango circumstances)
x_sm_type = "normal"; // not "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif
if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SYS_312"; // "На востоке от Bagango расположены две радиоантенны. Одна из них используется врагом для передачи данных. Ваша задача: уничтожить нужную радиоантенну.";
	current_mission_resolved_text = localize "STR_SYS_313"; //"Задание выполнено! Радиомачта уничтожена.";
};

if (isServer) then {
	__Poss
	_vehicle = "Land_radar" createvehicle (_poss);
	_vehicle setVectorUp [0,0,1];
	[_vehicle] spawn XCheckSMHardTarget;
	// createGuardedPoint[d_side_enemy, position _vehicle, -1, _vehicle];
	sleep 3.21;
	if ( random 10 < 5 ) then
	{
		["uaz_mg", 1, "uaz_grenade", 0, "tank", 0, _poss, 2, 100, true] spawn XCreateArmor; // patrol around
	};
	["specops", 1, "basic", 1, _poss,0,true] spawn XCreateInf;
	__AddToExtraVec(_vehicle)
};

if (true) exitWith {};