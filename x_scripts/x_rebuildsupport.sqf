// x_rebuildsupport.sqf, by Xeno
// call only on client computer
//
private ["_id","_fac","_no","_pos"];

#include "x_setup.sqf"

_id = _this select 2;
_fac = _this select 3;

hint localize format["+++ x_rebuildsupport.sqf: %1", _this];
#ifdef __RANKED__

// TODO: if (_string_player in d_is_engineer /*|| __AIVer*/) then {
// _string_player = format ["%1",_p];
if (score player < (d_ranked_a select 13)) exitWith {
	(format [localize "STR_SYS_213" /* "Для ремонта здания необходимо очков: %2, вы имеете: %1!" */, score player,(d_ranked_a select 13)]) call XfHQChat;
};

_addscore = (d_ranked_a select 20);

// if non-engineer, to repair you need enough score in engineering fund

    #ifdef __REP_SERVICE_FROM_ENGINEERING_FUND__

if (_addscore < SYG_engineering_fund) exitWith
{
    // not enough scores in fund
    (format [localize "STR_SYS_137_3", (d_ranked_a select 20), SYG_engineering_fund]) call XfHQChat;
};
// enough scores in fund
SYG_engineering_fund = SYG_engineering_fund - _addscore;
publicVariable "SYG_engineering_fund";
(format [localize "STR_SYS_137_4", (d_ranked_a select 20), SYG_engineering_fund]) call XfHQChat;

    #endif

    #ifndef __REP_SERVICE_FROM_ENGINEERING_FUND__

player addScore _addscore * -1;

    #endif

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
