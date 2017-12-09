// Xeno, dlg/beam_tele.sqf
private ["_control","_index","_p","_pp","_global_pos","_typepos","_global_dir","_veh"];
if (!X_Client) exitWith {};

#include "x_setup.sqf"

if (beam_target < 0) exitWith{};

if (x_loop_end) exitWith {};

x_loop_end = true;

// TODO: after wait for 10 seconds start some random track to stop it with fade as if only user select teleporter
// TODO: fade music if playing

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
		call compile format ["_global_pos = markerpos ""respawn_%1"";", d_side_player_str];
#endif
#ifdef __REVIVE__
		_global_pos = markerPos "base_spawn_1";
#endif
	};
	case 1: { // teleport to the MHQ1
#ifndef __TT__
        _veh = MRR1;
		_global_pos = _veh modelToWorld [0,-5,0];
		_global_dir = direction _veh;
#endif
#ifdef __TT__
        if (playerSide == west) then {
        _veh = MRR1;
        } else {
        _veh = MRRR1;
        };
		_global_pos = _veh modelToWorld [0,-5,0];
		_global_dir = direction _veh;
#endif
		_typepos = 1;
	};
	case 2: { // teleport to the MHQ2
#ifndef __TT__
        _veh = MRR2;
		_global_pos = _veh modelToWorld [0,-5,0];
		_global_dir = direction _veh;
#endif
#ifdef __TT__
        if (playerSide == west) then {
            _veh = MRR2;
        } else {
            _veh = MRRR2;
        };
		_global_pos = _veh modelToWorld [0,-5,0];
		_global_dir = direction _veh;
#endif
		_typepos = 1;
	};
};
beam_target = -1;
if (_typepos == 1) then {  //  teleport to some of our MHQ

/* Don't work, have to investigate why so?
    if ( (_global_pos select 2) > 1) then // MHQ is hanging in air (strange but possible e.g. user disconnect during lifting)
    {
        _global_pos set [2,0];
        _veh setPos _global_pos;
    };
*/
    // TODO: send command to the server
    (group player) addVehicle _veh;
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