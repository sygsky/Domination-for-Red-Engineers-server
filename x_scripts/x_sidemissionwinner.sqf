﻿// by Xeno, x_scripts/x_sidemissionwinner.sqf. Called from x_scripts\x_funcs\x_netinitclient.sqf on "sm_res_client" event
// sent from call to XSideMissionResolved on server, on client net come with code "sm_res_client"
private ["_bonus_pos","_bonus_string","_bonus_vehicle","_s"];

if (!X_Client) exitWith {};

#include "x_setup.sqf"

//#define __DEBUG__

#define PENALTY_PRESENCE_TIME 600 // (10 minutes) the time spent on the island, after which the player is penalized for not completing the SM mission

sleep 1;

if (x_sm_type == "undefined") then { // remove all possible markers
	_i = 1;
	{
		deleteMarkerLocal format["%1_%2",sm_marker_name, _i];
		_i = _i + 1;
	} forEach x_sm_pos;
//	hint localize format["+++ x_sidemissionwinner.sqf: deleteMarkerLocal ""XMISSIONM2%1"" (found as ""%2"")", current_mission_index + 1, _s];
} else {
	// clear finished side mission markers
	deleteMarkerLocal sm_marker_name;
	//hint localize format["+++ x_sidemissionwinner.sqf: deleteMarkerLocal ""XMISSIONM%1"" (found as ""%2"")", current_mission_index + 1, _s];
	if (x_sm_type == "convoy") then {
		deleteMarkerLocal sm_marker_name2;
	//	hint localize format["+++ x_sidemissionwinner.sqf: deleteMarkerLocal ""XMISSIONM2%1"" (found as ""%2"")", current_mission_index + 1, _s];
	};
};

current_mission_text = localize "STR_SYS_120"; // "Дополнительное задание ещё не назначено...";

