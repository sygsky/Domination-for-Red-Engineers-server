/*
    scripts\baseillum\illum_start.sqf
	author: Sygsky
	description: start illumination over base:
	    1. Check time, if not night, print refuse message
	    2. If night, send request to server
	    3. If server accept it, it send back confirm message to subtract score according to you rank (10 * (rank_index +1)
	returns: nothing
*/

//hint localize format["+++ illum_start.sqf: _this = %1, X_Client = %2", _this, X_Client];
if (!X_Client) exitWith {};

#include "x_setup.sqf"

#ifdef __RANKED__
_rank_id = player call XGetRankIndexFromScore; // rank index
_score = round((_rank_id max 1) call XGetScoreFromRank) / 10; // How costs the illumination above base. For Private as for Corporal
#endif

_id = call SYG_getDayTimeId;
_str = call SYG_nowTimeToStr;
//hint localize format[ "+++ illum_start.sqf: (call SYG_getDayTimeId) = %1, time = %2", _id, _str];

if ((call SYG_getDayTimeId) != 0) exitWith {
    // this is not night
#ifdef __RANKED__
    // "Come again at night (after message). And don't forget the points (%1)"
    [ "msg_to_user", "",  [ ["STR_ILLUM_2", _score] ], 0, 0, false, "losing_patience" ] call SYG_msgToUserParser;
#else
    // "Come again at night (after message)"
    [ "msg_to_user", "",  [ ["STR_ILLUM_2_0"] ], 0, 0, false, "losing_patience" ] call SYG_msgToUserParser;
#endif
};

#ifdef __RANKED__
// Check if player have enough scores to launch illumination
if (score player < _score ) exitWith {
    // "You don't have enough points. Required, with your rank, %1"
    ["msg_to_user", "",  [ [ "STR_ILLUM_1", _score] ], 0, 0, false, "losing_patience" ] call SYG_msgToUserParser;
};
#endif
// send request message "illum_over_base" to the server , it will response with refuse text message ("STR_ILLUM"), or by event "illum_over_base" to confirm and subtract your scores
["illum_over_base", name player] call XSendNetStartScriptServer; // thats all
