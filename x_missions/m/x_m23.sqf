// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[10312.7,13407.5,0], [10202.5,13416.8,0], [10309.9,13471.5,0],[10433.7,13239.7,0],[10319.8,13444.5,0],[10284,13425.8,0],[10326.3,13397.6,0],[10335.9,13354.9,0]]; // index: 23,   Special forces boats in a bay near Pacamac
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SYS_522"; //"Разведка докладывает что вблизи Pacamac силы специального назначения готовят операцию. Там же, на побережье, были обнаружены надувные лодки. Ваша задача уничтожить лодки и тем самым сорвать операцию";
	current_mission_resolved_text = localize "STR_SYS_523"; //"Задание выполнено! Лодки уничтожены.";
};

if (isServer) then {
	[x_sm_pos] execVM "x_missions\common\x_sideboats.sqf";
};

if (true) exitWith {};