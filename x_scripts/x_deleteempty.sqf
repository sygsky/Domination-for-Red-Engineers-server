// by Xeno, x_scripts\x_deleteempty.sqf
// removes only empty vehicles from the newly liberated town
//

if (!isServer) exitWith{};

// hint localize format["+++ x_deleteempty.sqf: _this  = %1", _this]; // debug printing

private ["_index","_no","_pos","_radius","_target","_vecs","_vehicle"];

_index = _this;

// if (_index < 0) then { hint localize format["--- x_deleteempty.sqf: [_index = %1]",_index]}; // debug printing

_target = target_names select _index;
_pos = _target select 0;
_radius = _target select 2;
_rnd = 1500 + (random 300);
// hint localize format["+++ x_deleteempty.sqf: sleep %1 secs in %2", round (_rnd), _target select 1]; // debug printing
sleep _rnd;

_vecs = []; // full list of enemy vehiсles
_side_vehs = switch (d_enemy_side) do { // array of arrays of enemy vehicle types
	case "EAST" : { d_veh_a_E  };
	case "WEST" : { d_veh_a_W };
	case "RACS" : { d_veh_a_G };
};

{ [_vecs, _x] call SYG_addArrayInPlace } forEach _side_vehs;

_no = nearestObjects [_pos, _vecs, _radius];

_cnt = 0;
{
	if (({alive _x} count (crew _x)) == 0) then {
		_cnt = _cnt +1;
		{deleteVehicle _x; sleep 3.321 } forEach (crew _x) + [_x];
	};
} forEach _no;
hint localize format["+++ x_deleteempty.sqf: deleted %1 veh[s] from %2 found (%3 types) in ""%4""", _cnt, count _no, count _vecs, _target select 1]; // debug printing
_no = nil;

if (true) exitWith {};
