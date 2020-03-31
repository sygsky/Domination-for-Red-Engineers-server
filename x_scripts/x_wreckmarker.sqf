// by Xeno, x_scripts\x_wreckmarker.sqf. It is 1st time draw static destroy marker procedure, immediatelly after death of vehicle
// Logic:
// 1. Waits until vehicle is dead
// 2. On death creates wreck marker and wait while vehicle not null and distance from vdead vehicle to marker origin is <= 30 m
// 3. Remove marker and do: _vehicle execVM "x_scripts\x_wreckmarker2.sqf";
// 4. exit!!!!! So it is only initiate marker procedure only

private ["_vehicle", "_mname", "_sav_pos", "_type_name", "_marker", "_i", "_element", "_str"];
if (!isServer) exitWith {};
#include "x_setup.sqf"
#include "x_macros.sqf"
_vehicle = _this;

//+++++++++++++++++++++++++++++++++++++++++
// Wait until vehicle is dead
while {alive _vehicle} do {sleep (5.532 + random 2.2)};
// TODO: add message sound about heli fatum if at water
while {speed _vehicle > 4} do {sleep (1.532 + random 2.2)};
sleep 0.01;

// #347.1: Падающую в море, на глубину более N метров, любого рода технику сразу уничтожать.
_type_name = [typeOf (_vehicle),0] call XfGetDisplayName;

hint localize format["+++ x_wreckmarker.sqf: %1 in water %2, on depth %3, restorable!", _type_name, surfaceIsWater (getPos _vehicle), round ((_vehicle modelToWorld [0,0,0]) select 2)];

if ((vectorUp _vehicle) select 2 < 0) then {_vehicle setVectorUp [0,0,1]};
while {speed _vehicle > 4} do {sleep (0.532 + random 1)};

_mname = format ["%1", _vehicle];
_sav_pos = position _vehicle;
_str = format [localize "STR_MIS_18", _type_name];

hint localize format["+++ x_wreckmarker.sqf: marker title ""%1""", _str] ;

[_mname, _sav_pos,"ICON","ColorBlue",[1,1], _str, 0, "DestroyedVehicle"] call XfCreateMarkerGlobal; // "%1 wreck", variable _marker is assigned in call of XfCreateMarkerGlobal function
d_wreck_marker set [ count d_wreck_marker, [ _mname, _sav_pos, _type_name ] ];

if ((surfaceIsWater (getPos _vehicle)) ) then {
    // the vehicle didn't sink deep enough
    ["msg_to_user", "", [["STR_SYS_630_1", _type_name]],0,12 + (random 10),0,"good_news"] call XSendNetStartScriptClientAll; // message output
};

_sunk = false;
while { (!isNull _vehicle) && (_vehicle distance (markerPos _marker) < 30) && (!_sunk) } do {

    sleep (3.321 + random 2.2);

    if ( ( surfaceIsWater (getPos _vehicle) ) ) then {
        if ( ( vectorUp _vehicle ) select 2 < 0 ) then { _vehicle setVectorUp [0,0,1]; };
        while {speed _vehicle > 4} do {sleep (0.532 + random 1)};
        _sunk = ( (_vehicle modelToWorld [0,0,0]) select 2 ) < -7; // it sunk!!!
    };
};

// remove permanent marker at wreckage place
for "_i" from 0 to (count d_wreck_marker - 1) do {
	_element = d_wreck_marker select _i;
	if ((_element select 0) == _mname && (format ["%1",(_element select 1)] == format ["%1",_sav_pos])) exitWith {
		d_wreck_marker set [_i, "X_RM_ME"];
	};
};
deleteMarker _marker;

if (_sunk) exitWith {
    // remove vehicle, add lost marker and remove it after 2 minutes
    hint localize format["+++ x_wreckmarker.sqf: %1 in water on depth %2, not restorable!", _type_name, round ((_vehicle modelToWorld [0,0,0]) select 2)];
    ["msg_to_user", "", [["STR_SYS_630", _type_name, round ((_vehicle modelToWorld [0,0,0]) select 2)]],0,12 + (random 10),0,"under_water_3"] call XSendNetStartScriptClientAll; // message output
    _sav_pos = position _vehicle;
    [_mname, _sav_pos,"ICON","ColorBlue",[0.5,0.5],format [localize "STR_MIS_18_1", _type_name],0,"Marker"] call XfCreateMarkerGlobal; // "wreck %1, deep", _marker is assigned in call of XfCreateMarkerGlobal function
    [ _vehicle ] call XAddCheckDead;
    {
        if ( count _x > 1) then {_marker setMarkerColor (_x select 1)};
        if ( typeName _x == "ARRAY") then { _x = _x select 0 };
        sleep _x;
    } forEach [40, [40,"ColorRed"],[40, "ColorRedAlpha"]];
    deleteMarker _marker;
};

d_wreck_marker = d_wreck_marker - ["X_RM_ME"];
_vehicle execVM "x_scripts\x_wreckmarker2.sqf";
if (true) exitWith {};