// by Xeno
private ["_vehicle","_position","_enterer","_was_engineon"];

_vehicle = _this select 0;
_position = _this select 1;
_enterer = _this select 2;

_was_engineon = isEngineOn _vehicle;

_exit_it = false;
if (local _enterer) then {
	if (playerSide == west) then {
		if (_vehicle in [MEDVECR,TRR1,TRR2,TRR3,TRR5]) then {
			_exit_it = true;
			["This is a RACS vehicle.\nYou are not allowed to enter it !!!", "SIDE"] call XHintChatMsg;
		};
	} else {
		if (_vehicle in [MEDVEC,TR1,TR2,TR3,TR5]) then {
			_exit_it = true;
			["This is a US vehicle. You are not allowed to enter it !!!", "SIDE"] call XHintChatMsg;
		};
	};
};
if (_exit_it) exitWith {
	_enterer action["Eject",_vehicle];
	if (!_was_engineon && isEngineOn _vehicle) then {_vehicle engineOn false};
};

if (true) exitWith {};
