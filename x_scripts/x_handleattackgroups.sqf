// by Xeno, x_scripts\x_handleattackgroups.sqf - hadnles with paratrooper groups at main targets
private ["_allunits","_grp","_grps"];

#include "x_macros.sqf"

if (!isServer) exitWith {};

_grps = _this select 0;
_allunits = [];
{
	_grp = _x;
	{
		_allunits = _allunits + [_x];
	} forEach units _grp;
	sleep 0.011;
} forEach _grps;

sleep 1.2123;

while {!mt_radio_down} do {
	if (X_MP) then {
		waitUntil {sleep (5.012 + random 1);(call XPlayersNumber) > 0};
	};
	// __DEBUG_NET("x_handleattackgroups.sqf",(call XPlayersNumber))
	if (({alive _x} count _allunits) < 5) exitWith {
		create_new_paras = true;
	};
	sleep 10.623;
};

_allunits = nil;
_grps = nil;

d_c_attacking_grps = [];

if (true) exitWith {};
