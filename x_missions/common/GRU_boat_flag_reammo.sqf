/*
	x_missions\common\GRU_boat_flag_reammo.sqf
	author: Sygsky
	description:
	description:
        Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]
        target (_this select 0): Object - the object which the action is assigned to
        caller (_this select 1): Object - the unit that activated the action
        ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
        arguments (_this select 3): empty array []

	returns: nothing
*/

// check if is called on client at "remote_execute" sent from server
if (!X_Client) exitWith { hint localize "--- GRU_boat_flag_reammo.sqf: called not on client, exit!"};

#define BOAT_TYPE "RHIB2Turret"
#define BOAT_GRU_TYPE "RHIB"
#define MAX_DIST 10
#define ROUND_SLEEP 1

_flag = _this select 0;
// find nearest boat
_boat = nearestObject [ _flag, BOAT_GRU_TYPE ];
if ( isNull _boat ) exitWith {
    // "GRU boat not detected nearby flag"
    [ "msg_to_user", name player, ["STR_GRU_BOAT_ABSENT"], 0, 0, false, "no_more_waiting" ] call SYG_msgToUserParser;
};

if ( [_boat, _flag] call SYG_distance2D < MAX_DIST) exitWith {
    // "Boat cant be served on distance more than %1 meters"
    [ "msg_to_user", name player, ["STR_GRU_BOAT_BADDIST", MAX_DIST], 0, 0, false, "no_more_waiting" ] call SYG_msgToUserParser;
};

if ( typeOf _boat == BOAT_TYPE) exitWith {
    // "Can't serve US boats, only GRU allowed"
    [ "msg_to_user", name player, ["STR_GRU_BOAT_BADTYPE"], 0, 0, false, "no_more_waiting" ] call SYG_msgToUserParser;
};

_cnt = [_boat,"M2", "100Rnd_127x99_M2", true] call SYG_reloadAmmo;
if (_cnt < 0) exitWith {
    // "Can't re-ammo this boat, ask Engineer ACE about problem, say him number ""%1"""
    [ "msg_to_user", name player, ["STR_GRU_BOAT_ERRLOAD", _cnt], 0, 0, false, "no_more_waiting" ] call SYG_msgToUserParser;
};

if (_cnt == 0) exitWith {
    // "No need to reload, ammo is full"
    [ "msg_to_user", name player, ["STR_GRU_BOAT_FULLLOAD"], 0, 0, false, "no_more_waiting" ] call SYG_msgToUserParser;
};

for "_i" from 1 to _cnt do {
    sleep ROUND_SLEEP;
    ["say_sound",_boat, ["armory4","armory5"] call XfRandomArrayVal] call XSendNetStartScriptClientAll;
};

// "Ammo reloaded, %1n magazines added"
    [ "msg_to_user", name player, ["STR_GRU_BOAT_CNTLOAD", _cnt], 0, 0, false, "no_more_waiting" ] call SYG_msgToUserParser;

hint localize "+++ GRU_boat_flag_reammo.sqf finished!";
