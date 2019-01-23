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
if (X_MP && (call (XPlayersNumber) > 0) ) exitWith {false}; // only work in absence of any player 

#include "x_setup.sqf"

#ifdef __TT__
if (true) exitWith {false};
#end

_veh  = _this select 0;

_index = _veh getVariable "GetOutIndex";

if (isNil _index) exitWith {};

_veh removeEventHandler ["GetOut", _index]; // prevent multiple event firing

if ( (_veh isKindOf "Air") || (_veh isKindOf "Ship")) exitWith
{ 
    hint localize format["--- eventGetOut: call on invalid vehicle type %1, exit", typeOf _veh];
};

// still only for land vehicles

_role = _his select 1;
_man = _his select 2;

_crewtype = typeOf _man; //"SoldierWB";

if ( !alive _veh ) exitWith {false}; // vehicle is dead, nothing to do with him
_crew = crew _veh; // store whole crew
// Allow all AI jumped out and let find the cause
sleep 5;
if ( !alive _veh ) exitWith {false}; // vehicle is dead, nothing to do with him

_veh setDamage 0; // remove any vehicle damage

if ( {alive _x} count (crew _veh) > 0 ) exitWith
{
    // cyclic jump-in jump-out, try simply to repair this vehicle and exit
    hint localize format["eventGetOut: vehicle %1 possible with cyclic in/out events detected, repaired and not process it more", typeOf _veh];
    _index = _veh addEventHandler ["GetOut", {_this execVM "scripts\eventGetOut.sqf";}]; //
    _veh setVariable  ["GetOut", _index]; // prepare new processing
    true
};

// check if vehicle is upsidedown
_udState = _veh call SYG_vehIsUpsideDown;

_pos = position _veh;
_nil = "Logic" createVehicle _pos;
_veh setPos (position _nil);

if (_udState) then { hint localize format["eventGetOut: Upsidedown vehicle %1 of %2 crew returned back", typeOf _veh, count crew _veh] };

_roles = [ "driver", "gunner", "commander"];
// vehicle is empty, try to populate it again with nearest group members
if ( _role != "cargo") then {
    switch (_role ) do
    {
        case "driver":    { _man assignAsDriver    _veh; _man moveInDriver    _veh };
        case "gunner":    { _man assignAsGunner    _veh; _man moveInGunner    _veh };
        case "commander": { _man assignAsCommander _veh; _man moveInCommander _veh};
//        case "cargo":     { _man assignAsCargo     _veh; _man moveInCargo     _veh};
    };
    _roles = _roles - [_role]; // remove already populated role
};

// accumulate all nearest pedestrians of the group
{
    if ( (alive _x) && (canStand _x) && ( vehicle _x == _x) && (_man distance _x < 50) && !(_x in _crew) ) then {_crew = _crew + [_x];};
} forEach units group _man;

{
    if ( count _roles == 0) exitWith{};
    if ( alive _x && canStand _x && vehicle _x == _x ) then
    {
        unassignVehicle _x;
        _x setDamage 0;
        _newrole = _roles select 0;
        _roles  = _roles - [_newrole];
        switch (_newrole ) do
        {
            case "driver":    { _x assignAsDriver    _veh; _x moveInDriver    _veh };
            case "gunner":    { _x assignAsGunner    _veh; _x moveInGunner    _veh };
            case "commander": { _x assignAsCommander _veh; _x moveInCommander _veh};
            case "cargo":     { _x assignAsCargo     _veh; _x moveInCargo     _veh};
        };
    };
} forEach _crew;

hint localize format["eventGetOut: vehicle %1 populated with %2 of crew", typeOf _veh, count crew _veh];
_index = _veh addEventHandler ["GetOut", {_this execVM "scripts\eventGetOut.sqf";}]; //
_veh setVariable  ["GetOut", _index]; // prepare new processing
true
