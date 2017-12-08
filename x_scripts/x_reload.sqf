// x_reload.sqf, by Xeno, called from SQM
//
//
// new input params format is: [thislist,"vehicle_type"]
private ["_config","_count","_i","_magazines","_object","_type","_type_name","_pos","_su34","_speed"];

#include "x_setup.sqf"
#include "x_macros.sqf"

_object = objNull;

_type = arg(1); // "Plane", "Helicopter", "LandVehicle" etc
{
    if ( _x isKindOf _type) then
    {
        if (isNull _object ) then
        {
            _object = _x;
        }
        else
        {
            if (!(_object isKindOf "ParachuteBase")) then
            {
                if ( ((velocity _x) distance [0,0,0]) > ((velocity _object) distance [0,0,0]) ) then
                {
                    _object = _x;
                };
            };
        };
    };
} forEach arg(0); // for each thislist item do

if ( isNull _object) exitWith{};

if (!alive _object) exitWith {};

// Special check for helicopters
_exit = false;
if ( _object isKindOf "Helicopter") then
{
    _already_loading = _object getVariable "already_on_load";
    if (format ["%1", _already_loading] == "<null>") exitWith { _exit = true;  };
    _object setVariable ["already_on_load", true];
};
if ( _exit) exitWith
{
    _object setVariable ["already_on_load", nil];
    [_object, "STR_SYS_256_A_NUM" call SYG_getLocalizedRandomText] call XfVehicleChat; // "You lost your magical ability to download double ammunition"
};

_magazines = [];

_type = typeOf _object;

#ifdef __REARM_SU34__
//_su34 = _object call SYG_rearmAnySu34;
_su34 = _object call SYG_rearmVehicleA;
if ( _su34 ) then // Su34 is rearmed
{
    //_magazines = argp((_type call SYG_getSu34Table),1); // get magazines list to reload each time
    _magazines = argp((_type call SYG_getVehicleTable),1); // get magazines list to reload each time
};
#endif


if (isNil "x_reload_time_factor") then {x_reload_time_factor = 1;};

//if (!local _object) exitWith {};

if (d_reload_engineoff) then {
	_object action ["engineOff", _object];
};

_object setFuel 0;
_object setVehicleAmmo 1;	// Reload turrets / drivers magazine

_type_name = [_type,0] call XfGetDisplayName;

[_object,format [localize "STR_SYS_255", _type_name]] call XfVehicleChat; // "Обслуживание: %1... Ожидайте..."

#ifdef __REARM_SU34__
if (! _su34 ) then // not filled with Su34 rearm code
{
#endif
    _magazines = getArray(configFile >> "CfgVehicles" >> _type >> "magazines");
#ifdef __REARM_SU34__
};
#endif

if (count _magazines > 0) then {
	_removed = [];
	{
		if (!(_x in _removed)) then {
			_object removeMagazines _x;
			_removed = _removed + [_x];
		};
	} forEach _magazines;
	{
		[_object, format [localize "STR_SYS_256", _x]] call XfVehicleChat; // "Перезарядка: %1"
		sleep x_reload_time_factor;
		if (!alive _object) exitWith {_object setVariable ["already_on_load", nil];};
		_object addMagazine _x;
	} forEach _magazines;
};

#ifdef __REARM_SU34__
_count = 0;
if (!_su34) then
{
#endif
    _count = count (configFile >> "CfgVehicles" >> _type >> "Turrets");
#ifdef __REARM_SU34__
};
#endif

if (_count > 0) then {
	for "_i" from 0 to (_count - 1) do {
		scopeName "xx_reload2_xx";
		_config = (configFile >> "CfgVehicles" >> _type >> "Turrets") select _i;
		_magazines = getArray(_config >> "magazines");
		_removed = [];
		{
			if (!(_x in _removed)) then {
				_object removeMagazines _x;
				_removed = _removed + [_x];
			};
		} forEach _magazines;
		{
			_mag_disp_name = [_x,2] call XfGetDisplayName;
			[_object,format [localize "STR_SYS_256", _mag_disp_name]] call XfVehicleChat; // "Перезарядка: %1"
			sleep x_reload_time_factor;
			if (!alive _object) then {breakOut "xx_reload2_xx"};
			_object addMagazine _x;
			sleep x_reload_time_factor;
			if (!alive _object) then {breakOut "xx_reload2_xx"};
		} forEach _magazines;
		// check if the main turret has other turrets
		_count_other = count (_config >> "Turrets");
		// this code doesn't work, it's not possible to load turrets that are part of another turret :(
		// nevertheless, I leave it here
		if (_count_other > 0) then {
			for "_i" from 0 to (_count_other - 1) do {
				_config2 = (_config >> "Turrets") select _i;
				_magazines = getArray(_config2 >> "magazines");
				_removed = [];
				{
					if (!(_x in _removed)) then {
						_object removeMagazines _x;
						_removed = _removed + [_x];
					};
				} forEach _magazines;
				{
					_mag_disp_name = [_x,2] call XfGetDisplayName;
					[_object, format [localize "STR_SYS_256", _mag_disp_name]] call XfVehicleChat; // "Перезарядка: %1"
					sleep x_reload_time_factor;
					if (!alive _object) then {breakOut "xx_reload2_xx"};
					_object addMagazine _x;
					sleep x_reload_time_factor;
					if (!alive _object) then {breakOut "xx_reload2_xx"};
				} forEach _magazines;
			};
		};
	};
};

// set cargo fuel and repair for any vehicles that support it
_object setFuelCargo 1;
_object setRepairCargo 1;

#ifdef __ACE__
_object call SYG_reammoTruck; // call just in case of vehicle type "Truck5tReammo"
#endif

_object setVehicleAmmo 1;	// Reload turrets / drivers magazine

if (__MandoVer) then {
	if (_object isKindOf "Air") then {
		_fcleft = _object getVariable "mando_flaresleft";
		_maxfc = _object getVariable "mando_maxflares";
		if (format ["%1", _fcleft] != "<null>" && format ["%1", _maxfc] != "<null>") then {
			_object setVariable ["mando_flaresleft", _maxfc];
		};
	};
};
sleep x_reload_time_factor;
if (!alive _object) exitWith {_object setVariable ["already_on_load", nil];};
[_object, localize "STR_SYS_258"] call XfVehicleChat; // "Починка..."
_object setDamage 0;
sleep x_reload_time_factor;
if (!alive _object) exitWith {_object setVariable ["already_on_load", nil];};
[_object, localize "STR_SYS_257"] call XfVehicleChat; //"Заправка..."
while {fuel _object < 0.99} do {
	_object setFuel (((fuel _object) + 0.1) min 1);
	//_object setFuel 1;
	sleep 0.3;
};
sleep x_reload_time_factor;
if (!alive _object) exitWith {_object setVariable ["already_on_load", nil];};
[_object, format [localize "STR_SYS_259", _type_name]] call XfVehicleChat; // "%1: обслуживание завершено..."


if (true) exitWith {_object setVariable ["already_on_load", nil];};
