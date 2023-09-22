// Xeno, dlg\beam_tele.sqf
private ["_control","_index","_pos","_global_pos","_tele_pos","_typepos","_global_dir","_veh","_sound_to","_diff","_dist","_dmg","_str"];
if (!X_Client) exitWith {};

#include "x_setup.sqf"

// Uncomment to eneble teleport with turning accodring to the MHQ, else direction not changes after teleport
//#define __TELEPORT_WITH_TURNING__

if (beam_target < 0) exitWith{};

if (x_loop_end) exitWith {};

x_loop_end = true;

if (vehicle player != player) then {
	unassignVehicle player;
};


_global_pos = [];

#ifdef __TELEPORT_WITH_TURNING__
_global_dir = 180;
#endif
_typepos = 0;
_veh = objNull;

switch (beam_target) do {
	case 0: { // teleport to the base
#ifndef __REVIVE__
        //hint localize format["+++ d_side_player_str=%1, markerpos ""respawn_east""=%2",d_side_player_str, markerpos "respawn_east"];
//		call compile format ["_global_pos = markerpos ""respawn_%1"";", d_side_player_str];
		_global_pos = markerPos format["respawn_%1", d_side_player_str];
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

// TODO: if teleport point is in house, prevent teleport ("You can't teleport to non-empty space!!!")
d_last_telepoint = beam_target;
beam_target = -1;

_sound_to = "teleport_to";
if ( _typepos == 1 ) then {  //  teleport to some of our MHQ
#ifdef __TELEPORT_DEVIATION__
    _tele_pos = _veh modelToWorld [0,-5,0]; // initial (not deviated) teleport position
    // if teleport is near iron mass add some deviation to the position
    _diff = [_veh, __TELEPORT_DEVIATION__] call SYG_findTeleportError; // deviation in meters due to magnetic mass in vicinity
    _dmg = (damage _veh) * __TELEPORT_DEVIATION__ / 2; // deviation due to veh damage is halv of mass one
    _dist = _diff + _dmg;
    if ( _dist > 0.2 ) then {
	   	// if there is an error on teleport, calculate shifted position now
     	_global_pos = [_tele_pos, _dist] call SYG_deviateTeleportPoint; // real teleport position with error counted
     	_dist = [_global_pos, _tele_pos] call SYG_distance2D;
		hint localize format["+++ teleport deviated to %1 m, shift %2", (round(_dist*10))/10, [ _global_pos, _tele_pos ] call  SYG_vectorSub];
		_str = if ( _dist < 2 ) then {"STR_SYS_75_5_2"} else { // slightly
			if ( _dist < 5 ) then {"STR_SYS_75_5_5"} else { // a little
				if ( _dist < 10 ) then {"STR_SYS_75_5_10"} else {"STR_SYS_75_5_MORE"}; // significantly/has very much
			};
		};
	    format [localize "STR_SYS_75_5", localize _str ]  call XfHQChat; // "Dest. point is %1 off due to iron mass and/or MHQ damage!"
     	_sound_to = call SYG_powerDownSound; // play specific sound for this case
     } else { _global_pos = _tele_pos };
#else
    _global_pos = _veh modelToWorld [0,-5,0]; // real teleport position (no deviation allowed at this mission)
#endif
    // TODO: if teleport point is in house, prevent teleport ("You can't teleport to non-empty space!!!")
#ifdef __TELEPORT_WITH_TURNING__
    _global_dir = direction _veh;
#endif
    ["addVehicle", (group player), _veh] call XSendNetStartScriptServer; // try to inform enemy about MHQ position
    sleep 1.0; // (round(_err*10))/10, (round((_global_pos distance _new_pos)*10))/10
};

// _global_pos set [2, 0];  // always port to the ground, but this point already is zero at Z value
_pos = getPos player; // start positon
_global_pos resize 2;
player setPos _global_pos;
#ifdef __TELEPORT_WITH_TURNING__
player setDir _global_dir;
#endif
["say_sound", _pos, "teleport_from"] call XSendNetStartScriptClientAll; // play sound of teleport out event everywhere
sleep 0.2;
["say_sound", player, _sound_to] call XSendNetStartScriptClientAll; // play sound of teleport in event everywhere
sleep 1.8;
// TODO: try to set vehicle locally on each client computer
closeDialog 100001;

titletext ["", "BLACK IN"];

#ifdef __AI__
if (alive player) then {[] execVM "x_scripts\x_moveai.sqf"};
#endif

if (true) exitWith {};