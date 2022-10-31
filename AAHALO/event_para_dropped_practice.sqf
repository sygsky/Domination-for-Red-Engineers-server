/*
	AAHALO\event_para_dropped_practice.sqf

	author: Sygsky
	description: Event handler to check if player landed on base/circle/etc at practice jump
			Variants are:
			1. Out of base territory
			2. On base territory
			3. On one of base circles
			4. On "AISPAWN" circle! Main target hit!

            Passed array: [vehicle, role, unit]

	returns: nothing
*/
if (!isServer) exitWith {"--- event_para_dropped_practice.sqf illegally called on server"};
hint localize format["+++ event_para_dropped_practice.sqf: Landed on parachute _this %1, pos %2", _this, getPos (_this select 2)];
_veh  = _this select 0;
_unit = _this select 2;
_arr = [];
_volume = AISPAWN call SYG_objectSize3D; // [length,width,height]
_radius = [(_volume select 0) / 2, 0.1] call SYG_roundTo;
_on_base = false;
hint localize format ["+++ event_para_dropped_practice.sqf: count = %1, volume %2, rad %3", count d_ranked_a, _volume, _radius ];
if ( !alive _unit ) exitWith {};

if ( ( ( getPos _unit ) select 2 ) > 3 ) exitWith {};
// on the land

// 1. Are we in the circle?
_pos1 = getPosASL player;
_pos1 set [2,0];
_dist = [AISPAWN, _pos1] call SYG_distance2D;
_arr = nearestObjects[ _pos1, ["HeliH"], 100]; // find nearest circle of any type near the landing point
_msgArr = [];
hint localize format["+++ event_para_dropped_practice.sqf: landed on the base, nearest circle count %1", count _arr];

if ( _pos1 call SYG_pointIsOnBase ) then {
	if ( (count _arr) > 0 ) then {
		_pos2 = getPosASL (_arr select 0); // AISPAWN ?
		_dist = [[_pos1, _pos2] call SYG_distance2D, 0.1] call SYG_roundTo;
		hint localize format ["+++ event_para_dropped_practice.sqf: landed on dist %1 m to the nearest circle of radius %2 m ", _dist, _radius];
		if ( _dist < _radius ) exitWith {
			if ( (_arr select 0) == AISPAWN ) then  {
				// we are in AISPAWN circle!
				// "You hit the circle"
				_msgArr = [ "msg_to_user", "*", [["STR_INTRO_PARAJUMP_8_0"]], 0, 1, false, "no_more_waiting" ];
				hint localize format ["+++ event_para_dropped_practice.sqf: landed on dist to the main circle %1 m", _dist];
			    ["log2server", name player, "I hit the circle on training!"] call XSendNetStartScriptServer;
			} else {
				// "You hit the circle, but not the right one."
				_msgArr = [ "msg_to_user", "*", [["STR_INTRO_PARAJUMP_8_1_0"]], 0, 1, false, "losing_patience" ];
				hint localize format ["+++ event_para_dropped_practice.sqf: landed on dist to the one of the side circles %1 m", _dist];
			};
		};
		// "You landed outside the nearest circle (distance %1 m.)"
		_msgArr = [ "msg_to_user", "*", [["STR_INTRO_PARAJUMP_8_2_0", round(_dist)]], 0, 1, false, "losing_patience" ];
		hint localize format ["+++ event_para_dropped_practice.sqf: landed on dist to the one of the side circles %1 m", _dist];
	} else {
		// "You have landed in the base area, which is not bad. Try to land on the yellow circle near tent of barracs (points: +%1)"
		_msgArr = [ "msg_to_user", "*", [["STR_INTRO_PARAJUMP_7", _sc]], 0, 1, false, "losing_patience" ];
	};
} else {
	// "You have landed outside the base area (to the circle %1 m.). If you land on the yellow circle at the military recruitment tent, you will receive points: +%2"
	_msgArr = [ "msg_to_user", "*", [["STR_INTRO_PARAJUMP_7_1_0",round (_dist)]], 0, 1, false, "losing_patience" ];
	hint localize format["+++ event_para_dropped_practice.sqf: landed out of base far from any circle, %1 m. from circle", round _dist];
};

_arr2 = _msgArr select 2;
_damage = damage player;
_str = "";
if ( _damage > 0.26) then {
	_str = "STR_INTRO_PARAJUMP_10"; //  "You are badly injured when you land"
} else  {
	if (_damage > 0.05) then {
		_str =  "STR_INTRO_PARAJUMP_9"; // "You are slightly injured on landing"
	};
};
if (_str != "" ) then {
	_arr2 set [count _arr2, [_str]]; //  "You are badly injured when you land"
	hint localize format["+++ event_para_dropped_practice.sqf: damage detected = %1", _damage];
};
hint localize format["+++ event_para_dropped_practice.sqf: msg arr %1", _msgArr];
_msgArr spawn SYG_msgToUserParser;
