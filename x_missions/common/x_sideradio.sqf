/*
	author: Sygsky
	description: controls the installation of an antenna for radio communication with the USSR.
	params: [x_sm_pos,_radar,_vehs]
	returns: nothing
*/
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

#define RADAR_POINT = [13592,15591,0]   // central point of the area to install radar
#define INSTALL_RADIUS 2000             // how far from the RADAR_POINT
#define INSTALL_MIN_ALTITUDE 450        // minimal height above sea level to install
#define RADAR_MARKER "Arrow"            // BIS marker for radar
#define SM_MARKER "Unknown"             // BIS marker for question sign
#define DIST_TO_SHIFT_MARKER 25         // distance to change marker position

#ifdef __ACE__
#define TRUCK_MARKER "ACE_Icon_Truck"
#else
#define TRUCK_MARKER "SalvageVehicle"
#endif
//
// Returns "" if radar is installed on correct height and place, else return MSG CSV error code
//
_destination_error = {
	private ["_pos"];
	if (radar_loaded) exitWith {"STR_RADAR_0"}; // "Radar in loaded state, unload it before check"
	_pos = getPosASL _radar;
	if ( ([_pos, RADAR_POINT] call SYG_distance2D) > INSTALL_RADIUS) exitWith {"STR_RADAR_1"}; // "You are too far from the installation zone"
	if ( (_pos select 2) < INSTALL_MIN_ALTITUDE ) exitWith {"STR_RADAR_2"}; // "Radar must be installed on height not lower than %1 m., now you at %2 m."
	if ( (_radar call SYG_vehUpAngle) < 85 ) exitWith {"STR_RADAR_3"}; // "The radar is set at a slope of %1 degree. Set it at an inclination of no more than 5 degrees"
	"" // Reached, no error !!!
};

// 1. create antenna and trucks on the base

_radar = _this select 1; // Radar
_vehs  = _this select 2; // two trucks to load/install radiomast

sideradio_info = [ _radar, _vehs ];
sideradio_status = 0; // -1 - mission failured, 0 - mission not finished, 1 - succesfully finished
publicVariable "sideradio_info"; // initial information for clients
publicVariable "sideradio_status"; // status of mission, is set on clients only

// 2. wait until antenna or both trucks killed get it, inform all about antenna damage

// create markers (truck + radiomast)
_truck = _vehs select 0; // current alive truck
_truck_marker = "sideradio_truck_marker";
createMarker [_truck_marker, _truck ];
_truck_marker setMarkerColorLocal "ColorBlack";
_truck_marker setMarkerTypeLocal TRUCK_MARKER;
_truck_marker setMarkerSizeLocal [0.5, 0.5];

_radar_marker = "sideradio_truck_marker";
createMarker [_radar_marker, _radar ];
_radar_marker setMarkerColorLocal "ColorBlack";
_radar_marker setMarkerTypeLocal RADAR_MARKER;
_radar_marker setMarkerSizeLocal [0.5, 0.5];

while { sideradio_status == 0 } do {
    // check markers
    if (!alive _truck) then {
        // remove truck marker just in case
        _new_truck = _vehs select 1;
        if (alive _new_truck) then {
            _truck = _new_truck;
            _truck_marker setMarkerPos (getPos _new_truck);
        } else {
            deleteMarker _truck_marker;
        };
    };
    if (alive _truck ) then { // move marker if truck is shifted
        if ( ( [getMarkerPos _truck_marker, _truck] call SYG_distance2D ) > DIST_TO_SHIFT_MARKER ) then {
            _truck_marker setMarkerPos ( getPos _truck );
        };
    };
    if (alive _radar) then { // move marker if
        if ((_radar call _radarUnloaded)) then {
            if ( ( [getMarkerPos _radar_marker, _radar] call SYG_distance2D ) > DIST_TO_SHIFT_MARKER ) then {
                _radar_marker setMarkerPos ( getPos _radar );
            };
        } else {
            deleteMarker _radar_marker;
        };
    } else {
        deleteMarker _radar_marker;
    };
	sleep 3;
};
sleep (10 + (random 5));

// remove crew from trucks
{
	if (alive _x) then {
		_x lock true;
		{ if (alive _x) then { _x action ["Eject", _x]; }; } forEach (crew _x);
	};
} forEach _vehs;

sideradio_info = nil;
publicVariable "sideradio_info";
sideradio_status = nil;
publicVariable "sideradio_status";
