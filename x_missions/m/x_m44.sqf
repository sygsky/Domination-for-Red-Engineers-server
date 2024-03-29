// by Xeno: x_missions\m\x_m44.sqf
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[9529.46,3492.03,0], [9570.09,3566.11,0]]; // index: 44,   Steal chopper prototype on San Thomas
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SM_44";//  "The enemy began testing the new helicopter. Move to San Tomas, capture this vehicle and transport it to the base."
	current_mission_resolved_text = localize "STR_SM_044";// "The order is executed! You've got the enemy attack helicopters to explore!"
};

if (isServer) then {
#ifdef __ACE__
	_xchopper = (if (d_enemy_side == "EAST") then {"ACE_KA50"} else {"ACE_AH1Z_TOW"});
#else
	_xchopper = (if (d_enemy_side == "EAST") then {"KA50"} else {"AH1W"});
#endif
	__PossAndOther
	_hangar = "Land_SS_hangar" createVehicle (_poss);
	_hangar setDir 90;
	__AddToExtraVec(_hangar)
	sleep 1.0123;
	_vehicle = objNull;
	_vehicle = _xchopper createVehicle (_poss);
	_vehicle setDir 270;
	sleep 2.123;
	["specops", 1, "basic", 1, _poss,100,true] spawn XCreateInf;
	sleep 2.221;
	["shilka", 1, "bmp", 2, "tank", 0, _pos_other,1,150,true] spawn XCreateArmor;
	sleep 2.543;
	[_vehicle] execVM "x_missions\common\x_sidesteal.sqf";
	[_vehicle] call XAddCheckDead;

    sleep 10;
	[_poss,200] call SYG_rearmAroundAsHeavySniper;
};

if (true) exitWith {};