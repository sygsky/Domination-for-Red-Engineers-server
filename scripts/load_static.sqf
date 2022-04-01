//////////////////////////////////////////////////////////////////
// Function file for Armed Assault
// Created by: -eutf-Myke
//////////////////////////////////////////////////////////////////

#include "x_setup.sqf"

_vehicle = _this select 0;
_engineer = _this select 1;
_cargo = objnull;
_loading_allowed = false;

scopeName "load_static_scope";

//#ifndef __AI__
_str_p = format ["%1", _engineer];
if (!(_str_p in d_is_engineer)) exitWith {hint localize "STR_SYG_02";}; // "Only engineers can load static weapons"
//#endif

_tr_full = false;
switch (_vehicle) do {
	case TR7: {
		if (count truck1_cargo_array >= max_truck_cargo) then {
			(format [localize "STR_SYG_03", max_truck_cargo]) call XfGlobalChat; // "Already %1 items loaded. Not possible to load more."
			_tr_full = true;
		};
	};
	case TR8: {
		if (count truck2_cargo_array >= max_truck_cargo) then {
			(format [localize "STR_SYG_03", max_truck_cargo]) call XfGlobalChat; // "Already %1 items loaded. Not possible to load more."
			_tr_full = true;
		};
	};
};

if (_tr_full) exitWith {};

_cargo = nearestObject [_vehicle, "StaticWeapon"];
if (isNull _cargo) exitWith {hint localize "STR_SYG_04"}; // "No static weapon in range."
_cargo_type = typeOf _cargo;
_type_name = [_cargo_type,0] call XfGetDisplayName;
if (_cargo distance _vehicle > 10) exitWith {hint format [localize "STR_SYG_05", _type_name, 10]}; // "You're too far from %1, max. dist. %2!"

_loading_allowed = true;

if (_loading_allowed && currently_loading) exitWith {
	localize "STR_SYG_06" call XfGlobalChat; // "You are already loading an item. Please wait until it is finished"
};

if (_loading_allowed) then {
	currently_loading = true;
	switch (_vehicle) do {
		case TR7: {
			if (count truck1_cargo_array >= max_truck_cargo) then {
				(format [localize "STR_SYG_03", max_truck_cargo]) call XfGlobalChat; // "Already %1 items loaded. Not possible to load more."
			} else {
				truck1_cargo_array set[count truck1_cargo_array, _cargo_type];
				["truck1_cargo_array",truck1_cargo_array] call XSendNetVarAll;
			};
		};
		case TR8: {
			if (count truck2_cargo_array >= max_truck_cargo) then {
				(format [localize "STR_SYG_03", max_truck_cargo]) call XfGlobalChat; // "Already %1 items loaded. Not possible to load more."
			} else {
				truck2_cargo_array set[count truck2_cargo_array, _cargo_type];
				["truck2_cargo_array",truck2_cargo_array] call XSendNetVarAll;
			};
		};
	};
	for "_i" from 10 to 1 step -1 do {
		hint format [localize "STR_SYG_07", _type_name, _i]; // "%1 will be loaded in %2 sec."
		sleep 1;
	};
	deleteVehicle _cargo;
	hint format [localize "STR_SYG_08", _type_name]; // "%1 loaded and attached!"
	currently_loading = false;
} else {
	hint format [localize "STR_SYG_09", _type_name, typeof _vehicle]; // "You can't load a %1 into a %2!"
};
