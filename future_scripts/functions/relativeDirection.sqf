/*
	File: relativeDirection.sqf
	Description: returns the direction of one position towards another direction.
	
	Copyright © Bohemia Interactive Studio. All rights reserved.
*/

private ["_pos1", "_pos2"];
_pos1 = _this select 0;
_pos2 = _this select 1;

private ["_dX", "_dY", "_a"];
_dX = (_pos1 select 0) - (_pos2 select 0);
_dY = (_pos1 select 1) - (_pos2 select 1);
_a = _dX atan2 _dY;

_a - 180