// x_scripts/x_airki.sqf, by Xeno
// works for single air killer
//
private ["_type", "_pos", "_wp_behave", "_crew_member", "_addToClean", "_heli_type", "_vehicle", "_initial_type", "_grp",
 "_vehicles", "_bad_units","_num_p", "_re_random", "_randxx", "_grpskill", "_xxx", "_needs_gunner", "_unit2", "_leader",
 "_old_target", "_loop_do", "_dummy", "_current_target_pos", "_wp", "_pat_pos", "_radius", "_dist", "_old_pat_pos", "_angle",
  "_x1", "_y1", "_i", "_vecx","_new_group","_pilot","_good_units", "_counter","_rejoinPilots", "_ret", "_lastDamage"];

if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

//#define __DEBUG__

//#define __SYG_AIRKI_DEBUG__

#define __PRINT__

// arrival time delay between KA and MIMG
#define KA_MIMG_ARRIVAL_DELAY 300
#define REFUEL_INTERVAL 600

// how many player is not detected near target in seconds
#define PLAYER_NOT_AT_TARGET_LIMIT 1200
// how far from point of interest а player is checked
#define PLAYER__AT_TARGET_CHECK_RADIOUS 1000

_type = _this select 0; // vehicle type (KA, MIMG, SU: attack heli, light heli, airjet)

_pos = d_airki_start_positions select 0; // from where to fly to goal

_wp_behave = "AWARE";

_crew_member = (
	switch (d_enemy_side) do {
		case "EAST": {d_pilot_E};
		case "WEST": {d_pilot_W};
	}
);

// List of all heli downed on Sahrani
if ( isNil "s_down_heli_arr" ) then
{
	s_down_heli_arr = [];
};

/**
 * Kills sigle unit or units in array
 * call: 
 *    _unit call _killUnits;
 *    [_unit1,_unit2] call _killUnits;
 *    units _grp call _killUnits;
 * returns: nothing
 */
_killUnits = {
	private ["_arr"];
	if ( typeName _this != "ARRAY") then // single unit designated
	{
		_arr = [_this];
	};
	
	{
		if (!isNull _x ) then 
		{
			_x setDammage 1.1;
			sleep 0.3;
			[_x] call XAddDead;
			sleep 0.1;
		};
	} forEach _arr;
};

_addToClean = {
	private ["_heli_type","_vehicle"];
	_heli_type = _this select 0; _vehicle = _this select 1;
	if (!(_heli_type in x_heli_wreck_lift_types)) then {
		//__addRemoveVehi(_vehicle)
		_vehicle addEventHandler ["killed", {_this spawn x_removevehi;}];
		if (!d_lock_ai_air) then {[_vehicle] call XAddCheckDead;}; // add vehicle to the list units, checked to be killed (see in x_setupserver.sqf)
	};
	#ifdef __TT__
	_vehicle addEventHandler ["killed", {[8,_this select 1] call XAddKills;}];
	#endif
	#ifdef __AI__
	if (__RankedVer) then {
		_vehicle addEventHandler ["killed", {[8,_this select 1] call XAddKillsAI}];
	};
	#endif
	if (d_lock_ai_air) then {_vehicle lock true;};
};

/**
 * +++ Sygsky: OPTIMIZE pilots from shotdown helis
 * simply rejoin them to any good town group or kill them all
 *
 * call:
 *  _pilotsGrp call _rejoinPilots;
 * returns: true if one or more pilot were rejoined, false if no one is
 *
 */
