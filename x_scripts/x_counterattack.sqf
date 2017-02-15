// by Xeno
private ["_current_target_pos","_current_target_radius","_dummy","_number_basic","_number_bmp","_number_specops","_number_tank","_start_array","_type_list_attack","_typeidx","_xx","_numbervecs","_vecs_counter_attack"];
if (!isServer) exitWith {};

_dummy = target_names select current_target_index;
_current_target_pos = _dummy select 0;
_current_target_radius = _dummy select 2;

_start_array = [_current_target_pos, _current_target_radius + 200] call x_getwparray2;

_vecs_counter_attack = (5 call XfRandomFloor) max 2;

_number_basic = ceil (random _vecs_counter_attack);
_number_specops = ceil (random _vecs_counter_attack);
_number_tank = ceil (random (_vecs_counter_attack - 1));
_number_bmp = ceil (random (_vecs_counter_attack - 1));

_numbervecs = (_vecs_counter_attack - 2) max 1;

_type_list_attack = [["basic",0],["specops",0],["tank",(ceil random _numbervecs)],["bmp",(ceil random _numbervecs)]];

sleep 120 + random 120;

["an_countera", "start_real"] call XSendNetStartScriptClient;

for "_xx" from 0 to (count _type_list_attack - 1) do {
	_typeidx = _type_list_attack select _xx;
	call compile format["if (_number_%1 > 0) then {for ""_i"" from 1 to _number_%1 do {[_typeidx select 0, _start_array, _current_target_pos, _typeidx select 1, ""attack"",d_enemy_side,0,-1.111] execVM ""x_scripts\x_makegroup.sqf"";sleep 5.123;};};",_typeidx select 0];
};

_start_array = nil;
_type_list_attack = nil;

sleep 301.122;
current_trigger = createTrigger["EmptyDetector",_current_target_pos];
current_trigger setTriggerArea [(_current_target_radius max 300) + 50, (_current_target_radius max 300) + 50, 0, false];
current_trigger setTriggerActivation [d_enemy_side, "PRESENT", false];
current_trigger setTriggerStatements["(""Tank"" countType thislist  < 2) && (""Man"" countType thislist < 6)", "counterattack = false;deleteVehicle current_trigger", ""];

_current_target_pos = nil;

if (true) exitWith {};
