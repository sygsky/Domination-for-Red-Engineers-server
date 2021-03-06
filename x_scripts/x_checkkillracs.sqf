// by Xeno
private ["_killed","_killer","_killedfriendly"];

#include "x_setup.sqf"

_killed = _this select 0;
_killer = _this select 1;

_killedfriendly = false;

if (!isNull _killer && side _killer == west && isPlayer _killer) then {
	_s = format ["You were killed by %1, the West team looses 20 kill points", name _killer];
	[_s, "GLOBAL"] call XHintChatMsg;
	_add_kills_west = - 30;
	["add_kills_west",_add_kills_west] call XSendNetStartScriptServer;
	_unit_killer = [name _killer, name _killed, "US", "RACS"];
	["unit_killer",_unit_killer] call XSendNetStartScriptClient;
};

if (!isNull _killer && side _killer == d_side_player) then {_killedfriendly = true};
#ifdef __RANKED__
if (!_killedfriendly) then {player addScore d_sub_kill_points};
#endif

sleep d_respawn_delay + 10 + (random 15);
deleteVehicle _killed;

if (true) exitWith {};
