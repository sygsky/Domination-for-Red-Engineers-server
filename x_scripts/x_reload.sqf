// x_reload.sqf, by Xeno, called from SQM
//
//
// new input params format is: [thislist,"vehicle_type"]
private ["_config","_count","_i","_magazines","_vehicle","_type","_type_name","_pos","_su34","_speed"];

#include "x_setup.sqf"
#include "x_macros.sqf"

_vehicle = objNull;

_type = arg(1); // "Plane", "Helicopter", "LandVehicle" etc
{
    if ( _x isKindOf _type) then
    {
        if (isNull _vehicle ) then
        {
            _vehicle = _x;
        }
        else
        {
            if (!(_vehicle isKindOf "ParachuteBase")) then
            {
                if ( ((velocity _x) distance [0,0,0]) > ((velocity _vehicle) distance [0,0,0]) ) then
                {
                    _vehicle = _x;
                };
            };
        };
    };
} forEach arg(0); // for each thislist item do

if ( isNull _vehicle) exitWith{};

if (!alive _vehicle) exitWith {};

// Mainly check for helicopters, others are not so exposed to double reloading efforts
_already_loading = false;
_already_loading = _vehicle getVariable "already_on_load";
if (format ["%1", _already_loading] == "<null>") then { _already_loading = false;  }; // no var means not loading
if ( _already_loading ) exitWith
{
    _vehicle setVariable ["already_on_load", nil];
    [_vehicle, "STR_SYS_256_A_NUM" call SYG_getLocalizedRandomText] call XfVehicleChat; // "You lost your magical ability to download double ammunition"
};
_vehicle setVariable ["already_on_load", true]; // mark starting reload

_magazines = [];

_type = typeOf _vehicle;

#ifdef __REARM_SU34__
//_su34 = _vehicle call SYG_rearmAnySu34;
_su34 = _vehicle call SYG_rearmVehicleA;
if ( _su34 ) then // Su34 is rearmed
{
    //_magazines = argp((_type call SYG_getSu34Table),1); // get magazines list to reload each time
    _magazines = argp((_type call SYG_getVehicleTable),1); // get magazines list to reload each time
};
#endif


if (isNil "x_reload_time_factor") then {x_reload_time_factor = 1;};

//if (!local _vehicle) exitWith {};

if (d_reload_engineoff) then {
	_vehicle action ["engineOff", _vehicle];
};

_vehicle setFuel 0;
_vehicle setVehicleAmmo 1;	// Reload turrets / drivers magazine

_type_name = [_type,0] call XfGetDisplayName;

[_vehicle,format [localize "STR_SYS_255", _type_name]] call XfVehicleChat; // "Обслуживание: %1... Ожидайте..."

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
			_vehicle removeMagazines _x;
			_removed = _removed + [_x];
		};
	} forEach _magazines;
	{
		[_vehicle, format [localize "STR_SYS_256", _x]] call XfVehicleChat; // "Перезарядка: %1"
		sleep x_reload_time_factor;
		if (!alive _vehicle) exitWith {_vehicle setVariable ["already_on_load", nil];};
		_vehicle addMagazine _x;
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
				_vehicle removeMagazines _x;
				_removed = _removed + [_x];
			};
		} forEach _magazines;
		{
			_mag_disp_name = [_x,2] call XfGetDisplayName;
			[_vehicle,format [localize "STR_SYS_256", _mag_disp_name]] call XfVehicleChat; // "Перезарядка: %1"
			sleep x_reload_time_factor;
			if (!alive _vehicle) then {breakOut "xx_reload2_xx"};
			_vehicle addMagazine _x;
			sleep x_reload_time_factor;
			if (!alive _vehicle) then {breakOut "xx_reload2_xx"};
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
						_vehicle removeMagazines _x;
						_removed = _removed + [_x];
					};
				} forEach _magazines;
				{
					_mag_disp_name = [_x,2] call XfGetDisplayName;
					[_vehicle, format [localize "STR_SYS_256", _mag_disp_name]] call XfVehicleChat; // "Перезарядка: %1"
					sleep x_reload_time_factor;
					if (!alive _vehicle) then {breakOut "xx_reload2_xx"};
					_vehicle addMagazine _x;
					sleep x_reload_time_factor;
					if (!alive _vehicle) then {breakOut "xx_reload2_xx"};
				} forEach _magazines;
			};
		};
	};
};

// set cargo fuel and repair for any vehicles that support it
_vehicle setFuelCargo 1;
_vehicle setRepairCargo 1;

#ifdef __ACE__
_vehicle call SYG_reammoTruck; // call just in case of vehicle type "Truck5tReammo"
#endif

_vehicle setVehicleAmmo 1;	// Reload turrets / drivers magazine

if (__MandoVer) then {
	if (_vehicle isKindOf "Air") then {
		_fcleft = _vehicle getVariable "mando_flaresleft";
		_maxfc = _vehicle getVariable "mando_maxflares";
		if (format ["%1", _fcleft] != "<null>" && format ["%1", _maxfc] != "<null>") then {
			_vehicle setVariable ["mando_flaresleft", _maxfc];
		};
	};
};
sleep x_reload_time_factor;
if (!alive _vehicle) exitWith {_vehicle setVariable ["already_on_load", nil];};

//++++++++++++ Repairing
if ((getDammage _vehicle) > 0) then
{
    [_vehicle, localize "STR_SYS_258"] call XfVehicleChat; // "Repairing..."
    _vehicle setDamage 0;
    sleep x_reload_time_factor;
}
else
{
    [_vehicle, localize "STR_SYS_258_1"] call XfVehicleChat; // "Vehicle is fully functional, thx to engineers!"
};

//+++++ Refuelling
if (!alive _vehicle) exitWith {_vehicle setVariable ["already_on_load", nil];};
_pos = getPos _vehicle; // original position on service
[_vehicle, localize "STR_SYS_257"] call XfVehicleChat; // "Refuel..."
while {fuel _vehicle < 0.99} do {

    _pos1 = getPos _vehicle;
	if ( (_pos distance _pos1) > 0.5) exitWith // vehicle moved from service, so stop refuelling
	{
	    hint localize format["x_reload.sqf: refuelling aborted, fuel %1, (pos_orig %2) distance (pos_now %3) = %4", fuel _vehicle, _pos, getPos _vehicle, _pos distance _vehicle];
        [_vehicle, format [localize "STR_SYS_257_1", _type_name]] call XfVehicleChat; // "Refueling is interrupted, the hose came off"
	};
	sleep 0.3;
	_vehicle setFuel (((fuel _vehicle) + 0.5) min 1);
};
//_vehicle setFuel 1;
sleep x_reload_time_factor;
if (!alive _vehicle) exitWith {_vehicle setVariable ["already_on_load", nil];};
[_vehicle, format [localize "STR_SYS_259", _type_name]] call XfVehicleChat; // "%1: обслуживание завершено..."


if (true) exitWith {_vehicle setVariable ["already_on_load", nil];};
