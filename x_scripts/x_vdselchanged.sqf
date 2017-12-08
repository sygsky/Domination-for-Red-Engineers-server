// by Xeno, x_scripts/x_vdselchanged.sqf, view range set
private ["_selection", "_control", "_selectedIndex", "_rarray", "_index"];
_selection = _this select 0;

_control = _selection select 0;
_selectedIndex = _selection select 1;


/*
//_rarray = [900, 1000, 1200, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000, 6500, 7000, 7500, 8000, 8500, 9000, 10000];
_rarray = [1500, 2000, 2500, 3000, 3500, 4000, 5000, 6000, 7000, 8000, 9000, 10000];

_selectedIndex == (_selectedIndex max 0) min (count _rarray -1);


if (d_viewdistance != (_rarray select _selectedIndex)) then {
	d_viewdistance = _rarray select _selectedIndex;
	setViewDistance d_viewdistance;
	(format [localize "STR_SYS_1140",d_viewdistance]) call XfGlobalChat; // "Viewdistance set to: %1"
};
*/

_selectedIndex call SYG_setViewDistance;

if (true) exitWith {};