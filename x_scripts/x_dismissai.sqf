// by Xeno, x_scripts/x_dismissai.sqf - dimiss all alive AI from the player  if available

#include "x_setup.sqf"

private [ "_refund"];
_grp_player = group player;
_units_player = units _grp_player;
_ai_cnt = {(!isPlayer _x) && (alive _x)} count _units_player;
_dmg_cnt = 0;

if (_ai_cnt > 0) then {
	_ai_cnt = 0;
	_ai_low_cost = d_ranked_a select 3; // constant cost for the 1st soldier
	_refund = 0;
	{
		if (!isPlayer _x) then {
			_ai_cnt = _ai_cnt + 1;
			_x removeAllEventHandlers "killed";
			_ai_cost = _x getVariable "AI_COST";
            if (isNil "_ai_cost") then {
                _refund = _refund + _ai_low_cost;
            } else {
                _dmg = damage _x;
                _refund = _refund + ceil (_ai_cost * 0.5 * (1 - _dmg));
                if (_dmg > 0 ) then {_dmg_cnt = _dmg_cnt + 1};
            };
			if (vehicle _x == _x) then {
				deleteVehicle _x;
				sleep 0.1;
			} else {
				_x action ["eject", vehicle _x];
				unassignVehicle _x;
				sleep 0.532;
				deleteVehicle _x;
			};
		};
	} forEach _units_player;
	if ( (_ai_cnt > 0) && (_refund != 0)) then {
	    playSound "return";
        // each AI soldier costs score points
        //player addScore _refund; // return scores for each alive dismissed AI
        _refund call SYG_addBonusScore;
	};
	_str = "";
	if ( _dmg_cnt  > 0) then {
	    _str = format[localize "STR_AI_9_1", _dmg_cnt];
	    playSound "losing_patience";
	}; // "Treat your soldiers better (wounded %1)"
	(format[localize "STR_AI_9", _ai_cnt, _refund, _str])  call XfHQChat; // "All (%1) AI soldiers dismissed !!! Points returned %2%3"
} else {
	(localize "STR_AI_9_2")  call XfHQChat; // "You have no recruits!"
};

if (true) exitWith {};
