// by Xeno: x_scripts/x_autokick.sqf
//+++ Sygsky: this script for not Ranked version only
if (!XClient) exitWith {};
private ["_nomercyendtime", "_vec", "_type", "_type_name", "_wtime", "_minutes","_was_engineon"];
waitUntil {!isNil "player_autokick_time"};
if (player_autokick_time <= 0) exitWith {player_autokick_time = nil};
_nomercyendtime = time + player_autokick_time;
while {true} do {
	scopeName "xx_nomercy_scope";
	while {vehicle player == player} do {
		sleep 0.45;
		if (time > _nomercyendtime) then {breakOut "xx_nomercy_scope"};
	};
	if (vehicle player != player) then {
		_vec = vehicle player;
		_was_engineon = isEngineOn _vec;
		if (_vec isKindOf "Air") then {
			_type = typeOf _vec;
			if (_type in mt_bonus_vehicle_array || _type in sm_bonus_vehicle_array) then {
				if (player == driver _vec || player == gunner _vec || player == commander _vec) then {
					player action ["Eject",_vec];
					if (!_was_engineon && isEngineOn _vec) then {_vec engineOn false};
					_type_name = [_type,0] call XfGetDisplayName;
					_wtime = _nomercyendtime - time;
					_minutes = round (_wtime / 60);
					if (_minutes < 1) then {_minutes = 1};
					[format ["Вы не прошли аттестацию на использование авиатехники.\n\nБудет доступно через %2 минут(ы). Ожидайте...", _type_name, _minutes], "HQ"] call XHintChatMsg;
					waitUntil {vehicle player == player};
				} else {
					while {vehicle player != player} do {
						sleep 0.72;
						if (time > _nomercyendtime) then {breakOut "xx_nomercy_scope"};
					};
				};
			} else {
				while {vehicle player != player} do {
					sleep 0.72;
					if (time > _nomercyendtime) then {breakOut "xx_nomercy_scope"};
				};
			};
		} else {
			while {vehicle player != player} do {
				sleep 0.72;
				if (time > _nomercyendtime) then {breakOut "xx_nomercy_scope"};
			};
		};
	};
	if (time > _nomercyendtime) exitWith {};
};
["Поздравляем, вы получили возможность управлять авиатехникой!!!", "HQ"] call XHintChatMsg;
player_autokick_time = nil;

if (true) exitWith {};
