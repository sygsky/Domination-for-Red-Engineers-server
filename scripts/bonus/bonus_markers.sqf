/*
	scripts\bonus\bonus_server.sqf

	author: Sygsky

	description: searches for all still not found bonus vehicles
				 and generates markers for found ones in the form of the road cones on the base

	returns: nothing
*/

//
// TODO: realize the algorithm of bonus vehicle search and corresponding road cones create
//
_center     = d_island_center;
_scale      = 0.001; // scale 1: 100 => 100 m in 1 m
_new_center = getPos cone_map_center;
_cone_type  = "RoadCone";
_xc = _center select 0;     _yc = _center select 1;
_xn = _new_center select 0; _yn = _new_center select 1;

{
	_veh = objNull;
	if (alive _x) then {
		_id = _x getVariable "INSPECT_ACTION_ID";
		if ( isNil "_id" ) exitWith { }; // not vehicle, not bonus vehicle of already registered bonus vehicle
		if (_x in client_bonus_markers_array) exitWith {}; // already markered
		_pos      = getPos _x;
		_new_pos  = [_xn + (((_pos select 0) - _xc) * _scale), _yn + (((_pos select 1) - _yc) * _scale),0];
		_obj      = _cone_type createVehicleLocal _new_pos;
		_obj setVariable [ "bonus_veh", _veh ];
		_obj addAction[ localize "STR_CHECK_ITEM", "scripts\bonus\coneInfo.sqf" ];
	};
} forEach vehicles;