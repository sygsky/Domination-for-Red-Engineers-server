/*
	File: isAmphibious.sqf
	Description: function will return whether or not this vehicle is amphibious.
	
	Copyright © Bohemia Interactive Studio. All rights reserved.
*/

private ["_tid", "_entry", "_amphib"];
_tid = _this select 0;
_entry = _this select 1;
_amphib = false;

if (_tid in [0, 1]) then 
{
	if (getNumber(_entry >> "canFloat") == 1) then 
	{
		_amphib = true;
	};
} 
else 
{
	if (_tid == 11) then 
	{
		_amphib = true;
	};
};

_amphib