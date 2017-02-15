// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

x_sm_pos = [[10146.6,16968.6,0]]; // index: 52,   Shot down chopper
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (X_Client) then {
	current_mission_text = format[localize "STR_SYS_504","Mataredo",15]; //"Возле Mataredo был сбит наш вертолет. Ваша задача как можно быстрее выдвинуться на поиски экипажа вертолета. Вражеские войска так же выслали свои силы в зону крушения. У вас примерно 15 минут до их прибытия. (Завершить миссию может только игрок в роли спасателя)";
	current_mission_resolved_text = localize "STR_SYS_505"; //"Задание выполнено! Операция по спасению экипижа вертолета прошла успешно.";
};

if (isServer) then {
	_time_till_enemy = (15 * 60) + random 60; // 15 minutes + some random time
	[x_sm_pos,time + _time_till_enemy]  execVM "x_missions\common\x_sideevac.sqf";
};

if (true) exitWith {};