// by Xeno
private ["_vehicle","_position","_enterer"];

_vehicle = _this select 0;
_position = _this select 1;
_enterer = _this select 2;

if (local _enterer && _position == "driver") then {
	if (_enterer == player && player_is_driver) then {
		player_is_driver = false;
		if (hud_id != -1000) then {
			_vehicle removeAction hud_id;
			hud_id = -1000;
		};
	};
};

if (true) exitWith {};
