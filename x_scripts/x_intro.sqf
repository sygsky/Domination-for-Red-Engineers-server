// x_intro.sqf, by Xeno
/*
	All variants of this script usage.

	Arrival on:
	1.Base
		1.1. You are private: jump over ridge near base
	2. Antigua
		2.1. Flight on DC-3 and jump above Antigao west hill part

*/
private ["_s","_str","_dlg","_XD_display","_control","_line","_camstart","_intro_path_arr",
         "_plpos","_i","_XfRandomFloorArray","_XfRandomArrayVal","_cnt","_lobj", "_lobjpos",
		 "_year","_mon","_day","_newyear","_holiday","_camera","_start","_pos","_tgt","_sound","_date","_music",
		 "_spawn_point","_para","_doJump"];
if (!X_Client) exitWith {hint localize "--- x_intro run not on client!!!";};
//hint localize "+++ x_intro started!!!";
d_still_in_intro = true;
_start_time = time; // to calculate time to visit base

#include "x_setup.sqf"
#include "x_macros.sqf"

#define __DEBUG__
#define __TIME_OF_DAY_MISIC__
// #define __SOVIET_MUSIC_ONLY__

// uncomment next line to test how 23-FEB-1985, 7-NOV-1985 etc are processed as Soviet holiday
//#define __HOLIDAY_DEBUG__

#define RANDOM_POS_OFFSET 5 // 5 meters to offset any point except last one
// get a random number, floored, from count array
// parameters: array
// example: _randomarrayint = _myarray call XfRandomFloorArray;
_XfRandomFloorArray = {
	floor (random (count _this))
};

// get a random item from an array
// parameters: array
// example: _randomval = _myarray call XfRandomArrayVal;
_XfRandomArrayVal = {
	_this select (_this call _XfRandomFloorArray);
};

//++++++++++++++++++++++++++++++
//      find spawn point depending on parachute used
// call: _spawn_point = _paratype call _makeSpawnPoint;
//+++++++++++++++++++++++++++++
_makeSpawnPoint = {
	private ["_spawn_rect","_para","_id","_pnt"];
#ifdef __ACE__
	_para = _this;
	_id = (SPAWN_INFO select 0) find _para;
//	hint localize format["+++ x_intro/_makeSpawnPoint: _para %1, _id %2, SPAWN_INFO %3", _para, _id, SPAWN_INFO];
	if ( _id >= 0) then {  // find point according to the parachute type (0 - planning one, 1 - round)
		_spawn_rect = +((SPAWN_INFO select 2) select _id); // drop rect for planning parachute
		hint localize "+++ x_intro/_makeSpawnPoint: jump point is set for gliding parachute";
	} else {
#endif
		_spawn_rect = +((SPAWN_INFO select 2) select 1);
		hint localize "+++ x_intro/_makeSpawnPoint: jump point is set for round parachute";
#ifdef __ACE__
	};
#endif
//	hint localize format["+++ x_intro/_makeSpawnPoint: _spawn_rect %1", _spawn_rect ];
//	waitUntil {!(isNil "XfGetRanPointSquareOld")};
	_pnt = _spawn_rect call XfGetRanPointSquareOld;
	_pnt set [2, ((_spawn_rect select 0) select 2)]; // set point height the same as in rect
	_pnt
};

enableRadio false;
showCinemaBorder false;
//_phiteh = player addEventHandler ["hit", {(_this select 0) setDamage 0}];_pdamageeh = player addEventHandler ["dammaged", {(_this select 0) setDamage 0}];
_dlg = createDialog "X_RscAnimatedLetters";
_XD_display = findDisplay 77043;
_control = _XD_display displayCtrl 66666;
_control ctrlShow false; // dont remove last 3 lines as they needed to show text with delay
_line = 0;
i = 0;

/*
#ifdef __DEBUG__
SYG_client_start = [2015,12,25,8,0,0 ];
hint localize format["x_intro.sqf: time %1, for debugging purposes missionStart set to %2", time, SYG_client_start call SYG_dateToStr];
#endif
*/

_year = SYG_client_start select 0;
_mon  = SYG_client_start select 1;
_day  = SYG_client_start select 2;
_newyear = false;

// ++++++++++++++++++++++ check if today is in soviet holiday list (in 1985)
_holiday = SYG_client_start call SYG_getCountryDay; // country foundation day, if success, return array of 2 items: ["PLAY","music"]
_sound = "";
if ( count _holiday == 0 ) then { // check for some soviet holiday
#ifdef __HOLIDAY_DEBUG__
	_date =  + SYG_client_start;
	_date set [1,11]; _date set [2, 7]; // 07-NOV-1985, 23-FEB-1985 etc
	_holiday = _date call SYG_getHoliday;
#else
	_holiday = SYG_client_start call SYG_getHoliday; // The same as follow: _holiday_arr = [_is_holiday, _music, _title ];
#endif
};
if (count _holiday > 0 ) then {
    // Soviet/country holiday detected, show its info about soviet holiday and/or play correponding sound
    _sound = _holiday select 1;
    _music = _sound;
    playSound _sound;
    hint localize format["+++ x_intro.sqf: holiday detected %1", _holiday];
};

