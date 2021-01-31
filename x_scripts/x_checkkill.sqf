// x_checkkill.sqf, by Xeno. Called on player being killed
private ["_killed","_killer","_killedfriendly"];

#include "x_setup.sqf"

_killed = _this select 0;
_killer = _this select 1;

_killedfriendly = false;
//hint localize format["+++ x_checkkill.sqf: killed at pos %1, alive is %2", getPos _killed, if (alive _killed) then {"true"} else {"false"}];
#ifdef __AI__
if (!isNull _killer && side _killer == d_side_player && !isPlayer _killer) then {
	_leader_killer = leader _killer;
	if (isPlayer _leader_killer) then {
		_s = format [localize "STR_SYS_1170", name _leader_killer]; //"You were killed by the AI of %1"
		[_s, "GLOBAL"] call XHintChatMsg;
		_unit_killer = [name _leader_killer, name _killed, _killer];
		["unit_killer",_unit_killer] call XSendNetStartScriptClient;
	};
	_killedfriendly = true;
};
#endif

if (!isNull _killer && isPlayer _killer && _killer != _killed) then {
	_s = format [localize "STR_SYS_600", name _killer,d_sub_tk_points]; // "Вас убил %1. Штрафные очки для него -%2!"
	[_s, "GLOBAL"] call XHintChatMsg;
	_unit_killer = [name _killer, name _killed, _killer];
	["unit_killer",_unit_killer] call XSendNetStartScriptClient;
	_killedfriendly = true;
};

#ifdef __RANKED__
//if (!_killedfriendly) then {player addScore d_sub_kill_points};
if (!_killedfriendly) then { call SYG_incDeathCount };
#endif

#ifndef __REVIVE__
sleep d_respawn_delay + 10 + (random 15);
deleteVehicle _killed;
#endif

if (true) exitWith {};
