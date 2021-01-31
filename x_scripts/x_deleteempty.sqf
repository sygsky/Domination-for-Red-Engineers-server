// by Xeno, x_scripts\x_deleteempty.sqf
private ["_index","_no","_pos","_radius","_target","_vecs","_vehicle"];
if (!isServer) exitWith{};

_index = _this select 0;

if (current_target_index < 0) then {
	hint localize format["--- x_deleteempty.sqf: current_target_index = %1", current_target_index];
	for "_i" from 1 to 60 do {
		sleep 1;
		if (current_target_index >= 0 ) exitWith {
			hint localize format["+++ x_deleteempty.sqf: after waiting %1 second[s] current_target_index = %2", _i, current_target_index]
		};
	};
	if (current_target_index < 0 ) then {
		hint localize format["--- x_deleteempty.sqf: after waiting 60 seconds current_target_index = %1", current_target_index]
	};
};

// if (_index < 0) then { hint localize format["--- x_deleteempty.sqf: [_index = %1]",_index]}; // debug printing

_target = target_names select _index;
_pos = _target select 0;
_radius = _target select 2;
_rnd = 1500 + (random 300);
hint localize format["+++ x_deleteempty.sqf: sleep %1 secs in %2", round (_rnd), _target select 1]; // debug printing
sleep _rnd;

_vecs = [];
switch (d_enemy_side) do {
	case "EAST" : {{_vecs = _vecs + _x;} forEach d_veh_a_E};
	case "WEST" : {{_vecs = _vecs + _x;} forEach d_veh_a_W};
	case "RACS" : {{_vecs = _vecs + _x;} forEach d_veh_a_G};
};

_no = nearestObjects [_pos, _vecs, _radius];

{
	_vehicle = _x;
	if (({alive _x} count (crew _vehicle)) == 0) then {
		{deleteVehicle _x; sleep 3.321 } forEach [_vehicle] + (crew _vehicle);
	};
} forEach _no;
hint localize format["+++ x_deleteempty.sqf: deleted %1 veh[s] in %2", count _no, _target select 1]; // debug printing
_no = nil;

if (true) exitWith {};
