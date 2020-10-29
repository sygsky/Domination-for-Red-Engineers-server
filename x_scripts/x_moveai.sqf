// by Xeno, x_scripts\x_moveai.sqf, move  AI together with player, by parachute and by telepot
// +++ 06-МАР-2019: Sygsky  changes:
// AI is moved to player if 2D distance  is more them 500 m.
// AI is moved if player is leader of his group or is formation leader of his formation
// prevent teleport of some units if special SM is executing, parajump is still allowed for such persons
// ---
private ["_grp_player","_units_player","_ntp_cnt","_ai"];

#include "x_setup.sqf"

_disable_teleport_list =
    if (d_enemy_side == "EAST") then {
        [
#ifdef __ACE__
        "ACE_OfficerE",
#endif
        "OfficerE"
        ]
    } else {
        [
#ifdef __ACE__
        "ACE_USMC0302","ACE_USMC8541A2",
#endif
        "OfficerW"
        ]
    };

_grp_player = group player;
_units_player = units _grp_player;
if (({alive _x} count _units_player) > 0) then {
	_units_formation = formationMembers player;
	if (count _this == 0) then { // called for teleport
		_pos_p = position player;
		_ntp_cnt = 0; // no teleport count
		_pos_p = [_pos_p select 0, _pos_p select 1, 0];
		{
			if ( (alive _x) && !isPlayer _x && vehicle _x == _x && ( [_x,_pos_p] call SYG_distance2D) > 500 ) then {
			    if ( (formationLeader _x == player) || (leader _x == player)) then {
			        _ai = _x getVariable "AI_COST"; // AI of this player must have the variable
			        _ai = !(isNil "_ai");
			        if ( _ai && (!((typeOf _x) in _disable_teleport_list)) ) then { _x setPos _pos_p; } // teleport
			            else  { _ntp_cnt = _ntp_cnt +1; }; // no teleport
			    };
			};
		} forEach _units_formation;
		if (_ntp_cnt > 0 ) then {
		    (format[localize "STR_SM_TELEPORT_1", _ntp_cnt]) call XfHQChat; // "You realized that teleportation didn’t work with all your team members"
//		    hint localize format["+++ x_moveai.sqf: teleport stopped for %1 civilians/officers", _ntp_cnt ];
		    playSound "losing_patience";
		};
	} else { // called for parajump
		 // params: [position _obj_jump, velocity _obj_jump, direction _obj_jump]
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
            if (alive _x) then { // there were situations when dead AI was para-jumping :)
                if (!isPlayer _x && vehicle _x == _x && ( [_x,_pos_p] call SYG_distance2D) > 500) then {
                    if ( (formationLeader _x == player) || (leader _x == player)) then {
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