_music_cnt = 0;
if (_sound == "") then { // select random music for an ordinal day
    if ( ( (_mon == 12) && (_day > 20) ) || ( (_mon == 1) && (_day < 11) ) ) then {
    	_music = ((SYG_holidayTable select 0) select 2) call _XfRandomArrayVal;
    	_sound = _music;
        playSound _music; //music for New Year period from 21 December to 10 January
	    hint localize format["+++ x_intro.sqf: New Year music set ""%1""", _music];
        _newyear = true;
    } else {
        // music normally played on intro
        if ( _mon == 11 && (_day >= 4 && _day <= 10) ) then {
            // 7th November is a Day of Great October Socialist Revolution
            _sound = (call compile format["[%1]", localize "STR_INTRO_MUSIC_VOSR"]) call _XfRandomArrayVal;
            _music = _sound;
            playSound  _sound;
		    hint localize format["+++ x_intro.sqf: 7th November period detected, music set ""%1""", _music];
        } else {

#ifdef __TEST__
        	if (name player == "Rokse [LT]") exitWith {
        		_music = ["burnash","johnny","druzba","adjutant",/*"vague",*/"enchanted_boy","ahead_friends","mission_impossible",
        		"lastdime","lastdime2","lastdime3","esli_ranili_druga","soviet_officers","travel_with_friends","on_thin_ice","dangerous_chase"] call _XfRandomArrayVal;
        		playSound _music;
        		_sound = _music;
        		hint localize format["+++ Sound (not music!) for ""%1"" player as intro", _sound];
        	};
#endif
            // add some personalized songs for well known players
            _players =
            [
                ["Ceres-de","CERES de","Ceres.","CERES"] , // Germany
                ["Rokse [LT]"], // military radist
                ["Shelter", "Marcin"], // polyaks
                ["Petigp", "gyuri", "Frosty"], // hungarian
                ["Snooper" ] // Russian from Belorussia
//                ["gyuri"] // Hungary People Republic, August 20, 1949
            ];
            _sounds  =
            [
                ["amigohome_ernst_bush","ddrhymn","zaratustra"],
                ["morze","morze2","morze_0","morze_2","morze_3","morze_4","morze_5","morze_6","morze_7"],
                ["stavka_bolshe_chem","stavka_bolshe_chem","four_tankists","four_tankists"],
                ["hungarian_dances","hungarian_dances","hungarian_dances"],
                ["toccata","toccata","hungarian_dances","hungarian_dances","grig","grig"]
            ];
            _name    = name player;
            _personalSounds = [];
            if (localize "STR_LANG" == "GERMAN") then {
            	// for any german players add german music
				{ [ _personalSounds, _sounds select 0 ] call SYG_addArrayInPlace } forEach [1,2,3];
            } else {
				{
					_pos = _x find _name;
					if ( _pos >= 0 ) exitWith {
					    { [ _personalSounds ,_sounds select _pos ] call SYG_addArrayInPlace } forEach [1,2,3];
					    hint localize format["+++ x_intro.sqf: personal sounds added: %1", _sounds select _pos];
					};
				} forEach _players;
            };
            if ( format["%1",player] in d_can_use_artillery ) then {
                // add special music for GRU soldiers
                { [ _personalSounds, ["from_russia_with_love","bond","on_thin_ice"] ] call SYG_addArrayInPlace } forEach [1,2,3];
            }; // as you are some kind of spy

            // add some rarely heard music now if no personal music set

#ifdef __TIME_OF_DAY_MISIC__
            // music to play day and night, night music can be played at day time, but day music can be played at night time
            _night_music = [
                "bond",/*"bond1",*/"from_russia_with_love","adjutant","total_recall_mountain"/*,"adagio","morze"*/,"morze_3",
                "treasure_island_intro","fear2","soviet_officers"/*,"cosmos"*/,"manchester_et_liverpool","tovarich_moy",
                "hound_baskervill","condor","way_to_dock","melody_by_voice","sovest1","sovest2",/*"del_vampiro1",
                "del_vampiro2",*/"zaratustra","bolivar",/*"jrtheme","vague",*/"enchanted_boy","bloody",
                "peregrinus","kk_the_hole","shaov_defeat","evening_7"
            ];

            // music to play only in day time
            _daytime_music = [
                "grant","burnash","lastdime","lastdime2","lastdime3","mission_impossible","strelok","capricorn1title",
                "Letyat_perelyotnye_pticy_2nd","ruffian"/*,"morze"*/,"morze_3"/*,"chapaev"*/,"rider","Vremia_vpered_Sviridov",
                "Letyat_perelyotnye_pticy_end","toccata","travel_with_friends","on_thin_ice","wild_geese",
                "dangerous_chase"
            ];

            // only night music
//            _music = _night_music + _personalSounds;
            _music = +_night_music;
            if ( count _personalSounds > 0 ) then {
	            [_music, _personalSounds] call SYG_addArrayInPlace;
            } else {
            	[_music, ["ddrhymn", "four_tankists","stavka_bolshe_chem","Varshavianka_eng"]] call SYG_addArrayInPlace;
            };
            // if day time add day music too
            if ( (daytime > SYG_startDay) && (daytime < SYG_startEvening) ) then { [_music, _daytime_music] call SYG_addArrayInPlace };
            _music_cnt = count _music;
            _music = _music call _XfRandomArrayVal;
#else
            _music = ((call compile format["[%1]", localize "STR_INTRO_MUSIC"]) +
            [	// most common sounds list
                "bond",/*"bond1",*/"from_russia_with_love","grant","burnash","adjutant","lastdime","lastdime2","lastdime3",
                "mission_impossible",/*"bond1",*/"strelok",
                "total_recall_mountain","capricorn1title","Letyat_perelyotnye_pticy_2nd",/*"adagio",*/
                "ruffian"/*,"morze"*/,"morze_3","treasure_island_intro","fear2"/*,"chapaev"*/,"soviet_officers"/*,"cosmos"*/,"manchester_et_liverpool",
                "tovarich_moy","rider","hound_baskervill","condor","way_to_dock","Vremia_vpered_Sviridov",
                "Letyat_perelyotnye_pticy_end","melody_by_voice","sovest1","sovest2","toccata",
                /*"del_vampiro1","del_vampiro2",*/"zaratustra","bolivar",/*"jrtheme","vague",*/"travel_with_friends","on_thin_ice","peregrinus",
                "wild_geese","dangerous_chase","kk_the_hole"
            ]
                + _personalSounds ) call _XfRandomArrayVal;
#endif

#ifdef __SOVIET_MUSIC_ONLY__
			_music = ["strelok","Letyat_perelyotnye_pticy_2nd"/*,"chapaev"*/,"soviet_officers","tovarich_moy",
			    "Vremia_vpered_Sviridov","grant","burnash","adjutant","lastdime",
				"Letyat_perelyotnye_pticy_end","sovest1","sovest2","bolivar","hound_baskervill",
				"travel_with_friends","on_thin_ice","peregrinus"] call _XfRandomArrayVal;
#endif


			// _sound = call SYG_getCounterAttackTrack;
			// DEBUG code, remove ASAP
			//_music = ["ATrack24",[0,59.76]]; // one ot tracks
			//waitUntil { !isNil "XHandleNetStartScriptClient"};
			//["say_sound","PLAY",_music,0,30] call XHandleNetStartScriptClient; // show music title on playing

			_sound = _music;
			playSound _music; //playSound "ATrack25"; // oldest value by Xeno
			["log2server", name player, format["intro sound: ""%1""", _sound]] call XSendNetStartScriptServer;

         };
    };
};

if ((daytime > (SYG_startNight + 0.5)) || (daytime < (SYG_startMorning - 0.5))) then {
	camUseNVG true;
};

