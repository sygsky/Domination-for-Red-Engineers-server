// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[11424.7,8573.97,0], [11354.3,8554.22,0]]; // index: 10,   Artillery at top of mount San Esteban
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SM_10"; //"На вершине горы San Esteban расположилась вражеская артиллерия. Задача: уничтожить всю технику.";
	current_mission_resolved_text = localize "STR_SM_010"; //"Задание выполнено! Артиллерия уничтожена.";
};

if (isServer) then {
	_xarti = (if (d_enemy_side == "EAST") then {"D30"} else {"M119"});
	__PossAndOther
	_vehicle = objNull;
	_vehicle = _xarti createVehicle (_poss);
	#ifndef __TT__
	_vehicle addEventHandler ["killed", {_this call XKilledSMTargetNormal}];
	#endif
	#ifdef __TT__
	_vehicle addEventHandler ["killed", {_this call XKilledSMTargetTT}];
	#endif
	_vehicle lock true;
	sleep 2.21;
	["specops", 1, "basic", 1, _poss,0] spawn XCreateInf;
	sleep 2.045;
	["shilka", 1, "bmp", 2, "tank", 0, _pos_other,1,0] spawn XCreateArmor;
};

if (true) exitWith {};