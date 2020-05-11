// by Xeno, x_scripts/x_target_clear_client.sqf
private ["_current_target_name","_target_array2"];

#include "x_setup.sqf"
#include "x_macros.sqf"

#define OBJECT_ID (_target_array2 select 3)

if (!X_Client) exitWith {};

__TargetInfo

_current_target_name setMarkerColorLocal "ColorGreen";

_current_target_pos = _target_array2 select 0;

client_target_counter = client_target_counter + 1;

call compile format ["""%1"" objStatus ""DONE"";", OBJECT_ID]; // mark just liberated town with correcponding marker in the diary

if (client_target_counter < number_targets) then {
	_type_name = mt_bonus_vehicle_array select extra_bonus_number;

	_bonus_vehicle = [_type_name, 0] call XfGetDisplayName;

	_bonus_pos = localize "STR_SYS_309";//"на базе.";

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
	if (__RankedVer) then
	{
		_strBonus = "";
		if ( player distance _current_target_pos <= (d_ranked_a select 10) ) then
		{
		    _strBonus = format[ localize "STR_SYS_1102_1", d_ranked_a select 9 ];
            player addScore (d_ranked_a select 9); // you get point only being in the town!
            playSound "good_news";
		};
        (format [localize "STR_SYS_1102"/* "For the liberation of the settlement you get %1%2 !" */,_strBonus, _bonus_vehicle]) call XfHQChat;
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
    hint localize "+++ last town is cleared ++=+";
	_mt_str = format ["%1 %2",format[localize "STR_SYS_1100_1", _current_target_name], localize "STR_SYS_1101_1"]; // "Last settlement %1 has been cleared!!! The enemy has finally fled. You just have to clean up the last occupied city!"
	
#ifndef __TT__
	hint  composeText[
		parseText("<t color='#f02b11ed' size='1'>" + _mt_str + "</t>"), lineBreak,lineBreak,
		localize "STR_SYS_128" /* "Поздравления..." */
	];
    if ( player distance _current_target_pos <= (d_ranked_a select 10) ) then
    {
        player addScore (d_ranked_a select 9); // you get point only being in the town!
        playSound "good_news";
    };

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
