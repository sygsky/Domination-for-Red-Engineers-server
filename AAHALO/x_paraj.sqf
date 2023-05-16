//
// Xeno, AAHALO\x_paraj.sqf - flag pole action "parajump"
// e.g.: FLAG_BASE addAction [localize "STR_FLAG_1","AAHALO\x_paraj.sqf"];
// +++ Sygsky: 2023-APR-11 stop using if player is not registered on base visited

// first of all check if player visited the base before use the jump flag
if (base_visit_mission < 1) exitWith {
	player groupChat (localize "STR_SYS_341"); // "The flag starts working only after you visit the base"
};

_unit = _this select 1;
new_paratype = _unit call SYG_getParachute; // Find parachute of player (if no parachute weared, "" returned)
_ind = (SPAWN_INFO select 0) find new_paratype;

// Check if parachute  is absent or is unknown
if (_ind < 0 ) then { _ind = 1 }; // "ACE_ParachuteRoundPack" is default
_rect = (SPAWN_INFO select 2) select _ind; // Second spawn rectangle with height of central point as default
new_height = _rect select 2;

hint localize format["+++ x_paraj.sqf: _this = %1, weapons = %2, height is %3, pos %4", _this, weapons _unit, new_height, (_this select 1) call SYG_msgOnPosE0];

private ["_do_exit","_wait_score","_jump_score","_full_score"];

#include "x_setup.sqf"

// +++++++++++++++++++++++++++++++++++++++++++++++++
// + call as follows: _user_msg call _showHintC;   +
// +++++++++++++++++++++++++++++++++++++++++++++++++
_showHintC = {
	localize "STR_WPN_TITLE" hintC [ // "Important information"
		composeText[ image "img\red_star_64x64.paa"], // Small red star
		composeText[ localize "STR_SYS_607_TXT_COMMON1"],	// "Jumping no more than once every 5 minutes you spend a minimum of points per jump: -1."
		composeText[ localize "STR_SYS_607_TXT_COMMON2"],	// "Jumping faster than 5 minutes is more costly."
		composeText[ localize "STR_SYS_607_TXT_COMMON3"],	// "Around 5 minutes -2, after 4 minutes -4, after 3 minutes -7, after 2 minutes -11, after 1 minute -16. The choice is yours!"
		composeText[ localize "STR_SYS_607_TXT_COMMON4",lineBreak],   // "The choice is yours!"
		_this, // custom message
		parseText  ("<t align='center'><t color='#ffff0000'>" + (format[localize "STR_WPN_EXIT",localize "STR_DISP_INT_CONTINUE"])) // "press '%1' to exit from dialog"
	];
};

#ifdef __RANKED__
_jump_score = d_ranked_a select 4; // score to jump in ranked version
if ( score player < _jump_score ) exitWith {
	(format[localize "STR_SYS_607_TXT_NO_SCORE", score player, _jump_score]) call _showHintC; // "You need %2 point[s] for parajump. Your current scores are %1"
};
#endif


_do_exit = false;
_wait_score = 0;
_full_score = _jump_score;
if ( d_para_timer_base > 0 ) then { // pass time interval to jump
#ifndef __TT__
    _dist = position player distance FLAG_BASE;
#else
    _dist = position player distance RFLAG_BASE < 15;
    _dist = _dist min (position player distance WFLAG_BASE);
#endif
    if ( _dist <= 15 ) then {
        _miss_mins = (d_next_jump_time - time)/60; // how many mins before next jump
        if ( _miss_mins > 0 ) then { // paid for all (and partial) munutes to wait from next free jump
            _miss_mins = ceil _miss_mins;
            _wait_score = ceil ((_miss_mins*(_miss_mins + 1)) / 2) ; //  Natural series 1,2,3,4,5 of an arithmetic progression is { SUM_{i=1}^{n}i=1+2+3+...+n={Frac {n(n+1)/2}}}
            _full_score = _jump_score + _wait_score;
            if ( score player  < _full_score ) exitWith {

                // "You need more points, now wait %1 minutes for a free jump (or %2 points), the jump itself requires another %3 points. You only have %4"
                (format [localize "STR_SYS_607_TXT_WAIT", _miss_mins, _wait_score, _jump_score, score player]) call _showHintC;
                _do_exit = true;
            };
            hint localize format["+++ x_paraj.sqf: assign full score %1, jump score %2, wait score %3", _full_score, _jump_score, _wait_score];
			if (_wait_score > 0) then { // Inform player about high cost of non-free jump
				format [localize "STR_SYS_607_WARNING", _full_score, _jump_score, _wait_score, d_para_timer_base/60, _miss_mins] call _showHintC; // "Your total cost (points) for the jump: %1, %2 for the jump itself and %3 for impatience. Free jump - every %4 min., the next one in %5 min."
			} else {
				// "Your costs (points) for a parachute jump: %1. Free parachute jump - every %2 min."
				(format [localize "STR_SYS_608_0", _full_score, d_para_timer_base/60]) call XfHQChat;
			};
        } else {
            (format [localize "STR_SYS_607", score player,_jump_score]) call XfHQChat; // "You need %2 point[s] for parajump. Your current scores are %1"
        };
    } else {hint localize format["--- x_paraj.sqf: player too far (%1 > 15 m) from flag", _dist]};
};
if (_do_exit) exitWith {};