#ifdef __DEBUG__
hint localize format["+++ x_intro.sqf: music/cnt %1, time is %2, daytime is %3, nowtime is %4, missionStart is %5", format["""%1""/%2", _sound, _music_cnt ], time, daytime, call SYG_nowTimeToStr, SYG_client_start call SYG_dateToStr];
#endif

#ifdef __TT__

d_intro_color = (
	if (playerSide == west) then {
		[0,0,1,1]
	} else {
		[1,1,0,1]
	}
);
_camstart = (
	if (playerSide == west) then {
		camstart
	} else {
		camstart_racs
	}
);

//#ifdef __TT__
#else

d_intro_color = (
	switch (d_own_side) do {
		case "WEST": {[0,0,1,1]};
		case "EAST": {[1,0,0,1]};
		case "RACS": {[1,1,0,1]};
	}
);

_SYG_selectIntroPath = {
	if (true) exitWith { _this call _XfRandomArrayVal }; // TODO: do something not only exit!
	private ["_tt","_pnt","_pos","_i","_min","_path","_ind"];
	_tt = call SYG_getTargetTown;
#ifdef __DEBUG__	
	hint localize format["x_intro.sqf: target town detected %1", _tt];
#endif	

	if ( count _tt == 0) exitWith { _this call _XfRandomArrayVal };
	_pos = + (_tt select 0); // center of town
	_ind = -1; // index of nearest entry
	_posInd = -1; // index of point in nearest path
	//find nearest entry point to the target
	_min = 1000000;
	for "_i" from 0 to (count _this - 1) do {
    	// for each paths in available array
		_path = _this select _i; // whole array of path point + possible last index for object
		for "_j" from 0 to (count _path - 1) do {
		    _x = argp(_path, j); // point [x,y,z] of the path
            if ( (typeName _x) == "ARRAY") then {
                // may be not point but scalar index (last in array)
                if ( (_x distance _pos) < _min ) then {_min = _x distance _pos; _ind = _i; _posInd = j};
            };
		};
	};
	
	// we found the nearest intro path to the target town, assigned to _ind variable
#ifdef __OLD__
	// now find nearest point in this path to target town
	_path = _this select _ind;
	_min = 1000000;
	for "_i" from 0 to (count _path - 2) do {
		if ( ((_path select _i) distance _pos) < _min) then {_min = (_path select _i) distance _pos; _ind = _i;};
	};
	// we found path point nearest to the target town, assigned to the _ind variable
	// now replace this point with target town center!!!
	_pos set [2, -300]; // mark point to camera attention with Z to be abs(Z)
	_path set [_ind, _pos];
#else
	_pos1 = _path select 0;
	_cnt = count _path;
	_pos2 = [_pos1, _pos, - (_pos1 distance _pos)/2] call SYG_elongate2Z;
	_pos2 set[2,-500];
	_pos set[2,-100]; 
	//_pos1 set [2, -(_pos1 select 2)];
	_pos3 = _path select (_cnt - 2);
	_pos3 set [2, -(_pos3 select 2)];
	_path1 = [_pos1,_pos2,_pos,_pos3,[0,0,0]];
	//2nd point will be middle point between start and town
#endif	
	_path1
};

//+++Sygsky TODO: try to prepare flight above all targets
if ( (current_target_index != -1 && !target_clear) && !all_sm_res && !stop_sm && !side_mission_resolved && (current_mission_index >= 0)) then {
	hint localize format["x_intro.sqf: current_target_index = %1, current_mission_index = %2",current_target_index, current_mission_index ];
/* 	_target_array2 = target_names select current_target_index;
	_current_target_pos = _target_array2 select 0;
	_current_target_name = _target_array2 select 1;
	_color = (if (current_target_index in resolved_targets) then {"ColorGreen"} else {"ColorRed"});
	[_current_target_name, _current_target_pos,"ELLIPSE",_color,[300,300]] call XfCreateMarkerLocal;
	"dummy_marker" setMarkerPosLocal _current_target_pos;
	"1" objStatus "DONE";
	call compile format ["""%1"" objStatus ""VISIBLE"";", current_target_index + 2];
 */
};
//--- Sygsky

_pos = [];
_lobjpos = [];
_doJump = false;

#ifdef __CONNECT_ON_PARA__

waitUntil { !(isNil "base_visit_session") }; // wait info about local base visiting state and time

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Structure of info is as follows:
// [[Parashute names list],{Code to decide is jump needed or not},[Respawn rectangles for all parachutes]]
#ifdef __ARRIVED_ON_ANTIGUA__
// Arrival on Antigua only if base not visited during mission and user is Snooper or EngineerACE.
// Later after debugging all players will go through Antigua trip
hint localize "+++ x_intro: __ARRIVED_ON_ANTIGUA__ defined";
if (base_visit_mission < 1) then {
	_arr1 = [[17337,17883,500], 360, 280, 25 ]; // Big rect on Antigua hills
	_arr2 = [[17352,17931,100], 140, 140, 0]; 	 // Small rect on Antigua hills

	SPAWN_INFO = [
	["ACE_ParachutePack","ACE_ParachuteRoundPack"], // parachute types
	{base_visit_mission < 1},						// Code returns true if jump, else return false
	[ _arr1, _arr2], // rect + circle
	_arr2, // Teleport area on kill event
	"ANTIGUA" // name of drop zone
	];
} else {
#endif
	// Old variant of paradropping above ridge near Paraiso (on planning para) and near Somato (on round para)
	// Used as old variant or as variant for players who visited base after Antigua jump but with parachute in inventory on connection
	SPAWN_INFO = [ // AirBase
		["ACE_ParachutePack","ACE_ParachuteRoundPack"],
		{ ( ( ( d_player_stuff select 3 ) call XGetRankIndexFromScore ) < 1) || ( (player call SYG_getParachute) != "") },
		[ [[11306,8386,2000], 600,150, -45], drop_zone_arr select 0 ], // Rect 1 - above ridge near base, rect 2 - near Somato (the same rect as desant one)
		drop_zone_arr select 0, // Teleport area on kill event
		"BASE" // name of drop zone
	];
#ifdef __ARRIVED_ON_ANTIGUA__
};
#endif

hint localize format["+++ x_intro/SPAWN_INFO: %1", SPAWN_INFO];

_dt = d_player_stuff select 1; // #587
hint localize format["+++ x_intro: disconnect time == %1", _dt];

waitUntil { !(isNil "XGetRankIndexFromScore") }; // wait info about time elapsed between last exit and this entrance

_para = player call SYG_getParachute; // we need this statement here!!! Don't move it to the parenthesis
_owned_para = _para;
_rank = (d_player_stuff select 3) call XGetRankIndexFromScore; // score may be not set еще player, so get it from player stuff array
_rname = _rank call XGetRankFromIndex; // rank name
//hint localize format["+++ _rank %1, _rname %2", _rank, _rname ];

//_doJump = /*(base_visit_mission < 1) ||*/ (_rank < 1) || (_owned_para != "");	// check the rank and para weared on user at visit
_doJump = call (SPAWN_INFO select 1);	// check the jump condition

hint localize format["+++ x_intro: _doJump %1, _rank %2(%3), base_visit_mission %4, base_visit_mission %5, parachute '%6'", str(_doJump), _rank, _rname, base_visit_mission, base_visit_mission, _para ];

if (_owned_para != "") then {
	(format[localize "STR_INTRO_PARAJUMP_11",_para]) call XfHQChat; // "You found a parachute (%1) on your back and decided to use it to please the smugglers."
};

if (_doJump) then {
    format["+++ x_intro: Do jump now, _dt %1 secs ago", _dt ];

    //++++++++++++++++++++++++++++++++++++++++++++++++++++
    //      define parachute type (round of square)
    //++++++++++++++++++++++++++++++++++++++++++++++++++++
    waitUntil { !( (isNil "SYG_getParachute") || (isNil "XfRandomArrayVal"))  }; // wait until functions are loaded
    hint localize format["+++ x_intro.sqf: player (alive %1) weapons %2, para %3", alive player,  weapons player, if (_para == "") then {"not found"} else {"found"} ];
    if ( _para == "" ) then {
        #ifdef __ACE__
    //	_para = ["ACE_ParachutePack","ACE_ParachuteRoundPack"] call XfRandomArrayVal;
        _para = "ACE_ParachutePack";
        #endif
        #ifndef __ACE__
        _para = switch (d_own_side) do {
            case "RACS": {"ParachuteG"};
            case "WEST": {"ParachuteWest"};
            case "EAST": {"ParachuteEast"};
        };
        #endif
        player addWeapon _para;
        hint localize format["+++ x_intro.sqf: player has no parachute, assign him with ""%1""",  _para];
    } else { hint localize format["+++ x_intro.sqf: player already has parachute ""%1""", _para]};

    //++++++++++++++++++++++++++++++
    //      find spawn point
    //+++++++++++++++++++++++++++++
    _spawn_point = _para call _makeSpawnPoint;
//    _spawn_point set [2, 500]; // spawn near to the real parachute jump pos
} else {
	base_visit_session = 1;
	_spawn_point  = getPos player;
};

#else
_spawn_point  = getPos player;
#endif

//hint localize format["+++ x_intro.sqf: _spawn_point = %1", _spawn_point];
#ifdef __DEFAULT__
    // 7703.5,7483.2, 0
	// array of camera turn points. Last point is for illusion object creation point.If it is NUMBER in range {0..last_turn_point_index-1>} designated index turn point is used for illusion
  _lines = [
    [[1947,19059,1],[2260,18839,10],[4979,15480,40],[8982.5,10777,150],1], // Island Parvulo (1)
    [[18361,18490,1],[14260,15170,30],[11141,13340,50],[18127,18337,0]], // Isle Antigua (2)
    [[19684.6,14128.7,25],[17681.2,13076.8,40],[15397.76,11924.51,50],[11420,8570,20],[10869,9172,40],[19356,14018,0]], // Pita (3)
    [[1224,1391,1],[1580,1711,20],[8971,8170,70],1], // Rahmadi (4)
    [[18534,2730,1],[18259,2978,10],[11420,8570,20],[10628,9328,40],1], // vulcano Asharan (5)
	[[12113,5833,1],[11820,6059,6],[11717.1,6068.6,15],[11642,6336,15],[11480,6658,15],[11147,7138,11],[10992,7749,21],[11014,7990,31],[11121,8155,51],[11420,8570,46],[10869,9172,41],[12025,6082,0]], // Dolores (6)
	[[6111,17518,1],[7355,17182,60],[12221,15217,50],[12000,14618,50],[10719,14222,70],[8982.5,10777,150],[12270,15217,0]], // Cabo Valiente (7)
	[[19682,12457,1],[19454,11893,20],[17985,9733,20],[16713,8909,20],[15541,8262,20],[13968,7852,20],[13222,8655,30],[12746,9138,10],[12490,10850,30],[9369,11208,10],[8981,10777,40], 7]// 1.5 км to south of Pita near the shore in open sea (8)
  ];
  _camstart = _lines call _SYG_selectIntroPath;
  _pos = _camstart select 1;
  // last pos is illusion object one. If number found it means index of point to use as pos, else it means pos3D to build illusion
  _lobjpos = _camstart select ((count _camstart) - 1);
  if ((typeName _lobjpos) == "SCALAR") then {
	  if (_lobjpos < (count _camstart) - 1) then {
	  	_lobjpos = _camstart select _lobjpos;
	  } else {_lobjpos = _camstart select (count _camstart - 2)}; // use penultimate position
//	  _camstart resize (count _camstart - 1); // remove illusion index from the end of list
  };
//  _lobjpos = if (typeName _lobjpos == "ARRAY") then {_lobjpos} else { _camstart select _lobjpos};
#else
	_camstart = [[(position camstart select 0),(position camstart select 1),175]];
	_pos = _camstart select 0;
#endif

_lobj = (
    ["LODy_test", "Barrels", "Land_kulna","misc01", "Land_helfenburk","FireLit",
    "Land_majak2","Land_zastavka_jih","Land_ryb_domek","Land_aut_zast","Land_telek1",
    "Land_water_tank2","Land_R_Minaret","Land_vez","Land_strazni_vez","Platform"] call _XfRandomArrayVal) createVehicleLocal _lobjpos;
sleep 0.1;
_lobj  setVectorUp [0,0,1]; // make object be upright
switch typeOf _lobj do {
	case "Barrels": { _lobj setDamage 1.0;};
};
//_lobj setDirection (random 360);
  
#define DEFAULT_EXCESS_HEIGHT_ABOVE_POINT 30

#ifdef __CONNECT_ON_PARA__
#define DEFAULT_EXCESS_HEIGHT_ABOVE_HEAD 5
#endif

#define DEFAULT_SHOW_TIME 20
 
//hint localize format["x_intro.sqf: _camstart %1 (cnt %2)", _camstart, count _camstart];

_start = _camstart select 0; // start point

// add last point as player position
_tgt = position player;
_tgt set [2, DEFAULT_EXCESS_HEIGHT_ABOVE_HEAD];
_camstart set [count _camstart -1, _tgt]; // replace illusion position with end point (player pos)

#ifdef __CONNECT_ON_PARA__
if (_doJump && (base_visit_mission < 0)) then {
    // last-1 point is the player pos, last and last+1 are special ones
	_camstart set [count _camstart, (_lines select 1) select 1]; // add Pico de Perez as next WP for the camera
    _camstart set [count _camstart, _spawn_point]; // add Antigua WP for the camera
};
#endif

// calc whole path length/partial segments commit times
_plen = 0; // whole path length
_arr = []; // array of segment lengths
for "_i" from 1 to ((count _camstart) - 1) do { // skip start (1st) point
	_tgt = _camstart select _i; // segment end point
	_pos = _camstart select (_i -1); // segment start point
	_dist = _pos distance _tgt;
	_plen = _plen + _dist;
	_arr set [count _arr, _dist];
};
//hint localize format["+++ x_intro.sqf: campath          [%1] %2", count _camstart, _camstart];
//hint localize format["+++ x_intro.sqf: len %1, segments [%2] %3", _plen, count _arr, _arr];
for "_i" from 0 to ((count _arr) - 1) do {_arr set[_i, (_arr select _i) / _plen * DEFAULT_SHOW_TIME]}; // durations
//hint localize format["+++ x_intro.sqf: time array       [%1] %2", count _arr, _arr];
//hint localize format["x_intro.sqf: updated  camstart is %1", _camstart];
//hint localize format["x_intro.sqf: duration array %1", _arr];

//#ifdef __TT__ #else
#endif

_PS1 = "#particlesource" createVehicleLocal [position player select 0, position player select 1, DEFAULT_EXCESS_HEIGHT_ABOVE_HEAD]; // raise the spark above the player, as the base building became higher
_PS1 setParticleCircle [0, [0, 0, 0]];
_PS1 setParticleRandom [0, [0, 0, 0], [0,0,0], 0, 1, [0, 0, 0, 0], 0, 0];
_PS1 setParticleParams [["\Ca\Data\ParticleEffects\SPARKSEFFECT\SparksEffect.p3d", 8, 3, 1], "", "spaceobject", 1, 0.2, [0, 0, 1], [0,0,0], 1, 10/10, 1, 0.2, [2, 2], [[1, 1, 1 ,1], [1, 1, 1, 1], [1, 1, 1, 1]], [0, 1], 1, 0, "", "", _this];
_PS1 setDropInterval 0.01;

_camera = objNull;
_plpos = [(position player select 0),(position player select 1),1.5];
if ( typeName _camstart == "ARRAY" ) then {
	_camera = "camera" camCreate _start;
	if (surfaceIsWater _start) then { // gurgle if in water
		_camera say "under_water_3";
		sleep (random 0.2);
		_camera say (call SYG_getSubmarineSound);
	};
} else {
	_camera = "camera" camCreate [(position _camstart select 0), (position _camstart select 1) + 1, 200];
};
//hint localize format["x_intro.sqf: started at %1, look to  %2", _start,_camstart select 0];

_camera camCommand "inertia on";
_tgt = [_start,_camstart select 1,30000.0] call SYG_elongate2Z;
_camera camSetTarget _tgt; // illusion object position_plpos; // point ot the player position
_camera camSetFov 0.7;
_camera cameraEffect ["INTERNAL", "Back"];
_camera camCommit 1;
waitUntil {camCommitted _camera}; // complete show of start point of intro path
//hint localize format["x_intro.sqf: initial camera view commiter at %1", time call SYG_userTimeToStr];

#ifdef __TT__
_str = "Two Teams";
_str2 = "";
_sarray = [];
_start_pos = 8;
#else
_str = (localize "STR_INTRO_TEAM") /* "One Team - " */ + d_version_string;
_start_pos = 5;
_start_pos2 = 1;
_str2 = "";
if (__MandoVer) then {if (_str2 != "") then {_str2 = _str2 + " MANDO";} else {_str2 = _str2 + "MANDO";}};
if (__ReviveVer) then {if (_str2 != "") then {_str2 = _str2 + " REVIVE";} else {_str2 = _str2 + "REVIVE";}};
if (__ACEVer) then {if (_str2 != "") then {_str2 = _str2 + " ACE";} else {_str2 = _str2 + "ACE";}};
if (__CSLAVer) then {if (_str2 != "") then {_str2 = _str2 + " CSLA";} else {_str2 = _str2 + "CSLA";}};
if (__P85Ver) then {if (_str2 != "") then {_str2 = _str2 + " P85";} else {_str2 = _str2 + "P85";}};
if (__AIVer) then {if (_str2 != "") then {_str2 = _str2 + " AI";} else {_str2 = _str2 + "AI";}};
if (__RankedVer) then {if (_str2 != "") then {_str2 = _str2 + " RA";} else {_str2 = _str2 + "RA";}};
_sarray = toArray (_str2);
switch (count _sarray) do {
	case 2: {_start_pos2 = 11;};
	case 3: {_start_pos2 = 11;};
	case 4: {_start_pos2 = 10;};
	case 5: {_start_pos2 = 10;};
	case 6: {_start_pos2 = 9;};
	case 7: {_start_pos2 = 9;};
	case 8: {_start_pos2 = 8;};
	case 9: {_start_pos2 = 8;};
	case 10: {_start_pos2 = 8;};
	case 11: {_start_pos2 = 7;};
	case 12: {_start_pos2 = 6;};
	case 15: {_start_pos2 = 4;};
};
#endif

if ( _newyear ) then {
	cutRsc ["XDomLabelNewYear","PLAIN",2];
} else {
	cutRsc ["XDomLabel","PLAIN",2];
};

//[1, "D O M I N A T I O N  3!", 4] execVM "IntroAnim\animateLettersX.sqf";_line = _line + 1; waitUntil {i == _line};
[_start_pos, _str, 5] execVM "IntroAnim\animateLettersX.sqf";_line = _line + 1; waitUntil {i == _line};
if (count _sarray > 0) then {
	[_start_pos2, _str2, 6] execVM "IntroAnim\animateLettersX.sqf";_line = _line + 1; waitUntil {i == _line};
};

if (typeName _camstart != "ARRAY" ) then {
	_camera camSetTarget player;
	_camera camSetPos _plpos;
	_camera camCommit 18;
} else { };

#ifdef __OLD__
// [_music_name<, _wait_title_is_showed_in_secs>] spawn SYG_showMusicTitle;
SYG_showMusicTitle = {
	private [ "_str", "_XD_display", "_control", "_control1", "_endtime", "_r", "_g", "_b", "_a","_dlg"];
	_dlg = createDialog "S_RscIntroTitles";
	_XD_display = findDisplay 77044;
	// Check if music has title defined
	_str = localize format["STR_%1", _this select 0];
	if (isNull _XD_display) exitWith {
		hint localize format[ "+++ SYG_showMusicTitle: _XD_display(77044) isNull, music title ""%1"" (%2) can't be shown, exit.", _str, _this select 0 ];
		if (dialog) then { closeDialog 0 };
	};
	if ( _str != "") then { // title defined and found
		_control1 = _XD_display displayCtrl 66667;
		_control1 ctrlSetText _str;
		_control1 ctrlShow true;
		hint localize format[ "+++ SYG_showMusicTitle: music text control (%1) created, music title ""%2""", _control1, _this select 0 ];
	} else  { // to title found
		_control1 = displayNull;
		hint localize format[ "--- SYG_showMusicTitle: music text not found, skip control for music ""%1"" creation", _this select 0 ];
	};

	if (d_still_in_intro) then { // then show logo of the mission (Author, modified by etc)
//		sleep 1;
		_control = _XD_display displayCtrl 66666;
		_control ctrlShow true;

		_endtime = time + 30; // how long to show music title (if exists)
		_r = 0.2; _a = 0.008;
		_g = 0.2; _b = 0.2; // new
//		hint localize format["+++ x_intro: %1, time %2", [_r,_g,_b,_b], time];
		//+++++++++++++++++++++++++++ PRINT BLUE TEXT ++++++++++++++++++++++++
		while { (_endtime > time) && d_still_in_intro } do {
			_control ctrlSetTextColor [_r,_g,_b,_b];
			if ( _b > 1 ) exitWith {};
			_b = _b + _a;
			sleep .01;
		};
		if ( (_endtime > time) && d_still_in_intro ) then { sleep 1};
//		hint localize format["+++ x_intro: %1, time %2", [_r,_g,_b,_b], time];
		//+++++++++++++++++++++++++++ PRINT GREEN TEXT ++++++++++++++++++++++++
		while { (_endtime > time) && d_still_in_intro } do {
			_control ctrlSetTextColor [_r,_g,_b,1];
			if ( _g > 1 ) exitWith {};
			_g = _g + _a;
			_b = (_b - _a) max 0.2;
			sleep .01;
		};
		if ( (_endtime > time) && d_still_in_intro ) then { sleep 1};
//		hint localize format["+++ x_intro: %1, time %2", [_r,_g,_b,1], time];
		//+++++++++++++++++++++++++++ PRINT RED TEXT ++++++++++++++++++++++++
		while { (_endtime > time) && d_still_in_intro } do {
			_control ctrlSetTextColor [_r,_g,_b,1];
			if ( _r > 1 ) exitWith {};
			_r = _r + _a;
			_g = (_g - _a) max 0.2;
			sleep .01;
		};
		if ( (_endtime > time) && d_still_in_intro ) then { sleep 1};
//		hint localize format["+++ x_intro: %1, time %2", [_r,_g,_b,1], time];
		//+++++++++++++++++++++++++++ PRINT WHITE TEXT ++++++++++++++++++++++++
		while { (_endtime > time) && d_still_in_intro } do {
			_control ctrlSetTextColor [_r,_g,_b,1];
			if ( _g > 1 ) exitWith {};
			_b = _b + _a;
			_g = _g + _a;
			sleep .01;
		};
//		hint localize format["+++ x_intro: %1, time %2", [_r,_g,_b,1], time];
		while { (_endtime > time) && d_still_in_intro } do { sleep 0.5 };
//		hint localize format["+++ x_intro: %1, time %2", [_r,_g,_b,1], time];
		_control ctrlShow false;
	} else {
		if (!isNull _control1) then {
			if (count _this > 1) then {	sleep (_this select 1)} else {sleep 30 };
		};
	};

	if (!isNull _control1) then { _control1 ctrlShow false };
	if (dialog) then { closeDialog 0; hint localize "+++ SYG_showMusicTitle: dialog at end of method removed" }
		else {hint localize "+++ SYG_showMusicTitle: no dialog at end of method"};
};
#else

// there are two variants of sound parameter:
//  [_music_name<, _wait_title_is_showed_in_secs>] spawn SYG_showMusicTitle; // Sound from CfgSounds
//  [[_music_name,...]<, _wait_title_is_showed_in_secs>] spawn SYG_showMusicTitle; // Sound from CfgMusic
// The sound/music itself is player in outside code
SYG_showMusicTitle = {
	hint localize format["+++ SYG_showMusicTitle: _this = %1", _this];
	private [ "_str", "_sound", "_control", "_endtime", "_r", "_g", "_b", "_a", "_start"];
	// load both comtrols
	_start = time;
	cutRsc ["S_RscIntroTitles","PLAIN"];
	sleep 0.1;
	_control = INTRO_HUD displayCtrl 66667; // find music title
	// Check if music has title defined
	_sound = _this select 0;
	if (typeName _sound == "ARRAY") then {
		_sound = _sound select 0;  // ["sound_name",{...}] // Arma music format, not sound
	}; // else e.g. "STR_condor"

	_str = localize format[ "STR_%1", _sound ]; // e.g. "STR_ATrack24" from Arma CfgMusic section
	if ( _str != "") then { // title defined and found
		_control ctrlSetText _str;
		hint localize format[ "+++ SYG_showMusicTitle: music text control (%1/%2) created for ""%3"", _this = %4", INTRO_HUD, _control, _sound, _this ];
	} else {
		hint localize format[ "--- SYG_showMusicTitle: music title not found, _this = %1", _this ];
	};

	_control = INTRO_HUD displayCtrl 66666;
	hint localize format["+++ SYG_showMusicTitle: d_still_in_intro = %1", d_still_in_intro];
	if (d_still_in_intro) then { // Show logo of the mission (Author, modified by etc)
		_control ctrlSetText (localize "STR_TITLE"); // Set intro text on the bottom left side of the screen
		_endtime = time + 30; // How long to show mission title (if exists)
		hint localize format["+++ SYG_showMusicTitle: start to print intro text control (%1) during %2 secs", _control, _endtime - time];
		_r = 0.2; _a = 0.008; _g = 0.2; _b = 0.2; // new
//		hint localize format["+++ x_intro: %1, time %2", [_r,_g,_b,_b], time];
		//+++++++++++++++++++++++++++ PRINT TEXT FADING TO THE BLUE ++++++++++++++++++++++++
		while { (_endtime > time) && d_still_in_intro } do {
			_control ctrlSetTextColor [_r,_g,_b,_b];
			if ( _b > 1 ) exitWith {};
			_b = _b + _a;
			sleep .01;
		};
		if ( (_endtime > time) && d_still_in_intro ) then { sleep 1};
//		hint localize format["+++ x_intro: %1, time %2", [_r,_g,_b,_b], time];
		//+++++++++++++++++++++++++++ PRINT TEXT FADING TO THE  GREEN ++++++++++++++++++++++++
		while { (_endtime > time) && d_still_in_intro } do {
			_control ctrlSetTextColor [_r,_g,_b,1];
			if ( _g > 1 ) exitWith {};
			_g = _g + _a;
			_b = (_b - _a) max 0.2;
			sleep .01;
		};
		if ( (_endtime > time) && d_still_in_intro ) then { sleep 1};
//		hint localize format["+++ x_intro: %1, time %2", [_r,_g,_b,1], time];
		//+++++++++++++++++++++++++++ PRINT TEXT FADING TO THE RED ++++++++++++++++++++++++
		while { (_endtime > time) && d_still_in_intro } do {
			_control ctrlSetTextColor [_r,_g,_b,1];
			if ( _r > 1 ) exitWith {};
			_r = _r + _a;
			_g = (_g - _a) max 0.2;
			sleep .01;
		};
		if ( (_endtime > time) && d_still_in_intro ) then { sleep 1};
//		hint localize format["+++ x_intro: %1, time %2", [_r,_g,_b,1], time];
		//+++++++++ PRINT TEXT FADING TO THE WHITE +++++++++++
		while { (_endtime > time) && d_still_in_intro } do {
			_control ctrlSetTextColor [_r,_g,_b,1];
			if ( _g > 1 ) exitWith {};
			_b = _b + _a;
			_g = _g + _a;
			sleep .01;
		};
//		hint localize format["+++ x_intro: %1, time %2", [_r,_g,_b,1], time];
		while { (_endtime > time) && d_still_in_intro } do { sleep 0.5 };
//		hint localize format["+++ x_intro: %1, time %2", [_r,_g,_b,1], time];
	} else {
		if ( _str != "") then {
			hint localize "+++ SYG_showMusicTitle: no intro text shown, only music title is displayed";
			if (count _this > 1) then {	sleep (_this select 1)} else {sleep 30 };
		};
	};
//	cutText["", "PLAIN"];      // remove intro/music cut controls
	cutRsc["Default","PLAIN"]; // remove intro/music cut controls
	hint localize format["+++ SYG_showMusicTitle: finished, duration = %1 secs, d_still_in_intro= %2", time - _start, d_still_in_intro];
};
#endif

[_music, 30] spawn SYG_showMusicTitle;

//
// +++++++++++++ SHOW MAIL, TITLE and test messages ++++++++++++
//
[_holiday,_start] spawn {
	private ["_txt","_str","_holiday"];
   	_holiday = _this select 0;
//	hint localize format["+++ spawn _holiday = %1", _holiday];
	//sleep 2;
	{
		_txt = switch _x do {
			case 1: { localize "STR_INTRO_1" }; // Alternative reality
			case 2: { localize "STR_INTRO_2" }; // North Atlantic
			case 3: { format[localize "STR_INTRO_3", date call SYG_humanDateStr, (date call SYG_weekDay) call SYG_weekDayLocalName, call SYG_nowHourMinToStr, ceil(call SYG_missionDayToNum)] }; // landing time / week day 
			case 4: { format[localize "STR_INTRO_4", text ((_this select 1) call SYG_nearestSettlement)] }; // settlement
			case 5: {  // message and sound for current day period (morning,day,evening,night), if available
                [] spawn {
                    private ["_str"];
                    sleep (60 + (random 20));
                    _str = [] call SYG_getMsgForCurrentDayTime;
                    titleText[_str, "PLAIN DOWN"];
                    _str = ([] call SYG_getCurrentDayTimeRandomSound);
                    if (_str != "") then {
                    	playSound _str;
                    };
                };
                ""
			};
			case 6: { // print info per holiday if available. Params example: [22,  4, ["lenin","lenin_1"],"STR_HOLIDAY_22_APR",0]
//            	hint localize format["+++ case 6 _holiday = %1", _holiday];
            	if (count _holiday == 2) then { // one of socialist country holiday
                    format[ localize "STR_INTRO_05",localize (_holiday select 0),"" ]; // message output
                } else { // some soviet holiday
                    if (count _holiday == 3) then {
                        _str = if ( _holiday select 0 ) then { "STR_INTRO_5_1" } else { "STR_INTRO_5_0" };
                        format[localize "STR_INTRO_5",localize (_holiday select 2),localize _str]; // message for the selebration
                    } else {""};
                };
			};
		};
		if (_txt != "") then {
            titleText[ _txt, "PLAIN DOWN" ];
            sleep 4.5;
		};
	} forEach [ 4, 1, 2, 3, 6, 5 ];
};

//
// ++++++++++++++++++++++++++ MAIN SHOW WAY +++++++++++++++++++++++++++++++++++++
//
_cnt = count _camstart;
//	hint localize format["%1 x_intro.sqf: start commits for %2", call SYG_daytimeToStr, _camstart];

//++++++++++++ daemon to print something before and at jump
if ( _doJump ) then {
	[_camera, _rank, _owned_para] spawn {
		private [ "_time", "_camera", "_rank", "_owned_para", "_para", "_str" ];
		// BLACK OUT in 0.7 sec when close to the base <= 100 m.
		// Wait until in plane
		// BLACK IN in 0.7 sec
		// 		cutText["","WHITE OUT",FADE_OUT_DURATION];  // blind him fast
		_time = time;
		_camera = _this select 0;
		_rank = _this select 1;
		_owned_para = _this select 2;
		_para = player call SYG_getParachute;
		while { ((_camera distance FLAG_BASE) > 200) && (alive player) } do {sleep 0.1};
		if (!alive player) exitWith {
			hint localize format["+++ x_intro.sqf: player dead in %1 secs (%2)", time - _time, _para];
		};
		hint localize format["+++ x_intro.sqf: player alive after %1 secs (%2)", time - _time, _para];
		_str = "";
		if ( (_rank < 1) || (_owned_para == "") ) then {
			_str = format[localize "STR_INTRO_PARAJUMP_1", if ((d_player_stuff select 1) >= 0) then {localize "STR_INTRO_PARAJUMP_1_1"} else {""}]; // "I'll have to jump%1. What else can I do?"
		} else {
			// _rank > 0 so user have had some parachute weared on him
			_str = format[localize "STR_INTRO_PARAJUMP_11",_owned_para]; // "You found a parachute (%1) on your back and decided to use it to please the smugglers."
		};
		cutText[ _str, "PLAIN", 10 ];  // "I'll have to jump%1. What else can I do?". black out for 20 seconds or less

		_time = time;

		// wait while player in any vehicle (plane or parachute)

		while { ((vehicle player) != player) && (alive player) } do {sleep 0.5};
		if (!alive player) exitWith {
			hint localize format["+++ x_intro.sqf: player dead on jump in %1 secs (%2)", time - _time, _para];
		};
		sleep 3;
		if (alive player ) then {
			//	cutText[localize "STR_INTRO_PARAJUMP_2","BLACK IN",0.7];  // "Let's go-o-o-o...". black in again
			cutText[localize "STR_INTRO_PARAJUMP_2","PLAIN",5];  // "Let's go-o-o-o...". black in again
			hint localize format["+++ x_intro.sqf: alive on jump after %1 secs (%2)", time - _time, _para];
		} else {
			cutText[localize "STR_INTRO_PARAJUMP_3","PLAIN",5];  // "Fuck-k-k.k..."
			hint localize format["+++ x_intro.sqf: player dead on jump in %1 secs (%2)", time - _time, _para];
		};
	};
} else {
	if ( _rank  > 0)  exitWith {
		cutText[ format[localize "STR_INTRO_NOJUMP_BYRANK", _rname],"PLAIN",5];  // "The smugglers delivered you to the base out of respect for your rank (%1)."
	};
	// TODO: for the future messages
};

for "_i" from 1 to (_cnt-1) do {
    _pos = _camstart select _i; // next point to look and go to it
    if ( (_pos select 2)  < 0 ) then {
        _tgt = + _pos;
        _tgt set [2, 0]; // point on the ground
        _pos set [2, abs(_pos select 2)]; // point above the ground
//        hint localize format["+++ _xintro.sqf: spec point[%1] tgt %2, pnt %3", _i, _tgt, _pos];
    } else {
        // for not last point shift X and Y coordinates slightly, for more native behaviour
        if ( _i < (_cnt-1)) then {
            _pos set [0, (_pos select 0) - RANDOM_POS_OFFSET +  (2 * (random RANDOM_POS_OFFSET))]; // shift along X
            _pos set [1, (_pos select 1) - RANDOM_POS_OFFSET +  (2 * (random RANDOM_POS_OFFSET))]; // shift along Y
        };
        _tgt = [ _start, _pos, 30000.0 ] call SYG_elongate2Z;
    };

    _camera camPrepareTarget _tgt; // let look to over there
//		_camera camCommitPrepared 0.5; // time to rotate to target
//		waitUntil {camCommitted _camera}; // wait until pointing to the target

//		hint localize format["_x_init.sqf: %2, vectorDir at %1", vectorDir _camera, time];

    _camera camPreparePos _pos;	// let go to over there
    _camera camCommitPrepared (_arr select (_i - 1)); // set time to go
    waitUntil { camCommitted _camera }; // wait until come
//    hint localize format["+++ x_intro.sqf: step %1, duration %2, to pos %3", _i, _arr select (_i - 1), _pos	]; //if ( _i == 2 ) then {sleep 5;};
    _start = _pos;
};
//	hint localize format["%1 x_intro.sqf: last camera commit completed",call SYG_daytimeToStr];

if ( typeName _camstart != "ARRAY" ) then {
	waitUntil {camCommitted _camera};
};

#ifdef __CONNECT_ON_PARA__

if (_doJump) then {
    // Move player to the point of a rect between Somato and base on the parachute
    // first find/put parachute in his inventory
    hint localize format["+++ x_intro.sqf: call to jump.sqf, player para = ""%1""", player call SYG_getParachute];
    // now check if player parachute already changed due to rearm procedure in x_setupserver1.sqf
    if (_owned_para != "") then {
        if (_owned_para != _para) then {
            hint localize format["+++ x_intro.sqf: the assigned type %1 is replaced by the existing type %2", _para, _owned_para];
            _para = _owned_para;
            //++++++++++++++++++++++++++++++
            //      reset spawn point
            //+++++++++++++++++++++++++++++
            _spawn_point = _owned_para call _makeSpawnPoint;
        }; // replace jump type with para type/
    };

    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //                               JUMP
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    #ifdef __ARRIVED_ON_ANTIGUA__
    if ( base_visit_mission < 1 ) then { // Jump over Antigua
    	[ _spawn_point, _para, "DC3", false, "ADD_PARA"] execVM "AAHALO\jump.sqf"; // no circle to hit on Antigua
    } else { // Jump near base
    #endif
	    [ _spawn_point, _para, "DC3", false, true] execVM "AAHALO\jump.sqf"; // last true means "check circle hit"
    #ifdef __ARRIVED_ON_ANTIGUA__
    };
    #endif

    // Inform player about new order
    ["msg_to_user", "", [[ format[localize "STR_INTRO_PARAJUMP", (round ((_spawn_point distance FLAG_BASE)/50)) * 50 ] ]], 0, 5, false ] spawn SYG_msgToUserParser; // "Get to the base any way you want!"
    // #579: add destination point on yellow circle of the base barracs tent
    // Start routine to set the destinatioin point and check it until player is on base
    [] spawn SYG_showDestWPIfNotOnBase;

    // move camera to the DC3 cargo player
    waitUntil { (FLAG_BASE distance player) > 100 };

    _tgt = [_camera, player, 30000.0] call SYG_elongate2Z;
    sleep 0.2;
    if (vehicle player != player) then {
        _camera camSetTarget (vehicle player)
    } else { _camera camSetTarget player};

    _camera camSetRelPos [0,1.5, 0.5];
    // let look to over there
    _camera camCommit 1; // set time to go
    waitUntil { camCommitted _camera }; // wait until come

	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    if ( alive player) then { _start_time execVM "scripts\intro\SYG_checkPlayerAtBase.sqf" }; // run service to check alive player to be on base not in vehicle
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	if (!alive player) exitWith {}; // Exit ALL follow animations and messages

    // print informative messages while in air
    _para spawn {
        private ["_para","_msg_arr","_i","_last","_time","_town_name","_glide","_msg_delay","_msg_delay","_sleep"];
        _para = _this;
        _town_name = call SYG_getTargetTownName;
        _saboteurs = !isNil "d_on_base_groups";
        if (base_visit_mission < 1) then { // Then you are at Antigua
			_town_msg = switch ( _town_name ) do {
				case "Corazol": {"STR_INTRO_INFO1_2"}; // "Corazol is occupied by the enemy, go around it by water, look for boats at Mercallilo."
				case "Masbete":  {"STR_INTRO_INFO1_1"}; // "The city right in the way, Masbete, is occupied by the enemy, beware of clashing with him!"
				// "Nearby towns are free, beware of patrols[ and saboteurs]"
				default         { if (_saboteurs &&  (count d_on_base_groups > 0)) then { "STR_INTRO_INFO_0_1" } else { "STR_INTRO_INFO_0" } };
			};
			// "Rip the cord near the ground and glide toward the tent..
			// "'W' - acceleration and descent, 'S' - ...
			// "When landing, watch your rate of descent...
			// "Smugglers, in violation of agreements with the GRU, have dropped above Antigua...
			// "The order is to arrive at the base and...
			// "Will I be back from this misterios island?"
			_msg_arr = [_town_msg, "STR_INTRO_MSG1_0","STR_INTRO_MSG_1","STR_INTRO_MSG_2","STR_INTRO_MSG1_3","STR_INTRO_MSG_4","STR_INTRO_MSG_6"];
        } else { // Then you are above the ridge near to the base
			_town_msg = switch ( _town_name ) do {
				case "Paraiso": {"STR_INTRO_INFO_2"}; // "Paraiso is occupied by the enemy, manoeuvre by parachute to avoid meeting them."
				case "Somato":  {"STR_INTRO_INFO_1"}; // "The nearby Somato is occupied by the enemy, beware of encounters with him!"
				// "Nearby towns are free, beware of patrols[ and saboteurs]"
				default         { if (_saboteurs &&  (count d_on_base_groups > 0)) then { "STR_INTRO_INFO_0_1" } else { "STR_INTRO_INFO_0" } };
			};
			// "Rip the cord right off and glide towards the base, flying around enemy concentrations"
			// "'W' - acceleration and descent, 'S' - ...
			// "At top speed (pressed 'W') you will fly 1.5 times farther in distance and 1.5 times less in time."
			// "Try to land on the yellow circle (under the flares), points: +10"
			// "When landing, watch your rate of descent...
			// "By arrangement with the GRU, a smuggling plane took you to the vicinity of the GRU base."
			// "The order is to arrive at the base and...
			// "Follow the course for the purple flares (almost white in the daytime)"
			// "Will I be back from this misterios island?"
			_msg_arr = [_town_msg, "STR_INTRO_MSG_0","STR_INTRO_MSG_1","STR_INTRO_MSG_1_1","STR_INTRO_MSG_1_2","STR_INTRO_MSG_2","STR_INTRO_MSG_3","STR_INTRO_MSG_4","STR_INTRO_MSG_5","STR_INTRO_MSG_6"];
        };
    #ifdef __ARRIVED_ON_ANTIGUA__
    #else
	#endif
    //	hint localize format[ "+++ x_intro.sqf: print array %1", _msg_arr];
        _last = (count _msg_arr) - 1;
    #ifdef __ACE__
        _glide = _para == "ACE_ParachutePack";
    #else
        _glide = false;
    #endif
        _cnt = if ( _glide ) then { count _msg_arr } else { (count _msg_arr) - 3 }; // number of strings to show
        _msg_delay = (100 / ( _cnt -1 )) min 10; // average delay between strings (max 10)  with whole time 100 seconds
        _sleep = _msg_delay / 3.05; // status check delay (to exit etc)
        _time = time + _msg_delay;
        hint localize format[ "+++ x_intro.sqf: print thread, target town detected ""%1"", print cnt %2, msg delay %3, sleep each %4, glide %5",
            _town_name,
            _cnt,
            _msg_delay,
            _sleep,
            _glide];

        _i = 0;
        scopeName "main";
        for "_i" from 0 to _last do {
        	if ( !alive player) exitWith {};
            if ( (!(_i in [1,2,3,4,5])) || _glide ) then {
                cutText [localize (_msg_arr select _i),"PLAIN"];
                _time = time + _msg_delay;
            };
            while { time < _time} do {  // wait to print
                if ( base_visit_session != 0 ) then { breakTo "main" }; // Exit on status -1 (dead) or 1 (reached the base)
                sleep _sleep;
            };
        };

        hint localize format[ "+++ x_intro.sqf: print thread returned after step #%1", _i ];
    };

    // remove round parachute after landing
    _para spawn {
        private ["_para"];
        _para = _this;
    #ifdef __ACE __
        if (_para == "ACE_ParachutePack") exitWith {}; // only round pack need auto cut
    #endif
        // detect for parachute to be on player or player is on the ground and remove it from magazines
        waitUntil { sleep 0.132; (!alive player) || (vehicle player != player) || ( ( ( getPos player ) select 2 ) < 5 ) };
        if (!alive player) exitWith{};
        // TODO: type some messages for the player orientation
        if ( (vehicle player) != player ) then { // parachute still on!
            waitUntil { sleep 0.132; (!alive player) || (vehicle player == player)  || ( ( ( getPos player ) select 2 ) < 5 ) };
        //    if ( (player call XGetRankIndexFromScore) > 2 ) then {
            sleep 5.0; // Ensure  player to be on the ground
            // Let's stop the parachute jumping on the ground
            if ( (vehicle player) != player ) then {
                player action ["Eject", vehicle player];
                hint localize "+++ x_intro.sqf: player ejected from parachute";
                playSound "steal";
                if (alive player) then {
                    (localize "STR_SYS_609_5") call XfHQChat; // "Thanks to your life experience (and rank!), you  got rid of your parachute."
                };
            };
        };
    };
    sleep 2;
};
#endif

player cameraEffect ["terminate","back"];
camDestroy _camera;

#ifdef __ACE__
if (_doJump) then {
	SYG_initialEquipmentStr = player call SYG_getPlayerEquipAsStr; // store original equipment in string
	// replace weapon with drop pack to restore it after base visit
	hint localize "+++ x_intro: replace server equipment with para-jump set";
	// [["ACE_RPG7","ACE_RPK47","Binocular","ACE_ParachuteRoundPack"],["ACE_Bandage(3)","ACE_Morphine(5)","ACE_75Rnd_762x39_BT_AK(5)","ACE_RPG7_PG7VL"],"",[]]
	// replace with initial one

	// remove rucksack as not needed
	player setVariable [  "ACE_weapononback", nil ];
	player setVariable [ "ACE_Ruckmagazines", nil ];

	[ player,
		[
			["ACE_AK74",_para], // weapons, "ACE_SmokeGrenade_Green" added on task #611.6
			[["ACE_45Rnd_545x39_BT_AK",3],["ACE_SmokeGrenade_Green",3],["ACE_Bandage",3],["ACE_Morphine",5]], // magazines
			"", // No rucksack
			[] // No rucsack items
		]
	] call SYG_rearmUnit;

	if (call SYG_isDarkness) then {
		player call SYG_addNVGoggles; // add NVG as knight is on
	};
	player call SYG_addBinocular; // add binocular
};

#endif

if (dialog) then { closeDialog 0 };
if (!_doJump) then {
	[ "say_sound", FLAG_BASE, "gong_5" ] call XSendNetStartScriptClientAll; // play gong very low sound on the place for all players online
};

enableRadio true;

if ( !(isNull _lobj) ) then { deleteVehicle _lobj};
d_still_in_intro = false;
sleep 3;
deleteVehicle _PS1;

#ifdef __CONNECT_ON_PARA__

if (_doJump) then {
    // wait any of : death, landing, parachute opening
    waitUntil { sleep 0.132; (!alive player) || (vehicle player != player) || ( ( ( getPos player ) select 2 ) < 5 ) };
    if ( (vehicle player) != player ) then { // parachute is on!

		hint localize format["+++ x_intro.sqf: at jump end will remove parachute ""%1"", has ""%2""", _para, player call SYG_getParachute];
		if ( _para != "") then {
			waitUntil {alive player};
			player removeWeapon _para;
		}; // The parachute is used, remove it from inventory

        // The parachute still is opened, wait player to be on the ground, out of parachute or dead
        waitUntil { sleep 0.132; (!alive player) || (vehicle player == player)  || ( ( ( getPos player ) select 2 ) < 5 ) };
        #ifdef __ACE __
        if (_para == "ACE_ParachutePack") exitWith {}; // this parachute not need to be removed by the script
        #endif
        sleep 5.0; // Ensure  player to be on the ground
        // Let's stop the parachute jumping on the ground
        if ( (vehicle player) != player ) then {
            player action ["Eject", vehicle player];
            hint localize "+++ x_intro.sqf: player ejected from parachute";
            playSound "steal";
            (localize "STR_SYS_609_5") call XfHQChat; // "Thanks to your life experience (and rank!), you  got rid of your parachute."
        };
    //    }
    };
    if (alive player) then {
        if (base_visit_session <= 0) then {
            ["msg_to_user", "", [["STR_INTRO_PARAJUMP_6", (round ((player distance FLAG_BASE)/50)) * 50]], 0, 0, false ] spawn SYG_msgToUserParser; // "I'm gonna go to the blue flares... distance %1 m"
        };
    };

};
#endif

if (true) exitWith {};