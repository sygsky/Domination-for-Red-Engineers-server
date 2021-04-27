/*
	File: findMaxSpeed.sqf
	Description: find the effective maximum speed for a vehicle.
	
	Copyright © Bohemia Interactive Studio. All rights reserved.
*/

private ["_entry", "_type", "_sim"];
_entry = _this select 0;
_type = configName _entry;
_sim = getText(_entry >> "simulation");

private ["_maxSpeed", "_terrainCoef"];
_maxSpeed = getNumber(_entry >> "maxSpeed");
_terrainCoef = getNumber(_entry >> "terrainCoef");

private ["_realMaxSpeed"];
switch (_sim) do 
{
	//terrainCoef and modifier
	case "car": 
	{
		_realMaxSpeed = (_maxSpeed / _terrainCoef) + 18;
	};
	
	//terrainCoef and modifier
	case "motorcycle": 
	{
		_realMaxSpeed = (_maxSpeed / _terrainCoef) + 25;
	};
	
	//-0%
	case "tank": 
	{
		_realMaxSpeed = _maxSpeed;
	};
	
	//-15%
	case "helicopter": 
	{
		_realMaxSpeed = _maxSpeed * 0.85;
	};
	
	//-20%
	case "airplane": 
	{
		_realMaxSpeed = _maxSpeed * 0.8;
	};
	
	//-0%
	case "ship": 
	{
		_realMaxSpeed = _maxSpeed;
	};
	
	default 
	{
		_realMaxSpeed = _maxSpeed;	
	};
};

_realMaxSpeed