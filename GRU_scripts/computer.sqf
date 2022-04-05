// computer.sqf, by Sygsky at 26-NOV-2015, run on client only
// support computer action menu

#include "x_setup.sqf"
#include "GRU_setup.sqf"

//#define __PRINT__

private ["_comp","_unit","_dir","_dir1","_str"];
_comp = _this select 0;
_unit = _this select 1;


_dir = round([_comp, _unit] call XfDirToObj);
_dir1 = round(getDir _comp);

#ifdef __PRINT__
hint localize format[ "+++ computer.sqf: get intel task -> dir to player %1, comp dir %2, ", _dir, _dir1 ];
//player groupChat localize format["get intel task: dir to player %1, comp dir %2", round (_dir), round(getDir _comp)];
#endif

// check direction. TODO: add check for negative values
_dir = _dir1 - _dir;
_str = if ( _dir < 4 || _dir > 104 ) then {"STR_COMP_4"} else { // bad access angle, use computer from front side
	if ((call GRU_taskCount) == 0) then { "STR_COMP_2" } // no tasks
	else {
		[ _unit call SYG_hasWeapon4GRUMainTask/* SYG_hasOnlyPistol */ ] execVM "GRU_scripts\dlg.sqf";
		""
	};
};
if ( _str != "" ) then {titleText [localize _str,"PLAIN DOWN"];};
