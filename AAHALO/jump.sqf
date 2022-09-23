// AAHALO\jump.sqf: Parachute jump pre/post processing
#include "x_setup.sqf"
#include "x_macros.sqf"

private ["_start_location","_paratype","_jump_score","_jump_helo","_halo_height","_obj_jump","_startTime","_pos","_pilot"];
_start_location = _this select 0;
_paratype       = _this select 1;
_jump_score     = if (count _this > 2) then  {_this select 2} else { 0 }; // how many score to return if player forget his parachute

#ifdef __SPECIAL_JUMP_OVER_SEA__
_use_wind       = if (count _this > 3) then  {_this select 3} else { true }; // Emulate wind above sea (true) or not (false)
#endif

hint localize format[ "+++ jump.sqf: _this = %1, player para = ""%2""", _this, player call SYG_getParachute ];

if (d_para_timer_base > 0) then {
	d_next_jump_time = time + d_para_timer_base;
};

if (typeName _jump_score == "STRING") then {
	_jump_helo = _jump_score;
	_jump_score = 0;
} else  {
#ifdef __ACE__
	_jump_helo = if (playerSide == east) then { "ACE_Mi17_MG" } else { "ACE_UH60MG_M240C" };
#else
	_jump_helo =  if (playerSide == east) then {"Mi17_MG" } else { "uh60MG" };
#endif
};

#define __SPECIAL_JUMP_OVER_SEA__ // special condition of strong wind over sea surface
#define JUMP_DISPERSION 1000        // max. dispersion due to wind in ocean
#define MAX_SHIFT 3500
#define MIN_SHIFT 300

#ifdef __SPECIAL_JUMP_OVER_SEA__
if (_use_wind) then { // emulate sea wind if jump above sea

	_shift = JUMP_DISPERSION;
	#ifdef __ACE__
	if (_paratype == "ACE_ParachutePack") then { _shift = 6 * _shift }; // up to 6 times further
	#endif

	// detect if jump is over sea
	_pos = [];
	_water_count = 0;
	_offsets = [-JUMP_DISPERSION,0, +JUMP_DISPERSION]; // offsets on X and Y to create check matrix 3 x 3 of dimension
	// _offsets = [-JUMP_DISPERSION,-JUMP_DISPERSION/2,0, +JUMP_DISPERSION/2,+JUMP_DISPERSION]; // offsets on X and Y to create check matrix 5 x 5 on dimensiono
	for "_x" from 0 to (count _offsets)-1 do {
		_pos set [0, (_start_location select 0) + (_offsets select _x)];
		for "_y" from 0 to (count _offsets)-1 do {
			// skip central point from counting
			if (_x != 1 || _y != 1) then {
				_pos set [1, (_start_location select 1) + (_offsets select _y)];
				if (surfaceIsWater _pos) then { _water_count = _water_count + 1};
			};
		};
	};

	// if 2 or more points in 3x3 grid with 1 km sides are on land, no ocean wind effect will be applied, else wind is very-very strong))
	_wind_arr = wind;
	if (_water_count >= ((count _offsets) ^ 2 - 2) ) then { // player jumps over sea surface, add strong wind effect
		_len = _wind_arr distance [0,0,0]; // scalar vector length
		_shift = MIN_SHIFT max (random ( _shift min MAX_SHIFT) ); //  shift 300 to 3500 meters from the original start point
		_dx = ((_wind_arr select 0) / _len) * _shift;
		_dy = ((_wind_arr select 1) / _len) * _shift;
		_dz = ((_wind_arr select 2) / _len) * _shift;
		_start_location set [0, (_start_location select 0) + _dx];
		_start_location set [1, (_start_location select 1) + _dy];
		_start_location set [2, (_start_location select 2) + _dz];
		_str_dir = ([[0,0,0],_wind_arr] call XfDirToObj) call SYG_getDirName;
		if ( _shift > 50 ) then {
			format[localize "STR_SYS_76", round(_shift / 20) * 20, _str_dir] call XfHQChat; // “A strong ocean wind blew the parachute off”
		};
		hint localize format["+++ jump.sqf: wind %1 (dir %2), dispersion is %3 [%4,%5,%6] m, water count %7 of %8",
			_wind_arr, ([[0,0,0],_wind_arr] call XfDirToObj) call SYG_getDirNameEng,
			round(_shift), round(_dx), round(_dy), round(_dz), _water_count, ((count _offsets) * (count _offsets) - 1) ];

	};
};
#endif

