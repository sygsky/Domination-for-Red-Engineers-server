// by Xeno: x_scripts\x_showsecondary.sqf
private ["_current_target_name","_s","_target_array2"];
if (!X_Client) exitWith {};

#include "x_macros.sqf"

#define __PRINT__

_s = localize "STR_SYS_210"; //"Второстепенное задание: ";

_current_target_name = localize "STR_SYS_208"; //"Нет цели"
if ((current_target_index != -1) && (sec_kind > 0)) then
{
	__TargetInfo

    // process some cases if needed
 	switch (sec_kind) do {
		case 3:	 {// ammo truck is a secondary target in the town
			_rearmed = [_target_array2 select 0] call SYG_reammoTruckAround;
#ifdef __PRINT__
			hint localize format[ "x_showsecondary.sqf: vehicles of 'Truck5tReammo' type rearmed %1", _rearmed ];
#endif				
		}; 
 	    case 1;
 	    case 2;
 	    case 4;
 	    case 5;
 	    case 6;
 	    case 7;
 	    case 8;
 	    default {};
	};

	_s = _s + format [localize (format["STR_SEC_%1",sec_kind]), _current_target_name]; // compound description generation
} else {
	_s = _s + localize "STR_SYS_209"; //"Второстепенная задача не определена..."
};

_s call XfHQChat;

if (true) exitWith {};


