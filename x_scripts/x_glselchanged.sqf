// by Xeno, x_scripts/x_glselchanged.sqf - grass level settings
private ["_selection", "_control", "_selectedIndex", "_real_list", "_vlist"];
_selection = _this select 0;

_control = _selection select 0;
_selectedIndex = _selection select 1;

if (_selectedIndex == -1) exitWith {};

_selectedIndex call SYG_setGrassLevel;

if (true) exitWith {};