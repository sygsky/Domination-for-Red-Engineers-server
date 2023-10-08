// by Sygsky
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1

x_sm_pos = [[2582.7,2427.4,0], [2555.0,2497.1,0]]; //  steal plane prototype, Rahmadi, second array position armor
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = format[localize "STR_SM_2","Rahmadi"]; // "Враг испытывает новый многоцелевой самолёт в %1. Захватите его и доставьте на базу.";
	current_mission_resolved_text = localize "STR_SM_02"; //"Задание выполнено! Вы получили новый многоцелевой самолёт противника.";
};

if (isServer) then {
	_planes = if (d_enemy_side == "EAST") then
#ifdef __ACE__
	{["ACE_Su30Mk_KAB500KR","ACE_Su30Mk_Kh29T","ACE_Su34B"]}
	else { SYG_AV8B_TYPES }; //+++ Sygsky: for more fun, defined at i_server.sqf top lines
#else
	{["SU34","Su34B"]}
	else { ["AV8", "AV8B2"] }; //+++ Sygsky: for more fun
#endif
	_xplane = _planes call XfRandomArrayVal; //+++ Sygsky: for more fun
	__PossAndOther;
	_hangar = "Land_SS_hangar" createVehicle (_poss);
	_hangar setDir 180.000000;
//	__AddToExtraVec(_hangar)
	_hangar call SYG_addToExtraVec;
	sleep 1.0123;
	
	_vehicle = objNull;
	_vehicle = _xplane createVehicle (_poss);
	_vehicle setDir 0;
	sleep 2.123;
	["specopsbig", 1, "basic", 3, _poss,200,true] spawn XCreateInf;
	sleep 2.221;
	["shilka", 3, "bmp", 1, "tank", 2, _pos_other,1,200,true] spawn XCreateArmor;
	[_vehicle] execVM "x_missions\common\x_sidesteal.sqf";
	[_vehicle] call XAddCheckDead;
    sleep 10;
	
    [_poss, 300] call SYG_rearmAroundAsHeavySniper;

};


if (true) exitWith {};