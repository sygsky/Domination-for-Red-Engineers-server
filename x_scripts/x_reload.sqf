// x_reload.sqf, by Xeno, called from SQM
//
// new input params format is: [thislist,"vehicle_type"]
//
// if (isServer && (!X_SPE)) exitWith{ hint localize format["--- x_reload.sqf for %1 with %2 called on dedicated server, exit", _this select 1, typeOf ((_this select 0) select 0)] };

private ["_config","_count","_i","_magazines","_veh","_type","_type_name","_pos","_su34","_speed","_nemaster",
         "_driver","_already_loading","_done","_msg"];

#include "x_setup.sqf"
#include "x_macros.sqf"

#define __DOUBLE_AMMUNITION__
#ifdef __DOUBLE_AMMUNITION__

if (isNil "SYG_DA_NAMES") then {// men allowed to load double ammunition on this service
    SYG_DA_NAMES = ["Виталий","Rokse [LT]","HE_MACTEP"];
};
#define PLAYER_CAN_LOAD_DOUBLE_AMMO ((isPlayer (driver _veh)) && ((name (driver _veh)) in SYG_DA_NAMES))

#else

#define PLAYER_CAN_LOAD_DOUBLE_AMMO false


#endif


_veh = objNull;

_type = arg(1); // "Plane", "Helicopter", "LandVehicle" etc
{
    if ( _x isKindOf _type) then {
        if (isNull _veh ) then {
            _veh = _x;
        } else {
            if (!(_veh call SYG_isParachute)) then {
                if ( ((velocity _x) distance [0,0,0]) > ((velocity _veh) distance [0,0,0]) ) then {// find fastest of vehicles available
                    _veh = _x;
                };
            };
        };
    };
} forEach arg(0); // for each thislist item do

if (!alive _veh) exitWith {};

// hint localize format["+++ x_reload.sqf: isServer=%1, isPlayer=%2(%3), _veh %4, dmg %5", isServer, isPlayer (driver _veh), name player, typeOf _veh, damage _veh];

#ifdef __DOUBLE_AMMUNITION__

_nemaster = PLAYER_CAN_LOAD_DOUBLE_AMMO;

// Mainly check for helicopters, others are not so exposed to double reloading efforts
_already_loading = false;
_already_loading = _veh getVariable "already_on_load";
//if (format ["%1", _already_loading] == "<null>") then { _already_loading = false;  }; // no var means not loading
if (isNil "_already_loading") then {_already_loading = false;};

//((isPlayer (driver _this)) && ((name (driver _this)) in SYG_DA_NAMES))
//hint localize format["+++ x_reload.sqf: player %1 (%2), in DA list == %3, already loading %4", isPlayer (driver _veh), name player, (name player) in SYG_DA_NAMES, _already_loading];

//hint localize format["_nemaster = %1, _already_loading = %2", _nemaster, _already_loading];
if ((!_nemaster) && _already_loading ) exitWith {
    [_veh, "STR_SYS_256_A_NUM" call SYG_getLocalizedRandomText] call XfVehicleChat; // "You lost your magical ability to reload double ammunition"
    _veh setVariable ["already_on_load", nil];
};

_done = false;
if (_nemaster && _already_loading ) then {
    if ((random 5) < 1) exitWith {// works 4 times out of 5
        [_veh, "STR_SYS_256_STOP_NUM" call SYG_getLocalizedRandomText] call XfVehicleChat; // "It seems that there are no technicians, we will have to ship everything manually"
        _done = true;
    };
    hint localize format[">>> x_reload.sqf: ""%1"" on heli service with double ammunitions !!! <<<",name (driver _veh)];
    [_veh, "STR_SYS_256_HM_NUM" call SYG_getLocalizedRandomText] call XfVehicleChat; // "A six-pack, being fetched to maintenance man, magically turns into double set of ammo!"
};

if (_done) exitWith {};

_veh setVariable ["already_on_load", true]; // mark already in reloading phase

#endif

_magazines = [];

_type = typeOf _veh;

#ifdef __REARM_SU34__
//_su34 = _veh call SYG_rearmAnySu34;
_su34 = _veh call SYG_rearmVehicleA;
if ( _su34 ) then {// Su34 is rearmed
    _magazines = argp((_type call SYG_getVehicleTable),1); // get magazines list to reload each time
};
#endif


if (isNil "x_reload_time_factor") then {x_reload_time_factor = 1;};

//if (!local _veh) exitWith {};

if (d_reload_engineoff) then {
	_veh action ["engineOff", _veh];
};

_veh setFuel 0;
_veh setVehicleAmmo 1;	// Reload turrets / drivers magazine

_type_name = [_type,0] call XfGetDisplayName;

[_veh,format [localize "STR_SYS_255", _type_name]] call XfVehicleChat; // "Обслуживание: %1... Ожидайте..."

#ifdef __REARM_SU34__
if (! _su34 ) then {// not filled with Su34 rearm code
#endif
    _magazines = getArray(configFile >> "CfgVehicles" >> _type >> "magazines");
#ifdef __REARM_SU34__
};
#endif

if (count _magazines > 0) then {
	_removed = [];
	{
		if (!(_x in _removed)) then {
			_veh removeMagazines _x;
			_removed = _removed + [_x];
		};
	} forEach _magazines;
	{
		[_veh, format [localize "STR_SYS_256", _x]] call XfVehicleChat; // "Перезарядка: %1"
		sleep x_reload_time_factor;
		if (!alive _veh) exitWith {_veh setVariable ["already_on_load", nil];};
		_veh addMagazine _x;
	} forEach _magazines;
};

