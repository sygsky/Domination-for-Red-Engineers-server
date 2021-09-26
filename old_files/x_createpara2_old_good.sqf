// by Xeno
//
// x_createpara2.sqf : old script, not used anymore
//
// Creates paratroopers for base invasion, eject them and check heli up to the final moment
//
//private ["_assigned","_helifirstpoint","_chopper","_paragrp","_leader","_pos_end","_u","_unit_array","_vgrp","_wp","_xx","_heliendpoint","_wp2","_attack_pos", "_i", "_grp_array","_parachute_type"];
private ["_assigned", "_helifirstpoint", "_chopper", "_paragrp", "_leader", "_u", "_vgrp", "_wp", "_xx", 
         "_heliendpoint", "_wp2", "_attack_pos", "_i", "_unti1", "_vehicle", "_type", "_para", "_units", 
		 "_cnt", "_res","_grp_array","_parachute_type"];

if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

#define __SYG_PIPEBOMB__
//#define __DEBUG__

_vgrp = _this select 0;
_chopper = _this select 1;
_helifirstpoint = _this select 2;
_heliendpoint = _this select 3;

sleep 2.123;

_wp = _vgrp addWaypoint [_helifirstpoint, 30];
_wp setWaypointBehaviour "CARELESS";
_wp setWaypointSpeed "NORMAL";
_wp setwaypointtype "MOVE";
_wp setWaypointFormation "WEDGE";

_wp2 = _vgrp addWaypoint [_heliendpoint, 0];
_wp2 setwaypointtype "MOVE";
_wp2 setWaypointBehaviour "CARELESS";
_wp2 setWaypointSpeed "NORMAL";
_wp2 setwaypointtype "MOVE";

_chopper flyInHeight 100; // fly on height about 100 meters

_parachute_type = (
	switch (d_enemy_side) do {
		case "EAST": {"ParachuteEast"};
		case "WEST": {"ParachuteWest"};
	}
);

// Wait until heli is 150 meters near to droping point
while {_helifirstpoint distance (leader _vgrp) > 250} do {
	if (isNull _chopper || !alive _chopper || !canMove _chopper || !alive driver _chopper ) exitWith { // But if heli already out of service
		[driver _chopper, _chopper] spawn 
		{ // So kill pilot just in case
			private ["_driver_veh","_vehicle"];
			_driver_veh = _this select 0;
			_vehicle = _this select 1;
			sleep 240 + random 100;
			if (!isNull _driver_veh) then 
			{
				_driver_veh setDamage 1.1;
			};
			if (!isNull _vehicle) then 
			{
				{_x removeAllEventHandlers "killed"; deleteVehicle _x} forEach ([_vehicle] + crew _vehicle);
			};
		};
	};
	sleep 2.123;
};

// try to anumate ramp opening
#ifdef __ACE__	
	// animate heli action
	if ( _chopper isKindOf "ACE_CH47D" ) then
	{
		_chopper animate ["ramp", 1]; // open ramp
		// hint localize "x_createpara2.sqf: _chopper animate [""ramp"", 1] executed";
	};
#endif	
	sleep 5.123;

