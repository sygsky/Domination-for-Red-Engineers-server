// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[11611.9,14336.6,0]]; // index: 41,   Prison camp, Tandag
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (X_Client) then {
	current_mission_text = format[localize "STR_SYS_118", "Tandag"];//	"В Tandag расположен лагерь, где незаконно удерживается и подвергается различным пыткам гражданское население. Ваша задача - освободить гражданских и доставить их на базу. Для выполнения задания хотя бы один заложник должен добраться до базы живым. (Завершить миссию может только игрок в роли спасателя).";
	current_mission_resolved_text = localize "STR_SYS_119"; //"Задание выполнено! Пленные освобождены.";
};

if (isServer) then {
	[x_sm_pos] execVM "x_missions\common\x_sideprisoners.sqf";
};

if (true) exitWith {};