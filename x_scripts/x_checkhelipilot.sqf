// by Xeno: x_helilift.sqf
private ["_listin", "_no_lift", "_vehicle", "_position", "_enterer", "_exit_it", "_may_fly", "_type_enterer","_was_engineon"];

#include "x_setup.sqf"
#include "x_macros.sqf"

_listin = _this select 0;
_no_lift = _this select 1;
_vehicle = _listin select 0;
_position = _listin select 1;
_enterer = _listin select 2;

_was_engineon = isEngineOn _vehicle;

#ifdef __TT__
_exit_it = false;
if (local _enterer) then {
	if (playerSide == west) then {
		if (_vehicle in [HRR1,HRR2,HRR3,HRR4]) then {
			_exit_it = true;
			["This is a RACS chopper.\nYou are not allowed to enter it !!!", "SIDE"] call XHintChatMsg;
		};
	} else {
		if (_vehicle in [HR1,HR2,HR3,HR4]) then {
			_exit_it = true;
			["This is a US chopper.\nYou are not allowed to enter it !!!", "SIDE"] call XHintChatMsg;
		};
	};
};
if (_exit_it) exitWith {
	_enterer action["Eject",_vehicle];
	if (!_was_engineon && isEngineOn _vehicle) then {_vehicle engineOn false};
};
#endif

if (local _enterer && _position == "driver") then {
	_may_fly = true;
	if (count d_only_pilots_can_fly > 0) then {
		_type_enterer = typeOf _enterer;
		if (!(_type_enterer in d_only_pilots_can_fly)) then {
			_may_fly = false;
			hint localize "STR_SYS_79_3"; // "You're not allowed to fly!"
			driver _vehicle action["Eject",_vehicle];
			if (!_was_engineon && isEngineOn _vehicle) then {_vehicle engineOn false};
		};
	};

	if (_may_fly && _enterer == player) then {
		if (_no_lift == 0) then {
			player_is_driver = true;
			hud_id = -1000;
			if (!(__ACEVer) && !(__MandoVer)) then {
				if (d_chophud_on) then {
					hud_id = _vehicle addAction ["Turn Off Hud", "x_scripts\x_sethud.sqf",0,-1,false];
				} else {
					hud_id = _vehicle addAction ["Turn On Hud", "x_scripts\x_sethud.sqf",1,-1,false];
				};
			};

			[_vehicle] execVM "x_scripts\x_helilift.sqf";
		};
	};
};

if (true) exitWith {};
