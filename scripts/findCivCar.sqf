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
#define            MAX_COUNT 3
// #define PLAYER_SEARCH_RADIUS 200
#define CAR_MARKER_NAME      "free_car_marker_name"
#define CAR_MARKER_COLOR     "ColorBlack"

if (typeName _this == "STRING") then { _this = [_this]};
_mode = if (count _this == 0) then { "CHECK"} else { _this select 0};
// call as: _car call _set_marker

if ( _mode == "CHECK") exitWith { // Client code
	hint localize format["+++ findCivCar.sqf on client run, player is %1, _this = %2",
		if (vehicle player != player)  then { format["in %1", typeOf vehicle player] } else {"on feet"}, _this];

	if (vehicle player != player) exitWith { ["msg_to_user","*",[["STR_CAR_GO_OUT"]], 0, 0, false, "losing_patience" ] call SYG_msgToUserParser };

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
			_str = "";
			_marker_type = _car call SYG_getVehicleMarkerType;
			_pos = getPos _car;
			_mrk_type = markerType CAR_MARKER_NAME; // Marker type name, may be "Empty", so invisible
			if ( (_mrk_type == "") ) then { // Marker not exists, create it now
				[ CAR_MARKER_NAME,  _pos, "ICON", CAR_MARKER_COLOR, [0.7,0.7],"",0, _marker_type] call XfCreateMarkerLocal;
				_str = format[ "STR_CAR_MAPPED", typeOf _car]; // ". Marker has been mapped."
			} else {
				// Update marker pos and type
				if (_mrk_type != _marker_type) then { CAR_MARKER_NAME setMarkerTypeLocal _marker_type };
				CAR_MARKER_NAME setMarkerPosLocal _pos;
				_str = format[ "STR_CAR_MAPPED_1", typeOf _car]; // ". Marker already has been mapped."
			};
			// "Vehicle (%1) is detected at %2%3"
			["msg_to_user","*",[["STR_CAR_FOUND", typeOf _car, [_car, 50] call SYG_MsgOnPos0],_str], 0, 0, false, "no_more_waiting" ] call SYG_msgToUserParser;

		};

	} forEach _arr;
	if ( !isNull _car ) exitWith {}; // Car found ann marker, exit
	CAR_MARKER_NAME setMarkerTypeLocal "Empty"; // Hide free car marker
	["msg_to_user","*",[[ "STR_CAR_NOT_FOUND", RADIUS_TO_FIND_CAR]], 0, 0, false, "losing_patience" ] call SYG_msgToUserParser; // "No cars found in the vicinity. Try again... a little later"

	// Execute remote command to create/move free car at designated position
	["remote_execute", format ["[""CREATE"",%1, ""%2""] execVM ""scripts\findCivCar.sqf""", _pos, name player]] call XSendNetStartScriptServer;
};

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++ HELP +++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if (_mode == "HELP") exitWith {
};

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++ CREATE ++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
hint localize format["+++ findCivCar.sqf on server run, _this = %1", _this];

// Server side code
if (isNil "FREE_CAR_LIST") then { allow_car_list_changes = true; FREE_CAR_LIST = [] };

private ["_car"];

_create_car = {
	private ["_pos1", "_type", "_car"];
	_pos1 = _this;
	// create a new car from the list: ALL_CAR_ONLY_TYPE_LIST
	_type = ALL_CAR_ONLY_TYPE_LIST call XfRandomArrayVal;
	_car = createVehicle [ _type, _pos1, [], 0, "NONE" ];
	FREE_CAR_LIST set [count FREE_CAR_LIST, _car];
	hint localize format["+++ findCivCar.sqf(server): car #%1 (%2) created at %3", (count FREE_CAR_LIST) - 1, _type, _pos1 call SYG_MsgOnPosE0];
	_car
};

if (typeName _this != "ARRAY") exitWith { hint localize format["--- findCivCar.sqf(server): _this not ARRAY (%1), exit!", typeName _this] };

_pos = _this select 1; // pos to set car

// Find nearest cars
_arr = nearestObjects [_pos, ALL_CAR_ONLY_SEARCH_LIST, RADIUS_TO_FIND_CAR];
if (count _arr > 0 ) exitWith  { hint localize format["*** findCivCar.sqf(server): car already exists at search radius %2, exit", RADIUS_TO_FIND_CAR] };

// Find positon to place car to the close area
_pos1 = [ _pos, RADIUS_TO_CREATE_CAR] call XfGetRanPointCircleBig;
hint localize format["*** findCivCar.sqf(server): _pos1 = %1", _pos1];
if (count _pos1 > 0) then {

	waitUntil {allow_car_list_changes};
	allow_car_list_changes = false;
	if ( (count FREE_CAR_LIST) <  MAX_COUNT ) then {
		_car = _pos1  call _create_car;
	} else {
		// Find oldest empty car with no players nearby to the random position near designated pos
		_car = objNull;
		_end = (count FREE_CAR_LIST) - 1;
		for "_i" from 0 to _end do { // Check all vehs in the list
			_x = FREE_CAR_LIST select _i;
			if (isNull _x) then {
				FREE_CAR_LIST set [_i, "RM_ME"]
			} else {
				if (typeName _x == "OBJECT") then {
					if (alive _x) then { // Car ready
						if ( isNull _car ) then { // Car not selected
							_car = _x;  // Select oldest used alive car
							FREE_CAR_LIST set [_i, "RM_ME"];
							hint localize format["+++ findCivCar.sqf(server): veh at list.get(%1) wiLl be used, _car is %2null",
							_i, if (alive _car) then {""} else {"not "}];
						};
					} else {  // Delete dead vehicle
						deleteVehicle _x;
						FREE_CAR_LIST set [_i, "RM_ME"];
					};
				};
			};
		};
		// No car found but some item[s] were removed, try to create new car
		if ("RM_ME" in FREE_CAR_LIST ) then {
			_cnt = count FREE_CAR_LIST;
			FREE_CAR_LIST call SYG_cleanArray;
			hint localize format["+++ findCivCar.sqf(server): free car list cleaned from size %1 to  %2", _cnt, count FREE_CAR_LIST];
		};
		if (alive _car) then {
			_car setDir (random 360);
			_car setPos _pos1;
			FREE_CAR_LIST set [count FREE_CAR_LIST, _car]; // Add this car to the end of list as last used one
		} else { // No car found, create new one if list is not full
			if (count FREE_CAR_LIST < MAX_COUNT) then {
				_car = _pos1 call _create_car;
				_car setDir (random 360);
				_car setPos (getPos _car);
				hint localize format["--- findCivCar.sqf(server): new car created for list of final size %1", count FREE_CAR_LIST];
			} else {
				hint localize format["--- findCivCar.sqf(server): no veh found in list of size %1, LIST = %2", count FREE_CAR_LIST, FREE_CAR_LIST call SYG_vehToType];
			}
		};
	};
	allow_car_list_changes = true;
	hint localize format["+++ findCivCar.sqf(server): car %1 found for the player%2!",
		typeOf _car, if (count _this > 2) then { format[" %1", _this select 2]} else {""} ]
} else {
	hint localize format["--- findCivCar.sqf(server): no car found for the player%1!",
		if (count _this > 2) then { format[" %1", _this select 2]} else {""} ]
};

