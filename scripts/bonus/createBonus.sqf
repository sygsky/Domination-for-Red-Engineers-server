/*
	scripts\bonus\createBonus.sqf: DEBUG script to test main functionality, NOT USED ANYMORE

    ...
	author: Sygsky
	description: place next bonus near the designated position according to the new rules of bonus placing
	returns: nothing
	call as: [[x,y,z], _typeName<, "CIRCLE",_rad>|<"ANNULUS", _rad1,_rad2>] execVM "scripts\bonus\createBonus.sqf"; // ...
*/

#include "bonus_def.sqf"

if (isNil "mt_bonus_vehicle_array_COM") exitWith{
    _mt_bonus_vehicle_CAR = ["ACE_UAZ_MG", "ACE_UAZ_AGS30"];
    _mt_bonus_vehicle_array_TANK = ["ACE_T55_A", "ACE_T55_AM", "ACE_T72","ACE_T72_B","ACE_T72_BK"];
    _mt_bonus_vehicle_array_HELI = ["ACE_Mi24D","ACE_Mi24V","ACE_Mi24P","ACE_Mi17"];
    _mt_bonus_vehicle_array_AIR = ["ACE_Su30Mk_R27_R73","ACE_Su27S2","ACE_Su27S"];
//    mt_bonus_vehicle_array_SHIP = [];
    mt_bonus_vehicle_array_COM = _mt_bonus_vehicle_CAR + _mt_bonus_vehicle_array_TANK + _mt_bonus_vehicle_array_HELI + _mt_bonus_vehicle_array_AIR;
    mt_descr_len = count (target_names select 0);// number of items in targets array item
    mt_bonus_vehicle_CAR_arr = [_mt_bonus_vehicle_CAR, [], mt_bonus_vehicle_array_COM];
    mt_bonus_vehicle_array_TANK_arr = [_mt_bonus_vehicle_array_TANK, [], mt_bonus_vehicle_array_COM];
    mt_bonus_vehicle_array_HELI_arr = [_mt_bonus_vehicle_array_HELI, [], mt_bonus_vehicle_array_COM ];
    mt_bonus_vehicle_array_AIR_arr = [_mt_bonus_vehicle_array_AIR, [], mt_bonus_vehicle_array_COM ];

//    mt_bonus_vehicle_array_SHIP_arr = [mt_bonus_vehicle_array_SHIP, [], mt_bonus_vehicle_array_COM ];

    player addAction ["Create CAR","scripts\bonus\createBonus.sqf", "CAR"];
    player addAction ["Create TANK","scripts\bonus\createBonus.sqf", "TANK"];
    player addAction ["Create HELI","scripts\bonus\createBonus.sqf", "HELI"];
    player addAction ["Create AIR","scripts\bonus\createBonus.sqf", "AIR"];
//    player addAction ["Create SHIP","scripts\bonus\createBonus.sqf", "SHIP"];
    player addAction ["Bump target","scripts\bonus\createBonus.sqf", "BUMP_TARGET"];
    player addAction ["Teleport to veh","scripts\bonus\createBonus.sqf", "TELE"];
    player addAction ["TURN over...","scripts\bonus\createBonus.sqf", "TURN_OVER"];

    mt_id = 0; // start id for the town list
    flag_at_pos = objNull;
    conus_at_pos = objNull;

	[] execVM "scripts\bonus\bonus_client.sqf";
//	[] execVM "scripts\bonus\bonus_server.sqf";

	_str = "+++ test bonus module initiated";
    hint localize _str;
    player groupChat _str;
};

//
// Sends info to the enterer or his leader if enterer is not the player
//
_sendInfoToPlayer = {
	private ["_this"];
//    hint localize format ["_sendInfoToPlayer: %1", _this];
	if ( typeName _this == "ARRAY") then {_this = format _this};
    player groupChat _this;
    hint localize _this;
};

//
// Sends info in form of format script command ... array parameters
// parameters for format, e.g. ["STR_BONUS_1_1", typeOf _veh] // STR_BONUS_1_1,"Your squad has detected %1! The one who delivered the find to the base will receive points, and the car will be able to fully restore on the service."
//
_sendInfo = {
    if (typeName _this == "ARRAY") then { _this = format _this;  };
    _this call _sendInfoToPlayer;
};


