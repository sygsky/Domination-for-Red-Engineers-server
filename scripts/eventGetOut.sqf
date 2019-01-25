/*
	author: Sygsky
	description: none
	returns: nothing

	Triggered when a unit exits the object (only useful when the event handler is assigned to a vehicle).
	It does not trigger upon a change of positions within the same vehicle.

    Global.

    Passed array: [vehicle, role, unit]

    vehicle: Object - Vehicle the event handler is assigned to
    role:    String - Can be either "driver", "gunner", "commander" or "cargo"
    unit:    Object - Unit that exit the vehicle
*/
//#define __DEBUG__
#ifdef __DEBUG__

X_MP = true;
XPlayersNumber = {0};

#endif

if (X_MP && (call (XPlayersNumber) > 0) ) exitWith {false}; // only work in absence of any player

#include "x_setup.sqf"

#ifdef __TT__
if (true) exitWith {false};
#endif

_veh  = _this select 0;
_veh removeAllEventHandlers "GetOut"; // prevent multiple event firing

if ( (_veh isKindOf "Air") || (_veh isKindOf "Ship")) exitWith
{
    hint localize format["--- eventGetOut: call on invalid vehicle type %1, exit", typeOf _veh];
};

// still only for land vehicles

_role = _this select 1;
_man = _this select 2;
hint localize format["--- eventGetOut: params %1, %2, %3", typeOf _veh, _role, typeOf _man];

_crewtype = typeOf _man; //"SoldierWB";

if ( !alive _veh ) exitWith {false}; // vehicle is dead, nothing to do with him

_getNextRole = {
    if (_this emptyPositions "driver" > 0) exitWith { "driver"};
    if (_this emptyPositions "gunner" > 0) exitWith { "gunner"};
    if (_this emptyPositions "commander" > 0) exitWith { "commander"};
    if (_this emptyPositions "cargo" > 0) exitWith { "cargo"};
    "" // no more roles
};
_crew = crew _veh; // crew still in vehicle

#ifdef __DEBUG__
hint localize format["eventGetOut: vehicle crew has %1 men, wait vehicle to be empty", count crew _veh];
#endif

// Allow all AI jumped out and let find the cause
sleep 10;
if ( !alive _veh ) exitWith
{
#ifdef __DEBUG__
    hint localize format["eventGetOut: %1 vehicle is down", typeof _veh];
#endif
    false
}; // vehicle is dead, nothing to do with him

_veh setDamage 0; // remove any vehicle damage

if ( {alive _x} count (crew _veh) > 0 ) exitWith
{
    // cyclic jump-in jump-out, try simply to repair this vehicle and exit
    sleep 0.2;
#ifdef __DEBUG__
    hint localize format["eventGetOut: %1 vehicle  has cyclic in/out events detected, repaired and exit", typeOf _veh];
#endif
    _index = _veh addEventHandler ["GetOut", {_this execVM "scripts\eventGetOut.sqf";}]; //
    true
};

// check if vehicle is upsidedown
_udState = _veh call SYG_vehIsUpsideDown;

if (_udState) then {

    _pos = position _veh;
    _nil = "Logic" createVehicle _pos;
    _veh setPos (position _nil);
    sleep 0.01;
    deleteVehicle _nil;

    hint localize format["eventGetOut: Upsidedown vehicle %1 of %2 crew returned back", typeOf _veh, count crew _veh]
};

if ( vehicle _man == _veh) exitWith { hint localize format["--- eventGetOut: jumped out man already moved inside %1, exit", typeOf _veh] };

_roles = [ "driver", "gunner", "commander"];

// vehicle is empty, try to populate it again with nearest group members

#ifdef __DEBUG__
hint localize format["eventGetOut: try to move in vehicle first out man  (as %1)", _role];
#endif

if ( _role != "cargo") then
{
    switch (_role ) do
    {
        case "driver":    { _man assignAsDriver    _veh; _man moveInDriver    _veh };
        case "gunner":    { _man assignAsGunner    _veh; _man moveInGunner    _veh };
        case "commander": { _man assignAsCommander _veh; _man moveInCommander _veh};
//        case "cargo":     { _man assignAsCargo     _veh; _man moveInCargo     _veh};
    };
    _roles = _roles - [_role]; // remove already populated role
}
else
{

#ifdef __DEBUG__
    hint localize format["eventGetOut: %1 added to list", _role];
#endif
    _crew = _crew + [_man]
};


_cnt = count _crew;
// accumulate all nearest pedestrians of the group
{
    if ( (alive _x) && (canStand _x) && ( vehicle _x == _x) && (_veh distance _x < 50) && !(_x in _crew) ) then {_crew = _crew + [_x];};
} forEach units group _man;

#ifdef __DEBUG__

hint localize format["eventGetOut: %1 men in group, %2 men near vehicle, %3 men in vehicle, empty roles %4", count units group _man, count _crew, count crew _veh, _roles];
_cnt = count _crew;

#endif

{
    _newrole = _veh call _getNextRole;
    if ( _newrole == "") exitWith { true };

    #ifdef __DEBUG__
    hint localize format["eventGetOut: move %1 in vehicle", _newrole];
    #endif

    switch (_newrole ) do
    {
        case "driver":    {
            _x assignAsDriver    _veh; _x moveInDriver    _veh;
        };
        case "gunner":    {
            _x assignAsGunner    _veh; _x moveInGunner    _veh;
         };
        case "commander": {
            _x assignAsCommander    _veh; _x moveInCommander    _veh;
         };
        case "cargo":     {
            _x assignAsCargo    _veh; _x moveInCargo    _veh ;
        };
    };
    sleep 0.1;
} forEach _crew;

#ifdef __DEBUG__
hint localize format["eventGetOut: vehicle %1 populated with %2 of crew, outer crew size now %3, not poped roles %4", typeOf _veh, count crew _veh, (count _crew) - (count crew _veh), _roles];
#endif

_index = _veh addEventHandler ["GetOut", {_this execVM "scripts\eventGetOut.sqf";}]; //

true
