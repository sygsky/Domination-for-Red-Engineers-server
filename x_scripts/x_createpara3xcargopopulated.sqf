// by Xeno
//
// x_createpara3xcargopopulated.sqf
//
// creates paratroopers for targeted city + heli to actually transport them
private ["_type","_startpoint","_attackpoint","_heliendpoint","_number_vehicles","_fly_height","_crew_member","_parachute_type","_make_jump","_stop_it","_current_target_pos","_dummy", "_mti",
         "_cnt_uni"];
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

#define HEIGHT_TO_EJECT 80

_startpoint = _this select 0;
_attackpoint = _this select 1;
_heliendpoint = _this select 2;
_number_vehicles = _this select 3;
_fly_height = 100;
if ( count _this > 4) then {_fly_height = _this select 4};

d_should_be_there = _number_vehicles;

d_c_attacking_grps = [];

_crew_member = (
	switch (d_enemy_side) do {
		case "EAST": {d_pilot_E};
		case "WEST": {d_pilot_W};
	}
);

_make_jump = {
	private ["_vgrp", "_vehicle", "_attackpoint", "_heliendpoint", "_driver_vec", "_wp", "_stop_me", "_parachute_type", "_dummy", "_current_target_pos", "_unit_array", "_real_units", "_i", "_type", "_one_unit", "_para", "_leader", "_grp_array", 
	         "_cur_uni", "_eject_complete", "_next_to_eject", "_main_polling_interval", "_cnt_uni", "_paragrp", "_emergency_eject", "_at_least_one_active"] ;
	_vgrp = _this select 0;
	_paragrp = _this select 1;
	_unit_array = _this select 2;
	_vehicle = _this select 3;
	_attackpoint = _this select 4;
	_heliendpoint = _this select 5;
	_cnt_uni = count _unit_array;
	
	_driver_vec = driver _vehicle;
	
	if (_vehicle distance _attackpoint > _vehicle distance d_island_center) then {
		_wp = _vgrp addWaypoint [d_island_center, 0];
		_wp setWaypointBehaviour "CARELESS";
		_wp setWaypointSpeed "NORMAL";
		_wp setwaypointtype "MOVE";
		_wp setWaypointFormation "VEE";
	};
	
	_wp = _vgrp addWaypoint [_attackpoint, 0];
	_wp setWaypointBehaviour "CARELESS";
	_wp setWaypointSpeed "NORMAL";
	_wp setwaypointtype "MOVE";
	_wp setWaypointFormation "VEE";
	if (_heliendpoint distance _attackpoint > _heliendpoint distance d_island_center) then {
		_wp = _vgrp addWaypoint [d_island_center, 0];
	};
	_wp = _vgrp addWaypoint [_heliendpoint, 0];
	
	_vehicle flyInHeight _fly_height;
	
	sleep 10.0231;
	// Wait until heli is 200 meters near to droping point
	_eject_complete = false;
	_cur_uni = 0;
	_next_to_eject = 0;
	_emergency_eject = false; 
	_at_least_one_active = false;
	_main_polling_interval = 2.123;

	while { ([_attackpoint,leader _vgrp] call SYG_distance2D) > 200 || !canMove _vehicle} do {
		if (mt_radio_down && (_attackpoint distance (leader _vgrp) > 1300)) exitWith {
			{
				_x removeAllEventHandlers "killed";
				deleteVehicle _x
			} forEach ([_vehicle] + crew _vehicle + _unit_array);
			//_stop_me = true;
		};

		if (!alive _vehicle) exitWith {};
		if (!canMove _vehicle && !_eject_complete && alive driver _vehicle && alive _vehicle) then {
			while {alive _vehicle && alive driver _vehicle && (position _vehicle select 2) >= HEIGHT_TO_EJECT && !_eject_complete} do {
				_cur_uni = _unit_array select _next_to_eject;
				if (alive _cur_uni ) then {
					_cur_uni action ["Eject",_vehicle];
					_emergency_eject = true;
					unassignVehicle _cur_uni;
				};
				_next_to_eject = _next_to_eject + 1;
				sleep 0.82;
			};
			_eject_complete = _next_to_eject >= _cnt_uni;
		};

		if (!canMove _vehicle && !_eject_complete && alive driver _vehicle && alive _vehicle) then {
			while {alive _vehicle && alive driver _vehicle && (position _vehicle select 2) < HEIGHT_TO_EJECT && !_eject_complete} do {
				if (position _vehicle select 2 < 2) exitWith {
					while {_next_to_eject < _cnt_uni} do {
						_cur_uni = _unit_array select _next_to_eject;
						if ( alive _cur_uni ) then {
							_cur_uni action ["Eject",_vehicle];
							_emergency_eject = true;
							unassignVehicle _cur_uni;
						};
						_next_to_eject = _next_to_eject + 1;
						sleep 0.81;
					};
					_eject_complete = _next_to_eject >= _cnt_uni;
				};
			};
		};
		
		if (!alive driver _vehicle) exitWith {};
		if (!canMove _vehicle && (position _vehicle select 2) >= HEIGHT_TO_EJECT) then {_main_polling_interval = 0.1;};
		if (!canMove _vehicle && (position _vehicle select 2) < HEIGHT_TO_EJECT) then {_main_polling_interval = 1.123;};
		if (_eject_complete) exitWith	{};
		sleep _main_polling_interval;
	};
	

	//if (_stop_me) exitWith {};	

#ifdef __ACE__	
			// animate heli action
			if ( _vehicle isKindOf "ACE_CH47D" && alive _vehicle) then {
				_vehicle animate ["ramp", 1]; // open ramp
			};
			sleep 5.0;
#endif	
	
	//Regular drop, or emergency drop from chopper with dead pilot
	if (!_eject_complete && alive _vehicle) then {
			while {_next_to_eject < _cnt_uni &&  alive _vehicle} do {
				_cur_uni = _unit_array select _next_to_eject;
				if ( alive _cur_uni && canMove _cur_uni) then {
					_cur_uni action ["Eject",_vehicle];
					unassignVehicle _cur_uni;
				};
				_next_to_eject = _next_to_eject + 1;
				if (_emergency_eject) then {
					sleep 0.81;
				} else {
					sleep (0.85 + (random 0.25));
				};
			};
		_eject_complete = true;
	};
	
	if (_eject_complete) then {sleep 30};
	
	_unit_array = nil;
	
	if (alive _vehicle) then {
		_vehicle flyInHeight 200;
	};
			
#ifdef __ACE__	
			// animate heli action - close ramp
			if ( _vehicle isKindOf "ACE_CH47D"  && alive _vehicle) then	{
				_vehicle animate ["ramp", 0]; // close ramp
			};
#endif	

	{   
		if (alive _x && canMove _x) exitWith { 
			_at_least_one_active = true;
		};
	} forEach units _paragrp;

	if (_at_least_one_active) then {
		_leader = leader _paragrp;
		_leader setRank "LIEUTENANT";
		_paragrp allowFleeing 0;
		_paragrp setCombatMode "YELLOW";
		_paragrp setBehaviour "AWARE";
		
		_grp_array = [_paragrp, [position _leader select 0, position _leader select 1, 0], 0,[_current_target_pos,200],[],-1,0,[],300 + (random 50),0,[2]]; // rejoin in 2 units in group
		_grp_array execVM "x_scripts\x_groupsm.sqf";
	
		d_c_attacking_grps = d_c_attacking_grps + [_paragrp];
	
		sleep 0.112;
		d_should_be_there = d_should_be_there - 1;

		//+++ Sygsky: rearm group	
		(units _paragrp) call SYG_rearmBasicGroup;
		//--- Sygsky
	} else {
		d_should_be_there = d_should_be_there - 1;
	};
	
	while {(_heliendpoint distance (leader _vgrp) > 300)} do {
		if (isNull _vehicle || !alive _vehicle || !alive _driver_vec || !canMove _vehicle) exitWith {};
		sleep 5.123;
	};

	{  
	    _x removeAllEventHandlers "killed";
   	    deleteVehicle _x;
	} forEach ([_vehicle] + crew _vehicle);
	
	if (!isNull _driver_vec) then {_driver_vec setDamage 1.1};
	
};

