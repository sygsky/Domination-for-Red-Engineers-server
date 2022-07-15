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
// wait antenna and trcu are ready
_cnt = 0;
while { !( (alive d_radar_truck) && (alive d_radar) && _cnt < 300 ) } do { sleep 1; _cnt = _cnt + 1 };

if ( !( (alive d_radar_truck) && (alive d_radar) ) ) exitWith {
    ["msg_to_user","",[["STR_RADAR_FAILED1"]]] call XSendNetStartScriptClientAll;
	side_mission_winner = -702;
	side_mission_resolved = true;
};


// 1. create antenna and trucks on the base

sideradio_status = 0; // 0 - mission in progress, 1 - mast installed, 2- truck returned to the base
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

// 2. wait until antenna killed get it, inform all about antenna damage

// create markers (truck + radiomast)
_truck = d_radar_truck; // current (first) alive truck
_truck_marker = "";
_radar_marker = [ "sideradio_radar_marker", RADAR_MARKER, d_radar, RADAR_SM_COLOR,[0.5, 0.5]] call _make_marker;

//
// Main loop, controls markers movement and end of the mission
//
_truck = objNull;
while { sideradio_status <= 0 } do {

	if (X_MP && ((call XPlayersNumber) == 0)) then {
		waitUntil {sleep (60 + (random 1)); (call XPlayersNumber) > 0};
	};
	_delay = 15;

	if (true) then {
		// check if truck is killed now
		if (!alive d_radar_truck) exitWith { deleteMarker _truck_marker };
		if (alive d_radar_truck && locked d_radar_truck) exitWith { deleteMarker _truck_marker }; // truck not found

	    // create radar marker if needed
		if ((getMarkerType _truck_marker) == "") exitWith {
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
    if (alive d_radar) then { // radar alive
    	_asl = getPosASL d_radar;
        if ( ( _asl select 2) >= 0) then { // unloaded
			if ( (getMarkerType _radar_marker) == "") exitWith { // marker not exists, create it now
				_radar_marker = [ "sideradio_radar_marker", RADAR_MARKER, d_radar, RADAR_SM_COLOR,[0.5, 0.5]] call _make_marker;
			};
			if ( ( [getMarkerPos _radar_marker, d_radar] call SYG_distance2D ) > DIST_TO_SHIFT_MARKER ) then {
				_radar_marker setMarkerPos ( _asl );
			};
        } else {// radar is load in the truck, wipe it from the map
            deleteMarker _radar_marker;
        };
    } else { // radar dead or removed, wait until sideradio_status changes
        deleteMarker _radar_marker;
    };

    // TODO: add random enemy infantry patrols on the way to the destination at certain time intervals,
    // TODO: e.g. on each kilometer close to the mission finish

    if (sideradio_status == 1) exitWith {_truck = d_radar_truck}; // Mast installed, wait until curent truck returned to the base
	sleep _delay;
};

while { (sideradio_status == 1) && (alive d_radar) && (alive d_radar_truck) } do  {
	sleep 5;
	if ( (d_radar_truck distance FLAG_BASE) < 20 ) exitWith { sideradio_status = 2 };
};

if (sideradio_status < 0) then {
	side_mission_winner = -702;
	side_mission_resolved = true;
} else {
	if ( sideradio_status == 2 ) then {
		side_mission_winner = 2;
		side_mission_resolved = true;
	};
};

sleep (5 + (random 5));

//==================================================
//=            Finish the mission                  =
//==================================================

// assign completed codes etc

// remove markers
deleteMarker _radar_marker;
deleteMarker _truck_marker;
// d_radar continue to exists for the future adventures
