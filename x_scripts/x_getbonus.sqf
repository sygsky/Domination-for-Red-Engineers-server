// x_scripts/x_getbonus.sqf : by Xeno
// creates bonus vehicle for side missions and place it to the ground
private ["_dir","_pos","_posa","_vehicle"];

if (!isServer) exitWith {};

#include "x_setup.sqf"

bonus_number = floor (random (count sm_bonus_vehicle_array));
sleep 1.012;

_dir = 0;
_pos = [];
#ifndef __TT__
_posa = sm_bonus_positions select bonus_number; _pos = _posa select 0;_dir = _posa select 1;
#endif
#ifdef __TT__
if (side_mission_winner == 2) then {
	_west = sm_bonus_positions select 0;
	_posa = _west select bonus_number; _pos = _posa select 0;_dir = _posa select 1;
} else {
	if (side_mission_winner == 1) then {
		_racs = sm_bonus_positions select 1;
		_posa = _racs select bonus_number; _pos = _posa select 0;_dir = _posa select 1;
	} else {
		if (side_mission_winner == 123) then {
			_west = sm_bonus_positions select 0;
			_posa = _west select bonus_number; _pos = _posa select 0;_dir = _posa select 1;
			_vehicle2 = (sm_bonus_vehicle_array select bonus_number) createVehicle (_pos);
			_vehicle2 setDir _dir;
			_vehicle2 execVM "x_scripts\x_wreckmarker.sqf";
			_racs = sm_bonus_positions select 1;
			_posa = _racs select bonus_number; _pos = _posa select 0;_dir = _posa select 1;
		};
	};
};
#endif
_vehicle = (sm_bonus_vehicle_array select bonus_number) createVehicle (_pos);
_vehicle setDir _dir;

_pos = nil;
_posa = nil;

["sm_res_client",side_mission_winner,bonus_number] call XSendNetStartScriptClient;

side_mission_winner = 0;
_vehicle execVM "x_scripts\x_wreckmarker.sqf";

if (true) exitWith {};
