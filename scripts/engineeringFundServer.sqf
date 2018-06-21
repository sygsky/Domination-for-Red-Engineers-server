/*
	author: Sygsky
	description: process all Engineering fund actions on server only
	call _this array:  ["engineering_fund", "+"|"-"|"=", _score | _something, name player]
	returns: nothing
*/
if (!isServer) exitWith {false};

if (isNil "SYG_engineering_fund") then
{
    SYG_engineering_fund = 0;
};

private [""];

_command = _this select 1; // command to handle this fund
_arg     = _this select 2; // score/other argument to handle with, may be array e.g.
_pname   = _this select 3; // name of player that send command

hint localize format["+++ engineering_fund request: %1", _this ];

_scalar = typeName _arg == "SCALAR";

_processed = false;
switch _command do {
    // adds some scores to the fund
    case "+":
    {
        if ( _scalar ) exitWith
        {
            SYG_engineering_fund = SYG_engineering_fund + _arg; // increase fund
            publicVariable "SYG_engineering_fund";
            _processed = true;
        };
    };
    // subtracts designated scores
    case "-":
    {
        if ( _scalar ) exitWith
        {
            SYG_engineering_fund = SYG_engineering_fund - _arg; // decrease fund
            publicVariable "SYG_engineering_fund";
            _processed = true;
        };

    };
    // returns available score number
    case "=":
    {
        _processed = true;
    };
};

if (_processed) exitWith
{
    [_this select 0, _command, SYG_engineering_fund, _pname] call XSendNetStartScriptClient; // inform clients about action results
    true
};

hint localize format["--- Expected ""engineering_fund"" command arguments invalid:  %1", _this];
if (true) exitWith {false};

