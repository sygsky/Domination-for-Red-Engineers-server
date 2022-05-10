/*
    scripts\bonus\assignAsBonus.sqf, called on server ONLY
	author: Sygsky
	description: handlers assigned to the vehicle to check bonus in/kill events
		called on server (in debug SP mission it is emulated only)
	call: [_veh1, ..., _vehN] execVM "scripts\bonus\assignAsBonus.sqf";
	returns: nothing
*/
if(!isServer) exitWith {hint localize "--- assignAsBonus.sqf called on client, exit!!!"};

#include "bonus_def.sqf"

if (typeName _this == "OBJECT") then {_this = [_this]};
if (typeName _this != "ARRAY") exitWith {hint localize format["--- assignAsBonus.sqf, expected input type is ARRAY, detected %1, EXIT ON ERROR !!!",typeName _this]};
private ["_x"];
_msg_arr = [];

//++++++++++++++++++++++++ clean main DOSAAF array first +++++++++++++++++++++
_arr = SYG_DOSAAF_array select 0;
// check unknown DOSAAF vehicles to be alive
_removed = false;
for	"_i" from 0 to count _arr -1 do {
	_veh = _arr select _i;
	if (!alive _veh) then {	_arr set [_i, "RM_ME"]; _removed = true };
} forEach _arr;
if (_removed) then { _arr call SYG_clearArray };
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
{
	if ( ! (_x isKindOf "LandVehicle" || _x isKindOf "Air" || _x isKindOf "Ship") ) exitWith {
		hint localize format["--- assignAsBonus.sqf: expected type LandVehicle|Air|Ship, detected ""%1"", EXIT ON ERROR !!!", typeOf _x];
	};
	_x call SYG_addEventsAndDispose; // add all std mission-driven events here (not recoverable, may be killed and removed from the mission)
	_x setVariable ["DOSAAF", ""]; // mark as DOSAAF vehicle, not detected, not registered
	_near_loc_name = text (_x call SYG_nearestLocation);
	_msg_arr set [count _msg_arr, ["STR_BONUS", _near_loc_name, typeOf _x]];
	hint localize format["+++ assignAsBonus.sqf: all events set, ""%1"" action will be added on clients to the %2 near %3", localize "STR_CHECK_ITEM", typeOf _x, _near_loc_name];
} forEach _this;
// send info about new DOSAAF vehicle to all clients
["bonus", "INI", _this] call XSendNetStartScriptClientAll;
// TODO: transfer messages to the "INI" event on clients. Format all mesaages on client after receiveing ["bonus", "INI",_arr] event.
["msg_to_user","*",_msg_arr,8,1,false,"good_news"] call XSendNetStartScriptClientAll;