#define AIR_POINT_SEARCH_RANGE 5000
//++++++++++++++++++
// Finds best air bonus position for the designated center point
// call: _pos = _center_pos call _find_air_pos;
// Where return _pos = [ _point_3D_arr, _dir_in_degree ];
// on any error return empty array: (count _pos == 0)
//------------------
_find_air_pos  = {
	private ["_distMin","_posArr","_dist","_veh","_points","_search_range"];
	_points = [
	   [[2547.39,2403.39,0],0],
	   [[2819.55,2637.53,0],0],
	   [[2537.64,3001.69,0],0],
	   [[2376.74,2726.55,0],0],
	   [[9139.74,4699.07,0],70],
	   [[11039.9,4935.83,0],65],
	   [[15481.4,8840.07,0],0],
	   [[14963.5,9071.42,0],160],
	   [[18478.5,12326.5,0],315],
	   [[18423.8,14611.6,0],90],
	   [[11610.1,17691.5,0],250],
	   [[14285.8,12153.9,0],90],
	   [[9360.23,7708,0],110],
	   [[17607.3,18153.2,0],60],
	   [[11344.3,14651.9,0],90],
	   [[8448.13,15346.2,0],320],
	   [[14312.4,13581.9,0],210],
	   [[16256.6,9054.83,0],305],
	   [[10346.1,17005.7,0],75],
	   [[13616,8752.6,0],120],
	   [[8341.69,6307.55,0],120],
	   [[6443.57,7702.82,0],90],
	   [[10350.3,8983.18,0],235],
	   [[6976.53,8380.28,0],55],
	   [[13396.3,7073.32,0],30],
	   [[12197.1,6100.8,0],45]
	];

	_distMin = 9999999;
	_posArr = [];
	_search_range = 0;
	while {count _posArr == 0} do { // while not found any point for the air bonus
		_search_range = _search_range + AIR_POINT_SEARCH_RANGE;	//
		{	// find all points suitable to set air vehicle on it
			_dist = [(_x select 0), _this] call SYG_distance2D;
			if ( _dist <= _search_range ) then {
				_veh = nearestObject [ _x select 0, "Air" ];
				if ( isNull _veh ) then { // no any vehicles near the point
					_posArr set [count _posArr, _x];
				} else { hint localize format[ "+++ createBonus.sqf:  point %1 has air vehicle %2 near", _x select 0, typeOf _veh ]; };
			};
		} forEach _points;
	};
    // select random air point
    _posArr = _posArr call XfRandomArrayVal;
    hint localize format[ "+++ createBonus.sqf:  %1 call _find_air_pos -> %2", _this, _posArr ];
	_posArr
};

//
// Creates bonus vehicle in the designated annulus or on the nearest spawn point for "Plane" vehicles
//
// call as follow: _new_veh = [[_x, _y<,_z>], _rad, _veh_type_name] call _create_bonus_veh;
// on any error returns objNull
//
_create_bonus_veh = {
	if (count _this < 3) exitWith { hint localize format["---_create_bonus_veh: Expected params count 3, found %1", count _this]; objNull };
	private ["_center","_rad","_type","_pos","_is_plane","_dir","_veh","_x"];
	_center = _this select 0;
	if (typeName _center != "ARRAY") exitWith { hint localize format["---_create_bonus_veh: Expected 1st param type is 'ARRAY', found %1", typeName (_this select 0)]; objNull };
	_rad       = _this select 1; // battle zone radious (e.g. town radious)
	_type      = _this select 2; // vehicle type to create
	_pos       = [ _center, _rad * 1.5, _rad * 2 ] call XfGetRanPointAnnulusBig; // position for the land bonus vehicle
	_is_plane  = _type isKindOf "Plane";
	_dir = 0;
	if (_is_plane) then {
		_pos = _center call _find_air_pos; // find nearest position
		_dir = _pos select 1;
		_pos = _pos select 0;
	} else { _dir = random 360 }; // random direction

	_veh = _type createVehicle  [0,0,0];
	_veh setDir _dir;
    _veh setPos _pos;
    if ( !(_veh isKindOf "Ship")) then {
	    if (_veh isKindOf "Air" ) exitWith { _veh setFuel 0.1; _veh setVectorUp [0,0,1] };
	    if ( (_veh isKindOf "LandVehicle") && ((random 10) > 2) ) exitWith { _veh setFuel 0; _veh setVectorUp [0,0,-1] };
    };
    { _veh removeMagazines _x; } forEach magazines _veh;
	sleep 2;
	_veh setDamage 0.5;
	_veh execVM "scripts\bonus\assignAsBonus.sqf"; // assign action to check movement to the base
	_veh
};

// 1. Find nearest settlement/takeoff/sea port to the initial position
// 2. Find  good position in annulus (350-500) of found settlement for land vehicle or
//      on the nearest air takeoff field for planes/helicopters and
//      sea port for ships
// 3. Create and place vehicle with random fuel, health, vertical orientation (for land only) and armament on the point
// 4. Assign vehicle to the ordinal event handling on killing
// 5. Add getin/geout events for this bonus vehicle

