//++++++++++++++++++++++++++++++++++++++++++++++++++++++
// scripts\SYG_utilsSound.sqf
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
#define DEATH_COUNT_TO_PLAY_MUSIC 50

SYG_lastPlayedSoundItem = ""; // last played music/sound item
SYG_deathCountCnt = 0;

SYG_checkLastSoundRepeated= {
    private ["_item","_ind","_ind0"];
    _ind = floor(random(count _this));
    _item = _this select _ind;
    if ( count _this > 1 ) then
    {
        if ( str(_item) == SYG_lastPlayedSoundItem ) then
        {
            _ind0 = floor( random( ( count _this ) - 1 ) );
            if ( _ind0 >= _ind ) then { _ind0  = _ind0 + 1 };
            _item = _this select _ind0;
        };
    };
    SYG_lastPlayedSoundItem = str(_item); // store current sound
    _item
};

//
// call as: 
//  _musicName = _music_index call SYG_musicTrackName; // index from 0 to ((call SYG_musicTrackCount) - 1)
//  playMusic ( floor( random (call SYG_musicTrackCount) ) call SYG_musicTrackName);
//
SYG_musicTrackName = {
	if ( _this < 0 or _this >= (call SYG_musicTrackCount) ) exitWith { "" }; // no such track
	configName((configFile >> "CfgMusic") select _this)
};

/*
 * call as: 1 call SYG_playMusicTrack;
 * Returns started track name, or "" if bad index designated
 */
SYG_playMusicTrack = {
	private ["_name"];
	if ( _this < 0 or _this >= (call SYG_musicTrackCount) ) exitWith { "" }; // no such track
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
    ["Delerium_Wisdom","pimbompimbom","vendetta","take_five"],
    ["Gandalf_Simades","whold","end","radionanny"],
    ["ATrack9","ATrack10","ATrack14"],
    ["ATrack16","ATrack17","ATrack18"],
    ["ATrack20","ATrack21","ATrack22","thetrembler"],
    ["arroyo","ATrack15","ATrack19","sinbad_baghdad"],
    ["ATrack1",[0,8.412],[9.349,5.911],[15.254,10.407],[30.272,9.157]],
    ["ATrack23",[0,8.756],[28.472,8.031],[49.637,9.939],[91.435,5.302]],
    ["i_new_a_guy","decisions","treasure_island_defeat","hound_chase"],
    ["sorcerie","melody","thefuture","moon_stone"],
    ["fear2",[0, 10.45],[10.45,7.4],[17.641,7.593],[25.34,7.314],[40.124,8.882]],
    ["cosmos",[0,8.281],[14.25,9.25],[28.8,-1]]

];

// Play music from partial track (Arma-1 embed music and some long custom sounds may be)
// call as:
// [name, start, length (seconds)] call SYG_playPartialTrack;
SYG_playPartialTrack = {playMusic [_this select 0,_this select 1];sleep ((_this select 2)-1); 1 fadeMusic 0; sleep 1; playMusic ""; 0 fadeMusic 1;};

SYG_playRandomDefeatTrack = {
    SYG_defeatTracks call SYG_playRandomTrack;
};

SYG_rammsteinDefeatTracks1 = ["rammstein_1","rammstein_2","rammstein_3","rammstein_4"];
SYG_rammsteinDefeatTracks2 = ["rammstein_5","rammstein_6","rammstein_7","rammstein_8","rammstein_9"];

SYG_northDefeatTracks =
[
    ["ATrack7",[0,8.743],[57.582,7.755],[65.505,9.385],[77.076,11.828]],
    ["ATrack7",[117.908,8.1],[184.943,6.878],[191.822,9.257],[201.144,6.848]],
    ["ATrack9","ATrack10","ATrack19","bolero"],
    ["metel","gayane1","gayane2","gayane3", "mountains"],
    SYG_rammsteinDefeatTracks1,   SYG_rammsteinDefeatTracks2
];

SYG_southDefeatTracks =
[
    ["ATrack8",[0,10.801],[11.243,9.135],[22.175,6.533]],
    ["ATrack8",[29.332,7.392],[36.723,7.492],[44.219,7.496]],
    ["ATrack8",[51.715,7.287],[59.002,8.563],[67.565,7.704]],
    ["ATrack8",[75.269,8.823],[84.092,9.734],[95.986,6.246]],
    ["ATrack8",[103.377,7.157],[141.480,11.66],[153.293,9.286]],
    ["ATrack11","ATrack12","ATrack13"],
    ["arroyo","arabian_death","the_complex"],
    ["sinbad_baghdad","whatsapp","stripped_voyage"]
];

