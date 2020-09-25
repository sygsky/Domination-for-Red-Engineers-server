/*
	author: Sygsky
	description: called from STATUS dialog to set SPPM marker (if in vehicle) or check SPPM markers (if not in vehicle)
	returns: nothing
*/

#define SPPM_MIN_DISTANCE 50 // Minimum distance at which the nearest SPPM can be located
#define SPPM_VEH_MIN_DISTANCE 10 // Minimum distance at which vehicles in SMPPM must be located
#define SPPM_OBJ_TYPE "ACE_Target_CArm" // SPPM invisible object for search

hint localize "+++ scripts/sppm.sqf: check/set SPPM marker[s]";
// 0. Check if player is on base
if (! ([_pos,d_base_array] call SYG_pointInRect)) exitWith {
	(localize "STR_SPPM_2") call XfHQChat; // "SPPM marker can't be created on the base"
};

if (! vehicle player == player) exitWith {
	(localize "STR_SPPM_1") call XfHQChat; // "All SPPM markers will be renewed (you are not in vehicle)"
};

// 1. Check if current vehicle is in existing SPPM or existing SPPM is closer then 50 meters

// Find nearest SPPM
_nearSPPMPos = player call SYG_findNearestSPPM;

// 2. If vehicle is in near SPPM, update it and exit // "STR_SPPM_4"
// 3. If vehicle is not in SPPM, create new marker for SPPM
(localize "STR_SPPM_3") call XfHQChat; // "You are in vehicle, no SPPM marker detected near around, the new one can be created";
