// by Xeno, x_scripts/x_dismissai.sqf - dimiss all alive AI from the player  if available

#include "x_setup.sqf"

_grp_player = group player;
_units_player = units _grp_player;

if (({alive _x} count _units_player) > 0) then {
	_ai_cnt = 0;
	_price = d_ranked_a select 3;
	{
		if (!isPlayer _x) then {
			_ai_cnt = _ai_cnt + 1;
			_x removeAllEventHandlers "killed";
			if (vehicle _x == _x) then {
				deleteVehicle _x;
			} else {
				_x action ["eject", vehicle _x];
				unassignVehicle _x;
				sleep 0.532;
				deleteVehicle _x;
			};
			#ifdef __RANKED__
            // each AI soldier costs score points
                player addScore _price; // return scores for each alive dismissed AI
            #endif
		};
	} forEach _units_player;
	if ( (_ai_cnt != 0) && (_price != 0)) then {
	    playSound "return";
	};
	(format[localize "STR_AI_9",_price * _ai_cnt])  call XfHQChat; // "All AI soldiers dismissed !!!!"
};

if (true) exitWith {};
