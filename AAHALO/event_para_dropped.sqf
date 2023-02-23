/*
	AAHALO\event_para_dropped.sqf

	author: Sygsky
	description: Event handler to check if player landed on base/circle/etc after intro/practice procedure
			Variants are:
			1. Out of base territory
			2. On base territory far from any circle
			3. On one of base circles
			4. On "AISPAWN" circle! Main target hit!

            Passed array: [vehicle, role, unit<,_count_score_or_not>]

	returns: nothing
*/

private ["_fmt","_sub_name"];
hint localize format["+++ event_para_dropped.sqf: Landed with parachute _this %1, pos %2", _this, getPos (_this select 2)];
_veh  = _this select 0; // usually is NULL
_unit = _this select 2;
_add_score =  if ((count _this) < 4) then {true} else {_add_score = _this select 3}; // add score if count of params < 4
if (_add_score) then {
	_fmt= "";
	_sub_name = "";
} else {
	_fmt = "_0";
	_sub_name = "_practice";
};
_arr = [];
_volume  = AISPAWN call SYG_objectSize3D; // [length,width,height]
_radius  = [(_volume select 0) / 2, 0.1] call SYG_roundTo;
_on_base = false;
_sc      = d_ranked_a select 32; // prize score value
_dmg     = round( _sc * (damage player)) min _sc; // damage to subtract, #595
_sc      = _sc - _dmg; // score is proportional to the health
hint localize format ["+++ event_para_dropped%1.sqf: circle hit score %2, alive %3, volume %4, rad %5, sub dmg %6", _sub_name, _sc, alive _unit, _volume, _radius, _dmg ];
if ( !alive _unit ) exitWith {};

if ( ( ( getPos _unit ) select 2 ) > 3 ) exitWith {};
// on the land

// 1. Are we in the circle?
_pos1 = getPosASL player;
_pos1 set [2,0];
_dist = [[AISPAWN, _pos1] call SYG_distance2D, 0.1] call SYG_roundTo;
_arr = nearestObjects[ _pos1, ["HeliH"], 100]; // find nearest circle of any type near the landing point
_msgArr = [];
_send_to_server = false;

if ( _pos1 call SYG_pointIsOnBase ) then {
	hint localize format["+++ event_para_dropped%1.sqf: landed on the base, nearest circle count %2", _sub_name, count _arr];
	if ( (count _arr) > 0 ) then {
		_pos2 = getPosASL (_arr select 0); // AISPAWN or other base circle?
		_dist = [[_pos1, _pos2] call SYG_distance2D, 0.1] call SYG_roundTo;
		hint localize format ["+++ event_para_dropped%1.sqf: landed on dist %2 m to the nearest circle of radius %3 m ", _sub_name, _dist, _radius];
		if ( _dist < _radius ) exitWith {
			if ( (_arr select 0) == AISPAWN ) then  {
				// we are in AISPAWN circle!
				// "You hit the circle and are rewarded for this: +%1, off for damage %2"
				_msgArr = [ "msg_to_user", "*", [[format["STR_INTRO_PARAJUMP_8%1",_fmt], _sc, _dmg]], 0, 8, false, "no_more_waiting" ];
				if (_add_score) then {
					_sc call SYG_addBonusScore; // score to the player
				};
				hint localize format ["+++ event_para_dropped%1.sqf: landed in circle on dist to the main circle %2 m", _sub_name, _dist];
				_send_to_server = true; // mark to send info to server
			} else {
				// "You hit the circle, but not the right one[ and you don't get points (+%1)]"
				_msgArr = [ "msg_to_user", "*", [[format["STR_INTRO_PARAJUMP_8_1%1", _fmt], _sc, _dmg]], 0, 5, false, "losing_patience" ];
				hint localize format ["+++ event_para_dropped%1.sqf: landed on dist to the one of the side circles %2 m", _sub_name, _dist];
			};
		};
		// "You landed outside the nearest circle (distance %1 m.)[ and do not get points (+%2)]"
		_msgArr = [ "msg_to_user", "*", [[format["STR_INTRO_PARAJUMP_8_2%1",_fmt], round(_dist), _sc, _dmg]], 0, 5, false, "losing_patience" ];
		hint localize format ["+++ event_para_dropped%1.sqf: landed on dist to the one of the side circles %2 m", _sub_name, _dist];
	} else {
		// "You have landed in the base area, which is not bad. Try to land on the yellow circle near tent of barracs (points: +%1)"
		_msgArr = [ "msg_to_user", "*", [["STR_INTRO_PARAJUMP_7", _sc]], 0, 5, false, "losing_patience" ];
		hint localize format["+++ event_para_dropped%1.sqf: landed on base far from circles", _sub_name];
	};
} else {
	// "You have landed outside the base area (to the circle %1 m.). If you land on the yellow circle at the military recruitment tent, you will receive points: +%2"
	_msgArr = [ "msg_to_user", "*", [[format["STR_INTRO_PARAJUMP_7_1%1",_fmt],round (_dist),_sc]], 0, 5, false, "losing_patience" ];
	hint localize format["+++ event_para_dropped%1.sqf: landed out of base far from any circle, %2 m. from circle", _sub_name, round _dist];
};

_arr2 = _msgArr select 2;
if (_send_to_server) then { // send message about circle hit to all players and print this on server
    // print to this player
	_msgArr spawn SYG_msgToUserParser;
	// print to all other players if any: "%1 hit the circle (%2 m) and is rewarded for this: +%3, off for damage %4"
	_msgArr1 = [ "msg_to_user", "*", [[format["STR_INTRO_PARAJUMP_8_ALL%1",_fmt], name player, _dist, _sc, _dmg]], 0, 3, false, "no_more_waiting" ];
	_msgArr1 spawn XSendNetStartScriptClient;
	hint localize format["+++ event_para_dropped%1.sqf: print to all players %2", _sub_name, _msgArr1];
    // Write to the server RPT log file
    if (_add_score) then {
	    ["log2server", name player, format["I hit the circle on intro: dist. %1 m, dmg %2", _dist, _dmg]] call XSendNetStartScriptServer;
    } else {
    	["log2server", name player, format["I hit the circle on practice: dist. %1 m, dmg %2", _dist, _dmg]] call XSendNetStartScriptServer;
    };
	// now remove message from the list as it is already sent
	_arr2 resize 0;
};

// print health status if player was wounded
_damage = damage player;
if (_damage > 0 ) then {
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
        hint localize format["+++ event_para_dropped%1.sqf: damage detected = %2", _sub_name, _damage];
    };
};

if (count _arr2 == 0) exitWith {};
hint localize format["+++ event_para_dropped%1.sqf: msg arr %2", _sub_name, _msgArr];
_msgArr spawn SYG_msgToUserParser;
