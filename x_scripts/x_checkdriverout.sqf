// by Xeno
private ["_vehicle","_position","_enterer"];

#include "x_setup.sqf"

#ifdef __MANDO__
_vehicle = _this select 0;
_position = _this select 1;
_enterer = _this select 2;

if (_enterer == player) then {
	// if (vec2_id != -1000) then {
		// _vehicle removeAction vec2_id;
		// vec2_id = -1000;
	// };
	// if (vec3_id != -1000) then {
		// _vehicle removeAction vec3_id;
		// vec3_id = -1000;
	// };
	if (vec_mando_id != -1000) then {
		_vehicle removeAction vec_mando_id;
		vec_mando_id = -1000;
	};
};
#endif

if (true) exitWith {};
