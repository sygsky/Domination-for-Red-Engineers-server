// Sygsky: deathSound.sqf, called when player respawn on client side to play fun music
/*
	author: Sygsky
	description: spawn this file to play some short music while you are laying dead
	returns: nothing
*/

private ["_killer","_man","_men", "_unit","_exit","_churchArr","_TVTowerArr","_castleArr","_sound","_sounds", "_arr",
		 "_i"];
#include "x_setup.sqf"

_unit = _this select 0; // player
_killer = _this select 1;

_killer_name = if (isNull _killer) then {"<null>"} else { if (isPlayer _killer) then { name _killer} else {typeOf _killer} };
hint localize format["+++ deathSound.sqf runs for killed %1 and killer %2 +++", name _unit, _killer_name];

if ( !( local _unit ) ) exitWith {hint localize format["--- scripts/deathSound.sqf, params not allow to play sound (!local): %1", _this]};
if ( !( isPlayer _unit ) ) exitWith {hint localize format["--- scripts/deathSound.sqf, params not allow to play sound(!isPlayer): %1", _this]};

SYG_deathCountCnt = SYG_deathCountCnt + 1; // total death count bump

#ifdef __CONNECT_ON_PARA__
if (base_visit_session <= 0) exitWith { playSound  "atmos"; hint localize "*** scripts/deathSound.sqf: playeSound ""atmos.ogg"""}; // if we today still never visit the base, atmospheric sound is played
#endif

if ( (_unit != _killer) /*|| (X_MP && (call XPlayersNumber) == 1)*/ ) exitWith {// Play ordinal sound if KIA or alone
    if ( !(call SYG_playExtraSounds) ) exitWith { false }; // yeti doesn't like such sounds

    // if killed in tank
    // TODO: check if playe was in tank on kill event. Oк is near killed tank now.
    // Really it can be removed out of tank on "killed" event.
    // So "killed" event has no chance to detect player in tank
    _exit = false;
    if ( (vehicle _unit) isKindOf "Tank" ) then { _exit = call SYG_playDeathInTankSound }; // play only for RUSSIAN language interface
    if ( _exit) exitWith {};

    // if killed from enemy tank
    if ((vehicle _killer) isKindof "Tank") exitWith { call SYG_playDeathFromEnemyTankSound };

    // check for helicopter
    if ( (vehicle _killer) isKindOf "Helicopter" && ((side _killer) == d_side_enemy) ) exitWith {
	    playSound format["heli_over_%1", (floor (random 4)) + 1]; // play sound of heli fly over your poor remnants
    };

    _unit call SYG_playRandomDefeatTrackByPos; // some music for poor dead man
    _arr = []; // array of enemies to cry
   	_sounds = []; // aray oа sounds to cry

	// try to play laughter sound from killer and his collegues

	_men = nearestObjects [player, ["CAManBase"], 60];
	_men =  [_killer]  + (_men - [_unit, _killer]); // killer shoul be first to say
	_killer_side = side _killer;
	{
		if ( (count _sounds) >= 4 ) exitWith {}; // not more than 4 men can exclamate now
		// AI can say sound?
#ifdef __ACE__
			_can_say = (_x  call SYG_ACEUnitConscious) && ( _killer_side == (side _x) );
#else
			_can_say = (canStand _x) && ( _killer_side == (side _x) );
#endif
			if ( _can_say ) then {
			_sound = _x getVariable "killer_sound"; // has already some sound sayed?
			if (isNil "_sound") then { // create new war sound now as it was not sayed by this AI before
				_sound = call SYG_getLaughterSound; // prepare new war cry sound 10% of times
				while { _sound in _sounds } do { _sound = call SYG_getLaughterSound;};
			};
			_sounds set [count _sounds, _sound];
			_x setVariable ["killer_sound", _sound];
			_arr set [count _arr, [_x, _sound, random 1.5]];
		};
	} forEach _men;

	if (count _arr > 0) then {
		["say_sound", "LIST", _arr] call XSendNetStartScriptClientAll;
//		hint localize format["+++ deathSound: %1 war cry prepared => %2, lis of %3", count _arr, _arr, count _men];
	};
};

// some kind of suicide? Say something about...
hint localize "+++ deathSound: suicide assumed, assigning sound for it";

// check if we are in water
if (surfaceIsWater (getPos _unit) ) exitWith {
	_sound = call SYG_getWaterDefeatTracks;
	hint localize format["+++ deathSound: suicide at WATER, dmg %1, sound ""%2""", damage _unit, _sound ];
	["say_sound", _unit, _sound] call XSendNetStartScriptClientAll; // in water  sounds if suicide in water
};

// check if you are near church etc
_churchArr = nearestObjects [ getPos _unit, SYG_religious_buildings, 50];
if ( (count _churchArr > 0) && ((random 9) > 1)) exitWith {
	_sound = SYG_liturgyDefeatTracks call XfRandomArrayVal;
	hint localize format["+++ deathSound: suicide at church, dmg %1, sound ""%2""", damage _unit, _sound ];
	// let all to hear this sound, not only current player
	["say_sound", _churchArr select 0, _sound] call XSendNetStartScriptClientAll;
};

// check if we are near TV-Tower
_TVTowerArr = _unit nearObjects [ "Land_telek1", 50];
if ( ((count _TVTowerArr) > 0) && ((random 10) > 1)) exitWith {
	_sound =  call SYG_getTVTowerGong;
	hint localize format["+++ deathSound: suicide nearTVTower, dmg %1, sound ""%2""", damage _unit, _sound ];
	["say_sound", _TVTowerArr select 0, _sound] call XSendNetStartScriptClientAll; // gong from tower
};

// check if we are near castle
_castleArr = _unit nearObjects [ "Land_helfenburk", 800];
if ( ((count _castleArr) > 0) && ((random 5) > 1)) exitWith {
	_sound =  SYG_MedievalDefeatTracks call XfRandomArrayVal;
	hint localize format["+++ deathSound: suicide near medieval building, dmg %1, sound ""%2""", damage _unit, _sound ];
	["say_sound", _unit, _sound] call XSendNetStartScriptClientAll; // medieval music if suicide near castle
};

// short melody on unknown death case, anybody within some range can hear this
_sound = "male_scream_0"; // default value
// check if a woman is killed
if ( _unit call SYG_isWoman ) then {
	_sound = call SYG_getSuicideFemaleScreamSound; //_sound = "suicide_female_" + str(floor(random 12))};  // 0-11
} else {
	_sound = call SYG_getSuicideMaleScreamSound; // _sound = "male_scream_" + str(floor(random 15))};  // 0-14
};

hint localize format["+++ deathSound: ordinal suicide assumed, dmg %1, sound ""%2""", damage _unit, _sound ];
// let all to hear this sound, not only current player
["say_sound", _unit, _sound] call XSendNetStartScriptClientAll;
