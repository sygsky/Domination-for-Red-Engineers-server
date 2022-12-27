// by Xeno, x_scripts\x_mediccheck.sqf, added to player on client with any roles to allow little medicine help
private ["_nearestbase", "_healerslist", "_objs", "_points", "_nobs", "_i", "_h", "_anim_list", "_healedName","_sound"];
#include "x_setup.sqf"
#include "x_macros.sqf"

sleep 5;

_nearestbase = (
	switch (d_own_side) do {
		case "WEST": {["SoldierWB"]};
		case "EAST": {["SoldierEB","SoldierWB"]};
		case "RACS": {["SoldierGB"]};
	}
);
_healerslist = [];
//_medic = false;

// how many to add on healing: medic +5, para-medic +1
_score_to_add = if (format ["%1",player] in d_is_medic) then {argp(d_ranked_a,17)} else {1};

// AmovPpneMstpSrasWrflDnon_healed - подняться из положения лёжа
// AinvPknlMstpSlayWrflDnon_healed - сидя под лечением
_anim_list = ["ainvpknlmstpslaywrfldnon_healed","amovppnemstpsraswrfldnon_healed"];

while {true} do {
	_objs = [];
	_points = 0;
	_healedName = "?";
	if (alive player) then {
		_objs = nearestObjects [player, _nearestbase, 3];
        if (count _objs > 0) then {
            //hint localize format[ "+++ x_mediccheck.sqf: found %1 of %2", count _objs, _nearestbase  ];
            {
                if ( (!( _x in _healerslist )) && ( _x != player ) ) exitWith { // not in healed list, not the player, some player
                    //hint localize format[ "+++ x_mediccheck.sqf: %1 - not player and not in healing list found", typeOf _x  ];
                    if ( animationState _x in _anim_list ) then {
                        hint localize format[ "+++ x_mediccheck.sqf: %1 is in healing animation, list size %2", typeOf _x, count  _healerslist ];
                        _healerslist set [count _healerslist,_x];
                        // is one of players healed
                        if ( isPlayer _x ) then {
                            _points = _points + _score_to_add;
                            _healedName = name _x;
                        };
                        _sound = "healing"; // frienв unit is healed
                        // if enemy healed
                        if ( side _x  == d_side_enemy ) then { _sound = call SYG_exclamationSound; };
                        hint localize format[ "+++ x_mediccheck.sqf: say sound ""%1"" for %2, list size %3", _sound, typeOf _x, count  _healerslist ];
                        ["say_sound", _x, _sound] call XSendNetStartScriptClientAll;
                    };
                };
            } forEach _objs;
            if ( _points > 0 ) then {
                //player addScore _points;
                _points call SYG_addBonusScore;
                ( format [localize "STR_MED_8", _points, _healedName] ) call XfHQChat; // "You get +%1 points for healing %2!"
            };
            sleep 0.01;
        };
        if (count _healerslist > 0) then {
            for "_i" from 0 to (count _healerslist - 1) do {
                _h = _healerslist select _i;
                if (alive _h) then {
                    if (!(animationState _h in _anim_list)) then { _healerslist set [_i, "X_RM_ME"]; };
                } else {_healerslist set [_i, "X_RM_ME"]};
            };
            _healerslist = _healerslist - ["X_RM_ME"];
        };
	} else {
	    _healerslist = [];
	};
	sleep 0.561;
};
