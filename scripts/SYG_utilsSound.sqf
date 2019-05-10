//++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
// Script to detect if designated weapon is sniper one (return true) or not (return false)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++

#include "x_setup.sqf"
#include "x_macros.sqf"

//#define __DEBUG__

#define arg(x) (_this select(x))
#define argp(param,x) ((param)select(x))
#define argopt(num,val) (if(count _this<=(num))then{val}else{arg(num)})
#define RANDOM_ARR_ITEM(ARR) (ARR select(floor(random(count ARR))))
#define RANDOM_FROM_PARTS_ARR(ARR) (ARR select((floor(random((count ARR)-1)))+1))

#define NEW_DEATH_SOUND_ON_BASE_DISTANCE 2000

//
// call as: 
//  _musicName = _music_index call SYG_musicTrackName; // index from 0 to ((call SYG_musicTrackCount) - 1)
//  playMusic ( floor( random (call SYG_musicTrackCount) ) call SYG_musicTrackName);
//
SYG_musicTrackName = {
	if ( _this < 0 or _this >= (call SYG_musicCount) ) exitWith { "" }; // no such track
	configName((configFile >> "CfgMusic") select _this)
};

/*
 * call as: 1 call SYG_playMusicTrack;
 * Returns started track name, or "" if bad index designated
 */
SYG_playMusicTrack = {
	private ["_name"];
	if ( _this < 0 or _this >= (call SYG_musicCount) ) exitWith { "" }; // no such track
	_name = _this call SYG_musicTrackName;
	playMusic ( _name);
	_name
};

/*
 * call as: call SYG_randomMusicTrack;
 * Returns random track name
 * playMusic ( call SYG_randomMusicTrack);
 */
SYG_randomMusicTrack = {
	(floor (random (call SYG_musicTrackCount))) call SYG_musicTrackName
};


//
// call as: _musCnt = call SYG_musicTrackCount;
//
SYG_musicTrackCount = {
	count (configFile >> "CfgMusic" )
};


// Corazol (center of island with radious 500 m) sounds
SYG_defeatTracks =
[
    ["Delerium_Wisdom","pimbompimbom","vendetta"],
    ["Gandalf_Simades","whold","end"],
    ["ATrack9","ATrack10","ATrack14"],
    ["ATrack16","ATrack17","ATrack18"],
    ["ATrack20","ATrack21","ATrack22","thetrembler"],
    ["arroyo","ATrack15","ATrack19"],
    ["ATrack1",[0,8.412],[9.349,5.911],[15.254,10.407],[30.272,9.157]],
    ["ATrack23",[0,8.756],[28.472,8.031],[49.637,9.939],[91.435,5.302]],
    ["i_new_a_guy","decisions","treasure_island_defeat"],
    ["sorcerie","melody","thefuture"],
    ["fear2",[0, 10.45],[10.45,7.4],[17.641,7.593],[25.34,7.314],[40.124,8.882]],
    ["cosmos",[0,8.281],[14.25,9.25],[28.8,-1]]

];

SYG_playPartialTrack = {playMusic [_this select 0,_this select 1];sleep ((_this select 2)-1); 1 fadeMusic 0; sleep 0.1; playMusic ""; 0 fadeMusic 1;};

SYG_playRandomDefeatTrack = {
    SYG_defeatTracks call SYG_playRandomTrack;
};

SYG_rammsteinDefeatTracks1 = ["rammstein_1","rammstein_2","rammstein_3","rammstein_4"];
SYG_rammsteinDefeatTracks2 = ["rammstein_5","rammstein_6","rammstein_7","rammstein_8","rammstein_9"];
SYG_rammsteinDefeatTracks =  [ SYG_rammsteinDefeatTracks1,   SYG_rammsteinDefeatTracks2 ];

SYG_northDefeatTracks =
[
    ["ATrack7",[0,8.743],[57.582,7.755],[65.505,9.385],[77.076,11.828]],
    ["ATrack7",[117.908,8.1],[184.943,6.878],[191.822,9.257],[201.144,6.848]],
    ["ATrack9","ATrack10","ATrack19","bolero"],
    ["metel","gayane1","gayane2","gayane3", "mountains"]
] + SYG_rammsteinDefeatTracks;

