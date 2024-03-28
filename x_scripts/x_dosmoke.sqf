// by Xeno; x_dosmoke.sqf; launch smokes for men
//called on unit kill
//
// Modified:
//
private ["_killed", "_killer", "_grp_killed", "_has_smoke", "_grp_units", "_leader", "_one_shell", "_shell_unit", "_mags", "_one_shell_muzzle"];

if (!isServer) exitWith {};

#include "x_setup.sqf"

#undef __DEBUG__

_killed = _this select 0;
_killer = _this select 1;

_grp_killed = group _killed;

#ifndef __DEBUG__
if ( side _killer == side _killed || side _killer == civilian || isNull _killer || isNull _grp_killed ) exitWith {}; // Last man in group
//if ( _killer isKindOf "Air" && (((getPos _killer) select 2) > 5) ) exitWith {}; // Heli in air is killer
#endif

if ( vehicle _killed != _killed ) exitWith {
    [vehicle _killed, _killer, damage vehicle _killed] call x_smoke2;
};
_has_smoke = false;

// print unusual unit state when killed
if ( combatMode _killed != "YELLOW" ) then {
    if ( behaviour _killed != "COMBAT" ) then {
        hint localize format["+++ x_dosmoke.sqf: %1 killed, combat mode %2, behaviour %3%4",
            typeOf _killed,
            combatMode _killed,
            behaviour _killed,
            if (alive _killer) then { format[", dist to killer (%1) %2 m.",typeOf _killer, round(_killer distance _killed) ] } else { ", no alive killer" }];
    };
};

#ifdef __DEBUG__
if (_grp_killed in smoke_groups) exitWith {
	hint localize "+++ x_dosmoke.sqf: group of killed unit is already smoking, exit";
};
#endif

_grp_units = units _grp_killed;

#ifdef __DEBUG__
hint localize format["x_dosmoke.sqf: units in group %1, alive units %2", count _grp_units, {alive _x} count _grp_units];
#endif

if (({alive _x} count _grp_units) > 0) then {
	_grp_killed setCombatMode "YELLOW";
	_grp_killed setSpeedMode "NORMAL";
	_grp_killed setBehaviour "AWARE";
	
	sleep 0.5123;
	_leader = leader _grp_killed;
#ifdef __DEBUG__
	hint localize format["+++ x_dosmoke.sqf: leader %1 knowsAbout %2", name _leader, _leader knowsAbout _killer];
#endif
	if ((!isNull _leader) && (_leader knowsAbout _killer >= 1.5)) then {
		{
			if (alive _x) then {
				_x setUnitPos "DOWN";
			};
		} forEach _grp_units;
		_grp_units = nil;
		_nearest = objNull;
		_one_shell = "";
		scopeName "xxxx1";
	    _dist = 999999;
		_shell_unit = objNull;
		{
		    if (canStand _x) then {
                _shell_unit = _x;
                {
                    if (_x in [
    #ifdef __ACE__
                    "ACE_SmokeGrenade_Red","ACE_SmokeGrenade_White","ACE_SmokeGrenade_Green","ACE_SmokeGrenade_Yellow","ACE_SmokeGrenade_Violet",
    #endif
                    "SmokeShellRed","SmokeShellGreen","SmokeShell"]) then
                    {
                        if ((_shell_unit distance _killer) < _dist) then {_one_shell = _x; _nearest = _shell_unit; _dist = (_shell_unit distance _killer);};
                        breakTo "xxxx1";
                    };
                } forEach magazines _x;
                sleep 0.011;
			};
		} forEach units _grp_killed;

		if ( ! isNull _nearest ) then {
		    _shell_unit = _nearest;
#ifdef __DEBUG__
			hint localize format["+++ x_scripts/x_dosmoke.sqf: shell %1, unit %2 selected to throw", _one_shell, _shell_unit];
#endif			
			_one_shell_muzzle = (switch (_one_shell) do
			{
#ifdef __ACE__
			    case "ACE_SmokeGrenade_Red"   : {"SmokeShellRedMuzzle"};
			    case "ACE_SmokeGrenade_White" : {"SmokeShellMuzzle"};
			    case "ACE_SmokeGrenade_Green" : {"SmokeShellGreenMuzzle"};
			    case "ACE_SmokeGrenade_Yellow": {"SmokeShellYellowMuzzle"};
			    case "ACE_SmokeGrenade_Violet": {"SmokeShellVioletMuzzle"};
#endif
			    case "SmokeShell"     : {"SmokeShellMuzzle"};
			    case "SmokeShellGreen": {"SmokeShellGreenMuzzle"};
			    case "SmokeShellRed"  : {"SmokeShellRedMuzzle"};
				default {"<not defined>"};
			});
//			_one_shell_muzzle = (switch (_one_shell) do {case "SmokeShell": {"SmokeShellMuzzle"};case "SmokeShellGreen": {"SmokeShellGreenMuzzle"};case "SmokeShellRed": {"SmokeShellRedMuzzle"};});
#ifdef __DEBUG__			
			hint localize format["+++ x_scripts/x_dosmoke.sqf: shell %1, muzzle %2, unit %3 selected to throw", _one_shell, _one_shell_muzzle, _shell_unit];
#endif			
			_shell_unit selectWeapon _one_shell_muzzle;
			sleep 0.121;
			if (_shell_unit == _leader) then {
				_shell_unit doTarget _killer;
			} else {
				_shell_unit commandTarget _killer;
			};
#ifdef __DEBUG__			
			hint localize "+++ x_scripts/x_dosmoke.sqf: unit watch you now";
#endif			
			sleep 1.634;
			_shell_unit fire _one_shell_muzzle;
			_has_smoke = true;
			smoke_groups set [count smoke_groups, _grp_killed];
			sleep 1.437;
		    _shell_unit doWatch objNull;
#ifdef __DEBUG__		
			hint localize "+++ x_scripts/x_dosmoke.sqf: unit stop watching you";
		} else {
			hint localize "+++ x_scripts/x_dosmoke.sqf: smoke shell not found";
#endif			
		};
#ifdef __DEBUG__
	} else {
		hint localize format["+++ x_scripts/x_dosmoke.sqf: leader knowsAbout about %1 (too little)",_leader knowsAbout _killer];
#endif		
	};
	if (_has_smoke ) then {

		// let the group to be lurked about 1 minute
		sleep 0.512;
		{
			if (alive _x) then {
				_x disableAI "TARGET";
				_x disableAI "AUTOTARGET";
			};
		} forEach units _grp_killed;
		
		_grp_killed spawn {
			private ["_grp_killed"];
			_grp = _this;
			sleep 18.123;
			{
				if (alive _x) then {
					_x setUnitPos "AUTO";
					_x enableAI "TARGET";
					_x enableAI "AUTOTARGET";
				};
			} forEach units _grp;
		};
	
		_grp_killed spawn {
			private ["_grp_killed"];
			_grp = _this;
#ifdef __DEBUG__
			sleep 10.123;
#else
			//sleep 123.123;
			sleep 60.327;
#endif			
			smoke_groups = smoke_groups - [_grp];
		};
	};
};

smoke_groups = smoke_groups - [objNull];

if (true) exitWith {};
