/*
	File: isWeapon.sqf
	Description: returns whether or not this tid is a weapon.
	
	Copyright © Bohemia Interactive Studio. All rights reserved.
*/

private ["_tid", "_cid", "_isWeapon"];
_tid = _this select 0;

if (_tid >= 0) then 
{
	_cid = (LIB_types select _tid) select 1;
} 
else 
{
	_cid = -1;
};

if (_cid == 1) then 
{
	_isWeapon = true;
} 
else 
{
	_isWeapon = false;
};

_isWeapon