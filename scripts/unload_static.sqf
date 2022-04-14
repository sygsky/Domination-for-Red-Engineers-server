//////////////////////////////////////////////////////////////////
// Function file for Armed Assault
// Created by: -eutf-Myke
//////////////////////////////////////////////////////////////////

#include "x_setup.sqf"

_vehicle = _this select 0;
_engineer = _this select 1;
#ifdef __NO_REAMMO_IN_SALVAGE__
_cargo = objNull;
#else
_cargo = "";
#endif
_do_exit = false;

cargo_selected_index = -1;

scopeName "unload_static_scope";

#ifndef __ACE__
_str_p = format ["%1", _engineer];
if (!(_str_p in d_is_engineer)) then {hint (localize "STR_SYS_530"); breakOut "unload_static_scope";}; // "Only engineers can place static weapons"
#endif

if (driver _vehicle == _engineer) exitWith {hint (localize "STR_SYS_531")}; // "You have to get out before you can place the static weapon!"

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
	hint (localize "STR_SYS_532"); // "No static weapon loaded..."
};

waitUntil {cargo_selected_index != -1 || !dialog || !alive player};

if (!alive player) exitWith {
	closeDialog 11099;
};

if (cargo_selected_index == -1) exitWith {(localize "STR_SYS_533") call XfGlobalChat}; // "Unload canceled"

call compile format ["
	if ((cargo_selected_index + 1) > count truck%1_cargo_array) exitWith {
		hint (localize ""STR_SYS_534"");
	};
", current_truck_cargo_array]; // STR_SYS_534,"Someone else unloaded already an item. Try again."

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

hint localize format["++++ unload_static.sqf: cargo %1, damage %2, found at %3", typeOf _cargo, damage _cargo, getPos _cargo];

_pos_to_set = _engineer modelToWorld [0,5,0];

#ifdef __NO_REAMMO_IN_SALVAGE__
_static = _cargo;
#else
_static = _cargo createVehicleLocal _pos_to_set;
#endif

_dir_to_set = getDir _engineer;

_place_error = false;
(localize "STR_SYS_535") call XfGlobalChat; // "Static placement preview mode. Press Place Static to place the object.
e_placing_running = 0; // 0 = running, 1 = placed, 2 = placing canceled
e_placing_id1 = player addAction [localize "STR_SYS_536", "x_scripts\x_cancelplacestatic.sqf"]; // "Cancel Placing Static"
e_placing_id2 = player addAction [localize "STR_SYS_537", "x_scripts\x_placestatic.sqf",[], 0]; // "Place Static"
while {e_placing_running == 0} do {
	_pos_to_set = _engineer modelToWorld [0,5,0];
	_dir_to_set = getDir _engineer;

	_static setDir _dir_to_set;
	_static setPos [_pos_to_set select 0, _pos_to_set select 1, 0];
	sleep 0.211;
	if (_vehicle distance _engineer > 20) exitWith {
		(localize "STR_SYS_538") call XfGlobalChat; // "You are too far away from the Salvage truck to place the static vehicle, placing canceled!"
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

#ifndef __NO_REAMMO_IN_SALVAGE__
deleteVehicle _static;
#endif

if (_place_error || (e_placing_running == 2)) exitWith {
	if (e_placing_running == 2) then { (localize "STR_SYS_539") call XfGlobalChat;};  // "Static placement canceled..."
	call compile format ["
		truck%1_cargo_array set[count truck%1_cargo_array, _cargo];
		[""truck%1_cargo_array"",truck%1_cargo_array] call XSendNetVarAll;
	", current_truck_cargo_array];
};

#ifdef __NO_REAMMO_IN_SALVAGE__
_type_name = [typeOf _cargo,0] call XfGetDisplayName;
#else
_type_name = [_cargo,0] call XfGetDisplayName;
#endif

//for "_i" from 10 to 1 step -1 do {
//	hint format ["%1 will be placed in %2 sec.", _type_name, _i];
//	sleep 1;
//};
#ifdef __NO_REAMMO_IN_SALVAGE__
_static = _cargo;
#else
_static = _cargo createVehicle _pos_to_set;
#endif

_static setDir _dir_to_set;
_static setPos [_pos_to_set select 0, _pos_to_set select 1, 0];
["say_sound", _static, "return"] call XSendNetStartScriptClientAll;

_str = format [localize "STR_SYS_540", _type_name]; // "%1 placed!"
hint _str;
_str call XfGlobalChat;
