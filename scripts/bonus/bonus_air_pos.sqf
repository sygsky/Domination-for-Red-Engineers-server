/*
	scripts\bonus\bonus_air_pos.sqf
	author: Sygsky
	description: find bonus plane position on the island Sahrani
	call as follows: [_x,_y<,_z>] execVM "scripts\bonus\bonus_air_pos.sqf";
	returns: the input array contains result
*/

#define AIR_POINT_SEARCH_RANGE 2500
//++++++++++++++++++
// Finds best air bonus position for the designated center point
// call: _pos = _center_pos call _find_air_pos;
// Where return _pos = [ _point_3D_arr, _dir_in_degree ];
// on any error return empty array: (count _pos == 0)
//------------------
_find_air_pos  = {
	private ["_distMin","_posArr","_dist","_veh","_points","_search_range","_x"];
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
	   [[13691,8741,0], 130], //Old value [[13616,8752.6,0],120] - air20 near SE port in Corazol
	   [[8341.69,6307.55,0],120],
	   [[6443.57,7702.82,0],90],
	   [[10350.3,8983.18,0],235],
	   [[6976.53,8380.28,0],55],
	   [[13396.3,7073.32,0],30],
	   [[12197.1,6100.8,0],45],
	   [[17987,19002,0],150] // Antigua
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
				} else { hint localize format[ "+++ bonus_air_pos.sqf:  point %1 has air %2 near", _x select 0, typeOf _veh ]; };
			};
		} forEach _points;
	};
    // select random air point
    _posArr = _posArr call XfRandomArrayVal;
    hint localize format[ "+++ bonus_air_pos.sqf:  %1 call _find_air_pos -> %2", _this, _posArr ];
	_posArr
};

//
// ++++ MAIN CODE ++++
// _this = _pos;
_pos  = _this; // input array address
_pos1 = +_this;
_pos1 = _pos1 call _find_air_pos;
_pos resize 2; // resize input array to accept 2 items on return from script
// store result in input array to go through execVM call
_pos set [0, _pos1 select 0]; // air creation point
_pos set [1, _pos1 select 1]; // air creation dir
