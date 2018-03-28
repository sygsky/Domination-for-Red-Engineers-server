// Xeno, dlg/beam_tele.sqf
private ["_control","_index","_p","_pp","_global_pos","_typepos","_global_dir","_veh"];
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
_veh = objNull;

switch (beam_target) do {
	case 0: { // teleport to the base
#ifndef __REVIVE__
        //hint localize format["+++ d_side_player_str=%1, markerpos ""respawn_east""=%2",d_side_player_str, markerpos "respawn_east"];
		call compile format ["_global_pos = markerpos ""respawn_%1"";", d_side_player_str];
#endif
#ifdef __REVIVE__
		_global_pos = markerPos "base_spawn_1";
#endif
	};
	case 1: { // teleport to the MHQ1
#ifndef __TT__
        _veh = MRR1;
#endif
#ifdef __TT__
        if (playerSide == west) then {
        _veh = MRR1;
        } else {
        _veh = MRRR1;
        };
#endif
		_typepos = 1;
	};
	case 2: { // teleport to the MHQ2
#ifndef __TT__
        _veh = MRR2;
#endif
#ifdef __TT__
        if (playerSide == west) then {
            _veh = MRR2;
        } else {
            _veh = MRRR2;
        };
#endif
		_typepos = 1;
	};
};

beam_target = -1;

if (_typepos == 1) then {  //  teleport to some of our MHQ

    _global_pos = _veh modelToWorld [0,-5,0];
    if ( [_global_pos, d_base_array] call SYG_pointInRect ) then // remove in any case if on base
    {
        player groupChat "tropelet";
        playSound "tropelet"; // some mistical sound to in base rect
    }
    else
    {
        player groupChat "teleport";
        playSound "teleport"; // some mistical sound to out of base
    };
    _global_dir = direction _veh;

    // TODO: send command to the server, not do it here
    (group player) addVehicle _veh;
};

_global_pos set [2, 0];  // always port to the ground
player setPos _global_pos;
player setDir _global_dir;
sleep 2;
closeDialog 100001;

titletext ["", "BLACK IN"];

#ifdef __AI__
if (alive player) then {[] execVM "x_scripts\x_moveai.sqf"};
#endif

if (true) exitWith {};