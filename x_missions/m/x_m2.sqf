// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1

#ifdef __TT__
x_sm_pos = [[9469.29,9980.0,0], [9475.11,10052.3,0]]; // index: 2,   steal plane prototype, Paraiso airfield, second array position armor
#endif
#ifndef __TT__
x_sm_pos = [[18074.1,18206.8,0], [18151.5,18216.1,0]]; //  steal plane prototype, Antigua, second array position armor (Paraiso in TT version)
#endif
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif
if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	#ifdef __TT__
	current_mission_text = format[localize "STR_SM_2","Paraiso Airfield"]; //"Враг испытывает новый прототип самолета в Paraiso Airfield. Захватите его и доставьте на базу.";
	current_mission_resolved_text = localize "STR_SM_02"; //"Превосходно сработано. Вы получили прототип самолета.";
	#endif
	#ifndef __TT__
	current_mission_text = format[localize "STR_SM_2","Antigua"]; // "Враг испытывает новый многоцелевой самолет в Antigua. Захватите его и доставьте на базу.";
	current_mission_resolved_text = localize "STR_SM_02"; //"Задание выполнено! Вы получили новый многоцелевой самолет противника.";
	#endif
};

if (isServer) then {
//	_xplane = (if (d_enemy_side == "EAST") then {"SU34"} else {"ACE_A10_MK82HD"});

	_planetypes = if (d_enemy_side == "EAST") then
#ifdef __ACE__
    {["ACE_Su27S","ACE_Su27S2"]} else
	{SYG_AV8B_TYPES};
#else
	{["SU34","Su34B"]}
	else { ["A10"] }; //+++ Sygsky: for more fun
#endif
	_xplane =  _planetypes call XfRandomArrayVal; //+++ Sygsky: for more fun
	__PossAndOther;
	_hangar = "Land_SS_hangar" createVehicle (_poss);
	_hangar setDir 260;
	__AddToExtraVec(_hangar)
	sleep 1.0123;
	_vehicle = objNull;
	_vehicle = _xplane createVehicle (_poss);
	_vehicle setDir 80;
	sleep 2.123;
	["specops", 1, "basic", 2, _poss,100,true] spawn XCreateInf;
	sleep 2.221;
	["shilka", 1, "bmp", 1, "tank", 2, _pos_other,1,100,true] spawn XCreateArmor;
	[_vehicle] execVM "x_missions\common\x_sidesteal.sqf";
	[_vehicle] call XAddCheckDead;
    sleep 10;
	[_poss,200] call SYG_rearmAroundAsHeavySniper;
};


if (true) exitWith {};