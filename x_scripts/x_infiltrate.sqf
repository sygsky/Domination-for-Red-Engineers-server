// x_infiltrate.sqf: handles with infiltration to the base.
// by Xeno
//
// +++ Sygsky: periodically (12- 24 hours) base cleaning from "WeaponHolder", "PipeBomb", dead "Land_MAP_AH64_Wreck", dead enemy too
private ["_pilot", "_chopper", "_player_num_delay", "_grp", "_vehicle", "_attack_pos", "_arr"];
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"
#include "global_vars.sqf"

#define MIN_SABOTAGE_LIMIT_TO_START_NEXT_GROUP 10 // how many alive sabotages must exist to not send next group to infiltrate base

#define __PRINT__

// to debug sabotages with short intervals between infiltrations
//#define __DEBUG_INFILTRATE_PERIOD__  1200

// to debug cleansing procedure (run it with short intervals)
//#define __DEBUG_CLEAN__
#define __DEBUG_CLEAN_PRINT__

//#define __DEBUG_FIRE__

// how often remove garbage from the base, 86400 secs ==24 hours
#ifdef __DEBUG_CLEAN__
#define ON_BASE_GARBAGE_REMOVE_INTERVAL 600
#else
//#define ON_BASE_GARBAGE_REMOVE_INTERVAL 86400 // 86400 secs ==24 hours
#define ON_BASE_GARBAGE_REMOVE_INTERVAL 14400 // 144004 secs = 4 hours
#endif

if ( isNil "d_on_base_groups" ) then {
	d_on_base_groups = [];
	[] execVM "scripts\flaresoverbase.sqf";
#ifdef __PRINT__
	hint localize "+++ x_infiltrate.sqf: d_on_base_groups = []; [] execVM ""scripts\flaresoverbase.sqf""";
#endif

    // create fires from array
	_cnt = 0;
	{
#ifdef __DEBUG_FIRE__	
		_fire = createVehicle ["FireLit", _x, [], 0, "NONE"];
		_fire setVariable ["fire_off_time", time + 120];
#else
		_fire = createVehicle ["Fire", _x, [], 0, "NONE"];
#endif
		_cnt = _cnt + 1;
	} forEach d_base_sabotage_fires_array;
	hint localize format["+++ x_infiltrate.sqf: %1 fires created", _cnt];
	// send info to already connected clients about
	sleep 1.07;
	["update_fires", true] call XSendNetStartScriptClient;
	SYG_firesAreCreated = true;
	publicVariable "SYG_firesAreCreated";
};

#ifdef __PRINT__
if ( isNil "d_on_base_groups" ) then {
	hint localize "--- x_infiltrate.sqf: d_on_base_groups isNil, while MUST be defined";
};
#endif

_pilot = (
	switch (d_enemy_side) do {
		case "EAST": {d_pilot_E};
		case "WEST": {d_pilot_W};
	}
);

//
// Returns count of alive sobatages in all known groups
//
_alive_sabotage = {
	private ["_cnt"];
	_cnt = 0;
	{
		_cnt = _cnt + ({alive _x } count units _x);
	} forEach d_on_base_groups;
	hint localize format["+++ Alive sabotage count = %1", _cnt];
	_cnt
};

_time_to_clean = time;
_items_to_clean = [];
_base_center = d_base_array select 0; //[[9821.47,9971.04,0], 600, 200, 0]
_dx = (d_base_array select 1)/* + 150*/; // half of rect width
_dy = (d_base_array select 2) /*+ 150*/; // half of rect height
_search_radious = sqrt( _dx * _dx + _dy * _dy) + 10;

