/*
	x_missions\common\x_sideradio.sqf

	author: Sygsky
	description: controls the installation of an antenna for radio communication with the USSR.
		Draws the markers for active truck and radio-mast,
		check if mission is failed.
		Really the flow of script is as follow:
		Radar and truck are recreated after each destroy (see script radar-service.sqf logic)
		1. Wait until radar is installed correctly (sideradio_status == 1).
		2. Wait until last truck (used to install radar on correct position) is reached the base, then SM is finished successfully.
		3. If last truck or radar is destroyed, mission is counted as failed.

		Markers:
		All the time markers are drown for radar (if unloaded) and truck.
		After point 1 is reached radar marker is cleared.
		After success or failure all markers are cleared.

		The need for the radio relay does not disappear after completing a mission.
		If a mast is destroyed, it must be rebuilt again under the same conditions.

	params: nothing
	returns: nothing
*/
if ( !isServer ) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"
#include "sideradio_vars.sqf"

#ifdef __ACE__
#define TRUCK_MARKER "ACE_Icon_Truck"
#else
#define TRUCK_MARKER "SalvageVehicle"
#endif

_mission = true; // (>0) is mission; (<= 0) not mission
if (!isNil "_this") then {
    switch (typeName _this) do {
        case   "BOOL": { _mission = _this };
        case "STRING": { _mission =  !((toUpper this) in ["NO_MISSION","NOT_MISSION"]); };
        case "SCALAR": { _mission =  _this != 0 };
        default {};
    };
};

// wait (new) antenna and (new) truck is alive or recreated by radio_service.sqf
_cnt = 0;
while { !( (alive d_radar_truck) && (alive d_radar) && _cnt < 60 ) } do { sleep 5; _cnt = _cnt + 1 };

if ( !( (alive d_radar_truck) && (alive d_radar) ) ) exitWith {
    ["msg_to_user","",[["STR_RADAR_FAILED1"]]] call XSendNetStartScriptClient;
    if (_mission) then {
        side_mission_winner = -702;
        side_mission_resolved = true;
    };
};

// 1. create antenna and trucks on the base

sideradio_status = 0; // 0 - mission in progress, 1 - mast installed truck not reached the base, 2- truck reached the base
publicVariable "sideradio_status"; // status of mission, after this setting can be changed on clients only

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
_radar_marker = ""; //

//
// Main loop, controls markers movement and end of the mission
//
_truck = objNull;
while { sideradio_status <= 0 } do { // -1, 0 states are allowed

	if ( X_MP && ((call XPlayersNumber) == 0) ) then {
		waitUntil {sleep (60 + (random 1)); (call XPlayersNumber) > 0};
	};
	_delay = 15;

	if ( alive d_radar_truck ) then {
		if ( locked d_radar_truck ) exitWith { deleteMarker _truck_marker; _truck_marker = ""  }; // truck is locked that means it is not found

	    // create radar marker if needed
		if ( _truck_marker == "" ) then {
			_truck_marker = [ "sideradio_truck", TRUCK_MARKER, d_radar_truck, RADAR_SM_COLOR,[0.5, 0.5]] call _make_marker;
			_delay = 3;
		} else {
            // move existing truck marker if needed
            if ( ( [getMarkerPos _truck_marker, d_radar_truck] call SYG_distance2D ) > DIST_TO_SHIFT_MARKER ) then {
                _truck_marker setMarkerPos (getPos d_radar_truck);
                _delay = 3;
            };
		};
	} else { // truck dead, remove marker while new truck will be created
	    if ( _truck_marker != "" ) then {
	        deleteMarker _truck_marker; _truck_marker = ""
	    };
	};

    // check radar marker
    if (alive d_radar) then { // radar alive
    	_asl = getPosASL d_radar;
        if ( ( _asl select 2) >= 0) then { // radar is unloaded, so it stands on the land somewhere
			if ( _radar_marker == "") then { // marker not exists, create it now
				_radar_marker = [ "sideradio_radar_marker", RADAR_MARKER, d_radar, RADAR_SM_COLOR, [0.5, 0.5] ] call _make_marker;
			} else {
                // marker exists, move it if needed
                if ( ( [getMarkerPos _radar_marker, d_radar] call SYG_distance2D ) > DIST_TO_SHIFT_MARKER ) then {
                    _radar_marker setMarkerPos ( _asl );
                };
			};
        } else {    // radar is load into the truck, wipe it from the map
            if ( _radar_marker != "" ) then {
                deleteMarker _radar_marker; _radar_marker = ""
            };
        };
    } else { // radar dead or removed, wait until sideradio_status changes
        if ( _radar_marker != "" ) then {
            deleteMarker _radar_marker; _radar_marker = ""
        };
    };

    // TODO: add random enemy infantry patrols on the way to the destination at certain time intervals,
    // TODO: e.g. on each kilometer close to the mission finish

    if (sideradio_status == 1) exitWith {_truck = d_radar_truck}; // Mast installed, wait until curent truck returned to the base
	sleep _delay;
};

while { (sideradio_status == 1) && (alive d_radar) && (alive _truck) } do  {
	sleep 5;
	if ( (_truck distance FLAG_BASE) < 20 ) exitWith { sideradio_status = 2; publicVariable "sideradio_status" };
};

if (_mission) then { // check victory or failure
    if ( sideradio_status == 2 ) then { // Victory!
        side_mission_winner = 2;
        side_mission_resolved = true;
    } else {    // Failure
        side_mission_winner = -702;
        side_mission_resolved = true;
    };
    // now start the main loop, because there should be no more missions with the radio relay
    while {true} do {
        _handle  = "NO_MISSION" execVM "x_missions\common\x_sideradio.sqf";
        while {!scriptDone _handle} do { sleep 60 };
    }
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
