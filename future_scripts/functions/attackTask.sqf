/*
	File: attackTask.sqf
	Description: assign an attack task to the task force.
	Call: [[_grp1, ..., _grpoN], _pos] execVM "attackTask.sqf"
	Copyright © Bohemia Interactive Studio. All rights reserved.
*/

private ["_attackForce", "_pos", "_grp", "_wp"];
_attackForce = _this select 0;
_pos = _this select 1;

for "_i" from 0 to ((count _attackForce) - 1) do {
	_grp = _attackForce select _i;
	//Create the waypoint.
	_wp = _grp addWaypoint [_pos, 0];
	_wp setWaypointType "SAD";
	//Set group properties.
	_grp setBehaviour "AWARE";
};

true