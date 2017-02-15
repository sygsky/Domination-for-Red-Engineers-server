// by Xeno
private ["_selection", "_control", "_selectedIndex", "_real_list", "_vlist"];
_selection = _this select 0;

_control = _selection select 0;
_selectedIndex = _selection select 1;

if (_selectedIndex == -1) exitWith {};

_real_list = [50, 25, 12.5];
_vlist = ["STR_SYS_011","STR_SYS_012","STR_SYS_013"]; // "No Grass", "Medium Grass", "Full Grass"
if (d_graslayer_index != _selectedIndex) then {
	d_graslayer_index = _selectedIndex;
	setTerrainGrid (_real_list select d_graslayer_index);

	(format [localize "STR_SYS_01"/*"Настройки отображения травы: %1"*/ , localize (vlist select d_graslayer_index)]) call XfGlobalChat;
};

if (true) exitWith {};