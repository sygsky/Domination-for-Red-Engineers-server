//////////////////////////////////////////////////////////////////
// Function file for Armed Assault
// Created by: -eutf-Myke
//////////////////////////////////////////////////////////////////

#include "x_setup.sqf"

_vehicle = _this select 0;
_engineer = _this select 1;
_cargo = "";
_do_exit = false;

cargo_selected_index = -1;

scopeName "unload_static_scope";

#ifndef __ACE__
_str_p = format ["%1", _engineer];
if (!(_str_p in d_is_engineer)) then {hint "Выгружать орудия может только инженер!";breakOut "unload_static_scope";};
#endif

if (driver _vehicle == _engineer) exitWith {hint "Для выгрузки орудия вам необходимо выйти из грузовика!"};

switch (_vehicle) do {
	case TR7: {
		if (count truck1_cargo_array > 0) then {
			current_truck_cargo_array = 1;
			_ok = createDialog "XD_UnloadDialog";
		} else {
			_do_exit = true;
		};
	};
	case TR8: {
		if (count truck2_cargo_array > 0) then {
			current_truck_cargo_array = 2;
			_ok = createDialog "XD_UnloadDialog";
		} else {
			_do_exit = true;
		};
	};
};

if (_do_exit) exitWith {
	hint "Орудие не погружено...";
};

waitUntil {cargo_selected_index != -1 || !dialog || !alive player};

if (!alive player) exitWith {
	closeDialog 11099;
};

if (cargo_selected_index == -1) exitWith {"Unload canceled" call XfGlobalChat};

call compile format ["
	if ((cargo_selected_index + 1) > count truck%1_cargo_array) exitWith {
		hint ""Этот грузовик уже кто-то разгружает. Попробуйте еще раз."";
	};
", current_truck_cargo_array];

call compile format ["
	_cargo = truck%1_cargo_array select cargo_selected_index;
	for ""_i"" from 0 to (count truck%1_cargo_array - 1) do {
		_ele = truck%1_cargo_array select _i;
		if (_ele == _cargo) exitWith {
			truck%1_cargo_array set [_i, ""X_RM_ME""];
		};
	};
	truck%1_cargo_array = truck%1_cargo_array - [""X_RM_ME""];
	[""truck%1_cargo_array"",truck%1_cargo_array] call XSendNetVarAll;
", current_truck_cargo_array];

_pos_to_set = _engineer modeltoworld [0,5,0];
_static = _cargo createVehicleLocal _pos_to_set;
_static lock true;
_dir_to_set = getdir _engineer;

_place_error = false;
"Укажите место размещения орудия (не ближе 20 метров от грузовика)!" call XfGlobalChat;
e_placing_running = 0; // 0 = running, 1 = placed, 2 = placing canceled
e_placing_id1 = player addAction ["Cancel Placing Static", "x_scripts\x_cancelplacestatic.sqf"];
e_placing_id2 = player addAction ["Place Static", "x_scripts\x_placestatic.sqf",[], 0];
while {e_placing_running == 0} do {
	_pos_to_set = _engineer modeltoworld [0,5,0];
	_dir_to_set = getdir _engineer;

	_static setdir _dir_to_set;
	_static setPos [_pos_to_set select 0, _pos_to_set select 1, 0];
	sleep 0.211;
	if (_vehicle distance _engineer > 20) exitWith {
		"Вы далеко от грузовика! Подойдите ближе к нему и повторите!" call XfGlobalChat;
		_place_error = true;
	};
	if (!alive _engineer) exitWith {
		_place_error = true;
		if (e_placing_id1 != -1000) then {
			player removeAction e_placing_id1;
			e_placing_id1 = -1000;
		};
		if (e_placing_id2 != -1000) then {
			player removeAction e_placing_id2;
			e_placing_id2 = -1000;
		};
	};
};

deleteVehicle _static;

if (_place_error) exitWith {
	call compile format ["
		truck%1_cargo_array = truck%1_cargo_array + [_cargo];
		[""truck%1_cargo_array"",truck%1_cargo_array] call XSendNetVarAll;
	", current_truck_cargo_array];
};

if (e_placing_running == 2) exitWith {
	"Выгрузка отменена..." call XfGlobalChat;
	call compile format ["
		truck%1_cargo_array = truck%1_cargo_array + [_cargo];
		[""truck%1_cargo_array"",truck%1_cargo_array] call XSendNetVarAll;
	", current_truck_cargo_array];
};

_type_name = [_cargo,0] call XfGetDisplayName;

//for "_i" from 10 to 1 step -1 do {
//	hint format ["%1 will be placed in %2 sec.", _type_name, _i];
//	sleep 1;
//};

_static = _cargo createvehicle _pos_to_set;
_static setdir _dir_to_set;
_static setPos [_pos_to_set select 0, _pos_to_set select 1, 0];

hint format ["%1 placed!", _type_name];
format ["%1 placed!", _type_name] call XfGlobalChat;
