private ["_do_exit"];

#include "x_setup.sqf"


#ifdef __RANKED__

if (score player < (d_ranked_a select 4)) exitWith
{
	(format [localize "STR_SYS_607", score player,d_ranked_a select 4]) call XfHQChat;
};

#endif


_do_exit = false;
if (d_para_timer_base > 0) then {
#ifndef __TT__
	if (position player distance FLAG_BASE < 15) then {
#else
	if (position player distance RFLAG_BASE < 15 || position player distance WFLAG_BASE < 15) then {
#endif

		if (d_next_jump_time > time) then {
			_do_exit = true;
			(format [localize "STR_SYS_608", ceil ((d_next_jump_time - time)/60)]) call XfHQChat;
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
player addScore (d_ranked_a select 4) * -1; // subtract score for parajump
#endif

_ok = createDialog "XD_ParajumpDialog";
onMapSingleClick "_StartLocation = _pos;closeDialog 0;[_StartLocation, new_paratype] execVM ""AAHALO\jump.sqf"";onMapSingleClick """"";

waitUntil {!dialog};
sleep 0.512;
onMapSingleClick "";

sleep 2.56;

//hint localize format["new_paratype == %1", new_paratype];
//    hint localize format["vehicle player == %1", vehicle player];

// detect for parachute to be open and remove it from magazines
waitUntil { sleep 0.132; (!alive player) || (vehicle player != player)  || ( ( ( getPos player ) select 2 )< 5 )};

if ( (vehicle player) != player ) then // parashute was on!
{
    // the parachute was just opened, so remove it from slot after landing/death
    // TODO play corresponding sound
    waitUntil { sleep 0.132; (!alive player) || (vehicle player == player)  || ( ( ( getPos player ) select 2 ) < 5 ) };
    player removeWeapon new_paratype;
};
//hint localize format["x_paraj.sqf: alive %1, vehicle player %2, getPos player %3", alive player, vehicle player, getPos player];


if (true) exitWith {true};
