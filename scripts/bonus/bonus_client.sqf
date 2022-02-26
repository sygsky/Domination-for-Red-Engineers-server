/*
	1.Sara/scripts/bonuses/bonus_client.sqf: draws and control all markers on client
	author: Sygsky
	description: none
	returns: nothing
*/

#include "bonus_def.sqf"

if (!isNil "client_bonus_markers_array") exitWith {}; // already run

private ["_bonus_markers", "_bonus_timestamp", "_bonus_array", "_i", "_veh", "_mrk", "_last_id", "_reset_params"];

while {isNil "client_bonus_markers_array"} do {sleep DELAY_WHILE_NIL};
player groupChat "+++ bonus_client started";
// markers for each markerd bouns vehicle
_bonus_markers         = []; // known veh markers
_bonus_timestamp       = -1;
_bonus_array           = []; // known vehs itself
_next_id = 1;	// next free id for the bonus vehicle markers

//
// reset bonus markers system from the scratch
//
_reset_params = {
	private [ "_veh","_mrk","_ind","_x","_mrk_type","_new_array","_del_arr","_add_arr","_x" ];
	_new_array       = + client_bonus_markers_array; // copy array not assign it
	_bonus_timestamp = client_bonus_markers_timestamp;
	hint localize format["+++ _reset_params: old array[%1], new array[%2]", count _bonus_array, count _new_array];

	_del_arr = _bonus_array - _new_array;
	hint localize format["+++ bonus client: remove %1 vehicle[s]", count _del_arr];
	if (count _del_arr > 0) then { // old veh array
		{
			_ind = _bonus_array find _x;
			hint localize format["+++ bonus client: removed %1", typeOf _x];
			if (_ind >= 0) then {
				deleteMarkerLocal (_bonus_markers select _ind);
				_bonus_markers set [_ind, ""];
				_bonus_array   set [_ind, ""];
			};
			sleep 0.1;
		} forEach _del_arr;
		_bonus_array   = _bonus_array   - [""];
		_bonus_markers = _bonus_markers - [""];
		_del_arr = nil;
	};

	_add_arr = _new_array - _bonus_array; // vehicles to add to the client bonus markers
	hint localize format["+++ bonus client: add %1 vehicle[s]", count _add_arr];
	if (count _add_arr > 0) then { // new veh array
		{
			hint localize format["+++ bonus client: add %1", typeOf _x];
			_mrk = createMarkerLocal [ format[ "_marker_veh_%1", _next_id ], _x ];
			_next_id = _next_id + 1;
			_mrk setMarkerColorLocal MARKER_COLOR;
			_mrk_type = _x call SYG_getVehicleMarkerType;
			_mrk setMarkerTypeLocal _mrk_type;
			hint localize format[ "+++ bonus_client_reset_params: created marker %1 (%2 for %3)", _mrk, _mrk_type, typeOf _x ];
			_mrk setMarkerSizeLocal [ 0.75, 0.75 ];
			_bonus_markers set [ count _bonus_markers, _mrk ];
			_bonus_array   set [ count _bonus_array,     _x ];
			sleep 0.01;
		} forEach _add_arr;
		_add_arr = nil;
	};
	_new_array = nil;
};

//
// eternal loop to redraw moved markers
//
hint localize "+++ bonus_client: main loop started";
_last_id =  (count _bonus_array) - 1;
while { true } do {
	_moved_cnt = 0;
	if ( _bonus_timestamp != client_bonus_markers_timestamp) then { // timestamp changed, reset all
		// global array changed, copy it to the internal buffer
		hint localize format["+++ bonus_client: marker list changed  %1 => %2", count _bonus_array, count client_bonus_markers_array];
		call _reset_params;
		_last_id =  (count _bonus_array) - 1;
	} else {
		// re-draws moved markers, 0-based item is the time-stamp, not markered vehicle
		for "_i" from 0 to  _last_id do {
			_veh = _bonus_array select _i;
			if (alive _veh) then {
				_mrk = _bonus_markers select _i;
				_vpos = getPos _veh;
				_vpos resize 2;
				_mpos = markerPos _mrk;
				_mpos resize 2;
				_dist =  _mpos distance _vpos;
//				hint localize format["+++ bonus_client: veh #%1 moved dist %2", _i, _dist];
				if ( _dist > DIST_TO_REDRAW) then {
					_mrk setMarkerPosLocal _vpos;
					_moved_cnt = _moved_cnt + 1;
					sleep 0.05;
				} else { sleep 0.01};
			};
		};
	};
	if (_moved_cnt  > 0 ) then {
//		hint localize format["+++ bonus_client: vehs moved %2", _moved_cnt];
		sleep DELAY_NORMAL;
	} else { sleep DELAY_LONG };
};