if (alive _chopper && !isNull _chopper && canMove _chopper && alive (driver _chopper) ) then // create sabotage group
{
	__GetEGrp(_paragrp)
	_unit_array = ["sabotage", d_enemy_side] call x_getunitliste;
	_real_units = _unit_array select 0;
	_unit_array = nil;
	sleep 0.1;
	for "_i" from 0 to ((count _real_units) - 1) do 
	{
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
		
		_para = createVehicle [_parachute_type, position _chopper, [], 20, 'NONE'];
//		_para setPos [(position _chopper) select 0,(position _chopper) select 1,((position _chopper) select 2)- 12 + (random 2)];
		_para setPos (_chopper modelToWorld [(random 2) - 1, -7 + (random 2), -12 + (random 4)]);
		_para setDir ((direction _chopper) + 135 + (random 90)); //+++ Sygsky: set random direction for each paratrooper with direction to chopper back
		_one_unit moveInDriver _para;
		sleep (0.85 + (random 0.25));
		if (!alive _chopper OR isNull _chopper OR ! canMove _chopper OR (!alive (driver _chopper))) exitWith {};
	};
	// fly on height about 200 meters after paradrop completion (prevent collision with mountain slopes)
	_chopper flyInHeight 200;

#ifdef __ACE__	
	// animate heli action
	if ( _chopper isKindOf "ACE_CH47D" ) then
	{
		_chopper animate ["ramp", 0]; // close ramp
		//hint localize "x_createpara2.sqf: _chopper animate [""ramp"", 0] executed";
	};
#endif	

	_leader = leader _paragrp;
	_leader setRank "LIEUTENANT";
	_paragrp allowFleeing 0;
	_paragrp setCombatMode "YELLOW";
	_paragrp setBehaviour "AWARE";
	_paragrp setFormation "VEE";
	sleep 0.113;
	/*
	[
		[[9502,9871.2,0],290,150,0],       // court of airbase
		[[10239.6,9901.48,0],160,200,-25], // airbase part near Paraiso
		[[9956,9771,0],175,250,0],         // middle south of airfield + hangars
		[[9780.1,10332.6,0],650,170,0],    // north of airfield
		[[9149.29,10079,0],125,100,0]     // west of airfield
	];
	*/
#ifdef __DEBUG
	_xx = d_base_patrol_markers select 0; // patrol area of internal yard
#else	
	_xx = d_base_patrol_markers call XfRandomArrayVal;
#endif	
	
#ifdef __SYG_PIPEBOMB__	
	//"__SYG_PIPEBOMB__ in x_createpara2.sqf detected" call XfGlobalChat;

	// load Kronzky urban patrol script (UPS)
	//sleep 15.0; // wait for paratroopers landing
	
	// select random area to patrol
 	hint localize format["%1 x_createpara2.sqf: patrol area %2 selected for group %3(%4)", call SYG_missionTimeInfoStr, _xx, _paragrp, count units _paragrp];
	_xx = [ _leader, _xx, "SAVEDIST:", 150, "NOSLOW" ] execVM "scripts\UPS.sqf"; // run urban patrol logic

	// use d_ups_array except of d_base_array
	//_grp_array = [_paragrp, [position _leader select 0, position _leader select 1, 0], 0,[d_ups_array select 0,d_ups_array select 1,d_ups_array select 2,0],[],-1,1,[],500,1+10];
	//_grp_array execVM "x_scripts\x_groupsm.sqf";
#else	
	//"Std definitions for x_createpara2.sqf detected" call XfGlobalChat; // last parameters stands for rejoin try if 2 men in group remained
	_grp_array = [_paragrp, [position _leader select 0, position _leader select 1, 0], 0,[d_base_array select 0,d_base_array select 1,d_base_array select 2,0],[],-1,1,[],500,1,[2]]; // try rejoin if number of units <= 2
	_grp_array execVM "x_scripts\x_groupsm.sqf";
#endif	
	
	sleep 0.1;
	
	// add specific sabotage ammunitions to units
	// private [ "_units", "_cnt", "_res" ];
	_units = units _paragrp;
	
	// replace some magazines with good bombs :o)
	_cnt = 0;
	_res = 0;
	_cnt = _units call SYG_rearmSabotageGroup;
	if ( _cnt > 0 ) then // start sabotage
	{
#ifdef	__DEBUG__
		hint localize format["x_createpara2.sqf: sabotage.sqf started with squad of %1 units", _cnt];
		//"x_createpara2.sqf: sabotage.sqf can't be started as no bomb were found" call XfGlobalChat;
#endif		
		[_paragrp] execVM "scripts\sabotage.sqf"; // run sabotage logic (separate from patrol one)
		//format["x_createpara2.sqf: Run sabotage.sqf with additional PipeBomb cnt = %1", _cnt] call XfGlobalChat;
	}
	else
	{
#ifdef	__DEBUG__
		hint localize "x_createpara2.sqf: sabotage.sqf isn't started as no bomb were found";
		//"x_createpara2.sqf: sabotage.sqf can't be started as no bomb were found" call XfGlobalChat;
#endif		
	};

	// check previous groups and add to common list
	if (!isNil "d_on_base_groups") then 
	{
		if ( count d_on_base_groups > 0 ) then
		{
			for "_i" from 0 to count d_on_base_groups - 1 do
			{
				_grp = d_on_base_groups select _i;
				if ( !isNull _grp ) then
				{
					_cnt = _grp call XfGetAliveUnits;
					switch _cnt do
					{
						case 0: 
						{ 
							d_on_base_groups set [_i, "RM_ME"]; 
						};
						case 1: 
						{ 
							// join whole group to this one
#ifdef	__DEBUG__
							hint localize format["x_createpara2.sqf: prev. group id %1 (of 1 man) joined to the new one", _i];
#endif		
							(units _grp) join _paragrp;
							d_on_base_groups set [_i, "RM_ME"];
						};
					};
				};
			};
			d_on_base_groups = (d_on_base_groups - ["RM_ME"]);
		};
		d_on_base_groups set [count d_on_base_groups, _paragrp]; // add a new group to common array
#ifdef	__DEBUG__
		hint localize format["x_createpara2.sqf: d_on_base_groups count %1", count d_on_base_groups];
#endif		
	}
	else
	{
#ifdef	__DEBUG__
		hint localize "--- x_createpara2.sqf: d_on_base_groups isNil ---";
#endif		
	};
};

if (isNull _chopper || !alive _chopper || !canMove _chopper || !alive driver _chopper) exitWith {
	[driver _chopper, _chopper] spawn {
		private ["_driver_veh","_vehicle"];
		_driver_veh = _this select 0;
		_vehicle = _this select 1;
		sleep 240 + random 100;
		if (!isNull _driver_veh) then {
			_driver_veh setDamage 1.1;
		};
		if (!isNull _vehicle) then {
			{_x removeAllEventHandlers "killed"; deleteVehicle _x} forEach ([_vehicle] + crew _vehicle);
		};
	};
};

while {(_heliendpoint distance (leader _vgrp) > 300)} do {
	if (isNull _chopper || !alive _chopper || !canMove _chopper || !alive driver _chopper) exitWith {
		[driver _chopper, _chopper] spawn {
			private ["_driver_veh","_vehicle"];
			_driver_veh = _this select 0;
			_vehicle = _this select 1;
			sleep 240 + random 100;
			if (!isNull _driver_veh) then {
				_driver_veh setDamage 1.1;
			};
			if (!isNull _vehicle) then {
				{_x removeAllEventHandlers "killed"; deleteVehicle _x} forEach ([_vehicle] + crew _vehicle);
			};
		};
	};
	sleep 5.123;
};

{if (!isNull _x) then {_x removeAllEventHandlers "killed";deleteVehicle _x}} forEach ([_chopper] + crew _chopper);

if (true) exitWith {};



