// by Xeno
private ["_killer","_killed"];

_killed = _this select 0;
_killer = _this select 1;

if (local _killed) then {
	if (side _killer == resistance && isPlayer _killer) then {
		if (isServer) then {
			kill_points_racs = kill_points_racs - 20;
		} else {
			_add_kills_racs = - 20;
			["add_kills_racs",_add_kills_racs] call XSendNetStartScriptServer;
		};
		_vec_killer = [name _killer, "RACS"];
		["vec_killer",_vec_killer] call XSendNetStartScriptClient;
	};
};

if (true) exitWith {};
