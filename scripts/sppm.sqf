/*
	scripts\sppm.sqf

	author: Sygsky
	description: called from STATUS dialog to set SPPM marker (if in vehicle) or check SPPM markers (if not in vehicle)
	returns: nothing
*/

#define SPPM_MIN_DISTANCE 50 // Minimum distance at which the nearest SPPM can be located
#define SPPM_VEH_MIN_DISTANCE 20 // Minimum distance between vehicle  and SPPM
#define SPPM_OBJ_TYPE "ACE_Target_CArm" // SPPM invisible object for search

hint localize "+++ scripts/sppm.sqf: check/set SPPM marker[s]";
// 0. Check if player is on base
_pos = player call SYG_getPos;
hint localize format["+++ sppm.sqf: [player call SYG_getPos, d_base_array] = %1", [ _pos, d_base_array]];

if ((vehicle player == player)) exitWith {
	(localize "STR_SPPM_1") call XfHQChat; // "All SPPM markers will be renewed (you are not in vehicle)"
	call SYG_updateAllSPPMMarkers;
};

if ( ([player call SYG_getPos, d_base_array] call SYG_pointInRect) ) exitWith {
	(localize "STR_SPPM_2") call XfHQChat; // "SPPM marker can't be created on the base"
};

// 1. Check if current vehicle is in existing SPPM or existing SPPM is closer then 50 meters
_str = _pos call SYG_addSPPMMarker;

(localize _str) call XfHQChat; // "You are in vehicle, no SPPM marker detected near around, the new one can be created";
