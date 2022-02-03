// by Xeno, x_scripts/x_sidemissionwinner.sqf. Called from x_scripts\x_funcs\x_netinitclient.sqf on "sm_res_client" event
// sent from call to XSideMissionResolved on server
private ["_bonus_pos","_bonus_string","_bonus_vehicle","_s"];

if (!X_Client) exitWith {};

#include "x_setup.sqf"

//#define __DEBUG__

sleep 1;

// clear finished side mission markers
_mrk = format["XMISSIONM%1",current_mission_index + 1];
deleteMarkerLocal _mkr;
//call compile format ["deleteMarkerLocal ""XMISSIONM%1"";",current_mission_index + 1];
if (x_sm_type == "convoy") then {
	_mrk = format["XMISSIONM2%1",current_mission_index + 1];
	deleteMarkerLocal _mkr;
//	call compile format ["deleteMarkerLocal ""XMISSIONM2%1"";",current_mission_index + 1];
};

current_mission_text = localize "STR_SYS_120"; // "Дополнительное задание ещё не назначено...";

if (side_mission_winner != 0 && bonus_number != -1) then {

	_bonus_pos = localize "STR_SYS_309";//"on the base.";
	_type_name = sm_bonus_vehicle_array select bonus_number;
	_bonus_vehicle = [_type_name,0] call XfGetDisplayName;

#ifdef __RANKED__
	_get_points = false;
	if ( ( isNil "d_sm_p_pos") && (!d_was_at_sm)) then {
		_posi_array = x_sm_pos;
		_posione = _posi_array select 0;
		_get_points = (player distance _posione < (d_ranked_a select 12));
	} else { // not is nil
		_get_points =  d_was_at_sm;
		if (!_get_points) then {
			_get_points = (player distance d_sm_p_pos < (d_ranked_a select 12));
		};
	};
    hint localize format["+++ x_sidemissionwinner.sqf : d_sm_p_pos %1, d_was_at_sm %2, x_sm_pos %3",
        if (isNil "d_sm_p_pos") then {"nil"} else {d_sm_p_pos},
        if (isNil "d_was_at_sm") then {"nil"} else {d_was_at_sm},
        if (isNil "x_sm_pos") then {"nil"} else {x_sm_pos}
    ];
	if (_get_points) then {
		(format [localize "STR_SYS_125"/* "Participating in the side mission execution you get points: +%1 and %2 !!!" */,(d_ranked_a select 11),_bonus_vehicle]) call XfHQChat;
		//player addScore (d_ranked_a select 11);
		(d_ranked_a select 11) call SYG_addBonusScore;
		playSound "good_news";
	};
	d_sm_p_pos = nil;
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
        default {"STR_SYS_129_100"}; // "You lost a fortune..."
    };
	_s = localize _s;

	if (_s != "") then {
        _penalty = d_ranked_a select 11; // todo: lower all players in rank on such bad event!!!
        //player addScore (-_penalty);
        (-_penalty) call SYG_addBonusScore;
		hint composeText[ 
			parseText("<t color='#f0ff00ff' size='1'>" + localize "STR_SYS_129"/* "Side mission failed!!!" */ + "</t>"),
			lineBreak,
			lineBreak,
			_s
			];
		_s = format [localize "STR_SYS_130"/* ""For failure of the side mission You are personally held accountable. Deducted %1 points. So will be with everyone!" */, _penalty];
		_s call XfHQChat;
		hint localize ("--- SideMission: " + (localize "STR_SYS_129"));
	};
};

sleep 1;
side_mission_winner = 0;
bonus_number = -1;