uh60p = createVehicle [_jump_helo, _start_location, [], 0, "FLY"];
_dir = random 360;
uh60p setDir _dir;
_plane = _jump_helo isKindOf "Plane";
_speed = if (_plane) then {60} else {35};
uh60p setVelocity  [(sin _dir) * _speed, (cos _dir) * _speed, 0 ];
/**
_pilot = (
	switch (d_side_player) do {
		case east: {d_pilot_E};
		case west: {d_pilot_W};
		case resistance: {d_pilot_G};
	}
);
_grp = call SYG_createOwnGroup;
_pilot = _grp createUnit [_pilot, position uh60p, [], 0, "FORM"];
hint localize format["+++ jump.sqf: _grp = %1, _pilot = %2", _grp, _pilot];
[_pilot] join _grp; _pilot setSkill 1; _pilot assignAsDriver uh60p; _pilot moveInDriver uh60p;
*/
uh60p setSpeedMode ( if (_plane) then {"FULL"} else {"LIMITED"} );

_halo_height = d_halo_height;
#ifdef __ACE__
switch _paratype do {
    case "ACE_ParachutePack" : {_halo_height = d_halo_height * 2};
    case "ACE_ParachuteRoundPack";
    default  {_halo_height = d_halo_height / 7};
};
#endif
// check parachute presence
if (_plane) then { // this is intro jump, not flag/heli one
	if ( (player call SYG_getParachute) == "" ) then { player addWeapon _paratype; hint localize format["+++ x_jump.sqf: parachute absent, ""%1"" added", _paratype] };
};

hint localize format[ "+++ jump.sqf: halo height set to %1 m, player has ""%""", round _halo_height, player call SYG_getParachute ];
uh60p setPos [_start_location select 0,_start_location select 1, _halo_height];
uh60p engineOn true;
player moveInCargo uh60p;

#ifndef __ACE__
enableRadio false;
#endif
titleText ["","Plain"];

hint localize format["+++ jump.sqf: vehicle %1 created on height %2 m, player (has ""%3"") move to it", typeOf uh60p, round _halo_height, player call SYG_getParachute];
_obj_jump = player;

if(vehicle player == player)exitWith {};	// ?

#ifdef __ACE__

if ( _plane ) then { // not jump from plane as this usully leads to the wounds
	// Put player 5 meters out of the plane/heli as he is out of vehicle
	player setPos ( uh60p modelToWorld [-5, -5, -5] );
	player setDir _dir;
	player setVelocity  [ (sin _dir) * 20, (cos _dir) * 20, 0 ]; // set speed 20 m/s in direction of plane flight else you are always get  damage to your health
	if (((getPos (vehicle player)) select 2) < 10) exitWith {};
	[ player ] execVM "ace_sys_eject\s\ace_jumpOut_cord.sqf";
	[] spawn {
		waitUntil { (!(alive player)) || (vehicle player != player) || ((getPos player select 2) < 5) };
		if ((getPos player select 2) < 5) exitWith {};
		if (!(alive player)) exitWith {};
		if ( vehicle player != player) then {
			if  ((vehicle player) call SYG_isParachute) then {
				_id = (vehicle player) addEventHandler ["getout", {_this execVM "AAHALO\event_para_dropped.sqf"}];
				(vehicle player) setVariable ["PARA_GETOUT", _id];
			};
		};
	};
} else {
	[uh60p,_obj_jump] execVM "\ace_sys_eject\s\ace_jumpout.sqf"; // Go to ACE code to complete jump
};


sleep 3;

