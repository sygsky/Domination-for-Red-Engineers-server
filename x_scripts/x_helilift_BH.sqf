// x_helilift.sqf, by Xeno. Called on client computer only for BH heli lift type
#ifdef __TT__
    if (true) exitWith{false};
#endif
#ifndef __ACE__
    if (true) exitWith{false};
#endif
#ifdef __OWN_SIDE_WEST__
    if (true) exitWith{false};
#endif

private ["_vehicle", "_menu_lift_shown", "_nearest", "_id", "_possible_types", "_pos", "_nobjects", "_dummy", "_nearest_pos", "_nx", "_ny", "_px", "_py", "_release_id", "_height", "_vup", "_vdir", "_npos", "_fheight"];

if (!X_Client) exitWith {};

#include "x_setup.sqf"

_vehicle = _this select 0; // heli to lift with

Vehicle_Attached = false;
Vehicle_Released = false;
Attached_Vec = objNull;
_menu_lift_shown = false;
_nearest = objNull;
_id = -1;

sleep 10.123;

_possible_types = SYG_HELI_BIG_LIST_ACE_W + SYG_HELI_LITTLE_LIST_ACE_W;

while {(alive _vehicle) && (alive player) && (vehicle player == _vehicle)} do {
    _pos = getPos _vehicle;

    if ( (!Vehicle_Attached) && (_pos select 2 > 2.5) && (_pos select 2 < 11) ) then {
        _nearest = objNull;
        _nobjects = nearestObjects [_vehicle, ["Air"],40];
        if (count _nobjects > 0) then {
            _dummy = _nobjects select 0;
            if (_dummy == _vehicle) then {
                if (count _nobjects > 1) then {
                    _nearest = _nobjects select 1;
                };
            } else {
                _nearest = _dummy;
            };
        };
        sleep 0.1;
        if (!(isNull _nearest) && _nearest != Attached_Vec && (((typeOf _nearest) in _possible_types))) then {
            _nearest_pos = getPos _nearest;
            _nx = _nearest_pos select 0;_ny = _nearest_pos select 1;_px = _pos select 0;_py = _pos select 1;
            if ((_px <= _nx + 10 && _px >= _nx - 10) && (_py <= _ny + 10 && _py >= _ny - 10)) then {
                if (!_menu_lift_shown) then {
                    _id = _vehicle addAction [ localize "STR_SYS_35", "x_scripts\x_heli_action.sqf",-1,100000]; // "Поднять технику"
                    _menu_lift_shown = true;
                };
            } else {
                _nearest = objNull;
                if (_menu_lift_shown) then {
                    _vehicle removeAction _id;
                    _menu_lift_shown = false;
                };
            };
        };
    } else {
        if (_menu_lift_shown) then {
            _vehicle removeAction _id;
            _menu_lift_shown = false;
        };

        sleep 0.1;

        if (isNull _nearest) then {
            Vehicle_Attached = false;
            Vehicle_Released = false;
        } else {
            if (Vehicle_Attached) then {

                // ++ Sygsky: checking again legal type of vehicle to lift here

                if ((typeOf _nearest) in _possible_types) then {
                    //hint localize format["+++ x_helilift.sqf: vehicle %1 lifted", typeOf _nearest];
                    _release_id = _vehicle addAction [ localize "STR_SYS_36", "x_scripts\x_heli_release.sqf",-1,100000]; //"Сбросить технику"
					[_vehicle, format[localize "STR_SYS_37",[typeOf (_nearest),0] call XfGetDisplayName]] call XfVehicleChat;
                    Attached_Vec = _nearest;

                    _height = 15;
                    while {alive _vehicle && player_is_driver && alive _nearest && alive player && !Vehicle_Released} do {
                        _vup = vectorUp _vehicle;
                        _vdir = vectorDir _vehicle;
                        _voffset = (speed _vehicle min 50) / 3.57;
                        _fheight = _height + (2.5 min (_vehicle modelToWorld [0,-1-_voffset,-_height] select 2));
                        _nearest_pos = _vehicle modelToWorld [0,-1-_voffset,-_fheight];
                        _nearest setPos _nearest_pos;
                        _nearest setVectorDir _vdir;
                        _nearest setVectorUp  _vup;
                        _nearest setVelocity [0,0,0];
                        sleep 0.001;
                    };
                    _nearest engineOn false;
                    _nearest setVelocity (velocity _vehicle);  //+++ Sygsky - let vehicle to inertially fly ahead some distance
                    hint localize format["+++ x_helilift.sqf: velocity on drop %1 was %2 m/s", typeOf _nearest, (velocity _vehicle) distance [0,0,0]];
                    Vehicle_Attached = false;
                    Vehicle_Released = false;

                    Attached_Vec = objNull;

                    if (!alive _vehicle) then {
                        _vehicle removeAction _release_id;
                    } else {
                        [_vehicle, localize "STR_SYS_39"] call XfVehicleChat; //"Техника сброшена..."
                    };

                    if ((position _nearest) select 2 < 20) then {
                        waitUntil {(position _nearest) select 2 < 10};
                    };

                    sleep 1.012;
                    _npos = position _nearest;
                    _nearest setPos [_npos select 0, _npos select 1, 0];
                    _nearest setVelocity [0,0,0];
                    if ( isEngineOn _nearest ) then { _nearest engineOn false; };
                }
                else // vehicle not in legal list
                {

                    //++ Sygsky: found that vehicle ready to lift not in legal list! Clear possible activity and report user about
                    [_vehicle, localize "STR_SYS_38"] call XfVehicleChat; //"Техника слишком тяжела..."
                    Vehicle_Attached = false;
                    Vehicle_Released = false;
                };
            };
        };
    };
	sleep 0.51;
};

player_is_driver = false;
_vehicle removeAction vec_id;


if (true) exitWith {};