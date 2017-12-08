// x_infiltrate.sqf: handles with infiltration to the base.
// by Xeno
//
// +++ Sygsky: periodically (12- 24 hours) base cleaning from "WeaponHolder", "PipeBomb", dead "Land_MAP_AH64_Wreck", dead enemy too
private ["_pilot", "_chopper", "_player_num_delay", "_grp", "_vehicle", "_attack_pos", "_arr"];
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

//#define __PRINT__

// to debug sabotages with short intervals between infiltrations
//#define __DEBUG__

// to debug cleansing procedure (run it with short intervals)
//#define __DEBUG_CLEAN__
#define __DEBUG_CLEAN_PRINT__

//#define __DEBUG_FIRE__

// how often remove garbage from the base, 86400 secs ==24 hours
#ifdef __DEBUG_CLEAN__
#define ON_BASE_GARBAGE_REMOVE_INTERVAL 600
#else
#define ON_BASE_GARBAGE_REMOVE_INTERVAL 86400
#endif

if ( isNil "d_on_base_groups" ) then
{
	d_on_base_groups = [];
	[] execVM "scripts\flaresoverbase.sqf";
#ifdef __PRINT__
	hint localize "x_infiltrate.sqf: d_on_base_groups = []; [] execVM ""scripts\flaresoverbase.sqf""";
#endif

// create fires from array
	_cnt = 0;
	{
#ifdef __DEBUG_FIRE__	
		_fire = createVehicle ["FireLit", _x, [], 0, "NONE"];
		_fire setVariable ["fire_choke_time", time + 120];
#else
		_fire = createVehicle ["Fire", _x, [], 0, "NONE"];
#endif
		_cnt = _cnt + 1;
	} forEach d_base_patrol_fires_array;
	hint localize format["x_infiltrate.sqf: %1 fires created", _cnt];
	// send info to already connected clients about
	sleep 1.07;
	["update_fires", true] call XSendNetStartScriptClient;
	SYG_firesAreCreated = true;
	publicVariable "SYG_firesAreCreated";
};

#ifdef __PRINT__
if ( isNil "d_on_base_groups" ) then
{
	hint localize "--- x_infiltrate.sqf: d_on_base_groups isNil, while MUST be defined";
};
#endif

_pilot = (
	switch (d_enemy_side) do {
		case "EAST": {d_pilot_E};
		case "WEST": {d_pilot_W};
	}
);

_time_to_clean = time;
_items_to_clean = [];
_base_center = d_base_array select 0; //[[9821.47,9971.04,0], 600, 200, 0]
_dx = (d_base_array select 1) + 150; // half of rect width
_dy = (d_base_array select 2) + 150; // half of rect height
_search_radious = sqrt( _dx * _dx + _dy * _dy) + 10;

