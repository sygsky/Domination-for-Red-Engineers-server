/*
	x_missions\common\sideradar\radio_delete.sqf
	author: Sygsky
	description: deletes the radar
	_killed = _this select 0;
	_killer = _this select 1;
	returns: nothing
*/

if (!isServer) exitWith{};
sideradio_status = -1;
publicVariable "sideradio_status";
{
	if (alive _x) then {_x lock true};
} forEach (sideradio_info select 2); // remove all crew from all vehicles

_cnt = 0;
_killed = _this select 0;
_pos = getPos _killed;
while (true) do {
    sleep (60 + (random 60));
    _player =  [_pos, 300] call SYG_findNearestPlayer; // find any alive player in or out vehicles
    if ( !alive _player ) then {
        _cnt = _cnt + 1;
		if (_cnt > 9) exitWith { // 10 times with 60 seconds check if no players nearby
			deleteVehicle _killed;
		};
    } else {_cnt = 0;};
};