while { true } do {

    // zombi AI features: group is null, name == "Error: No unit", is alive, isKindOf "CAManBase"
	if ( time >= _time_to_clean ) then {

        //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        // clear previously  accumulated array of garbage vehicles on the base
        //------------------------------------------------------------------

		 _cnt             = count _items_to_clean; // whole counter
		_cnt_dead         = 0; // dead men
		_cnt_alive        = 0; // alive men (so then were standing her all the time
		_cnt_car          = 0; // dead cars
		_cnt_holder       = 0; // all weapon holders
		_cnt_holder_water = 0; // weapon holders in water
		_cnt_null         = 0; // null objects (nullified after time out)
		_cnt_pb           = 0; // pipe bombs
		_cnt_garbage      = 0; // all other types
		_cnt_zombi        = 0; // detected zombi
		{
			if ( !isNull _x ) then {
			    _man = _x isKindOf "CAManBase";
			    _alive = alive _x;
			    if ( ! _man ) then {
				    // count by vehicle type
                    if (_x isKindOf "Car") then {
                        _cnt_car = _cnt_car + 1;
                    } else {
                        if (_x isKindOf "WeaponHolder") then {
                            _cnt_holder = _cnt_holder + 1;
                            if ( surfaceIsWater (getPos _x)) then { _cnt_holder_water = _cnt_holder_water + 1 };
                        } else {
                            if (_x isKindOf "PipeBomb") then {
                                _cnt_pb = _cnt_pb + 1;
                            } else {
                                _cnt_garbage = _cnt_garbage + 1;
                            };
                        };
                    };
					deleteVehicle _x; sleep 0.1;
				} else {
				    // may be alive so called zombi
				    if ( !_alive ) then {
				        _cnt_dead = _cnt_dead + 1;
    					deleteVehicle _x; sleep 0.1;
				    } else { // alive man
                        if ( isNull (group _x) && (name _x == "Error: No unit")) then { // zombi - arghhhhhh!!!
                            hint localize format["+++ x_infiltrate.sqf: try to delete zombi %1 pos %2 from base in clean proc", _x, getPos _x];
                            deleteVehicle _x; sleep 0.1;
                            _cnt_zombi = _cnt_zombi + 1;
                        } else {
                            _cnt_alive = _cnt_alive + 1;
                        };
				    };
				};
			} else {
                // item is null, count as skipped
                _cnt_null = _cnt_null + 1;
			};
		} forEach _items_to_clean; // clean  all garbages (especially  bombs, WeaponHolders and dead Apaches) from the base area
		_str = format[ "cnt %1: men alv %2/ded %3, zmb %4, car %5, w/h %6%7, bmb %8, grb %8, null %10",
		     _cnt, _cnt_alive, _cnt_dead, _cnt_zombi, _cnt_car, _cnt_holder, if (_cnt_holder_water > 0) then {format["(water %1)", _cnt_holder_water]} else {""}, _cnt_pb, _cnt_garbage, _cnt_null ];
		_items_to_clean = [];
		sleep 15;

		//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		// add all vehicles found on base again to clean after good timeout
		//------------------------------------------------------------------

		_arr = _base_center nearObjects ["CAManBase",_search_radious];
		sleep 0.5;
//		_arr = _arr + (_base_center nearObjects ["WeaponHolder",_search_radious]);
		_arr = [_arr, (_base_center nearObjects ["WeaponHolder",_search_radious])] call SYG_addArrayInPlace;
		sleep 0.5;
//		_arr = _arr + (_base_center nearObjects ["PipeBomb",_search_radious]);
		_arr = [_arr, (_base_center nearObjects ["PipeBomb",_search_radious])] call SYG_addArrayInPlace;
		sleep 0.5;
//		_arr = _arr + (_base_center nearObjects ["Land_MAP_AH64_Wreck",_search_radious]);
		_arr = [_arr, (_base_center nearObjects ["Land_MAP_AH64_Wreck",_search_radious])] call SYG_addArrayInPlace;
		sleep 0.5;
//		_arr = _arr + (_base_center nearObjects ["Car",_search_radious]); // why this is added? Don't know :o(
		_arr = [_arr, (_base_center nearObjects ["Car",_search_radious])] call SYG_addArrayInPlace;

		if ( ! isNull aborigen_heli ) then { // #666: request by EngineerACE in December of 2023, delete the aborigen heli if empty and on base
			if ( aborigen_heli  call SYG_pointIsOnBase ) then {
				if ( ({alive _x} count crew aborigen_heli) == 0 ) then {
					hint localize format[ "+++ %1 aborigen_heli (%2) removed from the base during clean procedure", if (alive aborigen_heli) then {"Alive "} else {"Dead"}, typeOf aborigen_heli ];
					[ "say_sound", aborigen_heli, "steal" ] call XSendNetStartScriptClientAll;
					sleep 1;
					deleteVehicle aborigen_heli;
				};
			};
		};

		sleep 0.5;
		_cnt_dead = 0;
		if (count _arr > 0) then {
            for "_i" from 0 to (count _arr) - 1 do {
                _vehicle = _arr select _i;
                if ( !(_vehicle call SYG_pointIsOnBase) ) exitWith {};
				// in rect of base
				if ( isNull _vehicle ) exitWith {};
				_found = _vehicle isKindOf "Land_MAP_AH64_Wreck";
				if (!_found) then {
					if ( _vehicle isKindOf "CAManBase") exitWith { // check if dead man not player
						_found = !((alive _vehicle) || (isPlayer _vehicle)); // add dead bodies only
						if ( _found ) exitWith {
							// dead body
							_cnt_dead = _cnt_dead + 1;
						};
						// check for zombies found (not player and alive)
						if ( primaryWeapon _vehicle == "") then { // may be zombi or AI at rearming progress
							if (name _vehicle == "Error: No unit") then {
								// Yesss, he is ZOMBIiiiii..... try to remove him in any way
								//_vehicle setPos [ 0, 0, 0 ];
								_vehicle setDamage 1.1;
								_name = name _vehicle;
								hint localize format["+++ x_infiltrate.sqf: zombi (no prim weapon) ""%1"" detected in clean proc, name ""%2""", _vehicle, _name];
								sleep 0.1;
								//hideBody _vehicle;
								deleteVehicle _vehicle;
								sleep 0.5;
								_found = !isNull _vehicle;
							};
						};
					};
					if (_found) exitWith {};

					if ( _vehicle isKindOf "Car" ) exitWith {
						_found = !(alive _vehicle || (_vehicle in d_helilift1_types) ); // don't clean alive and resurrectable vehicles
					};

					// #667: request by EngineerACE in December of 2023
					if ( _vehicle call SYG_isParachute ) exitWith {
						_found = isNull (driver _vehicle); // don't clean parachute with man
					};

					// check if holder is on the ground or is hanging in air (some Arma bug)
					_found = (((_vehicle modelToWorld [0,0,0]) select 2) < 0.7) || (((getPos _vehicle) select 2) > 4); // if z > 4, item is hanging in air
				};
				if ( _found ) then {
					if (!(_vehicle in _items_to_clean)) then {
						_items_to_clean set [ count _items_to_clean, _vehicle];
					};
				};
            }; // for "_i" from 0 to count _arr - 1 do //forEach _arr;
		};
#ifdef __DEBUG_CLEAN_PRINT__
		hint localize format["+++ x_infiltrate.sqf: %3 base cleaning proc: %1 cleaned / %2 items added, next after %4",
		        _str, count _items_to_clean, call SYG_missionTimeInfoStr, _delay call SYG_secondsToStr
		    ];
		if ((count _items_to_clean) > 0) then {
			_arr =  [_items_to_clean, 10] call SYG_objArrToTypeStr;
			hint localize format["+++ x_infiltrate.sqf: items to clear later %1 ...", _arr];
			_arr = [];
		} else {
			hint localize "+++ x_infiltrate.sqf: no items to clear found";
		};
#endif		
		// set new time to clean
		_delay = ON_BASE_GARBAGE_REMOVE_INTERVAL/2 + (random (ON_BASE_GARBAGE_REMOVE_INTERVAL/2)); // 2..4 hours, 3 on average
		_time_to_clean = time + _delay;
	}; // if ( time >= _time_to_clean ) then
	
#ifdef __DEBUG_INFILTRATE_PERIOD__
	sleep 1;
#else
	sleep 5000 + (random 1200);
#endif

	if (X_MP) then {
		if ((call XPlayersNumber) == 0) then {
			waitUntil { sleep (10.0123 + random 1);(call XPlayersNumber) > 0 };
		};
	};
	//__DEBUG_NET("+++x_infiltrate.sqf",(call XPlayersNumber))

	// start sabotage only if alive sabotage count <  MIN_SABOTAGE_LIMIT_TO_START_NEXT_GROUP
	_alive_cnt = ( call _alive_sabotage );
	if ( _alive_cnt <  MIN_SABOTAGE_LIMIT_TO_START_NEXT_GROUP ) then {
		hint localize format["+++ x_infiltrate: %1 sabotage[s] found, next infiltration STARTED", _alive_cnt];
		// Sabotage drop zones array
		_ind = floor random (count drop_zone_arr); // 0 or 1 is used
		_rect =  drop_zone_arr select _ind; // call XfRandomArrayVal; // 1st rect is south to airbase, 2nd is north to airbase
		_delta = _rect select 4; // start point offset to south (+) or north (-)
		//  _random_point  = [position trigger2, 200, 300, 30] call XfGetRanPointSquareOld;
		_attack_pos = _rect call XfGetRanPointSquareOld; //[position FLAG_BASE,600] call XfGetRanPointCircle;
		_msg = [_attack_pos, localize "STR_SYS_POSE"] call SYG_MsgOnPosE;
	//	_attack_pos  = position FLAG_BASE;
	//	_attack_pos set [ 1, (_attack_pos select 1) - 50]; // drop near player

		//__WaitForGroup
		//__GetEGrp(_grp)
		_grp = call SYG_createEnemyGroup;
		_chopper = d_transport_chopper call XfRandomArrayVal;
		_start_pos = d_airki_start_positions select 0;
		_start_pos set [1, random _delta];

		_vehicle = createVehicle [_chopper, _start_pos, [], 100, "FLY"];
		[ _vehicle, _grp, _pilot, 1.0 ] call SYG_populateVehicle;
		// forEach crew _vehicle;
		{ // support each crew member
			__addDead(_x)
			sleep 0.01;
		} forEach crew _vehicle;

		__addRemoveVehi(_vehicle)

		_grp setCombatMode "RED";
		sleep 1.123;


		sleep 0.1;
		//[_grp,_vehicle,_attack_pos,d_airki_start_positions select 1] execVM "x_scripts\x_createpara2.sqf";
		[_grp,_vehicle,_attack_pos,d_airki_start_positions select 1] execVM "x_scripts\x_createpara2cut.sqf";
	#ifdef __PRINT__
		hint localize format["+++ x_infiltrate.sqf: started at %1 on pnt %2", date, _msg ];
	#endif
	} else {  // if ((call _alive_sabotage) < 10) then {
		hint localize format["+++ x_infiltrate: %1 sabotage[s] found, next infiltration STOPPED", _alive_cnt];
	};
#ifdef __DEBUG_INFILTRATE_PERIOD__
	sleep __DEBUG_INFILTRATE_PERIOD__; // 20 mins to kill them all or be down himself
#else
	// additional delay for small player team < 5. If player number >=5 there is no additional delay
	sleep ((600 + random 200) + (5-(5 min(call XPlayersNumber)))*1000);
#endif	
     if (current_counter >= number_targets) exitWith {
        [ "msg_to_user", "*", [ [ "STR_SYS_1220" ] ], 0, 2, false, "hound_chase" ] call  XSendNetStartScriptClient; // "The enemy aircraft carrier got out together with the paratroopers!"
#ifdef __PRINT__
	hint localize "*** x_infiltrate.sqf: EXIT infiltration loop as end of last town reached";
#endif

     };
}; // while { true } do 

if (true) exitWith {};