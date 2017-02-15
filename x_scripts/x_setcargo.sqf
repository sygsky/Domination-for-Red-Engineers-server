// by Xeno
private ["_control","_display","_index"];

_display = findDisplay 11099;

_control = _display displayCtrl 101115;
_index = lbCurSel _control;

if (_index < 0) exitWith {closeDialog 11099;};

cargo_selected_index = _index;

closeDialog 11098;

if (true) exitWith {};