_dummy = target_names select current_target_index;
_current_target_pos = _dummy select 0;
_stop_it = false;

for "_i" from 1 to _number_vehicles do {
	if (mt_radio_down) exitWith {};
	_dummy = target_names select current_target_index;
	_new_current_target_pos = _dummy select 0;
	if (_new_current_target_pos distance _current_target_pos > 500) exitWith {_stop_it = true;};
	__WaitForGroup
	__GetEGrp(_vgrp)
	_heli_type = d_transport_chopper select ((count d_transport_chopper) call XfRandomFloor);
	_vehicle = createVehicle [_heli_type, _startpoint, [], 150, "FLY"];
	[ _vehicle, _vgrp, _crew_member, 1.0 ] call SYG_populateVehicle;
	
	{ // support each crew member
		#ifdef __TT__
		_x addEventHandler ["killed", {[1,_this select 1] call XAddKills;}];
		#endif
		#ifdef __AI__
		if (__RankedVer) then {	_x addEventHandler ["killed", {[1,_this select 1] call XAddKillsAI}]; };
		#endif
		__addDead(_x)
		sleep 0.01;
	} forEach crew _vehicle;

	
	if (!(_heli_type in x_heli_wreck_lift_types)) then {
	    //insure that vehicle will be removed after destroyed    
		__addRemoveVehi(_vehicle)
		if (!d_lock_ai_air) then {
			[_vehicle] call XAddCheckDead;
		};
	};
	#ifdef __TT__
	_vehicle addEventHandler ["killed", {[8,_this select 1] call XAddKills;}];
	#endif
	#ifdef __AI__
	if (__RankedVer) then {
		_vehicle addEventHandler ["killed", {[8,_this select 1] call XAddKillsAI}];
	};
	#endif
	// Chopper is prepared now and waiting for cargo
	
	_paragrp = call SYG_createEnemyGroup;
	_unit_array = ["heli", d_enemy_side] call x_getunitliste;
	_real_units = _unit_array select 0;
	_cnt_uni = (count _real_units) min (_vehicle emptyPositions "Cargo"); // heli may be small one
	_unit_array = [];

	sleep 0.1;
	for "_i" from 0 to (_cnt_uni - 1) do 
	{
		_type = _real_units select _i;
		_one_unit = _paragrp createUnit [_type, [0,0,0], [], 300,"NONE"];
		_one_unit moveInCargo _vehicle;
		[_one_unit] join _paragrp;
		_unit_array set [ count _unit_array, _one_unit];
		_one_unit addEventHandler ["killed", {[_this select 0] call XAddDead;if (d_smoke) then {[_this select 0, _this select 1] spawn x_dosmoke}}];
		#ifdef __TT__
		_one_unit addEventHandler ["killed", {[1,_this select 1] call XAddKills;}];
		#endif
		#ifdef __AI__
		if (__RankedVer) then {
			_one_unit addEventHandler ["killed", {[1,_this select 1] call XAddKillsAI}];
		};
		#endif
		_one_unit setSkill ((d_skill_array select 0) + (random (d_skill_array select 1)));
	};
	// cargo is created and loaded on the chopper
	
	
	if (d_lock_ai_air) then {
		_vehicle lock true;
	};
	sleep 5.012;
	
	_vehicle flyInHeight 100;
	hint localize format["+++x_createpara3x.sqf: Air assault procedure to current town %2 with %1 starts at pos %3", typeOf _vehicle, _dummy select 1, _startpoint];

	if (mt_radio_down) exitWith {
		_stop_it = true;
		[_vehicle] spawn {
			private ["_vehicle"];
			_vehicle = _this select 0;
			sleep 240 + random 100;
			if (!isNull _vehicle) then {
				{_x removeAllEventHandlers "killed"; deleteVehicle _x} forEach ([_vehicle] + crew _vehicle);
			};
		};
	};
	
	[_vgrp,_paragrp,_unit_array,_vehicle,_attackpoint,_heliendpoint] spawn _make_jump;
	
	sleep 40 + random 30;
};

if (_stop_it) exitWith {};

while {d_should_be_there > 0 && !mt_radio_down} do {sleep 1.021;};

if (!mt_radio_down) then {
	sleep 20.0123;
	if (count d_c_attacking_grps > 0) then {
		[d_c_attacking_grps] execVM "x_scripts\x_handleattackgroups.sqf";
	} else {
		d_c_attacking_grps = [];
		create_new_paras = true;
	};
};

if (true) exitWith {};



