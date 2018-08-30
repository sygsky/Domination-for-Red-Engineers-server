// x_fackilled.sqf, by Xeno. Called from "killed" event
// "Killed" event params:
//  Triggered when the unit is killed.
//
//  Local.
//
//  Passed array: [unit, killer]
//
//  unit: Object - Object the event handler is assigned to
//  killer: Object - Object that killed the unit
//  Contains the unit itself in case of collisions.
//
#include "x_setup.sqf"

private ["_fac","_pos","_index"];
if (!isServer) exitWith {};


_fac = _this select 0;
_pos = position _fac;

_index = -1;
for "_i" from 0 to (count d_aircraft_facs - 1) do {
	_element = d_aircraft_facs select _i;
	_apos = _element select 0;
	if (_apos distance _pos < 10) exitWith { // this factory is deep underground now (so Arma kills building)
		_index = _i;
	};
};

if (_index != -1) then {
	switch (_index) do {
		case 0: {d_jet_service_fac = _fac;["d_jet_service_fac",d_jet_service_fac] call XSendNetStartScriptClient;};
		case 1: {d_chopper_service_fac = _fac;["d_chopper_service_fac",d_chopper_service_fac] call XSendNetStartScriptClient;};
		case 2: {d_wreck_repair_fac = _fac;["d_wreck_repair_fac",d_wreck_repair_fac] call XSendNetStartScriptClient;};
	};
};

_killer = _this select 1;
if ( isNull _killer  || _fac == _killer ) exitWith { hint localize format[ "x_fackilled.sqf: killer = %1", _killer ]; };

// Some agent killed factory, send message

_man    = if ( _killer isKindOf "CaManBase" ) then { "MAN" } else { "VEH" };
_side   = if ( side _killer == d_side_enemy ) then { "ENEMY" } else { "OWN" };

_param1 = typeOf _killer;
_param2 = if ( _killer isKindOf "CaManBase" ) then { name _killer } else { name ( gunner _killer ) };

_str    = format[ "STR_FAC_%1_%2", _side, _man ];
[ "sub_fac_score", _str, _param1, _param2 ] call XSendNetStartScriptClient;
if (true) exitWith {};
