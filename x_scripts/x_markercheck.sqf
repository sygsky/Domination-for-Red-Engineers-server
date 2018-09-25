// by Xeno, x_scripts\x_markercheck.sqf
// removes all placed objects, e.g. mash, MG_nest etc
private ["_pvar_name", "_i", "_ar", "_obj_name", "_obj_type", "_mkr_name", "_objs"];
if (!isServer) exitWith {};

_pvar_name = _this;

for "_i" from 0 to (count d_placed_objs - 1) do {
	_ar = d_placed_objs select _i;
	if (_pvar_name == (_ar select 0)) exitWith {
		_obj_name = "";
		_obj_type = "";
		switch (_ar select 2) do {
			case 0: {
				_obj_name = "Mash %1";
				_obj_type = "Mash";
			};
			case 1: {
				_obj_name = "MG Nest %1";
				_obj_type = d_mg_nest;
			};
		};
		_mkr_name = format [_obj_name, _pvar_name];
		deleteMarker _mkr_name;
		_objs = nearestObjects[(_ar select 1), [_obj_type], 5];
		if (count _objs > 0) then {
			deleteVehicle (_objs select 0);
		};
		d_placed_objs set [_i, "X_RM_ME"];
	};
};

d_placed_objs = d_placed_objs - ["X_RM_ME"];

if (true) exitWith {};
