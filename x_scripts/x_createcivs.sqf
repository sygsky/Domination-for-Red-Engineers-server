// by Xeno
private ["_target_nr","_list","_target","_target_center","_ran_bus","_ran_car","_ran_ped","_radius"];
if (!isServer) exitWith {};

#include "x_macros.sqf"

_target_nr = _this select 0;
_list = _this select 1;

_target = target_names select _target_nr;
_target_center = _target select 0;

_ran_bus = ceil random 2;
_ran_car = ceil random 3;
_ran_ped = ceil random 5;
if (_ran_ped < 3) then {_ran_ped = 3};

_radius = _target select 2;

call compile format ["waitUntil {sleep 0.121;count x_civs_array_%1 == 0};",_target_nr];

for "_i" from 1 to _ran_bus do {
	_start_pos = [_target_center,_radius] call XfGetRanPointCircle;
	
	if (count _list == 0) exitWith {};
	
	_ulist = ["civbus", "CIV"] call x_getunitliste;
	sleep 0.131;
	if (count _list == 0) exitWith {};
	_vec = createVehicle [_ulist select 1, _start_pos, [], 0, "NONE"];
	if (count _list == 0) exitWith {
		deleteVehicle _vec;
	};
	
	call compile format ["x_civs_array_%1 = x_civs_array_%1 + [_vec];", _target_nr];
	
	__WaitForGroup
	_cgrp = ["CIV"] call x_creategroup;
	sleep 0.131;
	if (count _list == 0) exitWith {
		deleteGroup _cgrp;
	};
	_units = [_start_pos,(_ulist select 0),_cgrp] call x_makemgroup;
	call compile format ["x_civs_array_%1 = x_civs_array_%1 + _units;", _target_nr];
	(_units select 0) moveInDriver _vec;
	for "_xx" from 1 to (count _units - 1) do {
		(_units select _xx) moveInCargo _vec;
	};
	
	if (count _list == 0) exitWith {};
	
	_cgrp setBehaviour "CARELESS";
	_cgrp setCombatMode "BLUE";
	_grp_array = [_cgrp, _start_pos, 0,[_target_center,_radius],[],-1,0,[],5,0];
	_grp_array execVM "x_scripts\x_groupsm.sqf";
	sleep 0.131;
};

if (count _list == 0) exitWith {};

for "_i" from 1 to _ran_car do {
	_start_pos = [_target_center,_radius] call XfGetRanPointCircle;
	
	if (count _list == 0) exitWith {};
	
	_ulist = ["civcar", "CIV"] call x_getunitliste;
	sleep 0.131;
	if (count _list == 0) exitWith {};
	_vec = createVehicle [_ulist select 1, _start_pos, [], 0, "NONE"];
	if (count _list == 0) exitWith {
		deleteVehicle _vec;
	};
	
	call compile format ["x_civs_array_%1 = x_civs_array_%1 + [_vec];", _target_nr];
	
	__WaitForGroup
	_cgrp = ["CIV"] call x_creategroup;
	sleep 0.131;
	if (count _list == 0) exitWith {
		deleteGroup _cgrp;
	};
	_units = [_start_pos,(_ulist select 0),_cgrp] call x_makemgroup;
	call compile format ["x_civs_array_%1 = x_civs_array_%1 + _units;", _target_nr];
	(_units select 0) moveInDriver _vec;
	for "_xx" from 1 to (count _units - 1) do {
		(_units select _xx) moveInCargo _vec;
	};
	
	if (count _list == 0) exitWith {};
	
	_cgrp setBehaviour "CARELESS";
	_cgrp setCombatMode "BLUE";
	_grp_array = [_cgrp, _start_pos, 0,[_target_center,_radius],[],-1,0,[],5,0];
	_grp_array execVM "x_scripts\x_groupsm.sqf";
	sleep 0.131;
};

if (count _list == 0) exitWith {};

for "_i" from 1 to _ran_ped do {
	_start_pos = [_target_center,_radius] call XfGetRanPointCircle;
	
	if (count _list == 0) exitWith {};
	
	_ulist = ["civcity", "CIV"] call x_getunitliste;
	sleep 0.131;
	if (count _list == 0) exitWith {};
	
	__WaitForGroup
	_cgrp = ["CIV"] call x_creategroup;
	sleep 0.131;
	if (count _list == 0) exitWith {
		deleteGroup _cgrp;
	};
	_units = [_start_pos,(_ulist select 0),_cgrp] call x_makemgroup;
	call compile format ["x_civs_array_%1 = x_civs_array_%1 + _units;", _target_nr];
	
	if (count _list == 0) exitWith {};
	
	_cgrp setBehaviour "CARELESS";
	_cgrp setCombatMode "BLUE";
	_grp_array = [_cgrp, _start_pos, 0,[_target_center,_radius],[],-1,0,[],5,0];
	_grp_array execVM "x_scripts\x_groupsm.sqf";
	sleep 0.131;
};

if (true) exitWith {};
