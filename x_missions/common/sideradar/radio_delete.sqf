/*
	x_missions\common\sideradar\radio_delete.sqf, created at JUN 2022
	author: Sygsky
	description: deletes the radar on mission failure
	params: [_killed, _killer]
	_killed = _this select 0;
	_killer = _this select 1;
	returns: nothing
*/

if (!isServer) exitWith{};

#include "sideradio_vars.sqf"

sideradio_status = -1; // radar is down, no truck available
publicVariable "sideradio_status";

_killer = _this select 1;
_name = if ( isPlayer _killer ) then { name _killer } else { typeOf _killer };
hint localize format[ "+++ radio_delete.sqf: radar deleted by %1", _name ];

_cnt = 0;
_killed = _this select 0;
_pos = getPos _killed;

// remove radar after 10 minutes of players absence around 300 meters of radar.
while (!(isNull _killed)) do {
    sleep (60 + (random 60));
    _player =  [_pos, 300] call SYG_findNearestPlayer; // find any alive player in/out vehicles
    if ( !alive _player ) then {
        _cnt = _cnt + 1;
		if (_cnt > 9) exitWith { // 10 times with 60 seconds check if no players nearby
			deleteVehicle _killed;
		};
    } else {_cnt = 0;};
};
