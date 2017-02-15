// by Xeno
private ["_unit", "_caller", "_hasbox", "_time_next", "_height", "_speed", "_the_box", "_nobjs", "_box"];

if (!X_Client) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

_unit = _this select 0;
_caller = _this select 1;

if (_caller != driver _unit) exitWith {};

_unit = vehicle _caller;

_height = _unit call XfGetHeight;
if (_height > 3) exitWith {
	[_unit,"Слишком высоко! Опуститесь ниже..."] call XfVehicleChat;
};
_speed = speed _unit;
if (_speed > 3) exitWith {
	[_unit,"Транспорт движется! Загрузка невозможна..."] call XfVehicleChat;
};

_hasbox = _unit getVariable "d_ammobox";
if (format["%1",_hasbox] == "<null>") then {
	_hasbox = false;
};
if (_hasbox) exitWith {
	[_unit, "Все готово к загрузке..."] call XfVehicleChat;
};

_time_next = _unit getVariable "d_ammobox_next";
if (format["%1",_time_next] == "<null>") then {
	_time_next = -1;
};
if (_time_next > time) exitWith {
	[_unit, format ["Загрузка будет вновь доступна через %1 сек.",round (_time_next - time)]] call XfVehicleChat;
};

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

_nobjs = nearestObjects [_unit, [_the_box], 20];
if (count _nobjs == 0) exitWith {
	[_unit,"Нет доступных к загрузке ящиков!!!"] call XfVehicleChat;
};
_box = _nobjs select 0;
[_unit,"Идёт загрузка..."] call XfVehicleChat;
["d_rem_box",position _box] call XSendNetStartScriptAllDiff;
deleteVehicle _box;
_unit setVariable ["d_ammobox", true];
_time_next = time + 240;
_unit setVariable ["d_ammobox_next", _time_next];
["d_ammo_vec", _unit, true, _time_next] call XSendNetStartScriptAll;

[_unit, "Ящик загружен!!!"] call XfVehicleChat;

if (true) exitWith {};