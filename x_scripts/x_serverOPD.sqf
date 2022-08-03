// Xeno, x_scripts\x_serverOPD.sqf, OnPlayerDisconnected
if (!isServer) exitWith{};
private ["_name", "_index", "_parray", "_oldwtime", "_connecttime", "_newwtime","_str","_arr","_equipment","_wpnArr"];

_name = _this select 0;
if (_name == "__SERVER__") exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

#define __DEBUG_PRINT__


// __DEBUG_NET("x_serverOPD player disconnected",_name)

_index = d_player_array_names find _name;
if (_index >= 0) exitWith {
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
	_player = call (compile (_parray select 4)); // find player object by his role name
#ifdef __EQUIP_OPD_ONLY__
	// Note: server knows nothing  about ACE rucksack and distance and death sound on/off.
	// These parameters are known only on client computers and must be saved by player with command on the flag base
	_arr = _player call SYG_getPlayerEquiptArr; // real equipment array= = [ [weapons names], [magazines names]<, "",[]]
	_equipment = _parray select 5; // read string with equipment array
	_wpnArr = if ( _equipment != "" ) then { _equipment call SYG_unpackEquipmentFromStr } else { [] }; // stored weapon array
	{ _wpnArr set [_x, _arr select _x] } forEach [ 0, 1 ]; // copy only valuable parts
	_str = _wpnArr call SYG_equipArr2Str;
	_parray set [5, _str]; // replace old eequipment list with one found in OPD procedure
	_str = _arr call SYG_getPlayerEquipAsStr; // Get armament formatted array as string
#else
	_str = _player call SYG_equipArr2Str; // Get armament formatted array as string
#endif
#ifdef __DEBUG_PRINT__
    hint localize format[ "+++ x_scripts\x_serverOPD.sqf: player ""%1"", old array  %2", _name, _parray call SYG_compactArray ];
	hint localize format[ "+++ x_scripts\x_serverOPD.sqf: player ""%1"", new wpnarr %2", _name, _str ];
#endif

//	_parray set [ 5, _str]; // set new armament in any case
#ifdef __AI__
    // TODO: try to remove all AI of the disconnected player
    // orphaned AI must be now local to server, not to any player as only single group player can recruit AI from barracks
#endif
    //__DEBUG_NET("x_serverOPD player disconnected _parray",_parray)
    _parray set[4, ""]; // mark player to be logged out (empty role name in player array)
};

hint localize format[ "--- x_scripts\x_serverOPD.sqf: unknown player name detected ""%1""", _name];
if (true) exitWith {};