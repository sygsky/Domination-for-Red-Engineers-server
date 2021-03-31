// by Xeno, x_scripts\x_createjumpflag.sqf - creates jump flag at designated point
//
// run as: _last_town_id execVM "x_scripts\x_createjumpflag.sqf";
//
//hint localize format[ "+++ DEBUG: x_createjumpflag.sqf: current_target_index = %1", _this ];

if (!isServer) exitWith {
	hint localize format[ "--- x_createjumpflag.sqf: !isServer", _this ];
};

private ["_dummy", "_current_target_pos", "_radius", "_posi", "_ftype", "_flag","_i"];

_dummy = target_names select _this;
_current_target_pos = _dummy select 0;
_radius = _dummy select 2;

hint localize format[ "+++ x_createjumpflag.sqf: target ""%1"", radius %2", _dummy select 1, _radius ];

// create random position
_posi = [];
while {count _posi == 0} do {
	_posi = [_current_target_pos, _radius] call XfGetRanPointCircle;
	sleep 0.04;
};
_current_target_pos = nil;

if (count _posi > 0) then {
	_ftype = (
		switch (d_own_side) do {
			case "EAST": {"FlagCarrierNorth"};
			case "WEST": {"FlagCarrierWest"};
			case "RACS": {"FlagCarrierSouth"};
		}
	);

	_flag = _ftype createVehicle _posi;
	jump_flags = jump_flags + [_flag];
	if (d_own_side == "EAST") then  { //+++Sygsky: add more fun with flags
		_flag setFlagTexture "\ca\misc\data\rus_vlajka.pac"; // set USSR flag
	};
	["new_jump_flag",_flag] call XSendNetStartScriptClient;
} else {
	hint localize "--- x_createjumpflag.sqf: position for jumpflag not found!";
};

if (true) exitWith {};