SYG_southDefeatTracks =
[
    ["ATrack8",[0,10.801],[11.243,9.135],[22.175,6.533]],
    ["ATrack8",[29.332,7.392],[36.723,7.492],[44.219,7.496]],
    ["ATrack8",[51.715,7.287],[59.002,8.563],[67.565,7.704]],
    ["ATrack8",[75.269,8.823],[84.092,9.734],[95.986,6.246]],
    ["ATrack8",[103.377,7.157],[141.480,11.66],[153.293,9.286]],
    ["ATrack11","ATrack12","ATrack13"],
    ["arroyo","arabian_death","the_complex"]
];

SYG_baseDefeatTracks =
[
    "tezcatlipoca","village_ruins","yma_sumac","yma_sumac_2","aztecs","aztecs2","aztecs3","aztecs4","aztecs5","aztecs6",
    "betrayed","aztecs4","Gandalf_Simades","whold","end","thetrembler","arroyo","bolero","Delerium_Wisdom","pimbompimbom",
    "gamlet_hunt","treasure_island_defeat","musicbox_silent_night","i_new_a_guy","decisions","church_organ_1","sorcerie",
    "melody","medieval_defeat","defeat2","arabian_death",
    ["cosmos", [0,8.281] ],
    ["cosmos", [14.25,9.25] ],
    ["cosmos", [28.8,-1] ]
] + SYG_rammsteinDefeatTracks1 + SYG_rammsteinDefeatTracks2;

// for the death near TV-tower, independently in town/SM or ordinal on map one
SYG_TVTowerDefeatTracks =
    [
    "clock_1x_gong", "gong_01", "gong_02","gong_03","gong_04","gong_05","gong_06","gong_07","gong_08","gong_09","gong_10"
    ];

// for the death near medieval castles (2 buildings on whole island)
SYG_MedievalDefeatTracks =
    [
     "medieval_defeat",  "medieval_defeat1",  "medieval_defeat2",  "medieval_defeat3",  "medieval_defeat4",  "medieval_defeat5",
     "medieval_defeat6",  "medieval_defeat7",  "medieval_defeat8",  "medieval_defeat9", "medieval_defeat10", "medieval_defeat11",
     "medieval_defeat12", "medieval_defeat13", "medieval_defeat14", "medieval_defeat15", "medieval_defeat16", "medieval_defeat17",
     "village_consort"
    ];


// All available curche types in the Arma (I think so)
SYG_religious_buildings =  ["Church","Land_kostelik","Land_kostel_trosky"];

