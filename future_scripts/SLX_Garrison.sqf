/*
    Converted from SQS to SQF (Arma 1 compatible)
    Original purpose: Garrisons AI squad in nearby buildings
    Params:
    [_group, _tg] execVM "garrison_sqf"
*/

private ["_group", "_tg", "_grpcnt", "_building", "_garrisoned", "_inside_arr", "_i", "_spotnum", "_units", "_unit", "_pos", "_wait", "_dir"];

_group = _this select 0;
_tg = _this select 1;

// Debug output
if (format["%1",SLX_Debug] != SLX_Null) then {
    if (isNil  "garrison_sqf") then {garrison_sqf = 0};
    garrison_sqf = garrison_sqf + 1;
    hint localize format["+++ garrison_sqf %1 %2", garrison_sqf, _this select 0];
};

SLX_Busy = SLX_Busy + [_group];

// If target group is not defined, use current group
if (format["%1",_tg] == SLX_Null) then {_tg = _group};

_grpcnt = (count (units _tg)) - 1;
_building = objNull;
_garrisoned = [];
_inside_arr = [];

// Main garrison logic
_i = 0;
_spotnum = 40;

// Find suitable buildings
while {_i <= _grpcnt} do {
    _unit = ((units _tg) select _i);
    _building = nearestBuilding _unit;
    _i = _i + 1;
    
    if (!(_building in _garrisoned)) then {
        if (!(isNull _building) && {_building distance (leader _group) <= 200}) then {
            // Set group behavior
            _group setBehaviour "AWARE";
            _group setCombatMode "YELLOW";
            _group setSpeedMode "FULL";
            
            _units = units _group;
            if ((count _units) > 3) then {
                [_units, "move"] exec (SLX_GL3_path+"Shout.sqf");
            };
            
            _garrisoned = _garrisoned + [_building];
            
            // Garrison units in building
            _spotnum = 40;
            _grpcnt = (count _units) - 1;
            
            while {_grpcnt >= 0 && _spotnum >= 0} do {
                _unit = _units select _grpcnt;
                _grpcnt = _grpcnt - 1;
                
                if (alive _unit && {!(vehicle _unit != _unit)} && {!(_unit in _inside_arr)}) then {
                    _pos = _building buildingPos _spotnum;
                    _spotnum = _spotnum - 1;
                    
                    // Skip invalid positions
                    while {_spotnum > 0 && {(_pos select 0 == 0) && (_pos select 1 == 0) && (_pos select 2 == 0)}} do {
                        _pos = _building buildingPos _spotnum;
                        _spotnum = _spotnum - 1;
                    };
                    
                    if !((_pos select 0 == 0) && (_pos select 1 == 0) && (_pos select 2 == 0)) then {
                        _inside_arr = _inside_arr + [_unit];
                        _unit doMove _pos;
                        sleep 3;
                    };
                };
            };
        };
    };
    sleep 0.01;
};

// Wait for units to complete movement
_wait = 20;
while {_wait > 0} do {
    {
        if ((unitReady _x) || (isNull _x) || !(alive _x) || _wait <= 0) then {
            if (unitReady _x) then {
                doStop _x;
                _dir = ((getPos _building select 0) - (getPos _x select 0)) atan2 ((getPos _building select 1) - (getPos _x select 1));
                _dir = _dir + 180;
                _pos = [(getPos _x select 0) + 75*sin(_dir), (getPos _x select 1) + 75*cos(_dir), 3];
                _x doWatch _pos;
            };
            _x setUnitPos "AUTO";
            _inside_arr = _inside_arr - [_x];
        };
    } forEach _inside_arr;
    
    _wait = _wait - 1;
    sleep 2;
};

// Cleanup
SLX_Busy = SLX_Busy - [_group];

// Debug output
if (format["%1",SLX_Debug] != SLX_Null) then {
    if (format["%1",garrison_sqf] == SLX_Null) then {garrison_sqf = 0};
    garrison_sqf = garrison_sqf - 1;
    hint localize format["+++ garrison_sqf %1 %2", garrison_sqf, _this select 0];
};