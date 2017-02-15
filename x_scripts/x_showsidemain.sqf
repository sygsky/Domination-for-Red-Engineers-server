// by Xeno
if (!XClient) exitWith {};

#include "x_setup.sqf"

_which = _this select 0;

if ((_which == 1 && ((current_target_index == -1)) || (client_target_counter >= number_targets))) exitWith {};
//if (_which == 0 && (current_mission_text == "Все миссии выполнены!!!" || current_mission_text == "Новых дополнительных заданий не определено..." || current_mission_text == "В настоящие время дополнительное задание не определено...")) exitWith {};
if (_which == 0 && ((current_mission_text == localize "STR_SYS_120") || current_mission_text == localize "STR_SYS_121")) exitWith {};

_display = findDisplay 11001;

_ctrlmap = _display displayCtrl 11010;
ctrlMapAnimClear _ctrlmap;

#ifndef __TT__
_start_pos = position FLAG_BASE;
#endif
#ifdef __TT__
_start_pos = (
	if (playerSide == west) then {
		position WFLAG_BASE
	} else {
		position RFLAG_BASE
	}
);
#endif
_end_pos = [];
_exit_it = false;

switch (_which) do {
	case 0: {
		_markername = format ["XMISSIONM%1", current_mission_index + 1];
		_end_pos = markerPos _markername;
		if (format ["%1", _end_pos] == "[0,0,0]") then {
			_exit_it = true;
		};
	};
	case 1: {
		_end_pos = markerPos "dummy_marker";
	};
};

if (_exit_it) exitWith {};

_ctrlmap ctrlMapAnimAdd [0.0, 1.00, _start_pos];
_ctrlmap ctrlMapAnimAdd [1.2, 1.00, _end_pos];
_ctrlmap ctrlMapAnimAdd [0.5, 0.30, _end_pos];
ctrlMapAnimCommit _ctrlmap;

if (true) exitWith {};
