// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[12723,8729.78,0], [6946.93,8226.66,0]]; // index: 21,   Convoy Corazol to Estrella, start and end position
x_sm_type = "convoy"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (X_Client) then {
	current_mission_text = format[localize "STR_SYS_500","Corazol","Estrella"]; //"Враг отправил колонну снабжения усиленную бронетехникой из Corazol в Estrella. Ваша задача, обнаружить и уничтожить конвой."
	current_mission_resolved_text = localize "STR_SYS_501"; // "Задание выполнено! Конвой разбит.";
};

if (isServer) then {
	__PossAndOther
	[_poss, _pos_other, 1] execVM "x_missions\common\x_sideconvoy.sqf";
};

if (true) exitWith {};