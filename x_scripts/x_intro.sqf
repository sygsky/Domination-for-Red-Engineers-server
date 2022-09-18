// x_intro.sqf, by Xeno
private ["_s","_str","_dlg","_XD_display","_control","_line","_camstart","_intro_path_arr",
         "_plpos","_i","_XfRandomFloorArray","_XfRandomArrayVal","_cnt","_lobj", "_lobjpos",
		 "_year","_mon","_day","_newyear","_holiday","_camera","_start","_pos","_tgt","_sound","_date","_music",
		 "_spawn_point"];
if (!X_Client) exitWith {hint localize "--- x_intro run not on client!!!";};
//hint localize "+++ x_intro started!!!";
d_still_in_intro = true;

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
_holiday = SYG_client_start call SYG_getCountryDay; // country foundation day, if success, return array of 2 items: ["title","music"]
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
};

_music_cnt = 0;
if (_sound == "") then { // select random music for an ordinal day
    if ( ( (_mon == 12) && (_day > 20) ) || ( (_mon == 1) && (_day < 11) ) ) then {
    	_music = ((SYG_holidayTable select 0) select 2) call _XfRandomArrayVal;
    	_sound = _music;
        playSound _music; //music for New Year period from 21 December to 10 January
        _newyear = true;
    } else {
        // music normally played on intro
        if ( _mon == 11 && (_day >= 4 && _day <= 10) ) then {
            // 7th November is a Day of Great October Socialist Revolution
            _sound = (call compile format["[%1]", localize "STR_INTRO_MUSIC_VOSR"]) call _XfRandomArrayVal;
            _music = _sound;
            playSound  _sound;
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
					if ( _pos >= 0 ) exitWith { { [ _personalSounds ,_sounds select _pos ] call SYG_addArrayInPlace } forEach [1,2,3] };
				} forEach _players;
            };
            if ( format["%1",player] in d_can_use_artillery ) then {
                // add special music for GRU soldiers
                { [ _personalSounds, ["from_russia_with_love",/*"bond1",*/"bond"] ] call SYG_addArrayInPlace } forEach [1,2,3];
            }; // as you are some kind of spy

            // add some rarely heard music now if no personal music set

#ifdef __TIME_OF_DAY_MISIC__
            // music to play day and night
            _night_music = [
                "bond",/*"bond1",*/"from_russia_with_love","adjutant","total_recall_mountain"/*,"adagio"*/,"morze","morze_3",
                "treasure_island_intro","fear2","soviet_officers"/*,"cosmos"*/,"manchester_et_liverpool","tovarich_moy",
                "hound_baskervill","condor","way_to_dock","melody_by_voice","sovest1","sovest2",/*"del_vampiro1",
                "del_vampiro2",*/"zaratustra","bolivar",/*"jrtheme","vague",*/"enchanted_boy","bloody",
                "peregrinus"
            ];

            // music to play only in day time
            _daytime_music = [
                "grant","burnash","lastdime","lastdime2","lastdime3","mission_impossible","strelok","capricorn1title",
                "Letyat_perelyotnye_pticy_2nd","ruffian","morze","morze_3"/*,"chapaev"*/,"rider","Vremia_vpered_Sviridov",
                "Letyat_perelyotnye_pticy_end","toccata","travel_with_friends","on_thin_ice","wild_geese","wild_geese",
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
                "ruffian","morze","morze_3","treasure_island_intro","fear2"/*,"chapaev"*/,"soviet_officers"/*,"cosmos"*/,"manchester_et_liverpool",
                "tovarich_moy","rider","hound_baskervill","condor","way_to_dock","Vremia_vpered_Sviridov",
                "Letyat_perelyotnye_pticy_end","melody_by_voice","sovest1","sovest2","toccata",
                /*"del_vampiro1","del_vampiro2",*/"zaratustra","bolivar",/*"jrtheme","vague",*/"travel_with_friends","on_thin_ice","peregrinus",
                "wild_geese","wild_geese","dangerous_chase"
            ]
                + _personalSounds ) call _XfRandomArrayVal;
#endif

