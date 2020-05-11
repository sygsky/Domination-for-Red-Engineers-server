// by Xeno
private ["_current_target_name","_s","_target_array2"];
if (!X_Client) exitWith {};

#include "x_macros.sqf"

#define __PRINT__

_s = localize "STR_SYS_210"; //"Второстепенное задание: ";

_current_target_name = localize "STR_SYS_208"; //"Нет цели"
if ((current_target_index != -1) && (sec_kind > 0)) then
{
	__TargetInfo

/*
 	switch (sec_kind) do {
		case 1: {
			_s = _s + format [localize "STR_SYS_200", _current_target_name]; //"Найти в %1 и устранить местного губернатора."
		};
		case 2: {
			_s = _s + format [localize "STR_SYS_201", _current_target_name]; //"Найти вышку связи в %1 и уничтожить её."
		};
		case 3: {
			_s = _s + format [localize "STR_SYS_202", _current_target_name]; //"Найти и уничтожить в %1 грузовик с боезапасом."
		};
		case 4: {
			_s = _s + format [localize "STR_SYS_203", _current_target_name]; // "Найти в %1 штабную бронемашину (замаскированную под санитарную) и уничтожить её."
		};
		case 5: {
			_s = _s + format [localize "STR_SYS_204", _current_target_name]; // "Найти и уничтожить в %1 штабную бронемашину противника."
		};
		case 6: {
			_s = _s + format [localize "STR_SYS_205", _current_target_name]; // "Найти и уничтожить в %1 завод по производству героина."
		};
		case 7: {
			_s = _s + format [localize "c", _current_target_name]; // "Найти и уничтожить в %1 большой завод по производству героина."
		};
	};

*/
    // process some cases if needed
 	switch (sec_kind) do
 	{
 	    case 1;
 	    case 2;
		case 3:	// ammo truck is a secondary target in the town
		{ 
			// TODO find this ammo truck and make it super ammo one
			_rearmed = [_target_array2 select 0] call SYG_reammoTruckAround;
#ifdef __PRINT__
			hint localize format[ "x_showsecondary.sqf: vehicles of 'Truck5tReammo' type rearmed %1", _rearmed ];
#endif				
		}; 
 	    case 4;
 	    case 5;
 	    case 6;
 	    case 7;
 	    default {};
	};

	_s = _s + format [localize (format["STR_SYS_20%1",(sec_kind-1)]), _current_target_name]; // compound description generation
} else
{
	_s = _s + localize "STR_SYS_207"; //"Второстепенная задача не определена..."
};

_s call XfHQChat;

if (true) exitWith {};