// call: _unit call SYG_playRandomDefeatTrackByPos; // or
//       getPos _vehicle call SYG_playRandomDefeatTrackByPos;
SYG_playRandomDefeatTrackByPos = {
    _done = false;
	if (typeName _this != "ARRAY") then // called as: _unit call  SYG_playRandomDefeatTrackByPos;
	{
	    _this = position _this;
	}
	else
	{
	    if (( count _this >= 2) && ((_this select 1) isKindOf "Helicopter")) then // called as: [_player, _killer] call SYG_playRandomDefeatTrackByPos;
	    {
	        if (side (_this select 1) == d_enemy_side) then
	        {
    	        playSound "helicopter_fly_over";
    	        _done = true;
	        };
	    };
	};
	if ( _done ) exitWith {true};
	// detect if killed near base (2 km from FLAG_BASE)
	_flag = objNull;
	#ifndef __TT__
	_flag = FLAG_BASE;
    #endif
    #ifdef __TT__
	if (playerSide == west) then
	{
		_flag = WFLAG_BASE;
	} else {
		_flag = RFLAG_BASE;
	};
    #endif

    // check if we are near some church
    _churchArr = nearestObjects [ _this, SYG_religious_buildings, 100];
    if ( (count _churchArr > 0) && ((random 10) > 1)) exitWith
    {
        SYG_chorusDefeatTracks call SYG_playRandomTrack; // 4 time from 5
    };

    // check if we are near base flag
    if ( (!isNull  _flag) && ((_this distance _flag) <= NEW_DEATH_SOUND_ON_BASE_DISTANCE) ) exitWith
    {
        SYG_baseDefeatTracks call SYG_playRandomTrack;
    };

    // check if we are near TV-Tower
    _TVTowerArr = _this nearObjects [ "Land_telek1", 50];
    if ( ((count _TVTowerArr) > 0) && ((random 10) > 1)) exitWith
    {
        _sound =  RANDOM_ARR_ITEM(SYG_TVTowerDefeatTracks);
        ["say_sound", _TVTowerArr select 0, _sound] call XSendNetStartScriptClientAll; // gong from tower
    };

    // check if we are near castle
    _castleArr = _this nearObjects [ "Land_helfenburk", 500];
    if ( ((count _castleArr) > 0) && ((random 10) > 1)) exitWith
    {
        SYG_MedievalDefeatTracks call SYG_playRandomTrack;
    };

    _found = true;
    switch (_this call SYG_whatPartOfIsland) do
    {
        case "NORTH": {SYG_northDefeatTracks call SYG_playRandomTrack}; // North Sahrani
        case "SOUTH": {SYG_southDefeatTracks call SYG_playRandomTrack}; // South Sahrani
        default  // Corazol // central Sahrani
        {
            _found = false;
        };
    };
    if ( _found ) exitWith {};

    if (_this call SYG_pointOnIslet) exitWith // always if on a small island
    {
        SYG_islandDefeatTracks call SYG_playRandomTrack;
    };

    if (_this call SYG_pointOnRahmadi) exitWith // always if on Rahmadi
    {
        SYG_RahmadiDefeatTracks call SYG_playRandomTrack;
    };

    // no special conditions found, play std music now
    call SYG_playRandomDefeatTrack;
};

SYG_OFPTracks =
    [
	    ["ATrack24",[8.269,5.388],[49.521,7.320],[158.644,6.417],[234.663,-1]],
		["ATrack25",[0,11.978],[13.573,10.142],[105.974,9.508],[138.443,-1]]
	];

/*
    Music for town counter attacks
*/
SYG_counterAttackTracks =
    [
        ["ATrack24",[0,59.76]],
        ["ATrack24",[60,73]],
        ["ATrack24",[134,-1]],

        ["ATrack25",[0,71]],
        ["ATrack25",[71,-1]],

        "ATrack1","ATrack23","fear2","ruffian","mission_impossible"
    ];

SYG_playRandomOFPTrack = {
    SYG_OFPTracks call SYG_playRandomTrack;
};

SYG_chorusDefeatTracks =
    [
        ["ATrack26",[0,8]],
        ["ATrack26",[8.086,8]],
        ["ATrack26",[16.092,6.318]],
        ["ATrack26",[24.014,8.097]],
        ["ATrack26",[32.06,-1]],
        ["church_organ_1"],
        ["church_voice"],
        ["haunted_organ_1"],
        ["haunted_organ_2"]

    ];

// if you suicided near (50 meters) church
SYG_liturgyDefeatTracks = [  "liturgy_1","liturgy_2","liturgy_3","liturgy_4" ];


// Any isle defeat music
SYG_islandDefeatTracks = [ SYG_chorusDefeatTracks ] + SYG_OFPTracks + ["treasure_island_defeat"];

SYG_RahmadiDefeatTracks = ["ATrack23",[0,9.619],[9.619,10.218],[19.358,9.092],[28.546,9.575],[48.083,11.627],[59.709,13.203],[83.721,-1]];

