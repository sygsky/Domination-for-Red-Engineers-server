//++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
// Script to detect if designated weapon is sniper one (return true) or not (return false)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++

#include "x_setup.sqf"
#include "x_macros.sqf"

#define __DEBUG__

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

SYG_defeatTracks =
[
    ["Delerium_Wisdom","pimbompimbom","vendetta","thefuture"],
    ["mountains","Gandalf_Simades","whold","end"],
    ["ATrack9","ATrack10","ATrack14","ATrack15"],
    ["ATrack16","ATrack17","ATrack18","ATrack19"],
    ["ATrack20","ATrack21","ATrack22","thetrembler","arroyo"],
    ["ATrack1",[0,8.412],[9.349,5.911],[15.254,10.407],[30.272,9.157]],
    ["ATrack23",[0,8.756],[28.472,8.031],[49.637,9.939],[91.435,5.302]]
];

SYG_playPartialTrack = {playMusic [_this select 0,_this select 1];sleep ((_this select 2)-1); 1 fadeMusic 0; sleep 0.1; playMusic ""; 0 fadeMusic 1;};

SYG_playRandomDefeatTrack = {
    SYG_defeatTracks call SYG_playRandomTrack;
};

SYG_northDefeatTracks =
[
    ["ATrack7",[0,8.743],[57.582,7.755],[65.505,9.385],[77.076,11.828]],
    ["ATrack7",[117.908,8.1],[184.943,6.878],[191.822,9.257],[201.144,6.848]],
    ["ATrack9","ATrack10","ATrack19","bolero"]
];

SYG_baseDefeatTracks =
    [
    "tezcatlipoca","village_ruins","yma_sumac","yma_sumac_2","aztecs","aztecs2","aztecs3","aztecs4","aztecs5","aztecs6",
    "betrayed","aztecs4","Gandalf_Simades","whold","end","thetrembler","arroyo","bolero","Delerium_Wisdom","pimbompimbom"
    ];


SYG_southDefeatTracks =
[
    ["ATrack8",[0,10.801],[11.243,9.135],[22.175,6.533]],
    ["ATrack8",[29.332,7.392],[36.723,7.492],[44.219,7.496]],
    ["ATrack8",[51.715,7.287],[59.002,8.563],[67.565,7.704]],
    ["ATrack8",[75.269,8.823],[84.092,9.734],[95.986,6.246]],
    ["ATrack8",[103.377,7.157],[141.480,11.66],[153.293,9.286]],
    ["ATrack11","ATrack12","ATrack13","arroyo"]
];

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
    if ( (!isNull  _flag) && ((_this distance _flag) <= NEW_DEATH_SOUND_ON_BASE_DISTANCE) ) exitWith
    {
        SYG_baseDefeatTracks call SYG_playRandomTrack;
    };

    if (_this call SYG_pointOnIslet) exitWith
    {
        SYG_islandDefeatTracks call SYG_playRandomTrack;
    };

    if (_this call SYG_pointOnRahmadi) exitWith
    {
        SYG_RahmadiDefeatTracks call SYG_playRandomTrack;
    };

    switch (_this call SYG_whatPartOfIsland) do
    {
        case "NORTH": {SYG_northDefeatTracks call SYG_playRandomTrack};
        case "SOUTH": {SYG_southDefeatTracks call SYG_playRandomTrack};
        default  // Corazol
        {
            call SYG_playRandomDefeatTrack
        };
    };
};

SYG_OFPTracks =
    [
	    ["ATrack24",[8.269,5.388],[49.521,7.320],[158.644,6.417],[234.663,-1]],
		["ATrack25",[0,11.978],[13.573,10.142],[105.974,9.508],[138.443,-1]]
	];

SYG_playRandomOFPTrack = {
    SYG_OFPTracks call SYG_playRandomTrack;
};

// Any isle defeat music
SYG_islandDefeatTracks =
        [
            ["ATrack26",[0,8],[8.086,8],[16.092,6.318],[24.014,8.097],[32.059,4.0],[36.053,-1]],
            ["ATrack24",[8.269,5.388],[49.521,7.320],[158.644,6.417],[234.663,-1]],
            ["ATrack25",[0,11.978],[13.573,10.142],[105.974,9.508],[138.443,-1]]
        ];

SYG_RahmadiDefeatTracks = ["ATrack23b",[0,9.619],[9.619,10.218],[19.358,9.092],[28.546,9.575],[48.083,11.627],[59.709,13.203],[83.721,-1]];

//
// Plays random track or track part depends on input array kind (see below)
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
        hint localize format["""%1"" call SYG_playRandomTrack;",_this];
#endif
        playMusic _this
    }; // full track
    if ( typeName _this != "ARRAY") exitWith
    {
        hint localize format["SYG_playRandomTrack: unknown params %1",_this];
    };
    // if here it is some ARRAY
    if (count _this == 0) exitWith
    {
        hint localize "SYG_playRandomTrack : empty input array";
    };
    if ( (count _this == 1) && ((typeName arg(0)) == "STRING")) exitWith // 4. _arr = ["ATrack24"]; // play full track
    {
#ifdef __DEBUG__
        hint localize format["[""%1""] call SYG_playRandomTrack;",_this];
#endif
        playMusic arg(0);
    };
    // count >= 1
    if ( (typeName arg(0)) == "ARRAY" ) exitWith // array of array
    {
        RANDOM_ARR_ITEM(_this) call SYG_playRandomTrack; // find random array and try to play from it
    };
    if ( (typeName arg(0)) == "STRING") exitWith // ordinal array may be
    {
        if ((typeName arg(1)) == "STRING") exitWith // 1. _arr = ["ATrack9","ATrack10" ...]; // play full random track
        {
            _item = RANDOM_ARR_ITEM(_this);
#ifdef __DEBUG__
            hint localize format["""%1"" call SYG_playRandomTrack;",_item];
#endif
            playMusic _item;
        }; // list of tracks, play any selected
        // first is track name (STRING), others are part descriptors [start, length], ...
        if ((typeName arg(1)) == "ARRAY") exitWith  // list of track parts
        {
            private ["_trk"];

            // in rare random case (1 time from 100 attempts) play whole track
            if ( (random 100) < 1) exitWith
            {
#ifdef __DEBUG__
                hint localize format["SYG_playRandomTrack: play whole track %1 now !!!",arg(0)];
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
    };
    hint localize format["SYG_playRandomTrack: can't parse input %1", _this];
};

//
// Changes positon for sound created with call to createSoundSource function
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
