// x_rebuildsupport.sqf, by Xeno
// call only on client computer
// Non-engineer can use it only if if __REP_SERVICE_FROM_ENGINEERING_FUND__ is defined in x_setup.sqf
//
private ["_id","_fac","_no","_pos"];

#include "x_setup.sqf"

_id = _this select 2;
_fac = _this select 3;

hint localize format["+++ x_rebuildsupport.sqf: %1", _this];
_is_engineer = format ["%1", player] in d_is_engineer;

_addscore = (d_ranked_a select 20); // how many scores needed to rebild service

#ifdef __ADD_SCORE_FOR_FACTORY_SUPPORT__
_engineer_profit = __ADD_SCORE_FOR_FACTORY_SUPPORT__; // add score to engineer for support
#else
_engineer_profit = - _addscore;   // subtract score from engineer for support
#endif

#ifdef __RANKED__

if (score player < (d_ranked_a select 13)) exitWith {
	(format [localize "STR_SYS_213" , score player,(d_ranked_a select 13)]) call XfHQChat; // "You need %2 scores to rebuild a factory, your current scores are: %1!"
};


// non-engineer is here only if __REP_SERVICE_FROM_ENGINEERING_FUND__ is defined in x_setup.sqf

_exit = false;
if (!_is_engineer) then
{
    if ( SYG_engineering_fund < _addscore) exitWith  // to repair you need enough score in engineering fund
    {
        // not enough scores in fund
        (format [localize "STR_SYS_137_3", (d_ranked_a select 20), SYG_engineering_fund]) call XfHQChat;
        _exit = true;
    };
    // enough scores in fund
    SYG_engineering_fund = SYG_engineering_fund - _addscore; // subtract non-engineer support price
    publicVariable "SYG_engineering_fund";
    (format [localize "STR_SYS_137_4", (d_ranked_a select 20), SYG_engineering_fund]) call XfHQChat;
}
else
{
    player addScore _engineer_profit; // subtract (if normal flow) or add if is defined __ADD_SCORE_FOR_FACTORY_SUPPORT__
};
if (_exit ) exitWith {false};

#endif

player removeAction _id;

_no =  nearestObject [player, "Land_budova2_ruins"];
_pos = position _fac;
_pos = [_pos select 0,_pos select 1, 0];
["d_del_ruin",_pos] call XSendNetStartScriptAll;
deleteVehicle _no;
sleep 1.021;

if (!_is_engineer) then
{
   (localize "STR_SYS_214_1") call XfHQChat; // "The service is being repaired at the expense of the engineering Fund..."
}
else
{
   (localize "STR_SYS_214") call XfHQChat; // "Restore support building. This will take some time and scores..."
};

_d_fac_ruins_pos = [_pos, _fac];
["d_fac_ruins_pos",_d_fac_ruins_pos] call XSendNetStartScriptServer;

if (true) exitWith {};
