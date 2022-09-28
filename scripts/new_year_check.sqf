/*
	scripts\new_year_check.sqf
	author: Sygsky
	description: play with new year period player activity (if score is changed player is active))).
	If player is active in NY period (-10 NY +10 minutes) then congratulates him and add +10 scores.
	Will work ONLY in MP, as in SP 'score' command doesn't work.
	input parameters: date execVM "scripts\new_year_check.sqf"
	returns: nothing
*/

_start = _this;
if ( (_start select 0) == 0 ) exitWith {"--- new_year_check.sqf: multipleer not found, exiting"};
if ( ((_start select 1) != 12) || ((_start select 2) < 30 ) ) exitWith {"--- new_year_check.sqf: it is before 30th of December, good bye, soldier!"}; // check to be 31-DECEMBER-XXXX
hint localize format["+++ new_year_check.sqf: new year activity procedure started with missionStart = %1", _start];

_time = time; // current time of mission
_nydate = [(_start select 0) + 1, 1, 1, 0, 0, 0]; // New Year date/time is is XXXX-JAN-01 00:00:00

// call as: _diff_in_seconds = [_date_next, _date_prev] call SYG_getDateDiffInSeconds
_nysecs = [ _nydate, _start ] call SYG_getDateDiffInSeconds; // seconds to New Year's Eve
_sleep = _nysecs - _time - 600; // how to sleep to awake 10 minutes before NY
// how many seconds to sleep up to 600 seconds before the NY
if (_sleep <= 0) exitWith {format["+++ new_year_check.sqf: you are %1 seconds late to be checked on the NY event", _sleep]};
// STR_SYS_NEW_YEAR_START
["msg_to_user", "", ["STR_SYS_NEW_YEAR_START" ], 0, 0, false, "drum_fanfare"] spawn SYG_msgToUserParser; // ""The New Year's Eve Combat Check Procedure has begun!""
sleep _sleep; // wait up to the 10 minutes before NY
_score = score player; // remember current score befoe NY
playSound "drum_fanfare"; // NY check procedure started
_sleep =  900; // sleep period to the 5 minutes after NY
sleep _sleep; // slip to the 5 minutes after NY
if ((score player) != _score ) exitWith { // Combat activity detected!!! Score changed during 15 minute interval over NY
	10 call  SYG_addBonusScore;
	["msg_to_user", "", ["STR_SYS_NEW_YEAR", 10 ], 0, 0, false, "good_news"] spawn SYG_msgToUserParser; // ""For combat activity on New Year's Eve, the chief engineer awards you +%1 points.""
	[ "log2server", name player, format[ "+++ new_year_check.sqf: For combat activity on New Year's Eve, the chief engineer awards %1 with +%2 points", name player, 10] ] call XSendNetStartScriptServer;
};
hint localize "-- new_year_check.sqf: The test of New Year's activity did not yield results";