if (!_plane) then {
	playSound (["parajump1", "parajump2"] call XfRandomArrayVal); // Start of parajump event (and corresponding sound of 20 seconds length max)
};
_startTime = time;

if ( _paratype == "" ) then {
    (localize "STR_SYS_609_1") call XfHQChat; // "You finally realize that skydiving requires a parachute ! But it's late... Last question: - How about paid for jump points?"
    if ( player call SYG_isWoman ) then {
        player say format ["female_shout_of_pain_%1",(floor (random 4)) + 1];  // 1-4
    } else {
        player say (call SYG_getSuicideScreamSound);
    };
};

[] spawn { sleep 4; deleteVehicle uh60p };

#ifdef __AI__
	if (alive player) then {
		[position player, velocity player, direction player] execVM "x_scripts\x_moveai.sqf";
	};
#endif

// there are 3 possible states of alive jumper:
// 1. free fall
waitUntil {sleep 0.1; !alive player || ((getPos player select 2) < 5) || (vehicle player) != player || (time - _startTime) >= 20};

// ## 312
if (_jump_score > 0) then { // subtract score from player NOW, while he is alive (may be0
    if ( _paratype == "" ) then {
        (localize "STR_SYS_609_2") call XfHQChat; // "You can jump without a parachute all you want."
    } else {
        format[localize "STR_SYS_609_3",_jump_score] call XfHQChat; // "Jump costs -%1"
        playSound "losing_patience";
        //player addScore -_jump_score;
        (-_jump_score) call SYG_addBonusScore;
    };
};

if ( !alive player || ((getPos player select 2) <= 5)) exitWith {
	hint localize format["+++ jump.sqf: Parajump completed, alive %1, height AGL %2", alive player, round(getPos player select 2)]
}; // can't play sound

if (!_plane) then {
	if ( (time - _startTime) >= 20) then {
		if ( (vehicle player) == player ) then {
			if ( (getPos player select 2) > 300) then {
				hint localize format["+++ jump.sqf: Player still in free fall, height AGL >= 300 (%1) m.", round(getPos player select 2)];
				playSound (["freefall1", "freefall2", "freefall3", "freefall4", "freefall5", "freefall6", "freefall7"] call XfRandomArrayVal); // Start of parajump event (and corresponding sound of 20 seconds length max)
			} else {
				hint localize format["+++ jump.sqf: Player in free fall, height AGL < 300 (%1) m.", round(getPos player select 2)];
				playSound "freefall300m"; // Start of free fall on height < 300 m (and corresponding sound of 16-20 seconds length max)
			};
			_startTime = time;
		};
	};
};
waitUntil {sleep 0.1; !alive player || ((getPos player select 2) < 5) || (((time - _startTime) >= 20) && (vehicle player !=  player)) };

if ( !alive player || ((getPos player select 2) <= 5)) exitWith { hint localize format["+++ jump.sqf: Parajump completed emergency, alive %1, height AGL %2", alive player, round(getPos player select 2)] }; // can't play sound

// 2. para opening
if (!_plane) then {
	if ( (vehicle player) != player ) then {
		hint localize format["+++ jump.sqf: Player in parachute now, height AGL %1!", getPos player select 2];
		playSound format["rippara%1", (floor(random 4)) + 1]; // short versions insteed of one long (1..4)
	};
};

if ( !alive player || ((getPos player select 2) <= 5)) exitWith { hint localize format["+++ jump.sqf: Parajump completed emergency, alive %1, height AGL %2", alive player, round(getPos player select 2)] }; // can't play sound

hint localize format["+++ jump.sqf: Normal exit from script, alive %1, height AGL %2", alive player, round(getPos player select 2)];
if (true) exitWith {}; // ++++++++++++++++ end of script
#else

//===================CONFIG========================

_float_time = 2;
_float_delay = 0.025;

_float_failProb = 0.000001;

_float_ctrlHSpeedStart = 4;
_float_ctrlVSpeedStart = 4;
_float_ctrlVSpeedEnd = -20;

