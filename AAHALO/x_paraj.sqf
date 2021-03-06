﻿// Xeno, AAHALO\x_paraj.sqf - flag pole action "parajump"
// e.g.: FLAG_BASE addaction [localize "STR_SYS_76","AAHALO\x_paraj.sqf"];

private ["_do_exit","_wait_score","_jump_score","_full_score"];

#include "x_setup.sqf"

#ifdef __RANKED__
_jump_score = d_ranked_a select 4; // score to jump in ranked version
if ( score player < _jump_score ) exitWith {
	(format [localize "STR_SYS_607", score player,_jump_score]) call XfHQChat; // "You need %2 point[s] for parajump. Your current scores are %1"
};
#endif

_do_exit = false;
_wait_score = 0;
_full_score = _jump_score;
if ( d_para_timer_base > 0 ) then { // pass time interval to jump
    if (
#ifndef __TT__
	position player distance FLAG_BASE < 15
#else
	position player distance RFLAG_BASE < 15 || position player distance WFLAG_BASE < 15
#endif
    ) then {
        _miss_mins = (d_next_jump_time - time)/60; // how many mins before next jump
        if ( _miss_mins > 0 ) then { // paid for all (and partial) munutes to wait from next free jump
            _miss_mins = ceil _miss_mins;
            _wait_score = (_miss_mins*(_miss_mins + 1)) / 2 ; //  Natural series 1,2,3,4,5 of an arithmetic progression is { SUM_{i=1}^{n}i=1+2+3+...+n={Frac {n(n+1)}{2}}}
            if ( score player  < (_jump_score  + _wait_score)) exitWith {
                // "You need more points, now wait %1 minutes for a free jump (or %2 points), the jump itself requires another %3 points. You only have %4"
                (format [localize "STR_SYS_608", _miss_mins, _wait_score, _jump_score, score player]) call XfHQChat; 
                _do_exit = true;
            };
            _full_score = _jump_score + _wait_score;
            hint localize format["+++ x_paraj.sqf: assign full score %1, jump score %2, wait score %3", _full_score, _jump_score, _wait_score];
            // STR_SYS_608_1,"You spent points on this jump: %1, %2 for jump and %3 for impatience to free jump (%4 min.)"
            (format [localize "STR_SYS_608_1", _full_score, _jump_score, _wait_score, _miss_mins]) call XfHQChat;
        } else {
            (format [localize "STR_SYS_607", score player,_jump_score]) call XfHQChat; // "You need %2 point[s] for parajump. Your current scores are %1"
        };
    } else {hint localize "--- x_paraj.sqf: player too far (> 15 m) from flag"};
};
if (_do_exit) exitWith {};

//hint localize format["x_paraj.sqf: weapons are %1", weapons player];
new_paratype = "";

#ifdef __DISABLE_PARAJUMP_WITHOUT_PARACHUTE__
    _disableFreeDropping = true;
#else
    _disableFreeDropping = false;
#endif

hint localize "";
#ifdef __ACE__
{
	if (_x  in ["ACE_ParachutePack","ACE_ParachuteRoundPack"]) exitWith {
	    new_paratype = _x;
	}; // ACE_Para - main kind of parachute in game
} forEach weapons player;

if ( _disableFreeDropping && new_paratype == "" ) exitWith { localize "STR_SYS_609"/*"!!! Вам нужен парашют !!!"*/ call XfHQChat;};

if (d_with_ace_map && (!(call XCheckForMap)) ) exitWith {
	localize "STR_SYS_304" call XfHQChat; // "!!!!!!!!!!!! Нужна карта !!!!!!!!!!!"
};
#else
{
	if (_x isKindOf "ParachuteBase" ) exitWith {
	    new_paratype = _x;
	}; // ACE_Para - main kind of parachute in game
} forEach weapons player;

if ( _disableFreeDropping && new_paratype == "" ) exitWith { localize "STR_SYS_609"/*"!!! Вам нужен парашют !!!"*/ call XfHQChat;};

#endif

d_cancelled = true; // to detect if "Cancel" button was clicked
_ok = createDialog "XD_ParajumpDialog";
onMapSingleClick format[ "_StartLocation = _pos;closeDialog 0;[_StartLocation, new_paratype, %1] execVM ""AAHALO\jump.sqf"";d_cancelled=false;onMapSingleClick """"", _full_score ];

// TODO: handle if player clicks "Cancel" button on dialog

waitUntil {!dialog}; // wait for dialog to be closed by any mean: or by click on map or "Cancel" baton on dialog
sleep 0.112;
onMapSingleClick "";

if (d_cancelled) exitWith {
    hint localize "*** player cancelled parajump dialog";
    (localize ("STR_SYS_JUMP_NUM" call SYG_getRandomText)) call XfHQChat; // "Because of your poor health, You decided not to jump"
    playSound "return";
};

// we are in air!!!
sleep 2.56;

#ifdef __RANKED__
hint localize format["+++ x_paraj.sqf: subtract full score %1 for the jump (jump score %2 + wait score %3)", _full_score, _jump_score, _wait_score];
//player addScore (-_full_score); // subtract score for parajump
//playSound "losing_patience";
#endif

// detect for parachute to be on player and on the ground and remove it from magazines
waitUntil { sleep 0.132; (!alive player) || (vehicle player != player)  || ( ( ( getPos player ) select 2 ) < 5 ) };

if ( (vehicle player) != player ) then { // parachute still on!
    // the parachute was just opened, so remove it from slot after landing/death
    waitUntil { sleep 0.132; (!alive player) || (vehicle player == player)  || ( ( ( getPos player ) select 2 ) < 5 ) };
    player removeWeapon new_paratype;
    if ( (player call XGetRankIndexFromScore) > 2 ) then {
    	#ifdef __ACE __
    	if (new_paratype != "ACE_ParachuteRoundPack") exitWith {}; // only round pack need auto cut
    	#endif
    	sleep 5.0; // Ensure  player to be on the ground
    	if ( (vehicle player) != player ) then {
			player action ["Eject", vehicle player];
			hint localize "+++ x_paraj.sqf: player ejected from parachute";
			playSound "steal";
			(localize "STR_SYS_609_5") call XfHQChat;
    	};
    }
};
//hint localize format["x_paraj.sqf: alive %1, vehicle player %2, getPos player %3", alive player, vehicle player, getPos player];

if (true) exitWith {true};
