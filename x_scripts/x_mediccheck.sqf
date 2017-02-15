// by Xeno
private ["_nearestbase", "_healerslist", "_objs", "_points", "_nobs", "_i", "_h"];
#include "x_setup.sqf"
#include "x_macros.sqf"

sleep 5;

_nearestbase = (
	switch (d_own_side) do {
		case "WEST": {"SoldierWB"};
		case "EAST": {"SoldierEB"};
		case "RACS": {"SoldierGB"};
	}
);
_healerslist = [];

while {true} do {
	_objs = [];
	_points = 0;
	if (alive player) then {
		_objs = nearestObjects [player, [_nearestbase], 3];
	};
	if (count _objs > 0) then {
		{
			if (!(_x in _healerslist) && (_x != player)) then {
				if (animationState _x in ["ainvpknlmstpslaywrfldnon_healed","amovppnemstpsraswrfldnon_healed"]) then {
					_points = _points + (d_ranked_a select 17);
					_healerslist = _healerslist + [_x];
				};
			};
		} forEach _objs;
		if (_points > 0) then {
			player addScore _points;
			(format ["You get %1 points for healing other units!", _points]) call XfHQChat;
		};
		sleep 0.01;
	};
	if (count _healerslist > 0) then {
		for "_i" from 0 to (count _healerslist - 1) do {
			_h = _healerslist select _i;
			if (!(animationState _h in ["ainvpknlmstpslaywrfldnon_healed","amovppnemstpsraswrfldnon_healed"])) then {
				_healerslist set [_i, "X_RM_ME"];
			};
		};
		_healerslist = _healerslist - ["X_RM_ME"];
	};
	sleep 0.561;
};