_rejoinPilots = 
{
	private ["_grp", "_newgrp", "_pilot", "_badunits", "_goodunits", "_counter", "_i", "_unit", "_killUnits", "_ret", "_current_target_pos"];
	_grp = _this;
	_ret = true;
	if ( (!isNull _grp) && (count (units _grp)) > 0 ) then
	{
		_badunits = units _grp; // execution list
		_counter = count _badunits;
		if ( _counter  > 0 ) then
		{
            _pilot = objNull;
            _goodunits = [] + _badunits; // live units list

            for "_i" from 0 to _counter - 1 do
            {
                _unit = _badunits select _i;
                if ( !alive _unit) then
                {
                    _goodunits set [_i, "RM_ME"];
                }
                else
                {
                    if ( _unit  call SYG_ACEUnitUnconscious ) then
                    {
                        _goodunits set [_i, "RM_ME"];
                    }
                    else
                    {
                        _badunits set [_i, "RM_ME"];
                        _unit setRank "PRIVATE";
                        _pilot = _unit;
                    };
                };
            };
            _badunits = _badunits - ["RM_ME"];
            _goodunits = _goodunits - ["RM_ME"];
            _newgrp = grpNull;
            if ( !isNull _pilot ) then // there is some alive pilots in the group
            {

                _newgrp     = [_pilot, 2500, (count _goodunits) + 1] call SYG_findGroupAtTargets;
                // prepare good pilots to change group
                if ( !isNull _newgrp ) then
                {
#ifdef __PRINT__
                    hint localize format["x_airki.sqf: Rejoin good pilots (%1) to group %2 (%3 men), and removing invalid pilots %4",_goodunits, _newgrp, count units _newgrp, _badunits];
#endif
                    _goodunits join _newgrp;
                    sleep 0.25;
                }
                else
                {
                    // no good group is found, let kill them all now
#ifdef __PRINT__
                    hint localize format["x_airki.sqf: Re-join is unavailble, kill air crew, as good (%1) as bad (%2)",_goodunits, _badunits];
#endif
                    _goodunits call _killUnits; // TODO: first try to find and kill enemy that shot heli/plane
                    _ret = false;
                };
                sleep 0.36;
            }
            else
            {
#ifdef __PRINT__
                hint localize format["x_airki.sqf: No good pilots in grp %1 found, remove bad ones (%2)", _grp, _badunits];
#endif
                _ret = false;
            };
            _badunits call _killUnits;
            _badunits = nil;
            _goodunits = nil;
		}
		else { _ret = false; };
	}
	else
	{
#ifdef __PRINT__	
		hint localize "x_airki.sqf: Grp is <NULL> or pilots are dead";
#endif		
		_ret = false;
	};
	_ret
};

_initial_type = _type;
_min_dist_between_wp = 100;

// ***************************************
// *       Main loop of the script       *
// ***************************************

