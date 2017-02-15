// by Xeno
private ["_target_nr","_tarray"];
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

if (true) exitWith {};