_int_opensMax = 2;
_float_camMinFBH = 100.0;
_float_freezeTime = 2;

_float_crashSpeed = 10;

_parachute = (
	switch (d_own_side) do {
		case "RACS": {"ParachuteG"};
		case "WEST": {"ParachuteWest"};
		case "EAST": {"ParachuteEast"};
	}
);

//=================================================

_float_startVel = velocity vehicle _obj_jump select 2;

if( getPos vehicle player select 2 <
(
	_float_time*(_float_ctrlVSpeedStart + _float_startVel)+
	0.5*(_float_ctrlVSpeedEnd + _float_startVel - _float_ctrlVSpeedEnd - _float_startVel)*_float_time
))exitWith{_obj_jump action["EJECT",vehicle _obj_jump];};

//----------EJECTING SEQUENCE, INDEPENDENT AND DEPENDENT ADAPTATION----------

_v__float_door =[];
_v__float_vehVU = vectorUp vehicle _obj_jump;
_v__float_vehVD = vectorDir vehicle _obj_jump;
_bool_getouSeqAdapt = false;
_v__float_offSet =[0,0,0];
_pos_vehicle =[0,0,0];

_v__float_VDxVU =
[
	(_v__float_vehVU select 1)*(_v__float_vehVD select 2)-(_v__float_vehVD select 1)*(_v__float_vehVU select 2),
	(_v__float_vehVU select 2)*(_v__float_vehVD select 0)-(_v__float_vehVD select 2)*(_v__float_vehVU select 0),
	(_v__float_vehVU select 0)*(_v__float_vehVD select 1)-(_v__float_vehVD select 0)*(_v__float_vehVU select 1)
];

_float_DxUNorm = sqrt((_v__float_VDxVU select 0)^2 +(_v__float_VDxVU select 1)^2 +(_v__float_VDxVU select 2)^2);
_float_DNorm = sqrt((_v__float_vehVD select 0)^2 +(_v__float_vehVD select 1)^2 +(_v__float_vehVD select 2)^2);
_v__float_VDxVU =
[
	(_v__float_VDxVU select 0)/_float_DxUNorm,
	(_v__float_VDxVU select 1)/_float_DxUNorm,
	(_v__float_VDxVU select 2)/_float_DxUNorm
];

_pos_vehicle = getPos vehicle _obj_jump;

switch(typeOf(vehicle _obj_jump))do {
	case "Mi17":{_v__float_door =[2,2.28,1];};
	default {
		_obj_jump action["GETOUT",vehicle _obj_jump];
		_bool_getouSeqAdapt = true;
	}
};

if(!_bool_getouSeqAdapt)then {
	_obj_jump setPos
	[
		(getPos vehicle _obj_jump select 0)+(_v__float_VDxVU select 0)*(_v__float_door select 0)+(_v__float_vehVD select 0)*(_v__float_door select 1)/_float_DNorm,
		(getPos vehicle _obj_jump select 1)+(_v__float_VDxVU select 1)*(_v__float_door select 0)+(_v__float_vehVD select 1)*(_v__float_door select 1)/_float_DNorm,
		(_v__float_door select 2)+(getPos vehicle _obj_jump select 2)+(_v__float_VDxVU select 2)*(_v__float_door select 0) +(_v__float_vehVD select 2)*(_v__float_door select 1)/_float_DNorm
	];
};

waitUntil{vehicle _obj_jump == _obj_jump};

_v__float_offSet =[(getPos _obj_jump select 0)-(_pos_vehicle select 0),
	(getPos _obj_jump select 1)-(_pos_vehicle select 1),
	(getPos _obj_jump select 2)-(_pos_vehicle select 2)];