#ifdef __REARM_SU34__
_count = 0;
if (!_su34) then {
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
				_veh removeMagazines _x;
				_removed = _removed + [_x];
			};
		} forEach _magazines;
		{
			_mag_disp_name = [_x,2] call XfGetDisplayName;
			[_veh,format [localize "STR_SYS_256", _mag_disp_name]] call XfVehicleChat; // "Перезарядка: %1"
			sleep x_reload_time_factor;
			if (!alive _veh) then {breakOut "xx_reload2_xx"};
			_veh addMagazine _x;
			sleep x_reload_time_factor;
			if (!alive _veh) then {breakOut "xx_reload2_xx"};
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
						_veh removeMagazines _x;
						_removed = _removed + [_x];
					};
				} forEach _magazines;
				{
					_mag_disp_name = [_x,2] call XfGetDisplayName;
					[_veh, format [localize "STR_SYS_256", _mag_disp_name]] call XfVehicleChat; // "Перезарядка: %1"
					sleep x_reload_time_factor;
					if (!alive _veh) then {breakOut "xx_reload2_xx"};
					_veh addMagazine _x;
					sleep x_reload_time_factor;
					if (!alive _veh) then {breakOut "xx_reload2_xx"};
				} forEach _magazines;
			};
		};
	};
};

//+++ #255: allow to restore flares here without need to be near repair trucks
//+++ for CAE flares always loaded
#ifndef __ACE__
if (__MandoVer) then {
#endif
	if (_veh isKindOf "Air") then {
		_fcleft = _veh getVariable "mando_flaresleft";
		_maxfc  = _veh getVariable "mando_maxflares";
		if ( (format ["%1", _fcleft] != "<null>") && (format["%1", _maxfc] != "<null>")) then {
		    if(_fcleft == _maxfc) exitWith{ titleText[ format[localize "STR_SYS_1218_0", typeOf _veh], "PLAIN DOWN" ]; }; // All chaff and flare dispensers are already full
		    _fcleft = _fcleft + 1;
		    for "_i" from _fcleft to _maxfc do  {
		        // print info on the step to load flares/chaffles "STR_SYS_1218"
		        titleText[ format[localize "STR_SYS_1218", _i], "PLAIN DOWN" ]; // Reload chaff and flare dispenser #%1
        		sleep x_reload_time_factor;
		    };
			_veh setVariable ["mando_flaresleft", _maxfc];
		};
	};
#ifndef __ACE__
};
#endif

if (!alive _veh) exitWith {_veh setVariable ["already_on_load", nil];};

//++++++++++++ Repairing
if (( damage _veh) > 0.001) then {
    [_veh, localize "STR_SYS_258"] call XfVehicleChat; // "Repairing..."
    _veh setDamage 0;
    sleep x_reload_time_factor;
} else {
    [_veh, localize "STR_SYS_258_1"] call XfVehicleChat; // "Vehicle is fully functional, thx from engineers!"
    //player addScore 1;
    1 call SYG_addBonusScore;
};

//+++++ refueling
if (!alive _veh) exitWith {_veh setVariable ["already_on_load", nil];};
_pos = getPos _veh; // original position on service
[_veh, localize "STR_SYS_257"] call XfVehicleChat; // "Refuel..."
while {fuel _veh < 0.9} do {

    _pos1 = getPos _veh;
	if ( (_pos distance _pos1) > 0.5) exitWith {// vehicle moved from service, so stop refueling
//	    hint localize format["+++ x_reload.sqf: %1 refueling aborted, fuel %12 (pos_orig %3) distance (pos_now %4) = %5", typeOf _veh, fuel _veh, _pos, getPos _veh, _pos distance _veh];
        [_veh, format [localize "STR_SYS_257_1", _type_name]] call XfVehicleChat; // "Refueling is interrupted, the hose came off"
	};
	sleep 0.3;
	_veh setFuel (((fuel _veh) + 0.5) min 1);
};
//_veh setFuel 1;
sleep x_reload_time_factor;

#ifdef __ACE__
if ( alive _veh) then {
    // add fuel/repair/ammo cargo for any vehicles that support it
    _msg = "";
    switch (typeOf _veh) do {
        case "ACE_Truck5t_Repair": { _veh setRepairCargo     1; _msg = "STR_SYS_RELOAD_REPAIR"; };
        case "ACE_Truck5t_Reammo": { _veh call SYG_reammoTruck; _msg = "STR_SYS_RELOAD_REAMMO";};
        case "ACE_Truck5t_Refuel": { _veh setFuelCargo       1; _msg = "STR_SYS_RELOAD_REFUEL";};
        default {};
    };
    if (_msg != "") then {
        [_veh, localize _msg] call XfVehicleChat; // "Reloading cargo..."
        sleep x_reload_time_factor;
    };
};
#endif


if (!alive _veh) exitWith {
    if ( !isNull _veh) then {
        _veh setVariable ["already_on_load", nil];
    };
    // TODO: print "Vehicle is destroyed"
};
[_veh, format [localize "STR_SYS_259", _type_name]] call XfVehicleChat; // "%1: обслуживание завершено..."

#ifdef __DOUBLE_AMMUNITION__
if (true) exitWith {_veh setVariable ["already_on_load", nil];};
#endif