//hint localize format["+++ x_paraj.sqf: weapons are %1", weapons player];

#ifdef __DISABLE_PARAJUMP_WITHOUT_PARACHUTE__
    _disableFreeDropping = true;
#else
    _disableFreeDropping = false;
#endif

if ( _disableFreeDropping && new_paratype == "" ) exitWith { localize "STR_SYS_609" call XfHQChat;}; // "!!!!!!!!!!!! You need a parachute pack first !!!!!!!!!!!"

#ifdef __ACE__
if (d_with_ace_map && (!(call XCheckForMap)) ) exitWith {
	localize "STR_SYS_304" call XfHQChat; // "!!!!!!!!!!!! Нужна карта !!!!!!!!!!!"
};
#endif

d_cancelled = true; // to detect if "Cancel" button was clicked
_ok = createDialog "XD_ParajumpDialog";
onMapSingleClick format[ "_StartLocation = _pos;_StartLocation set [2, new_height];closeDialog 0;[_StartLocation, new_paratype, %1] execVM ""AAHALO\jump.sqf"";d_cancelled=false;onMapSingleClick """"", _full_score ];

waitUntil {!dialog}; // wait for dialog to be closed by any mean: or by click on map or "Cancel" baton on dialog
sleep 0.112;
onMapSingleClick "";

// handle if player clicks "Cancel" button on dialog
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
if (new_paratype == "") then {  // no parachute on player!!!
	hint localize format["+++ x_paraj.sqf: no parachute detected, animated freefall as ""ACE_IC_ParaFail"""];
	player playMove "ACE_IC_ParaFail"
};
#endif

// detect for parachute to be on player or player is on the ground and remove it from magazines
waitUntil { sleep 0.132; (!alive player) || (vehicle player != player) || ( ( ( getPos player ) select 2 ) < 5 ) };

_para_used = false; // was parachute used or not (default)
if ( (vehicle player) != player ) then { // parachute still on!
	hint localize format["+++ x_paraj.sqf: parachute %1 is opened!", new_paratype];
	_para_used = true; // parachute was used
    // The parachute was just opened, wait player to be on the ground, alive or dead
    waitUntil { sleep 0.132; (!alive player) || (vehicle player == player)  || ( ( ( getPos player ) select 2 ) < 5 ) };
//    if ( (player call XGetRankIndexFromScore) > 2 ) then {
    #ifdef __ACE __
    if (new_paratype == "ACE_ParachutePack") exitWith {}; // only round packs need auto cut
    #endif
    sleep 6.0; // Ensure  player to be on the ground
    // Let's stop the parachute jumping on the ground
    if ( (vehicle player) != player ) then {
        player action ["Eject", vehicle player];
        hint localize "+++ x_paraj.sqf: player ejected out of parachute being on the ground";
        playSound "steal";
        (localize "STR_SYS_609_5") call XfHQChat; // "Thanks to your life experience (and rank!), you  got rid of your parachute."
    };
//    }
};
// remove parachute from inventory in any case
if ( (new_paratype != "") && _para_used) then {player removeWeapon new_paratype}; // The parachute was put on and used
hint localize format["+++ x_paraj.sqf: parachute removed from %1 player weapons! Para %2, was opened %3",
						if (alive player) then {"alive"} else {"dead"} ,new_paratype, _para_used];
//hint localize format["x_paraj.sqf: alive %1, vehicle player %2, getPos player %3", alive player, vehicle player, getPos player];

if (true) exitWith {true};