//
// Plays random track or track part depends on input array kind (see below)
// This procedure use only playMusic operator and playe items from CfgMisic section
//
// call: _arr call SYG_playRandomTrack;
// where _arr may be:
// 1. _arr = ["ATrack9","ATrack10","ATrack14"]; // play full random track
// 2. _arr = ["ATrack24",[8.269,5.388],[49.521,7.320],[158.644,6.417],[234.663,-1]]; // play random part of the track
// 3. _arr = "ATrack24"; // play full track
// 4. _arr = ["ATrack24"]; // play full track
//
SYG_playRandomTrack = {
    //hint localize format["+++ scripts/SYG_utilsSound.sqf: input %1 +++",_this];
    if (typeName _this == "STRING") exitWith // 3. _arr = "ATrack24"; // play full track
    {
#ifdef __DEBUG__
        hint localize format["--- ""%1"" call SYG_playRandomTrack;",_this];
#endif
        playMusic _this
    }; // full track

    if ( typeName _this != "ARRAY") exitWith // must be array or string
    {
        hint localize format["--- SYG_playRandomTrack: unknown params %1",_this];
    };

    // if we are here, it is ARRAY
    if (count _this == 0) exitWith
    {
        hint localize "--- SYG_playRandomTrack : empty input array";
    };

    // count >= 1
    if ( (typeName arg(0)) == "ARRAY" ) exitWith // array of array
    {
        RANDOM_ARR_ITEM(_this) call SYG_playRandomTrack; // find random array and try to play from it
    };

    //
    // if here it is some ARRAY
    //
    if (count _this == 1) exitWith
    {
        if (  typeName arg(0) == "STRING") exitWith
        {
            playMusic arg(0);
        };
        hint localize format["--- ""%1"" call SYG_playRandomTrack;",_this ];
    };

    // Check to be array of size > 1 and with special items sequence ["cosmos",[0, 10]]
    if ( (typeName arg(0)) == "STRING") exitWith // ordinal array may be,  mandatory with size > 1
    {
        if ((typeName arg(1)) == "STRING") exitWith // _arr = ["ATrack9","ATrack10", ..., ["ATrack12,[10,10]]...];
        {
            _item = RANDOM_ARR_ITEM(_this) call SYG_playRandomTrack;
        }; // list of tracks, play any selected
        //
        // ["ATrack12,[10,10]<,[20,15]>]
        // first is track name (STRING), others are part descriptors [start, length], ...
        //
        if ((typeName arg(1)) == "ARRAY") exitWith  // list of track parts
        {
            private ["_trk"];

            // in rare random case (1 time from 50 attempts) play whole track
            if ( (random 50) < 1) exitWith
            {
#ifdef __DEBUG__
                hint localize format[ "SYG_playRandomTrack: play whole track %1 now !!!", arg(0)];
#endif
                playMusic arg(0)
            };

            // play partial random sub-track
            _trk = floor(random ((count _this)-1)) + 1;
            _trk = arg(_trk); // get any random partial item, excluding 1st (sound name)
            if ( argp(_trk,1) > 0) then // partial length defined, else play up to the end of music
            {
#ifdef __DEBUG__
                hint localize format["SYG_playPartialTrack: %1",[arg(0),argp(_trk,0),argp(_trk,1)]];
#endif
                [arg(0),argp(_trk,0),argp(_trk,1)] spawn SYG_playPartialTrack;
            }
            else
            {
#ifdef __DEBUG__
                hint localize format["SYG_playRandomTrack: %1",[arg(0),argp(_trk,0)]];
#endif
                playMusic [arg(0),argp(_trk,0)];
            };

        };
        hint localize format["--- ""%1"" call SYG_playRandomTrack;",_this ];
    };
    hint localize format["--- ""%1"" call SYG_playRandomTrack;",_this ];
};

//
// Changes position for sound created with call to createSoundSource function
//
// Example:
// _sndArr = [_sound];
// [ _caller, _sndArr] call SYG_moveSoundSource; // 1st sound ar index 0 from _sndArr is changed place to the _caller position
//
SYG_moveSoundSource = {
	private ["_caller", "_id", "_args", "_snd", "_pos"];

	_caller = _this select 0;
	_args = _this select 1; // [ [snd1, snd2 ...], pos ]
	_arr = _args select 0; // array with sounds
	_pos = 0; // pos in array
	if ( count _this > 2 ) then
	{
		_pos = _this select 2; // special pos in array, not zero one
	};
	_snd = _arr select _pos; // sound to move to
	if ( !isNull snd ) then
	{
		deleteVehicle _snd;
		sleep 0.1;
		_snd = createSoundSource ["Music", getPosASL _caller, [], 0];
		_arr set [ _pos, _snd];
		_caller globalChat format["Movesnd: snd pos: %2, new pos is %1", getPosASL _caller, getPosASL _snd];
	};
};

if (true) exitWith {};
