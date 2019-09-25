// by Xeno
private ["_flag","_owner","_posi_array","_ran","_ran_pos","_flagtype","_ini_str"];
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

_flagtype = "FlagCarrierWest";
_ini_str = "this setflagside west;";
if (d_enemy_side == "EAST") then {
	_flagtype = "FlagCarrierNorth";
	_ini_str = "this setFlagSide east;";
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

_owned = false;
while {true} do {
	if (X_MP) then {
		waitUntil {sleep (1.012 + random 1);( call XPlayersNumber) > 0 };
	};
	_owner = flagOwner _flag;
	#ifndef __TT__
	_alive = alive _owner;  // (alive owner) is the same as (flag owned)
	if ( ( _alive || _owned ) && !( _alive && _owned ) ) // state changed and if alive, flag is owned
	{
	    _owned = _alive;
	    _msg = if ( _owned ) then { [ "STR_SYS_FLAG_OWNED", name _owner ] } else { [ "STR_SYS_FLAG_EMPTY" ] };
        [ "msg_to_user", "", [ _msg ] ] call XSendNetStartScriptClientAll; // inform about flag state change
	};
	if ((_alive) && (_owner distance FLAG_BASE < 20)) exitWith {
		if (__RankedVer) then {
			["d_sm_p_pos", position FLAG_BASE] call XSendNetVarClient;
		};
		_flag setFlagOwner objNull;
		clearVehicleInit _flag;
		deleteVehicle _flag;
		side_mission_winner=2;
		side_mission_resolved = true;
	};
	#else
	if ((alive _owner) && (_owner distance RFLAG_BASE < 20)) exitWith {
		if (__RankedVer) then {
			["d_sm_p_pos", position RFLAG_BASE] call XSendNetVarClient;
		};
		_flag setFlagOwner objNull;
		clearVehicleInit _flag;
		deleteVehicle _flag;
		side_mission_winner = 1;
		side_mission_resolved = true;
	};
	if ((alive _owner) && (_owner distance WFLAG_BASE < 20)) exitWith {
		if (__RankedVer) then {
			["d_sm_p_pos", position WFLAG_BASE] call XSendNetVarClient;
		};
		_flag setFlagOwner objNull;
		clearVehicleInit _flag;
		deleteVehicle _flag;
		side_mission_winner = 2;
		side_mission_resolved = true;
	};
	#endif
	sleep 5.123;
};

if (true) exitWith {};
