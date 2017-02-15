// by Xeno
private ["_vehicle","_position","_enterer","_was_engineon"];

#include "x_setup.sqf"

_vehicle = _this select 0;
_position = _this select 1;
_enterer = _this select 2;

_was_engineon = isEngineOn _vehicle;

#ifdef __TT__
_exit_it = false;
if (local _enterer) then {
	if (playerSide == west) then {
		if (_vehicle in [MRRR1,MRRR2]) then {
			_exit_it = true;
			["This is a RACS mobile respawn vehicle.\nYou are not allowed to enter it !!!", "SIDE"] call XHintChatMsg;
		};
	} else {
		if (_vehicle in [MRR1,MRR2]) then {
			_exit_it = true;
			["This is a US mobile respawn vehicle.\nYou are not allowed to enter it !!!", "SIDE"] call XHintChatMsg;
		};
	};
};
if (_exit_it) exitWith {
	_enterer action["Eject",_vehicle];
	if (!_was_engineon && isEngineOn _vehicle) then {_vehicle engineOn false};
};
#endif

#ifdef __MANDO__
if (_position == "driver") then {
	if (_enterer == player) then {
		// vec2_id = _vehicle addAction ["Drop Ammocrate", "x_scripts\x_dropammobox2.sqf",[],-1,false];
		// vec3_id = _vehicle addAction ["Load Ammocrate", "x_scripts\x_loaddropped.sqf",[],-1,false];
		vec_mando_id = _vehicle addaction ["Air Support", "mando_bombs\mando_airsupportdlg.sqf",[],-1,false];
	};
};
#endif

if (true) exitWith {};
