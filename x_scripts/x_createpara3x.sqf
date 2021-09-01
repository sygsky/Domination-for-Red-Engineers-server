// by Xeno
//
// x_createpara3x.sqf: not used from January-2021 (replaced by x_scripts\x_createpara3xcargopopulated.sqf)
// called from x_scripts\x_parahandler.sqf as follow: [_start_pos,_attack_pos,_end_pos,_vecs, _fly_height] execVM "x_scripts\x_createpara3x.sqf";
//
// creates paratroopers for targeted city, heli created in x_scripts\x_parahandler.sqf
//
private ["_type","_startpoint","_attackpoint","_heliendpoint","_number_vehicles","_fly_height","_crew_member","_parachute_type","_make_jump","_stop_it","_current_target_pos","_dummy", "_mti"];
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

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
	private ["_vgrp", "_vehicle", "_attackpoint", "_heliendpoint", "_driver_vec", "_wp", "_stop_me", "_parachute_type", "_dummy", "_current_target_pos", "_paragrp", "_unit_array", "_real_units", "_i", "_type", "_one_unit", "_para", "_leader", "_grp_array"];
	_vgrp = _this select 0;
	_vehicle = _this select 1;
	_attackpoint = _this select 2;
	_heliendpoint = _this select 3;
	
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
	
	_stop_me = false;
	while {_attackpoint distance (leader _vgrp) > 200} do {
		if (isNull _vehicle || !alive _vehicle || !alive _driver_vec || !canMove _vehicle) exitWith {d_should_be_there = d_should_be_there - 1};
		sleep 0.01;
		if (mt_radio_down && (_attackpoint distance (leader _vgrp) > 1300)) exitWith {
			{_x removeAllEventHandlers "killed"; deleteVehicle _x} forEach ([_vehicle] + crew _vehicle);
			_stop_me = true;
		};
		sleep 2.023;
	};
	if (_stop_me) exitWith {};
	
	sleep 0.534;
	
	_parachute_type = (
		switch (d_enemy_side) do {
			case "EAST": {"ParachuteEast"};
			case "WEST": {"ParachuteWest"};
		}
	);
	
	if (!isNull _vehicle && alive _vehicle && alive _driver_vec && canMove _vehicle) then {
		_dummy = target_names select current_target_index;
		_current_target_pos = _dummy select 0;
		if (!mt_radio_down && (_vehicle distance _current_target_pos < 300)) then {
			__WaitForGroup
			__GetEGrp(_paragrp)
			_unit_array = ["heli", d_enemy_side] call x_getunitliste;
			_real_units = _unit_array select 0;
			_unit_array = nil;
			
			// try to animate ramp opening
#ifdef __ACE__	
			// animate heli action
			if ( _vehicle isKindOf "ACE_CH47D" ) then {
				_vehicle animate ["ramp", 1]; // open ramp
			};
#endif
			sleep 0.1;
			for "_i" from 0 to ((count _real_units) - 1) do {
				_type = _real_units select _i;
				_one_unit = _paragrp createunit [_type, [0,0,0], [], 300,"NONE"];
				[_one_unit] join _paragrp;
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
				
				_para = createVehicle [_parachute_type, position _vehicle, [], 20, 'NONE'];
				//_para setPos [(position _vehicle) select 0,(position _vehicle) select 1,((position _vehicle) select 2)- 12 + (random 2)];
				_para setPos (_vehicle modelToWorld [(random 2) - 1, -7 + (random 2), -12 + (random 4)]);
				_para setDir ((direction _vehicle) + 135 + (random 90)); //+++ Sygsky: set random direction for each paratrooper with direction to chopper back
				
				_one_unit moveInDriver _para;
				sleep (0.85 + (random 0.25));
			};
			// fly on height about 200 meters after paradrop completion (prevent collision with mountain slopes)
			_vehicle flyInHeight 200;
			
#ifdef __ACE__	
			// animate heli action - close ramp
			if ( _vehicle isKindOf "ACE_CH47D" ) then
			{
				_vehicle animate ["ramp", 0]; // close ramp
			};
#endif	
			_leader = leader _paragrp;
			_leader setRank "LIEUTENANT";
			_paragrp allowFleeing 0;
			_paragrp setCombatMode "YELLOW";
			_paragrp setBehaviour "AWARE";
			
			_grp_array = [_paragrp, [position _leader select 0, position _leader select 1, 0], 0,[_current_target_pos,200],[],-1,0,[],300 + (random 50),0,[2]]; // rejoin in 2 units in group
			_grp_array execVM "x_scripts\x_groupsm.sqf";
			
			d_c_attacking_grps set [count d_c_attacking_grps, _paragrp];
			
			sleep 0.112;
			d_should_be_there = d_should_be_there - 1;

			//+++ Sygsky: rearm group
			_paragrp call SYG_rearmBasicGroup;
			//--- Sygsky
			
			while {(_heliendpoint distance (leader _vgrp) > 300)} do {
				if (isNull _vehicle || !alive _vehicle || !alive _driver_vec || !canMove _vehicle) exitWith {};
				sleep 5.123;
			};
			
			{_x removeAllEventHandlers "killed"; deleteVehicle _x} forEach ([_vehicle] + crew _vehicle);
			if (!isNull _driver_vec) then {_driver_vec setDamage 1.1};
		};
	} else {
		[_driver_vec, _vehicle] spawn {
			private ["_driver_vec","_vehicle"];
			_driver_vec = _this select 0;
			_vehicle = _this select 1;
			sleep 240 + random 100;
			if (!isNull _driver_vec) then {
				_driver_vec setDamage 1.1;
			};
			if (!isNull _vehicle) then {
				{_x removeAllEventHandlers "killed"; deleteVehicle _x} forEach ([_vehicle] + crew _vehicle);
			};
		};
	};
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
	
	[_vgrp,_vehicle,_attackpoint,_heliendpoint] spawn _make_jump;
	
	sleep 40 + random 30;
};

if (_stop_it) exitWith {};

while {d_should_be_there > 0 && !mt_radio_down} do {sleep 1.021;};

if (!mt_radio_down) then {
	sleep 20.0123;
	if (count d_c_attacking_grps > 0) then {
		[d_c_attacking_grps] execVM "x_scripts\x_handleattackgroups.sqf";
	} else {
		d_c_attacking_grps resize 0;
		create_new_paras = true;
	};
};

if (true) exitWith {};



