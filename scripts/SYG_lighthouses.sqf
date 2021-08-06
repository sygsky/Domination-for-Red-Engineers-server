/*
	scripts\SYG_lighthouses.sqf,	author: Sygsky
	description: lighthouse night hawler sounds handling
	returns: nothing

	call as: [ _start_time, stop_time ] execVM "scripts\SYG_lighthouses.sqf";
	Note: _start_time and _stop_time are in daytime format (hours).
	E.g. [[_po1, _pos2], 20.5, 4.25] execVM "scripts\SYG_lighthouses.sqf";
*/
if (!X_Client) exitWith{};

if ( !isNil "SYG_lighthouse_handled" ) exitWith {hint localize "--- SYG_lighthouses: SYG_lighthouse_handled already defined, exit..."};
hint localize format["+++ SYG_lighthouses: lighthouse hawler service _this = %1", _this];

SYG_lighthouse_handled = true;

#include "x_setup.sqf"

#ifndef __DEFAULT__
if ( true ) exitWith {}; // only island Sahrani supported
#endif

#define LH_DISTANCE 2000 // search distance
#define LH_HEARING_DISTANCE 1000 // distance to hear lighthouse hawler

_majak_data = [
	[19446,13598],[6541,16011],[12743,9929],[10021,11816],[11628,5053],[7285,8903]
];
_wholer_data = [
	["lighthouse_1",  6, 13], // length 3.4, 3 buzzer + 1 silence
	["lighthouse_2",  8, 15],   // length 4.0 sec. 2 buzz + 2 silence
	["lighthouse_3", 10, 18],   // lemgth 5.44
	["lighthouse_4", 10, 10, 25]  // length 5.5
];

//
// [_lighthouse, _start, _end, _ind, _howler_arr] call _howler_work;
//
_howler_work = {
	private ["_i", "_arr", "_sound","_majak","_start","_end"];
	_majak = _this select 0;
	_start = _this select 1;
	_end   = _this select 2;
	_arr   = _this select 4;
	_sound =  _arr select 0;
	hint localize format[ "+++ Spawned service for the majak(%1) #%2, daytime %3, _start %4, _end %5, sound %6", _majak, _this select 3, daytime, _start, _end, _sound ];
	while { if (_start > _end) then { (daytime > _start) || (daytime < _end) }  else { (daytime > _start) &&  (daytime < _end) } } do  {
		if (!alive _majak) exitWith {hint localize format["--- _howler_work: majak #%1 destroyed, exit", _this select 3] };
		for "_i" from 1 to ( count _arr ) - 1 do {
			if ((player distance _majak) < LH_HEARING_DISTANCE) then { _majak say _sound; };
			sleep (_arr select _i);
		};
	};
	hint localize format[ "+++ Finished service for the majak #%1", _this select 3 ];
};

//
// collect all lighthouses on the map that will buzz
//
_lh_arr = [];
_i = 1;
{
	_arr = nearestObjects [_x, ["Land_majak"], LH_DISTANCE]; // may be 8-9 lighthouses on Sahrani island
	{
		if (alive _x) then {
			if (!(_x in _lh_arr) ) then {
				_lh_arr set[ count _lh_arr, _x ];
				hint localize format[ "+++ Lighthouse #%1: %2", _i, [_x, "at %1 m. to %2 from %3",50] call SYG_MsgOnPosE ];
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
	if ( if (_start > _end) then { (daytime > _end) && (daytime < _start) }  else { (daytime > _end) ||  (daytime < _start) } ) then {
		_time = (_start - daytime) * 3600;
		hint localize format["+++ SYG_lighthouses: sleep until night start %1 sec", random( time * 3600)];
		sleep _time;
	};

	//time is after night evening or before morning
	for "_i" from 0 to (count _lh_arr) - 1 do {
		_x = _lh_arr select _i;
		if (alive _x ) then {
			[_x, _start, _end, _i, _wholer_data select ( _i mod 4 )] spawn _howler_work;
		};
		sleep 0.1;
	};
	_time = (_start - daytime +24) * 3600;
	hint localize format["+++ SYG_lighthouses.sqf: sleep %1", round (_time)];
	sleep _time;
};

SYG_lighthouse_handled = nil;
