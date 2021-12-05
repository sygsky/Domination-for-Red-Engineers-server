// Xeno, dlg\beam_tele.sqf
private ["_control","_index","_pos","_global_pos","_typepos","_global_dir","_veh","_sound_to","_diff","_dist","_dmg","_str"];
if (!X_Client) exitWith {};

#include "x_setup.sqf"

if (beam_target < 0) exitWith{};

if (x_loop_end) exitWith {};

x_loop_end = true;

if (vehicle player != player) then {
	unassignVehicle player;
};

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

// TODO: if teleport point is in house, prevent teleport ("You can't teleport to non-empty space!!!")
d_last_telepoint = beam_target;
beam_target = -1;

_sound_to = "teleport_to";
if ( _typepos == 1 ) then {  //  teleport to some of our MHQ
    _global_pos = _veh modelToWorld [0,-5,0];
#ifdef __NO_TELEPORT_NEAR_LARGE_IRON_MASS__
    // if teleport is near iron mass add dome deviation to the position
    _diff = [_veh, __NO_TELEPORT_NEAR_LARGE_IRON_MASS__] call SYG_findTeleportError;
    _dmg = (damage _veh) * __NO_TELEPORT_NEAR_LARGE_IRON_MASS__ / 2;
    _dist = _diff + _dmg;
    if ( _dist > 0 ) then {
	   	// if there is an error on teleport, calculate shifted position now
     	_global_pos = [_global_pos, _dist] call SYG_deviateTeleportPoint;
     	_dist = _global_pos distance _veh;
		hint localize format["+++ teleport deviated to %1 m", (round(_dist*10))/10];
		_str = if ( _dist < 2 ) then {"STR_SYS_75_5_2"} else {
			if ( _dist < 5 ) then {"STR_SYS_75_5_5"} else {
				if ( _dist < 10 ) then {"STR_SYS_75_5_10"} else {"STR_SYS_75_5_MORE"};
			};
		};
	    format [localize "STR_SYS_75_5", localize _str ]  call XfHQChat; // "A large mass of iron next to the MHQ %1 shifted the point of teleport!"
     	_sound_to = call SYG_powerDownSound; // play specific sound for this case
     };
#endif
    // TODO: if teleport point is in house, prevent teleport ("You can't teleport to non-empty space!!!")
    _global_dir = direction _veh;
    ["addVehicle", (group player), _veh] call XSendNetStartScriptServer; // try to inform enemy about MHQ position
    sleep 1.0; // (round(_err*10))/10, (round((_global_pos distance _new_pos)*10))/10
};

_global_pos set [2, 0];  // always port to the ground
_pos = getPos player; // start positon
player setPos _global_pos;
player setDir _global_dir;
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