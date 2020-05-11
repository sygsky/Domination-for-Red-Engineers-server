// by Xeno, x_scripts\x_civsremove.sqf
if (!isServer) exitWith {};

private ["_target_nr","_tarray","_target","_target_center","_radius"];

_target_nr = _this select 0;

_tarray = call compile format ["x_civs_array_%1",_target_nr];
_cnt = count _tarray;
_groups = [];
if (_cnt > 0) then {
	{
		if (!isNull _x) then {
			if (_x isKindOf "Car") exitWith {
//				_grp = grpNull;
				{
				    if (_x isKindOf "Man") then {
				        _grp = group _x;
                        if (!_gpr in _groups) then {_groups set [count _groups, _grp]};
				    };
				    deleteVehicle _x;
				} forEach [_x] + crew _x;
//				if (!isNull _grp) then {deleteGroup _grp};
			};
            // it is a man
            _grp = group _x;
            if (!_gpr in _groups) then {_groups set [count _groups, _grp]};
            deleteVehicle _x;
//            if (!isNull _grp) then {deleteGroup _grp};
		};
	} forEach _tarray;	
	_tarray = [];
};
call compile format ["x_civs_array_%1 = [];",_target_nr];
_gcnt  = count _groups;
sleep 2;
{deleteGroup _x }forEach _groups;

//==============================================================================================================

// search for casually not removed cars by std means
_target = target_names select _target_nr;
_target_center = _target select 0;
_radius = _target select 2;

// find all cars and buses in the current town
_tarray1 = nearestObjects [_target_center, d_civ_cars + ["Bus_city"], _radius + 100];
_cnt1 = 0; // man in cars counter
if (count _tarray1 > 0) then {
    _groups = [];
    private ["_grp"];
    {
        _grp = grpNull;
        {
            if ( _x isKindOf "Man") then {
                _grp = group _x;
                if (!_gpr in _groups) then {_groups set [count _groups, _grp]};
                _cnt1 = _cnt1 + 1;
            };
            deleteVehicle _x;
        } forEach [_x] + crew _x;
//        if (!isNull _grp) then {deleteGroup _grp};
    } forEach _tarray1;
    sleep 2;
    {deleteGroup _x }forEach _groups;
    _groups = [];
    _tarray1 = [];
};

// remove accidentally not deleted civilian pedestrians
_tarray2 = _target_center nearObjects ["Civilian", _radius + 100];
_cnt2 = 0; // man in cars counter
if (count _tarray2 > 0) then {
    _groups = [];
    private ["_type","_arr"];
    {
        _arr = toArray (typeOf _x);
        _arr resize 8; // Length of "Civilian" is 8
        _type  = toString _arr;
        if ( toUpper (_type) == "CIVILIAN" ) then {
            _cnt2 = _cnt2 + 1 ;
            _grp = group _x;
            if (!_gpr in _groups) then {_groups set [count _groups, _grp]};
            deleteVehicle _x;
        };
    } forEach _tarray2;
    sleep 2;
    {deleteGroup _x }forEach _groups;
    _groups = [];
    _tarray2 = [];
};
hint localize format["+++ x_civsremove.sqf: town %1, x_civs_array_%2[%3] groups %4, removed lost civs %5 vehicles, %6 crew, %7/%8 pedestrians",
    _target select 1, _target_nr, _cnt, _gcnt, count _tarray, _cnt1, _cnt2, count _tarray2];

if (true) exitWith {};
