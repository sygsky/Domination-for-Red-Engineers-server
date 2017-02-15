// by Xeno
if (isNil "SYG_resurrect_array") exitWith
{
    hint localize "dlg/res_radselchanged.sqf: SYG_resurrect_array isNil";
};

private ["_selection", "_control", "_selectedIndex", "_dist"];

//hint localize format["dlg/res_radselchanged.sqf: event called with _this = %1", _this];

_selection = _this select 0;

_control = _selection select 0;

_selectedIndex = _selection select 1;

if (_selectedIndex == -1) exitWith {};

SYG_resurrect_array_index = _selectedIndex;

if (true) exitWith {};