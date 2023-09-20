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

#include "x_setup.sqf"

#define   RADIUS_TO_FIND_CAR 500
#define RADIUS_TO_CREATE_CAR 400
#define            MAX_COUNT 5
#define PLAYER_SEARCH_RADIUS 200


if (X_Client) exitWith { // Pure Client
	// Search for cars nearby
	_pos = getPos player;
	_arr = nearestObjects [_pos, ALL_CAR_ONLY_SEARCH_LIST, RADIUS_TO_FIND_CAR];
	if (count _arr == 0) then {
		// Search in nearest town
		_loc = player call SYG_nearestSettlement;
		_pos = position _loc;
		if ( ( _pos distance player ) < RADIUS_TO_FIND_CAR ) exitWith {
			_arr = nearestObjects [_pos, ALL_CAR_ONLY_SEARCH_LIST, RADIUS_TO_FIND_CAR];
		};
		_pos = getPos player; // set better position to use for car creation
	};
	_car = objNull;
	{
		if ( (alive _x) && ( (speed _x) < 1 ) ) exitWith { // Send message to the player about car found
			_car  = _x;
			// "The car (%1) is detected at %2"
			["msg_to_user","*",[["localize", "STR_CAR_FOUND", typeOf _car, [_car, 50] call SYG_MsgOnPos0], 0, 0, false, "no_more_waiting" ]] call SYG_msgToUserParser;
			_car call _set_marker;
			["msg_to_user","*",[["localize", "STR_CAR_MAPPED", typeOf _car], 0, 0, false, "no_more_waiting" ]] call SYG_msgToUserParser; // "Car (%1) has been mapped."
		};
	} forEach _arr;
	if ( !isNull _car ) exitWith {};

	["msg_to_user","*",[["localize", "STR_CAR_NOT_FOUND"], 0, 0, false, "losing_patience" ]] call SYG_msgToUserParser; // "No cars found in the vicinity. Try again... a little later"
	// Execute remote command to create/move free car at designated position
	["remote_execute", format ["[""CREATE"",%1] execVM ""scripts\findCivCar.sqf""", _pos]] call XSendNetStartScriptServer;
};

// Server side code
if (isNil "FREE_CAR_LIST") then { allow_car_list_changes = true; FREE_CAR_LIST = [] };

private ["_car","_type"];

_removed = false;
_end = (count FREE_CAR_LIST) -1;
for "_i" from 0 to _end do {
	_car = FREE_CAR_LIST select _i;
	if (!alive _car) then {
		if (!isNull _car) then {
			deleteVehicle _car;
			FREE_CAR_LIST set [_i, "RM_ME"];
			_removed = true;
		};
	};
};
if (_removed) then { FREE_CAR_LIST call SYG_cleanArray };

_create_car = {
	// create a new car from the list: ALL_CAR_ONLY_TYPE_LIST
	_type = ALL_CAR_ONLY_TYPE_LIST call XfRandomArrayVal;
	_pos1 = [ _pos, RADIUS_TO_CREATE_CAR] call XfGetRanPointCircleBig;
	_car = createVehicle [ _type, _pos1, [], 0, "NONE" ];
	FREE_CAR_LIST set [count FREE_CAR_LIST, _car];
	hint localize format["+++ findCivCar.sqf(server): car (%1) created at %2", _type, _pos1 call SYG_MsgOnPosE0];
};

if (typeName _this != "ARRAY") exitWith { hint localize format["--- findCivCar.sqf(server): _this not ARRAY (%1), exit!", typeName _this] };
_pos = _this select 1;
// 2. Find nearest car
_arr = nearestObjects [_pos, ALL_CAR_ONLY_SEARCH_LIST, RADIUS_TO_FIND_CAR];
if (count _arr > 0 ) exitWith  { hint localize format["*** findCivCar.sqf(server): car already exists at search radius %2, exit", RADIUS_TO_FIND_CAR] };

waitUntil {allow_car_list_changes};
allow_car_list_changes = false;

if ( (count FREE_CAR_LIST) <  MAX_COUNT ) then {
	call _create_car;
} else {
	// Find oldest empty car with no players nearby to the random position near designated pos
	_car = objNull;
	_removed = false;
	_end = (count FREE_CAR_LIST) - 1;
	for "_i" from 0 to _end do {
		_x = FREE_CAR_LIST select _i;
		if (alive _x) then { // Car ready
			if ( !(alive _car) ) then { // Car not selected
				if ( ({alive _x} count (crew _x)) == 0 ) then { _car == _x }; // Select empty alive car
			};
		} else { // Mark to remove dead car
			FREE_CAR_LIST set [_i, "RM_ME"];
			_removed = true;
			if (!isNull _x) then {
				deleteVehicle _x;
			};
		};
	};
	if (_removed) then {
		FREE_CAR_LIST call SYG_cleanArray;
		if (!alive _car) exitWith {	call _create_car }; // No car found but some item[s] were removed, try to create new car
	};
};
allow_car_list_changes = true;
if (!alive _car) exitWith {  // No car found for the palyer call
	hint localize format["--- findCivCar.sqf(server): no car found for the player%1!",
		if (count _this > 2) then { format[" %1", _this select 2]} else {""} ]
} else {
	hint localize format["--- findCivCar.sqf(server): car %1 found for the player%2!",
		_type, if (count _this > 2) then { format[" %1", _this select 2]} else {""} ]
};

