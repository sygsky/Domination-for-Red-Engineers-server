// x_intro.sqf, by Xeno
private ["_s","_str","_dlg","_XD_display","_control","_line","_camstart","_intro_path_arr",
         "_Sahrani_island","_plpos","_i","_XfRandomFloorArray","_XfRandomArrayVal","_cnt","_lobj", "_lobjpos",
		 "_year","_mon","_day","_newyear"];
if (!X_Client) exitWith {hint localize "--- x_intro run not in client!!!";};
//hint localize "+++ x_intro started!!!";
d_still_in_intro = true;

#include "x_setup.sqf"
#include "x_macros.sqf"

#define __DEBUG__

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
//_phiteh = player addEventHandler ["hit", {(_this select 0) setDamage 0}];_pdamageeh = player addEventHandler ["damage", {(_this select 0) setDamage 0}];
_dlg = createDialog "X_RscAnimatedLetters";
_XD_display = findDisplay 77043;
_control = _XD_display displayCtrl 66666;
_control ctrlShow false;
_line = 0;
i = 0;

/*
#ifdef __DEBUG__
SYG_mission_start = [2015,12,25,8,0,0 ];
hint localize format["x_intro.sqf: time %1, for debugging purposes missionStart set to %2", time, SYG_mission_start call SYG_dateToStr];
#endif
*/

_year = SYG_mission_start select 0;
_mon  = SYG_mission_start select 1;
_day  = SYG_mission_start select 2;
_newyear = false;

if ( ( (_mon == 12) && (_day > 20) ) || ( (_mon == 1) && (_day < 11) ) ) then
{
	playMusic (["snovymgodom","grig"] call _XfRandomArrayVal); //music for New Year period from 21 December to 10 January
	_newyear = true;
}
else // music normally played on intro
{
    if ( _mon == 11 && (_day >= 4 && _day <= 10) ) then
    {
        playMusic "Varshavianka"; // 7th November is a Day of Great October Socialist Revolution
    }
    else
    {
        _music = (call compile format["[%1]", (localize "STR_INTRO_MUSIC")]) +
        [
            "bond","grant","stavka_bolshe_chem","red_alert_soviet_march",
            "burnash","adjutant","lastdime","english_murder","requiem"
        ] call _XfRandomArrayVal;
//        _music = format["[%1]", """johnny"",""Art_Of_Noise_mono"""];
//        _music = (call compile _music) call _XfRandomArrayVal;
        playMusic _music;
        //playMusic "ATrack25";
	 };
};

if ((daytime > (SYG_shortNightStart + 0.5)) || (daytime < (SYG_shortNightEnd - 0.5))) then {
	camUseNVG true;
};

#ifdef __DEBUG__
hint localize format["x_intro.sqf: time is %1, nowtime is %2, missionStart is %3",time, call SYG_nowTimeToStr, SYG_mission_start call SYG_dateToStr];
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
	if (true) exitWith { _this call _XfRandomArrayVal};
	private ["_tt","_pnt","_pos","_i","_min","_path","_ind"];
	_tt = call SYG_getTargetTown;
#ifdef __DEBUG__	
	hint localize format["x_intro.sqf: target town detected %1", _tt];
#endif	

	_pos = +(_tt select 0); // center of town
	if ( count _tt == 0) exitWith { _this call _XfRandomArrayVal };
	_ind = -1; // index of nearest entry
	//find nearest entry point to the target
	_min = 1000000;
	for "_i" from 0 to (count _this - 1) do 
	{
		_path = _this select _i;
		if ( ((_path select 0) distance _pos) < _min) then {_min = (_path select 0) distance _pos; _ind = _i;};
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
 */};
 //--- Sygsky

_pos = [];
_lobjpos = [];
if (_Sahrani_island ) then // 7703.5,7483.2, 0
{
	// array of camera turn points. Last point is for illusion object creation point.If it is NUMBER in range {0..last_turn_point_index-1>} designated index turn point is used for illusion
  _camstart = 
  [
    [[1947.0,19059.0,1.0],[2260.0,18839.0,10.0],[4979.0,15480.0,40.0],[8982.5,10777.0,150.0],1], // Island Parvulo
    [[18361.0,18490.0,1.0],[14260.0,15170.0,30.0],[11141.0,13340.0,50.0],[18127,18337,0]], // Isle Antigua (2)
    [[19684.6,14128.7,25.0],[17681.2,13076.8,40.0],[15397.763672,11924.510742,50.0],[11420.0,8570.0,20.0],[10869,9172,40.0],[19356,14018,0]], // Pita (3)
    [[1224.0,1391.0,1.0],[1580.0,1711.0,20.0],[8971,8170,70],1], // Rahmadi (4)
    [[18534.0,2730.0,1.0],[18259.0,2978.0,10.0],[11420.0,8570.0,20.0],[10628.0,9328.0,40.0],1], // vulcano Asharan (5)
	[[12113.0,5833.0,1.0],[11820.0,6059.0,6.0],[11717.1,6068.6,9.0],[11642.0,6336.0,9.0],[11480.0,6658.0,10.0],[11147.0,7138.0,11.0],[10992.0,7749.0,21.0],[11014.0,7990.0,31.0],[11121.0,8155.0,51.0],[11420.0,8570.0,46.0],[10869,9172,41.0],[12025,6082,0]], // Dolores (6)
	[[6111,17518,1],[7355,17182,60],[12221,15217,50],[12000,14618,50],[10719,14222,70],[8982.5,10777.0,150.0],[11930,14526,0]] // Cabo Valiente (7)
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
    ["LODy_test", "Barrels", /*"ACamp",*/ "Land_kulna","misc01", "Land_helfenburk","FireLit",
    "Land_majak2","Land_zastavka_jih","Land_ryb_domek","Land_aut_zast"] call _XfRandomArrayVal) createVehicleLocal _lobjpos;
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
		_control = _XD_display displayCtrl 66666;
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
	_control = _XD_display displayCtrl 66666;
	_control ctrlShow false;
};

_start spawn {
	private ["_txt"];
	//sleep 2;
	{
		_txt = switch _x do
		{
			case 1: { localize "STR_INTRO_1" }; // Alternative reality
			case 2: { localize "STR_INTRO_2" }; // North Atlantic
			case 3: { format[localize "STR_INTRO_3", date call SYG_humanDateStr, (date call SYG_weekDay) call SYG_weekDayLocalName, call SYG_nowHourMinToStr, ceil(call SYG_missionDayToNum)] }; // landing time / week day 
			case 4: { format[localize "STR_INTRO_4", text (_this call SYG_nearestSettlement)] }; // settlement
		};
		titleText[ _txt, "PLAIN DOWN" ];
		sleep 4;
	} forEach [ 4, 1, 2, 3 ];
	// titleText[ "", "PLAIN DOWN" ]; // not needed
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
//player removeEventHandler ["damage", _pdamageeh];

if ( !isNull _lobj ) then { deleteVehicle _lobj};

d_still_in_intro = false;

if (true) exitWith {};
