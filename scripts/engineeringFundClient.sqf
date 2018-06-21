/*
	author: Sygsky
	description: process on clients all Engineering fund messages from server
	call _this array:  ["engineering_fund", "+"|"-"|"=", _score | _something, name player]
	returns: nothing
*/
if (isServer) exitWith {false};
_pname   = _this select 3; // name of player that send command
if ( _pname != name player) exitWith {false};

_command = _this select 1; // command to handle this fund
_arg     = _this select 2; // score/other argument to handle with, may be array e.g.

hint localize format["+++ engineering_fund request: %1", _this ];

_scalar = typeName _arg == "SCALAR";

if ( _scalar) exitWith
{
    switch _command do {
        //  some scores were added to the fund
        case "+":
        {
            playSound "gong";
            (format[localize "STR_ENG_FUND_1", _arg]) call XfGlobalChat;
        };
        // subtracts designated scores
        case "-":
        {
            playSound "losing_patience";
            (format[localize "STR_ENG_FUND_2", _arg]) call XfGlobalChat;
        };
        // returns available score number, asked to understand that fund has enough money
        case "=":
        {
            playSound "good_news";
            (format[localize "STR_ENG_FUND_2", _arg]) call XfGlobalChat;
        };
    };
};

hint localize format["--- Expected ""engineering_fund"" command arguments invalid:  %1", _this];
if (true) exitWith {false};

