// by Xeno: x_checktrucktrans.sqf
private ["_vehicle",/* "_position", */"_enterer","_was_engineon"];

#include "x_setup.sqf"

_vehicle = _this select 0;
//_position = _this select 1;
_enterer = _this select 2;

_was_engineon = isEngineOn _vehicle;

#ifdef __TT__
_exit_it = false;
if (local _enterer) then {
	if (playerSide == west) then {
		if (_vehicle in [TRR4]) then {
			_exit_it = true;
			["This is a RACS truck.\nYou are not allowed to enter it !!!", "SIDE"] call XHintChatMsg;
		};
	} else {
		if (_vehicle in [TR4]) then {
			_exit_it = true;
			["This is a US truck.\nYou are not allowed to enter it !!!", "SIDE"] call XHintChatMsg;
		};
	};
};
if (_exit_it) exitWith {
	_enterer action["Eject",_vehicle];
	if (!_was_engineon && isEngineOn _vehicle) then {_vehicle engineOn false};
};
#endif

//#ifndef __AI__
if (!(str(_enterer) in d_is_engineer) && local _enterer) then {
	(localize "STR_SYG_01") call XfHQChat; // "Only engineers can enter the Salvage trucks..." 
	_enterer action ["eject",_vehicle];
	if (!_was_engineon && isEngineOn _vehicle) then {_vehicle engineOn false};
};
//#endif

if (true) exitWith {};
