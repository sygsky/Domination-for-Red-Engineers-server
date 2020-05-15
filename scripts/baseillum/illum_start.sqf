/*
	author: Sygsky
	description: start illumination over base:
	    1. Check time, if not night, print refuse message
	    2. If night, send request to server
	    3. If server accept it, it send back confirm message to subtract score according to you rank (10 * (rank_index +1)
	returns: nothing
*/

if (isServer) exitWith {};

#include "x_setup.sqf"
#define COST_PER_RANK 10

if ((call SYG_getDayTimeId) != 0) exitWith {
    // this is not night
#ifdef __RANKED__
    ["msg_to_user", "",  [ ["STR_ILLUM_2", (player call XGetRankIndexFromScoreExt) * COST_PER_RANK]], 0, 2, false, "losing_patience" ] call SYG_msgToUserParser;
#else
    ["msg_to_user", "",  [ ["STR_ILLUM_2_0"]], 0, 2, false, "losing_patience" ] call SYG_msgToUserParser;
#endif
};

// send request message "illum_over_base" to the server , it must return ot with refuse message ("STR_ILLUM"), or by request for scores "illum_over_base"
["illum_over_base", name player] call XSendNetStartScriptServer; // thats all
