/*
	scripts\SYG_lighthouses.sqf,	author: Sygsky
	description: lighthouse night hawler sounds handling
	returns: nothing

	call as: [ _start_time, stop_time ] execVM "scripts\SYG_lighthouses.sqf";
	Note: _start_time and _stop_time are in daytime format (hours).
	E.g. [[_po1, _pos2], 20.5, 4.25] execVM "scripts\SYG_lighthouses.sqf";
*/
hint localize format[ "+++ SYG_lighthouses: X_Client is %1, lighthouse hawler service _this = %2", X_Client, _this ];
if ( !X_Client ) exitWith{};

if ( !isNil "SYG_lighthouse_handled" ) exitWith { hint localize "--- SYG_lighthouses: SYG_lighthouse_handled already defined, exit..." };

SYG_lighthouse_handled = true;

#include "x_setup.sqf"

#ifndef __DEFAULT__
if ( true ) exitWith {}; // only island Sahrani supported
#endif

#define LH_DISTANCE 2000 // search distance
#define LH_HEARING_DISTANCE 1000 // distance to hear lighthouse hawler

// Points to search for lighthouses around them
_majak_data = [
	[19446,13598],[6541,16011],[12743,9929],[10021,11816],[11628,5053],[7285,8903]
];

// Description for each lighthouse sound sequences
_wholer_data = [
	["lighthouse_1",  6, 13], // length 3.4, 3 buzzer + 1 silence
	["lighthouse_2",  8, 15],   // length 4.0 sec. 2 buzz + 2 silence
	["lighthouse_3", 10, 18],   // lemgth 5.44
	["lighthouse_4", 10, 10, 25]  // length 5.5
];

//_diff_pos = [1.06738,-0.278809,-8.07489];
//_diff_dir = -66.116;

//
// [_lighthouse, _start, _end, _ind, _howler_arr] call _howler_work;
//
#define __FUTURE__
_howler_work = {
	private ["_id","_i", "_arr", "_sound","_majak","_start","_end","_last_ind","_pos"];
	_majak = _this select 0;
#ifdef __FUTURE__
	_id = _majak addAction [ localize "STR_LIGHTHOUSE_SIREN", "scripts\sirenSwitch.sqf" ];
	_majak setVariable ["siren", true]; // By default siren in on
#endif
	_pos   = getPos _majak;
	_start = _this select 1;
	_end   = _this select 2;
	_arr   = _this select 4;
	_last_ind = ( count _arr ) - 1;
	_sound =  _arr select 0;
	hint localize format[ "+++ SYG_lighthouses: spawned service #%1 for the majak(%2) #%3, daytime %4, _start %5, _end %6, sound %7", _id, _majak, _this select 3, daytime, _start, _end, _sound ];
	while { if (_start > _end) then { (daytime > _start) || (daytime < _end) }  else { (daytime > _start) &&  (daytime < _end) } } do  {
		// while it is the night do
		for "_i" from 1 to _last_ind do {
			if (!alive _majak) exitWith {
				hint localize format["--- SYG_lighthouses: _howler_work for dead majak #%1 stopped", _this select 3];
				// ["msg_to_user",_player_name | "*" | "",[_msg1, ... _msgN]<,_delay_between_messages<,_initial_delay<,no_title_msg><,sound_name>>>>] call SYG_msgToUserParser
				_majak = _pos call SYG_nearestSettlement;
				["msg_to_user", "", ["STR_LIGHTHOUSE_KILLED", _majak ], 0, 3, false, "return"] call SYG_msgToUserParser;
			};
			if ((player distance _majak) < LH_HEARING_DISTANCE) then { _majak say _sound; };
			sleep (_arr select _i);
		};
		if (!alive _majak) exitWith {};
	};
	hint localize format[ "+++ SYG_lighthouses: Finished service for the majak #%1", _this select 3 ];
};

//
// collect all lighthouses on the map that will buzz
//
_lh_arr = [];
_i = 1;
{
	_arr = nearestObjects [_x, ["Land_majak"], LH_DISTANCE]; // may be 8-9 lighthouses on Sahrani island
	hint localize "+++ Detect Lighthouse buildings...";
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

//
// Run all buzzers
//
_start = _this select 0;
_end   = _this select 1;
while { true } do {
	// sleep to the start of the night *siren ON)
	if ( if (_start > _end) then { (daytime > _end) && (daytime < _start) } else { (daytime < _start) ||  (daytime > _end) } ) then {
		// we are in night, start services for the lighthouses
		_time = (((_start - daytime) + 24 )  % 24) * 3600 + 10;
		hint localize format["+++ SYG_lighthouses: sleep until night start %1 sec", round( _time )];
		sleep _time;
	};

	//time is directly after night evening or somewhere before morning
	for "_i" from 0 to (count _lh_arr) - 1 do {
		_x = _lh_arr select _i;
		if (alive _x ) then {
			[_x, _start, _end, _i, _wholer_data select ( _i mod 4 )] spawn _howler_work;
		};
		sleep 0.1;
	};
	// sleep to the start of the day (siren off)
	// we are in night, start services for the lighthouses
	_time = (((_end - daytime) + 24 )  % 24) * 3600 + 10;
	hint localize format["+++ SYG_lighthouses: sleep until day start %1 sec", round( _time )];
	sleep _time;

};

SYG_lighthouse_handled = nil;
