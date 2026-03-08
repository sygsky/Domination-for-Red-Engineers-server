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

#define GRU_BOAT_MARKER "GRU_boat_marker"
#define BOAT_TYPE "RHIB2Turret"
#define BOAT_GRU_TYPE "RHIB"
#define MAX_DIST 10
#define ROUND_SLEEP 1

_flag = _this select 0;
// find nearest boat
_boat = nearestObject [ _flag, "Ship" ];
_str_boat_pos = "<no info about boat>";
if ( isNull _boat ) then {
    _cnt = 0;
    {
        if (typeOf _x isKindOf "Ship") then {
            if (typeOf _x == BOAT_GRU_TYPE) exitWith {
                _boat = _x;
            };
            sleep 0.3;
        };
        if (!isNull _boat) exitWith {};
        _cnt = _cnt + 1;
        if ((_cnt mod 20) == 0) then { sleep 0.1 };
    } forEach vehicles;
    if (!alive _boat) then {
        _str_boat_pos = localize "STR_GRU_BOAT_NULL" // "No GRU boat on map found"
    } else {
        _str_boat_pos = _boat call SYG_MsgOnPos0; // "%1 m. to %2 from %3"
    }
};
if ( !isNull _boat ) exitWith { // Boat found
    if (!(alive _boat)) exitWith { // Boat is dead
        _str = format[localize "STR_GRU_BOAT_DEAD", _str_boat_pos];
    } else {
        _type = markerType GRU_BOAT_MARKER;
        _str = "STR_GRU_BOAT_ABSENT"; // "GRU boat not detected nearby flag"
        if (_type == "") then {
            _str = "STR_GRU_BOAT_ABSENT_FULL"; // "GRU boat not detected nearby flag and marker also is absent"
        } else {
            _posMrk = markerPos GRU_BOAT_MARKER;
            _arr = nearestObjects [_posMrk, [BOAT_GRU_TYPE], 500];
            if ( count _arr == 0 ) exitWith { // No boat near marker, find it on map in vehicles collection
                _boat = objNull;
                _cnt = 0;
                {
                    if (typeOf _x isKindOf "Ship") then {
                        if (typeOf _x == BOAT_GRU_TYPE) exitWith {
                            _boat = _x;
                        };
                        sleep 0.3;
                    };
                    if (!isNull _boat) exitWith {};
                    _cnt = _cnt + 1;
                    if ((_cnt mod 20) == 0) then { sleep 0.1 };
                } forEach vehicles;
                if (alive _boat) exitWith {
                    _str = [_boat, 50] call SYG_MsgOnPos0;
                    _str = format[localize "STR_GRU_BOAT_FOUND_OUT_MARKER", _str ]; // format["Found GRU boat marker at %1, but no boat in radius 500 m. found", "150 m. to W from Pita"]
                };

                // "%1 m. to %2  from %3" ("150 m. to W from Pita") =>
                // [_obj|_pos, _localized_format_msg<,roundTo>] call SYG_MsgOnPosA;
                _str = [_posMrk, 50] call SYG_MsgOnPos0;
                _str = format[localize "STR_GRU_BOAT_FOUND_OUT_MARKER", _str ]; // format["Found GRU boat marker at %1, but no boat in radius 500 m. found", "150 m. to W from Pita"]
            } else {
                // Found ship near marker!!!
                _str = [_arr select 0, 50] call SYG_MsgOnPos0;
                _str = format[localize "STR_GRU_BOAT_FOUND_NEAR_MARKER", _str];  // format["Found GRU boat at %1, marker is near it", "150 m. to W from Pita"]
                _dist = round ([_posMrk,_posShip] call SYG_distance2D);
                _str = [format["%1 (%2 m)"], _str, _dist] call SYG_MsgOnPosA;
            };
        };

    };

    // "GRU boat not detected nearby flag"
    [ "msg_to_user", name player, _str, 0, 0, false, "losing_patience" ] call SYG_msgToUserParser;
};

if ( [_boat, _flag] call SYG_distance2D < MAX_DIST) exitWith {
    // "Boat cant be served on distance more than %1 meters"
    [ "msg_to_user", name player, ["STR_GRU_BOAT_BADDIST", MAX_DIST], 0, 0, false, "losing_patience" ] call SYG_msgToUserParser;
};

if ( (typeOf _boat) != BOAT_GRU_TYPE) exitWith {
    // "Can serve only GRU boat of type '%1', found  ship '%2' is not allowed"
    [ "msg_to_user", name player, ["STR_GRU_BOAT_BADTYPE", "BOAT_GRU_TYPE", typeOf _boat], 0, 0, false, "losing_patience" ] call SYG_msgToUserParser;
};

_cnt = [_boat,"M2", "100Rnd_127x99_M2", true] call SYG_reloadAmmo;
if (_cnt < 0) exitWith {
    // "Can't re-ammo this boat, ask Engineer ACE about problem, say him number ""%1"""
    [ "msg_to_user", name player, ["STR_GRU_BOAT_ERRLOAD", _cnt], 0, 0, false, "losing_patience" ] call SYG_msgToUserParser;
};

if (_cnt == 0) exitWith {
    // "No need to reload, ammo is full"
    [ "msg_to_user", name player, ["STR_GRU_BOAT_FULLLOAD"], 0, 0, false, "losing_patience" ] call SYG_msgToUserParser;
};

for "_i" from 1 to _cnt do {
    sleep ROUND_SLEEP;
    ["say_sound",_boat, ["armory4","armory5"] call XfRandomArrayVal] call XSendNetStartScriptClientAll;
};

// "Ammo reloaded, %1n magazines added"
    [ "msg_to_user", name player, ["STR_GRU_BOAT_CNTLOAD", _cnt], 0, 0, false, "no_more_waiting" ] call SYG_msgToUserParser;

hint localize "+++ GRU_boat_flag_reammo.sqf finished!";