SYG_baseDefeatTracks =
[
    "tezcatlipoca","village_ruins","yma_sumac","yma_sumac_2","aztecs","aztecs2","aztecs3","aztecs4","aztecs5","aztecs6",
    "betrayed","aztecs4","Gandalf_Simades","whold","end","thetrembler","arroyo","bolero","Delerium_Wisdom","pimbompimbom",
    "gamlet_hunt","treasure_island_defeat","musicbox_silent_night","i_new_a_guy","decisions","church_organ_1","sorcerie",
    "melody","medieval_defeat","defeat2","arabian_death", "village_consort","radionanny","hound_chase","moon_stone","take_five",
    ["cosmos", [0,8.281] ],
    ["cosmos", [14.25,9.25] ],
    ["cosmos", [28.8,-1] ],
    ["ruffian",[0,10.27]],
    ["Vremia_vpered_Sviridov",[0.479,9.778]],
	SYG_rammsteinDefeatTracks1,
	SYG_rammsteinDefeatTracks2];

// for the death near TV-tower, independently in town/SM or ordinal on map one
SYG_gongNextIndex = 0;

SYG_getTVTowerGong = {
    format["gong_%1", floor(random 15)]; // gong_[0..14].ogg
};

// for the death near medieval castles (2 buildings on whole island)
SYG_MedievalDefeatTracks =
    [
     "medieval_defeat",  "medieval_defeat1",  "medieval_defeat2",  "medieval_defeat3",  "medieval_defeat4",  "medieval_defeat5",
     "medieval_defeat6",  "medieval_defeat7",  "medieval_defeat8",  "medieval_defeat9", "medieval_defeat10", "medieval_defeat11",
     "medieval_defeat12", "medieval_defeat13", "medieval_defeat14", "medieval_defeat15", "medieval_defeat16", "medieval_defeat17",
     "village_consort"
    ];


SYG_getWaterDefeatTracks = {
    if (localize "STR_LANGUAGE" == "RUSSIAN" && (random 2) < 1 ) exitWith { "fish_man_song" };
    format["under_water_%1", ceil 9];
};

SYG_playWaterSound = {
    (call SYG_getWaterDefeatTracks) call SYG_playRandomTrack;
};

SYG_getSubmarineSound = {
	format["submarine_sound_%1", ceil (random 6)]; // sounds from 1 to 6
};

// All available curche types in the Arma (I think so)
SYG_religious_buildings =  ["Church","Land_kostelik","Land_kostel_trosky","Land_R_Minaret"];

