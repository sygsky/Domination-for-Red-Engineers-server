// by Xeno
private ["_index","_no","_pos","_radius","_target","_vecs","_vehicle"];
if (!isServer) exitWith{};

_index = _this select 0;

_target = target_names select _index;
_pos = _target select 0;
_radius = _target select 2;

sleep 1500 + (random 300);

_vecs = [];
switch (d_enemy_side) do {
	case "EAST" : {{_vecs = _vecs + _x;} forEach d_veh_a_E};
	case "WEST" : {{_vecs = _vecs + _x;} forEach d_veh_a_W};
	case "RACS" : {{_vecs = _vecs + _x;} forEach d_veh_a_G};
};

_no = nearestObjects [_pos, _vecs, _radius];

if (count _no > 0) then {
	{
		_vehicle = _x;
		if (({alive _x} count (crew _vehicle)) == 0) then {
			deleteVehicle _vehicle;
			sleep 3.321;
		};
	} forEach _no;
};

_no = nil;

if (true) exitWith {};
