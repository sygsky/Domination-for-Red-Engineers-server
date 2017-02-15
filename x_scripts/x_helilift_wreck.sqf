// by Xeno. x_helilift_wreck.sqf
private ["_id","_menu_lift_shown","_nearest","_nearest_pos","_npos","_nx","_ny","_p_x","_p_y","_p_z","_pos","_posi","_px","_py","_release_id","_vehicle"];

if (!X_Client) exitWith {};

_vehicle = _this select 0;

Attached_Vec = objNull;
Vehicle_Attached = false;
Vehicle_Released = false;
_menu_lift_shown = false;
_nearest = objNull;
_id = -1;

sleep 10.123;

while {(alive _vehicle) && (alive player) && player_is_driver} do {
	if ((driver _vehicle) == player) then {
		_pos = getPos _vehicle;

		if (!Vehicle_Attached && /* (_pos select 2 > 2.5) && */ (_pos select 2 < 100)) then {
			_nearest = objNull;
			_nobjects = nearestObjects [_vehicle, ["LandVehicle","Air","Ship"],100]; //+++ Sygsky: changed search dist from 70 to 100 m
			if (count _nobjects > 0) then {
				_dummy = _nobjects select 0;
				if (_dummy == _vehicle) then {
					if (count _nobjects > 1) then {
						_nearest = _nobjects select 1;
					};
				} else {
					_nearest = _dummy;
				};
			};
			sleep 0.1;
			if (!(isNull _nearest) && _nearest != Attached_Vec && (damage _nearest >= 1) && ((typeOf _nearest) in x_heli_wreck_lift_types)) then {
				_nearest_pos = getPos _nearest;
				_nx = _nearest_pos select 0;_ny = _nearest_pos select 1;_px = _pos select 0;_py = _pos select 1;
//				if ((_px <= _nx + 10 && _px >= _nx - 10) && (_py <= _ny + 10 && _py >= _ny - 10)) then {
				if ( ((abs(_px - _nx)) < 10) && (abs(_py - _ny) < 10) ) then {
					if (!_menu_lift_shown) then {
						_id = _vehicle addAction [localize "STR_SYS_35"/* "ПОДНЯТЬ ТЕХНИКУ" */, "x_scripts\x_heli_action.sqf",-1,100000];
						_menu_lift_shown = true;
					};
				} else {
					_nearest = objNull;
					if (_menu_lift_shown) then {
						_vehicle removeAction _id;
						_menu_lift_shown = false;
					};
				};
			};
		} else {
			if (_menu_lift_shown) then {
				_vehicle removeAction _id;
				_menu_lift_shown = false;
			};

			sleep 0.1;

			if (isNull _nearest) then {
				Vehicle_Attached = false;
				Vehicle_Released = false;
			} else {
				if (Vehicle_Attached) then {
					_release_id = _vehicle addAction [localize "STR_SYS_36"/* "СБРОСИТЬ ТЕХНИКУ" */, "x_scripts\x_heli_release.sqf",-1,100000];
					[_vehicle, localize "STR_SYS_37"/* "Техника поднята вертолётом..." */] call XfVehicleChat;
					Attached_Vec = _nearest;

					_height = 15;
					while {true} do {
						_vup = vectorUp _vehicle;
						_vdir = vectorDir _vehicle;
						_voffset = (speed _vehicle min 50) / 3.57;
						_fheight = _height + (2.5 min (_vehicle modelToWorld [0,-1-_voffset,-_height] select 2));
						_nearest setPos (_vehicle modelToWorld [0,-1-_voffset,-_fheight]);
						_nearest setVectorDir _vdir;
						_nearest setVectorUp  _vup;
						_nearest setVelocity [0,0,0];
						if (!alive _vehicle) exitWith {};
						if (!player_is_driver) exitWith {};
						if (isNull _nearest) exitWith {};
						if (!alive player) exitWith {};
						if (Vehicle_Released) exitWith {};
						sleep 0.001;
					};

					Vehicle_Attached = false;
					Vehicle_Released = false;

					Attached_Vec = objNull;

					if (!alive _nearest || !alive _vehicle) then {
						_vehicle removeAction _release_id;
					} else {
						[_vehicle, localize "STR_SYS_39"/* "Техника сброшена..." */] call XfVehicleChat;
					};

					if (!(_nearest isKindOf "StaticWeapon") && (position _nearest) select 2 < 200) then {
						waitUntil {(position _nearest) select 2 < 10};
					};

					_npos = position _nearest;
					_nearest setPos [_npos select 0, _npos select 1, 0];
					_nearest setVelocity [0,0,0];

					sleep 1.012;
				};
			};
		};
	};
	sleep 0.51;
};

if (!(alive _vehicle) || !(alive player)) then {
	player_is_driver = false;
	_vehicle removeAction vec_id;
};

if (true) exitWith {};