#ifdef __SOVIET_MUSIC_ONLY__
			_music = ["strelok","Letyat_perelyotnye_pticy_2nd"/*,"chapaev"*/,"soviet_officers","tovarich_moy","Vremia_vpered_Sviridov",
				"Letyat_perelyotnye_pticy_end","bolivar","travel_with_friends","on_thin_ice","peregrinus"] call _XfRandomArrayVal;
#endif

			_sound = _music;
            playSound _music; //playSound "ATrack25"; // oldest value by Xeno
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

#ifdef __CONNECT_ON_PARA__

//++++++++++++++++++++++++++++++++++++++++++++++++++++
//      define parachute type (round of square)
//++++++++++++++++++++++++++++++++++++++++++++++++++++
waitUntil { !( (isNil "SYG_getParachute") || (isNil "XfRandomArrayVal") || (isNil "XfGetRanPointSquareOld" ) ) };
_para = player call SYG_getParachute;
hint localize format["+++ x_intro.sqf: BEFORE player (alive %1) has parachute ""%2""", alive player,  _para];
if ( (_para == "") || (isNil "_para")) then {
	#ifdef __ACE__
	_para = ["ACE_ParachutePack","ACE_ParachuteRoundPack"] call XfRandomArrayVal;
	#endif
	#ifndef __ACE__
	_para = switch (d_own_side) do {
		case "RACS": {"ParachuteG"};
		case "WEST": {"ParachuteWest"};
		case "EAST": {"ParachuteEast"};
	};
	#endif
	player addWeapon _para;
};
hint localize format["+++ x_intro.sqf: AFTER  player (alive %1) has parachute ""%2""", alive player,  _para];

//++++++++++++++++++++++++++++++
//      find spawn point
//+++++++++++++++++++++++++++++
_spawn_rect = drop_zone_arr select 0;
	#ifdef __ACE__
if (_para == "ACE_ParachutePack") then {  // find point in the rectangle above Sierra Madre
	_spawn_rect = [ [11306,8386,0], 600,150, -45 ];
	hint localize "+++ x_intro.sqf: jump point is set above mountines";
} else {
		hint localize "+++ x_intro.sqf: jump point is set above plain";
};
	#endif
_spawn_point  = _spawn_rect call XfGetRanPointSquareOld;
_spawn_point set [2, 150]; // spawn at parachute pos

#else
_spawn_point  = getPos player;
#endif
//hint localize format["+++ x_intro.sqf: _spawn_point = %1", _spawn_point];
#ifdef __DEFAULT__
    // 7703.5,7483.2, 0
	// array of camera turn points. Last point is for illusion object creation point.If it is NUMBER in range {0..last_turn_point_index-1>} designated index turn point is used for illusion
  _camstart = 
  [
    [[1947,19059,1],[2260,18839,10],[4979,15480,40],[8982.5,10777,150],1], // Island Parvulo (1)
    [[18361,18490,1],[14260,15170,30],[11141,13340,50],[18127,18337,0]], // Isle Antigua (2)
    [[19684.6,14128.7,25],[17681.2,13076.8,40],[15397.76,11924.51,50],[11420,8570,20],[10869,9172,40],[19356,14018,0]], // Pita (3)
    [[1224,1391,1],[1580,1711,20],[8971,8170,70],1], // Rahmadi (4)
    [[18534,2730,1],[18259,2978,10],[11420,8570,20],[10628,9328,40],1], // vulcano Asharan (5)
	[[12113,5833,1],[11820,6059,6],[11717.1,6068.6,9],[11642,6336,9],[11480,6658,10],[11147,7138,11],[10992,7749,21],[11014,7990,31],[11121,8155,51],[11420,8570,46],[10869,9172,41],[12025,6082,0]], // Dolores (6)
	[[6111,17518,1],[7355,17182,60],[12221,15217,50],[12000,14618,50],[10719,14222,70],[8982.5,10777,150],[12270,15217,0]], // Cabo Valiente (7)
	[[19682,12457,1],[19454,11893,20],[17985,9733,20],[16713,8909,20],[15541,8262,20],[13968,7852,20],[13222,8655,30],[12746,9138,10],[12490,10850,30],[9369,11208,10],[8981,10777,40], 7]// 1.5 км to south of Pita near the shore in open sea (8)
  ] call _SYG_selectIntroPath;
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
  
