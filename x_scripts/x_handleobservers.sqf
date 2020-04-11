// by Xeno, x_scripts\x_handleobservers.sqf
private ["_enemy_ari_available","_nextaritime","_type","_man_type","_observer_type"];
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

#define KILL_RADIOUS 30 // radious to be hit directly by arti shoots
#define HIT_RADIOUS 45 // radious to be hit indirectly by arti shoots
#define SAVE_RADIOUS 50 // radious to he save by arti shoots
#define MIN_FRIENDLY_COUNT_TO_STRIKE 3

_enemy_ari_available = true;
_nextaritime = 0;

if (typeName _this == "STRING") then
{
    _observer_type = _this;
}
else
{
    _observer_type = "-"; // unknown
};
#ifndef __TT__
_man_type = (
	switch (d_enemy_side) do {
		case "WEST": {"SoldierWB"};
		case "EAST": {"SoldierEB"};
	}
);

_enemySide = (
    switch (d_enemy_side) do {
        case "WEST": {west};
        case "EAST": {east};
    }
);

_ownSide = (
    switch (d_own_side) do {
        case "WEST": {west};
        case "EAST": {east};
    }
);
_usa = ["StrykerBase","M113","ACE_M60","M1Abrams","Truck5tMG","HMMWV50","M113_MHQ_unfolded","StaticWeapon"];
_ussr  = ["BMP2","T72","D30","ZSU","UAZMG","Ural","BRDM2","BMP2_MHQ_unfolded"]; // BMP2_MHQ inherited from BMP2

_own_vehicles = (
    switch (d_own_side) do {
        case "WEST": {_usa};
        case "EAST": {_ussr};
        }
);

_enemy_vehicles = (
    switch (d_enemy_side) do {
        case "WEST": {_usa};
        case "EAST": {_ussr};
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
_observers set [0, Observer1];
_observers set [1, Observer2];
_observers set [2, Observer3];
hint localize format["+++ x_handleobservers start: nr_observers = %1", nr_observers];
_enemyToReveal = objNull;
while { nr_observers > 0 && !target_clear } do {
	if (X_MP) then {
	    if ((call XPlayersNumber) == 0) then { waitUntil {sleep (5.012 + random 1);(call XPlayersNumber) > 0}; };
	};
//	__DEBUG_NET("x_handleobservers.sqf",(call XPlayersNumber))

	for "_i" from 0 to (count _observers) - 1 do {
	    _observer = _observers select _i; // current observer
        if (!alive _observer) then
        {
            _observers set[_i, "RM_ME"];
        }
        else
        {
            if (_enemy_ari_available) then {
                if (alive _enemyToReveal) then
                {
                    _observer reveal _enemyToReveal;
                    sleep 0.1;
                };
                _enemy = _observer findNearestEnemy _observer;
                if ((alive _enemy) && ((_observer knowsAbout _enemy) > 1.5) && ((vehicle _enemy) isKindOf "Land") ) then {
                    _distance = _observer distance _enemy;
                    _near_targets = _observer nearTargets (_distance + 10);
                    if (count _near_targets > 0) then {
                        _pos_nearest = [];
                        {
                            if ( (_x select 4) == _enemy ) exitWith {
                                _pos_nearest = _x select 0;
                            };
                            sleep 0.001;
                        } forEach _near_targets;
                        _near_targets = [];
                        _cnt = 0;
                        if ( (count _pos_nearest > 0) && ( (name _enemy) != "Error: No unit") ) then {

                            _own_arr       =  nearestObjects [_pos_nearest, _own_vehicles, KILL_RADIOUS]; // any alive owner (players) vehicles in kill zone to kill them immediatelly
                            _own_cnt       = {alive _x} count _own_arr;

                            _units_arr     = _pos_nearest nearObjects [_man_type, HIT_RADIOUS];
                            _unit_cnt      =  {(_x call SYG_ACEUnitConscious) && (side _x == _enemySide) } count _units_arr; // units in kill zone

                            _observers_arr = _pos_nearest nearObjects [_observer_type, SAVE_RADIOUS];
                            _observer_cnt  = {_x call SYG_ACEUnitConscious} count _observers_arr; // observers not is save zone

                            _veh_arr       =  nearestObjects [_pos_nearest, _enemy_vehicles, KILL_RADIOUS]; // array of enemy vehicle in kill zone
                            _veh_cnt       =  {side _x == _enemySide} count _veh_arr;    // enemy crew vehicles in kill zone

                            _killCnt = MIN_FRIENDLY_COUNT_TO_STRIKE;

                            if (_own_cnt > 0) then { _killCnt = MIN_FRIENDLY_COUNT_TO_STRIKE * (_own_cnt + 1); };

                            _type          = if ( (_unit_cnt > _killCnt )  || ((_observer_cnt  + _veh_cnt) > 0)) then { 2 } else { 1 }; // strike (1) or smoke (2)

                            // If enemy is too far from strike point, do smoking attack only
                            _dist = round( _pos_nearest distance _enemy );

                            if ( ( _dist > SAVE_RADIOUS ) && ( _type == 1 ) && (_own_cnt == 0) ) then { _type = 2 }; // smoke except strike as no player or his vehicles in unsave zone

                            if ( _dist < HIT_RADIOUS ) then { _enemyToReveal = _enemy } // knowledge is high
                            else
                            {
                                if ( _enemyToReveal == _enemy ) then { _enemyToReveal = objNull }; //// knowledge is low
                            };

                            hint localize format
                            [
                                "+++ x_handleobservers.sqf: Obs#%1 strikes %2 with %3 (knows %4) on dist %5 m., [enemy %6, enveh %7, obs %8/%9, ownveh %10], %11, real<->vrt dist %12 m.",
                                _i,
                                if (vehicle _enemy == _enemy) then {format["'%1'", name _enemy]} else {format["'%1'(%2)",name _enemy, typeOf (vehicle _enemy)]},
                                if (_type == 1) then {"warheads"} else {"smokes"},
                                _observer knowsAbout _enemy,
                                round(_observer distance _enemy),
                                _unit_cnt,
                                _veh_cnt,
                                _observer_cnt,  // observers in non-save zone
                                count _observers, // number of active observers
                                _own_cnt,
                                [_enemy, "%1 m to %2 from %3", 10] call SYG_MsgOnPosE,
                                _dist
                            ];

                            _nextaritime  = time + d_arti_reload_time + (random 40);
                            [_pos_nearest,_type] spawn x_shootari;
                            _enemy_ari_available = false;
                            _near_targets        = nil;
                            _own_arr             = nil;
                            _units_arr           = nil;
                            _veh_arr             = nil;
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
/**
if ( target_clear ) then
{
    // kill remaining observers
};
*/
hint localize format["+++ x_handleobservers.sqf: exit, observers %1, target_clear = %2", nr_observers, target_clear ];

if (true) exitWith {};
