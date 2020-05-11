// by Xeno,x_scripts\x_tanksmoke.sqf, not used if __ACE__ defined
private ["_possible_vecs","_get_vec"];
// base classes
_possible_vecs = ["StrykerBase","Tank"];

d_throw_smoke_vec = objNull;

_get_vec = compile "
	_result = false;if (vehicle player != player) then {_type = typeOf vehicle player;{if (_type isKindOf _x) exitWith {_result = true}} forEach _possible_vecs;};_result
";

while {true} do {
	_actID = -1000;
	waitUntil {sleep random 0.3;call _get_vec};
	_vec = vehicle player;
	_type = typeOf _vec;
	_count = count (configFile>>"CfgVehicles" >> _type >> "Turrets");
	_hasCommander = (getNumber (configFile >> "CfgVehicles" >> _type >> "hasCommander") == 1);
	while {call _get_vec} do {
		if (_count > 0) then {
			if (_hasCommander) then {
				if (commander _vec == player && _actID == -1000) then {
					_actID = _vec addAction ["Поставить дым","x_scripts\x_throwsmoke.sqf",[],-1,false];
				} else {
					if (commander _vec != player && _actID != -1000) then {
						_vec removeAction _actID;
						_actID = -1000;
					};
				};
			} else {
				if (gunner _vec == player && _actID == -1000) then {
					_actID = _vec addAction ["Поставить дым","x_scripts\x_throwsmoke.sqf",[],-1,false];
				} else {
					if (gunner _vec != player && _actID != -1000) then {
						_vec removeAction _actID;
						_actID = -1000;
					};
				};
			};
		};
		sleep 0.512;
	};
	if (_actID != -1000) then {
		_vec removeAction _actID;
	};
};