_id = 0;
_town_descr = target_names select mt_id;
_cmd = toUpper(_this select 3);
_dir = (random 360);
_town_rad = _town_descr select 2;
hint localize format[ "+++ createBonus.sqf: params: %1 call XfGetRanPointAnnulusBig", [ _town_descr select 0, _town_rad, _town_rad * 1.5 ] ];
sleep 0.01;
_pos = [ _town_descr select 0, _town_rad * 1.5, _town_rad * 2 ] call XfGetRanPointAnnulusBig; // position for the land bonus vehicle

switch ( toUpper _cmd ) do {
    case "AIR": {
        _id = mt_bonus_vehicle_array_AIR_arr call  SYG_findTargetBonusIndex;
        hint localize format["+++ AIR: id = %1", _id];
    };
    case "TANK": {
		if ((_town_descr select 0) call SYG_pointOnIslet) exitWith {
			hint localize  "+++ bonus vehicle creation: Tank bonus can't be on island, replaced by car";
	        _id = mt_bonus_vehicle_CAR_arr call  SYG_findTargetBonusIndex;
		};
        _id = mt_bonus_vehicle_array_TANK_arr call  SYG_findTargetBonusIndex;
    };
    case "HELI": {
        _id = mt_bonus_vehicle_array_HELI_arr call  SYG_findTargetBonusIndex;
    };
    case "CAR": {
        _id = mt_bonus_vehicle_CAR_arr call  SYG_findTargetBonusIndex;
    };
    case "BUMP_TARGET" : {
        _town_descr = target_names select mt_id;
        _mt_id = (mt_id + 1) % (count target_names); // bump to next. If out of count, set 0
        _town_descr1 = target_names select _mt_id;
    	["+++ bump next target: town was %1[%2], changed to %3[%4]", _town_descr select 1, mt_id, _town_descr1 select 1, _mt_id]  call _sendInfo;
    	mt_id = _mt_id;
    };
    case "TELE": {
        // [[9349,5893,0],   "Cayo"      ,210, 2],  //  0
		if (count _town_descr == mt_descr_len) exitWith { // pos was not set before
			["+++ Expected position not set in %1, please set it before next request", _town_descr select 1] call _sendInfo;
		};
		_pos  = _town_descr select mt_descr_len;
        player setPos [ (_pos select 0) -  15, (_pos select 1) - random 15, 0 ] ; // teleport near pos
        player groupChat format["TELEPORT to vehicle in %1", _town_descr select 1];
    };
    case "TURN_OVER": {
    	_veh = nearestObject [player, "LandVehicle"];
    	if (isNull _veh) exitWith {player groupChat format["Expected land vehicle not found in radius 50 meters!"]};
    	_veh = nearestObject [player, "Air"];
    	if (isNull _veh) exitWith {player groupChat format["Expected air vehicle not found in radius 50 meters!"]};
    	_veh = nearestObject [player, "Ship"];
    	if (isNull _veh) exitWith {player groupChat format["Expected ship vehicle not found in radius 50 meters!"]};
    	_veh setVectorUp [0,0,1];
    	_veh setFuel (0.1 max (fuel _veh));
    	_veh call SYG_fastReload;
//    	_veh setDamage 0;
    	player groupChat format["%1 turned up, fueled!", typeOf _veh];
//    	if (!alive _veh) exitWith {player groupChat format["Can't turn over dead vehicle!", typeOf _veh]};
    };
    default {player groupChat format["Command %1 not recognized", _cmd]};
};

if ( _cmd in ["TELE","BUMP_TARGET","TURN_OVER"]) exitWith{}; // sewrvice ocmmand already executed, exit now

// create vehicle now and here

_veh_type = mt_bonus_vehicle_array_COM select _id;

_veh = [_town_descr select 0, _town_descr select 2, _veh_type] call _create_bonus_veh;
_pos = getPos _veh;
_town_descr set[mt_descr_len, _pos];

if (!isNull flag_at_pos) then { deleteVehicle flag_at_pos; };
flag_at_pos = createVehicle [ "FlagCarrierNorth", [(_pos select 0) + 25, (_pos select 1), 0], [], 0, "CAN_COLLIDE" ]; // mark positon by flag at 25 meters to north from the point

//if (!isNull conus_at_pos) then { deleteVehicle conus_at_pos; };
//conus_at_pos = createVehicle [ "RoadCone",_pos, [], 0, "CAN_COLLIDE" ]; // mark center of pos by "RoadConus"

["+++ %1: generated %2 at %3 in %4", _cmd, typeof _veh, _pos, _town_descr select 1 ] call _sendInfo;


