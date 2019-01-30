// x_reload.sqf, by Xeno, called from SQM
//
// new input params format is: [thislist,"vehicle_type"]
//
if (isServer && (!X_SPE)) exitWith{ hint localize format["--- x_reload.sqf for %1 with %2 called on dedicated server, exit", _this select 1, typeOf ((_this select 0) select 0)] };

private ["_config","_count","_i","_magazines","_vehicle","_type","_type_name","_pos","_su34","_speed","_nemaster","_driver","_already_loading"];

#include "x_setup.sqf"
#include "x_macros.sqf"

#define __DOUBLE_AMMUNITION__
#ifdef __DOUBLE_AMMUNITION__

if (isNil "SYG_DA_NAMES") then // men allowed to load double ammunition on this service
{
    SYG_DA_NAMES = ["HE_MACTEP","Rokse [LT]"];
};
#define PLAYER_CAN_LOAD_DOUBLE_AMMO ((isPlayer (driver _vehicle)) && ((name (driver _vehicle)) in SYG_DA_NAMES))

#else

#define PLAYER_CAN_LOAD_DOUBLE_AMMO false

#endif


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
                if ( ((velocity _x) distance [0,0,0]) > ((velocity _vehicle) distance [0,0,0]) ) then // find fastest of vehicles available
                {
                    _vehicle = _x;
                };
            };
        };
    };
} forEach arg(0); // for each thislist item do

if ( isNull _vehicle) exitWith{};

if (!alive _vehicle) exitWith {};

#ifdef __DOUBLE_AMMUNITION__

_nemaster = PLAYER_CAN_LOAD_DOUBLE_AMMO;

// Mainly check for helicopters, others are not so exposed to double reloading efforts
_already_loading = false;
_already_loading = _vehicle getVariable "already_on_load";
//if (format ["%1", _already_loading] == "<null>") then { _already_loading = false;  }; // no var means not loading
if (isNil "_already_loading") then {_already_loading = false;};

//((isPlayer (driver _this)) && ((name (driver _this)) in SYG_DA_NAMES))
//hint localize format["+++ x_reload.sqf: player %1 (%2), in DA list == %3, already loading %4", isPlayer (driver _vehicle), name player, (name player) in SYG_DA_NAMES, _already_loading];

//hint localize format["_nemaster = %1, _already_loading = %2", _nemaster, _already_loading];
if ((!_nemaster) && _already_loading ) exitWith
{
    _vehicle setVariable ["already_on_load", nil];
    [_vehicle, "STR_SYS_256_A_NUM" call SYG_getLocalizedRandomText] call XfVehicleChat; // "You lost your magical ability to download double ammunition"
};

if (_nemaster && _already_loading ) then
{
    hint localize format[">>> x_reload.sqf: ""%1"" on heli service with double ammunitions !!! <<<",name (driver _vehicle)];
    [_vehicle, "STR_SYS_256_HM_NUM" call SYG_getLocalizedRandomText] call XfVehicleChat; // "A six-pack, being fetched to maintenance man, magically turns into double set of ammo!"
};

_vehicle setVariable ["already_on_load", true]; // mark already in reloading phase

#endif

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

if (__MandoVer) then {
	if (_vehicle isKindOf "Air") then {
		_fcleft = _vehicle getVariable "mando_flaresleft";
		_maxfc = _vehicle getVariable "mando_maxflares";
		if ( (format ["%1", _fcleft] != "<null>") && (format["%1", _maxfc] != "<null>")) then {
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
    [_vehicle, localize "STR_SYS_258_1"] call XfVehicleChat; // "Vehicle is fully functional, thx from engineers!"
    player addScore 1;
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

#ifdef __ACE__
if ( alive _vehicle) then
{
    // add fuel/repair/ammo cargo for any vehicles that support it
    _msg = "";
    switch (typeOf _vehicle) do {
        case "ACE_Truck5t_Repair": { _vehicle setRepairCargo     1; _msg = "STR_SYS_RELOAD_REPAIR"; };
        case "ACE_Truck5t_Reammo": { _vehicle call SYG_reammoTruck; _msg = "STR_SYS_RELOAD_REAMMO";};
        case "ACE_Truck5t_Refuel": { _vehicle setFuelCargo       1; _msg = "STR_SYS_RELOAD_REFUEL";};
        default {};
    };
    if (_mgs != "") then
    {
        [_vehicle, localize _msg] call XfVehicleChat; // "Reloading cargo..."
        sleep x_reload_time_factor;
    };
};
#endif


if (!alive _vehicle) exitWith
{
    if ( !isNull _vehicle) then
    {
        _vehicle setVariable ["already_on_load", nil];
    };
    // TODO: print "Vehicle is destroyed"
};
[_vehicle, format [localize "STR_SYS_259", _type_name]] call XfVehicleChat; // "%1: обслуживание завершено..."

#ifdef __DOUBLE_AMMUNITION__
if (true) exitWith {_vehicle setVariable ["already_on_load", nil];};
#endif
