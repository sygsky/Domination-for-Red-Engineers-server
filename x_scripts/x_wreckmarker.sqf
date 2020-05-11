// by Xeno, x_scripts\x_wreckmarker.sqf. Runs on server only.
// It is 1st time draw static destroy marker procedure, immediatelly after death of vehicle
// Logic:
// 1. Waits until vehicle is dead
// 2. On death creates wreck marker and wait while vehicle not null and distance from vdead vehicle to marker origin is <= 30 m
// 3. Remove marker and do: _vehicle execVM "x_scripts\x_wreckmarker2.sqf";
// 4. exit!!!!! So it is only initiate marker procedure only

if (!isServer) exitWith {};

#define DEPTH_TO_SINK -1 // when vehicle considered to have sunk
#define RIP_MARKER_TIME -5 // how long to show rip marker after vehicle is set to null
#define RIP_MARKER_LIVE_PERIOD (6 * 3600) // 6 hours
// #define RIP_MARKER_LIVE_PERIOD (6 * 60) // 6 minutes for DEBUG purposes

#define __PRINT__

private ["_vehicle", "_mname", "_sav_pos", "_type_name", "_marker", "_i", "_element", "_str","_msg_time","_msg_delay",
        "_time_stamp", "_time", "_part","_depth","_driver", "_drname", "_local"];
#include "x_setup.sqf"
#include "x_macros.sqf"

_vehicle = _this;
_local   = local _vehicle;
_driver  = driver _vehicle;
//+++++++++++++++++++++++++++++++++++++++++
// Wait until vehicle is dead
while {alive _vehicle} do { if ( alive driver _vehicle) then {_driver = driver _vehicle}; sleep (5.532 + random 2.2)};
_drname = "";
if (!isNull _driver ) then {
    if (!isPLayer _driver) then { _driver = leader _driver;}; // try to penalize leader of AI
    if (isPlayer _driver) exitWith {
        _drname = name _driver;
        if (_drname in ["Error: No vehicle", "Error: No unit"]) then { _drname = ""}; // no name
    };
};

while {speed _vehicle > 4} do {sleep (1.532 + random 2.2)};
sleep 0.01;

_type_name = [typeOf (_vehicle),0] call XfGetDisplayName;

#ifdef __PRINT__
hint localize format[ "+++ x_wreckmarker.sqf: script for %1, in water %2, Z %3, driver %4, vectorUp %5, local %6",
    _type_name,
    surfaceIsWater (getPos _vehicle),
    round ((_vehicle modelToWorld [0,0,0]) select 2),
    if (isNull _driver) then {"null"} else {name _driver},
    vectorUp _vehicle,
    _local
    ];
#endif

if ((vectorUp _vehicle) select 2 < 0) then {_vehicle setVectorUp [0,0,1]};
while {speed _vehicle > 4} do {sleep (0.532 + random 1)};
if ((vectorUp _vehicle) select 2 < 0) then {_vehicle setVectorUp [0,0,1]};

_mname = format ["%1", _vehicle];
_sav_pos = position _vehicle;
_str = format [localize "STR_MIS_18", _type_name];

#ifdef __PRINT__
_time_stamp = time;
hint localize format["+++ x_wreckmarker.sqf(0): marker title ""%1""", _str] ;
#endif

[_mname, _sav_pos,"ICON","ColorBlue",[1,1], _str, 0, "DestroyedVehicle"] call XfCreateMarkerGlobal; // "%1 wreck", variable _marker is assigned in call of XfCreateMarkerGlobal function
d_wreck_marker set [ count d_wreck_marker, [ _mname, _sav_pos, _type_name ] ];


// #347.1: Inform user about vehicle being in water
_msg_time = time;
if ((surfaceIsWater (getPos _vehicle)) ) then {
    // the vehicle didn't sink deep enough
    _msg_delay = 12 + (random 10);
    ["msg_to_user", "", [["STR_SYS_630_1", _type_name]],0,_msg_delay,0,"good_news"] call XSendNetStartScriptClientAll; // "The lost %1 can still be restored if it is delivered to the appropriate service!"
    _msg_time = time + _msg_delay;
};

