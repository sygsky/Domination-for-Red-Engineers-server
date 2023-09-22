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
#define CAR_MARKER_NAME      "free_car_marker_name"
#define CAR_MARKER_COLOR     "ColorBlack"

if (typeName _this == "STRING") then { _this = [_this]};
_mode = if (count _this == 0) then { "CHECK"} else { _this select 0};
// call as: _car call _set_marker

if (_mode == "CHECK") exitWith { // Client code
	hint localize format["+++ findCivCar.sqf on client run, player is %1",
	if (vehicle player != player)  then { format["in %1", typeOf vehicle player] } else {"on feet"}];
	if (vehicle player != player) exitWith {["msg_to_user","*",[["STR_CAR_GO_OUT"]], 0, 0, false, "losing_patience" ] call SYG_msgToUserParser;

	_set_marker = {
		_marker_type = _this call SYG_getVehicleMarkerType;
		_pos = getPos _this;
		if ( (markerType CAR_MARKER_NAME == "") ) exitWith { // Marker not exists, create it now
			[ CAR_MARKER_NAME,  _pos, "ICON", CAR_MARKER_COLOR, [0.7,0.7],"",0, _marker_type] call XfCreateMarkerLocal;
		};
		// Update marker pos type and color
	//	CAR_MARKER_NAME setMarkerColorLocal CAR_MARKER_COLOR;
		CAR_MARKER_NAME setMarkerTypeLocal _type;
		CAR_MARKER_NAME setMarkerPosLocal _pos;
	};

	// Search for cars nearby
	_pos = getPos player;
	_arr = nearestObjects [_pos, ALL_CAR_ONLY_SEARCH_LIST, RADIUS_TO_FIND_CAR];
	if (count _arr == 0) then {
		// Search in nearest town
		_loc = player call SYG_nearestSettlement;
		_pos1 = position _loc;
		if ( ( _pos1 distance player ) < RADIUS_TO_FIND_CAR ) exitWith {
			_arr = nearestObjects [_pos1, ALL_CAR_ONLY_SEARCH_LIST, RADIUS_TO_FIND_CAR];
			_pos = _pos1;  // set better position to use for car creation
		};
	};
	_car = objNull;
	{
		if ( (alive _x) && ( (speed _x) < 1 ) ) exitWith { // Send message to the player about car found
			_car  = _x;
			// "The car (%1) is detected at %2"
			["msg_to_user","*",[["STR_CAR_FOUND", typeOf _car, [_car, 50] call SYG_MsgOnPos0]], 0, 0, false, "no_more_waiting" ] call SYG_msgToUserParser;

			_marker_type = _car call SYG_getVehicleMarkerType;
			_pos = getPos _car;
			_mrk_type = markerType CAR_MARKER_NAME;
			if ( (_mrk_type == "") ) then { // Marker not exists, create it now
				[ CAR_MARKER_NAME,  _pos, "ICON", CAR_MARKER_COLOR, [0.7,0.7],"",0, _marker_type] call XfCreateMarkerLocal;
				["msg_to_user","*",[[ "STR_CAR_MAPPED", typeOf _car]], 0, 0, false, "no_more_waiting"] call SYG_msgToUserParser; // "Car (%1) has been mapped."
			} else {
				// Update marker pos and type
				if (_mrk_type != _marker_type) then { CAR_MARKER_NAME setMarkerTypeLocal _marker_type };
				CAR_MARKER_NAME setMarkerPosLocal _pos;
				["msg_to_user","*",[[ "STR_CAR_MAPPED_1", typeOf _car]], 0, 0, false, "no_more_waiting"] call SYG_msgToUserParser; // "Car (%1) has been mapped."
			};

		};

	} forEach _arr;
	if ( !isNull _car ) exitWith {};
	CAR_MARKER_NAME setMarkerTypeLocal "Empty"; // Hide free car marker
	["msg_to_user","*",[[ "STR_CAR_NOT_FOUND"]], 0, 0, false, "losing_patience" ] call SYG_msgToUserParser; // "No cars found in the vicinity. Try again... a little later"

	// Execute remote command to create/move free car at designated position
	["remote_execute", format ["[""CREATE"",%1] execVM ""scripts\findCivCar.sqf""", _pos]] call XSendNetStartScriptServer;
};

if (_mode == "HELP") exitWith {

};

hint localize "+++ findCivCar.sqf on server run";

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
	hint localize format["+++ findCivCar.sqf(server): car #%1 (%2) created at %3", (count FREE_CAR_LIST) + 1, _type, _pos1 call SYG_MsgOnPosE0];
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
	for "_i" from 0 to _end do { // Check all vehs in the list
		_x = FREE_CAR_LIST select _i;
		if (alive _x) then { // Car ready
			if ( !(alive _car) ) then { // Car not selected
				_car == _x;  // Select any alive car
				FREE_CAR_LIST set [_i, "RM_ME"];
				_removed = true;
			};
		} else { // Mark to remove dead car
			FREE_CAR_LIST set [_i, "RM_ME"];
			_removed = true;
			if (!isNull _x) then { deleteVehicle _x };
		};
	};
	if (_removed) then {  // No car found but some item[s] were removed, try to create new car
		FREE_CAR_LIST call SYG_cleanArray;
	};
	if (!alive _car) then {
		call _create_car
	} else {
		FREE_CAR_LIST set [_i, _car]; // Set car at last position (to be last used one)
	};
};
allow_car_list_changes = true;
if (!alive _car) then {  // No car found for the palyer call
	hint localize format["--- findCivCar.sqf(server): no car found for the player%1!",
		if (count _this > 2) then { format[" %1", _this select 2]} else {""} ]
} else {
	hint localize format["--- findCivCar.sqf(server): car %1 found for the player%2!",
		_type, if (count _this > 2) then { format[" %1", _this select 2]} else {""} ]
};

