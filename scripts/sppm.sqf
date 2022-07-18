/*
	scripts\sppm.sqf

	author: Sygsky
	description: called from STATUS dialog to set SPPM marker (if in vehicle) or check SPPM markers (if not in vehicle)
	returns: nothing
*/

//#define SPPM_OBJ_TYPE "ACE_Target_CArm" // SPPM invisible object for search
#define SPPM_UPDATE_INTERVAL_SECS 15 // interval in seconds to update SPPM markers on server
#define SPPM_ADD_INTERVAL_SECS 60 // interval in seconds to add next SPPM marker on server

hint localize "+++ scripts/sppm.sqf: check/set SPPM marker[s]";
// 0. Check if player is on base

if ( (time - SYG_recentSPPMCmdUseTime ) < SPPM_UPDATE_INTERVAL_SECS) exitWith {
	format[localize "STR_SPPM_7", round (time - SYG_recentSPPMCmdUseTime ), SPPM_UPDATE_INTERVAL_SECS ] call XfHQChat; // "You press this button too often (%1/%2 sec)"
};

_pos = player call SYG_getPos;
//hint localize format["+++ sppm.sqf: [player call SYG_getPos, d_base_array] = %1", [ _pos, d_base_array]];
if ((vehicle player != player) && (!((vehicle player) isKindOf "ParachuteBase") ) ) exitWith {
    //++++++++++++++++++++++++++++++++++++++++++++++++++++
    //+++ You are in vehicle (ADD SPPM can be applyed) +++
    //++++++++++++++++++++++++++++++++++++++++++++++++++++
    if ( isEngineOn  (vehicle player) ) exitWith {
        (localize "STR_SPPM_8") call XfHQChat; // "Stop engine to work with SPPM markers"
    };

    // On base you can't add SPPM markers
    if ( _pos call SYG_pointIsOnBase ) exitWith {
        (localize "STR_SPPM_2") call XfHQChat; // "SPPM markers are not used on the base"
    };

    // in town borders you can't add SPPM markers
    if ( _pos call SYG_pointIsInTownBorders ) exitWith {
        (localize "STR_SPPM_2_1") call XfHQChat; // "SPPM markers are not used in towns"
    };

    // Add SPPM marker now  (all vehicle checks are done on server)
	["SPPM","ADD", _pos, name player] call XSendNetStartScriptServer;
	SYG_recentSPPMCmdUseTime = time; // store last update time
};

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++    You are on your feet so UPDATE SPPM command can be applyed  +++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// Update all markers on server
["SPPM", "UPDATE", name player] call XSendNetStartScriptServer;

SYG_recentSPPMCmdUseTime = time; // store last update time

//_str = _pos call SYG_addSPPMMarker;
