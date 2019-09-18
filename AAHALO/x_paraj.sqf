// Xeno, AAHALO/x_paraj.sqf - flag pole action "parajump"

private ["_do_exit","_wait_score","_jump_score","_full_score"];

#include "x_setup.sqf"

#ifdef __RANKED__
_jump_score = d_ranked_a select 4; // score to jump in ranked version
_wait_score = 0;
if ( score player < _jump_score ) exitWith
{
	(format [localize "STR_SYS_607", score player,_jump_score]) call XfHQChat; // "You need %2 point[s] for parajump. Your current scores are %1"
};
#endif

_do_exit = false;
_wait_score = 0;
_full_score = 0;
if ( d_para_timer_base > 0 ) then { // pass time interval to jump
#ifndef __TT__
	if (position player distance FLAG_BASE < 15)
#else
	if (position player distance RFLAG_BASE < 15 || position player distance WFLAG_BASE < 15)
#endif
    then
    {
        _miss_mins = (d_next_jump_time - time)/60; // how many mins before next jump
        if ( _miss_mins > 0) then // paid for munutes to wait fror next free jump
        {
            _miss_mins = ceil _miss_mins;
            for "_i" from 1 to _miss_mins do { _wait_score = _i + _wait_score;  };
            if ( score player  < (_jump_score  + _wait_score)) exitWith {};
            {
                // For this jump you lost %1 points (%2 per jump and %2 per waiting munutes).
                (format [localize "STR_SYS_608", _miss_mins, _wait_score, _jump_score, score player]) call XfHQChat; 
                _do_exit = true;
            };
            _full_score = _jump_score + _wait_score;
            // STR_SYS_608_1,"You spent points on this jump: %1, %2 for jump and %3 for impatience to free jump (%4 min.)"
            (format [localize "STR_SYS_608_1", _full_score, _jump_score, _wait_score, _miss_mins]) call XfHQChat;
        };
    };
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
	if (_x  in ["ACE_ParachutePack","ACE_ParachuteRoundPack"]) exitWith
	{
	    new_paratype = _x;
	}; // ACE_Para - main kind of parachute in game
} forEach weapons player;

if ( _disableFreeDropping && new_paratype == "" ) exitWith { localize "STR_SYS_609"/*"!!! Вам нужен парашют !!!"*/ call XfHQChat;};

if (d_with_ace_map && (!(call XCheckForMap)) ) exitWith
{
	localize "STR_SYS_304" call XfHQChat; // "!!!!!!!!!!!! Нужна карта !!!!!!!!!!!"
};
#else
{
	if (_x isKindOf "ParachuteBase" ) exitWith
	{
	    new_paratype = _x;
	}; // ACE_Para - main kind of parachute in game
} forEach weapons player;

if ( _disableFreeDropping && new_paratype == "" ) exitWith { localize "STR_SYS_609"/*"!!! Вам нужен парашют !!!"*/ call XfHQChat;};

#endif

#ifdef __RANKED__
hint localize format["+++ x_paraj.sqf: subtract %1 scores for the jump (%2 + %3)", _full_score, _jump_score, _wait_score];
player addScore (-_full_score); // subtract score for parajump
#endif

_ok = createDialog "XD_ParajumpDialog";
onMapSingleClick format[ "_StartLocation = _pos;closeDialog 0;[_StartLocation, new_paratype, %1] execVM ""AAHALO\jump.sqf"";onMapSingleClick """"", _jump_score ];

waitUntil {!dialog};
sleep 0.512;
onMapSingleClick "";

sleep 2.56;

//hint localize format["new_paratype == %1", new_paratype];
//    hint localize format["vehicle player == %1", vehicle player];

// detect for parachute to be open and remove it from magazines
waitUntil { sleep 0.132; (!alive player) || (vehicle player != player)  || ( ( ( getPos player ) select 2 )< 5 )};

if ( (vehicle player) != player ) then // parachute was on!
{
    // the parachute was just opened, so remove it from slot after landing/death
    waitUntil { sleep 0.132; (!alive player) || (vehicle player == player)  || ( ( ( getPos player ) select 2 ) < 5 ) };
    player removeWeapon new_paratype;
    playSound "steal";
};
//hint localize format["x_paraj.sqf: alive %1, vehicle player %2, getPos player %3", alive player, vehicle player, getPos player];


if (true) exitWith {true};
