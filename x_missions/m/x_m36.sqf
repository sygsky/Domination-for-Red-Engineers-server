// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[11919.0,15361.0,0], [11967.0,15314.0,0],[11841.0,15302.0,0],[11935,15480.0,0],[11950.0,15395.0,0],[11897.4,15424.0,0]]; // index: 36,   Capture the flag, Pesadas
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (X_Client) then {
	current_mission_text = format[localize "STR_SYS_506","Pesadas"]; //"Враг занял н.п. Pesadas. Вам надлежит выкрасть полковое знамя и доставить его к нам на базу.";
	current_mission_resolved_text = localize "STR_SYS_507"; //"Задание выполнено! Полк без знамени что дырка без бублика. Они прячут глаза и лижут мороженое.";
};

if (isServer) then {
	[x_sm_pos] execVM "x_missions\common\x_sideflag.sqf";
};

if (true) exitWith {};