// returns random male laughter sound on your defeate
SYG_getLaughterSound =
{
    ["laughter_1","laughter_2","laughter_3","laughter_4","laughter_5","laughter_6","laughter_7","laughter_8",
    "laughter_9","laughter_10","laughter_11","laughter_12",
    "good_job","game_over","get_some","go_go_go","cheater","busted",
    "greatjob1","greatjob2","fight","handsup","indeanwarcry",
    "targetdown47","targetdown01","bastards","clear", "shoot_MF","target_neutralised",
    "tasty","doggy","score"] call XfRandomArrayVal
};
// NOTE: Plays ONLY music (items from CfgMusic), not sound (CfgSounds)
// call: _unit call SYG_playRandomDefeatTrackByPos;
// or
//       getPos _vehicle call SYG_playRandomDefeatTrackByPos;
SYG_playRandomDefeatTrackByPos = {
    _done = false;
    hint localize "+++ SYG_playRandomDefeatTrackByPos +++";
	if (typeName _this != "ARRAY") then {// called as: _unit call  SYG_playRandomDefeatTrackByPos;
	    _this = position _this;
	} else {
	    if (( count _this >= 2) && ((_this select 1) isKindOf "Helicopter")) then {// called as: [_player, _killer] call SYG_playRandomDefeatTrackByPos;
	        if (side (_this select 1) == d_enemy_side) then {
    	        playSound format["heli_over_%1", ceil 4];
    	        _done = true;
//  	            hint localize "+++ SYG_playRandomDefeatTrackByPos: helicopter_fly_over, done";
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
	if (playerSide == west) then {
		_flag = WFLAG_BASE;
	} else {
		_flag = RFLAG_BASE;
	};
    #endif

    // death in water
    if (surfaceIsWater _this) exitWith { call SYG_playWaterSound};

    // check if we are near some church
    _churchArr = nearestObjects [ _this, SYG_religious_buildings, 100];
    if ( (count _churchArr > 0) && ((random 10) > 1)) exitWith {
        SYG_chorusDefeatTracks call SYG_playRandomTrack; // 9 time from 10
        hint localize "+++ SYG_playRandomDefeatTrackByPos: SYG_chorusDefeatTracks, done";
    };

    // check if we are near base flag
    if ( (!isNull  _flag) && ((_this distance _flag) <= NEW_DEATH_SOUND_ON_BASE_DISTANCE) ) exitWith {
        SYG_baseDefeatTracks call SYG_playRandomTrack;
        hint localize "+++ SYG_playRandomDefeatTrackByPos: SYG_baseDefeatTracks, done";
    };

    // check if we are near TV-Tower
    _TVTowerArr = _this nearObjects [ "Land_telek1", 50];
    if ( ((count _TVTowerArr) > 0) && ((random 10) > 1)) exitWith {
        // let gong play sequentially on one client (in MP it will be randomized)
        _sound =  format["gong_%1", SYG_gongNextIndex];
        SYG_gongNextIndex = (SYG_gongNextIndex + 1) mod 16; // number of gong sounds
        ["say_sound", _TVTowerArr select 0, _sound] call XSendNetStartScriptClientAll; // gong from tower
        hint localize "+++ SYG_playRandomDefeatTrackByPos: gong, say_sound, done";
    };

    // check if we are near castle
    _castleArr = _this nearObjects [ "Land_helfenburk", 800]; // This radious includes Mercallilo and Benoma wholly!
    if ( ((count _castleArr) > 0) && ((random 10) > 1)) exitWith {
        SYG_MedievalDefeatTracks call SYG_playRandomTrack;
        hint localize "+++ SYG_playRandomDefeatTrackByPos: SYG_MedievalDefeatTracks, done";
    };

    if (_this call SYG_pointOnIslet) exitWith { // always if on a small island
        SYG_islandDefeatTracks call SYG_playRandomTrack;
        hint localize "+++ SYG_playRandomDefeatTrackByPos: SYG_islandDefeatTracks, done";
    };

    if (_this call SYG_pointOnRahmadi) exitWith {// always if on Rahmadi
        SYG_RahmadiDefeatTracks call SYG_playRandomTrack;
        hint localize "+++ SYG_playRandomDefeatTrackByPos: SYG_RahmadiDefeatTracks, done";
    };

    // no special conditions found, play std music now
    switch (_this call SYG_whatPartOfIsland) do {
        case "NORTH": {SYG_northDefeatTracks call SYG_playRandomTrack}; // North Sahrani
        case "SOUTH": {SYG_southDefeatTracks call SYG_playRandomTrack}; // South Sahrani
        default  { call SYG_playRandomDefeatTrack; };                   // Corazol // central Sahrani
    };
};

// OFP music only
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
        "church_organ_1", "church_voice", "haunted_organ_1", "haunted_organ_2", "sorrow_1", "sorrow_2", "sorrow_3", "sorrow_4"

    ];

// if you suicided near (50 meters) church
SYG_liturgyDefeatTracks = [  "liturgy_1","liturgy_2","liturgy_3","liturgy_4","liturgy_5" ];


// Any isle defeat music
SYG_islandDefeatTracks = [ SYG_chorusDefeatTracks ] + SYG_OFPTracks + ["treasure_island_defeat"];

SYG_RahmadiDefeatTracks = ["ATrack23",[0,9.619],[9.619,10.218],[19.358,9.092],[28.546,9.575],[48.083,11.627],[59.709,13.203],[83.721,-1]];

// additional sound, when base is under attack
SYG_onBaseAttackSound = {"enemy_attacks_base"};

//
// NOTE: play music by playMusic call, not playSound, so use sections only from CfgMusic, never from CfgSounds
// Plays random track or track part depends on input array kind (see below)
// NOTE: This procedure use only playMusic operator and player items from CfgMisic sections
//
// call: _arr call SYG_playRandomTrack;
// where _arr may be:
// 1. _arr = ["ATrack9","ATrack10","ATrack14"]; // play full random track
// 2. _arr = ["ATrack24",[8.269,5.388],[49.521,7.320],[158.644,6.417],[234.663,-1]]; // play random part of the track
// 3. _arr = "ATrack24"; // play full track
// 4. _arr = ["ATrack24"]; // play full track
//
SYG_playRandomTrack = {
    private ["_this","_item","_trk"];

    //hint localize format["+++ scripts/SYG_utilsSound.sqf: input %1 +++",_this];
    if (typeName _this == "STRING") exitWith {// 3. _arr = "ATrack24"; // play full track
#ifdef __DEBUG__
        hint localize format["+++ ""%1"" call SYG_playRandomTrack;",_this];
#endif
        playMusic _this
    }; // full track

    if ( typeName _this != "ARRAY") exitWith {// must be array or string
        hint localize format["--- SYG_playRandomTrack: unknown params %1",_this];
    };

    // if we are here, it is ARRAY
    if (count _this == 0) exitWith {
        hint localize "--- SYG_playRandomTrack : empty input array";
    };

    // count >= 1
    if ( (typeName (_this select 0)) == "ARRAY" ) exitWith { // array of array
        _item = _this call SYG_checkLastSoundRepeated;
        _item call SYG_playRandomTrack; // find random array and try to play from it
    };

    //
    // if here it is some ARRAY
    //
    if (count _this == 1) exitWith {
        if (  typeName (_this select 0) == "STRING") exitWith {
            playMusic arg(0);
        };
        hint localize format["--- 1: ""%1"" call SYG_playRandomTrack;",_this ];
    };

    // Check to be array of size > 1 and with special items sequence ["cosmos",[0, 10]]
    if ( (typeName (_this select 0)) == "STRING") exitWith {// ordinal array may be,  mandatory with size > 1
        if ((typeName (_this select 1)) == "STRING") exitWith { // _arr = ["ATrack9","ATrack10", ..., ["ATrack12,[10,10]]...];
            _item = _this call SYG_checkLastSoundRepeated;
            _item call SYG_playRandomTrack;
        }; // list of tracks, play any selected
        //
        // ["ATrack12,[10,10]<,[20,15]>]
        // first is track name (STRING), others are part descriptors [start, length], ...
        //
        if ((typeName (_this select 1)) == "ARRAY") exitWith {
            // list of track parts
            // check if death count is too big and play long-long music for this case
            if (SYG_deathCountCnt > DEATH_COUNT_TO_PLAY_MUSIC) exitWith {
                // in rare case (more then 30-40 death in one session) play whole track
#ifdef __DEBUG__
                hint localize format[ "*** SYG_playRandomTrack: play whole track %1 now, death count %2!!!", arg(0), SYG_deathCountCnt];
#endif
                SYG_deathCountCnt = 0;
                if (call SYG_playExtraSounds) then { playMusic arg(0); };
            };

            // play partial random sub-track
            _trk = floor(random ((count _this)-1)) + 1;
            _trk = _this select _trk; // get any random partial item, excluding 1st (sound name)
            // TODO: not allow the same partial track
            if ( (_trk select  1) > 0) then { // partial length defined, else play up to the end of music
#ifdef __DEBUG__
                hint localize format["*** SYG_playPartialTrack: %1",[arg(0),argp(_trk,0),argp(_trk,1)]];
#endif
                [arg(0),argp(_trk,0),argp(_trk,1)] spawn SYG_playPartialTrack;
            } else {
#ifdef __DEBUG__
                hint localize format["*** SYG_playRandomTrack: %1",[arg(0),argp(_trk,0)]];
#endif
                playMusic [arg(0),argp(_trk,0)];
            };
        };
        hint localize format["--- 2: ""%1"" call SYG_playRandomTrack;",_this ];
    };
    hint localize format["--- 3: ""%1"" call SYG_playRandomTrack;",_this ];
};

// NOT IN USE AT ALL
// Changes position for sound created with call to createSoundSource function
//
// Example:
// _sndArr = [_sound];
// [ _caller, _sndArr] call SYG_moveSoundSource; // 1st sound ar index 0 from _sndArr is changed place to the _caller position
//
SYG_moveSoundSource = {
	private ["_caller", "_id", "_args", "_snd", "_pos","_arr"];

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

/**
  gets name of the sound class
  call as:
    _sound_name = _sound_class_name call SYG_getSoundName;
    returns empty string if no name found, or string with name property in sound class (also may be empty)
 */
SYG_getSoundName = {

    private ["_name","_type","_isText","_str"];

    _name = _this;
    _isText = isText(configFile >> "CfgSounds" >> _name >> "name" );
    _name = getText(configFile >> "CfgSounds" >> _this >> "name");
    _type = typeName _name;
    _str = format["+++ typeName ""%1"" is ""%2"", isText %3", _name, _type, _isText];
    hint localize _str;
    player groupChat _str;
    if (_isText) exitWith {_name};
    ""
};

/**
  gets name of the music class
  call as:
    _music_name = _music_class_name call SYG_getMusicdName;
    returns empty string if no name found, or string with name property in music class (also may be empty)
 */
SYG_getMusicName = {
    if ( typeName _this != "STRING" ) exitWith {""};
    private ["_name","_type"];

    _config = configFile >> "CfgMusic" >> _this >> "name";
//    player groupChat format["+++ Config %1", _config];
    _name = getText(configFile >> "CfgMusic" >> _this >> "name" );
    _isText = isText(configFile >> "CfgMusic" >> _this >> "name" );
    _isNumber = isNumber(configFile >> "CfgMusic" >> _this >> "name" );
    _str = format["+++ music ""%1"", name ""%2"", typeName %3, isText %4", _this, _name, typeName _name, _isText];
    hint localize _str;
    player groupChat _str;
    if (_isText) exitWith {_name};
    ""
};

// static randomized sound assigned on the first call to this fanction
SYG_getSuicideScreamSound  = {
    if (isNil "SYG_suicideScreamSound") then {SYG_suicideScreamSound = "male_scream_" + str(floor(random 15))};  // 0-13
    SYG_suicideScreamSound
};

// call: _sound = _id call SYG_getSuicideScreamSoundById; // return sound according to the designated _id (must be in range[0..N]
SYG_getSuicideScreamSoundById  = {
    if (_this < 0) exitWith {call SYG_getSuicideScreamSound};
    format ["male_scream_%1",  str( _this % 15)] //  returns sound from the range {0.. 14}
};

/**
 *  Plays mysic for the next weather forecast act
 * TODO: create weather forecast event system and sound it
 */
SYG_playWeatherForecastMusic = {
    ["manchester_et_liverpool",  [0, 9.465], [10.092, 9.182], [ 18.42,   8.01], [ 26.74,   7.27], [ 34.006, 11.215], [ 45.221, -1] ];
};


//
// play random sound about death in tank
// returns: true if player is russian and sound played
//          or false if not russian and sound not played
//
SYG_tanks_music = [ "chiz_tanki_1", "chiz_tanki_2" ];
SYG_playDeathInTankSound = {
    if ( localize "STR_LANGUAGE" == "RUSSIAN") exitWith {
        if (random 3 > 1) then {playSound RANDOM_ARR_ITEM(SYG_tanks_music)} // Chiz song about tankists
        else {["say_sound", player, "tanki"] call XSendNetStartScriptClientAll}; // exclamation "Tanks!!!"
        true
    };
    false
};

//
// play random sound about death from enemy tank
// "Время вперёд", далее "Раммштейн 1-й и 5-й", gayane2, the_complex.ogg, betrayed.ogg
SYG_enemy_tanks_music = [ ["Vremia_vpered_Sviridov",0.451, 9.795], "gayane2", "the_complex", "betrayed","rammstein_1","rammstein_5"];

SYG_playDeathFromEnemyTankSound = {
    SYG_enemy_tanks_music call SYG_playRandomTrack;
};

SYG_getFemaleFuckSpeech = {
    private ["_arr"];
	_arr = ["woman_fuck","woman_fuck_2","woman_fuck_3","woman_fuck_4","woman_fuck_5","woman_kidding","woman_motherfucker","woman_sob","woman_svoloch","sorry_11","woman_dont_trust"];
    switch localize "STR_LANG" do {
        case "RUSSIAN": { _arr = _arr + ["woman_svoloch","woman_svoloch","woman_svoloch"]};
    };
	_arr call XfRandomArrayVal
};

SYG_getFemaleExclamation = {
    ["woman_excl1","woman_excl2","woman_excl3","woman_excl4","woman_excl5","woman_excl6","woman_excl7","woman_dont_trust"] call XfRandomArrayVal;
};

SYG_getMaleFuckSpeech = {
	["exclamation1", "exclamation2", "male_fuck_1"] call XfRandomArrayVal
};

SYG_captainRankSound = {
    format["captain_rus_%1", ceil (random 2)]
};

SYG_corporalRankSound = {
    "corporal_eng_1"
};

SYG_sergeantRankSound = {
    "sergeant_eng_1"
};

SYG_colonelRankSound = {
    format["colonel_rus_%1", ceil (random 2)]
};

SYG_exclamationSound = { format["exclamation%1", ceil (random 6)] };

SYG_fearSound = {["fear","bestie","gamlet","fear3","heartbeat","the_trap","koschei","sinbad_sckeleton","fear4","fear_Douce_Violence"] call XfRandomArrayVal};

SYG_invasionSound = {
    ["invasion","kwai","starwars","radmus","enemy","ortegogr"] call XfRandomArrayVal
};

SYG_prisonersSound = {
    private ["_rnd"];
    _rnd = random 10;
    if ( _rnd > 4) exitWith {call SYG_exclamationSound};
    format[ "hisp%1", ceil _rnd]
};

if (true) exitWith {};
