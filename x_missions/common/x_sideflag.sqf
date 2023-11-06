// by Xeno: x_missions\common\x_sideflag.sqf
private ["_flag","_owner","_posi_array","_ran","_ran_pos","_flagtype","_ini_str","_msg","_sound"];
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

_posi_array = _this select 0;

_ran = (floor random ((count _posi_array) - 1)) + 1;
_ran_pos = _posi_array select _ran;

_posi_array = nil;

#ifdef __RANKED__
d_sm_p_pos = nil;
#endif

if (d_enemy_side == "EAST") then {
	_flagtype = "FlagCarrierNorth";
	_ini_str = "this setFlagSide east;";
} else {
	_flagtype = "FlagCarrierWest";
	_ini_str = "this setFlagSide west;";
};

_flag = _flagtype createVehicle _ran_pos;
_flag setVehicleInit _ini_str;
processInitCommands;
sleep 2.123;
["shilka", 1, "bmp", 1, "tank", 1, _ran_pos,1,150,true] spawn XCreateArmor;
sleep 2.123;
["specops", 1, "basic", 2, _ran_pos,130,true] spawn XCreateInf;

_ran_pos = nil;
_ran = nil;
_flagtype = nil;
_ini_str = nil;

sleep 15.111;

_ownedPrev = false; // at start mission flag is on pole and not owned by anybody
while {true} do {
	if (X_MP) then {
	    if (( call XPlayersNumber) == 0) then {
    		waitUntil {sleep (10.012 + random 1);( call XPlayersNumber) > 0 };
	    };
	};
	_owner = flagOwner _flag;
	#ifndef __TT__
	_ownedNow = alive _owner;  // (alive owner) is the same as (flag owned)
	if ((_ownedNow || _ownedPrev) && !(_ownedNow && _ownedPrev)) then {// state changed
//	if (  _ownedNow != _ownedPrev ) then { // logical values can't be compared in this manner (!=, == etc)
	    _ownedPrev = _ownedNow; // save current state to check it changed or not at the next step
	    _msg       = if ( _ownedNow ) then { [ "STR_SYS_FLAG_OWNED", name _owner ] } else { [ "STR_SYS_FLAG_EMPTY" ] };
	    _sound     = if ( _ownedNow ) then { "flag_captured" } else { "flag_lost" };
	    // ["msg_to_user",_player_name | "*" | "",[_msg1, ... _msgN]<,_delay_between_messages<,_initial_delay<,no_title_msg><,sound_name>>>>]
        [ "msg_to_user", "", [ _msg ], 0, 0, false, _sound ] call XSendNetStartScriptClientAll; // inform about flag state change and play corrsponding sound
	};
	if ((_ownedNow) && (_owner distance FLAG_BASE < 20)) exitWith {
		if (__RankedVer) then {
			["d_sm_p_pos", position FLAG_BASE] call XSendNetVarClient;
		};
		_flag setFlagOwner objNull;
		clearVehicleInit _flag;
		deleteVehicle _flag;
		side_mission_winner=2;
		side_mission_resolved = true;
        //+++ added on issue # 562
        [ "say_sound", position FLAG_BASE, "flag_captured" ] call XSendNetStartScriptClient; // play sound of "flag capture" event everywhere
	};
	#else
	{
        if ((alive _owner) && (_owner distance _x < 20)) exitWith {
            if (__RankedVer) then {
                ["d_sm_p_pos", position _x] call XSendNetVarClient;
            };
            _flag setFlagOwner objNull;
            clearVehicleInit _flag;
            deleteVehicle _flag;
            side_mission_winner = 2;
            side_mission_resolved = true;
            //+++ added on issue # 562
            [ "say_sound", position _x, "flag_captured" ] call XSendNetStartScriptClient; // play sound of "flag capture" event everywhere
        };
	} forEach [RFLAG_BASE,WFLAG_BASE];
	#endif
	sleep 5.123;
};

if (true) exitWith {};
