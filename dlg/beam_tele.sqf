// Xeno, dlg\beam_tele.sqf
private ["_control","_index","_pos","_global_pos","_typepos","_global_dir","_veh","_sound"];
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

#ifdef __NO_TELEPORT_NEAR_LARGE_METALL_MASS__
// check if big metal mass is near teleporter
_exit = false;
if ( ( _typepos == 1 )  ) then {
	_arr = nearestObjects [ _veh, [ "Tank","StrykerBase","BRDM2","Bus_city","Truck5tMG","Truck","D30","M119" ], __NO_TELEPORT_NEAR_LARGE_METALL_MASS__ ];
	#ifdef __OWN_SIDE_EAST__
		_mhq = "BMP2_MHQ";
	#endif
	#ifndef __OWN_SIDE_EAST__
			_mhq = "M113_MHQ";
	#endif
	_count = 0;
	{
	#ifdef __ACE__
		if (_x isKindOf "ACE_BMP3") then {_count = _count + 1};
		if (_x isKindOf "ACE_BMD1") then {_count = _count + 1};
	#endif
		if (_x isKindOf _mhq) then {_count = _count + 1};
	} forEach _arr;
	_count = (count _arr) - _count;
	hint localize format["+++ beam_tele: _veh = %1, armors in dist 10 m = %2, _cnt = %3", _veh, _arr, _count];
	if (  _count > 0 ) then {
		( localize "STR_SYS_75_4" )  call XfGlobalChat; // "Teleportation is impossible as long as there is a large mass of metal nearby!!!"
		_sound = call SYG_powerDownSound;
		[ "say_sound", _veh, _sound ] call XSendNetStartScriptClientAll; // play sound of invalid teleport
		_exit = true;
	};
};
if (_exit) exitWith {};
#endif

// TODO: if teleport point is in house, prevent teleport ("You can't teleport to non-empty space!!!")
d_last_telepoint = beam_target;
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