/*
	author: Sygsky
	description: Event handler to check where player is landed after para jump.
			Variants are:
			1. On base
			2. On "AISPAWN" circle

            Passed array: [vehicle, role, unit]

	returns: nothing
*/

hint localize format["+++ event_para_dropped.sqf: Get out of parachute _this %1, pos %2", _this, getPos (_this select 2)];
_veh  = _this select 0;
_unit = _this select 2;

if ( alive _unit ) then {
	if ( ( ( getPos _unit ) select 2 ) < 3 ) then {
		// 1. Are we in the circle?
		_volume = AISPAWN call SYG_objectSize3D; // [length,width,height]
		_pos1 = getPosASL player;
		_pos2 = getPosASL AISPAWN;
		_dist = [_pos1, _pos2] call SYG_distance2D;
		hint localize format ["+++ event_para_dropped.sqf: landed on dist to circle %1 m", _dist];
		_arr = [];

		_sc = d_ranked_a select 32;
		if ( _dist < ((_volume select 0) / 2) ) then {
			// we are in circle!
			// "You hit the circle and are rewarded for this: +%1"
			_arr = [ "msg_to_user", "*", [["STR_INTRO_PARAJUMP_8", _sc]], 0, 1, false, "no_more_waiting" ];
			_sc call SYG_addBonusScore; // score to the player
		};

		if ( _pos1 call SYG_pointIsOnBase) then {
			// we are on base but not in circle
			// "You have landed in the base area, which is not bad. Try to land on the yellow circle near the barracs (points: +%1)"
			_arr = [ "msg_to_user", "*", [["STR_INTRO_PARAJUMP_7",_sc]], 0, 1, false, "good_news" ];
		} else {
			// "You have landed outside the base area (to the circle %1 m.). If you land on the yellow circle at the military recruitment tent, you will receive points: +%2"
			_arr = [ "msg_to_user", "*", [["STR_INTRO_PARAJUMP_7_1",round (_dist),_sc]], 0, 1, false, "losing_patience" ];
		};

		if (damage player > 0.1) then {
			_arr2 = _arr select 2;
			_arr set [count _arr2, ["STR_INTRO_PARAJUMP_9"]];
		} else {
			if (damage player > 0.26) then {
				_arr2 = _arr select 2;
				_arr set [count _arr2, ["STR_INTRO_PARAJUMP_10"]];
			};
		};
		_arr spawn SYG_msgToUserParser;
	};
};
