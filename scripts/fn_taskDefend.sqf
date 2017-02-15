#include "x_setup.sqf"
/*
	File: taskDefend.sqf
	Author: Joris-Jan van 't Land

	Description:
	Group will man nearby static defenses and guard the position.

	Parameter(s):
	_this select 0: group (Group)
	_this select 1: defense position (Array)
	
	Returns:
	Boolean - success flag
*/

if ((count _this) < 2) exitWith {false};

private ["_grp", "_pos"];
_grp = _this select 0;
_pos = _this select 1;

if ((typeName _grp) != (typeName grpNull)) exitWith {false};
if ((typeName _pos) != (typeName [])) exitWith {false};

_grp setBehaviour "SAFE";

private ["_list", "_units"];
_list = nearestObjects [_pos, ["StaticWeapon"], 100];
_units = (units _grp) - [leader _grp];
_staticWeapons = [];

{if ((_x emptyPositions "gunner") > 0) then {_staticWeapons set [count _staticWeapons, _x]};} forEach _list;

{
	if ((count _units) > 0) then {
		if ((random 1) > 0.2) then {
			private ["_unit"];
			_unit = (_units select ((count _units) - 1));
			_unit assignAsGunner _x;
			[_unit] orderGetIn true;
			_units resize ((count _units) - 1);
		};
	};
} forEach _staticWeapons;

private "_wp";
_wp = _grp addWaypoint [_pos, 10];
_wp setWaypointType "GUARD";

private "_handle";
_handle = _units spawn {
	sleep 5;
	{
		if ((random 1) > 0.4) then {
			doStop _x;
			sleep 0.5;
			_x action ["SitDown", _x];	
		};	
	} forEach _this;
};
true