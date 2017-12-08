// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[11388.3,9848.09,0]]; // index: 34,   Transformer station near Paraiso
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SM_34"; // "Высший офицерский состав расслабляется в городе Paraiso. Выша задача взорвать электростанцию на востоке города, тем самым оставив их бордель без электричества.";
	current_mission_resolved_text = localize "STR_SM034";//"Задание выполнено! Электростанция уничтожена, бордель закрылся.";
};

if (isServer) then {
	__Poss
	_vehicle = "Land_trafostanica_velka" createvehicle (_poss);
	_vehicle setDir 273.398;
	[_vehicle] spawn XCheckSMHardTarget;
	sleep 2.22;
	["shilka", 1, "bmp", 1, "tank", 1, _poss,1,150,true] spawn XCreateArmor;
	sleep 2.123;
	["specops", 1, "basic", 1, _poss,100,true] spawn XCreateInf;
	__AddToExtraVec(_vehicle)
};

if (true) exitWith {};