/*
	scripts\SYG_lighthouses.sqf,	author: Sygsky
	description: lighthouse night hawler sounds handling
	returns: nothing

	call as: [ _start_time, stop_time ] execVM "scripts\SYG_lighthouses.sqf";
	Note: _start_time and _stop_time are in daytime format (hours).
	E.g. [[_po1, _pos2], 20.5, 4.25] execVM "scripts\SYG_lighthouses.sqf";
*/

#include "x_setup.sqf"

#ifndef __DEFAULT__
if ( true ) exitWith {}; // only island Sahrani supported
#endif

hint localize format[ "+++ SYG_lighthouses: X_Client is %1, lighthouse hawler service _this = %2", X_Client, _this ];
if ( !X_Client ) exitWith{};

if ( !isNil "SYG_lighthouse_handled" ) exitWith { hint localize "--- SYG_lighthouses: SYG_lighthouse_handled already defined, exit..." };

SYG_lighthouse_handled = true;

//#define __PRINT_MAJAKS__

#ifdef __PRINT_MAJAKS__

sleep 60;

#define LH_DISTANCE 2000 // search distance for 2-3 majaks at one circle

#else

#define LH_DISTANCE 15 // search distance at point very near each majak on the Sahrani map

#endif

#define LH_HEARING_DISTANCE 1000 // distance to hear lighthouse hawler

// Points to search for lighthouses around them
#ifdef __PRINT_MAJAKS__
_majak_data = [
	[19446,13598],[6541,16011],[12743,9929],[10021,11816],[11628,5053],[7285,8903] // centers of big cicles (very slow and frozen screen pocedure)
];
#else
_majak_data = [
	[19487,13617],[4964,16070],[12376,10354],[12492,10856],[13207,8999],[10845,12565],[8982,10779],[11759,5952],[10641,4645],[7844,9742],[6725,8054]
];
#endif
// Description for each lighthouse sound sequences
_wholer_data = [
	["lighthouse_1",  6, 13],		// length 18, 2 buzz
	["lighthouse_2",  8, 15],		// length 21, 2 buzz
	["lighthouse_3", 10, 18],		// lemgth 28, 2 buzz
	["lighthouse_4", 10, 10, 25]	// length 45, 3 buzz
];

//_diff_pos = [1.06738,-0.278809,-8.07489];
//_diff_dir = -66.116;

//  offsets:  0,      1,    2,    3,           4
// [_lighthouse, _start, _end, _ind, _howler_arr] call _howler_work;
//
#define __FUTURE__

_howler_work = {
	private ["_id","_i", "_arr", "_sound","_majak","_siren","_start","_end","_last_ind","_pos"];
	_majak = _this select 0;
#ifdef __FUTURE__
	_siren = _majak getVariable "siren";
    if ( isNil "_siren" ) then {
		_id = _majak addAction [ localize "STR_LIGHTHOUSE_SIREN", "scripts\sirenSwitch.sqf" ];
		_siren = true;
		_majak setVariable ["siren", _siren]; // By default siren in on
    };
#endif
	_pos   = getPos _majak;
	_start = _this select 1;
	_end   = _this select 2;
	_arr   = _this select 4;
	_last_ind = ( count _arr ) - 1;
	_sound =  _arr select 0;
	hint localize format[ "+++ SYG_lighthouses: spawned service #%1 for the majak(%2) #%3, daytime %4, _start %5, _end %6, sound %7", _id, _majak, _this select 3, daytime, _start, _end, _sound ];
	_printed = false;
	while { if (_start > _end) then { (daytime > _start) || (daytime < _end) }  else { (daytime > _start) &&  (daytime < _end) } } do  {
		// while it is the night do
		for "_i" from 1 to _last_ind do {
			if (!alive _majak) exitWith {
				hint localize format["--- SYG_lighthouses: service for the dead majak #%1 stopping...", _this select 3];
				// ["msg_to_user",_player_name | "*" | "",[_msg1, ... _msgN]<,_delay_between_messages<,_initial_delay<,no_title_msg><,sound_name>>>>] spawn SYG_msgToUserParser
				_majak = _pos call SYG_nearestSettlement;
				["msg_to_user", "", ["STR_LIGHTHOUSE_KILLED", _majak ], 0, 3, false, "return"] spawn SYG_msgToUserParser;
			};
			if ((player distance _majak) < LH_HEARING_DISTANCE) then {
#ifdef __FUTURE__
				_siren = _majak getVariable "siren";
				if ( !_siren ) exitWith {
					if (!_printed) then {
						hint localize format["+++ SYG_lighthouses.sqf: lighthouse #%1 howler is swithed off", (_this select 3)];
						_printed = true;
					};
				};
				_printed = false;
#endif
				_majak say _sound;
			};
			sleep (_arr select _i);
		};
		if (!alive _majak) exitWith {};
	};
	hint localize format[ "+++ SYG_lighthouses: service for the dead majak #%1 killed", _this select 3 ];
};

//
// collect all lighthouses on the map that will buzz
//
_lh_arr = [];
_i = 1;
{
//	_arr = nearestObjects [_x, ["Land_majak"], LH_DISTANCE]; // may be 11 lighthouses on Sahrani island
	_arr = _x nearObjects ["Land_majak", LH_DISTANCE]; // may be 11 lighthouses on Sahrani island
#ifdef __PRINT_MAJAKS__
	sleep 1;
#else
	sleep 0.1;
#endif
//	hint localize "+++ Detect Lighthouse buildings procedure...";
	{
		if (alive _x) then {
			if (!(_x in _lh_arr) ) then {
				_lh_arr set[ count _lh_arr, _x ];
				hint localize format[ "+++ found #%1: %2", _i, [_x, "at %1 m. to %2 from %3",50] call SYG_MsgOnPosE ];
				_i = _i + 1;
			}
		}
	} forEach _arr;
} forEach _majak_data;

// +++++++++++++++++++++++++++++++++++
// Print new array of majak positions
// -----------------------------------
#ifdef __PRINT_MAJAKS__
hint localize "";
hint localize "_majak_data = [";
{
	_x = getPos _x;
	hint localize format["[%1,%2],    ", round( _x select 0), round (_x select 1)];
} forEach _lh_arr;
hint localize "];";
hint localize "";
#endif

// Points to search for lighthouses around them
_majak_data = [
	[19446,13598],[6541,16011],[12743,9929],[10021,11816],[11628,5053],[7285,8903]
];

//
// Run all buzzers
//
_start = _this select 0;
_end   = _this select 1;
while { true } do {
	// Detect if client is at the night (switch siren ON)
	if ( if (_start > _end) then { (daytime < _end) || (daytime > _start) } else { (daytime < _start) &&  (daytime > _end) } ) then {
		// we are in night, start services for the lighthouses
		_str = call SYG_missionTimeInfoStr;
		hint localize format["+++ %1 SYG_lighthouses: start all alive lighthouse services", _str];
		_cnt = count _wholer_data;
		for "_i" from 0 to (count _lh_arr) - 1 do {
			_x = _lh_arr select _i;
			if (alive _x ) then {
				[_x, _start, _end, _i, _wholer_data select ( _i mod _cnt )] spawn _howler_work;
			};
			sleep 0.05;
		};
	};

	// and sleep to the start of the next night
	_time = (((_start - daytime) + 24 )  % 24) * 3600 + 10;
	hint localize format["+++ SYG_lighthouses: sleep %1 hour[s] until next night start ", round( _time / 360 ) / 10];
	sleep _time;

};

SYG_lighthouse_handled = nil;
