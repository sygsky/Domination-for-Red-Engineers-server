// by Syg, x_scripts/x_rmselchanged.sqf - reborn music play/not play settings
private ["_selection", "_control", "_selectedIndex", "_msg", "_vlist"];
_selection = _this select 0;
_control = _selection select 0;
_selectedIndex = _selection select 1;
if (_selectedIndex == -1) exitWith {};

if (d_rebornmusic_index != _selectedIndex) then {
	d_rebornmusic_index = _selectedIndex;
    _msg = ["STR_REBORN_1","STR_REBORN_0"] select _selectedIndex; // "On", "Off"
	( format [ "%1 -> %2", localize "STR_SYS_168", localize _msg ] ) call XfGlobalChat;
};

if (true) exitWith {};