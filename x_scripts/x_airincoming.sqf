// by Xeno, x_scripts/x_airincoming.sqf not for ACE
private ["_get_air"];

_get_air = compile "_result = false;if (vehicle player != player) then {if (vehicle player isKindOf ""Air"" && !(vehicle player isKindOf ""ParachuteBase"")) then {_result = true} else {_result = false;};};_result";

while {true} do {
	private ["_vec"];
	_has_handler = false;
	waitUntil {sleep random 0.3;call _get_air};
	_vec = vehicle player;
	if (player == driver _vec) then {
		_type = typeOf player;
		_is_pilot = true;
		if (count d_only_pilots_can_fly > 0) then {
			if (!(_type in d_only_pilots_can_fly)) then {
				player action ["eject", _vec];
				hint "Only pilots can fly";
				_is_pilot = false;
			};
		};
		if (_is_pilot) then {
			_vec addEventHandler ["IncomingMissile", {if (player == driver (_this select 0)) then {[(_this select 0), "!!! Опасность !!! Угроза попадания ракеты !!!"] call XfVehicleChat;[_this select 0, _this select 1, _this select 2] spawn XIncomingMissile};}];
			_has_handler = true;
		};
	};
	waitUntil {sleep random 0.3;vehicle player == player};
	if (_has_handler) then {
		_vec removeAllEventHandlers "IncomingMissile";
	};
	sleep 0.712;
};