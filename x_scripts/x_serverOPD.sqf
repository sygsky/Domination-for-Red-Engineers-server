// Xeno, x_scripts\x_serverOPD.sqf, OnPlayerDisconnected
if (!isServer) exitWith{};
private ["_name", "_index", "_parray", "_oldwtime", "_connecttime", "_newwtime","_str"];

_name = _this select 0;

#include "x_setup.sqf"
#include "x_macros.sqf"

#define __DEBUG_PRINT__


if (_name == "__SERVER__") exitWith {};

// __DEBUG_NET("x_serverOPD player disconnected",_name)

_index = d_player_array_names find _name;
if (_index >= 0) then {
    _parray = d_player_array_misc select _index;
    _oldwtime = _parray select 0;
    _connecttime = _parray select 1;
    _newwtime = time - _connecttime;
    if (_newwtime >= _oldwtime) then {
        _newwtime = 0;
    } else {
        _newwtime = _oldwtime - _newwtime;
    };
    _parray set [0, _newwtime];
    (_parray select 4) execVM "x_scripts\x_markercheck.sqf"; // remove all player created markers

#ifdef __DEBUG_PRINT__
    hint localize format[ "+++ x_scripts\x_serverOPD.sqf: player ""%1"", array %2", _name, _parray ];
#endif

#ifdef __AI__
    // TODO: try to remove all AI of disconnecting player
    // orphaned AI must be now local to server, not to any player as only single group player can recruit AI from barracks
#endif

    __DEBUG_NET("x_serverOPD player disconnected _parray",_parray)
} else {
    hint localize format[ "+++ x_scripts\x_serverOPD.sqf: unknow player ""%1"", weapons %2, mags %3", _name, weapons player, magazines player ];
#ifdef __ACE__
    if ( player call ACE_Sys_Ruck_HasRucksack ) then
    {
        _str = [call ACE_Sys_Ruck_RuckMagazines,","] call SYG_joinArr;
        hint localize format[ "+++ x_scripts\x_serverOPD.sqf: unknown player rucksack ""%1""", _str ];
    };
#endif
};
if (true) exitWith {};