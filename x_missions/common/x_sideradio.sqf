/*
	author: Sygsky
	description: controls the installation of an antenna for radio communication with the USSR.
	returns: nothing
*/
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

#define RADAR_POINT = [13592,15591,0] // central point of the area to install radar
#define INSTALL_RADIUS 2000 // how far from the RADAR_POINT
#define INSTALL_MIN_ALTITUDE 450 // minimal height above sea level to install
#define RADAR_MARKER "Arrow" // BIS marker for radar
#define SM_MARKER "Unknown" // BIS marker for question sign

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
	if (radar_loaded) exitWith {"SYS_RADAR_0"}; // "Radar in loaded state, unload it before check"
	_pos = getPosASL _radar;
	if ( ([_pos, RADAR_POINT] call SYG_distance2D) > INSTALL_RADIUS) exitWith {"SYS_RADAR_1"}; // "You are too far from the installation zone"
	if ( (_pos select 2) < INSTALL_MIN_ALTITUDE ) exitWith {"SYS_RADAR_2"}; // "Radar must be installed on height not lower than %1 m., now you at %2 m."
	if ( (_radar call SYG_vehUpAngle) < 85 ) exitWith {"SYS_RADAR_3"}; // "The radar is set at a slope of %1 degree. Set it at an inclination of no more than 5 degrees"
	"" // Reached, no error !!!
};

// 1. create antenna and trucks on the base

_radar = _this select 0; // Radar
_vehs  = _this select 1; // two trucks to load/install radiomast

// 2. wait until antenna or both trucks killed get it, inform all about antenna damage
while { ((alive _radar) && ( ({alive _x} count _vehs) > 0)) && (!radar_installed)} do {
	sleep 3;
};
sleep 10 + random 5;
// remove crew from trucks
{
	if (alive _x) then {
		_x lock true;
		{ if (alive _x) then { _x action ["Eject", _x]; }; } forEach (crew _x);
	};
} forEach _vehs;

radar_installed = nil;