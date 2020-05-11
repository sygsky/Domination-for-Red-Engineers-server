// x_shootari.sqf, by Xeno
private ["_angle","_center_x","_center_y","_height","_i","_number_shells","_shell","_pos_enemy","_radius","_type",
         "_wp_array","_x1","_xo","_y1","_kind"];
if (!isServer) exitWith {};

#include "x_setup.sqf"

_pos_enemy = _this select 0;
_kind = _this select 1;

#define HIT_RADIOUS 30

_radius = HIT_RADIOUS;
_height = (switch (_kind) do {case 1: {150}; case 2: {0};});

_center_x = (_pos_enemy) select 0;
_center_y = (_pos_enemy) select 1;

_number_shells = 5 + (ceil random 5);
_type = "";

if (d_enemy_side == "EAST") then {
	if (_kind == 1) then {
		_type = "Sh_120_HE"
	} else {
		_type = "Smokeshell"
	};
} else {
	if (_kind == 1) then {
		_type = "Sh_125_HE"
	} else {
		_type = "Smokeshell"
	};
};

if (_kind == 1) then {["o_arti",_pos_enemy] call XSendNetStartScriptClient;};

_wp_array = [];
while {count _wp_array < _number_shells} do {
	_angle = random 360;
	_radius =random HIT_RADIOUS;
	_x1 = _center_x - (_radius * sin _angle);
	_y1 = _center_y - (_radius * cos _angle);
	_wp_array = _wp_array + [[_x1, _y1, _height]];
	sleep 0.0153; // 0.2
};
sleep (5.25 + (random 5));
for "_i" from 0 to (_number_shells - 1) do {
	_shell = _type createVehicle (_wp_array select _i);
	if (_kind == 2) then {
		#ifdef __ACE__
		[objNull,objNull,objNull,objNull,"SmokeShell",_shell] spawn ace_viewblock_fired;
		#endif
		#ifndef __ACE__
		if (d_found_DMSmokeGrenadeVB) then {
			[_shell] spawn X_DM_SMOKE_SHELL;
		};
		#endif
	};
	_xo = ceil random 10;
	 sleep (0.923 + (_xo / 10));
};

_wp_array = nil;

if (true) exitWith {};
