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
// #define PLAYER_SEARCH_RADIUS 200
#define CAR_MARKER_NAME      "free_car_marker_name"
#define CAR_MARKER_COLOR     "ColorBlack"

if (typeName _this != "ARRAY") then { _this = [_this]};
_mode = if (count _this == 0) then { "CHECK"} else { _this select 0};
if( (typeName _mode) != "STRING" ) exitWith { hint localize format["--- findCivCar.sqf: 1st param is not STRING (_this = %1), exit!", _this]};
// call as: _car call _set_marker

if ( _mode == "CHECK") exitWith { // Client code
	hint localize format["+++ findCivCar.sqf on client run, player is %1, _this = %2",
		if (vehicle player != player)  then { format["in %1", typeOf vehicle player] } else {"on feet"},
		_this
	];

	// "It doesn't work in the vehicle!"
	if (vehicle player != player) exitWith { ["msg_to_user","*",[["STR_CAR_GO_OUT"]], 0, 0, false, "losing_patience" ] call SYG_msgToUserParser };

	_set_marker = {
		_marker_type = _this call SYG_getVehicleMarkerType;
		_pos = getPos _this;
		if ( (markerType CAR_MARKER_NAME == "") ) exitWith { // Marker not exists, create it now
			[ CAR_MARKER_NAME,  _pos, "ICON", CAR_MARKER_COLOR, [0.7,0.7],"",0, _marker_type] call XfCreateMarkerLocal;
		};
		// Update marker type and _pos
		//	CAR_MARKER_NAME setMarkerColorLocal CAR_MARKER_COLOR;
		CAR_MARKER_NAME setMarkerTypeLocal _marker_type; // Just in case
		CAR_MARKER_NAME setMarkerPosLocal _pos;
	};

	// Search for alive cars nearby and in nearest town if it is not far
	_pos = getPos player;
	_arr = nearestObjects [_pos, ALL_CAR_ONLY_SEARCH_LIST, RADIUS_TO_FIND_CAR];
	if ({ alive _x } count _arr == 0) then {
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
		if ( (alive _x) && (!(_x call SYG_vehIsUpsideDown))) exitWith { // Send message to the player about car found
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
			["msg_to_user","*",[["STR_CAR_FOUND", typeOf _car, [_car, 50] call SYG_MsgOnPos0,_str]], 0, 0, false, "no_more_waiting" ] call SYG_msgToUserParser;
		};
	} forEach _arr;

	if ( !isNull _car ) exitWith {
	    sleep 0.1;
        [ "log2server", name player, format[ "findCivCar.sqf: free car (%1) for player found on dist %2 m.", typeOf _car, round(player distance _car) ] ] call XSendNetStartScriptServer;
	}; // Car found and marker too, exit
	// Not found
	// Try to define position for the vehicle near player (or in near town radious)
	CAR_MARKER_NAME setMarkerTypeLocal "Empty"; // Hide free car marker
	["msg_to_user","*",[[ "STR_CAR_NOT_FOUND", RADIUS_TO_FIND_CAR]], 0, 0, false, "losing_patience" ] call SYG_msgToUserParser; // "No cars found in the vicinity. Try again... a little later"
	_pos1 = [ _pos, RADIUS_TO_CREATE_CAR] call XfGetRanPointCircleBig;
	if (count _pos1 == 0) exitWith { // No vehicle can be found around
		["msg_to_user","*",[[ "STR_CAR_NOT_FOUND", RADIUS_TO_FIND_CAR]], 0, 0, false, "losing_patience" ] call SYG_msgToUserParser; // "No cars found in the vicinity. Try again... a little later"
	};
	// Execute remote command to create/move free car to the designated position
	["remote_execute", format ["[""CREATE"",%1, ""%2"", %3] execVM ""scripts\findCivCar.sqf""", _pos1, name player, getPos player ] ] call XSendNetStartScriptServer;
};

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++ HELP +++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if (_mode == "HELP") exitWith {
	// Show hintC dialog with help on vehicle near player:
	// "'Vehicles' - search for civilian cars around the player"
	// "On this command, the nearest (within 500 meters) civilian vehicle is searched for."
	// "The found vehicle is marked with a black marker (by type) and the direction and distance to it is reported"
	// "If the vehicle is missing, a message is displayed and an invitation to press the button again."
	// "<To continue, click the 'Continue' button at the very bottom of the dialog box (or 'Escape').>"
	localize "STR_CAR_HELP_TITLE" hintC [localize "STR_CAR_HELP_1",localize "STR_CAR_HELP_2",localize "STR_CAR_HELP_3",
    					localize "STR_CAR_HELP_4",localize "STR_CAR_HELP_5"];
};

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++ CREATE ++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// _this = ["remote_execute", format ["[""CREATE"",%1,""%2"",%3"] execVM ""scripts\findCivCar.sqf""", _pos1, name player, getPos player]];
hint localize format["+++ findCivCar.sqf: ""CREATE"" on server, _this = %1", _this];

