// by Xeno, x_scripts/x_glselchanged.sqf - grass level settings
private ["_selection", "_control", "_selectedIndex", "_real_list", "_vlist"];
_selection = _this select 0;

_control = _selection select 0;
_selectedIndex = _selection select 1;

if (_selectedIndex == -1) exitWith {};

_real_list = [50, 25, 12.5];
_vlist = ["STR_GRASS_1","STR_GRASS_2","STR_GRASS_3"]; // "No Grass", "Medium Grass", "Full Grass"
if (d_graslayer_index != _selectedIndex) then {
	d_graslayer_index = _selectedIndex;
	setTerrainGrid (_real_list select d_graslayer_index);

	(format [localize "STR_SYS_01"/* "Grass layer set to: %1" */ , localize (_vlist select d_graslayer_index)]) call XfGlobalChat;
};

if (true) exitWith {};