_v_float_getOutV =[(_v__float_VDxVU select 0)*((_v__float_VDxVU select 0)*(_v__float_offSet select 0)+
	(_v__float_VDxVU select 1)*(_v__float_offSet select 1)+
	(_v__float_VDxVU select 2)*(_v__float_offSet select 2)),
	(_v__float_VDxVU select 1)*((_v__float_VDxVU select 0)*(_v__float_offSet select 0)+
	(_v__float_VDxVU select 1)*(_v__float_offSet select 1)+
	(_v__float_VDxVU select 2)*(_v__float_offSet select 2)),
	(_v__float_VDxVU select 2)*(_v__float_VDxVU select 0)*(_v__float_offSet select 0)+
	(_v__float_VDxVU select 1)*(_v__float_offSet select 1)+
	(_v__float_VDxVU select 2)*(_v__float_offSet select 2)];



if((_v_float_getOutV select 0)== 0)then {
	if(( _v_float_getOutV select 1)< 0)then{_obj_jump setDir 180;}else{_obj_jump setDir 0;};
} else {
	if((_v_float_getOutV select 0)> 0)then {
		_obj_jump setDir(90 - atan(( _v_float_getOutV select 1)/(_v_float_getOutV select 0)));
	}else{
		_obj_jump setDir(270 - atan((_v_float_getOutV select 1)/(_v_float_getOutV select 0)));
	};
};

v__int_reqKeys = [];
v__float_mousePos =[0,0];

_int_cycle = 0;
_float_dir = 90 -(getDir _obj_jump);
_bool_open = false;
_int_opens = 0;

_float_vUpX = 0;
_float_vUpY = 0;
_float_vUpZ = 0;

_v__str_weapons = weapons _obj_jump;
_v__str_mags = magazines _obj_jump;
x_weapon_array = [_v__str_weapons,_v__str_mags];
removeAllWeapons _obj_jump;
if("NVGoggles" in _v__str_weapons)then{_obj_jump addWeapon "NVGoggles";};
_obj_jump switchMove "para_pilot";

_dis_diag = displayNull;
_ctrl_emerg = controlNull;

_obj_camera = "Camera" camCreate[0,0,0];
_obj_camera camSetTarget _obj_jump;
_obj_camera camSetRelPos[-10,2,-1];
_obj_camera camCommit 0;
_obj_camera cameraEffect["INTERNAL","BACK"];
showCinemaBorder false;

while{_int_cycle <( _float_time/_float_delay)}do {
	_int_cycle = _int_cycle + 1;
	
	_obj_jump setVelocity
	[
		cos _float_dir * _float_ctrlHSpeedStart*(1 - (_int_cycle*_float_delay/_float_time)),
		sin _float_dir * _float_ctrlHSpeedStart*(1 - (_int_cycle*_float_delay/_float_time)),
		_float_startVel+_float_ctrlVSpeedStart -(_float_ctrlVSpeedStart - _float_ctrlVSpeedEnd)*_int_cycle*_float_delay/_float_time
	];
	_float_vUpX = cos _float_dir*(_float_ctrlHSpeedStart -(_float_ctrlHSpeedStart - 1)*_int_cycle*_float_delay/_float_time);
	_float_vUpY = sin _float_dir*(_float_ctrlHSpeedStart -(_float_ctrlHSpeedStart - 1)*_int_cycle*_float_delay/_float_time);
	_float_vUpZ = _float_ctrlVSpeedStart -(_float_ctrlVSpeedStart + 2)*_int_cycle*_float_delay/_float_time;
	
	_obj_jump setVectorDir [_float_vUpX*_float_vUpZ,_float_vUpY*_float_vUpZ,-1*(_float_vUpX^2 + _float_vUpY^2)];
	_obj_jump setVectorUp [_float_vUpX,_float_vUpY,_float_vUpZ];
	
	if(_int_cycle ==(_float_time/_float_delay)/2)then{cutText["","BLACK OUT"];};

	sleep _float_delay;
};

_bool_diag = createDialog "ctrlParaDiag";
cutText["","BLACK IN"];

[_obj_jump,_obj_camera]execVM "AAHALO\freeFall.sqf";

[_obj_jump,-1*_float_crashSpeed]spawn {
	waitUntil{(getPos vehicle(_this select 0)select 2 )<10};
	if(alive (_this select 0)&&(velocity vehicle (_this select 0)select 2)<(_this select 1))then {
		(_this select 0) setDammage 1;
	};
};

