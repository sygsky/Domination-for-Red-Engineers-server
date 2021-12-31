/*
	scripts\new_year_check.sqf
	author: Sygsky
	description: play with new year period player activity (if score is changed player is active))).
	If player is active in NY period (-10 NY +10 minutes) then congratulates him and add +10 scores.
	Will work ONLY in MP, as in SP 'score' command doesn't work.
	input parameters: date execVM "scripts\new_year_check.sqf"
	returns: nothing
*/

if ( (_this select 1 != 12) && ((_this select 2) != 31 ) ) exitWith {}; // check to be 31-DECEMBER-XXXX

// how many seconds to sleep up to 600 seconds before the NY
_sleep_seconds = (24 - daytime) * 3600 - 600;
if (_sleep_seconds > 0) then { sleep _sleep_seconds; }; // wait to the 10 minutes before NY
_score = score player; // store score
_sleep_seconds = (24 - daytime) * 3600 + 300; // sleep interval to the 300 sconds after NY
sleep _sleep_seconds; // slip to the 5 minutes after NY
if ((score player) != _score ) then {
	10 call  SYG_addBonusScore;
	["msg_to_user", "", ["STR_SYS_NEW_YEAR", 10 ], 0, 0, false, "good_news"] call SYG_msgToUserParser; // "За боевую активность в Новый Год главный инженер вручает Вам +%1 очков"
	[ "log2server", name player, format[ "+++ new_year_check.sqf: For combat activity on New Year's Eve, the chief engineer awards %1 with +%2 points", name player, 10] ] call XSendNetStartScriptServer;
};