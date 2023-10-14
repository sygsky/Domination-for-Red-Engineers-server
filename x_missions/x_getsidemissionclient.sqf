// by Xeno, x_missions\x_getsidemissionclient.sqf, клиентский скрипт обработки сторонней миссии
private ["_do_hint","_mis_fname"];
#include "x_setup.sqf"
if (!X_Client) exitWith{};

_do_hint = _this select 0;

if (current_mission_index == -1) exitWith {};

if (!X_SPE) then {

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

	call compile preprocessFileLineNumbers _mis_fname;
};

sleep 0.01;

#ifdef __RANKED__
d_was_at_sm = false;
d_sm_running = true;
#endif

if (current_mission_index != -1) then {
	if (isNil "d_sm_p_pos") then {d_sm_p_pos = x_sm_pos select 0};
	sm_marker_name = format ["XMISSIONM%1", current_mission_index + 1]; // first (alone) marker
	hint localize format[ "+++ x_getsidemissionclient.sqf: x_sm_pos = %1, d_sm_p_pos = %2, marker name = %3", x_sm_pos, d_sm_p_pos, sm_marker_name ];
	if (x_sm_type == "normal") exitWith {
		[sm_marker_name, d_sm_p_pos,"ICON","ColorRedAlpha",[1,1],localize "STR_SYS_157",0,"Destroy"] call XfCreateMarkerLocal; // "Side mission"
        #ifdef __RANKED__
        d_sm_p_pos spawn {
            private ["_pos","_dist"];
            _pos = _this;
            _dist = d_ranked_a select 12; // dist from side mission point
            while {d_sm_running} do {
                if (player distance _pos < _dist) exitWith {
                    d_was_at_sm = true;
                    d_sm_running = false;
					hint localize "+++ x_getsidemissionclient.sqf: player assigned to be was at SM";
                };
                sleep (10.012 + (random 3));
            };
        };
        #endif
	};

	if (x_sm_type == "convoy") exitWith {
		[sm_marker_name, x_sm_pos select 0,"ICON","ColorRedAlpha",[1,1],localize "STR_SYS_158",0,"Start"] call XfCreateMarkerLocal; // "Start"
		sm_marker_name2 = format ["XMISSIONM2%1", current_mission_index + 1];
		[sm_marker_name2, x_sm_pos select 1,"ICON","ColorRedAlpha",[1,1],localize "STR_SYS_159",0,"End"] call XfCreateMarkerLocal; // "Finish"
	};

	// draw the markers around map to mark possible places to resolve this SM
	if (x_sm_type == "undefined") exitWith {
		_i = 1;
		{
//			[format["%1_%2",sm_marker_name, _i], _x,"ICON","ColorRedAlpha",[0.5,0.5],localize "STR_SYS_156",0,"Unknown"] call XfCreateMarkerLocal; // "Radiomast install"
			[format["%1_%2",sm_marker_name, _i], _x,"ICON","ColorGreenAlpha",[0.5,0.5],localize "STR_SYS_156",0,"Unknown"] call XfCreateMarkerLocal; // "Radiomast install"
			_i = _i + 1;
		} forEach x_sm_pos;
	};

};

if (_do_hint) then {
	_msg = current_mission_text call XfRemoveLineBreak;
	hint  composeText[
		parseText("<t color='#f000ffff' size='1'>" + (localize "STR_SYS_181") + "</t>"), lineBreak,lineBreak,
		_msg
	]; // "New order:"
	playSound "desant";
};

if (true) exitWith {};