// Server side code
if (isNil "FREE_CAR_LIST") then { allow_car_list_changes = true; FREE_CAR_LIST = [] };

private ["_car"];

_create_car = {
	private ["_pos1", "_type", "_car"];
	_pos1 = _this;
	// create a new car from the list: ALL_CAR_ONLY_TYPE_LIST
	_type = ALL_CAR_ONLY_TYPE_LIST call XfRandomArrayVal;
	_car = createVehicle [ _type, _pos1, [], 0, "NONE" ];
	_car setVectorUp [0,0,1];
	_car setDir (random 360);
	_car setPos (getPos _car);
	FREE_CAR_LIST set [count FREE_CAR_LIST, _car];
	hint localize format["+++ findCivCar.sqf(server): car #%1 (%2) created at %3",
	    (count FREE_CAR_LIST) - 1,
	    _type,
	    _pos1 call SYG_MsgOnPosE0];
	_car
};

// if (typeName _this != "ARRAY") exitWith { hint localize format["--- findCivCar.sqf(server): _this not ARRAY (%1), exit!", typeName _this] };

_pos1 = _this select 1; // pos to set car

hint localize format["*** findCivCar.sqf(server): _pos1 = %1", _pos1];

waitUntil {allow_car_list_changes};
allow_car_list_changes = false;

if ( (count FREE_CAR_LIST) <  MAX_COUNT ) then {
	_car = _pos1  call _create_car; // Simply add new car if list is incomplete
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
				if ( (alive _x) && (!(_x call SYG_vehIsUpsideDown))) then { // Car ready and not upsidedown and is empty
					if ( isNull _car ) then { // Car not selected
						if ( ({alive _x} count (crew _x)) == 0 ) then {
							_car = _x;  // Select oldest empty alive car
							FREE_CAR_LIST set [_i, "RM_ME"];
							hint localize format[ "+++ findCivCar.sqf(server): veh at list.get(%1) will be used, pos at %2, dist %3 м", _i, _car call SYG_MsgOnPosE0, _this select 2 ];
						};
					};
				} else {  // Delete dead or upsidedown vehicle
					// Play corresponding sound
					["say_sound", getPos _x, "steal"] call XSendNetStartScriptClientAll;
					deleteVehicle _x;
					FREE_CAR_LIST set [_i, "RM_ME"];
				};
			};
		};
	};

	if ("RM_ME" in FREE_CAR_LIST ) then { // Some car[s] were removed, clear them from the list
		_cnt = count FREE_CAR_LIST;
		FREE_CAR_LIST call SYG_cleanArray;
		hint localize format["+++ findCivCar.sqf(server): free car list cleaned from size %1 to  %2", _cnt, count FREE_CAR_LIST];
	};
	if (alive _car) then {	// Existing car is found, add it to the end of list
		_car setVectorUp [0,0,1];
		_car setDir (random 360);
		_car setPos _pos1;
		FREE_CAR_LIST set [count FREE_CAR_LIST, _car]; // Add this car to the end of list as last used one
	} else { // No car found, create new one if list is not full
		if (count FREE_CAR_LIST < MAX_COUNT) then { // there is aplce in laist, add new car
			_car = _pos1 call _create_car;
			hint localize format["+++ findCivCar.sqf(server): new car created for list of final size %1", count FREE_CAR_LIST];
		} else { // no place in list for a new car, print info about this to player (in client)
			hint localize format["--- findCivCar.sqf(server): no veh found in list of size %1, LIST = %2", count FREE_CAR_LIST, FREE_CAR_LIST call SYG_vehToType];
		}
	};
};
allow_car_list_changes = true;
hint localize format["+++ findCivCar.sqf(server): car %1 found%2%3",
	typeOf _car,
	if (count _this > 2) then { format[" for the player %1", _this select 2]} else {", <no player name set>"},
	if (count _this > 3) then { format [" on dist %1 m.!", round(_car distance (_this select 3))] } else {", <no pos set>"}
];

