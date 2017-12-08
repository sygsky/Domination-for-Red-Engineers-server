// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[11359.1,5325.78,0],[11346.2,5357.91,0],[11249.9,5286.24,0],[11200.1,5182.9,0],[11287.7,5280.05,0],[11347.4,5312.99,0]]; // index: 32,   Capture the flag, Parato
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = format[localize "STR_SYS_506","Parato"]; //"Враг занял н.п. Parato. Вам надлежит выкрасть полковое знамя и доставить его к нам на базу";
	current_mission_resolved_text = localize "STR_SYS_507"; //"Задание выполнено! Полк без знамени что дырка без бублика. Они прячут глаза и лижут мороженое";
};

if (isServer) then {
	[x_sm_pos] execVM "x_missions\common\x_sideflag.sqf";
};

if (true) exitWith {};