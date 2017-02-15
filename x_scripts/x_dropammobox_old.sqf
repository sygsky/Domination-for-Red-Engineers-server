// by Xeno
private ["_unit", "_caller", "_vehicle", "_s", "_height", "_speed", "_time", "_the_box", "_box", "_box_pos", "_boxscript"];

if (!X_Client) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

_unit = _this select 0;
_caller = _this select 1;

if (_caller != driver _unit) exitWith {};
_vehicle = vehicle _caller;
if (ammo_boxes >= max_number_ammoboxes) exitWith {
	_s = format ["Создано максимальное (%1) кол-во ящиков!", max_number_ammoboxes];
	_unit vehicleChat _s;
	_unit vehicleChat "Подождите пока один или более ящиков не будет автоматически удалён...";
};
_height = (position _unit) select 2;
if (_height > 3) exitWith {_unit vehicleChat "Слишком высоко для выгрузки ящика!!!"};
_speed = speed _unit;
if (_speed > 3) exitWith {_unit vehicleChat "Транспорт движется, остановитесь для начала выгрузки!"};
_time = time;
if (_time - last_ammo_drop < d_drop_ammobox_time) exitWith {
	_unit vehicleChat format ["Ожидайте %1 сек. до новой выгрузки!",d_drop_ammobox_time];
};
last_ammo_drop = _time;

#ifndef __TT__
_the_box = (
	switch (d_own_side) do {
		case "RACS": {"WeaponBoxGuer"};
		case "EAST": {"WeaponBoxEast"};
		case "WEST": {"WeaponBoxWest"};
	}
);
#endif
#ifdef __TT__
_the_box = (
	if (playerSide == west) then {
		"WeaponBoxWest"
	} else {
		"WeaponBoxGuer"
	}
);
#endif

_box = _the_box createVehicleLocal (position _unit);
_box_pos = position _box;

#ifdef __RANKED__
_boxscript = (
		if (__CSLAVer) then {
			"x_scripts\x_weaponcargor_csla.sqf"
	} else {
		if (__ACEVer) then {
			"x_scripts\x_weaponcargor_ace.sqf"
		} else {
			if (__P85Ver) then {
				"x_scripts\x_weaponcargor_p85.sqf"
			} else {
				"x_scripts\x_weaponcargor.sqf"
			}
		}
	}
);
#else
_boxscript = (
	if (__CSLAVer) then {
		"x_scripts\x_weaponcargo_csla.sqf"
	} else {
		if (__ACEVer) then {
			"x_scripts\x_weaponcargo_ace.sqf"
		} else {
			if (__P85Ver) then {
				"x_scripts\x_weaponcargo_p85.sqf"
			} else {
				"x_scripts\x_weaponcargo.sqf"
			}
		}
	}
);
#endif
[_box] execVM _boxscript;

_box addEventHandler ["killed",{["d_rem_box",position (_this select 0)] call XSendNetStartScriptServer;deleteVehicle (_this select 0)}];
["d_create_box",_vehicle, _box_pos] call XSendNetStartScriptAllDiff;

_unit vehicleChat "Ящик создан!!!";

if (true) exitWith {};
