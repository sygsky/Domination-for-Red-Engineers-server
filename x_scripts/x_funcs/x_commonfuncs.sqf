#include "x_setup.sqf"
#include "x_macros.sqf"

x_commonfuncs_compiled = false;

private ["_search_array"];
_search_array = [];

for "_i" from 0 to (count (configFile >> "cfgPatches") - 1) do {
	_search_array = _search_array + [configName ((configFile >> "cfgPatches") select _i)];
};

#ifndef __ACE__
if (isServer) then {
	if (d_use_mod_tracked) then {
		d_found_gdtmodtracked = (if ("GDTModTracked" in _search_array) then {true} else {false});
		__DEBUG_SERVER("x_commonfuncs.sqf",d_found_gdtmodtracked)

		if (!(d_found_gdtmodtracked)) then {
			// from GDTModTracked made by Hein Blud
			XGDTTracked = {
				private ["_vehicle"];
				_vehicle = _this select 0;
				if (local _vehicle) then {
					while {alive _vehicle && !isNull _vehicle} do {
						if (((vectorUp _vehicle select 2) < (0.3)) or (((velocity _vehicle select 2) > 5) and ((getPos _vehicle select 2) > 4))) then {
							_vehicle setPos [getPos _vehicle select 0, getPos _vehicle select 1, 0];
							_vehicle setVelocity [(velocity _vehicle select 0) * 0.5, (velocity _vehicle select 1) * 0.5, (velocity _vehicle select 2) * 0.5];
						};
						sleep 0.1;
					};
				};
			};
		}
		else
		{
        	hint localize "+++ GDTModTracked detected";
		};
	} else {
		d_found_gdtmodtracked = true;
	};
};
#else
d_found_gdtmodtracked = true; // skip GDTModTracked as totally useless
d_use_mod_tracked = false;
XGDTTracked = {};
#endif

SYG_found_GL3 = "GL3" in _search_array;
hint localize format["+++ GL3 = %1", SYG_found_GL3];
if (d_enemy_side == "WEST" && (__ACEVer) && isServer) then
{
    hint localize format["+++ Server: GL3_Global[65] = %1", argp(GL3_Global,65)];
    GL3_Server set[64, [d_crewman_W,d_creman2_W,d_pilot_W]]; // set crew men who never unmount vehicles during reinforcement
};
#ifndef __ACE__
d_found_DMSmokeGrenadeVB = (if ("DMSmokeGrenadeVB" in _search_array) then {true} else {false});
__DEBUG_SERVER("x_commonfuncs.sqf",d_found_DMSmokeGrenadeVB)

if ("six_sys_suppression" in _search_array) then {d_suppression = false;};

if (d_found_DMSmokeGrenadeVB) then {
	X_DM_SMOKE_SHELL = {
		private ["_ThisSmoke","_here","_ViewBlock","_wind","_timeout"];
		_ThisSmoke = _this select 0;
		DM_MP_THROW_OBJ = _ThisSmoke;
		publicVariable "DM_MP_THROW_OBJ";
		_here = position _ThisSmoke;
		sleep ((random 5) + 5);
		_ViewBlock = "DMShellSmokeVBinv" createVehicleLocal _here;
	
		_wind = wind;
				
		_ViewBlock setPos [(_here select 0), (_here select 1), ((_here select 2) +5)];
		_ViewBlock setVectorUp [-1*(_wind select 0),-1*(_wind select 1),1];
				
		_timeout = time + 60;
		while {time < _timeout} do {
			_wind = wind;
				
			sleep 5;// is here to allow particles to drift first before adjusting Viewblock
				
			_here = position _ThisSmoke;
			_ViewBlock setPos [(_here select 0), (_here select 1), ((_here select 2) +5)];//is in the loop in case of v. high launch
			_ViewBlock setVectorUp [-1*(_wind select 0),-1*(_wind select 1),1];
		};
		
		deleteVehicle _ViewBlock;
	};
};
#endif
#ifdef __ACE__
d_found_DMSmokeGrenadeVB = true; // makes things easier, don't want to update millions of files ;)

X_DM_SMOKE_SHELL = {
		private ["_smoke"];
		_smoke = _this select 0;
		if (local _smoke) then {
			[objNull,objNull,objNull,objNull,typeOf _smoke,_smoke] spawn ace_viewblock_fired;
		};
};
#endif

_search_array = nil;

x_repall = {
	private ["_vec"];
	_vec = _this select 0;
	_vec setDamage 0;
#ifdef __LIMITED_REFUELLING__
	if ((count _this)>1)then{_vec setFuel(_this select 1);}else{_vec setFuel 1;};
#else
	_vec setFuel 1;
#endif	
};

x_commonfuncs_compiled = true;

if (true) exitWith {};