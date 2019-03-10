// by Xeno, x_scripts\x_moveai.sqf, move  AI together with player, by parachute and by telepot
// +++ 06-МАР-2019: Sygsky  changes:
// AI is moved to player if 2D distance  is more them 500 m.
// AI is moved if player is leader of his group or is formation leader of his formation
// ---
private ["_grp_player","_units_player"];
_grp_player = group player;
_units_player = units _grp_player;
if (({alive _x} count _units_player) > 0) then {
	_units_formation = formationMembers player;
	if (count _this == 0) then { // called for teleport
		_pos_p = position player;
		_pos_p = [_pos_p select 0, _pos_p select 1, 0];
		{
			if ( (alive _x) && !isPlayer _x && vehicle _x == _x && ( [_x,_pos_p] call SYG_distance2D) > 500 ) then {
			    if ( (formationLeader _x == player) || (leader _x == player)) then
			    {
    				_x setPos _pos_p;
			    };
			};
		} forEach _units_formation;
	} else { // called for parajump
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
            if (alive _x) then // there were situations when dead AI was para-jumping :)
            {
                if (!isPlayer _x && vehicle _x == _x && ( [_x,_pos_p] call SYG_distance2D) > 500) then {
                    if ( (formationLeader _x == player) || (leader _x == player)) then
                    {
                        _obj_para = _parachute createVehicle[ 0,0,0 ];
                        _obj_para setPos _pos_p;
                        _obj_para setDir _dir;
                        _obj_para setVelocity _veloc;
                        _x moveInDriver _obj_para;
                        [_x] spawn {
                            _unit = _this select 0;
                            sleep 0.8321;
                            waitUntil {sleep 0.111;(vehicle _unit == _unit || !alive _unit)};
//                            if (alive _unit) then {
                                if (position _unit select 2 > 1) then {
                                    _unit setPos [position _unit select 0,position _unit select 1, 0];
                                };
//                            };
                        };
                    };
                };
			};
		} forEach _units_formation;
	};
};

if (true) exitWith {};
