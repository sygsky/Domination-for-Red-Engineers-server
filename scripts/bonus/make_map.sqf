/*
	scripts\bonus\make_map.sqf

	author: Sygsky

	description: searches for all still not found bonus vehicles
				 and generates markers for found ones in the form of the road cones on the base

	returns: nothing
*/

#include "x_setup.sqf"
#include "bonus_def.sqf"

// +++ find all map items on base (road cones with corresponding variable "DOSAAF"
_center_type = switch (d_own_side ) do {
	case "EAST": {"DangerEAST"};
	case "WEST": {"DangerWest"};
	case "RACS": {"DangerGUE"};
	default {"Danger"};
};

// Find all cones near and vehicles attached to tem
_cone_type   = "RoadCone";
_arr = DOSAAF_MAP_POS nearObjects [_cone_type, 55]; // find all conuses
hint localize format[ "+++ make_map.sqf: %1 on base found %2", _cone_type, count _arr ];
_arr_old = [];
_mapped_veh = objNull;
_scale       = DOSAAF_MAP_SCALE; // 0.0025 scale 1: 400 => 400 m in 1 m
_new_center  = DOSAAF_MAP_POS; // central point of the map
_xn = _new_center select 0; _yn = _new_center select 1;
_pos      = _new_center;
_nilCnt = 0; _ready_cnt = 0; _dead_cnt = 0; _cnt = 0;
{
	_mapped_veh = _x getVariable "bonus_veh"; // cone pointer to the vehicle
	_del = false;
	if (!isNil "_mapped_veh") then {
		_var = _mapped_veh getVariable "DOSAAF";
		if (alive _mapped_veh) then {  // if vehicle still not found
			if (isNil "_var") then {
				_ready_cnt = _ready_cnt + 1;
				_del = true;
			} else {
				_arr_old set [count _arr_old, _mapped_veh];
			};
		} else {
			_dead_cnt = _dead_cnt +1;
			_del = true;
		};
	} else {
		_nilCnt = _nilCnt + 1;
		_del = true;
	};
	if (_del) then {
		_x say "steal";
		sleep 0.2;
		deleteVehicle _x; // remove unused item
	} else {
     	// TODO: check if cone is standing good
     	_slope = [0,0,1] distance ( vectorUp _x );
     	if (_slope > 0.2) then { // reset position of the cone
			if ( !isNull _mapped_veh ) then {
				_pos = getPos _mapped_veh;
				_new_pos  = [ _xn + (((_pos select 0) - _xn) * _scale), _yn + (((_pos select 1) - _yn) * _scale), 0 ];
				_x say "return";
				_x setVectorUp [0,0,1];
				_x setVehiclePosition  [ _new_pos, [], 0, "CAN_COLLIDE" ];
				sleep 0.2;
			};
     	};
    };
    sleep 0.1;
}forEach _arr;
hint localize format[ "+++ make_map.sqf: DOSAAF vehicles unused %1, used %2, del %3, clr %4, cone cnt %5", _cnt, _ready_cnt, _dead_cnt, _nilCnt, count _arr ];

//
// create/find map center marker that designates the base
//
_map_marker	  = nearestObject [_new_center, _center_type];
if (isNull _map_marker ) then { // create base sign : "DangerEast"
	_map_marker = _center_type createVehicleLocal _pos;
	_map_marker setVehiclePosition [ _pos, [], 0, "CAN_COLLIDE" ];
	_map_marker addAction[ localize "STR_DOSAAF_UPDATE", "scripts\bonus\make_map.sqf", "" ]; // "Update the DOSAAF map"
	_map_marker addAction[ localize "STR_BASE_TITLE_SHORT", "scripts\bonus\info.sqf", format[localize "STR_BASE_TITLE", 1.0 / DOSAAF_MAP_SCALE] ]; // "DOSAAF map (scale 1:%1): our base"
	_map_marker addAction[ localize "STR_DOSAAF_TITLE", "scripts\bonus\info.sqf", localize "STR_DOSAAF_ABOUT" ]; // "What is DOSAAF"
	hint localize format[ "+++ make_map.sqf: Base map center (%1) created: ""%2""", _center_type, localize "STR_BASE_TITLE_SHORT" ];
//	["msg_to_user", "", [[ localize "STR_DOSAAF_MAP",  _cnt, _ready_cnt, _dead_cnt, _nilCnt]], 0, 105, false, "good_news"] call SYG_msgToUserParser;
} else {
	hint localize format[ "+++ make_map.sqf: Base map center (%1) found", _center_type ];
	["msg_to_user", "", [[ localize "STR_DOSAAF_MAP",  count _arr_old, _ready_cnt, _dead_cnt, _nilCnt]], 0, 5, false, "good_news"] call SYG_msgToUserParser;
};


//
// Get all unknown DOSAAF vehicles in mission list
//
_arr_new = [];
{
	_veh = objNull;
	if (alive _x) then {
		_id = _x getVariable "DOSAAF";
		if ( isNil "_id" ) exitWith { }; // not vehicle, not bonus vehicle of already registered bonus vehicle
		_arr_new set [count _arr_new, _x];
	};
} forEach vehicles;

//
// get new DOSAAF vehicles to add to the map
//
_arr_new = _arr_new - _arr_old; // vehicles to add to the map
hint localize format[ "+++ make_map.sqf: vehicles to add %1", count _arr_new];
{
	_pos = getPos _x;
	_new_pos  = [_xn + (((_pos select 0) - _xn) * _scale), _yn + (((_pos select 1) - _yn) * _scale), 0];
	_cone = _cone_type createVehicleLocal _new_pos;
	_cone setVehiclePosition [ _new_pos, [], 0, "CAN_COLLIDE" ];

	_cone setVariable [ "bonus_veh", _x ];
	_cone addAction[ localize "STR_CHECK_ITEM", "scripts\bonus\coneInfo.sqf" ];
	hint localize format[ "+++ make_map.sqf: Map item (%1) for veh at %2 added near map marker (%3) at dist %4", typeOf _cone, _pos, getPos _cone, [getPos _cone, _map_marker] call SYG_distance2D ];
} forEach _arr_new;

_arr = DOSAAF_MAP_POS nearObjects [_cone_type, 55];
hint localize format[ "+++ make_map.sqf: %1 on map %2", _cone_type, count _arr];

