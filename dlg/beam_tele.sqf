private ["_control","_index","_p","_pp","_global_pos","_typepos","_global_dir"];
if (!X_Client) exitWith {};

#include "x_setup.sqf"

if (beam_target < 0) exitWith{};

if (x_loop_end) exitWith {};

x_loop_end = true;

if (vehicle player != player) then {
	unassignVehicle player;
};

d_last_telepoint = beam_target;
_global_pos = [];
_global_dir = 180;
_typepos = 0;
_resp = objNull;
switch (beam_target) do {
	case 0: { // teleport to the base
#ifndef __REVIVE__
		call compile format ["_global_pos = markerpos ""respawn_%1"";", d_side_player_str];
#endif
#ifdef __REVIVE__
		_global_pos = markerPos "base_spawn_1";
#endif
	};
	case 1: { // teleport to the MHQ1
#ifndef __TT__
		_global_pos = MRR1 modelToWorld [0,-5,0];
		_global_dir = direction MRR1;
#endif
#ifdef __TT__
		_global_pos = (
			if (playerSide == west) then {
				MRR1 modelToWorld [0,-5,0]
			} else {
				MRRR1 modelToWorld [0,-5,0]
			}
		);
		_global_dir = (
			if (playerSide == west) then {
				direction MRR1
			} else {
				direction MRRR1
			}
		);
#endif
		_typepos = 1;
		_resp = MRR1;
	};
	case 2: { // teleport to the MHQ2
#ifndef __TT__
		_global_pos = MRR2 modelToWorld [0,-5,0];
		_global_dir = direction MRR2;
#endif
#ifdef __TT__
		_global_pos = (
			if (playerSide == west) then {
				MRR2 modelToWorld [0,-5,0]
			} else {
				MRRR2 modelToWorld [0,-5,0]
			}
		);
		_global_dir = (
			if (playerSide == west) then {
				direction MRR2
			} else {
				direction MRRR2
			}
		);
#endif
		_typepos = 1;
		_resp = MRR2;
	};
};
beam_target = -1;
if (_typepos == 1) then {  //  teleport to some of our MHQ

    _global_pos set [2,0];
    if ( (_global_pos select 2) > 1) then // MHQ is hanging in air (strange but possible e.g. user disconnect during lifting)
    {
        _resp setPos _global_pos;
    };
};
player setPos _global_pos;
player setDir _global_dir;
sleep 2;
closeDialog 100001;

titletext ["", "BLACK IN"];

#ifdef __AI__
if (alive player) then {[] execVM "x_scripts\x_moveai.sqf"};
#endif

if (true) exitWith {};