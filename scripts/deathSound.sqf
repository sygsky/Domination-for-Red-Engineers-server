// Sygsky: deathSound.sqf, called when player respawn on client side to play fun music
/*
	author: Sygsky
	description: spawn this file to play some short music while you are laying dead
	returns: nothing
*/

private ["_killer","_man","_men", "_unit","_exit","_churchArr","_TVTowerArr","_castleArr","_sound","_sounds", "_arr",
		 "_i","_cnt"];
#include "x_setup.sqf"

#define RANDOM_ARR_ITEM(ARR) (ARR select(floor(random(count ARR))))

_killer = _this select 1;
_unit = _this select 0; // player

//hint localize format["+++ open.sqf runs for killed %1 and killer %2 +++", name _unit, name _killer];

if ( !( local _unit ) ) exitWith {hint localize format["--- scripts/deathSound.sqf, params not allow to play sound (!local): %1", _this]};
if ( !( isPlayer _unit ) ) exitWith {hint localize format["--- scripts/deathSound.sqf, params not allow to play sound(!isPlayer): %1", _this]};

SYG_deathCountCnt = SYG_deathCountCnt + 1; // total death count bump

if ( (_unit != _killer) || (X_MP && (call XPlayersNumber) == 1) ) exitWith {// Play ordinal sound if KIA or alone
    if ( !(call SYG_playExtraSounds) ) exitWith{false}; // yeti doesn't like such sounds

    // if killed in tank
    _exit = false;
    if ( (vehicle _unit) isKindOf "Tank" ) then { _exit = call SYG_playDeathInTankSound }; // play only for RUSSIAN language interface
    if ( _exit) exitWith {};

    // if killed from enemy tank
    if ((vehicle _killer) isKindof "Tank") exitWith { call SYG_playDeathFromEnemyTankSound };

    // check for helicopter
    if ( (vehicle _killer) isKindOf "Helicopter" && (format["%1",side _killer] == d_enemy_side) ) exitWith {
	    playSound format["heli_over_%1", ceil 4]; // play sound of heli fly over your poor remnants
    };

    _unit call SYG_playRandomDefeatTrackByPos; // some music for poor dead man
    _arr = []; // array of enemies to cry
   	_sounds = []; // aray oа sounds to cry

	// try to play laughter sound from killer and his collegues

	_men = nearestObjects [player, ["CAManBase"], 60];
	_men = _men - [_unit, _killer];
	_men = [_killer] + _men; // killer shoul be first to process

	_cnt = 0;	 // max count of possible war cries
	{
		if ( _cnt >=3 ) exitWith {}; // not more than 3 men can exclamate now
		if ( (
#ifdef __ACE__
		_x  call SYG_ACEUnitConscious
#else
		canStand _x
#endif
		) && ( ( side _killer) == (side _x) ) ) then {
			_sound = _x getVariable "killer_sound"; // has already some sound sayed?
			if (!isNil "_sound") then {
				while { _sound in _sounds } do { _sound = call SYG_getLaughterSound;};
				_sounds set [count _sounds, _sound];
				_x setVariable ["killer_sound", _sound];
				_arr set [count _arr, [_x, _sound, random 1.5]]; // next exclamation cry added
			} else {
				if ( (random 3) < 2 ) then {
					_sound = call SYG_getLaughterSound; // prepare new war cry sound
					while { _sound in _sounds } do { _sound = call SYG_getLaughterSound;};
					_sounds set [count _sounds, _sound];
					_x setVariable ["killer_sound", _sound];
					_arr set [count _arr, [_x, _sound, random 1.5]];
				};
			};
			_cnt = _cnt + 1;
		};
	} forEach _men;

	if (count _arr > 0) then {
		["say_sound", "LIST", _arr] call XSendNetStartScriptClientAll;
//		hint localize format["+++ deathSound: %1 war cry prepared => %2, lis of %3", count _arr, _arr, count _men];
	};
};
// some kind of suicide? Say something about...

// check if we are in water
if (surfaceIsWater (getPos _unit) ) exitWith {
	_sound = call SYG_getWaterDefeatTracks;
	["say_sound", _unit, _sound] call XSendNetStartScriptClientAll; // in water  sounds if suicide in water
 };

// check if you are near church etc
_churchArr = nearestObjects [ getPos _unit, SYG_religious_buildings, 50];
if ( (count _churchArr > 0) && ((random 9) > 1)) exitWith {
	// let all to hear this sound, not only current player
	["say_sound", _churchArr select 0, RANDOM_ARR_ITEM(SYG_liturgyDefeatTracks)] call XSendNetStartScriptClientAll;
};

// check if we are near TV-Tower
_TVTowerArr = _unit nearObjects [ "Land_telek1", 50];
if ( ((count _TVTowerArr) > 0) && ((random 10) > 1)) exitWith {
	_sound =  call SYG_getTVTowerGong;
	["say_sound", _TVTowerArr select 0, _sound] call XSendNetStartScriptClientAll; // gong from tower
};

// check if we are near castle
_castleArr = _unit nearObjects [ "Land_helfenburk", 800];
if ( ((count _castleArr) > 0) && ((random 5) > 1)) exitWith {
	_sound =  RANDOM_ARR_ITEM(SYG_MedievalDefeatTracks);
	["say_sound", _unit, _sound] call XSendNetStartScriptClientAll; // medieval music if suicide near castle
};

// short melody on unknown death case, anybody within some range can hear this
_sound = "male_scream_0"; // default value
// check if a woman is killed
if ( _unit call SYG_isWoman ) then {
	_sound = "female_shout_of_pain_" + str(ceil (random 4));  // 1-4
} else {
//#ifdef __ACE__
//play 15 sounds from ACE collection for hard screams
//_sound = format["ACE_BrutalScream%1", ceil(random 15)]; // 1-15
//        hint localize format["ACE sound is %1", _sound];
//#else
	_sound = call SYG_getSuicideScreamSound;
//#endif
};

hint localize format["deathSound: killer unknown, dmg %1", damage _unit ];
// let all to hear this sound, not only current player
["say_sound", _unit, _sound] call XSendNetStartScriptClientAll;
