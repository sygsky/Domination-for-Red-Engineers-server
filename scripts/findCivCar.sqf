/*
	scripts\findCivCar.sqf: called on clent and recalled in that client script on server
	author: Sygsky
	description:
		Try to add civilian car from list of allowed types on the call from STATUS dialog:
		 1. If no free car detected in radius RADIUS_TO_FIND_CAR m. new one created if free car count < MAX_COUNT,
		 	else oldest of existed cars is moved to the random place near player
		 2. Killed cars from the list of created cars are removed from the map

	Params: _pos execVM "scripts\findCivCar.sqf"

	returns: nothing
*/

if (!X_Server) exitWith { // Client
	// Search for cars nearby
	_arr = nearestObjects [_pos, ALL_CAR_ONLY_SEARCH_LIST, RADIUS_TO_FIND_CAR];
	_car = objNull;
	{
		if ( (alive _x) && ( (speed _x) < 1 ) ) exitWith { // Send message to the player about car found
			_car  = _x;
			// "The car (%1) is detected at %2"
			["msg_to_user","*",[["localize", "STR_CAR_FOUND", typeOf _car, [_car, 50] call SYG_MsgOnPos0], 0, 0, false, "losing_patience" ]] call SYG_msgToUserParser;
		};
	} forEach _arr;
	if ( !isNull _car ) exitWith {};
	// Execute remote command to create/move free car
	["remote_execute", format ["[""CREATE"",%1] execVM ""scripts\findCivCar.sqf""", getPos _car]] call XSendNetStartScriptServer;
	// Send message about cars absence and run car creation/search on server
	["msg_to_user","*",[["localize", "STR_CAR_FOUND", typeOf _car, [_car, 50] call SYG_MsgOnPos0], 0, 0, false, "losing_patience" ]] call XHandleNetStartScriptClient;
};

if (isNil "FREE_CAR_LIST") then { FREE_CAR_LIST = [] };

#include "x_setup.sqf"

#define  RADIUS_TO_FIND_CAR  500
#define RADIUS_TO_CREATE_CAR 400
#define            MAX_COUNT 5

_pos = _this;

// 1. Clear lits just in case
private ["_car"];

_removed = false;
for "_i" from 0 to _cnt do {
	_car = FREE_CAR_LIST select _i;
		if (!alive _car) then {
			if (!isNull _car) then {
				deleteVehicle _car;
				FREE_CAR_LIST set [_i, "RM_ME"];
				_removed = true;
			};
		};
};
if (_removed) then {FREE_CAR_LIST call SYG_cleanArray};

// 2. Find nearest car
_arr = nearestObjects [_pos, ALL_CAR_ONLY_SEARCH_LIST, RADIUS_TO_FIND_CAR];
if (count _arr == 0 ) then {
	if ( (count FREE_CAR_LIST) <  MAX_COUNT ) then {
		// create a new car from the list: ALL_CAR_ONLY_TYPE_LIST
		_type = ALL_CAR_ONLY_TYPE_LIST call XfRandomArrayVal;
		_pos = _type call XfGetRanPointCircleBig;
		_car =  createVehicle [ _type, _pos, [], 0, "NONE" ];
		FREE_CAR_LIST set [count FREE_CAR_LIST, _car];
	} else {
		// Find oldest empty car with no players nearby to the random position near designated pos
		_car = objNull;
		{
			if ( alive _x ) then {
				if ( ({alive _x} count (crew _x)) == 0 ) then {
					_names = [_pos, PLATER_SEARCH_RADIUS] call SYG_findNearestPlayers;
					if (count _names == 0) exitWith {_car == _x}
				};
			};
			if (alive _car) exitWith {};
		} forEach FREE_CAR_LIST;
		if (!alive _car) exitWIth {
			["mag_to_user"]; // TODO:
		};
	};
};


