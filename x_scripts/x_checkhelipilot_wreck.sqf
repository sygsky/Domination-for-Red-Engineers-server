// by Xeno, x_scripts\x_checkhelipilot_wreck.sqf
private ["_vehicle","_position","_enterer","_was_engineon"];

#include "x_setup.sqf"
#include "x_macros.sqf"

_vehicle = _this select 0;
_position = _this select 1;
_enterer = _this select 2;

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
			["This is a US chopper.\n You are not allowed to enter it !!!", "SIDE"] call XHintChatMsg;
		};
	};
};
if (_exit_it) exitWith {
	_enterer action["Eject",_vehicle];
	if (!_was_engineon && isEngineOn _vehicle) then {_vehicle engineOn false};
};
#endif

if (local _enterer && _position == "driver") then {

#ifdef __RANKED__

	_index = (toUpper (d_wreck_lift_rank)) call XGetRankIndex;
	_indexp = (rank player) call XGetRankIndex;
	if ( (_index == 0) && (score player < (d_ranked_a select 0))) exitWith // Private can start fly but 10 point needed
	{
        (format [localize "STR_SYS_139_1", score player,(d_ranked_a select 0)]) call XfHQChat; // "To drive this heli you need %2 point(s). You have only %1 ..."
		driver _vehicle action["Eject",_vehicle];
		if (!_was_engineon && isEngineOn _vehicle) then {_vehicle engineOn false};
	};
	if (_indexp < _index) exitWith {
		// "Your rank: %1 does not allow to use this helicopter (Wreck-repair). Required rank: %2."
		(format [localize "STR_SYS_250", rank player, toLower((toUpper (d_wreck_lift_rank)) call XGetRankStringLocalized)]) call XfHQChat;
		driver _vehicle action["Eject",_vehicle];
		if (!_was_engineon && isEngineOn _vehicle) then {_vehicle engineOn false};
	};

#endif

	_may_fly = true;
	if (count d_only_pilots_can_fly > 0) then {
		_type_enterer = typeOf _enterer;
		if (!(_type_enterer in d_only_pilots_can_fly)) then {
			_may_fly = false;
			hint localize "STR_SYS_251"; //"Отсутствует допуск к полётам!"
			driver _vehicle action["Eject",_vehicle];
			if (!_was_engineon && isEngineOn _vehicle) then {_vehicle engineOn false};
		};
	};
	if (_may_fly && _enterer == player) then {
		player_is_driver = true;
		hud_id = -1000;
		if (!(__ACEVer) && !(__MandoVer)) then {
			if (d_chophud_on) then {
				hud_id = _vehicle addAction [localize "STR_HUD_OFF", "x_scripts\x_sethud.sqf",0,-1,false];
			} else {
				hud_id = _vehicle addAction [localize "STR_HUD_ON", "x_scripts\x_sethud.sqf",1,-1,false];
			};
		};
		[_vehicle] execVM "x_scripts\x_helilift_wreck.sqf";
	};
};

if (true) exitWith {};
