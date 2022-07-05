/*
	x_missions\common\x_sideradio.sqf

	author: Sygsky
	description: controls the installation of an antenna for radio communication with the USSR.
		Draws the markers for active truck and radio-mast,
		check if mission is failed
	params: [x_sm_pos,d_radar,_vehs]
	returns: nothing
*/
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"
#include "sideradio_vars.sqf"

#ifdef __ACE__
#define TRUCK_MARKER "ACE_Icon_Truck"
#else
#define TRUCK_MARKER "SalvageVehicle"
#endif

// 1. create antenna and trucks on the base

sideradio_status = 0; // -1 - mission failured, 0 - mission in progress, 1 - succesfully finished
publicVariable "sideradio_vehs"; // initial information for clients
publicVariable "sideradio_status"; // status of mission, is set on clients only

// _marker_name = [_marker_name, _marker_type, _truck_pos, _marker_color<,_marker_size>] call _make_marker;
_make_marker = {
	private ["_mrk_name"];
	_mrk_name = _this select 0;
	createMarker [_mrk_name, _this select 2 ]; // create marker on pos
	_mrk_name setMarkerColorLocal (_this select 3); // set marker color

	if (count _this > 4) then {
		_mrk_name setMarkerTypeLocal (_this select 1);  // marker type
		_mrk_name setMarkerSize (_this select 4);  // marker size
	} else {
		_mrk_name setMarkerType (_this select 1); // only marker type
	};
	_mrk_name
};

// 2. wait until antenna or both trucks killed get it, inform all about antenna damage

// create markers (truck + radiomast)
_truck = _vehs select 0; // current (first) alive truck
_truck_marker = "";
_radar_marker = [ "sideradio_radar_marker", RADAR_MARKER, d_radar, RADAR_SM_COLOR,[0.5, 0.5]] call _make_marker;

//
// Main loop, controls markers movement and end of the mission
//

while { sideradio_status in [0,1] } do {

	if (X_MP && ((call XPlayersNumber) == 0)) then {
		waitUntil {sleep (60 + (random 1)); (call XPlayersNumber) > 0};
	};
	_delay = 15;

    // check truck marker
    if ( (!alive d_radar_truck) || (locked d_radar_truck) ) then {
    	deleteMarker _truck_marker;
    } else {
	    // create radar marker if needed
		if ((getMarkerType _truck_marker) == "") then {
			_truck_marker = [ "sideradio_truck", TRUCK_MARKER, d_radar_truck, RADAR_SM_COLOR,[0.5, 0.5]] call _make_marker;
			_delay = 3;
		} else {
			if ( ( [getMarkerPos _truck_marker, d_radar_truck] call SYG_distance2D ) > DIST_TO_SHIFT_MARKER ) then {
				_truck_marker setMarkerPos (getPos _truck);
				_delay = 3;
			};
        };
    };
    // check radar marker
    if (alive d_radar) then { // move marker if needed
    	_asl = getPosASL d_radar;
        if ( ( _asl select 2) >= 0) then {
			if ( (getMarkerType _radar_marker) == "") exitWith { // marker not exists, create it now
				_radar_marker = [ "sideradio_radar_marker", RADAR_MARKER, d_radar, RADAR_SM_COLOR,[0.5, 0.5]] call _make_marker;
			} else {
				if ( ( [getMarkerPos _radar_marker, d_radar] call SYG_distance2D ) > DIST_TO_SHIFT_MARKER ) then {
					_radar_marker setMarkerPos ( _asl );
				};
			};
        } else {	// radar is in truck, wipe it from map
            deleteMarker _radar_marker;
        };
    } else {
        deleteMarker _radar_marker;
    };
	sleep _delay;
};

if (sideradio_status < 0) then { side_mission_winner = -702 } else {side_mission_winner = 2};
side_mission_resolved = true;

sleep (5 + (random 5));

//==================================================
//=            Finish the mission                  =
//==================================================

// assign completed codes etc

// remove markers
deleteMarker _radar_marker;
deleteMarker _truck_marker;

// Eject crew from truck
if (alive d_radar_truck) then {
//		_x lock true;
	{ d_radar_truck action ["Eject", d_radar_truck] } forEach (crew d_radar_truck);
	_x setFuel 0;
};

sideradio_status = nil;
publicVariable "sideradio_status";
// d_radar continue to exists for the future adventures
