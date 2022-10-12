// Xeno, AAHALO\SYG_parap.sqf -  parachute jump practice
// e.g.: FLAG_BASE addaction [localize "STR_FLAG_8","AAHALO\SYG_parap.sqf"];

#include "x_setup.sqf"

// create jump point.
// Call as : _spwn_point = "ACE_ParachutePack" call _makeSpawnPoint;
_makeSpawnPoint = {
	private ["_spawn_rect","_para"];
	_para = _this;
	_spawn_rect = drop_zone_arr select 0; // drop rect for ordinal parachute
#ifdef __ACE__
	if (_para == "ACE_ParachutePack") then {  // find point in the rectangle above Sierra Madre
		_spawn_rect = [ [11306,8386,0], 600,150, -45 ]; // drop rect for planning parachute
		hint localize "+++ SYG_parap.sqf: jump point is set on mountines";
	} else {
#endif
		hint localize "+++ SYG_parap.sqf: jump point is set on plains";
#ifdef __ACE__
	};
#endif
	_spawn_rect call XfGetRanPointSquareOld
};

_para = player call SYG_getParachute; // find parachute of player (if any)

#ifdef __DISABLE_PARAJUMP_WITHOUT_PARACHUTE__
if ( _para == "" ) exitWith { localize "STR_SYS_609" call XfHQChat;}; // "!!!!!!!!!!!! You need a parachute pack first !!!!!!!!!!!"
#endif


if( _para == "" ) then {
	#ifdef __ACE__
	_para == "ACE_ParachutePack";
	#else
	_para= (
		switch (d_own_side) do {
			case "RACS": {"ParachuteG"};
			case "WEST": {"ParachuteWest"};
			case "EAST": {"ParachuteEast"};
		}
	);
	#endif
};

_spawn_point = _para call _makeSpawnPoint;

[ _spawn_point, _para, "DC3", false, false] execVM "AAHALO\jump.sqf"; // J-u-m-p-p-p!!! It is not intro jump!

// we are in air!!!
sleep 2.56;
#ifdef __ACE__
// If jumper doesn't have a chute, then he is screwed.
// Make him play the ACE animation of a falling person (idea from MP mission "Operation Mongoose").
if (_para == "") then {  // no parachute on player!!!
	hint localize format["+++ SYG_parap.sqf: no parachute detected, animated freefall as ""ACE_IC_ParaFail"""];
	player playMove "ACE_IC_ParaFail"
};
#endif

// detect for parachute to be on player or player is on the ground and remove it from magazines
waitUntil { sleep 0.132; (!alive player) || (vehicle player != player) || ( ( ( getPos player ) select 2 ) < 5 ) };

_para_used = false; // was parachute used or not (default)
if ( (vehicle player) != player ) then { // parachute still on!
	_para_used = true; // parachute was used
    // The parachute was just opened, wait player to be on the gound, alive or dead
    waitUntil { sleep 0.132; (!alive player) || (vehicle player == player)  || ( ( ( getPos player ) select 2 ) < 5 ) };
//    if ( (player call XGetRankIndexFromScore) > 2 ) then {
    #ifdef __ACE __
    if (_para == "ACE_ParachutePack") exitWith {}; // only round packs need auto cut
    #endif
    sleep 6.0; // Ensure  player to be on the ground
    // Let's stop the parachute jumping on the ground
    if ( (vehicle player) != player ) then {
        player action ["Eject", vehicle player];
        hint localize "+++ SYG_parap.sqf: player ejected from parachute";
        playSound "steal";
        (localize "STR_SYS_609_5") call XfHQChat; // "Thanks to your life experience (and rank!), you  got rid of your parachute."
    };
//    }
};
// remove parachute from inventory in any case
if ( (_para != "") && _para_used) then {player removeWeapon _para}; // The parachute was put on and used
hint localize "+++ x_paraj.sqf: parachute removed from player weapons!";
//hint localize format["x_paraj.sqf: alive %1, vehicle player %2, getPos player %3", alive player, vehicle player, getPos player];

if (true) exitWith {true};
