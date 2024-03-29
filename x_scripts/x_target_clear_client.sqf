﻿// by Xeno, x_scripts/x_target_clear_client.sqf
// parameters _this is [counter attack state (true if counterattack occured or false if not), _player_bonus_score_for_finished_town, _all_players_names_and_bonus_array]
//
if (!X_Client) exitWith {};
hint localize format["+++ DEBUG: x_target_clear_client.sqf: counterattack is %1, town bonus to player %2", _this select 0, _this select 1];

private ["_current_target_name","_target_array2"];

#include "x_setup.sqf"
#include "x_macros.sqf"

#define OBJECT_ID (_target_array2 select 3)

//__TargetInfo
_target_array2 = target_names select current_target_index;_current_target_name = _target_array2 select 1;

_current_target_name setMarkerColorLocal "ColorGreenAlpha";

_current_target_pos = _target_array2 select 0;

client_target_counter = client_target_counter + 1;

call compile format ["""%1"" objStatus ""DONE"";", OBJECT_ID]; // mark just liberated town with corresponding marker in the diary

//hint localize format["+++ DEBUG: x_target_clear_client.sqf: client_target_counter (%1) < number_targets (%2) ?", client_target_counter, number_targets];

if (client_target_counter < number_targets) then {
	_type_name = mt_bonus_vehicle_array select extra_bonus_number;

	_bonus_vehicle = [_type_name, 0] call XfGetDisplayName;

#ifdef __DOSAAF_BONUS__
	_bonus_pos = localize "STR_SYS_309_1";//"near last side mission.";
#else
	_bonus_pos = localize "STR_SYS_309";//"on the base.";
#endif

	_mt_str = format [localize "STR_SYS_1100", _current_target_name]; //"%1 освобождён!!!"
	
#ifndef __TT__
	_bonus_string = format[localize "STR_SYS_126", _bonus_vehicle, _bonus_pos]; //"Ваша команда получает %1. Искать здесь: %2"

	hint  composeText
	[
		parseText("<t color='#f02b11ed' size='1'>" + _mt_str + "</t>"), lineBreak,lineBreak,
		localize "STR_SYS_128" /* "Поздравления..." */, lineBreak,lineBreak,
		_bonus_string, lineBreak,lineBreak,
		localize "STR_SYS_1101"/* "Ожидайте дальнейших распоряжений..." */
	];
	if (__RankedVer) then {
		_strBonus = "0";
		_strCountera = "";
		//_dist = d_ranked_a select 10;
	    _score = _this select 1;
		if ( _score > 0 ) then {
		    _strBonus = format[ localize "STR_SYS_1102_1", _score, if (_score == (d_ranked_a select 9)) then {" MAX"} else {""} ]; // "points (%1%2) and "
		    // #412 add score per town only if you get positive points for this town
		    if (_this select 0) then { // counterattack occured
		    	_strCountera = localize "STR_SYS_1102_3"; // "and repelling a counterattack "
		    };
            //player addScore _score; // you get point only being in the town!
            _score call SYG_addBonusScore;
            playSound "good_news";
			// "For the liberation of the settlement %1you gets %2%3!"
			( format [ localize "STR_SYS_1102",_strCountera, _strBonus, _bonus_vehicle ] ) call XfHQChat;
		} else {
			if (_score == 0 ) exitWith  {
				// "For the liberation of a settlement the team receives (+%1). You did not participate in the liberation of the city!"
	            playSound "losing_patience";
				( format [localize "STR_SYS_1102_0", _bonus_vehicle] ) call XfHQChat;
			};
            playSound "good_news";
			// _score < 0 (-1): last target cleared, print farewell message
			( localize "STR_SYS_1102_4" ) call XfHQChat;
		};

		if (count _this  > 2) then { // todo: find player[s] with maximum city liberation bonus and inform the player about about
			_arr = _this select 2;
			 if ( typeName _arr != "ARRAY" ) exitWith { hint localize format["--- expected town bonus array not ARRAY (%1)", typeOf (_this select 2)]; }; // --- not array
			 if ( count _arr == 0 ) exitWith { hint localize "--- expected town bonus array length is zero"; }; // --- empty array
			_arr = _arr call SYG_mainTownBonusInfoStr; // get info str on main town bonus scores
			( format["%1. %2",_arr select 0, _arr select 1]) call XfHQChat; // "Max bonus %1. Min bonus %1"
		}
	};
#endif

#ifdef __TT__
	_winner_string = "";
	switch (mt_winner) do {
		case 1: {_winner_string = format ["The US Team won the main target with %1 : %2 kill points.\nThe US Team gets 10 main points.",kill_points_west,kill_points_racs];};
		case 2: {_winner_string = format ["The RACS Team won the main target with %1 : %2 kill points.\nThe RACS Team gets 10 main points.",kill_points_racs,kill_points_west];};
		case 123: {_winner_string = format ["Both teams have %1 kill points.\nBoth teams get 5 main points.",kill_points_racs];};
	};
	_team = (
		switch (mt_winner) do {
			case 1: {"Team Racs gets"};
			case 2: {"Team West gets"};
			case 123: {"Both teams get"};
		}
	);
	_bonus_string = format["%1 a %2, it's available at %3", _team, _bonus_vehicle, _bonus_pos];

	hint  composeText[
		parseText("<t color='#f02b11ed' size='1'>" + _mt_str + "</t>"), lineBreak,lineBreak,
		"Congratulations...", lineBreak,lineBreak,
		_bonus_string, lineBreak,lineBreak,
		"Waiting for new orders..."
	];
	titleText [_winner_string, "PLAIN"];
	if (__RankedVer) then {
		if (player distance _current_target_pos < 400) then {
			"Вы получаете 20 очков за взятие города!!!" call XfHQChat;
			player addScore 20;
		};
	};
#endif

	(format ["%1 %2", format[localize "STR_SYS_1100", _current_target_name], localize "STR_SYS_1101" ]) call XfHQChat; // "%1 has been cleared!!! Waiting for new orders..."
} else {

/**
        if ( (count d_recapture_indices > 0) && (!stop_sm) ) then { _str = "STR_SYS_121_3_FULL" }
        else {
            if ( !stop_sm ) then { _str = "STR_SYS_121_3_SM" } else { _str = "STR_SYS_121_3_RECAPTURED"};
        };

*/
    hint localize "+++ x_target_clear_client.sqf: last town is cleared ++=+";
    _mt_str = format ["%1 %2",format[localize "STR_SYS_1100_1", _current_target_name], localize "STR_SYS_1101_1"]; // "Last settlement %1 has been cleared!!!", ""The enemy has finally fled. You just have to clean up the last occupied city and finish last SM!"

#ifndef __TT__
	hint  composeText[
		parseText("<t color='#f02b11ed' size='1'>" + _mt_str + "</t>"), lineBreak,lineBreak,
		localize "STR_SYS_128" /* "Congratulations..." */
	];
    if ( player distance _current_target_pos <= (d_ranked_a select 10) ) then {
        //player addScore (d_ranked_a select 9); // you get point only being in the town!
        (d_ranked_a select 9) call SYG_addBonusScore;
        playSound "good_news";
    };
    titleText [localize "STR_SYS_1230" , "PLAIN"]; // "H U R R A H!"
#endif
#ifdef __TT__
	_winner_string = "";
	switch (mt_winner) do {
		case 1: {_winner_string = format ["The US Team won the main target with %1 : %2 kill points.\nThe US Team gets 10 main points.",kill_points_west,kill_points_racs];};
		case 2: {_winner_string = format ["The RACS Team won the main target with %1 : %2 kill points.\nThe RACS Team gets 10 main points.",kill_points_racs,kill_points_west];};
		case 123: {_winner_string = format ["Both teams have %1 kill points.\nBoth teams get 10 main points.",kill_points_racs];};
	};
	hint  composeText[
		parseText("<t color='#f02b11ed' size='1'>" + _mt_str + "</t>"), lineBreak,lineBreak,
		"Congratulations..."
	];
	titleText [_winner_string, "PLAIN"];
#endif
	_mt_str call XfHQChat;
};

sleep 2;

current_target_index = -1;

if (true) exitWith {};
