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

_vehs  = +_this; // two trucks to load/install radiomast

sideradio_vehs = _vehs;
sideradio_status = 0; // -1 - mission failured, 0 - mission not finished, 1 - succesfully finished
publicVariable "sideradio_vehs"; // initial information for clients
publicVariable "sideradio_status"; // status of mission, is set on clients only

// 2. wait until antenna or both trucks killed get it, inform all about antenna damage

// create markers (truck + radiomast)
_truck = _vehs select 0; // current (first) alive truck
_truck_marker = "sideradio_truck_marker";
createMarker [_truck_marker, _truck ];
_truck_marker setMarkerColorLocal RADAR_SM_COLOR;
_truck_marker setMarkerTypeLocal TRUCK_MARKER;
_truck_marker setMarkerSizeLocal [0.5, 0.5];

_radar_marker = "sideradio_radar_marker";
createMarker [_radar_marker, d_radar ];
_radar_marker setMarkerColorLocal RADAR_SM_COLOR;
_radar_marker setMarkerTypeLocal RADAR_MARKER;
_radar_marker setMarkerSizeLocal [0.5, 0.5];

//
// Main loop, controls markers movement and end of the mission
//
while { sideradio_status == 0 } do {

	if (X_MP && ((call XPlayersNumber) == 0)) then {
		waitUntil {sleep (60 + (random 1)); (call XPlayersNumber) > 0};
	};
	_delay = 15;

    // check markers
    _marker_pos = [];
    if (!alive _truck) then {
        // remove truck marker just in case
        _new_truck = _vehs select 1;
        if (alive _new_truck) then {
            _truck = _new_truck;
            _truck lock false;
            _marker_pos = getPos _new_truck;
            _delay = 3;
        } else {
            deleteMarker _truck_marker;
        };
    };
    if (alive _truck ) then { // move marker if truck is shifted
        if ( ( [getMarkerPos _truck_marker, _truck] call SYG_distance2D ) > DIST_TO_SHIFT_MARKER ) then {
            _marker_pos = getPos _truck;
        };
    };
    
    if (count _marker_pos > 0) then { _truck_marker setMarkerPos (getPos _new_truck); _delay = 3; };

    if (alive d_radar) then { // move marker if
    	_pos = getPosASL d_radar;
        if ( ( _pos select 2) >= 0) then {
            if ( ( [getMarkerPos _radar_marker, d_radar] call SYG_distance2D ) > DIST_TO_SHIFT_MARKER ) then {
            	if ( (getMarkerType _radar_marker) == "") then { // marker not exists, create it now
            		_radar_marker = createMarker [_radar_marker, _pos]; //RADAR_MARKER;
            		_radar_marker setMarkerTypeLocal RADAR_MARKER;
            		_radar_marker setMarkerColor RADAR_SM_COLOR;
            	} else {
            		_radar_marker setMarkerColorLocal RADAR_SM_COLOR;
	                _radar_marker setMarkerPos ( _pos );
            	};
            	_delay = 3;
            };
        } else {
#ifdef __ACE__
        	_radar_marker setMarkerColorLocal "ACE_ColorTransparent";
#else
            deleteMarker _radar_marker;
#endif
        };
    } else {
        deleteMarker _radar_marker;
    };
	sleep _delay;
};

if (sideradio_status < 0) then { side_mission_winner = -702 } else {side_mission_winner = 2};
side_mission_resolved = false;

sleep (5 + (random 5));

//==================================================
//=            Finish the mission                  =
//==================================================

// assign completed codes etc

// remove markers
deleteMarker _radar_marker;
deleteMarkerLocal _truck_marker;

// Eject crew from trucks
{
	if (alive _x) then {
		_x lock true;
		{ _x action ["Eject", _x] } forEach (crew _x);
	};
} forEach _vehs;

sideradio_vehs = nil;
publicVariable "sideradio_vehs";
sideradio_status = nil;
publicVariable "sideradio_status";
// d_radar continue to exists for the future adventures
