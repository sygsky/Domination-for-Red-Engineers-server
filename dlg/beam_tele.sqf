// Xeno, dlg\beam_tele.sqf
private ["_control","_index","_pos","_global_pos","_typepos","_global_dir","_veh"];
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
    // TODO: if teleport point is in house, prevent teleport ("You can't teleport to non-empty space!!!")
    _global_dir = direction _veh;

    ["addVehicle", (group player), _veh] call XSendNetStartScriptServer; // inform enemy about MHQ position
    sleep 1.0;
};

_global_pos set [2, 0];  // always port to the ground
_pos = getPos player; // start positon
player setPos _global_pos;
player setDir _global_dir;
["say_sound", _pos, "teleport_from"] call XSendNetStartScriptClientAll; // play sound of teleport out event everywhere
sleep 0.2;
["say_sound", player, "teleport_to"] call XSendNetStartScriptClientAll; // play sound of teleport in event everywhere
sleep 1.8;
// TODO: try to set vehicle locally on each client computer
_veh call SYG_revealToAllPlayers;

closeDialog 100001;

titletext ["", "BLACK IN"];

#ifdef __AI__
if (alive player) then {[] execVM "x_scripts\x_moveai.sqf"};
#endif

if (true) exitWith {};