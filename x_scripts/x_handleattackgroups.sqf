// by Xeno, x_scripts\x_handleattackgroups.sqf - handles with paratrooper groups at main targets
private ["_allunits","_grp","_grps"];

#include "x_macros.sqf"

if (!isServer) exitWith {};

_grps = _this select 0;
_allunits = [];
{
	_grp = _x;
	[_allunits, units _grp] call SYG_addArrayInPlace;
	sleep 0.011;
} forEach _grps;

sleep 1.2123;

while {!(mt_radio_down || create_new_paras)} do {
	if (X_MP) then {
		waitUntil {sleep (35.012 + random 1);(call XPlayersNumber) > 0};
	};
	sleep 10.623;
	// __DEBUG_NET("x_handleattackgroups.sqf",(call XPlayersNumber))
	create_new_paras = ({alive _x  && canStand _x} count _allunits) < 5;
};

_allunits = nil;
_grps = nil;

d_c_attacking_grps = [];

if (true) exitWith {};
