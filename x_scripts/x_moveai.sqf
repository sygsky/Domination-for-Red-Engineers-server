// by Xeno
private ["_grp_player","_units_player"];
_grp_player = group player;
_units_player = units _grp_player;
if (({alive _x} count _units_player) > 0) then {
	_units_formation = formationMembers player;
	if (count _this == 0) then {
		_pos_p = position player;
		_pos_p = [_pos_p select 0, _pos_p select 1, 0];
		{
			if (!isPlayer _x && vehicle _x == _x && _x distance _pos_p > 500) then {
				_x setPos _pos_p;
			};
		} forEach _units_formation;
	} else {
		_pos_p = _this select 0;
		_veloc = _this select 1;
		_dir = _this select 2;
		_parachute = (
			switch (d_own_side) do {
				case "RACS": {"ParachuteG"};
				case "WEST": {"ParachuteWest"};
				case "EAST": {"ParachuteEast"};
			}
		);
		{
			if (!isPlayer _x && vehicle _x == _x && _x distance _pos_p > 500) then {
				_obj_para = _parachute createVehicle[ 0,0,0 ];
				_obj_para setPos _pos_p;
				_obj_para setDir _dir;
				_obj_para setVelocity _veloc;
				_x moveInDriver _obj_para;
				[_x] spawn {
					_unit = _this select 0;
					sleep 0.8321;
					waitUntil {sleep 0.111;(vehicle _unit == _unit || !alive _unit)};
					if (alive _unit) then {
						if (position _unit select 2 > 1) then {
							_unit setPos [position _unit select 0,position _unit select 1, 0];
						};
					};
				};
			};
		} forEach _units_formation;
	};
};

if (true) exitWith {};
