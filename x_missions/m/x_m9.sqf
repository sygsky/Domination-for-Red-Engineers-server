// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[19225.5,13889.3,0], [19231.1,13939,0], [19236.2,13992.5,0],  [19198.6,13912.9,0]]; // index: 9,   Helicopter Prototype at Pita Airfield
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SM_9"; //"В аэропорту Pita проходят летные испытания нового вертолета. Задача - уничтожить его!";
	current_mission_resolved_text = localize "STR_SM_09"; //"Задание выполнено! Вертолёт уничтожен.";
};

if (isServer) then {
	_xchopper = (if (d_enemy_side == "EAST") then {"KA50"} else {"ACE_AH64_AGM"});
	_randomv = floor random 2;
	__PossAndOther
	if (_randomv == 1) then {_poss = x_sm_pos select 3;};
	_pos_other2  = x_sm_pos select 2;
	_vehicle = objNull;
	_vehicle = _xchopper createvehicle (_poss);
	#ifndef __TT__
	_vehicle addEventHandler ["killed", {_this call XKilledSMTargetNormal}];
	#endif
	#ifdef __TT__
	_vehicle addEventHandler ["killed", {_this call XKilledSMTargetTT}];
	#endif
	_vehicle setDir 40;
	_vehicle lock true;
	sleep 2.123;
	["specops", 1, "basic", 1, _poss,90,true] spawn XCreateInf;
	sleep 2.111;
	["shilka", 1, "bmp", 2, "tank", 0, _pos_other2,1,100,true] spawn XCreateArmor;
};

if (true) exitWith {};