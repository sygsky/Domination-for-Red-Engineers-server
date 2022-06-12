// by Xeno: x_scripts\x_create_vec.sqf
private ["_display", "_control", "_index", "_which"];

_display = findDisplay 11002;

_control = _display displayCtrl 44449;
_index = lbCurSel _control;
closeDialog 11002;

if (_index < 0) exitWith {};

_which = d_create_bike select _index;

[0,0,0,[_which,0]] execVM "x_scripts\x_bike.sqf";

if (true) exitWith {};