[_obj_camera,_obj_jump,_v__str_weapons]spawn {
	_bool_NVOn = false;
	_v__int_reqKeysNew =[];
	while{true}do {
		while{(count v__int_reqKeys)> 0}do {
			if((v__int_reqKeys select 0)in(actionKeys "nightVision") && "NVGoggles" in(_this select 2))then {
				_bool_NVOn = !_bool_NVOn;
				camUseNVG _bool_NVOn;
			};
			_v__int_reqKeysNew =[];
			for[{_int_i = 1;},{_int_i < count v__int_keyReq},{_int_i = _int_i + 1;}]do {
				_v__int_reqKeysNew = _v__int_reqKeysNew +(v__int_reqKeys select _int_i);
			};
			v__int_reqKeys = _v__int_reqKeysNew;
		};
		waitUntil{(count v__int_reqKeys)> 0};
	};
};

waitUntil{!dialog || !alive _obj_jump};
while{_int_opens < _int_opensMax && !_bool_open && alive _obj_jump &&(getPos _obj_jump select 2)>10}do {
	_int_opens = _int_opens + 1;
	_obj_jump setVariable["bool_freeFall",false];
	_bool_open = true;
	_obj_para = _parachute createVehicle[0,0,0];
	_obj_para setPos getPos _obj_jump;
	_obj_para setVelocity velocity _obj_jump;
	_obj_jump moveInDriver _obj_para;
	if (__AIVer) then {
		if (alive player) then {
			[position _obj_jump, velocity _obj_jump, direction _obj_jump] execVM "x_scripts\x_moveai.sqf";
		};
	};

	if((getPos _obj_jump select 2)> _float_camMinFBH)then {
		_obj_camera camSetTarget vehicle _obj_jump;
		_obj_camera camCommit 0;
	}else{
		_obj_camera cameraEffect["Terminate","Back"];
		camDestroy _obj_camera;
		_obj_camera = objNull;
	};
	if(!_bool_open)then {
		sleep _float_freezeTime;
		if(isNull _obj_camera)then {
			_obj_camera = "Camera" camCreate[0,0,0];
			_obj_camera cameraEffect["External","Back"];
		};
		_bool_diag = createDialog "ctrlParaDiag";
		_dis_diag = findDisplay 856;
		_ctrl_emerg = _dis_diag displayCtrl 857;
		_ctrl_emerg ctrlSetTextColor[1,0,0,1];
		[_obj_jump,_obj_camera]execVM "AAHALO\freeFall.sqf";
	}else{
		sleep _float_freezeTime;
		if(!isNull _obj_camera)then {
			_obj_camera cameraEffect["Terminate","Back"];
			camDestroy _obj_camera;
			_obj_camera = objNull;
		};
	};
			
	waitUntil{_int_opens >= _int_opensMax || _bool_open ||(!alive _obj_jump)||(!dialog)||(getPos _obj_jump select 2)<10};
};

waitUntil{(!alive _obj_jump)||(getPos _obj_jump select 2)<10};
if (alive _obj_jump) then {
	x_weapon_array = [];
};
{_obj_jump addMagazine _x;} forEach _v__str_mags;
{if(_x != "NVGoggles")then{_obj_jump addWeapon _x;}} forEach _v__str_weapons;
_primw = primaryWeapon _obj_jump;
if (_primw != "") then {
	_obj_jump selectWeapon _primw;
	_muzzles = getArray(configFile>>"cfgWeapons" >> _primw >> "muzzles");
	_obj_jump selectWeapon (_muzzles select 0);
};
_obj_jump setVariable["bool_freeFall",false];
if(dialog)then{closeDialog 856;};
enableRadio true;

// bugfix Lockie@ArmaInteractive 
// always destroy camera 
_obj_camera CameraEffect  ["Terminate", "Back"];
_obj_camera camCommit 0;

if (true) exitWith {};
#endif
