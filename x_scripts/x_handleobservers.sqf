// by Xeno, x_scripts\x_handleobservers.sqf
private ["_enemy_ari_available","_nextaritime","_type","_enemy_man_type","_observer_type","_observers", "_pos_nearest"];
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

#define KILL_RADIOUS 30 // radious to be hit directly by arti shoots
#define HIT_RADIOUS 45 // radious to be hit indirectly by arti shoots
#define SAVE_RADIOUS 60 // radious to he save by arti shoots
#define MIN_FRIENDLY_COUNT_TO_STRIKE 3 // maximum number of enemy vehilce in zone to allow strike onto them
#define MAX_SHOOT_DIST 300 // maximum distance between known and real player pos observer can shoot on

_enemy_ari_available = true;
_nextaritime = 0;

if (typeName _this == "STRING") then {
    _observer_type = _this;
} else {
    _observer_type = "-"; // unknown
};
#ifndef __TT__
_enemy_man_type = (
	switch (d_enemy_side) do {
		case "WEST": {"SoldierWB"};
		case "EAST": {"SoldierEB"};
	}
);

_player_type = (
    switch (d_own_side) do {
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
_usa = ["StrykerBase","M113","ACE_M2A1","ACE_M60","M1Abrams","Truck5tMG","HMMWV50","M113_MHQ_unfolded","StaticWeapon"];
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
// Counts observers in the proposed  hit zone
// call: _cnt = _observers call _count_observers;
_count_observers = {
    if (count _this == 0) exitWith { 0 };
    private ["_cnt","_x"];
    _cnt = 0;
    {
        if (typeName _x == "OBJECT") then {
            if (alive _x) then {
                if ( ( _x call SYG_ACEUnitConscious) && ((_x distance _pos_nearest) < SAVE_RADIOUS)) then { _cnt = _cnt + 1 };
            };
        };
    } forEach _this;
    _cnt
};

_land_veh_type = "LandVehicle";
#endif

#ifdef __TT__
_enemy_man_type = ["SoldierWB","SoldierGB"];
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
while { ((nr_observers > 0) && (count _observers > 0))&& !target_clear } do {
	if (X_MP) then {
	    if ((call XPlayersNumber) == 0) then { waitUntil {sleep (5.012 + random 1);(call XPlayersNumber) > 0}; };
	};
//	__DEBUG_NET("x_handleobservers.sqf",(call XPlayersNumber))

	for "_i" from 0 to (count _observers) - 1 do {
	    _observer = _observers select _i; // current observer
        if (!alive _observer) then {
            _observers set[_i, "RM_ME"];
        } else { // if (!alive _observer) then
            if (typeName _observer != "OBJECT") exitWith {
                hint localize format["--- x_handleobservers.sqf: Obs#%1 typeName == %2", _i,typeName _observer ];
            };
            if (!_enemy_ari_available) exitWith { sleep 3.132 };

            if (alive _enemyToReveal) then {
                _observer reveal _enemyToReveal;
                sleep 0.1;
            };
            _enemy = _observer findNearestEnemy _observer;

            if (!alive _enemy) exitWith { sleep 3.234  };

            if ((_observer knowsAbout _enemy) <= 1.5) exitWith {};

            // check if player in flying landed air vehicle;

			if (  (vehicle _enemy != _enemy) &&  (( (getPos _enemy) select 2 > 10 ) || ( ( speed _enemy  ) > 10 )) ) exitWith {
			    hint localize format["*** x_handleobservers.sqf:  Exit on enemy (%1) height %2 or speed %3", typeOf(vehicle _enemy), round((getPos _enemy) select 2), round (speed _enemy) ];
			    sleep 3.345
			}; // lets help to observer to view detected enemy
			_observer reveal _enemy; // team helps to the observer)))
			sleep 0.3;
            _dist_obs_enemy = _observer distance _enemy; // distance to enemy from observer
            _near_targets = _observer nearTargets (_dist_obs_enemy + HIT_RADIOUS);
            if (count _near_targets > 0) then {
                _pos_nearest = []; // position of then nearest enemy found (intially empty)
                {
                    if ( (_x select 4) == _enemy ) exitWith {
                        _pos_nearest = _x select 0; // position to this target in the system list
                    };
                    sleep 0.001;
                } forEach _near_targets;
                _near_targets_cnt = count _near_targets;
                _near_targets = [];
                if ( (count _pos_nearest > 0) && ( (name _enemy) != "Error: No unit") ) then {
                    // don't shoot too far if player is not in vehicle as he can teleport from battle field
                    // but Arma updates its real coordinates in the nearTargets array
                    // Arti strike is not allowed if player is teleported far away (user is on base, on feet || close to flag)

                    _dist_between_pos = round( _pos_nearest distance _enemy );
                    _dist_obs_pos   = round( _observer distance _pos_nearest ); // dist between observer and hit point

                    if ( _dist_between_pos >= MAX_SHOOT_DIST ) exitWith {
                        hint localize format[ "+++ x_handleobservers.sqf: Arti strike on player %1 (known %2) cancelled, dist %3 m (<= %4 allowed) betw. known/real pos",
                        name _enemy, (round((_observer knowsAbout _enemy) * 10.0))/10.0, _dist_between_pos, MAX_SHOOT_DIST ];
                    };
// The following lines are commented as useless, because the previous statement completely solves the problem
// of firing far away from the real position (including because of the teleport to the base)
//#ifndef __TT__
//					_notAllowed = (isPlayer _enemy) && ((vehicle _enemy == _enemy) || ((_enemy distance FLAG_BASE) < SAVE_RADIOUS));
//#else
//					_notAllowed = (isPlayer _enemy) && ((vehicle _enemy == _enemy) || ((_enemy distance RFLAG_BASE) < SAVE_RADIOUS || (_enemy distance WFLAG_BASE) < SAVE_RADIOUS));
//#endif
//                    if ( (_dist_obs_pos >= (MAX_SHOOT_DIST * 10) ) && _notAllowed ) exitWith {
//                        hint localize format["+++ x_handleobservers.sqf: Arti strike on player %1 cancelled due to big dist between the obs and player who is not in vehilce (dist %2 m), up to %3 m is permitted",
//                        					name _enemy, _dist_obs_pos, MAX_SHOOT_DIST * 10];
//                    };

					["say_radio", "enemy_activity"] call XSendNetStartScriptServer;

                    _own_arr       =  nearestObjects [_pos_nearest, _own_vehicles, KILL_RADIOUS]; // any alive owner (players) vehicles in kill zone to kill them immediatelly
                    _own_cnt       = {alive _x} count _own_arr;

                    _units_arr     = _pos_nearest nearObjects [_enemy_man_type, HIT_RADIOUS];
                    _unit_cnt      =  {(_x call SYG_ACEUnitConscious) && (side _x == _enemySide) } count _units_arr; // observer side units in hit zone
                    _veh_arr       =  nearestObjects [_pos_nearest, _enemy_vehicles, KILL_RADIOUS]; // array of observer side vehicle in kill zone
                    _veh_cnt       =  {side _x == _enemySide} count _veh_arr;    // enemy crew vehicles in kill zone
                    _observer_cnt  = _observers call _count_observers;
                    _killCnt       = MIN_FRIENDLY_COUNT_TO_STRIKE * (_own_cnt + 1);  // how many friendly units are allowed to hit

					// observer side vehicles not allowed to be killed/hit
                    _type = if ( (_unit_cnt > _killCnt )  || ((_observer_cnt  + _veh_cnt) > 0)) then { 2 } else { 1 }; // strike (1) or smoke (2)

                    // If enemy is too far from strike point, do smoking attack only
                    if ( ( _dist_between_pos > SAVE_RADIOUS ) && ( _type == 1 ) && (_own_cnt == 0) ) then { _type = 2 }; // smoke except strike as no player or his vehicles in unsave zone
                    if ( ( _dist_obs_pos < SAVE_RADIOUS ) && ( _type == 1 ) ) then {
                    	// Prevent observer from killing himself!
                     	_type = 2;
                     	_pos_nearest = getPos _enemy; // help observer to blind enemy
                      };

                    if ( _dist_between_pos < HIT_RADIOUS ) then { _enemyToReveal = _enemy } // knowledge is correct
                    else { if ( _enemyToReveal == _enemy ) then { _enemyToReveal = objNull } }; // knowledge is bad

                    hint localize format [
                        "+++ x_handleobservers.sqf: Obs#%1 strikes %2 with %3 (knows %4), knwn/real dist %5/%6 m. [eu %7, ev %8/%9, obs %10/%11, ov %12], %13, real<->knwn dist %14 m., tgtcnt %15",
                        _i,
                        if (vehicle _enemy == _enemy) then {format["'%1'", name _enemy]} else {format["'%1'(%2)",name _enemy, typeOf (vehicle _enemy)]},
                        if (_type == 1) then {"warheads"} else {"smokes"},
                        (round((_observer knowsAbout _enemy) * 10.0))/10.0,
                        _dist_obs_pos,
                        round _dist_obs_enemy,
                        _unit_cnt,
                        _veh_cnt, count _veh_arr,
                        _observer_cnt,  // observers in non-save zone
                        count _observers, // observers array length
                        _own_cnt,
                        [_enemy, localize "STR_SYS_POSE", 10] call SYG_MsgOnPosE,
                        _dist_between_pos,
                        _near_targets_cnt
                    ];

                    [] spawn { sleep 3; ["say_radio", "enemy_spotted"] call XSendNetStartScriptServer; };

                    _nextaritime  = time + d_arti_reload_time + (random 40);
                    [_pos_nearest,_type,KILL_RADIOUS] spawn x_shootari;
                    _enemy_ari_available = false;
                    _near_targets        = nil;
                    _own_arr             = nil;
                    _units_arr           = nil;
                    _veh_arr             = nil;
                };
            };
            sleep 3.321;
        };
	};
	_observers call SYG_clearArray; // remove killed observers[s] if any
//	_observers = _observers - ["RM_ME"];
	sleep 5.123;
	if (!_enemy_ari_available) then {
		if ( time >= _nextaritime ) then { _enemy_ari_available = true; };
	};
};
/**
if ( target_clear ) then
{
    // kill remaining observers
};
*/
hint localize format["+++ x_handleobservers.sqf: exit, observers %1, count alive _observers %2, target_clear = %3", nr_observers, {alive _x} count _observers, target_clear ];

if (true) exitWith {};
