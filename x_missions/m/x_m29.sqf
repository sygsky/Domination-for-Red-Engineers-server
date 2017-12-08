// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[8166.81,17018.4,0],  [8130.84,17010.5,0],[8121.2,16991.2,0],[8140.73,17030,0],[8149.6,17049.7,0], [8162.93,16994.6,0],[8154.33,16974.8,0]]; // index: 29,   Tank depot at Cabo Juventudo
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SM_29"; // "There is an enemy depot in a base south of Cabo Juventudo. Destroy all tanks there to weaken the enemy troops."
	current_mission_resolved_text = localize "STR_SM_029"; // "Good job. All tanks are down."
};

if (isServer) then {
	[x_sm_pos, 0] execVM "x_missions\common\x_sidetanks.sqf";
};

if (true) exitWith {};