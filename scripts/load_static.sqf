//////////////////////////////////////////////////////////////////
// Function file for Armed Assault
// Created by: -eutf-Myke
//////////////////////////////////////////////////////////////////

#include "x_setup.sqf"

_vehicle         = _this select 0;
_engineer        = _this select 1;
_cargo           = objNull;
_loading_allowed = false;

scopeName "load_static_scope";

//#ifndef __AI__
_str_p = format [ "%1", _engineer ];
if ( !( _str_p in d_is_engineer ) ) exitWith { hint localize "STR_SYG_02" }; // "Only engineers can load static weapons"
//#endif

_tr_full = false;
switch ( _vehicle ) do {
	case TR7: {
		if ( count truck1_cargo_array >= max_truck_cargo ) then { _tr_full = true; };
	};
	case TR8: {
		if ( count truck2_cargo_array >= max_truck_cargo ) then { _tr_full = true; };
	};
};

if ( _tr_full ) exitWith {
	( format [ localize "STR_SYG_03", max_truck_cargo ] ) call XfGlobalChat; // "Already %1 items loaded. Not possible to load more."
};

_cargo = nearestObject [_vehicle, "StaticWeapon"];
if ( isNull _cargo ) exitWith { hint localize "STR_SYG_04" }; // "No static weapon in range."
_cargo_type = typeOf _cargo;
_type_name = [ _cargo_type, 0 ] call XfGetDisplayName;
if ( !alive _cargo ) exitWith { hint format [ localize "STR_SYG_16", _type_name, typeOf _vehicle ] }; // "You can't load the dead %1 into a %2!"
if ( _cargo distance _vehicle > 10 ) exitWith { hint format [ localize "STR_SYG_05", _type_name, 10 ] }; // "You're too far from %1, max. dist. %2!"

_loading_allowed = true;

if ( _loading_allowed && currently_loading ) exitWith {
	localize "STR_SYG_06" call XfGlobalChat; // "You are already loading an item. Please wait until it is finished"
};

if (_loading_allowed) then {
	currently_loading = true;
	switch (_vehicle) do {
		case TR7: {
#ifdef __NO_REAMMO_IN_SALVAGE__
			if ( !( _cargo in truck1_cargo_array ) ) then { truck1_cargo_array set[ count truck1_cargo_array, _cargo ] };
#else
			truck1_cargo_array set[count truck1_cargo_array, _cargo_type];
#endif
			["truck1_cargo_array",truck1_cargo_array] call XSendNetVarAll;
		};
		case TR8: {
#ifdef __NO_REAMMO_IN_SALVAGE__
			if ( !( _cargo in truck2_cargo_array ) ) then { truck2_cargo_array set[count truck2_cargo_array, _cargo] };
#else
			truck2_cargo_array set[count truck2_cargo_array, _cargo_type];
#endif
			["truck2_cargo_array",truck2_cargo_array] call XSendNetVarAll;
		};
	};

	_msg  = localize "STR_SYG_07";	// "%1 will be loaded in %2 sec."
	_msg1 = localize "STR_SYG_13";	// "%1 cant be loaded (not empty)"
	_msg2 = localize "STR_SYG_14";	// "loading %1 is possible"
	_last_state = ( { alive _x } count crew _cargo ) min 1;
	_state = _last_state;

	for "_i" from 10 to 1 step -1 do {
		_str = _msg;
		switch ( _state ) do {
			case -1: { _str = _msg + "\n" + _msg2 };
			case +1: { _str = _msg + "\n" + _msg1 };
		};
		hint format [ _str, _type_name, _i ]; // "%1 will be loaded in %2 sec."
		sleep 1;
		_state = ({ alive _x } count crew _cargo) min 1;
		if ( ( _last_state > 0 ) && ( _state == 0 ) ) then { _state = -1; _last_state = 0 } else { _last_state = _state }; // state changed
	};

	if ( ( { alive _x } count crew _cargo ) > 0 ) exitWith { hint localize "STR_SYG_15"; currently_loading = false };
#ifdef __NO_REAMMO_IN_SALVAGE__
	if ( local _cargo ) then {
		_cargo setVehiclePosition [ [11239.3,9968.6], [], 0, "CAN_COLLIDE" ]; // hide in the middle of nowhere
		[ "say_sound", _vehicle, "steal" ] call XSendNetStartScriptClientAll;
		sleep 0.1;
		hint localize format[ "++++ load_static.sqf: cargo %1, alive %2, moved to %3", typeOf _cargo, alive _cargo, getPos _cargo ];
	} else {
		[ "move_vehicle", _cargo, [11239.3,9968.6], _vehicle, "steal" ] call XSendNetStartScriptAll;
	};
	_vehicle say "steal";
#else
	deleteVehicle _cargo;
#endif
	hint format [ localize "STR_SYG_08", _type_name ]; // "%1 loaded and attached!"
	currently_loading = false;
} else {
	hint format [ localize "STR_SYG_09", _type_name, typeOf _vehicle ]; // "You can't load a %1 into a %2!"
};
