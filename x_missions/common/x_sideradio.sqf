/*
	x_missions\common\x_sideradio.sqf

	author: Sygsky
	description: controls the installation of an antenna for radio communication with the USSR.
		Draws the markers for active truck and radio-mast,
		check if mission is failed.
		Really the flow of script is as follow:
		Radar and truck are recreated after each destroy (while script radio_service.sqf is running)
		The truck can be destroyed/found an arbitrary number of times until the radio mast is intalled

		1. If current radar is killed, mission is counted is failed
		2. If current radar is installed, wait until current truck is reached GRU PC.
		3. If last truck or current radar are destroyed, mission is counted as failed.

		Markers:
		All the time markers are drown for radar (if unloaded) and truck.
		If punkt 1 is reached radar marker is cleared.
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

_mission = true; // (!= 0) is mission; (== 0) not mission
if (!isNil "_this") then {
    switch (typeName _this) do {
        case   "BOOL": { _mission = _this };
        case "STRING": { _mission =  !((toUpper this) in ["NO_MISSION","NOT_MISSION"]); };
        case "SCALAR": { _mission =  _this != 0 };
        default {};
    };
};

hint localize (if (_mission) then { format["+++ x_sideradio.sqf: _this = %1, is it mission run !!!", _this] } else { format["+++ x_sideradio.sqf: _this = %1, is NOT mission run !!!", _this] });

// wait (new) antenna to alive or recreated by radio_service.sqf
_cnt = 0;
_time  = time;
while { ! ( (alive d_radar) && (_cnt >= 100) ) } do { sleep 5; _cnt = _cnt + 1 };

// if no radar and it is mission, exit with failure code
if (_mission && (!( (alive d_radar) && ( _cnt < 100) ) ) ) exitWith {
	hint localize format["+++ x_sideradio.sqf: no radar created in %1 seconds, exit!!!", round (time - _time)];
	["msg_to_user","",[["STR_RADAR_FAILED1"]]] call XSendNetStartScriptClient; // "Not a single radio relay mast could be found on the entire island. That's sad!"
	if (_mission) then {
		side_mission_winner = -702;
		side_mission_resolved = true;
	};
};

// radar is alive now
_radar = d_radar;

if (sideradio_status == 2) then {
	hint localize "+++ x_sideradio.sqf: sideradio_status == 2, wait status change";
	_time = time;
	waitUntil {sleep 60; sideradio_status != 2};
	_str = [ time,_time] call SYG_timeDiffToStr;
	hint localize format["+++ x_sideradio.sqf: sideradio_status == %1, changed after %2", sideradio_status, _str];
};

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

// Antenna/trucks are recreated in rado_service.sqf running during whole misssion

// prepare markers (truck + radiomast)
_truck = d_radar_truck; // current (first) alive truck
_truck_marker = "";
_radar_marker = ""; //

//
// Main loop, controls markers movement and end of the mission
// Radar can't be destroyed else sidemission is failed
//
hint localize format["+++ x_sideradio.sqf: enter marker loop, status %1", sideradio_status];
while { (alive _radar) && (sideradio_status <= 0) } do { // 0 state is allowed

	if ( X_MP && ((call XPlayersNumber) == 0) ) then {
		waitUntil {sleep (60 + (random 1)); (call XPlayersNumber) > 0};
	};
	_delay = 15;

	// check truck marker
	if ( alive d_radar_truck ) then {
		if ( locked d_radar_truck ) exitWith {  // truck is locked that means it is not found
			if (_truck_marker != "") then {
				deleteMarker _truck_marker; _truck_marker = "";
			};
		};

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

	//
    // process markers of this side mission
    //
    if ((alive _radar) && (sideradio_status != 2)) then { // radar alive
    	_asl = getPosASL _radar;
        if ( ( _asl select 2) >= 0) then { // radar is unloaded, so it stands/lays on the land somewhere
			// check if radar is already detected
			_detected = _radar getVariable "DETECTED";
			if (!isNil "_detected") then { // alive, not installed, detected
				if ( _radar_marker == "") then { // marker not exists, create it now
					_radar_marker = [ "sideradio_radar_marker", RADAR_MARKER, _radar, RADAR_SM_COLOR, [0.5, 0.5] ] call _make_marker;
				} else {
					// marker exists, move it if needed
					if ( ( [getMarkerPos _radar_marker, _radar] call SYG_distance2D ) > DIST_TO_SHIFT_MARKER ) then {
						_radar_marker setMarkerPos ( _asl );
					};
				};
			};
        } else {    // radar is load into the truck, wipe it from the map
            if ( _radar_marker != "" ) then {
                deleteMarker _radar_marker; _radar_marker = ""
            };
        };
    } else { // radar dead or installed, wait until sideradio_status changes
        if ( _radar_marker != "" ) then {
            deleteMarker _radar_marker; _radar_marker = ""
        };
    };

    // TODO: add random enemy infantry patrols on the way to the destination at certain time intervals,
    // TODO: e.g. on each kilometer close to the mission finish

    if (sideradio_status == 1 ) exitWith {_truck = d_radar_truck}; // Mast installed, wait until curent truck returned to the base
	sleep _delay;
};
hint localize format["+++ x_sideradio.sqf: exit marker loop, status %1", sideradio_status];

hint localize format["+++ x_sideradio.sqf: enter truck return loop, status %1", sideradio_status];
while { (sideradio_status == 1) && (alive _radar) && (alive _truck) } do  {
	sleep 5;
	if ( (_truck distance (call SYG_computerPos)) < 20 ) exitWith { sideradio_status = 2; publicVariable "sideradio_status" }; // may be use point of FLAG_BASE as finish one?
};
hint localize format["+++ x_sideradio.sqf: exit truck return loop, status %1", sideradio_status];

if (_mission) then { // check victory or failure
    if ( sideradio_status == 2 ) then { // Victory!
        side_mission_winner = 2;
        side_mission_resolved = true;
    } else {    // Failure
        side_mission_winner = -702;
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
if (_mission) then {
    // start the main loop, because there should be no more missions with the radio relay
    [] spawn {
		private [ "_handle" ];
		while {true} do {
			_handle  = "NOT_MISSION" execVM "x_missions\common\x_sideradio.sqf";
			while {!scriptDone _handle} do { sleep 60 };
		}
    };

};
