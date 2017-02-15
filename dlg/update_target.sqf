#include "x_setup.sqf"

private ["_target","_display","_textctrl","_text","_end_pos"];

_target = _this select 0;

_display = findDisplay 100001;
_textctrl = _display displayCtrl 100110;

if (x_loop_end) exitWith {};

_text = "";
_end_pos = position player;
#ifndef __TT__
switch (_target) do {
	case 0: {
		if (tele_dialog == 0) then {
			_text = localize "STR_SYS_601"; // "Респаун на базе"
			beam_target = 0;
			_end_pos = position FLAG_BASE;
		} else {
			_text = format[localize "STR_SYS_602",1]; //"Телепорт на мобильный респаун 1"
			beam_target = 1;
			_end_pos = position MRR1;
		};
	};
	case 1: {
		_text = (
			if (tele_dialog == 0) then {
				format[localize "STR_SYS_603",1] //"Респаун на мобильный респаун 1"
				
			} else {
				format[localize  "STR_SYS_602",1] //"Телепорт на мобильный респаун 1"
			}
		);
		beam_target = 1;
		_end_pos = position MRR1;
	};
	case 2: {
		_text = (
			if (tele_dialog == 0) then {
				format[localize "STR_SYS_603",2] //"Респаун на мобильный респаун 2"
			} else {
				format[localize "STR_SYS_602",2] //"Телепорт на мобильный респаун 2"
			}
		);
		beam_target = 2;
		_end_pos = position MRR2;
	};
};
#endif
#ifdef __TT__
switch (_target) do {
	case 0: {
		if (tele_dialog == 0) then {
			_text = localize "STR_SYS_601"; // "Респаун на базе"
			beam_target = 0;
			_end_pos = (
				if (playerSide == west) then {
					position WFLAG_BASE
				} else {
					position RFLAG_BASE
				}
			);
		} else {
			_text = localize format["STR_SYS_602",1]; //"Телепорт на мобильный респаун 1"
			beam_target = 1;
			_end_pos = (
				if (playerSide == west) then {
					position MRR1
				} else {
					position MRRR1
				}
			);
		};
	};
	case 1: {
		_text = (
			if (tele_dialog == 0) then {
				localize format["STR_SYS_603",1] //"Респаун на мобильный респаун 1"
			} else {
				localize format["STR_SYS_602",1] //"Телепорт на мобильный респаун 1"
			}
		);
		beam_target = 1;
		_end_pos = (
			if (playerSide == west) then {
				position MRR1
			} else {
				position MRRR1
			}
		);
	};
	case 2: {
		_text = (
			if (tele_dialog == 0) then {
				localize format["STR_SYS_603",2] //"Респаун на мобильный респаун 2"
			} else {
				localize format["STR_SYS_602",2] //"Телепорт на мобильный респаун 2"
			}
		);
		beam_target = 2;
		_end_pos = (
			if (playerSide == west) then {
				position MRR2
			} else {
				position MRRR2
			}
		);
	};
};
#endif

_textctrl ctrlSetText _text;

[100001, 100104, _end_pos] call SYG_setMapPosToMainTarget;

/* _ctrlmap = _display displayCtrl 100104;
ctrlMapAnimClear _ctrlmap;

_start_pos = position player;
_ctrlmap ctrlMapAnimAdd [0.0, 1.00, _start_pos];
_ctrlmap ctrlMapAnimAdd [1.2, 1.00, _end_pos];
_ctrlmap ctrlMapAnimAdd [0.5, 0.30, _end_pos];
ctrlmapanimcommit _ctrlmap;
 */
if (true) exitWith {};
