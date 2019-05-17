// by Xeno, x_scripts/x_handleobservers.sqf
private ["_enemy_ari_available","_nextaritime","_type","_man_type"];
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

_enemy_ari_available = true;
_nextaritime = 0;

#ifndef __TT__
_man_type = (
	switch (d_enemy_side) do {
		case "WEST": {"SoldierWB"};
		case "EAST": {"SoldierEB"};
		case "RACS": {"SoldierGB"};
	}
);
_side = (
    switch (d_enemy_side) do {
        case "WEST": {west};
        case "EAST": {east};
        case "RACS": {resistance};
    }
);
_land_veh_type = "LandVehicle";
_tt = false;
#endif

#ifdef __TT__
_man_type = ["SoldierWB","SoldierGB"];
_tt = true;
#endif

if (isNil "x_shootari") then {
	x_shootari = compile preprocessFileLineNumbers "x_scripts\x_shootari.sqf";
};

sleep 10.123;

// prepare observers
_observers = [];
_observers set [0, {Observer1}];
_observers set [1, {Observer2}];
_observers set [2, {Observer3}];

while {nr_observers > 0} do {
	if (X_MP) then {
	if ((call XPlayersNumber) == 0) then { waitUntil {sleep (5.012 + random 1);(call XPlayersNumber) > 0}; };
	};
//	__DEBUG_NET("x_handleobservers.sqf",(call XPlayersNumber))

	for "_i" from 0 to (count _observers) - 1 do {
	    _observer = call (_observers select _i); // current observer
        if (!alive _observer) then
        {
            _observers set[_i, "RM_ME"];
        }
        else
        {
            if (_enemy_ari_available) then {
                _enemy = _observer findNearestEnemy _observer;
                if (!(isNull _enemy) && ((_observer knowsAbout _enemy) >= 1.5) && ((vehicle _enemy) isKindOf "Land") ) then {
                    _distance = _observer distance _enemy;
                    _near_targets = _observer nearTargets (_distance + 10);
                    if (count _near_targets > 0) then {
                        _pos_nearest = [];
                        {
                            if ((_x select 4) == _enemy) exitWith {
                                _pos_nearest = _x select 0;
                            };
                            sleep 0.001;
                        } forEach _near_targets;
                        _near_targets = [];
                        _vecs = [];
                        _cnt = 0;
                        if (count _pos_nearest > 0) then {
#ifndef  __TT__
                            _near_targets = _pos_nearest nearObjects [_man_type, 35];
                            _vecs         = _pos_nearest nearObjects [_land_veh_type, 35];
                            _cnt          =  ({alive _x && canStand _x} count _near_targets) + ({alive _x && (side _x == _side)} count _vecs);
                            hint localize format["+++ x_handleobservers.sqf: observer detected enemy %1 (knows %2) at %3 m., in range friendly count %3",
                                _enemy,
                                _observer knowsAbout _enemy,
                                _observer distance _enemy,
                                _cnt];
#else
                            _near_targets = nearestObjects [_pos_nearest, _man_type, 35];
                            _cnt          =  {alive _x && canStand _x} count _near_targets;
#endif
                            _type                = if ( _cnt > 0) then { 1 } else { 2 }; // strike (1) or smoke (2)
                            _nextaritime         = time + d_arti_available_time + random 120;
                            [_pos_nearest,_type] spawn x_shootari;
                            _enemy_ari_available = false;
                            _near_targets        = nil;
#ifndef  __TT__
                            _vecs                = nil;
#endif
                        };
                    };
                };
            };
            sleep 3.321;
        };
	};
	_observers = _observers - ["RM_ME"]; // remove killed observers[s]
	sleep 5.123;
	if (!_enemy_ari_available) then 
	{
		if ( time >= _nextaritime ) then { _enemy_ari_available = true; };
	};
};
hint localize "+++ x_handleobservers.sqf: no more observers detected";

if (true) exitWith {};
