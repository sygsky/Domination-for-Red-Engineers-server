// x_intro.sqf, by Xeno
private ["_s","_str","_dlg","_XD_display","_control","_line","_camstart","_intro_path_arr",
         "_Sahrani_island","_plpos","_i","_XfRandomFloorArray","_XfRandomArrayVal","_cnt","_lobj", "_lobjpos",
		 "_year","_mon","_day","_newyear","_holiday","_camera","_start","_pos","_tgt","_sound","_date"];
if (!X_Client) exitWith {hint localize "--- x_intro run not on client!!!";};
//hint localize "+++ x_intro started!!!";
d_still_in_intro = true;

#include "x_setup.sqf"
#include "x_macros.sqf"

#define __DEBUG__

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
_control ctrlShow false;
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
#ifdef __HOLIDAY_DEBUG__
_date =  + SYG_client_start;
_date set [1,11]; _date set [2, 7]; // 07-NOV-1985, 23-FEB-1985 etc
_holiday = _date call SYG_getHoliday;
#else
_holiday = SYG_client_start call SYG_getHoliday;
#endif

_sound = "";
if (count _holiday > 0 ) then {
    // Soviet holiday detected, show its info to user
    // TODO: show info about soviet holiday and/or play corresponding sound
    _sound = _holiday select 1;
    if (_sound != "") then {playMusic _sound};
};
if (_sound == "") then { // select random music for ordinal day
    if ( ( (_mon == 12) && (_day > 20) ) || ( (_mon == 1) && (_day < 11) ) ) then
    {
        playMusic (["snovymgodom","grig","zastolnaya","nutcracker","home_alone","mountain_king","merry_xmas","vangelis"] call _XfRandomArrayVal); //music for New Year period from 21 December to 10 January
        _newyear = true;
    }
    else // music normally played on intro
    {

        if ( _mon == 11 && (_day >= 4 && _day <= 10) ) then
        {
            // 7th November is a Day of Great October Socialist Revolution
            playMusic  ((call compile format["[%1]", localize "STR_INTRO_MUSIC_VOSR"]) call _XfRandomArrayVal);
        }
        else
        {
            // add some personalized songs for well known players
            _players =
            [
                ["Ceres-de","CERES de","Ceres.","CERES"] ,
                ["Rokse [LT]"],
                ["Shelter", "Marcin"]
            ];
            _sounds  =
            [
                ["amigohome_ernst_bush","amigohome_ernst_bush","zaratustra"],
                ["morze","morze2","morze_0","morze_2","morze_3","morze_4","morze_5","morze_6","morze_7"],
                ["stavka_bolshe_chem","stavka_bolshe_chem","four_tankists","four_tankists"]
            ];
            _name    = name player;
            _personalSounds = [];
            {
                _pos = _x find _name;
                if ( _pos >= 0 ) exitWith { _personalSounds = _sounds select _pos};
            } forEach _players;
            if (format["%1",player] in ["RESCUE","RESCUE2"]) then {
                {
                    _personalSounds = _personalSounds + ["from_russia_with_love","bond1","bond"];
                } forEach [1,2,3];
            }; // as you are some kind of spy
            _music = ((call compile format["[%1]", localize "STR_INTRO_MUSIC"]) +
            [
                "bond","grant",/*"red_alert_soviet_march",*/"burnash","adjutant","lastdime","lastdime1","lastdime2","lastdime3",
                "Art_Of_Noise_mono","mission_impossible","from_russia_with_love","bond1","prince_negaafellaga","strelok",
                "total_recall_mountain","capricorn1title","Letyat_perelyotnye_pticy_2nd","adagio","nutcracker",
                "ruffian","morze","treasure_island_intro","fear2","chapaev","cosmos","manchester_et_liverpool",
                "tovarich_moy","rider","hound_baskervill","condor","way_to_dock","Vremia_vpered_Sviridov", // "ipanoram",
                "Letyat_perelyotnye_pticy_end","melody_by_voice","sovest1","sovest2","morricone1","toccata","smersh",
                "del_vampiro1","del_vampiro2", "zaratustra"
            ] + _personalSounds ) call _XfRandomArrayVal;
    //        _music = format["[%1]", """johnny"",""Art_Of_Noise_mono"""];
    //        _music = (call compile _music) call _XfRandomArrayVal;
            playMusic _music;
            //playMusic "ATrack25"; // oldest value by Xeno
         };
    };
};

