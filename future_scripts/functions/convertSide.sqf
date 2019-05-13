/*
	File: convertSide.sqf
	Description: function which accepts either a side of integer representing a side and will return an appropriate side conversion.
	
	Copyright © Bohemia Interactive Studio. All rights reserved.
*/

private ["_side", "_return"];
_side = _this select 0;

if ((typeName _side) == "SCALAR") then 
{
	switch (_side) do 
	{
		case 0: 
		{
			_return = east;
		};
		
		case 1: 
		{
			_return = west;
		};
		
		case 2: 
		{
			_return = resistance;
		};
		
		case 3: 
		{
			_return = civilian;
		};
		
		default 
		{
			_return = east;
		};
	};
} 
else 
{
	switch (_side) do 
	{
		case east: 
		{
			_return = 0;
		};
		
		case west: 
		{
			_return = 1;
		};
		
		case resistance: 
		{
			_return = 2;
		};
		
		case civilian: 
		{
			_return = 3;
		};
		
		default 
		{
			_return = 0;
		};
	};
};

_return