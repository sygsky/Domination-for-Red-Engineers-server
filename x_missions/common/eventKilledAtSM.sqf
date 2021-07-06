/*
    x_missions/common\eventKilledAtSM.sqf
	author: Sygsky
	description: event on convoy vehicle killed. Tries to find player throwed this event and award him
	returns: nothing

	2.13 Killed
    Triggered when the unit is killed.

    Local.

    Passed array: [unit, killer]

    unit: Object - Object the event handler is assigned to
    killer: Object - Object that killed the unit
    Contains the unit itself in case of collisions.

    =================================================
    Called when any convoy vehicles is killed. We have to find and count follow situations (except case when isNull _unit):
    a) killer is player on feet. If he is not AI, he is counted
    b) all players sitting in vehicle of killer (player or AI), are counted
    c) any player near the killed event (radious hardcoded here in file) is counted
*/

if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

#define ACTION_RADIUS 250 // how far from "killed" event place player is counted as participant of this SideMission

hint localize format["+++ eventKilledAtSM.sqf: veh %1, killer %2", _this, typeOf (_this select 0), name (_this select 1)];

private ["_unit","_killer","_plist","_add_to_list","_arr"];

_unit     = _this select 0;
if (isNull _unit) exitWith {hint localize "*** eventKilledAtSM.sqf: _unit is NULL, can't process event..."};
_killer   = _this select 1;
_plist    = []; // list of found participaiting player

//
// Adds name of player to list
// call: _plist = name _killer call _add_to_list;
//
_add_to_list = {
    if (typeName _this != "STRING") exitWith { hint localize "---SYG_eventKilledAtSM: error in call to _add_to_list" }; // only string accepted as argument
    if (!(_this in _plist)) then {_plist set [count _plist, _this]};
};

// 1. count killer and all players in his vehicle
if ( !(isNull _killer) ) then {
    if (_killer != _unit) then {
        // killer is not itself
        {
            if ( isPlayer _x ) then { (name _x) call _add_to_list };
        } forEach crew (vehicle _killer);
    };
};
_arr = getPos _unit;
_arr = _arr nearObjects ["AllVehicles", ACTION_RADIUS];
{
    {
        if ( isPlayer _x ) then { (name _x) call _add_to_list };
    }forEach crew _x;
} forEach _arr;

if (count _plist > 0 ) then {
    ["was_at_sm", _plist] call XSendNetStartScriptClient;
    //hint localize format["+++ eventKilledAtSM.sqf: send event [""was_at_sm"",%1]", _plist];
};
