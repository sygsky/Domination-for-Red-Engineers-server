// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;

x_sm_pos = [[12956.3,8638.32,0]]; // index: 48,   Transformer substation at Corazol, attention, uses nearestObject ID
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SM_48"; // "Senior officers settled in the city of Corazol. Your task is to blow up five transformer substations at the South-West of the city, leaving the bastards without electricity";
	current_mission_resolved_text = localize "STR_SM_048"; // "The target is completed! Transformer substations are destroyed";
};

if (isServer) then {
	_poss = x_sm_pos select 0;
	[_poss] execVM "x_missions\common\x_sidecora.sqf";
};

if (true) exitWith {};