if (side_mission_winner != 0 && bonus_number != -1) then {
#ifdef __DOSAAF_BONUS__
	_bonus_pos = localize "STR_SYS_309_1";//"near last side mission.";
#else
	_bonus_pos = localize "STR_SYS_309";//"on the base.";
#endif
	_type_name = sm_bonus_vehicle_array select bonus_number;
	_bonus_vehicle = [_type_name,0] call XfGetDisplayName;

#ifdef __RANKED__
	_get_points = false;
	if ( isNil "d_sm_p_pos") then {d_sm_p_pos = [sm_p_pos select 0]};
	if ( !d_was_at_sm ) then {
		_posione = d_sm_p_pos;
		_get_points = ((player distance _posione) < (d_ranked_a select 12)); // 250 m
	} else { // not is nil
		_get_points =  d_was_at_sm;
		if (!_get_points) then {
			_get_points = (player distance d_sm_p_pos)< (d_ranked_a select 12); // 250 m
		};
	};
    hint localize format["+++ x_sidemissionwinner.sqf : d_sm_p_pos %1, d_was_at_sm %2, x_sm_pos %3",
    	d_sm_p_pos,
        if (isNil "d_was_at_sm") then {"nil"} else {d_was_at_sm},
        if (isNil "x_sm_pos") then {"nil"} else {x_sm_pos}
    ];
	if (_get_points) then {
		(format [localize "STR_SYS_125"/* "Participating in the side mission execution you get points: +%1 and %2 !!!" */,(d_ranked_a select 11),_bonus_vehicle]) call XfHQChat;
		//player addScore (d_ranked_a select 11);
		(d_ranked_a select 11) call SYG_addBonusScore;
		playSound "good_news";
	};
#endif
	_bonus_string = "<template>";
#ifndef __TT__
	_bonus_string = format[localize "STR_SYS_126", _bonus_vehicle, _bonus_pos]; //"Ваша команда получает %1. Искать здесь: %2"
#else
	_team = (
		switch (side_mission_winner) do {
			case 1: {"Team Racs gets"};
			case 2: {"Team West gets"};
			case 123: {"Both teams get"};
		}
	);
	_bonus_string = format["%1 a %2, it's available at %3", _team, _bonus_vehicle, _bonus_pos];
#endif

	_s = composeText[
		parseText("<t color='#f0ffff00' size='1'>" + (localize "STR_SYS_127")/* "Дополнительное задание выполнено" */ + "</t>"), lineBreak,lineBreak,
		localize "STR_SYS_128"/* "Поздравления..." */, lineBreak,lineBreak,
		current_mission_resolved_text, lineBreak, lineBreak,
		_bonus_string
	];
	hint  _s;
	_s = format ["%1! %2",localize "STR_SYS_127", _bonus_string];
	_s call XfHQChat; // "Side mission accomplished"
    hint localize ("+++ SideMission: " + _s);

} else { // if (side_mission_winner != 0 && bonus_number != -1) then {...} else {...
    _s = switch (side_mission_winner) do {
        case   -1 : {"STR_SYS_129_1"/*"Персона, намеченная к ликвидации, погибла в результате трагического инцидента..."*/};
        case   -2 : {"STR_SYS_129_2"/*"Враг решил взорвать все сам..."*/};
        case   -3 : {"STR_SYS_129_9"}; // "The enemy sensed danger and escaped..." - missins for king etc with predefined building or officer to catch killed!!!
        case -300 : {"STR_SYS_129_3"/*"Конвой достиг места назначения..."*/};
        case -400 : {"STR_SYS_129_4"/*"Ни один из заложников не выжил..."*/};
        case -500 : {"STR_SYS_129_5"/*"Вражеский офицер спятил и застрелился..."*/};
        case -600 : {"STR_SYS_129_6"/*"Образец захваченной у врага техники развалился до того, как попал в руки ГРУ на базе..."*/};
        case -700 : {"STR_SYS_129_7"/*"Пилоты скончались от столбняка до прибытия на базу..."*/};
        case -701 : {"STR_SYS_129_8"/*"Bus is destroyed or all civilians are dead"*/}; // the future SM type - "Safely deliver a group of civilians by bus to their destination!"
        case -702 : {"STR_RADAR_FAILED"/*"Mission failed, no help from GRU!"*/}; // the new SM type (GRu radiorelay) - "Safely deliver a new radio mast to the north mountine top and return truck to the base!"
        default {"STR_SYS_129_100"}; // "You lost a fortune..."
    };
	_s = localize _s;

	if ( _s != "") then {
        _penalty = d_ranked_a select 11; // Lower all players who are on island enough time in rank on such bad event!!!
        //player addScore (-_penalty);
        _time = floor (time);
        _guilty = (_time >= PENALTY_PRESENCE_TIME) && (base_visit_mission > 0); // Is guilty if in mission predefined period and was on base before it.
        if ( _guilty ) then {
            (-_penalty) call SYG_addBonusScore;
            playSound "whold"; // report failure and score reducing
        };
		hint composeText[
			parseText("<t color='#f0ff00ff' size='1'>" + localize "STR_SYS_129"/* "Side mission failed!!!" */ + "</t>"),
			lineBreak,
			lineBreak,
			_s
			];
        if ( _guilty ) then {
    		_s = format [localize "STR_SYS_130", _penalty]; // /* ""For failure of the side mission You are personally held accountable. Deducted %1 points. So will be with everyone!" */
        } else {
        	if (base_visit_mission > 0) then {
	    		_s = format [localize "STR_SYS_130_0", _time, _penalty]; // "You have been on the island for less than %1 minutes, so you have not had your points reduced (-%2)."
        	} else {
				_s = localize "STR_SYS_130_1"; // "You haven't reached the base until you are a SpecNaz GRU soldier, and you are not guilty of missing the convoy."
        	};
        };
		_s call XfHQChat;
		hint localize ("*** SideMission: " + (localize "STR_SYS_129") +  " #" + str(current_mission_index));
	};
};
//+++ Sygsky: fix a bug that did not clear variable in the next two lines if a mission failed.
// Var will be set again in the next mission.
d_sm_p_pos = nil;
publicVariable "d_sm_p_pos";

sleep 1;
side_mission_winner = 0;
bonus_number = -1;
