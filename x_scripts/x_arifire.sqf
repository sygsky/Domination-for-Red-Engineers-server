// x_scripts\x_arifire.sqf, by Xeno
private ["_arti_operator", "_height", "_type", "_radius", "_number_shells", "_arix", "_ariy", "_ang", "_posf", "_posb", "_posl", "_posr", "_center_x", "_center_y", "_arti_distance", "_travel_time", "_first_run", "_enemy_units", "_points_p", "_series", "_wp_array", "_x1", "_y1", "_angle", "_strenght", "_i", "_j", "_soldier_type", "_uuu", "_shell", "_xo", "_pos", "_pod", "_helper_bomb", "_remove_them", "_ari_salvos"];
if (!isServer) exitWith {};

#include "x_setup.sqf"

if (!ari_available) exitWith {};

_arti_operator = _this;

_height = 0;
_type = "";
_radius = 30;
_number_shells = 1;

ari_available = false;
["ari_available",ari_available] call XSendNetStartScriptClient;

switch (ari_type) do {
	case "flare": {
		_number_shells = 18;
#ifdef __ACE__
        _height = 450;
        _type = "ACE_Flare_Arty_White";
#else
        _height = 350;
        _type = "F_40mm_White";
#endif
        _radius = 300;
        _arix = getPos AriTarget select 0;
        _ariy = getPos AriTarget select 1;
        call compile format ["_ang = (_arix - (getPos %1 select 0)) atan2 (_ariy - (getPos %1 select 1));", _arti_operator];
        if(abs _ang != _ang) then {angle = _ang + 360};
        _posf = [_arix + _radius * sin(_ang), _ariy + _radius * cos(_ang)]; //in front range
        _posb = [_arix - _radius * sin(_ang), _ariy - _radius * cos(_ang)]; //behind range
        _posl = [_arix + _radius * sin(_ang-90), _ariy + _radius * cos(_ang-90)]; //left lateral
        _posr = [_arix + _radius * sin(_ang+90), _ariy + _radius * cos(_ang+90)]; //right lateral
	};
	case "he": {
		_number_shells = 6;
		_height = 150;
		_type = (if (d_enemy_side == "EAST") then {"Sh_125_HE"} else {"Sh_120_HE"});
	};
	case "smoke": {
#ifndef __ACE__
		_number_shells = 10;
#endif
#ifdef __ACE__
		_number_shells = 3;
#endif
		_height = 150;
		_type = "Smokeshell";
	};
	case "dpicm": {
		_number_shells = 40;
		_height = 150;
		_type = (if (d_enemy_side == "EAST") then {"G_30mm_HE"} else {"G_40mm_HE"});
		_radius = 100;
	};
};

sleep (12.25 + (random 7));

if (ari_type != "flare") then {
    _center_x = getPos AriTarget select 0;
    _center_y = getPos AriTarget select 1;
};

#ifndef __TT__
_arti_distance = FLAG_BASE distance [position AriTarget select 0,position AriTarget select 1,0];
#endif
#ifdef __TT__
_arti_distance = WFLAG_BASE distance [position AriTarget select 0,position AriTarget select 1,0];
#endif
_travel_time = _arti_distance / 500;
_first_run = true;

_enemy_units = [];
_points_p = 0;

