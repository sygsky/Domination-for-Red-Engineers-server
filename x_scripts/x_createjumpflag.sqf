// by Xeno
private ["_dummy", "_current_target_pos", "_radius", "_posi", "_ftype", "_flag"];
if (!isServer) exitWith {};

_dummy = target_names select current_target_index;
_current_target_pos = _dummy select 0;
_radius = _dummy select 2;

// create random position
_posi = [_current_target_pos, _radius] call XfGetRanPointCircle;
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
	if (d_own_side == "EAST") then //+++Sygsky: add more fun with flags
	{
		_flag setFlagTexture "\ca\misc\data\rus_vlajka.pac"; // set USSR flag
	};
	["new_jump_flag",_flag] call XSendNetStartScriptClient;
};

if (true) exitWith {};
