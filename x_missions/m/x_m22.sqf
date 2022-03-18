// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1

x_sm_pos = [[7736.82,15810.5,0], [14293.2,9450.24,0]]; // index: 22,   Convoy Hunapu to Modesta, start and end position
x_sm_type = "convoy"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,1)}; // it is request for pos, not SM execution

if (X_Client) then {
	// ;
	current_mission_text = format[ localize "STR_SYS_500", "Hunapu", "Modesta", d_ranked_a select 11 ]; //"The enemy has sent a convoy of supply, reinforced by armored vehicles, from %1 to %2. Your task: find and destroy all the machines, without any exception, including empty and upside down. If the mission fails, the penalty is -%3"
	current_mission_resolved_text = localize "STR_SYS_501"; // Task completed! Convoy is destroyed
};

if (isServer) then {
	__PossAndOther;
	[_poss, _pos_other, 2] execVM "x_missions\common\x_sideconvoy.sqf";
};

if (true) exitWith {};