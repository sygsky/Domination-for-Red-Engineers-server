// by Xeno, x_scripts\x_civsremove.sqf
private ["_target_nr","_tarray","_target","_target_center","_radius"];
if (!isServer) exitWith {};

_target_nr = _this select 0;

_tarray = call compile format ["x_civs_array_%1",_target_nr];

if (count _tarray > 0) then {
	{
		if (!isNull _x) then {
			if (_x isKindOf "Car") then {
				_grp = grpNull;
				{if (_x isKindOf "Man") then {_grp = group _x}; deleteVehicle _x} forEach [_x] + crew _x;
				if (!isNull _grp) then {deleteGroup _grp};
			} else {
				_grp = group _x;
				deleteVehicle _x;
				if (!isNull _grp) then {deleteGroup _grp};
			};
		};
	} forEach _tarray;	
	_tarray = [];
};

call compile format ["x_civs_array_%1 = [];",_target_nr];

// search for casually not removed cars by std means
_target = target_names select _target_nr;
_target_center = _target select 0;
_radius = _target select 2;
// find all cars and buses in the current town
_tarray = nearestObjects [_target_center, d_civ_cars + ["Bus_city"], _radius + 100];
if (count _tarray > 0) then {
    private ["_grp","_cnt"];
    _cnt = 0; // man in cars counter
    {
        _grp = grpNull;
        {if (_x isKindOf "Man") then { _grp = group _x; _cnt = _cnt + 1 }; deleteVehicle _x} forEach [_x] + crew _x;
        if (!isNull _grp) then {deleteGroup _grp};
    } forEach _tarray;
    hint localize format["--- x_civsremove.sqf: town %1, lost civ %2 vehicles and %3 men were removed", _target select 1, count _tarray, _cnt];
};

if (true) exitWith {};
