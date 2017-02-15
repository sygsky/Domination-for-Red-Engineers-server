// by Xeno
private ["_killer","_killed"];

_killed = _this select 0;
_killer = _this select 1;

if (local _killed) then {
	if (side _killer == west && isPlayer _killer) then {
		if (isServer) then {
			kill_points_west = kill_points_west - 20;
		} else {
			_add_kills_west = - 20;
			["add_kills_west",_add_kills_west] call XSendNetStartScriptServer;
		};
		_vec_killer = [name _killer, "US"];
		["vec_killer",_vec_killer] call XSendNetStartScriptClient;
	};
};

if (true) exitWith {};
