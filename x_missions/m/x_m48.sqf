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
	current_mission_text = localize "STR_SYS_502"; // "Высший офицерский состав обосновался в городе Corazol. Выша задача взорвать пять трансформаторных подстанций на юго-западе города, оставив гадов без электричества.";
	current_mission_resolved_text = localize "STR_SYS_503"; // "Задание выполнено! Трансформаторные подстанции уничтожены.";
};

if (isServer) then {
	_poss = x_sm_pos select 0;
	[_poss] execVM "x_missions\common\x_sidecora.sqf"; // TODO: check why is can completed automatically in 1 minute
};

if (true) exitWith {};