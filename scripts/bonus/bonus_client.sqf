/*
	1.Sara/scripts/bonus/bonus_client.sqf: draws and control all markers on client automatically
	author: Sygsky
	description: none
	returns: nothing
*/

#include "bonus_def.sqf"

// if (!isNil "client_bonus_markers_array") exitWith {hint localize format ["+++ As (!isNil client_bonus_markers_array), then exit"]}; // already run

private ["_bonus_markers", "_bonus_timestamp", "_i", "_veh", "_mrk", "_last_id"];
hint localize "+++ bonus_client started";

client_bonus_markers_timestamp = time; // start marker drawing
client_bonus_markers_array     = [];	// load all veh markers found in vehicles collection
_bonus_markers                 = [];	// known vehs itself
_next_id                       = 1;		// next free id for the bonus vehicle markers
_bonus_timestamp               = 0;

//
// reset bonus markers system from the scratch
//

_reset_params = {
	private [ "_veh","_mrk","_ind","_x","_mrk_type","_new_array","_del_arr","_add_arr","_update","_x","_cnt" ];
	_time = time;

	_ret = call SYG_countVehicles;
	hint localize format["+++ _reset_params: scan vehicles: cnt/ vehs/ DOSAAF/alive /markers /bonus = %2", typeOf _veh, _ret];

	_new_array = call SYG_scanDOSAAFVehicles; // load all alive DOSAAF vehicles
//	hint localize format["+++ SYG_scanDOSAAFVehicles executed in %1 secs ", time - _time];
	if ( (_next_id == 1) ) then {
		if ( count _new_array > 0 ) then {
			["msg_to_user", "", [[ localize "STR_BONUS_6", count _new_array]], 0, 105, false, "good_news"] call SYG_msgToUserParser; // "%1 vehicle of ДОСААФ detected on the island"
		};
	};

	hint localize format["+++ _reset_params: old array[%1], new array[%2]", count client_bonus_markers_array, count _new_array];
	_del_arr = client_bonus_markers_array - _new_array;	// array of vehs to remove (may contain killed vehicles)
	if (count _del_arr > 0) then { // old veh array
		hint localize format["+++ _reset_params: delete %1 vehicle[s]", count _del_arr];
		{
			_ind = _x call SYG_getVehIndexFromVehicles;
			hint localize format["+++_reset_params: remove id %1", _ind];
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
				hint localize format["+++ bonus client: add %1", typeOf _x];
				_mrk = createMarkerLocal [ format[ "_marker_veh_%1", _next_id ], _x ];
				_next_id = _next_id + 1;
				_mrk setMarkerColorLocal MARKER_COLOR;
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

hint localize "+++ bonus_client: main loop started";
_last_id =  (count client_bonus_markers_array) - 1;


while { true } do {
	_moved_cnt = 0;
	_update = false;
	_last_id =  (count client_bonus_markers_array) - 1;
	// re-draws moved markers, 0-based item is the time-stamp, not markered vehicle
	for "_i" from 0 to _last_id do {
		_veh = client_bonus_markers_array select _i;
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
				_update = true; // update on vehicle movement detected
				sleep 0.05;
			} else { sleep 0.01};
		} else {
			// !alive vehicle detected, remove it from markers
			_update = true; // update on killed vehicle detection
		};
	};
	if ( _update || ( client_bonus_markers_timestamp != _bonus_timestamp ) ) then {
		call _reset_params; // reset markers for DOSAAF vehicles
		if ( client_bonus_markers_timestamp != _bonus_timestamp ) then {
			hint localize format["+++ bonus_client: timestamp changed old %1, new %2", _bonus_timestamp, client_bonus_markers_timestamp];
			_bonus_timestamp = client_bonus_markers_timestamp;
		};
		_update = true; // update on list change
	};
	if (_update ) then {
		hint localize format[ "+++ bonus_client: sleep after update %1", DELAY_NORMAL ];
		sleep DELAY_NORMAL;
	} else {
		hint localize format[ "+++ bonus_client: loop sleep %1", DELAY_LONG ];
		sleep DELAY_LONG
	};
};