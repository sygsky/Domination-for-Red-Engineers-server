// by Xeno

#include "x_setup.sqf"

private ["_display", "_control", "_pic", "_index"];
lbClear 101115;
_display = findDisplay 11099;
_control = _display displayCtrl 101115;

#ifdef __NO_REAMMO_IN_SALVAGE__

call compile format ["
{
	_pic = getText(configFile>>""cfgVehicles"" >> (typeOf _x) >> ""picture"");
	_index = _control lbAdd ([typeOf _x,0] call XfGetDisplayName);
	_control lbSetPicture [_index, _pic];
	_control lbSetColor [_index, [1, 1, 0, 0.5]];
} forEach truck%1_cargo_array;
", current_truck_cargo_array];

#else

call compile format ["
{
	_pic = getText(configFile>>""cfgVehicles"" >> _x >> ""picture"");
	_index = _control lbAdd ([_x,0] call XfGetDisplayName);
	_control lbSetPicture [_index, _pic];
	_control lbSetColor [_index, [1, 1, 0, 0.5]];
} forEach truck%1_cargo_array;
", current_truck_cargo_array];

#endif

_control lbSetCurSel 0;

if (true) exitWith {};
