// by Xeno, x_scripts/x_vehirespawn.sqf, not used? TODO: remove this script from mission
private ["_delay","_disabled","_moved","_newveh","_startdir","_startpos","_type","_vehicle"];
if (!isServer) exitWith{};

_vehicle = _this select 0;
_delay = _this select 1;
_moved = false;
_startpos = getPos _vehicle;
_startdir = getDir _vehicle;
_type = typeOf _vehicle;

while {true} do {
	sleep (_delay + random 15);

	_moved = (if (_vehicle distance _startpos > 5) then {true} else {false});
	
	_empty = (if (({alive _x} count (crew _vehicle)) > 0) then {false} else {true});
	
	_disabled = (if (damage _vehicle > 0) then {true} else {false});
	
	if ((_disabled && _empty) || (_moved && _empty) || (_empty && !(alive _vehicle))) then {
		deleteVehicle _vehicle;
		_vehicle = objNull;
		sleep 0.5;
		_vehicle = _type createVehicle _startpos;
		_vehicle setPos _startpos;
		_vehicle setDir _startdir;
	};
};
