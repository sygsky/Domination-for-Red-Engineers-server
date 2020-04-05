// by Xeno, x_scripts\x_wreckmarker.sqf. Runs on server only.
// It is 1st time draw static destroy marker procedure, immediatelly after death of vehicle
// Logic:
// 1. Waits until vehicle is dead
// 2. On death creates wreck marker and wait while vehicle not null and distance from vdead vehicle to marker origin is <= 30 m
// 3. Remove marker and do: _vehicle execVM "x_scripts\x_wreckmarker2.sqf";
// 4. exit!!!!! So it is only initiate marker procedure only

if (!isServer) exitWith {};

#define DEPTH_TO_SINK -7 // when vehicle considered to have sunk
#define __PRINT__

private ["_vehicle", "_mname", "_sav_pos", "_type_name", "_marker", "_i", "_element", "_str","_msg_time","_msg_delay",
        "_time_stamp", "_time", "_part"];
#include "x_setup.sqf"
#include "x_macros.sqf"
_vehicle = _this;

//+++++++++++++++++++++++++++++++++++++++++
// Wait until vehicle is dead
while {alive _vehicle} do {sleep (5.532 + random 2.2)};

while {speed _vehicle > 4} do {sleep (1.532 + random 2.2)};
sleep 0.01;

_type_name = [typeOf (_vehicle),0] call XfGetDisplayName;

#ifdef __PRINT__
hint localize format["+++ x_wreckmarker.sqf: script start with %1, in water %2, height %3", _type_name, surfaceIsWater (getPos _vehicle), round ((_vehicle modelToWorld [0,0,0]) select 2)];
#endif

if ((vectorUp _vehicle) select 2 < 0) then {_vehicle setVectorUp [0,0,1]};
while {speed _vehicle > 4} do {sleep (0.532 + random 1)};

_mname = format ["%1", _vehicle];
_sav_pos = position _vehicle;
_str = format [localize "STR_MIS_18", _type_name];

#ifdef __PRINT__
_time_stamp = time;
hint localize format["+++ x_wreckmarker.sqf(0): marker title ""%1""", _str] ;
#endif

[_mname, _sav_pos,"ICON","ColorBlue",[1,1], _str, 0, "DestroyedVehicle"] call XfCreateMarkerGlobal; // "%1 wreck", variable _marker is assigned in call of XfCreateMarkerGlobal function
d_wreck_marker set [ count d_wreck_marker, [ _mname, _sav_pos, _type_name ] ];

// #347.1: Падающую в море, на глубину более N метров, любого рода технику сразу уничтожать.
_msg_time = time;
if ((surfaceIsWater (getPos _vehicle)) ) then {
    // the vehicle didn't sink deep enough
    _msg_delay = 12 + (random 10);
    ["msg_to_user", "", [["STR_SYS_630_1", _type_name]],0,_msg_delay,0,"good_news"] call XSendNetStartScriptClientAll; // message output
    _msg_time = time + _msg_delay;
};

_sunk = false;
while { (!isNull _vehicle) && (([_vehicle, (markerPos _marker)] call SYG_distance2D) < 30) && (!_sunk) } do {

    sleep (3.321 + random 2.2);

    if ( ( surfaceIsWater (getPos _vehicle) ) ) then {
        if ( ( vectorUp _vehicle ) select 2 < 0 ) then { _vehicle setVectorUp [0,0,1]; };
        while {speed _vehicle > 4} do {sleep (0.532 + random 1)};
        _sunk = ( (_vehicle modelToWorld [0,0,0]) select 2 ) < DEPTH_TO_SINK; // it sunk!!!
    };
};

// remove permanent marker at wreckage place
if (count d_wreck_marker > 0) then {
    for "_i" from 0 to (count d_wreck_marker - 1) do {
        _element = d_wreck_marker select _i;
        if (typeName _element == "ARRAY") then {
            if ((_element select 0) == _mname && (format ["%1",(_element select 1)] == format ["%1",_sav_pos])) exitWith {
                d_wreck_marker set [_i, "X_RM_ME"];
            };
        }
    };
};
d_wreck_marker = d_wreck_marker - ["X_RM_ME"];
deleteMarker _marker;

