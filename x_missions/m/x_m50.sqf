// by Xeno, x_m50.sqf
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[16591.5,11842.6,0]]; // index: 50,   Artillery base
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SM_50"; //"Finally we've found the enemy artillery base. If you can destroy all artillery guns the artillery observers at main targets have nothing to call in artillery strikes anymore."
	current_mission_resolved_text = localize "STR_SM_050"; //"Good job. All artillery guns are down. No artillery observers will appear at main targets anymore."
};

if (isServer) then {
	__Poss;
	[_poss] execVM "x_missions\common\x_sidearti.sqf";

    sleep 10;
    [_poss, 400] call SYG_rearmAroundAsHeavySniper;
};

if (true) exitWith {};