for "_series" from 1 to ari_salvos do {
	_wp_array = [];
	while {count _wp_array < _number_shells} do {	
		if (ari_type == "flare") then {
			{
				_x1 = (_x select 0) - 20 + random 40; // No need for circular randomness
				_y1 = (_x select 1) - 20 + random 40;
				_wp_array = _wp_array + [[_x1, _y1, _height + random 10]];
				sleep 0.0153;
			} forEach [_posf, _posb, _posl, _posr];
		} else {
			_angle = floor random 360;
			_randrad = _radius call XfRndRadious; // correct random distribution
			_x1 = _center_x - (_randrad * sin _angle);
			_y1 = _center_y - (_randrad * cos _angle);
			_wp_array = _wp_array + [[_x1, _y1, (if (ari_type == "he") then {_height + random 50} else {_height})]];
			sleep 0.0153; // 0.2
		};
	};
	
	["ari1msg",0,_series] call XSendNetStartScriptClient;
	
	sleep _travel_time;
	["ari1msg",1,_series,0] call XSendNetStartScriptClient;
	
	switch (ari_type) do {
		case "flare": {
			sleep 1;
			_strenght = 8; // Use this until we get flares with proper arty brightness. Maybe ACE can provide such flares for this use?
			for "_i" from 0 to (_number_shells-1) do {
				for "_j" from 0 to (_strenght-1) do {
					_type createVehicle [(_wp_array select _i) select 0, (_wp_array select _i) select 1, ((_wp_array select _i) select 2)-_j/100];
					sleep 0.002;
				};
				if (((_i+1) % 4 == 0) && (_i > 1)) then {sleep (18 + (ceil random 5))} else {sleep (0.5 + (random 1.5))};
			};
		};
		case "he": {
			_soldier_type = switch (d_enemy_side) do {
				case "EAST": {"SoldierEB"};
				case "WEST": {"SoldierWB"};
			};
			_enemy_units = nearestObjects [[position AriTarget select 0,position AriTarget select 1,0] ,[_soldier_type],_radius];
			for "_i" from 0 to (count _enemy_units - 1) do {
				_uuu = _enemy_units select _i;
				if (!alive _uuu) then {_enemy_units set [_i, "X_RM_ME"]};
			};
			_enemy_units = _enemy_units - ["X_RM_ME"];
			for "_i" from 0 to (_number_shells - 1) do {
				_type createVehicle (_wp_array select _i);
				sleep (0.923 + (random 2));
			};
		};
		case "smoke": {
			for "_i" from 0 to (_number_shells - 1) do {
				_shell = _type createVehicle (_wp_array select _i);
				#ifdef __ACE__
				[objNull,objNull,objNull,objNull,"SmokeShell",_shell] spawn ace_viewblock_fired;
				#endif
				#ifndef __ACE__
				if (d_found_DMSmokeGrenadeVB) then {
					[_shell] spawn X_DM_SMOKE_SHELL;
				};
				#endif
				_xo = ceil random 10;
				sleep (0.923 + (_xo / 10));
			};
		};
		case "dpicm": {
			_soldier_type = switch (d_enemy_side) do {
				case "EAST": {"SoldierEB"};
				case "WEST": {"SoldierWB"};
			};
			_enemy_units = nearestObjects [[position AriTarget select 0,position AriTarget select 1,0] ,[_soldier_type],_radius];
			for "_i" from 0 to (count _enemy_units - 1) do {
				_uuu = _enemy_units select _i;
				if (!alive _uuu) then {_enemy_units set [_i, "X_RM_ME"]};
			};
			_enemy_units = _enemy_units - ["X_RM_ME"];
			_pos = [(position AriTarget) select 0, (position AriTarget) select 1, _height];
			_pod = "Bomb" createVehicle _pos;
			_pod setPos _pos;
			_helper_bomb = "M_Ch29_AT" createVehicle _pos;
			sleep 0.5;
			deleteVehicle _helper_bomb;
			for "_i" from 0 to (_number_shells - 1) do {
				_type createVehicle (_wp_array select _i);
				_xo = ceil random 10;
				sleep (0.223 + (_xo / 10));
			};
			sleep 2.132;
			deleteVehicle _pod;
		};
	};
	_wp_array = nil;
	
	if (_first_run) then {
		_first_run = false;
		ari_type spawn {
			if (_this in ["flare","he"]) then {
				sleep 2.123;
				AriTarget execVM "x_scripts\x_arihit.sqf";
			};
		};
	};
		
	if (_series < ari_salvos) then {
		["ari1msg",2] call XSendNetStartScriptClient;
		sleep d_arti_reload_time + random 7;
		_remove_them = [];
		{
			if (!alive _x) then {_points_p = _points_p + 1;_remove_them set[count _remove_them,_x]};
		} forEach _enemy_units;
		_enemy_units = _enemy_units - _remove_them;
	};
};

sleep 2;

{
	if (!alive _x) then {_points_p = _points_p + 1};
} forEach _enemy_units;
["d_parti_add",_arti_operator,_points_p] call XSendNetStartScriptClient;
_enemy_units = nil;
sleep 0.5;

["ari1msg",3] call XSendNetStartScriptClient;

ari_salvos spawn {
	private ["_ari_salvos"];
	_ari_salvos = _this;
	sleep (d_arti_available_time + ((_ari_salvos - 1) * 200)) + (random 60);
	ari_available = true;
	["ari_available",ari_available] call XSendNetStartScriptClient;
};

if (true) exitWith {};
