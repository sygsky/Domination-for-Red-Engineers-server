/*
	x_missions\common\sideradar\radio_killed.sqf, created at JUN 2022
	author: Sygsky
	description: deletes the radar on mission failure
	params: [_killed, _killer]
	_killed = _this select 0;
	_killer = _this select 1;
	returns: nothing
*/

if (!isServer) exitWith{};

#include "sideradio_vars.sqf"

sideradio_status = 0; // radar is dead
publicVariable "sideradio_status";

_killer = _this select 1;
_name = if ( isPlayer _killer ) then { name _killer } else { if (isNull _killer) then {"<unknown>"} else {typeOf _killer} };
_cnt = 1;
_killed = _this select 0;
_pos = getPos _killed;

hint localize format[ "+++ radio_killed.sqf: radar deleted by %1 at %2; status = %3, send %1 to the jail", _name, [_this select 0, 10] call SYG_MsgOnPosE0, sideradio_status ];
//#648 - handle with mast killed. In future - restart mission from the scratch, now - sen dkilled to the jail
if (isPlayer _killer) then {
	while { !alive _killer } do { sleep 0.1 };
	sleep 0.2;
	[localize "STR_RADAR_KILLED"] execVM "scripts\jail.sqf"; // "Hint: You're being punished for destroying a GRU mast. Are you not a spy?"
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
