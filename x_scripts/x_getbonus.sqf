// x_scripts/x_getbonus.sqf : by Xeno
// creates bonus vehicle for side missions and place it to the ground
private ["_dir","_pos","_posa","_vehicle", "_vec_number"];

if (!isServer) exitWith {};

#include "x_setup.sqf"

//#define __DEBUG__

#ifdef __DEBUG__
hint localize "+++ x_getbonus.sqf called +++";
#define __NO_ETERNAL_BONUS__
side_mission_winner = 1;
#endif

bonus_number = sm_bonus_params call SYG_findTargetBonusIndex;

sleep 1.012;

_dir = 0;
_pos = [];

#ifdef __NO_ETERNAL_BONUS__
    _resurrect = false;
#else
    _resurrect = true;
#endif



#ifndef __TT__
_posa = sm_bonus_positions select (bonus_number % (count sm_bonus_positions));
_pos = _posa select 0;
_dir = _posa select 1;
//	_vec_type = sm_bonus_vehicle_array select (_i % (count sm_bonus_vehicle_array));
#endif

#ifdef __TT__
if (side_mission_winner == 2) then {
	_west = sm_bonus_positions select 0;
	_posa = _west select bonus_number; _pos = _posa select 0;_dir = _posa select 1;
} else {
	if (side_mission_winner == 1) then {
		_racs = sm_bonus_positions select 1;
		_posa = _racs select bonus_number; _pos = _posa select 0; _dir = _posa select 1;
	} else {
		if (side_mission_winner == 123) then {
			_west = sm_bonus_positions select 0;
			_posa = _west select bonus_number; _pos = _posa select 0; _dir = _posa select 1;
			_vehicle2 = (sm_bonus_vehicle_array select bonus_number) createVehicle (_pos);
			_vehicle2 setDir _dir;

			if ( _resurrect) then {
			    _vehicle2 execVM "x_scripts\x_wreckmarker.sqf";
			}
			else
			{
			    [_vehicle2] call SYG_addEventsAndDispose; // ???
			};

			_racs = sm_bonus_positions select 1;
			_posa = _racs select bonus_number; _pos = _posa select 0; _dir = _posa select 1;
		};
	};
};
#endif

_vec_type = sm_bonus_vehicle_array select bonus_number;

_vehicle = (_vec_type) createVehicle (_pos);

_vehicle setDir _dir;
hint localize format["+++ x_scripts/x_getbonus.sqf: type index %1, pos %2, veh %3", bonus_number, _pos, typeOf _vehicle];

_pos = nil;
_posa = nil;

["sm_res_client",side_mission_winner,bonus_number] call XSendNetStartScriptClient;

side_mission_winner = 0;

if ( _resurrect) then {	_vehicle execVM "x_scripts\x_wreckmarker.sqf"; };

if (true) exitWith {};
