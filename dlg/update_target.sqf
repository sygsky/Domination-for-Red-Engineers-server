// Xeno, dlg\update_target.sqf
#include "x_setup.sqf"

private ["_target","_display","_textctrl","_text","_end_pos","_veh","_sound"];

_target = _this select 0;

_display = findDisplay 100001;
_textctrl = _display displayCtrl 100110;

if (x_loop_end) exitWith {};

_text = "";
_sound = "";
_end_pos = position player;

#ifndef __TT__
_veh = objNull;
switch (_target) do {
	case 0: { // respawn to base only after death, not by teleport!!!
		if (tele_dialog == 0) then {
			_text = localize "STR_SYS_601"; // "Respawn at Base"
			beam_target = 0;
			_end_pos = position FLAG_BASE;
    		_sound = "base";
		} else { // it is not possible option
			_text = format[localize "STR_SYS_602",1]; // "Teleport to Mobile Resp %1"
			beam_target = 1;
			_end_pos = position MRR1;
			_veh = MRR1;
            _sound = "one";
		};
	};
	case 1: { // teleport to MHQ1
		_text = (
			if (tele_dialog == 0) then {
				format[localize "STR_SYS_603",1] //"Respawn at Mobile Resp %1"
			} else {
				format[localize  "STR_SYS_602",1] //"Teleport to Mobile Resp %1"
			}
		);
		beam_target = 1;
		_end_pos = position MRR1;
		_veh = MRR1;
        _sound = "one";
	};
	case 2: { // teleport to MHQ2
		_text = (
			if (tele_dialog == 0) then {
				format[localize "STR_SYS_603",2] //"Respawn at Mobile Resp %1"
			} else {
				format[localize "STR_SYS_602",2] //"Teleport to Mobile Resp %1"
			}
		);
		beam_target = 2;
		_end_pos = position MRR2;
    	_veh = MRR2;
        _sound = "two";
	};
};
#endif
#ifdef __TT__
switch (_target) do {
	case 0: {
		if (tele_dialog == 0) then {
			_text = localize "STR_SYS_601"; // ""Respawn at Base"
			beam_target = 0;
			_end_pos = (
				if (playerSide == west) then {
					position WFLAG_BASE
				} else {
					position RFLAG_BASE
				}
			);
		} else {
			_text = localize format["STR_SYS_602",1]; //""Teleport to Mobile Resp %1"
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
				localize format["STR_SYS_603",1] //"Respawn at Mobile Resp %1"
			} else {
				localize format["STR_SYS_602",1] //"Teleport to Mobile Resp %1"
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
				localize format["STR_SYS_603",2] //"Respawn at Mobile Resp %1"
			} else {
				localize format["STR_SYS_602",2] //"Teleport to Mobile Resp %1"
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

#ifndef __TT__
    #ifdef __NO_TELEPORT_ON_DAMAGE__

if  ( !isNull _veh  ) then {
    if (!alive _veh) exitWith {_sound = "crashed"};
    if (damage _veh >= 0.01) exitWith {
        _text = format[localize "STR_SYS_601_1", _text, round((damage _veh) *100), "%"]; // "%1. Dmg. %2%3"
        if ( damage _veh >=  __NO_TELEPORT_ON_DAMAGE__ ) exitWith { _sound = ["down","disabled"] call XfRandomArrayVal;};
        if ( damage _veh >=  (__NO_TELEPORT_ON_DAMAGE__ / 5) ) exitWith { _sound = ["damaged","damaging"] call XfRandomArrayVal;};
        // TODO: add code to prevent teleport to target if heave metall mass is near
        _sound = "warning";
    };
};
if ( _sound != "") then  { playSound _sound };
    #endif
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
