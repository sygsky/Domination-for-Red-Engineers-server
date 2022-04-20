/*
	scripts\bonus\make_map.sqf

	author: Sygsky

	description: searches for all still not found bonus vehicles
				 and generates markers for found ones in the form of the road cones on the base

	returns: nothing
*/

#include "x_setup.sqf"

// +++ find all map items on base (road cones with corresponding variable "DOSAAF"

_arr = nearObjects[_cone_type, 55];
_nilCnt = 0; _ready_cnt = 0; _dead_cnt = 0; _cnt = 0;
_arr_old = [];
{
	_obj = _x getVariable "bonus_veh";
	_del = false;
	if (!isNil "_obj") then {
		_var = _obj getVariable "DOSAAF";
		if (alive _obj) then {
			if (isNil "_var") then {_ready_cnt = _ready_cnt + 1} else {
				_arr_old set [count _arr_old, _obj];
				_cnt = _cnt + 1;
			} ;
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
		sleep 0.1;
		deleteVehicle _x; // remove unused item
	} else {
     	// TODO: check if cone is standing good
    };
    sleep 0.1;
}forEach _arr;

hint localize format[ "+++ make_map.sqf: DOSAAF vehicles unused %1, used %2, deleted %3, cleared %4", _cnt, _ready_cnt, _dead_cnt, _nilCnt ];

_arr_new = [];
{
	_veh = objNull;
	if (alive _x) then {
		_id = _x getVariable "DOSAAF";
		if ( isNil "_id" ) exitWith { }; // not vehicle, not bonus vehicle of already registered bonus vehicle
		_arr_new set [count _arr_new, _x];
	};
} forEach vehicles;

_arr_add = _arr_new - _arr_old; // vehicles to add to the map
if (count _arr_add > 0) then {
	_scale       = DOSAAF_MAP_SCALE; // 0.0025 scale 1: 400 => 400 m in 1 m
	_new_center  = DOSAAF_CONE_MAP_SERVER; // center of the map
	_cone_type   = "RoadCone";
	_center_type = switch (d_own_side ) do {
		case "EAST": {"DangerEAST"};
		case "WEST": {"DangerWest"};
		case "RACS": {"DangerGUE"};
		default {"Danger"};
	};
	_xn = _new_center select 0; _yn = _new_center select 1;
	// create base sign : "DangerEast"
	_pos      = _new_center;
	_obj	  = nearestObject [_new_center, _center_type];
	if (isNull _obj ) then {
		_obj = _center_type createVehicleLocal _pos;
		_obj setVehiclePosition [ _pos, [], 0, "CAN_COLLIDE" ];
		_obj addAction[ localize "STR_DOSAAF_UPDATE", "scripts\bonus\make_map.sqf", "" ]; // "Update the DOSAAF map"
		_obj addAction[ localize "STR_BASE_TITLE_SHORT", "scripts\bonus\info.sqf", localize "STR_BASE_TITLE" ]; // "DOSAAF map: our base"
		_obj addAction[ localize "STR_DOSAAF_TITLE", "scripts\bonus\info.sqf", localize "STR_DOSAAF_ABOUT" ]; // "What is DOSAAF"
		hint localize format[ "+++ scripts\bonus\make_map.sqf: Base map center (%1) created: ""%2""", _center_type, localize "STR_BASE_TITLE_SHORT" ];
		["msg_to_user", "", [[ localize "STR_DOSAAF_MAP",  _cnt, _ready_cnt, _dead_cnt, _nilCnt]], 0, 110, false, "good_news"] call SYG_msgToUserParser;
	} else { hint localize format[ "+++ Base map center (%1) found", _center_type ] };

	{
		_cone = _cone_type createVehicleLocal _pos;
		_new_pos  = [_xn + (((_pos select 0) - _xn) * _scale), _yn + (((_pos select 1) - _yn) * _scale), 0];
		_obj setVehiclePosition [ _new_pos, [], 0, "CAN_COLLIDE" ];

		_cone setVariable [ "bonus_veh", _x ];
		_obj addAction[ localize "STR_CHECK_ITEM", "scripts\bonus\coneInfo.sqf" ];
		hint localize format[ "+++ scripts\bonus\make_map.sqf: Map item (RoadCone) added = %1 (%2)", _id, localize "STR_BASE_TITLE_SHORT" ];
	} forEach _arr_add;
};
