// by Xeno, x_missions\x_getsidemissionclient.sqf, клиентский скрипт обработки сторонней миссии
private ["_do_hint","_mis_fname"];
#include "x_setup.sqf"
if (!X_Client) exitWith{};

_do_hint = _this select 0;

if (current_mission_index == -1) exitWith {};

#ifdef __DEFAULT__
_mis_fname = format ["x_missions\m\%2%1.sqf",current_mission_index,d_mission_filename];
#endif
#ifdef __TT__
_mis_fname = format ["x_missions\m\%2%1.sqf",current_mission_index,d_mission_filename];
#endif
#ifdef __SCHMALFELDEN__
_mis_fname = format ["x_missions\m_schmal\%2%1.sqf",current_mission_index,d_mission_filename];
#endif
#ifdef __UHAO__
_mis_fname = format ["x_missions\m_uhao\%2%1.sqf",current_mission_index,d_mission_filename];
#endif

if (!X_SPE) then {
	call compile preprocessFileLineNumbers _mis_fname;
};

sleep 0.01;

#ifdef __RANKED__
d_was_at_sm = false;
d_sm_running = true;
#endif

if (current_mission_index != -1) then {
	_posi_array = x_sm_pos;
	hint localize format[ "x_sm_pos=%1", x_sm_pos ];
	_posione = _posi_array select 0;
	if (x_sm_type != "convoy") then {
		_m_name = format ["XMISSIONM%1", current_mission_index + 1];
		[_m_name, _posione,"ICON","ColorRed",[1,1],localize "STR_SYS_157",0,"Destroy"] call XfCreateMarkerLocal; // "Доп.задание"
		#ifdef __RANKED__
			_posione spawn {
				private ["_posione"];
				_posione = _this;
				while {d_sm_running} do {
					if (player distance _posione < (d_ranked_a select 12)) exitWith {
						d_was_at_sm = true;
						d_sm_running = false;
					};
					sleep 3.012 + random 3;
				};
			};
		#endif
	} else {
		_m_name = format ["XMISSIONM%1", current_mission_index + 1];
		[_m_name, _posione,"ICON","ColorRed",[1,1],localize "STR_SYS_158",0,"Start"] call XfCreateMarkerLocal; // "Начало маршрута"
		_m_name = format ["XMISSIONM2%1", current_mission_index + 1];
		_posione = _posi_array select 1;
		[_m_name, _posione,"ICON","ColorRed",[1,1],localize "STR_SYS_159",0,"End"] call XfCreateMarkerLocal; // "Конец маршрута"
	};
};

if (_do_hint) then {
	hint  composeText[
		parseText("<t color='#f000ffff' size='1'>" + (localize "STR_SYS_181") + "</t>"), lineBreak,lineBreak,
		current_mission_text
	]; // "Новое задание:"
};

if (true) exitWith {};