if ((daytime > (SYG_startNight + 0.5)) || (daytime < (SYG_startMorning - 0.5))) then {
	camUseNVG true;
};

#ifdef __DEBUG__
hint localize format["x_intro.sqf: time is %1, daytime is %2, nowtime is %3, missionStart is %4",time, daytime, call SYG_nowTimeToStr, SYG_client_start call SYG_dateToStr];
#endif

#ifdef __DEFAULT__
_Sahrani_island = true;
#else
_Sahrani_island = false;
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
	for "_i" from 0 to (count _this - 1) do // for each paths in available array
	{
		_path = _this select _i; // whole array of path point + possible last index for object
		for "_j" from 0 to (count _path - 1) do
		{
		    _x = argp(_path, j); // point [x,y,z] of the path
            if ( (typeName _x) == "ARRAY") then // may be not point but scalar index (last in array)
            {
                if ( (_x distance _pos) < _min ) then {_min = _x distance _pos; _ind = _i; _posInd = j};
            };
		};
	};
	
	// we found the nearest intro path to the target town, assigned to _ind variable
#ifdef __OLD__
	// now find nearest point in this path to target town
	_path = _this select _ind;
	_min = 1000000;
	for "_i" from 0 to (count _path - 2) do 
	{
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
if ( (current_target_index != -1 && !target_clear) && !all_sm_res && !side_mission_resolved && (current_mission_index >= 0)) then {

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
if (_Sahrani_island ) then // 7703.5,7483.2, 0
{
	// array of camera turn points. Last point is for illusion object creation point.If it is NUMBER in range {0..last_turn_point_index-1>} designated index turn point is used for illusion
  _camstart = 
  [
    [[1947,19059,1],[2260,18839,10],[4979,15480,40],[8982.5,10777,150],1], // Island Parvulo
    [[18361,18490,1],[14260,15170,30],[11141,13340,50],[18127,18337,0]], // Isle Antigua (2)
    [[19684.6,14128.7,25],[17681.2,13076.8,40],[15397.763672,11924.510742,50],[11420,8570,20],[10869,9172,40],[19356,14018,0]], // Pita (3)
    [[1224,1391,1],[1580,1711,20],[8971,8170,70],1], // Rahmadi (4)
    [[18534,2730,1],[18259,2978,10],[11420,8570,20],[10628,9328,40],1], // vulcano Asharan (5)
	[[12113,5833,1],[11820,6059,6],[11717.1,6068.6,9],[11642,6336,9],[11480,6658,10],[11147,7138,11],[10992,7749,21],[11014,7990,31],[11121,8155,51],[11420,8570,46],[10869,9172,41],[12025,6082,0]], // Dolores (6)
	[[6111,17518,1],[7355,17182,60],[12221,15217,50],[12000,14618,50],[10719,14222,70],[8982.5,10777,150],[11930,14526,0]] // Cabo Valiente (7)
  ] call _SYG_selectIntroPath;
  _pos = _camstart select 1;
  // last pos is illusion object one. If number it means index of point to use as pos, else it means pos3D to build illusion
  _lobjpos = _camstart select ((count _camstart) - 1);
  _lobjpos = if (typeName _lobjpos == "ARRAY") then {_lobjpos} else { _camstart select _lobjpos};
}
else
{
	_camstart = [[(position camstart select 0),(position camstart select 1),175]];
	_pos = _camstart select 0;
};

_lobj = (
    ["LODy_test", "Barrels", "Land_kulna","misc01", "Land_helfenburk","FireLit",
    "Land_majak2","Land_zastavka_jih","Land_ryb_domek","Land_aut_zast","Land_telek1",
    "Land_water_tank2","Land_R_Minaret","Land_vez","Land_strazni_vez"] call _XfRandomArrayVal) createVehicleLocal _lobjpos;
sleep 0.1;
_lobj  setVectorUp [0,0,1]; // make object be upright
switch typeOf _lobj do
{
	case "Barrels": { _lobj setDamage 1.0;};
};
//_lobj setDirection (random 360);
  
#define DEFAULT_EXCESS_HEIGHT_ABOVE_POINT 20
#define DEFAULT_EXCESS_HEIGHT_ABOVE_HEAD 2
#define DEFAULT_SHOW_TIME 17
 
//hint localize format["x_intro.sqf: _camstart %1 (cnt %2)", _camstart, count _camstart];

// calc whole path length/partial segments commit times
_plen = 0;
_start = _camstart select 0;

// complete path on player position
_tgt = position player;
_tgt set [2, DEFAULT_EXCESS_HEIGHT_ABOVE_HEAD];
_camstart set [(count _camstart)-1, _tgt]; // replace illusion data with destination point 3D position
_arr = [];
_pos = _start;
for "_i" from 1 to ((count _camstart) - 1) do
{
	_tgt = _camstart select _i;
	_dist = _pos distance _tgt;
	_plen = _plen + _dist;
	_arr set [_i, _dist];
};
//hint localize format["x_intro.sqf: distance array [%1] is %2", count _arr, _arr];
for "_i" from 0 to ((count _arr) - 1) do {_arr set[_i, (_arr select _i) / _plen * DEFAULT_SHOW_TIME]}; // durations
//hint localize format["x_intro.sqf: updated  camstart is %1", _camstart];
//hint localize format["x_intro.sqf: duration array %1", _arr];

#endif

_PS1 = "#particlesource" createVehicleLocal [position player select 0, position player select 1, 1.5];
_PS1 setParticleCircle [0, [0, 0, 0]];
_PS1 setParticleRandom [0, [0, 0, 0], [0,0,0], 0, 1, [0, 0, 0, 0], 0, 0];
_PS1 setParticleParams [["\Ca\Data\ParticleEffects\SPARKSEFFECT\SparksEffect.p3d", 8, 3, 1], "", "spaceobject", 1, 0.2, [0, 0, 1], [0,0,0], 1, 10/10, 1, 0.2, [2, 2], [[1, 1, 1 ,1], [1, 1, 1, 1], [1, 1, 1, 1]], [0, 1], 1, 0, "", "", _this];
_PS1 setDropInterval 0.01;

_camera = objNull;
_plpos = [(position player select 0),(position player select 1),1.5];
if ( typeName _camstart == "ARRAY" ) then
{
	_camera = "camera" camCreate _start;
	if (surfaceIsWater _start) then { _camera say "under_water_3" }; // gurgle if in water
}
else
{
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

if ( _newyear ) then
{
	cutRsc ["XDomLabelNewYear","PLAIN",2];
}
else
{
	cutRsc ["XDomLabel","PLAIN",2];
};

//[1, "D O M I N A T I O N  3!", 4] execVM "IntroAnim\animateLettersX.sqf";_line = _line + 1; waitUntil {i == _line};
[_start_pos, _str, 5] execVM "IntroAnim\animateLettersX.sqf";_line = _line + 1; waitUntil {i == _line};
if (count _sarray > 0) then {
	[_start_pos2, _str2, 6] execVM "IntroAnim\animateLettersX.sqf";_line = _line + 1; waitUntil {i == _line};
};

if (typeName _camstart != "ARRAY" ) then
{
	_camera camSetTarget player;
	_camera camSetPos _plpos;
	_camera camCommit 18;
}
else
{
};

//titleRsc ["Titel1", "PLAIN"];
[] spawn {
	private ["_XD_display", "_control", "_endtime", "_r", "_a"];
	sleep 6;
	_XD_display = findDisplay 77043;
	_control = _XD_display displayCtrl 66666;
	_control ctrlShow true;
	_endtime = time + 10;
	_r = 0;_a = 0.008;_sec = 0;
	while {_endtime > time} do {
		//_control = _XD_display displayCtrl 66666;
		_control ctrlSetTextColor [_r,_r,_r,_r];
		_r = _r + _a;
		if (_r >= 1) then {
			_r = 1;
			_sec = _sec + 1;
		};
		if (_sec == 300) then {
			_a = -0.008;
			_sec = _sec + 1;
		};
		sleep .01;
	};
	//_control = _XD_display displayCtrl 66666;
	_control ctrlShow false;
};

_start spawn {
	private ["_txt","_arr"];
	//sleep 2;
	{
		_txt = switch _x do
		{
			case 1: { localize "STR_INTRO_1" }; // Alternative reality
			case 2: { localize "STR_INTRO_2" }; // North Atlantic
			case 3: { format[localize "STR_INTRO_3", date call SYG_humanDateStr, (date call SYG_weekDay) call SYG_weekDayLocalName, call SYG_nowHourMinToStr, ceil(call SYG_missionDayToNum)] }; // landing time / week day 
			case 4: { format[localize "STR_INTRO_4", text (_this call SYG_nearestSettlement)] }; // settlement
			case 5: {  // message and sound for current day period (morning,day,evening,night), if available
                [] spawn {
                    sleep (60 + (random 20));
                    private ["_str"];
                    _str = [] call SYG_getMsgForCurrentDayTime;
                    titleText[_str, "PLAIN DOWN"];
                    _str = ([] call SYG_getCurrentDayTimeRandomSound);
                    if (_sound != "") then { playSound _str; };
                };
                ""
			};
			case 6: { // print info per holiday if available
            	private ["_holiday","_date"];
            #ifdef __HOLIDAY_DEBUG__
                _date =  + SYG_client_start;
                _date set [1,11]; _date set [2, 7]; // 07-NOV-1985, 23-FEB-1985 etc
                _holiday = _date call SYG_getHoliday;
            #else
                _holiday = SYG_client_start call SYG_getHoliday;
            #endif
                if ( (count _holiday) == 0 ) exitWith {""};
                _str = if (_holiday select 0) then {"STR_INTRO_5_1"} else {"STR_INTRO_5_0"};
                ["msg_to_user", "", [["STR_INTRO_5",_holiday select 2,_str]]] call SYG_msgToUserParser; // message output
                "" // don't show anything more
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

	for "_i" from 1 to (_cnt-1) do
	{
		_pos = _camstart select _i; // next point to look and go to it
		if ( (_pos select 2)  < 0 ) then
		{
			_tgt = + _pos;
			_tgt set [2, 0]; // point on the ground
			_pos set [2, abs(_pos select 2)]; // point above the ground
			hint localize format["_x_init.sqf: spec point tgt %1, pnt %2", _tgt, _pos];
		}
		else
		{
		    // TODO: shift X and Y coordinates slightly, for more native behaviour
		    if ( _x < (_cnt-1)) then
		    {
		        _pos set [0, (_pos select 0) - RANDOM_POS_OFFSET +  (2 * (random RANDOM_POS_OFFSET))]; // shift along X
		        _pos set [1, (_pos select 1) - RANDOM_POS_OFFSET +  (2 * (random RANDOM_POS_OFFSET))]; // shift along Y
		    };
			_tgt = [_start, _pos, 30000.0] call SYG_elongate2Z;
		};

 		_camera camPrepareTarget _tgt; // let look to over there
//		_camera camCommitPrepared 0.5; // time to rotate to target
//		waitUntil {camCommitted _camera}; // wait until pointing to the target

//		hint localize format["_x_init.sqf: %2, vectorDir at %1", vectorDir _camera, time];
		
		_camera camPreparePos _pos;	// let go to over there
 		_camera camCommitPrepared (_arr select _i); // set time to go
		waitUntil {camCommitted _camera}; // wait until come
		//if ( _i == 2 ) then {sleep 5;};
//		hint localize format["_x_init.sqf: %2, pos       at %1", getPos _camera, time];

/*  		if ( _wait == 0) then 
		{
			playSound "ACE_VERSION_DING";
			sleep 2.0;
		};
 */

		_start = _pos;
	};
//	hint localize format["%1 x_intro.sqf: last camera commit completed",call SYG_daytimeToStr];

if ( typeName _camstart != "ARRAY" ) then
{
	waitUntil {camCommitted _camera};
}
else
{
	//_cnt = 0;
	//_maxcnt = 18*2; // 18 second minus 6 seconds already slept with step by 0.5 second (see next waitUntil)
	//waitUntil {sleep 0.5; _cnt = _cnt +1; (scriptDone _handle) || (_cnt > _maxcnt)};
//	waitUntil {scriptDone _handle};
	/* if ( _cnt >= _maxcnt ) then 
	{
		hint localize format["%1 x_intro.sqf: commit scrip finished by counter"];
	}
	else
	{
		hint localize format["%1 x_intro.sqf: commit scrip finished last camera commit completed",call SYG_daytimeToStr];
	};
	 */
};

player cameraEffect ["terminate","back"];
camDestroy _camera;
closeDialog 0;
deleteVehicle _PS1;

enableRadio true;
//player removeEventHandler ["hit", _phiteh];
//player removeEventHandler ["dammaged", _pdamageeh];

if ( !isNull _lobj ) then { deleteVehicle _lobj};

d_still_in_intro = false;

if (true) exitWith {};