#define DEFAULT_EXCESS_HEIGHT_ABOVE_POINT 20

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
// last-1 pointy is player pos, last is special one
_camstart set [count _camstart, _spawn_point]; // replace illusion position with end point (player pos)
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

//#ifdef __TT__
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

// [_music_name<, _wait_title_is_showed_in_secs>] spawn SYG_showMusicTitle;
SYG_showMusicTitle = {
	private [ "_str", "_XD_display", "_control", "_control1", "_endtime", "_r", "_g", "_b", "_a"/*,"_sec"*/];
	_XD_display = findDisplay 77043;
	// Check if music has title defined
	_str = localize format["STR_%1", _this select 0];
	if (isNull _XD_display) exitWith {
		hint localize format[ "+++ SYG_showMusicTitle: _XD_display(77043) isNull, music title for ""%1""(%2) can't be shown, exit.", _str, _this select 0 ];
	};
	if ( _str != "") then { // title defined and found
		_control1 = _XD_display displayCtrl 66667;
		_control1 ctrlSetText _str;
		_control1 ctrlShow true;
		hint localize format[ "+++ SYG_showMusicTitle: music text control (%1) for title ""%2""", ctrlText _control1, _str ];
	} else  { // to title found
		_control1 = displayNull;
		hint localize format[ "--- SYG_showMusicTitle: music text control for ""%1"" not found", _this select 0 ];
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
};

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
                    if (_str != "") then { playSound _str; };
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

//++++++++++++ daemon to FADE OUT while not in plane and FADE IN in if in parachute
_camera spawn {
	private ["_time","_para","_str"];
	// BLACK OUT in 0.7 sec when close to the base <= 100 m.
	// Wait until in plane
	// BLACK IN in 0.7 sec
	// 		cutText["","WHITE OUT",FADE_OUT_DURATION];  // blind him fast
	_time = time;
	_para = player call SYG_getParachute;
	while { ((_this distance FLAG_BASE) > 200) && (alive player) } do {sleep 0.1};
	if (!alive player) exitWith {
		hint localize format["+++ x_intro.sqf: player dead on FADE OUT in %1 secs", time - _time];
	};
	hint localize format["+++ x_intro.sqf: FADE OUT after %1 secs", time - _time];
	_str = format[localize "STR_INTRO_PARAJUMP_1", if ((score player) != 0) then {localize "STR_INTRO_PARAJUMP_1_1"} else {""}]; // "I'll have to jump%1. What else can I do?"
//	cutText[ _str, "BLACK OUT", 20 ];  // "I'll have to jump%1. What else can I do?". black out for 20 seconds or less
	cutText[ _str, "PLAIN", 10 ];  // "I'll have to jump%1. What else can I do?". black out for 20 seconds or less
	_time = time;
	// wait while player in any vehicle (plane or parachute)
	while { ((vehicle player) == player) && (alive player) } do {sleep 0.1};
	if (!alive player) exitWith {
		hint localize format["+++ x_intro.sqf: player dead on jump in %1 secs", time - _time];
	};
	sleep 3;
	if (alive player ) then {
		//	cutText[localize "STR_INTRO_PARAJUMP_2","BLACK IN",0.7];  // "Let's go-o-o-o...". black in again
		cutText[localize "STR_INTRO_PARAJUMP_2","PLAIN",5];  // "Let's go-o-o-o...". black in again
		hint localize format["+++ x_intro.sqf: alive on jump after %1 secs", time - _time];
	} else {
		cutText[localize "STR_INTRO_PARAJUMP_3","PLAIN",5];  // "Fuck-k-k.k..."
		hint localize format["+++ x_intro.sqf: player dead on jump in %1 secs", time - _time];
	};
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

// Move player to the point of rect between Somato and base on the parachute
// first find/put parachute in his inventory
hint localize format["+++ x_intro.sqf: call to jump.sqf, player has ""%1""", player call SYG_getParachute];
[ _spawn_point, _para, "DC3", false] execVM "AAHALO\jump.sqf";
// Inform player about new order
["msg_to_user", "", [[ format[localize "STR_INTRO_PARAJUMP", (round ((_spawn_point distance FLAG_BASE)/50)) * 50 ] ]], 0, 5, false ] spawn SYG_msgToUserParser; // "Get to the base any way you want!"

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

if ( alive player) then { [] execVM "scripts\SYG_checkPlayerAtBase.sqf" }; // run service to check alive player to be on base not in vehicle

// print informative messages while in air
_para spawn {
	private ["_msg_arr","_i","_last","_time","_town_name","_glide","_msg_delay","_msg_delay","_sleep"];
	_msg_arr = ["", "STR_INTRO_MSG_0","STR_INTRO_MSG_1","STR_INTRO_MSG_2","STR_INTRO_MSG_3","STR_INTRO_MSG_4","STR_INTRO_MSG_5","STR_INTRO_MSG_6"];
	_town_name = call SYG_getTargetTownName;
	hint localize format[ "+++ x_intro.sqf: print thread, target town detected ""%1""", _town_name ];
	_msg_arr set [0, switch (_town_name) do {
		case "Paraiso": {"STR_INTRO_INFO_2"};
		case "Somato":  {"STR_INTRO_INFO_1"};
		default         {"STR_INTRO_INFO_0"};
		}
	];
	_last = (count _msg_arr) - 1;
	_time = time + MSG_DELAY;
#ifdef __ACE__
	_glide = _para == "ACE_ParachutePack";
#else
	_glide = false;
#endif
	_cnt = if (_glide) then {count _msg_arr} else {(count _msg_arr) - 3}; // number of strings to show
	_msg_delay = 60 / ( _cnt -1 ); // delay between strings
	_sleep = _msg_delay / 3.05; // status check delay (to exit etc)

	scopeName "main";
	for "_i" from 0 to _last do {
		if ( (!(_i in [1,2,3])) || _glide ) then {
			cutText [localize (_msg_arr select _i),"PLAIN"];
			_time = time + _msg_delay;
		};
		while { time < _time} do {  // wait to print
			if ( base_visit_status != 0 ) then { breakTo "main" }; // Exit on status -1 (dead) or 1 (reached the base)
			sleep _sleep;
		};
	};

	hint localize format[ "+++ x_intro.sqf: print thread returned after step #%1", _i ];
};

// remove round parachute after landing
_para spawn {
	private ["_para"];
	_para = _this;
	// detect for parachute to be on player or player is on the ground and remove it from magazines
	waitUntil { sleep 0.132; (!alive player) || (vehicle player != player) || ( ( ( getPos player ) select 2 ) < 5 ) };
	if (!alive player) exitWith{};
	// TODO: type some messages for the player orientation
	if ( (vehicle player) != player ) then { // parachute still on!
		waitUntil { sleep 0.132; (!alive player) || (vehicle player == player)  || ( ( ( getPos player ) select 2 ) < 5 ) };
	//    if ( (player call XGetRankIndexFromScore) > 2 ) then {
		#ifdef __ACE __
		if (_para != "ACE_ParachuteRoundPack") exitWith {}; // only round pack need auto cut
		#endif
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
#endif

player cameraEffect ["terminate","back"];
camDestroy _camera;
closeDialog 0;
[ "say_sound", FLAG_BASE, "gong_5" ] call XSendNetStartScriptClientAll; // play gong very low sound on the place for all players online

enableRadio true;

if ( !(isNull _lobj) ) then { deleteVehicle _lobj};
d_still_in_intro = false;
sleep 3;
deleteVehicle _PS1;

#ifdef __CONNECT_ON_PARA__
// wait any of : death, landing, parachute opening
waitUntil { sleep 0.132; (!alive player) || (vehicle player != player) || ( ( ( getPos player ) select 2 ) < 5 ) };
if ( (vehicle player) != player ) then { // parachute is on!
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
	if (base_visit_status <= 0) then {
		["msg_to_user", "", [["STR_INTRO_PARAJUMP_6", (round ((player distance FLAG_BASE)/50)) * 50]], 0, 5, false ] call SYG_msgToUserParser; // "I'm gonna go to the blue flares... distance %1 m"
	};
};

hint localize format["+++ x_intro.sqf: removing parachute ""%1"", has ""%2""", _para, player call SYG_getParachute];
if ( _para != "") then { player removeWeapon _para }; // The parachute is used, remove it from inventory
#endif

if (true) exitWith {};