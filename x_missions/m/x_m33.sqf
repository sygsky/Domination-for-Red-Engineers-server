// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[11184.0,8849.0,0],   [11138.0,8869.0,0], [11195.0,8820.0,0], [11203.0,8857.0,0],[11149.0,8791.0,0],[11158.0,8860,0]]; // index: 33,   Capture the flag, Bonanza
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (X_Client) then {
	current_mission_text = format[localize "STR_SYS_506","Bonanza"]; //"Враг занял н.п. Bonanza. Вам надлежит выкрасть полковое знамя и доставить его к нам на базу";
	current_mission_resolved_text = localize "STR_SYS_507"; //"Задание выполнено! Полк без знамени что дырка без бублика. Они прячут глаза и лижут мороженое";
};

if (isServer) then {
	[x_sm_pos] execVM "x_missions\common\x_sideflag.sqf";
};

if (true) exitWith {};