_sunk = false;
while { (!isNull _vehicle) && (([_vehicle, (markerPos _marker)] call SYG_distance2D) < 30) && (!_sunk) } do {
    sleep (3.321 + random 2.2);
    if ( ( surfaceIsWater (getPos _vehicle) ) ) exitWith {
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
_depth = 0;
if ( _sunk ) then {
    // remove vehicle, add lost marker and remove it after time designated in this code section
#ifdef __PRINT__
    hint localize format["+++ x_wreckmarker.sqf(%1): %2 in water on depth %3, sunk!", round(time - _time_stamp), _type_name, round ((_vehicle modelToWorld [0,0,0]) select 2)];
#endif
    _msg_time  = (_msg_time max time) + 6 + (random 8);
    _msg_delay = _msg_time - time;
    ["msg_to_user", "", [["STR_SYS_630", _type_name, round ((_vehicle modelToWorld [0,0,0]) select 2)]],0, _msg_delay ,0,"under_water_3"] call XSendNetStartScriptClientAll; // message output
    _msg_time = time + _msg_delay;
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
        // change marker
        if ( typeName _x == "ARRAY") then {
            if ( count _x > 1) then {_marker setMarkerColor (_x select 1)};
            _x = _x select 0; // prepare sleep period value
        };

        // change marker timer
        for "_i" from 1 to _x do
        {
            sleep 1;
            _back_counter = (_back_counter - 1) max 0;
            _depth = round((_vehicle modelToWorld [0,0,0]) select 2); // Error #372 (update depth of vehicle)
            _marker setMarkerText format [localize "STR_MIS_18_1", _type_name, _depth, format[localize "STR_MIS_18_3", _back_counter] ];

            // check any changes in marked vehicle status

            if ( isNull _vehicle ) exitWith{ // vehicle is deleted from memory, mark it for 5 seconds and exit
                #ifdef __PRINT__
                hint localize format[ "+++ x_wreckmarker.sqf(%1): %2 isNull, exit", round(time - _time_stamp), _type_name ];
                #endif
                #ifdef __ACE__
                _marker setMarkerType  "ACE_Icon_SoldierDead"; // mark dead player as skull
                #endif
                _marker setMarkerText format [localize "STR_MIS_18_1", _type_name, _depth, localize "STR_MIS_18_2"] ;
                sleep RIP_MARKER_TIME; // last farewell to sunk vehicle
                _sunk = false;
            }; // the vehicle removed
            // if vehicle moved (by user may be)
            if (([_vehicle, (markerPos _marker)] call SYG_distance2D) > 30) exitWith {
            #ifdef __PRINT__
                hint localize format[ "+++ x_wreckmarker.sqf(%1): %2 moved from marker, goto x_wreckmarker2.sqf", round(time - _time_stamp), _type_name ];
            #endif
                _sunk = false;
            }; // the vehicle moved
        };
        if ( !_sunk ) exitWith{};
    } forEach _marker_stage_arr;

    if ( !isNull _vehicle && _sunk ) then {  // end of timer, user not get sunken vehicle
#ifdef __PRINT__
        hint localize format[ "+++ x_wreckmarker.sqf(%1): deleteVehicle %2 after marker dynamic loop finished", round(time - _time_stamp), _type_name ];
#endif
        deleteVehicle _vehicle;
    };
    sleep 0.5;

    if ( _sunk ) exitWith {

        if (_drname != "") then { // remove marker later
            // rename marker with bad boy name and keep it for predefined period
            [_marker, format[localize "STR_MIS_18_BAD", _type_name, _drname, _depth ]] spawn {
                (_this select 0) setMarkerText (_this select 1);
                sleep RIP_MARKER_LIVE_PERIOD;
                deleteMarker (_this select 0);
            };
        } else { deleteMarker _marker;};   // remove marker now

        if ( isNull _vehicle ) then { // vehicle is deleted from memory, mark it for 5 seconds and exit
            _msg_time  = (_msg_time max time) + 6;
            _msg_delay = _msg_time - time;
            ["msg_to_user", "", [["STR_SYS_630_2", _type_name, "STR_SYS_630_2_NUM" call SYG_getRandomText]],0, _msg_delay,0,"under_water_3"] call XSendNetStartScriptClientAll; // message output
        };
    };
};

if (_sunk) exitWith{}; // that's all, vehicle lost permanently

if (!_sunk) then { deleteMarker _marker; }; // remove sunk marker
d_wreck_marker = d_wreck_marker - ["X_RM_ME"];
_vehicle execVM "x_scripts\x_wreckmarker2.sqf";
if (true) exitWith {};