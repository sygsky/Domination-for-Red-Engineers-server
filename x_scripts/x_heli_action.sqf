// by Xeno, x_scripts\x_heli_action.sqf, called client computer
private ["_vehicle","_caller","_id"];

_vehicle = _this select 0;
_caller = _this select 1;
_id = _this select 2;

if (_caller == driver _vehicle) then {
	_vehicle removeAction _id;
	Vehicle_Attached = true;	
};

if (true) exitWith {};
