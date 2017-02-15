// x_scripts/x_arihit.sqf, by Xeno
private ["_grp","_grps","_hideobject","_leader","_noa","_shell","_units","_grpx","_ari_target"];
if (!isServer) exitWith {};

#include "x_setup.sqf"

_ari_target = _this;

_noa = nearestObjects [[position _ari_target select 0,position _ari_target select 1,0], ["CAManBase","LandVehicle"], 70];

if (count _noa == 0) exitWith {};

_grps = [];
{
	_grp = group _x;
	if (!(_grp in _grps)) then {
		_grps = _grps + [_grp];
	};
	sleep 0.01;
} forEach _noa;

_noa = nil;

sleep 0.412;

if (d_smoke) then {
	{
		_agrp = _x;
		if (({alive _x} count units _agrp) > 0) then {
			_leader = leader _agrp;
			if (!(isPlayer _leader)) then {
				if (vehicle _leader != _leader) then {
					if ((vehicle _leader) isKindOf "Tank") then {
						_shell = "SmokeShell" createVehicle (position _leader);
						#ifdef __ACE__
						[objNull,objNull,objNull,objNull,"SmokeShell",_shell] spawn ace_viewblock_fired;
						#endif
						#ifndef __ACE__
						if (d_found_DMSmokeGrenadeVB) then {
							[_shell] spawn X_DM_SMOKE_SHELL;
						};
						#endif
					};
				} else {
					_one_shell = "";
					_shell_unit = objNull;
					{
						scopeName "xxxx9";
						_mags = magazines _x;
						_shell_unit = _x;
						{
							if (_x in ["SmokeShellRed","SmokeShellGreen","SmokeShell"]) then {
								_one_shell = _x;
								breakOut "xxxx9";
							};
						} forEach _mags;
						sleep 0.011;
					} forEach units _agrp;
					if (_one_shell != "") then {
						_shell = _one_shell createVehicle (position _shell_unit);
						#ifdef __ACE__
						[objNull,objNull,objNull,objNull,"SmokeShell",_shell] spawn ace_viewblock_fired;
						#endif
						#ifndef __ACE__
						if (d_found_DMSmokeGrenadeVB) then {
							[_shell] spawn X_DM_SMOKE_SHELL;
						};
						#endif
						_shell_unit removeMagazine _one_shell;
					};
				};
			};
			sleep 1 + random 2;
		};
	} forEach _grps;
};

sleep 1.232;
{
	_units = units _x;
	_grpx = _x;
	if (({alive _x} count _units) != 0) then {
		_leader = leader _x;
		if (vehicle _leader == _leader) then {
			{
				_hideobject = _x findCover [position _ari_target, position _ari_target, 120];
				if (_x == leader _grpx) then {
					_x doMove position _hideobject;
				} else {
					_x commandMove position _hideobject;
				};
				sleep 0.012;
			} forEach _units;
		};
	};
	sleep 0.012;
} forEach _grps;

_grps = nil;

if (true) exitWith {};
