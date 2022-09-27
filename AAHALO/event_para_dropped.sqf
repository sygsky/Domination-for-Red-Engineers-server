/*
	author: Sygsky
	description: Event handler to check if player reached the base territory at last
			Variants are:
			1. On base
			2. On "AISPAWN" circle

            Passed array: [vehicle, role, unit]

	returns: nothing
*/

hint localize format["+++ event_para_dropped.sqf: Get out of parachute _this %1, pos %2", _this, getPos (_this select 2)];
_veh  = _this select 0;
_unit = _this select 2;
_arr = [];
_volume = AISPAWN call SYG_objectSize3D; // [length,width,height]
_radius = (_volume select 0) / 2;
_on_base = false;
_sc = d_ranked_a select 32; // prize score value
hint localize format ["+++ event_para_dropped.sqf: d_ranked_a select 32 = %1 m, count = %2", _sc, count d_ranked_a ];
if ( alive _unit ) then {
	if ( ( ( getPos _unit ) select 2 ) < 3 ) then { // on the land
		// 1. Are we in the circle?
		_pos1 = getPosASL player;
		_pos1 set [2,0];
		_dist = [AISPAWN, _pos1] call SYG_distance2D;
		_arr = nearestObjects[ _pos1, ["HeliH"], 100]; // find nearest circle of any type near the landing point
		hint localize format["+++ event_para_dropped.sqf: landed on the base, nearest circle count %1", count _arr];
		_on_base = _pos1 call SYG_pointIsOnBase;
		if (_on_base) then {

			if ( (count _arr) > 0 ) then {
				_pos2 = getPosASL (_arr select 0); // AISPAWN ?
				_dist = [_pos1, _pos2] call SYG_distance2D;
				hint localize format ["+++ event_para_dropped.sqf: landed on dist %1 m to the nearest circle of radius %2 m ", _dist, _radius];
				if ( _dist < _radius ) then {
					if ( (_arr select 0) == AISPAWN ) then  {
						// we are in AISPAWN circle!
						// "You hit the circle and are rewarded for this: +%1"
						_arr = [ "msg_to_user", "*", [["STR_INTRO_PARAJUMP_8", _sc]], 0, 1, false, "no_more_waiting" ];
						_sc call SYG_addBonusScore; // score to the player
						hint localize format ["+++ event_para_dropped.sqf: landed on dist to the main circle %1 m", _dist];
					} else {
						// "You hit the circle, but not the right one and you don't get points (+%1)"
						_arr = [ "msg_to_user", "*", [["STR_INTRO_PARAJUMP_8_1", _sc]], 0, 1, false, "no_more_waiting" ];
						hint localize format ["+++ event_para_dropped.sqf: landed on dist to the one of the side circles %1 m", _dist];
					};
				};
			};
			// "You landed outside the circle (distance %1 m.) and do not get points (+%2)"
			_arr = [ "msg_to_user", "*", [["STR_INTRO_PARAJUMP_8_2", round(_dist), _sc]], 0, 1, false, "no_more_waiting" ];
			hint localize format ["+++ event_para_dropped.sqf: landed on dist to the one of the side circles %1 m", _dist];
		} else {
			// "You have landed outside the base area (to the circle %1 m.). If you land on the yellow circle at the military recruitment tent, you will receive points: +%2"
			_arr = [ "msg_to_user", "*", [["STR_INTRO_PARAJUMP_7_1",round (_dist),_sc]], 0, 1, false, "losing_patience" ];
			hint localize format["+++ event_para_dropped.sqf: landed out of base far from any circle, %1 m. from circle", round _dist];
		};

		_arr2 = _arr select 2;
		if (damage player > 0.1) then {
			_arr set [count _arr2, ["STR_INTRO_PARAJUMP_9"]];
		} else {
			if (damage player > 0.26) then {
				_arr set [count _arr2, ["STR_INTRO_PARAJUMP_10"]];
			};
		};
		_arr spawn SYG_msgToUserParser;
	};
};
