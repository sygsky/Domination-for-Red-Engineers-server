// by Xeno
private ["_killed","_killer","_killedfriendly"];

#include "x_setup.sqf"

_killed = _this select 0;
_killer = _this select 1;

_killedfriendly = false;

if (!isNull _killer && side _killer == resistance && isPlayer _killer) then {
	_s = format ["You were killed by %1, the Racs team looses 20 kill points", name _killer];
	[_s, "GLOBAL"] call XHintChatMsg;
	_add_kills_racs = - 30;
	["add_kills_racs",_add_kills_racs] call XSendNetStartScriptServer;
	_unit_killer = [name _killer, name _killed, "RACS", "US"];
	["unit_killer",_unit_killer] call XSendNetStartScriptClient;
};

if (!isNull _killer && side _killer == d_side_player) then {_killedfriendly = true};
#ifdef __RANKED__
if (!_killedfriendly) then {player addScore d_sub_kill_points};
#endif

sleep d_respawn_delay + 10 + (random 15);
deleteVehicle _killed;

if (true) exitWith {};
