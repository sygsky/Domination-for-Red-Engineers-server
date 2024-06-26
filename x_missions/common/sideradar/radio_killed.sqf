/*
	x_missions\common\sideradar\radio_killed.sqf, created at JUN 2022
	author: Sygsky
	description: deletes the radar on mission failure
	params: [_killed, _killer]
	_killed = _this select 0;
	_killer = _this select 1;
	returns: nothing
*/

if (!isServer) exitWith{hint localize "--- radio_killed.sqf called on client!"};

#include "sideradio_vars.sqf"

sideradio_status = 0; // radar is dead
publicVariable "sideradio_status";

_killer = _this select 1;
_name = if ( isPlayer _killer ) then { name _killer } else { if (isNull _killer) then {"<unknown>"} else {typeOf _killer} };
_cnt = 1;
_killed = _this select 0;
_pos = getPos _killed;

//#648 - handle with mast killed. In future - restart sub-mission from the scratch, now - send killer to the jail
if (isPlayer _killer) then {
	while { !alive _killer } do { sleep 0.1 };
	sleep 0.2;
	// Example: ["msg_to_user", "", ["STR_RADAR_KILLER", _majak ], 0, 3, false, "return"] spawn SYG_msgToUserParser;
	_demote_score = (score _killer) call SYG_demoteByScore;
	// STR_RADAR_KILLED: "Hint: You're being punished (-%1) for destroying a GRU mast. Are you not a spy?"
	// STR_RADAR_KILLER: "%1 is being punished (-%2) for destroying a GRU mast. Isn't he a spy?"
	// String format to send to jail is predefined to have 1 parameter (demote scores)
	_str = format["if ((name player) == '%1') then {['PENALTY',%2,'STR_RADAR_KILLED'] execVM 'scripts\jail.sqf'} else {['msg_to_user', '', [['STR_RADAR_KILLER','%1',%2]],0,0,false,'losing_patience'] call SYG_msgToUserParser};", name _killer, _demote_score];
	[ "remote_execute", _str, "<server>" ] call XSendNetStartScriptClientAll; // Sent to all clients only
    hint localize format[ "+++ radio_service: radio_killed.sqf radar deleted by %1 (score %2) at %3; status = %4, send %1 to the jail and demote score by -%5",
        _name,
        score _killer,
        [_this select 0, 10] call SYG_MsgOnPosE0,
        sideradio_status,
        _demote_score
    ];
    
};

// remove radar after 10 minutes of players absence around 300 meters of radar.
while {!(isNull _killed)} do {
    sleep (60 + (random 30)); // 1-1.5 minutes loop
    _player =  [_pos, 200] call SYG_findNearestPlayer; // find any alive player in/out vehicles
    if ( (! (alive _player)) || ( _cnt > 10) ) exitWith { // 10 times with 60 seconds check if no players nearby
        _pos = getPos _killed;
        deleteVehicle _killed;
        ["say_sound", _pos, "steal"] call XSendNetStartScriptClient;
    };
    _cnt = _cnt + 1;
};
