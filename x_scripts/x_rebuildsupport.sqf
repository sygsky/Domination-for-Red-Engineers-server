// x_rebuildsupport.sqf, by Xeno
// call only on client computer
//
private ["_id","_fac","_no","_pos"];

#include "x_setup.sqf"

_id = _this select 2;
_fac = _this select 3;

#ifdef __RANKED__
if (score player < (d_ranked_a select 13)) exitWith {
	(format [localize "STR_SYS_213" /* "Для ремонта здания необходимо очков: %2, вы имеете: %1!" */, score player,(d_ranked_a select 13)]) call XfHQChat;
};
player addScore (d_ranked_a select 20) * -1;
#endif

player removeAction _id;

_no =  nearestObject [player, "Land_budova2_ruins"];
_pos = position _fac;
_pos = [_pos select 0,_pos select 1, 0];
["d_del_ruin",_pos] call XSendNetStartScriptAll;
deleteVehicle _no;
sleep 1.021;

(localize "STR_SYS_214") /* "Производится ремонт здания. Это займёт некоторое время и убавит счёт..." */ call XfHQChat;

_d_fac_ruins_pos = [_pos, _fac];
["d_fac_ruins_pos",_d_fac_ruins_pos] call XSendNetStartScriptServer;

if (true) exitWith {};
