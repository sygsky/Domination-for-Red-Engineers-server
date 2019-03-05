/*
	File: hasTransport.sqf
	Description: function determining this entry has transport capabilities.
	
	Copyright © Bohemia Interactive Studio. All rights reserved.
*/

private ["_tid", "_entry", "_hasTransport"];
_tid = _this select 0;
_entry = _this select 1;
_hasTransport = false;

if (!(_tid in [6, 7, 8, 9, 10])) then 
{
	if ((getNumber (_entry >> "transportSoldier")) > 0) then 
	{
		_hasTransport = true;
	};
};

_hasTransport