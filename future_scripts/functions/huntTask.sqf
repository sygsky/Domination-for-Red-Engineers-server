/*
	File: huntTask.sqf
	Description: assign a hunt task to the task force.
	
	Copyright © Bohemia Interactive Studio. All rights reserved.
*/

private ["_attackForce", "_prey"];
_attackForce = _this select 0;
_prey = _this select 1;

private ["_pos"];
_pos = position _prey;
for "_i" from 0 to ((count _attackForce) - 1) do 
{
	private ["_grp", "_wp"];
	_grp = _attackForce select _i;
	
	//Create the waypoint.
	_wp = _grp addWaypoint [_pos, 1];
	_wp setWaypointType "MOVE";
	_wp setWaypointStatements ["false", ""];
	
	//Set group properties.
	_grp setBehaviour "AWARE";
};

while {!([_attackForce] call LIB_forceDestroyedFunction)} do 
{
	_pos = position _prey;
	for "_i" from 0 to ((count _attackForce) - 1) do 
	{
		private ["_grp"];
		_grp = _attackForce select _i;
		
		//Update the waypoint.
		[_grp, 1] setWPPos _pos;
	};
	
	sleep 10;
};

true