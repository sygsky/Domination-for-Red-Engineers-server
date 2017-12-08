// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[14750.5,13925.6,0], [14750.4,13935.4,0], [14712.9,13992.4,0]]; //  steal tank prototype, Alcazar, array 2 and 3 = infantry and armor positions
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif
if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	#ifndef __TT__
	current_mission_text = localize "STR_SM_3"; //"Враг производит испытания нового танка. Отправляйтесь в Alcazar, захватите и доставьте образец на базу.";
	current_mission_resolved_text = localize "STR_SM_03"; //"Прекрасная работа. Вы получили усовершенствованую версию танка.";
	#endif
	#ifdef __TT__
	current_mission_text = localize "STR_SM_3"; //"Враг производит испытания нового танка. Отправляйтесь в Alcazar, захватите и доставьте образец на базу.";
	current_mission_resolved_text = localize "STR_SM_03"; //"Задание выполнено! Вы получили усовершенствованую версию танка.";
	#endif
};

if (isServer) then {
#ifdef __ACE__
	_xtank = (if (d_enemy_side == "EAST") then {"ACE_T90A"} else {"ACE_M1A2_SEP_TUSK_Desert"});
#else
	_xtank = (if (d_enemy_side == "EAST") then {"T72"} else {"M1Abrams"});
#endif
	__PossAndOther
	_pos_other2 = x_sm_pos select 2;
	_vehicle = objNull;
	_vehicle = _xtank createvehicle (_poss);
	#ifndef __TT__
	sleep 2.123;
	["specops", 2, "basic", 2, _pos_other,100,true] spawn XCreateInf;
	sleep 2.321;
	["shilka", 1, "bmp", 2, "tank", 0, _pos_other2,1,200,true] spawn XCreateArmor;
	[_vehicle] execVM "x_missions\common\x_sidesteal.sqf";
	[_vehicle] call XAddCheckDead;
	#endif

	#ifdef __TT__
	_vehicle addEventHandler ["killed", {_this call XKilledSMTargetTT}];
	_vehicle lock true;
	sleep 2.123;
	["specops", 1, "basic", 1, _pos_other,100,true] spawn XCreateInf;
	sleep 2.321;
	["shilka", 1, "bmp", 1, "tank", 1, _pos_other2,2,200,true] spawn XCreateArmor;
	#endif
	sleep 10;
    [_pos_other,200] call SYG_rearmAroundAsHeavySniper;
};

if (true) exitWith {};