while { true } do {

    // zombi AI features: group is null, name == "Error: No unit", is alive, isKindOf "CaManBase"
	if ( time >= _time_to_clean ) then
	{
		_cnt1 = count _items_to_clean;
		{ 
			if ( !isNull _x ) then
			{
			    _man = _x isKindOf "CaManBase";
			    _alive = alive _x;
			    if ( ! _man ) then
				{
					deleteVehicle _x; sleep 0.1;
				}
				else // may be alive so called zombi
				{
				    if ( !_alive ) then
				    {
    					deleteVehicle _x; sleep 0.1;
				    }
				    else // alive man
				    {
                        if ( isNull (group _x) && (name _x == "Error: No unit")) then // zombi - arghhhhhh!!!
                        {
                            hint localize format["+++ x_infiltrate.sqf: try to delete zombi %1 pos %2 from base in clean proc", _x, getPos _x];
                            deleteVehicle _x; sleep 0.1;
                        };
				    };
				}
			};
		} forEach _items_to_clean; // clean  all old WeaponHolders and dead Apaches from the base
		_items_to_clean = [];
		sleep 15;
		// seek for new items to clean

		_arr = _base_center nearObjects ["CAManBase",_search_radious];
		sleep 0.5;
		_arr = _arr + (_base_center nearObjects ["WeaponHolder",_search_radious]);
		sleep 0.5;
		_arr = _arr + (_base_center nearObjects ["PipeBomb",_search_radious]);
		sleep 0.5;
		_arr = _arr + (_base_center nearObjects ["Land_MAP_AH64_Wreck",_search_radious]);
		sleep 0.5;
		if (count _arr > 0) then
		{
            for "_i" from 0 to count _arr - 1 do
            {
                _vehicle = _arr select _i;
                if ( !isNull _vehicle ) then
                {
                    _found = _vehicle isKindOf "Land_MAP_AH64_Wreck";
                    if (!_found) then
                    {
                        if ( _vehicle isKindOf "CaManBase") then
                        { // check if dead man not player
                            _found = !((alive _vehicle) || (isPlayer _vehicle)); // add dead bodies only
                            // check for zombies found
                            if ( !_found ) then
                            {
                                if ( isNull (group _vehicle) && (name _vehicle == "Error: No unit")) then
								{
									// Yesss, he is ZOMBIiiiii..... try to remove him in any way
									hint localize format["+++ x_infiltrate.sqf: zombi detected in clean proc, try to remove it away from the base"];
									_vehicle setPos [ 0, 0, 0 ];
									sleep 0.1;
									_vehicle setDamage 1.1;
									sleep 0.1;
									_found = true;
								};
                            };
                        }
                        else
                        { // check if holder is on the ground or is hanging in air (some Arma bug)
                            _found = (((_vehicle modelToWorld [0,0,0]) select 2) < 0.7) || (((getPos _vehicle) select 2) > 4); // if z > 4, item is hanging in air
                        };
                    };
                    if ( _found ) then
                    {
                        if (!(_vehicle in _items_to_clean)) then
                        {
                            if ( [getPos _vehicle, d_base_array] call SYG_pointInRect ) then
                            {
                                _items_to_clean = _items_to_clean + [_vehicle];
                            };
                        };
                    };
                };
            }; // for "_i" from 0 to count _arr - 1 do //forEach _arr;
		};
		// set new time to clean
		_delay = ON_BASE_GARBAGE_REMOVE_INTERVAL/2 + (random (ON_BASE_GARBAGE_REMOVE_INTERVAL/2));
		_time_to_clean = time + _delay;
#ifdef __DEBUG_CLEAN_PRINT__
		hint localize format["x_infiltrate.sqf: %3 base cleaning proc: %1 items cleaned, %2 items added to the clean queue, next clean after %4 secs", _cnt1, count _items_to_clean, call SYG_missionTimeInfoStr, _delay ];
		if ((count _items_to_clean) > 0) then
		{
			_arr = [];
			for "_i" from 0 to (15 min (count _items_to_clean)) - 1 do
			{
				_arr set [_i, typeOf (_items_to_clean select _i)];
			};
			hint localize format["x_infiltrate.sqf: items to clear later %1 ...", _arr];
			_arr = [];
		}
		else
		{
			hint localize "x_infiltrate.sqf: no items to clear found";
		};
#endif		
	}; // if ( time >= _time_to_clean ) then
	
#ifdef __DEBUG__
	sleep 1;
#else
	sleep 5000 + (random 1200);
#endif

	if (X_MP) then {
		if ((call XPlayersNumber) == 0) then
		{		
			waitUntil { sleep (10.0123 + random 1);(call XPlayersNumber) > 0 };
		};
	};
	__DEBUG_NET("x_infiltrate.sqf",(call XPlayersNumber))
	
	__WaitForGroup
	__GetEGrp(_grp)
	_chopper = d_transport_chopper call XfRandomArrayVal;
	_vehicle = createVehicle [_chopper, d_airki_start_positions select 0, [], 100, "FLY"];
	[ _vehicle, _grp, _pilot, 1.0 ] call SYG_populateVehicle;
	// forEach crew _vehicle;
	{ // support each crew member
		__addDead(_x)
		sleep 0.01;
	} forEach crew _vehicle;

	__addRemoveVehi(_vehicle)
	
	_grp setCombatMode "RED";
	sleep 1.123;
	_attack_pos = [position FLAG_BASE,600] call XfGetRanPointCircle;
	
//	_attack_pos  = position FLAG_BASE;
//	_attack_pos set [ 1, (_attack_pos select 1) - 50]; // drop near player
	
	sleep 0.1;
	[_grp,_vehicle,_attack_pos,d_airki_start_positions select 1] execVM "x_scripts\x_createpara2.sqf";
	__SetGVar(INFILTRATION_TIME, date);
	
#ifdef __DEBUG__
	sleep 1200; // 20 mins to kill them all or be down himself
#else
	// additional delay for small player team < 5. If player number >=5 there is no additional delay
	sleep ((600 + random 200) + (5-(5 min(call XPlayersNumber)))*1000);
#endif	

}; // while { true } do 

if (true) 