if (_sunk) then {
    // remove vehicle, add lost marker and remove it after time designated in this code section
#ifdef __PRINT__
    hint localize format["+++ x_wreckmarker.sqf(%1): %2 in water on depth %3, sunk!", round(time - _time_stamp), _type_name, round ((_vehicle modelToWorld [0,0,0]) select 2)];
#endif
    _msg_time  = (_msg_time max time) + 6 + (random 8);
    _msg_delay = _msg_time - time;
    ["msg_to_user", "", [["STR_SYS_630", _type_name, round ((_vehicle modelToWorld [0,0,0]) select 2)]],0, _msg_delay ,0,"under_water_3"] call XSendNetStartScriptClientAll; // message output
    _depth = round((_vehicle modelToWorld [0,0,0]) select 2);
    [_mname, position _vehicle,"ICON","ColorBlue",[0.5,0.5],format [localize "STR_MIS_18_1", _type_name, _depth,"" ],0,"Marker"] call XfCreateMarkerGlobal; // "wreck %1, deep %2 m.%3", _marker is assigned in call of XfCreateMarkerGlobal function
    [ _vehicle ] call XAddCheckDead;
    _timer_start = time;

    // make marker text to be dynamic, with decreasing seconds counter of remain existance
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // +++ BASE <-> Mercallilo for a distance 3754 m 300 seconds are required
    _dist = round ([FLAG_BASE, _vehicle] call SYG_distance2D);
    _time = ceil (((300 * _dist / (3754 / 2)) + 30) / 60); // new time in minutes, simplest formula: 100 seconds per 1 kilometers
    _part = (_time * 0.2) max 1.0; // one part in minutes
    _marker_stage_arr = [ round(_part  * 60), [round(_part * 120), "ColorRed"], [round(_part * 120), "ColorRedAlpha"] ];
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    _back_counter = 0;
    {
        if ( typeName _x == "ARRAY") then { _x = _x select 0; };
        _back_counter = _back_counter + _x;
    } forEach _marker_stage_arr;

    {
        if ( typeName _x == "ARRAY") then {
            if ( count _x > 1) then {_marker setMarkerColor (_x select 1)};
            _x = _x select 0; // prepare sleep period value
        };

        _exit = false;
        for "_i" from 1 to _x do
        {
            sleep 1;
            _back_counter = _back_counter -1;
            _marker setMarkerText format [localize "STR_MIS_18_1", _type_name, _depth, format[" (%1)", _back_counter] ];

            // check any changes in marked vehicle status
            // if vehilce is deleted from meory
            if ( isNull _vehicle ) exitWith{
            #ifdef __PRINT__
                hint localize format[ "+++ x_wreckmarker.sqf(%1): %2 isNull, exit", round(time - _time_stamp), _type_name ];
            #endif
            #ifdef __ACE__
                _marker setMarkerType  "ACE_Icon_SoldierDead"; // mark dead player as skull
            #endif
                _marker setMarkerText format [localize "STR_MIS_18_1", _type_name, _depth, localize "STR_MIS_18_2"] ;
                sleep 5; // last farewell to sunk vehicle
                _exit = true;
            }; // the vehicle removed
            // if vehicle moved (by user may be)
            if (([_vehicle, (markerPos _marker)] call SYG_distance2D) > 30) exitWith {
            #ifdef __PRINT__
                hint localize format[ "+++ x_wreckmarker.sqf(%1): %2 moved from marker, goto x_wreckmarker2.sqf", round(time - _time_stamp), _type_name ];
            #endif
                _sunk = false;
                _exit = true;
            }; // the vehicle moved

        };
        if (_exit) exitWith{};

    } forEach _marker_stage_arr;

    if ( !isNull _vehicle && _sunk ) then {
#ifdef __PRINT__
        hint localize format[ "+++ x_wreckmarker.sqf(%1): deleteVehicle %2 after marker dynamic loop finished", round(time - _time_stamp), _type_name ];
#endif
        deleteVehicle _vehicle;
    };
    deleteMarker _marker; // remove lost marker
};

if (_sunk) exitWith{}; // that's all, vehicle lost permanently

d_wreck_marker = d_wreck_marker - ["X_RM_ME"];
_vehicle execVM "x_scripts\x_wreckmarker2.sqf";
if (true) exitWith {};