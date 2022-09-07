/*
	1.Sara/scripts/bonus/bonus_client.sqf: draws and control all markers on client automatically
	author: Sygsky
	description: none
	returns: nothing
*/

#include "bonus_def.sqf"

if (isNil "client_bonus_markers_array") then {
    client_bonus_markers_array = []; // Never change it from external code!!!
    client_bonus_markers_timestamp = time;
    sleep 10
} else {sleep 2};

hint localize "+++ bonus_client started";
private ["_bonus_markers", "_bonus_timestamp", "_i", "_veh", "_mrk", "_last_id"];

_bonus_markers                 = [];	// known veh markers itself
_next_id                       = 1;		// next free id for the bonus vehicle markers
_bonus_timestamp               = 0;		// last time processed timestamp

[] execVM "scripts\bonus\make_map.sqf";
//
// reset bonus markers system from the scratch
//

_reset_params = {
	private [ "_veh","_mrk","_ind","_x","_mrk_type","_new_array","_del_arr","_add_arr","_update","_x","_cnt" ];
	_time = time;
	_ret = call SYG_countVehicles;
	hint localize format["+++ _reset_params: scan vehicles: cnt/vehs/DOSAAF_0/DOSAAF_NOTREG/alive/markers/bonus = %1", _ret];

	_new_array = call SYG_scanDOSAAFVehicles; // load all alive DOSAAF vehicles
//	hint localize format["+++ SYG_scanDOSAAFVehicles executed in %1 secs ", time - _time];
	if ( (_next_id == 1) ) then {
		if ( count _new_array > 0 ) then {
			private ["_arr"];
			// TODO: add info for posittion of random vehicle in the _new_array
			_arr = [[ localize "STR_BONUS_6", count _new_array]];
			if (count _new_arr > 2) then { // add info about random vehicle from array of size larger than two
				_veh = _new_arr call XfRandomArrayVal;
				_arr set [count _arr, [localize "STR_FORMAT_8",typeOf _veh,  _veh call SYG_MsgOnPos]] ;
			};
			["msg_to_user", "", _arr, 5, 105, false, "good_news"] call SYG_msgToUserParser; // "%1 vehicle of ДОСААФ detected on the island"
		};
	};

	hint localize format["+++ _reset_params: old array[%1], new array[%2]", count client_bonus_markers_array, count _new_array];
	_del_arr = client_bonus_markers_array - _new_array;	// array of vehs to remove (may contain killed vehicles)
	if ( count _del_arr > 0 ) then { // old veh array
		hint localize format["+++ _reset_params: delete %1 vehicle[s]", count _del_arr];
		{
			_ind = client_bonus_markers_array find _x;
			hint localize format["+++ _reset_params: remove id %1", _ind];
			if (_ind >= 0) then {
				deleteMarkerLocal (_bonus_markers select _ind);
				_bonus_markers set [_ind, "RM_ME"];
				client_bonus_markers_array   set [_ind, "RM_ME"];
			};
			sleep 0.1;
		} forEach _del_arr;
		client_bonus_markers_array   = client_bonus_markers_array   - ["RM_ME"];
		_bonus_markers = _bonus_markers - ["RM_ME"];
		_del_arr = nil;
	};

	// remove all killed vehicles from the list
	_update = false;
	for "_i" from 0 to (count client_bonus_markers_array) - 1 do {
		_veh = client_bonus_markers_array select _i;
		if (!alive _veh) then { // killed or null
			deleteMarkerLocal (_bonus_markers select _i);
			_bonus_markers set [_i, "RM_ME"];
			client_bonus_markers_array set [_i, "RM_ME"];
			_update = true;
		};
	};
	if (_update) then {
		_cnt = count client_bonus_markers_array;
		client_bonus_markers_array   = client_bonus_markers_array   - ["RM_ME"];
		_bonus_markers = _bonus_markers - ["RM_ME"];
		hint localize format[ "+++ _reset_params: delete %1 dead vehicle[s]", _cnt -  (count _del_arr) ];
	};

	// now add newly found DOSAAF vehicles
	_add_arr = _new_array - client_bonus_markers_array; // vehicles to add to the client bonus markers
	if (count _add_arr > 0) then { // new veh array
		hint localize format["+++ _reset_params: add %1 vehicle[s]", count _add_arr];
		{
			if (alive _x) then { // only alive vehicles are markered
				hint localize format["+++ bonus_client: add %1", typeOf _x];
				_mrk = createMarkerLocal [ format[ "_marker_veh_%1", _next_id ], _x ];
				_next_id = _next_id + 1;
				_mrk setMarkerColorLocal DOSAAF_MARKER_COLOR;
				_mrk_type = _x call SYG_getVehicleMarkerType;
				_mrk setMarkerTypeLocal _mrk_type;
				hint localize format[ "+++ bonus_client_reset_params: created marker %1 (%2 for %3)", _mrk, _mrk_type, typeOf _x ];
				_mrk setMarkerSizeLocal [ 0.75, 0.75 ];
				_bonus_markers set [ count _bonus_markers, _mrk ];
				client_bonus_markers_array   set [ count client_bonus_markers_array,     _x ];
				sleep 0.01;
			};
		} forEach _add_arr;
		_add_arr = nil;
	};
	_new_array = nil;
	if ((count _bonus_markers) != (count client_bonus_markers_array)) then {format["--- _reset_params: markers cnt %1 != vehs cnt %2", count _bonus_markers, count client_bonus_markers_array]};
};

