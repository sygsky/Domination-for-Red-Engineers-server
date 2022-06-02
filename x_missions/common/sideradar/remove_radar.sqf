/*
	author: Sygsky
	description: none
	_killed = _this select 0;
	_killer = _this select 1;
	returns: nothing
*/

if (!isServer) exitWith{};
_cnt = 0;
_killed = _this select 0;
while (true) do {
    sleep (60 + (random 60));
    if ( {(alive _x) && (isPlayer _x)} count (_killed nearObjects ["SoldierEB", 300]) > 1) then {
        _cnt = _cnt + 1;
    } else {_cnt = 0;};
    if (_cnt > 10) exitWith { // 10 times check shows no players innearby
        deleteVehicle _killed;
    };
};
