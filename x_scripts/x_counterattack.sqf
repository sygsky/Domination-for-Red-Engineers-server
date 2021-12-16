// by Xeno, x_scripts\x_counterattack.sqf
if (!isServer) exitWith {};

#include "x_setup.sqf"

private ["_current_target_pos","_current_target_radius","_dummy","_number_basic","_number_bmp","_number_specops",
		 "_number_tank","_start_array","_type_list_attack","_typeidx","_xx","_numbervecs","_vehs_counter_attack",
	     "_outer_size","_counter_pos","_counter_rad"];

_dummy = target_names select current_target_index;
_current_target_pos = _dummy select 0;
_current_target_radius = _dummy select 2;
_outer_size = 200;

// TODO: counterattack on Paraiso should not start on base territory only!
_counter_pos = _current_target_pos;
_counter_rad = _current_target_radius + _outer_size;
#ifdef __DEFAULT__
switch (_dummy select 1 ) do { // change start pos for some special targets
	case "Paraiso": {
		_counter_pos = [[10299,8954,0],[11261,9341,0]] call XfRandomArrayVal;
		_counter_rad = 100;
	};
	case "Rahmadi": {
		_counter_pos = [[2498,2679,0],[3202,2259,0],[3308,2584,0]]  call XfRandomArrayVal;
		_counter_rad = 100;
	};
	case "Everon": {
		_counter_pos = [16476,9035,0];
		_counter_rad = 100;
	};
	case "Hunapu" : {
		_counter_pos = [[7524,15536,0],[8318,15667,0]] call XfRandomArrayVal;
		_counter_rad = 50;
	};
};
#endif
_start_array = [_counter_pos, _counter_rad] call x_getwparray2;

_vehs_counter_attack =  2 + ceil (random 2); // 2..4

// generate different type of vehicles group sizes
_number_basic = ceil (random _vehs_counter_attack); // 4..1
_number_specops = ceil (random _vehs_counter_attack); // 4..1
_number_tank = ceil (random (_vehs_counter_attack - 1)); // 3..1
_number_bmp = ceil (random (_vehs_counter_attack - 1)); // 3..1

_numbervecs = (_vehs_counter_attack - 2) max 1; // 2..1

_type_list_attack = [["basic",0],["specops",0],["tank",(ceil random _numbervecs)],["bmp",(ceil random _numbervecs)]];

sleep (120 + random 120);

["an_countera", "start_real"] call XSendNetStartScriptClient;

_basic_num = 0;
_specops_num = 0;
_tank_num = 0;
_bmp_num = 0;

for "_xx" from 0 to (count _type_list_attack - 1) do {
	_typeidx = _type_list_attack select _xx;
	switch (_typeidx select 0) do {
		case "basic" : {
			_basic_num = (_typeidx select 1) *_number_basic;
		};
		case "specops":  {
			_specops_num = (_typeidx select 1) * _number_specops;
		};
		case "tank":  {
			_tank_num = (_typeidx select 1) * _number_tank;
		};
		case "bmp":  {
			_bmp_num = (_typeidx select 1) * _number_bmp;
		};
	};
	call compile format["if (_number_%1 > 0) then {for ""_i"" from 1 to _number_%1 do {[_typeidx select 0, _start_array, _current_target_pos, _typeidx select 1, ""attack"",d_enemy_side,0,-1.111] execVM ""x_scripts\x_makegroup.sqf"";sleep 5.123;};};",_typeidx select 0];
};
hint localize format["*** x_counterattack.sqf: target ""%1"", basic  %2,  specops %3, tank %4, bmp %5", _dummy select 1, _basic_num, _specops_num, _tank_num, _bmp_num];

_start_array = nil;
_type_list_attack = nil;

sleep 301.122;
current_trigger = createTrigger["EmptyDetector",_current_target_pos];
current_trigger setTriggerArea [(_current_target_radius max 300) + 50, (_current_target_radius max 300) + 50, 0, false];
current_trigger setTriggerActivation [d_enemy_side, "PRESENT", false];
current_trigger setTriggerStatements["(""Tank"" countType thislist  <= 0) && (""Man"" countType thislist < 4)", "counterattack = false;deleteVehicle current_trigger", ""];

_current_target_pos = nil;

if (true) exitWith {};
