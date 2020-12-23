// by Xeno
private ["_vehicle","_position","_enterer"];

_vehicle = _this select 0;
_position = _this select 1;
_enterer = _this select 2;

if (local _enterer) then {
	if (_position == "driver") then {
		_type_enterer = typeOf _enterer;
		if (!(_type_enterer in d_only_pilots_can_fly)) then {
			hint localize "STR_SYS_251"; // "Отсутствует разрешение на полёты!";
			driver _vehicle action["Eject",_vehicle];
		};
	};
};

if (true) exitWith {};
