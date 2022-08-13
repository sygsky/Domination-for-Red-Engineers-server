// Sygsky, edited Xeno scrpt, AAHALO\x_paraj_intro_new.sqf - intro for 1st time connection

private ["_do_exit","_wait_score","_jump_score","_full_score"];

#include "x_setup.sqf"

new_paratype = "";

hint localize "";
#ifdef __ACE__
{
	if (_x  in ["ACE_ParachutePack","ACE_ParachuteRoundPack"]) exitWith {
	    new_paratype = _x;
	}; // ACE_Para - main kind of parachute in game
} forEach weapons player;

if ( new_paratype == "" ) then {
	// TODO: add parachute
};

#else
{
	if (_x isKindOf "ParachuteBase" ) exitWith {
	    new_paratype = _x;
	}; // ACE_Para - main kind of parachute in game
} forEach weapons player;

#endif

_StartLocation = _pos;
[_StartLocation, new_paratype] execVM "AAHALO\jump.sqf";

// TODO: handle if player clicks "Cancel" button on dialog

waitUntil {!dialog}; // wait for dialog to be closed by any mean: or by click on map or "Cancel" baton on dialog
sleep 0.112;
onMapSingleClick "";

if (d_cancelled) exitWith {
    hint localize "*** player cancelled parajump dialog";
    (localize ("STR_SYS_JUMP_NUM" call SYG_getRandomText)) call XfHQChat; // "Because of a bad feeling, you decided not to jump..."
    playSound "return";
};

// we are in air!!!
sleep 2.56;
#ifdef __ACE__
// If jumper doesn't have a chute, then they're screwed.
// Make them play the ACE animation of a falling person (idea from MP mission "Operation Mongoose").
if (new_paratype == "") then {player switchMove "ACE_IC_ParaFail"}; // no parachute on player!!!
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
    if (new_paratype != "ACE_ParachuteRoundPack") exitWith {}; // only round pack need auto cut
    #endif
    sleep 5.0; // Ensure  player to be on the ground
    // Let's stop the parachute jumping on the ground
    if ( (vehicle player) != player ) then {
        player action ["Eject", vehicle player];
        hint localize "+++ x_paraj.sqf: player ejected from parachute";
        playSound "steal";
        (localize "STR_SYS_609_5") call XfHQChat; // "Thanks to your life experience (and rank!), you  got rid of your parachute."
    };
//    }
};
// remove parachute from inventory in any case
if ( (new_paratype != "") && _para_used) then {player removeWeapon new_paratype}; // The parachute was put on and used

//hint localize format["x_paraj.sqf: alive %1, vehicle player %2, getPos player %3", alive player, vehicle player, getPos player];

if (true) exitWith {true};
