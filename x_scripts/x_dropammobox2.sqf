// by Xeno
private ["_unit", "_caller", "_s", "_hasbox", "_time_next", "_height", "_speed", "_the_box", "_box"];

if (!X_Client) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

_unit = _this select 0;
_caller = _this select 1;

if (_caller != driver _unit) exitWith {};

_unit = vehicle _caller;

if (_unit distance AMMOLOAD < 20) exitWith {
	[_unit,localize "STR_SYS_1103"/*"Вы не можете выгрузить ящик возле склада снабжения."*/] call XfVehicleChat;
};
#ifdef __TT__
if (_unit distance AMMOLOAD2 < 20) exitWith {
	[_unit,localize "STR_SYS_1103"/*"Вы не можете выгрузить ящик возле склада снабжения."*/] call XfVehicleChat;
};
#endif

_height = _unit call XfGetHeight;
if (_height > 3) exitWith {
	[_unit,localize "STR_SYS_1104"/*"Слишком высоко! Опуститесь ниже..."*/] call XfVehicleChat;
};
_speed = speed _unit;
if (_speed > 3) exitWith {
	[_unit, localize "STR_SYS_1105"/*"Транспорт движется! Разгрузка невозможна..."*/] call XfVehicleChat;
};

if (ammo_boxes >= max_number_ammoboxes) exitWith {
	_s = format [ localize "STR_SYS_1106"/*"Достигнуто максимальное:(%1) кол-во ящиков снабжения!!!"*/, max_number_ammoboxes];
	[_unit,_s] call XfVehicleChat;
	[_unit, localize "STR_SYS_1107"/*"Загрузка ящика снабжения..."*/] call XfVehicleChat;
};

_hasbox = _unit getVariable "d_ammobox";
if (format["%1",_hasbox] == "<null>") then {
	_hasbox = false;
};
if (!_hasbox) exitWith {
	[_unit, localize "STR_SYS_1108"/*"Ящик не загружен..."*/] call XfVehicleChat;
};

_time_next = _unit getVariable "d_ammobox_next";
if (format["%1",_time_next] == "<null>") then {
	_time_next = -1;
};
if (_time_next > time) exitWith {
	[_unit, format [localize "STR_SYS_1109"/*"Не доступно! Ожидайте %1 сек..."*/,round (_time_next - time)]] call XfVehicleChat;
};

[_unit, localize "STR_SYS_1110"/*"Ящик выгружен рядом с транспортом..."*/] call XfVehicleChat;

_unit setVariable ["d_ammobox", false];
_time_next = time + 240;
_unit setVariable ["d_ammobox_next", _time_next];
["d_ammo_vec", _unit, false, _time_next] call XSendNetStartScriptAll;

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
["d_create_box",_box_pos] call XSendNetStartScriptAllDiff;

[_unit, localize "STR_SYS_1111"/*"Ящик выгружен..."*/] call XfVehicleChat;

if (true) exitWith {};