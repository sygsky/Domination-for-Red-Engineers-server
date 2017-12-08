// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[17563.9,9550.78,0], [17589,9571.56,0], [17572.9,9567.49,0], [17529.4,9573.4,0], [17563.9,9533.05,0], [17527.6,9532.41,0], [17600.9,9551.71,0]]; // index: 31,   Tank depot near Everon
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SM_31";
	current_mission_resolved_text = localize "STR_SM_031";
};
if (isServer) then {
	[x_sm_pos, 1] execVM "x_missions\common\x_sidetanks.sqf";
};

if (true) exitWith {};