while { true } do {

    // possibility for SU creation is about 33%
    if (_initial_type == "SU") then {_type = (if ((random 100) > 33) then {"MIMG"} else {"SU"});};

#ifdef __PRINT__
	hint localize format["x_airki.sqf[%1]: +++ Enter wait loop",_type];
#endif
 	if (!mt_radio_down) then { // while tower stands
		while {!mt_spotted} do {sleep 23.32}; // wait until player is spotted
	} else { // tower is down
		while {mt_radio_down} do {sleep 21.123}; // wait for next tower standing
		if (!mt_spotted) then { //if player not spotted
			while {!mt_spotted} do {sleep 23.32}; // wait until player spotted
		};
	};

#ifdef __PRINT__
	hint localize format["x_airki.sqf[%1]: --- Exit wait loop",_type];
#endif

// "GRU reports that the enemy aircraft carrier launched procedures for the flight of some %1"
["msg_to_user","",[["STR_GRU_53",format["STR_GRU_53_%1",_initial_type]]],4,4 + round(random 4)] call XSendNetStartScriptClient;

// If GRU is active on, print also info about heli type

	_grp = objNull;
	_vehicle = objNull;
	_vehicles = nil;
	_vehicles = [];
	_num_p = call XPlayersNumber;
	_re_random = (
		if (_num_p < 5) then {
			1500
		} else {
			if (_num_p < 10) then {
				1000
			} else {
				if (_num_p < 20) then {
					500
				} else {
					250
				}
			}
		}
	);

#ifdef __SYG_AIRKI_DEBUG__
	_re_random = 20;
#endif		

#ifdef __DEBUG__
	hint localize format[ "x_airki.sqf[%2]: _re_random %1", _re_random, _type ];
#endif

	if (_num_p < 5) then {

#ifdef __SYG_AIRKI_DEBUG__
		hint localize format["x_airki.sqf[%1]: sleep 10 secs", _type];
		sleep 10;
#else	
		hint localize format["x_airki.sqf[%1]: sleep 800 secs", _type];
		sleep (400 + (random 800));
#endif		
	} else {
		if (_num_p < 10) then {
			sleep (200 + (random 400));
		} else {
			if (_num_p < 20) then {
				sleep (100 + (random 200));
			}
		}
	};
	if (X_MP) then {
		if ((call XPlayersNumber) == 0) then
		{
			waitUntil {sleep (10.012 + random 1); (call XPlayersNumber) > 0 };
			// sleep some time to allow different arriving
			if (_initial_type == "KA" ) then { sleep (random KA_MIMG_ARRIVAL_DELAY); }; // to prevent arriving at near time
		};
	};
	//__DEBUG_NET("x_airki.sqf",(call XPlayersNumber))
	while {mt_radio_down} do {sleep 21.123};
	_randxx = floor (random count (d_airki_start_positions));
	_pos = d_airki_start_positions select _randxx;
	
#ifdef __ACE__
	_grpskill = 0.6 + (random 0.3);
#else
	_grpskill = 0.6 + (random 0.3);
#endif

    _heli_type = "";

	//__WaitForGroup
	//__GetEGrp(_grp)
	_grp = call SYG_createEnemyGroup;
	_vec_cnt = 1;
	_heli_arr = d_light_attack_chopper;
	_flight_height = 200;
	_flyby_height  = 300;
	switch (_type) do {
		case "KA": 
		{
			_vec_cnt = d_number_attack_choppers;
			_heli_arr = d_airki_attack_chopper;
			_flight_height = 115;
        	_flyby_height  = 500;
			_flight_random = 5;
			_min_dist_between_wp = 100;
		};
		case "SU": 
		{
			_vec_cnt = d_number_attack_planes;
			_heli_arr = d_airki_attack_plane;
			_flight_height = 300;
        	_flyby_height  = 1000;
			_flight_random = 20;
			_min_dist_between_wp = 500;
		};
		case "MIMG"; 
		default 
		{
			_vec_cnt = d_number_attack_choppers;
			_heli_arr = d_light_attack_chopper;
			_flight_height = 90;
        	//_flyby_height  = 300;
			_flight_random = 20;
			_min_dist_between_wp = 100;
		};
	}; // switch (_type) do 

	//==========================
	//= creation of vehicle[s] =
	//==========================
	_dummy = target_names select current_target_index;

	for "_xxx" from 1 to _vec_cnt do {
		_heli_type = _heli_arr call XfRandomArrayVal;
		_vehicle = createVehicle [_heli_type, _pos, [], 100, "FLY"];
		_vehicle setVariable ["damage",0];
		
		
		_vehicles = _vehicles + [_vehicle];
		[_vehicle, _grp, _crew_member, _grpskill] call SYG_populateVehicle;

		{ // support each crew member
			//__addDead(_x)
			_x addEventHandler ["killed", {[_this select 0] call XAddDead;}];
			#ifdef __TT__
			_x addEventHandler ["killed", {[1,_this select 1] call XAddKills;}];
			#endif
			#ifdef __AI__
			if (__RankedVer) then {	_x addEventHandler ["killed", {[1,_this select 1] call XAddKillsAI}];};
			#endif
			sleep 0.01;
		} forEach crew _vehicle;
		[_heli_type, _vehicle] call _addToClean;
		_vehicle flyInHeight (_flight_height + (random _flight_random));
#ifdef __PRINT__	
	hint localize format["x_airki.sqf[%3]: %1 created to patrol town %2 at pos %4",_heli_type, _dummy select 1, _type, _pos];
#endif	
		sleep 0.01;
	};
	
	sleep 1.011;

	_leader = leader _grp;
	_leader setRank "LIEUTENANT";
	_grp allowFleeing 0;
	
	_old_target = [0,0,0];
	_loop_do = true;
	_dummy = target_names select current_target_index;
	
	_current_target_pos = _dummy select 0;
	if ((_vehicles select 0) distance _current_target_pos > (_vehicles select 0) distance d_island_center) then {
		_wp = _grp addWaypoint [d_island_center, 100];
	};
	_wp = _grp addWaypoint [_current_target_pos, 50];
	_wp setWaypointType "SAD";
	_pat_pos = _current_target_pos;
	[_grp, 1] setWaypointStatements ["never", ""];

#ifdef __PRINT__
	_lastDamage = 0;
#endif

    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//+ loop for vehicle patrol itself, while they are alive +
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	while {_loop_do} do {
		// TODO: allow target be not only town but sometimes side misison base or occupied town too
#ifdef __FUTURE__
		// find all zones of interest
        // if players not near town during some time
        if ( _type in ["SU","KA"]) then // check for other goal, not only main target
        {
            if ((random 100) < 10) then // 1 of 10 times try it
            {
                _res_arr = [getPos player, true,["OCCUPIED","AIRBASE","SIDEMISSION","LOCATION","SETTLEMENT"],15000] call SYG_nearestZoneOfInterest;
            };
        };
#else
		_dummy = target_names select current_target_index;
		_current_target_pos = _dummy select 0;
		_radius = (_dummy select 2) + 100; // increase target border radius by 100 m
#endif
#ifdef __DEFAULT__
		if ( (_dummy select 1) in d_mountine_towns ) then // mountine  town ["Hunapu","Pacamac"]
		{
			switch _type do
			{
				case "KA";
				case "MIMG":
				{
					// forEach _vehicles;
					{
						_x flyInHeight (160 + random 20);
					} forEach _vehicles;
				};
				case "SU":
				{
					// forEach _vehicles;
					{
						_x flyInHeight (450 + random 20);
					} forEach _vehicles;
				};
			};
		};
#endif		
		
		sleep 0.5754;

		switch (_type) do {
			case "KA";
			case "MIMG": {_radius = _radius * 5;};
			case "SU": {_radius = _radius * 15;};
		};

		_angle = floor (random 360);
		_dist = (sqrt((random _radius)/_radius)) * _radius;
		_x1 = (_current_target_pos select 0) - ( _dist * cos _angle);
		_y1 = (_current_target_pos select 1) - ( _dist * sin _angle);
		_pat_pos = [_x1, _y1,(_current_target_pos select 2)];
		if ( _type in ["KA","MIMG"] ) then {
			_old_pat_pos = _pat_pos;
			// prepare  new patrol position
			// ensure new position distance more than 100 meters from current one
			while {(_pat_pos distance _old_pat_pos) < _min_dist_between_wp} do {
				_angle = random 360;
				_dist = (sqrt((random _radius)/_radius)) * _radius;
				_x1 = (_current_target_pos select 0) - ( _dist * cos _angle);
				_y1 = (_current_target_pos select 1) - ( _dist * sin _angle);
				_pat_pos = [_x1, _y1,(_current_target_pos select 2)];
				sleep 0.01;
			};
			[_grp, 1] setWaypointPosition [_pat_pos, 0];
			_grp setSpeedMode "NORMAL";
			_grp setBehaviour _wp_behave;
			// wait until near WP
			sleep 15.821;
		} else { // SU type
			[_grp, 1] setWaypointPosition [_pat_pos, 0];
			_grp setSpeedMode "LIMITED";
			_grp setBehaviour _wp_behave;
			sleep (120 + random 120);
			// reload weapon for SU after delay
			_vehicles call SYG_fastReload; // reload SU just in case
		};
		
		if (X_MP && ()(call XPlayersNumber) == 0) then {
		    hint localize "x_airki.sqf: no players, wait for next one";
			waitUntil {sleep (5.012 + random 1);(call XPlayersNumber) > 0};
		};
		//__DEBUG_NET("x_airki_2.sqf",(call XPlayersNumber))
		if (count _vehicles > 0) then {
			for "_i" from 0 to ((count _vehicles) - 1) do {
				_vecx = _vehicles select _i;
				if ( isNull _vecx ) then 
				{
					_vehicles set [_i, "X_RM_ME"]; 
#ifdef __PRINT__
					hint localize format[ "x_airki.sqf[%1]: airkiller is Null, remove from list",  _type];
#endif			
				}
				else
				{
					if (!alive _vecx || !canMove _vecx) then {
						sleep 1;
						if ( ( {alive _x} count (crew _vecx) ) == 0 ) then {
							s_down_heli_arr = s_down_heli_arr + [_vecx];
							_vehicles set [_i, "X_RM_ME"];
						};
					} else 
					{
#ifdef __PRINT__
						if ( count _vehicles == 1) then
						{
							if ( ((damage _vecx) > 0) && ((damage _vecx) != _lastDamage) ) then
							{
								hint localize format[ "x_airki.sqf[%3]: airkiller %1 received damage = %2", typeOf _vecx, damage _vecx, _type ];
								_lastDamage = damage _vecx;
							};
						};
#endif			
						_vecx setFuel 1;
					};
					sleep 0.01;
				};
			};
			_vehicles = _vehicles - ["X_RM_ME"];
		};
		
		if (count _vehicles == 0) exitWith //+++ Sygsky: OPTIMIZE, crew may be on feet from now or wholly dead 
		{
			_vehicles = nil;
			_loop_do = false;
			sleep 5.654321;
#ifdef __PRINT__
			_cnt = units _grp;
#endif			
			_ret = _grp call _rejoinPilots;
#ifdef __PRINT__
			hint localize format[ "x_airki.sqf[%1]: all vehicle[s] are down, rejoin %2 pilot[s], rejoined %3", _type, _cnt, _ret ];
#endif
		};
#ifdef __FUTURE__		
		//+++ Sygsky: try to reveal info on known enemies for near friendly units
		_pos = getPos _vehicle select 0;
		_pos set [2, 0];
		_enemy_arr = nearestObjects [ _pos, ["SoldierEB","Tank"], 300];
		//+++ Sygsky: TODO add info exchange between air-air, air-land, air-ship units
#endif		
	}; // while {_loop_do} do
	
	_ret = d_airki_respawntime + _re_random + random (_re_random);
	
#ifdef __PRINT__
	hint localize format[ "x_airki.sqf[%3]: internal main loop finished, sleep for %1 secs; s_down_heli_arr[%2]", round(_ret), count s_down_heli_arr, _type];
#endif			

	sleep _ret;
}; // while {true} do

#ifdef __PRINT__
	hint localize format["x_airki.sqf[%1]: --- outer loop is exited, that is NONsense! ---", _type];
#endif			

if (true) exitWith {};

