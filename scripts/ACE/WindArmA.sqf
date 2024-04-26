/*
WindArmA.sqf

This script will try and simulate wind on the specified vehicle using ArmA's enviornmental Wind.

_EHGetInWind = TestVehicle addEventHandler ["GetIn", { _this execVM "windArmA.sqf" }]
*/

_Veh = _this select 0;
_Seat = _this select 1;
_Pilot = _this select 2;

_MinAlt = 2;

_Default_Wind_Modifier = .5;
_WindSpeedModifier = -1;
_WindAltModifier = -1;
If (IsNil "ACE_Wind_Heli_Enabled") exitwith {};

If (IsNil "ACE_Wind_Modifier_Vehicles") then
{
//	["ACE_Wind_Modifier_Vehicles modified"] call ACE_fDebug;
	ACE_Wind_Modifier_Vehicles = _Default_Wind_Modifier;
};

//[format["ACE_Wind_Modifier_Vehicles is %1",ACE_Wind_Modifier_Vehicles]] call ACE_fDebug;

ACE_PlayerisPilot = true;
//if (_Seat != "driver") then
if (driver _Veh != player) then {
	_LoopNonExit = true;
	while { ACE_PlayerisPilot && _LoopNonExit } do {
		if (driver _Veh == player) then {
			_LoopNonExit = false;
		};
	sleep 2;
	};
};

_windSpd = [  1,    4,    7,   8,   9, 100000]; // Wind Speed and
_windMod = [0.1, 0.15, 0.25, 0.4, 0.6,   0.85]; // its modifier
_wndLastInd = (count _windSpd) - 1;

_alt    = [  1,    5,    10,   25,   50, 100, 300, 500, 700, 1000, 100000]; // Wind Speed and
_altMod = [0.1, 0.15, 0.25, 0.4, 0.6,   0.85]; // its modifier
_altLastInd = (count _windSpd) - 1;

//["Wind Script Starting"] call ACE_fDebug;
while { ACE_PlayerisPilot && Alive _Veh } do {
	_CurWind = sqrt(((Wind select 0)*(Wind select 0))+((Wind select 1)*(Wind select 1)));
	_CurWindBearing = (Wind select 0) atan2 (Wind select 1);
//	hint format["Wind is %1 at %2 degrees",_CurWind,_CurWindBearing];
    for "_i" from 0 to _wndLastInd do {
        if (_CurWind < (_windSpd select _i)) exitWith {
            _WindSpeedModifier = _windMod select _i;
        };
    };
#ifdef __OLD__    
	if (_CurWind >= 0 && _CurWind < 1) then {
		_WindSpeedModifier = .1;
	} else {
		if (_CurWind >= 1 && _CurWind < 4) then {
			_WindSpeedModifier = .15;
		} else {
			if (_CurWind >= 4 && _CurWind < 7) then {
				_WindSpeedModifier = .25;
			} else {
				if (_CurWind >= 7 && _CurWind < 8) then {
					_WindSpeedModifier = .40;
				} else {
					if (_CurWind >= 8 && _CurWind < 9) then {
						_WindSpeedModifier = .60;
					} else {
						if (_CurWind >= 9) then {
							_WindSpeedModifier = .85;
						};
					};
				};
			};
		};
	};
#endif	
	_CurAlt = getpos _veh select 2;
	if (_CurAlt < 1) then
	{
		_WindAltModifier = 0;
	}
	else
	{
		if (_CurAlt >= 1 && _CurAlt < 5) then
		{
			_WindAltModifier = .1;
		}
		else
		{
			if (_CurAlt >= 5 && _CurAlt < 10) then
			{
				_WindAltModifier = .2;
			}
			else
			{
				if (_CurAlt >= 10 && _CurAlt < 25) then
				{
					_WindAltModifier = .3;
				}
				else
				{
					if (_CurAlt >= 25 && _CurAlt < 50) then
					{
						_WindAltModifier = .4;
					}
					else
					{
						if (_CurAlt >= 50 && _CurAlt < 100) then
						{
							_WindAltModifier = .5;
						}
						else
						{
							if (_CurAlt >= 100 && _CurAlt < 300) then
							{
								_WindAltModifier = .6;
							}
							else
							{
								if (_CurAlt >= 300 && _CurAlt < 500) then
								{
									_WindAltModifier = .7;
								}
								else
								{
									if (_CurAlt >= 500 && _CurAlt < 700) then
									{
										_WindAltModifier = .8;
									}
									else
									{
										if (_CurAlt >= 700 && _CurAlt < 1000) then
										{
											_WindAltModifier = .9;
										}
										else
										{
											if (_CurAlt >= 1000) then
											{
												_WindAltModifier = 1;
											};
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};

	_WX = ((Wind select 0)*_WindSpeedModifier*_WindAltModifier)/10;
	_WY = ((Wind select 1)*_WindSpeedModifier*_WindAltModifier)/10;
	_WZ = ((Wind select 2)*_WindSpeedModifier*_WindAltModifier)/10;

//	hint format["X: %1\nY: %2\nZ: %3",Wind select 0,wind select 1,wind select 2];
//	hint format["X: %1\nY: %2\nZ: %3",_WX,_WY,_WZ];

//	Apply wind to helicopter smoothly in 1/10 sec increments
	for [{ _i = 0 },{ _i != 10+1 },{ _i = _i+1 }] do
	{
		_VX = velocity _veh select 0;
		_VY = velocity _veh select 1;
		_VZ = velocity _veh select 2;
		_Veh SetVelocity [(_VX + _WX),(_VY + _WY),(_VZ + _WZ)];
		sleep 0.1;
	};
};
ACE_PlayerisPilot = false;

