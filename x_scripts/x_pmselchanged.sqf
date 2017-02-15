// by Xeno
private ["_selection", "_control", "_selectedIndex"];
_selection = _this select 0;

_control = _selection select 0;
_selectedIndex = _selection select 1;

if (_selectedIndex == -1) exitWith {};

if (d_show_player_marker != _selectedIndex) then {
	d_show_player_marker = _selectedIndex;
	execVM "x_scripts\x_deleteplayermarker.sqf";
};

if (true) exitWith {};