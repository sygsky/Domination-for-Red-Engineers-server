// Xeno, x_scripts\x_serverOPD.sqf, OnPlayerDisconnected
if (!isServer) exitWith{};
private ["_name", "_index", "_parray", "_oldwtime", "_connecttime", "_newwtime","_str","_arr","_equipStr","_wpnArr","_player","_cnt"];

#define __DEBUG_PRINT__
#ifdef __DEBUG_PRINT__
hint localize format[ "+++ x_scripts\x_serverOPD.sqf: _this = %1", _this ];
#endif

_name = _this select 0;
if (_name == "__SERVER__") exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"


_index = d_player_array_names find _name;
if (_index >= 0) exitWith {
    _parray = d_player_array_misc select _index; // [d_player_air_autokick, time, "EngineerACE", _score,"delta_1",_equipment_list_str]

#ifdef __RANKED__
    _parray set [1, time]; // set player disconnect time for ranked mission
#else
    //*** calculate time to autokick if player is re-entered soon
    _oldwtime = _parray select 0;
    _connecttime = _parray select 1;
    _newwtime = time - _connecttime;
    if (_newwtime >= _oldwtime) then {
        _newwtime = 0;
    } else {
        _newwtime = _oldwtime - _newwtime;
    };
    _parray set [0, _newwtime];
#endif

    (_parray select 4) execVM "x_scripts\x_markercheck.sqf"; // remove all player created markers
	_player = call (compile (_parray select 4)); // find player object by his role name
	_arr = _player call SYG_getPlayerEquiptArr; // _arr = [ [weapons names], [magazines names]<, rucksack_name<, [mags_in_rucksack_names]<, d_viewdistance<, d_rebornmusic_index<,base_vist_status>>>>> ]
#ifdef __EQUIP_OPD_ONLY__
	// Note: server knows nothing about ACE rucksack and distance and death sound on/off.
	// These parameters are known only on client computers and must be send to server with "d_ad_wp" command
	_equipStr = _parray select 5; // read string with equipment array
	_wpnArr = if ( _equipStr != "" ) then { _equipStr call SYG_unpackEquipmentFromStr } else { [] }; // stored full equipments array
#ifdef __DEBUG_PRINT__
	// print old weapon array
    hint localize format[ "+++ x_serverOPD.sqf: player ""%1"", score %2, old wpnarr(cnt %3) %4", _name, _parray select 3, count _wpnArr, _wpnArr call SYG_compactArray ];
#endif

	{ _wpnArr set [_x, _arr select _x] } forEach [ 0, 1 ]; // copy only weapon/magazines
	_str = _wpnArr call SYG_arr2Str;
	_parray set [5, _str]; // replace old equipment list with one got from player in OPD procedure
#endif
#ifdef __DEBUG_PRINT__
	// print new weapon array
	hint localize format[ "+++ x_serverOPD.sqf: player ""%1"", score %2, new wpnarr(cnt %3) = %4", _name, _parray select 3, count _wpnArr, _wpnArr call SYG_compactArray ];
	hint localize format[ "+++ x_serverOPD.sqf: player ""%1"", score %2,           _parray = %3", _name, _parray select 3, _parray ];
#endif

#ifdef __AI__
    // TODO: try to remove all AI of the disconnected player
    // orphaned AI must be now local to server, not to any player as only single group player can recruit AI from barracks
    _arr = (units _player) - [_player];
	_cnt = count _arr;
	if ( _cnt > 0 ) then {
	    for "_i" from 0 to count _arr -1 do {
	        _unit = _arr select _i;
	        _arr set [_i,
                if (isPlayer _unit) then {
                    format["player name %1 (%2)", name _unit,typeOf _unit]
                } else {
                    format["not player (%1)",typeOf _unit]
                }
            ];
	    };
//		_arr = 	_arr call SYG_vehToType;
		hint localize format["+++ x_serverOPD.sqf: %1 units count %2 %3", _name, _cnt, _arr];// ;
	};
#endif
    //__DEBUG_NET("x_serverOPD player disconnected _parray",_parray)
    _parray set[4, ""]; // mark player to be logged out (empty role name in player array)
};

hint localize format[ "--- x_serverOPD.sqf: unknown player name detected ""%1""", _name];
if (true) exitWith {};