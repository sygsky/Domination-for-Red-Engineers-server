#include "x_setup.sqf"
/*
   mando_chute.sqf v1.1
   by Mandoble

   Moves a chute to the landing position
   
   Parameters:
   unit ejecting: a soldier.
   target position: a 2D or 3D map position.
   radius from target, max distance from target position to aim.
   Type of chute to be used (its class),"" if you dont care.

   Ex.:
   [chuteman, getMarkerPos "mk_land", 20]execVM"mando_chute.sqf";
*/

private["_man", "_chuto", "_target_pos", "_deg_sec", "_dir", "_ang", "_posc", "_dif", "_difabs", "_turn", "_hspd", "_max_spd", "_deltatime", "_timeold", "_vx", "_vy", "_vh", "_vz", "_acc", "_cone", "_type", "_vvel", "_vdir", "_vup"];
_man = _this select 0;
_target_pos = _this select 1;
_rad = _this select 2;
_type = _this select 3;
_chuto = _this select 4;
_is_ammo = _this select 5;

if (count _target_pos == 2) then {
	_target_pos = _target_pos + [0];
};
_ang = random 360;
_target_pos = (
	if (_rad == 0) then {
		[(_target_pos select 0),(_target_pos select 1), 0]
	} else {
		[(_target_pos select 0)+sin(_ang)*_rad,(_target_pos select 1)+cos(_ang)*_rad, 0]
	}
);

_deg_sec = 30;
_max_spd = 4;
_hspd = _max_spd;
_acc = 2;
_vh = 0;
_vz = -3;

_timeold = time;
_dir = getDir _chuto;
_chuto setDir _dir;
_cone setDir _dir;
_posc = getPosASL _chuto;
_cone = "RoadCone" createVehicleLocal [0,0,0];
_cone setPosASL [_posc select 0, _posc select 1, (_posc select 2)-4];
_posc = getPosASL _cone;
while {alive _chuto && ((getPos _chuto select 2) > 5)} do {
	_deltatime = (time-_timeold) max 0.001;
	_timeold = time;
   
	_posc = getPosASL _cone;
	_ang = ((_target_pos select 0) - (_posc select 0)) atan2 ((_target_pos select 1) - (_posc select 1));
	if (([_target_pos select 0, _target_pos select 1, 0] distance [_posc select 0, _posc select 1, 0]) > (getPos _cone select 2)) then {
		if ((_vz + 0.5*_deltatime) < -1.5) then {
			_vz = _vz + 0.5*_deltatime;
		};
	} else {
		if ((_vz - 0.5*_deltatime) > -3) then {
			_vz = _vz - 0.5*_deltatime;
		};
	};

	_dif = (_ang - _dir);
	if (_dif < 0) then {_dif = 360 + _dif;};
	if (_dif > 180) then {_dif = _dif - 360;};
	_difabs = abs(_dif);
  
	if (_difabs > 0.01) then {
		_turn = _dif/_difabs;
	} else {
		_turn = 0;
	};

	_dir = _dir + (_turn * ((_deg_sec * _deltatime) min _difabs));

	if (_vh < _hspd) then {
		_vh = _vh + (_acc * _deltatime);
	} else {
		if (_vh > _hspd) then {
			_vh = _vh - (_acc * _deltatime);  
		};
	};

	if (_difabs > 45) then {
		_hspd = _max_spd / 3;
	} else {
		_hspd = _max_spd;
	};
	_cone setDir _dir;
	_cone setVelocity [sin(_dir)*_vh, cos(_dir)*_vh, _vz];
	if (!isNull _man) then {
		_man setPos position _cone;
		_man setDir _dir;
	};
	_chuto setPos (_cone modelToWorld [0,0,4]);
	_chuto setDir _dir;

	Sleep 0.01;
};
_pos_conex = [position _cone select 0,position _cone select 1,position _cone select 2];
deleteVehicle _cone;
if (_is_ammo) then {
	["d_air_box",_pos_conex] call XSendNetStartScriptClient;
} else {
	_pos_man = position _man;
	_helper1 = "HeliHEmpty" createVehicleLocal [_pos_man select 0, _pos_man select 1, 0];
	_helper1 setPos [_pos_man select 0, _pos_man select 1, 0];
	_man setPos [_pos_man select 0, _pos_man select 1, 0];
	_man setVectorUp (vectorUp  _helper1);
	deleteVehicle _helper1;
};