//+++ Sygsky: create single patrol group for Rahmadi
// x_scripts\x_makegroup.sqf copied from x_createguardpatrolgroups.sqf by Xeno
private ["_grptype", "_wp_array", "_target_pos", "_numbervehicles", "_type", "_side", "_grp_in", "_vec_dir", "_center_rad", "_grpspeed", "_vehicles", "_grp", "_pos", "_unit_array", "_leader", "_fran", "_grp_array", "_one"];

#include "x_macros.sqf"

if !(isServer) exitWith{};

_grptype = _this select 0; // "basic", "specops" etc
_wp_array = _this select 1; // start positions array of point [[x1,y1,z1],[x2,y2,z2]...]
_target_pos = _this select 2; // attack position array [x1,y1,z1]
_numbervehicles = _this select 3; // > 0 only for tanks/cars/static etx, else 0 for a man group
_type = _this select 4; // "patrol", "guard" etc
_side = _this select 5; // side of group if create group
_grp_in = _this select 6; // group to assign to, not group (e.g. 0) if create first
_vec_dir = _this select 7; // vehicles start direction if vehicles group
_center_rad = (if (count _this > 8) then {_this select 8} else {[]});
_grpspeed = "LIMITED";
_vehicles = [];

if ((typeName _grp_in) != "GROUP") then {__WaitForGroup};
_grp = (if ((typeName _grp_in) != "GROUP") then {[_side] call x_creategroup} else {_grp_in});
_pos = (if (count _wp_array > 1) then {_wp_array select ((count _wp_array) call XfRandomFloor)} else {_wp_array select 0});

_unit_array = [_grptype, _side] call x_getunitliste;

//hint localize format["+++ x_scripts/x_makegroup.sqf _grptype %1, _numbervehicles %2, _unit_array %3, _type %4", _grptype, _numbervehicles, _unit_array, _type];

if (_numbervehicles > 0) then {
	_vehicles = [_numbervehicles, _pos, (_unit_array select 2), (_unit_array select 1), _grp, 0,_vec_dir,true] call x_makevgroup;
	_grp setSpeedMode _grpspeed;
} else {
	[_pos, (_unit_array select 0), _grp, true] call x_makemgroup;
};

sleep 1.011;

_leader = leader _grp;
_leader setRank "LIEUTENANT";
//if ((_unit_array select 1) in ["M2StaticMG","AGS","M119","D30"]) then { // TODO: set correct vehicle types for static. May be use _grptype except _unit_array ?
if ( _grptype in ["AGS","DSHKM","D30"]) then {
	_leader setSkill 1.0;
} else {
	_leader setSkill (d_skill_array select 0) + (random (d_skill_array select 1));
};
_unit_array = nil;
_fran = (floor random 3) + 1;
_grp allowFleeing (_fran / 10); // fleeing possibility from 0.1 to 0.3

if (d_suppression) then {[_grp] execVM "scripts\ROMM_IA.sqf";};

// TODO: replace 300 + (random 50) with real town boundary radius

switch (_type) do {
	case "patrol": {
		_grp_array = [_grp, _pos, 0,_center_rad,[],-1,0,[],300 + (random 50),0,[2]];
		_grp_array execVM "x_scripts\x_groupsm.sqf";
	};
	case "guard": {
		sleep 0.0123;
		_grp call XGuardWP;
		_grp_array = [_grp, _pos, 0,[],[],-1,0,[],300 + (random 50),-1];
		_grp_array execVM "x_scripts\x_groupsm.sqf";
	};
	case "guardvehicle": {
		_grp call XGuardWP;
		_wp = _grp addWaypoint [_pos, 10];
        _wp setWaypointType "GUARD";
	};
	case "guardstatic": {
		sleep 0.0123;
		_grp call XGuardWP;
		_grp_array = [_grp, _pos, 0,[],[],-1,0,[],300 + (random 50),-1];
		_grp_array execVM "x_scripts\x_groupsm.sqf";
	};
	case "guardstatic2": {
		_one = _vehicles select 0;
		_one setDir floor random 360;
	};
	case "attack": {
		[_grp, _target_pos] call XAttackWP;
	};
	case "attackwaves": {
		[_grp, _target_pos] call XAttackWP;
	};
};

_vehicles = nil;

if (true) exitWith {};