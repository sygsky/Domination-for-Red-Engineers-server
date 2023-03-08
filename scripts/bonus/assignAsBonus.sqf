/*
    scripts\bonus\assignAsBonus.sqf, called on server ONLY
	author: Sygsky
	description: handlers assigned to the vehicle to check bonus in/kill events
		called on server (in debug SP mission it is emulated only)
	call: [_veh1, ..., _vehN] execVM "scripts\bonus\assignAsBonus.sqf";
	returns: nothing
*/

if (!X_Server) exitWith {hint localize "--- assignAsBonus.sqf called on client, exit!!!"};

#include "bonus_def.sqf"

if (typeName _this == "OBJECT") then {_this = [_this]};
if (typeName _this != "ARRAY") exitWith {hint localize format["--- assignAsBonus.sqf, expected input type is ARRAY, detected %1, EXIT ON ERROR !!!",typeName _this]};
private ["_x"];
_msg_arr = [];

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
_plane = false;
_error = false;
{
	if (!(_x isKindOf "Car"/*"LandVehicle"*/ || _x isKindOf "Air" || _x isKindOf "Ship") ) exitWith {
		hint localize format["--- assignAsBonus.sqf: expected type LandVehicle|Air|Ship, detected ""%1"", EXIT ON ERROR !!!", typeOf _x];
		_error = true;
	};
	_x call SYG_addEventsAndDispose; // add all std mission-driven events here (not recoverable, may be killed and removed from the mission)
	_x setVariable ["DOSAAF", ""]; // mark as DOSAAF vehicle, not inspected and not registered
	_near_loc_name = text (_x call SYG_nearestLocation);
	_msg_arr set [count _msg_arr, ["STR_BONUS", _near_loc_name, typeOf _x]]; // "In gratitude, people reported that they noticed the old vehicle of DOSAAF (%2) near %1. Inspect it and deliver to the base."
	hint localize format["+++ assignAsBonus.sqf: all events set, ""%1"" action will be added on clients to the %2 near %3", localize "STR_CHECK_ITEM", typeOf _x, _near_loc_name];
	if (_x isKindOf "Plane") then {_plane = true};
} forEach _this;
if (_error) exitWith {
	// send info about error to find DOSAAF vehicle
	hint localize format["--- SYG_createBonusVeh: veh created is not ""OBJECT"" = %1, EXIT", _veh];
	["msg_to_user","*",[["STR_BONUS_ERR"]],2,2,false,"losing_patience"] call XSendNetStartScriptClientAll; // "DOSAAF vehicle is not detected. Can we expect to see it at all?"
};
if (_plane) then { _msg_arr set [count _msg_arr, ["STR_BONUS_7"]]; }; // "When in doubt about an aircraft's ability to take off from the plane pad, use afterburner (Shift) on takeoff!"

// send info about new DOSAAF vehicle and print corresponding message on all active clients
["bonus", "INI", _this, ["msg_to_user","*",_msg_arr,8,8,false,"good_news"]] call XSendNetStartScriptClientAll;

