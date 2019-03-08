_StartLocation = _this select 0;
_paratype      = _this select 1;

//hint localize format["para type %1", _paratype];

#include "x_setup.sqf"
#include "x_macros.sqf"

if (d_para_timer_base > 0) then {
	d_next_jump_time = time + d_para_timer_base;
};

#ifndef __ACE__
_jump_helo = "uh60MG";
if (playerSide == east) then {
	_jump_helo = "Mi17_MG";
};
#endif
#ifdef __ACE__
_jump_helo = "ACE_UH60MG_M240C";
if (playerSide == east) then {
	_jump_helo = "ACE_Mi17_MG";
};
#endif

#ifndef __ACE__
enableRadio false;
#endif
titleText ["","Plain"];
uh60p = createVehicle [_jump_helo, _StartLocation, [], 0, "FLY"];
_halo_height = d_halo_height;
#ifdef __ACE__
if (_paratype  == "ACE_ParachutePack") then {_halo_height = d_halo_height * 2;} else {_halo_height = d_halo_height / 7;};
#endif

uh60p setPos [_StartLocation select 0,_StartLocation select 1, _halo_height];
uh60p engineOn true;
player moveInCargo uh60p;
_obj_jump = player;
if(vehicle player == player)exitWith {};

#ifdef __ACE__
[uh60p,_obj_jump] execVM "\ace_sys_eject\s\ace_jumpout.sqf"; // Go to ACE code to complete jump

sleep 3;

playSound (["vozdushnye_potoki", "vozdushnye_potoki_2"] call XfRandomArrayVal); // parajump made sound

#ifdef __DISABLE_PARAJUMP_WITHOUT_PARACHUTE__
if ( _paratype == "" ) then { (localize "STR_SYS_609_1") call XfHQChat};
#endif

deleteVehicle uh60p;
if (__AIVer) then {
	if (alive player) then {
		[position player, velocity player, direction player] execVM "x_scripts\x_moveai.sqf";
	};
};
if (true) exitWith {}; // ++++++++++++++++ end of script
#endif

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
	#ifdef __AI__
	if (alive player) then {
		[position _obj_jump, velocity _obj_jump, direction _obj_jump] execVM "x_scripts\x_moveai.sqf";
	};
	#endif
	
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