//
// eternal loop to redraw moved markers
//

//hint localize "+++ bonus_client: main loop started";

while { true } do {
	_moved_cnt = 0;
	_update = false;
	_redraw = false;
	// re-draws shifted markers, remove killed ones
	for "_i" from 0 to ((count client_bonus_markers_array) - 1) do {
		_veh = client_bonus_markers_array select _i;
		if (alive _veh) then {
			_mrk = _bonus_markers select _i;
			_vpos = getPos _veh;
			_vpos resize 2;
			_mpos = markerPos _mrk;
			_mpos resize 2;
			_dist =  _mpos distance _vpos;
//				hint localize format["+++ bonus_client: veh #%1 moved dist %2", _i, _dist];
			if ( _dist > DOSAAF_DIST_TO_REDRAW) then {
				_mrk setMarkerPosLocal _vpos;
				_moved_cnt = _moved_cnt + 1;
				_redraw = true; // update on vehicle movement detected
				sleep 0.05;
			} else { sleep 0.01};
		} else {
			// !alive vehicle detected, remove it from markers
			hint localize format["+++ bonus_client: veh ""%1"" not alive", typeOf _veh];
			_update = true; // update on killed vehicle detection
		};
	};
	if ( _update || ( client_bonus_markers_timestamp != _bonus_timestamp ) ) then {
		_bonus_timestamp = client_bonus_markers_timestamp;
		call _reset_params; // reset markers for DOSAAF vehicles
		hint localize format["+++ bonus_client: timestamp %1%2", _bonus_timestamp, if(_update) then {" detected dead markered vehicle[s], change markers array"} else {""}];
	};
	if (_redraw) then {
//		hint localize format[ "+++ bonus_client: sleep after redraw %1", DOSAAF_DELAY_NORMAL ];
		sleep DOSAAF_DELAY_NORMAL;
	} else {
        if ((count client_bonus_markers_array) == 0) exitWith {
        //	hint localize format[ "+++ bonus_client: loop sleep %1", DOSAAF_DELAY_LONG ];
            sleep DOSAAF_DELAY_LONG;
        }; // wait more as no markers found at all
        //	hint localize format[ "+++ bonus_client: loop sleep %1", DOSAAF_DELAY_STD ];
		sleep DOSAAF_DELAY_STD // wait for an average time, since markers exist but do not move
	};
};