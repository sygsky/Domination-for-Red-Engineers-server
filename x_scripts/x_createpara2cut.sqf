// by Xeno, Sygsky, Snooper(Agent)
//
// x_createpara2cut.sqf : used version of desant to the base
//
// Creates paratroopers for base invasion, eject them and follow heli up to the final moment
//
// TODO: allow pilots to patrol with saboteurs if landed
//
//private ["_assigned","_helifirstpoint","_chopper","_paragrp","_leader","_pos_end","_u","_vgrp","_wp","_xx","_heliendpoint","_wp2","_attack_pos", "_i", "_grp_array","_parachute_type"];
private ["_assigned", "_helifirstpoint", "_chopper", "_paragrp", "_leader", "_u", "_vgrp", "_wp", "_xx", 
         "_heliendpoint", "_wp2", "_attack_pos", "_i", "_unti1", "_vehicle", "_type", "_para", "_units", 
		 "_cnt", "_res","_grp_array","_parachute_type", "_ejected", "_crewlist", "_testgun", "_next_to_eject", "_cur_uni", "_cnt_uni", "_main_polling_interval", "_unit_array"];

if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"
#include "global_vars.sqf"

//#define __USE_KRONSKY_SCRIPT__
#define __DEBUG_PRINT__

#define HEIGHT_TO_EJECT 80

_vgrp = _this select 0; // chopper crew group
_chopper = _this select 1;
_chopper lock true;
_helifirstpoint = _this select 2;
_heliendpoint = _this select 3;

sleep 2.123;

_wp = _vgrp addWaypoint [_helifirstpoint, 30];
_wp setWaypointBehaviour "CARELESS";
_wp setWaypointSpeed "NORMAL";
_wp setWaypointType "MOVE";
_wp setWaypointFormation "WEDGE";

_wp2 = _vgrp addWaypoint [_heliendpoint, 0];
_wp2 setWaypointType "MOVE";
_wp2 setWaypointBehaviour "CARELESS";
_wp2 setWaypointSpeed "NORMAL";
_wp2 setWaypointType "MOVE";

_chopper flyInHeight 100; // fly on height about 100 meters

// store time of the start of last infiltration on base
__SetGVar(INFILTRATION_TIME, date);
#ifdef __DEBUG_PRINT__
hint localize format["x_scripts/x_createpara2.sqf: Десант на базу запущен, местное время %1", date];
#endif

_parachute_type = (
	switch (d_enemy_side) do {
		case "EAST": {"ParachuteEast"};
		case "WEST": {"ParachuteWest"};
	}
);


if (alive _chopper && canMove _chopper && alive (driver _chopper) ) then // Create sabotage group and arrange it as chopper cargo
{
	_paragrp = call SYG_createEnemyGroup;
	_unit_array = ["sabotage", d_enemy_side] call x_getunitliste;
	_real_units = _unit_array select 0;
	_cnt_uni = (count _real_units) min (_chopper emptyPositions "Cargo"); // heli may be small one
#ifdef __DEBUG_PRINT__
    hint localize format["x_scripts/x_createpara2.sqf: %1 / desant is %2 men., limit is %3,chopper  empty pos %4", typeOf _chopper, _cnt_uni, count _real_units, _chopper emptyPositions "Cargo" ];
#endif
	_unit_array = [];
	sleep 0.1;
	for "_i" from 0 to (_cnt_uni - 1) do 
	{
		_type = _real_units select _i;
		_one_unit = _paragrp createUnit [_type, [0,0,0], [], 300,"NONE"];
		_one_unit moveInCargo _chopper;
		[_one_unit] join _paragrp;
		_unit_array = _unit_array + [_one_unit];
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
};

 //_testgun = "ACE_ZSU" createVehicle position player;
// player addScore 500;
//[_paragrp, _helifirstpoint, _heliendpoint, _vgrp, _chopper] execVM "x_scripts\x_player.sqf";

// Wait until heli is 150 meters near to droping point
_ejected = false;
_next_to_eject = 0;
_main_polling_interval = 2.123;

while { ([_helifirstpoint,leader _vgrp] call SYG_distance2D) > 250 || !canMove _chopper} do
{ 
	if (!alive _chopper) exitWith {_ejected = true; /*[player,"Chopper destroyed"] call XfSideChat;*/};
	_msg = "unknown";
	if (!canMove _chopper && !_ejected && alive driver _chopper && alive _chopper) then
	{
	    _msg = [_chopper, "%1 m. to %2 from %3"] call SYG_MsgOnPosE;
		//hint localize format["--- x_createpara2cut.sqf: Chopper in air, ejecting %1 unit[s], pos %2", {alive _x} count _unit_array, _msg ];
        while {alive _chopper && alive driver _chopper && (position _chopper select 2) >= HEIGHT_TO_EJECT && _next_to_eject < _cnt_uni} do
		{
			_cur_uni = _unit_array select _next_to_eject;
			if (alive _cur_uni ) then
			{
				_cur_uni action ["Eject",_chopper];
				//[player, format["Unit %1 ejected as HI altitude", _next_to_eject]] call XfSideChat;
				unassignVehicle _cur_uni;
			};
			_next_to_eject = _next_to_eject + 1;
			sleep 0.82;
		};
		_ejected = _next_to_eject >= _cnt_uni;
	    _msg = [_chopper, "%1 m. to %2 from %3"] call SYG_MsgOnPosE;
		//hint localize format["--- x_createpara2cut.sqf: Chopper in air, ejecting completed, pos %1", _msg ];
	};

	if (!canMove _chopper && !_ejected && alive driver _chopper && alive _chopper) then
	{
  	    _msg = [_chopper, "%1 m. to %2 from %3"] call SYG_MsgOnPosE;

        while {alive _chopper && alive driver _chopper && (position _chopper select 2) < HEIGHT_TO_EJECT && _next_to_eject < _cnt_uni} do
		{
			if (position _chopper select 2 < 2) exitWith
			{
        	    _msg = [_chopper, "%1 m. to %2 from %3"] call SYG_MsgOnPosE;
        		hint localize format["--- x_createpara2cut.sqf: Chopper on the ground, ejecting %1 unit[s], pos %2", {alive _x} count _unit_array, _msg ];
				while {_next_to_eject < _cnt_uni} do
				{
					_cur_uni = _unit_array select _next_to_eject;
					if ( alive _cur_uni ) then
					{
						_cur_uni action ["Eject",_chopper];
						//[player, format["Unit %1 ejected as chopper touched ground", _next_to_eject]] call XfSideChat;
						unassignVehicle _cur_uni;
					};
					_next_to_eject = _next_to_eject + 1;
					sleep 0.81;
				};
        		_ejected = _next_to_eject >= _cnt_uni;
        	    _msg = [_chopper, "%1 m. to %2 from %3"] call SYG_MsgOnPosE;
			};
		};
   		hint localize format["--- x_createpara2cut.sqf: Chopper on the ground, ejecting completed, pos %1",  _msg ];
	};
	
	if (!canMove _chopper) then {_main_polling_interval = 0.1;};
	if (_ejected) exitWith	{};
	sleep _main_polling_interval;
};

_unit_array = nil;
//[player,"Enclosing part finished"] call XfSideChat;

// try to animate ramp opening
#ifdef __ACE__
	// animate heli action
	if ( alive _chopper  && _chopper isKindOf "ACE_CH47D" ) then
	{
		_chopper animate ["ramp", 1]; // open ramp
		// hint localize "x_createpara2.sqf: _chopper animate [""ramp"", 1] executed";
	};
	sleep 1.123;
#endif

if (!_ejected && alive _chopper) then 
{
	//[player,"Scheduled drop started"] call XfSideChat;
    _msg = [_chopper, "%1 m. to %2 from %3", 50] call SYG_MsgOnPosE;
    hint localize format["+++ x_createpara2cut.sqf: Ordinal saboteurs ejection started, %1 unit[s], h %2, %3", {alive _x} count (units _paragrp), round((getPos _chopper) select 2), _msg ];
	{
		_x action ["Eject",_chopper];
		unassignVehicle _x;
		sleep (0.85 + (random 0.25));
	} forEach units _paragrp;
	_ejected = true;
    //_msg = [_chopper, "%1 m. to %2 from %3"] call SYG_MsgOnPosE;
    // hint localize format["--- x_createpara2cut.sqf: Emergency saboteurs ejection completed, pos %1", _msg ];
	//[player,"Scheduled drop finished"] call XfSideChat;
};

if (_ejected) then // create sabotage group
{
//[player,"Saboteurs team onground setup block entered"] call XfSideChat;
_chopper flyInHeight 200;

	_leader = leader _paragrp;
	_leader setRank "LIEUTENANT";
	_paragrp allowFleeing 0;
	_paragrp setCombatMode "YELLOW";
	_paragrp setBehaviour "AWARE";
	_paragrp setFormation "VEE";
	sleep 0.113;
	/*
    d_base_patrol_array =
    [
        [[9502,9871.2,0],290,150,0],       // court of airbase, main area
        [[9956,9771,0],175,250,0],         // middle south of airfield + hangars + forest to Paraiso
        [[10304,9954,0],240,250,-25],      // airbase part near Paraiso (hill and air-field buildings on east)
        [[9780.1,10332.6,0],650,170,0],    // north of airfield (forest-bush
        [[9149.29,10079,0],125,200,0],     // west of airfield (pit on west of air-field)
        [[9582,9377,0],100,300,100],       // far to south from base (granary area)
        [[10518,10061,0],150,350,0]        // east from base between butt end of airfield and the big hill
    ];
	*/
	
#ifdef __USE_KRONSKY_SCRIPT__	
	//"__USE_KRONSKY_SCRIPT__ in x_createpara2.sqf detected" call XfGlobalChat;
	_xx = d_base_patrol_markers call XfRandomArrayVal;

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
	_i = d_base_patrol_array call XfRandomFloorArray; // random index
	_xx = d_base_patrol_array select _i; // value of this index
 	hint localize format["%1 x_createpara2.sqf: paratroopers patrol area ind #%5 %2 selected for group %3(%4)", call SYG_missionTimeInfoStr, _xx, _paragrp, count units _paragrp, _i];

	_grp_array = [_paragrp, [position _leader select 0, position _leader select 1, 0], 0,_xx,[],-1,1,[],300 + (random 50),1,[2]]; // try rejoin if number of units <= 2
//	_grp_array = [_paragrp, [position _leader select 0, position _leader select 1, 0], 0,[_current_target_pos,200],[],-1,0,[],300 + (random 50),0];	
	_grp_array execVM "x_scripts\x_groupsm.sqf";
#endif	
	
	sleep 0.1;
	
	// add specific sabotage ammunitions to units
	// private [ "_units", "_cnt", "_res" ];
	_units = units _paragrp;
	
	// replace some magazines with good bombs :o)
	_cnt = 0;
	_res = 0;
	// TODO: if GRU is on, add secret report to the officer
	_officer = [ d_sleader_W, _paragrp ] call SYG_ensureOfficerInGroup;
	_cnt = (units  _paragrp) call SYG_rearmSabotageGroup;
#ifdef	__DEBUG_PRINT__
	hint localize format["x_createpara2.sqf: sabotage.sqf started with squad of %1 units = %2 alive, %3 canStand", count (units  _paragrp), {alive _x} count (units  _paragrp),{canStand _x} count (units  _paragrp)];
#endif
	[_paragrp] execVM "scripts\sabotage.sqf"; // run sabotage logic (separate from patrol one)

	// check previous groups and add to common list
	if (!isNil "d_on_base_groups") then 
	{
		if ( count d_on_base_groups > 0 ) then
		{
			for "_i" from 0 to count d_on_base_groups - 1 do
			{
				_grp = d_on_base_groups select _i;
                _cnt = _grp call XfGetAliveUnits;
                if ( _cnt <= 2) then
                {
                    if ( _cnt > 0) then // join last member to this group
                    {
#ifdef	__DEBUG_PRINT__
                        hint localize format["x_createpara2.sqf: prev. group id %1 (of %2 alive saboteur[s]) joined to this one", _i, _cnt];
#endif

                        (units _grp) join _paragrp;
                        sleep 1.04;
                    };
                    d_on_base_groups set [_i, "RM_ME"]; // remove group in any case
                    deleteGroup _grp;
                    sleep 0.021;
                };
			};
			d_on_base_groups = (d_on_base_groups - ["RM_ME"]);
		};
		d_on_base_groups set [ count d_on_base_groups, _paragrp]; // add a new group to common array
		publicVariable "d_on_base_groups";

#ifdef	__DEBUG_PRINT__
        _list = [];
        {
            _list = _list + [{alive _x} count units _x];
        } forEach d_on_base_groups;
		hint localize format["x_createpara2.sqf: d_on_base_groups counts %1", _list];
		_list = nil;
#endif		
	}
	else
	{
#ifdef	__DEBUG_PRINT__
		hint localize "--- x_createpara2.sqf: d_on_base_groups isNil ---";
#endif		
	};
};

// heal all the men in current para group
_paragrp spawn {
    sleep 15; // wait for all to be on the earth
    // heal whole group for fun and just in case
    {
        if ( alive _x) then {sleep random 3; _x setDamage 0};
    } forEach (units _paragrp);
};
if ( !alive _chopper || !canMove _chopper || !alive driver _chopper) exitWith {
	[driver _chopper, _chopper] spawn {
		private ["_driver_veh","_vehicle"];
		_driver_veh = _this select 0;
		_vehicle = _this select 1;
		sleep (240 + (random 100));
		if (!isNull _driver_veh) then {
			_driver_veh setDamage 1.1;
		};
		if (!isNull _vehicle) then {
			{_x removeAllEventHandlers "killed"; deleteVehicle _x} forEach ([_vehicle] + crew _vehicle);
		};
	};
};

// REVEAL known to flying chopper enemies to the landed saboteurs
_nenemy = (driver _chopper) call SYG_nearestEnemy;
if ( !isNull _nenemy) then
{
    _grp reveal _nenemy;
#ifdef __DEBUG_PRINT__
    hint localize format["x_scripts/x_createpara2.sqf: %1 (knowledge %2) revealed to paratroopers at dist. %2 m", typeOf _nenemy, (driver _chopper) knowsAbout _nenemy, round(_chopper distance _nenemy)];
#endif
};

while {(_heliendpoint distance (leader _vgrp) > 300)} do {
	if (!alive _chopper || !canMove _chopper || !alive driver _chopper) exitWith {
		[driver _chopper, _chopper] spawn {
			private ["_driver_veh","_vehicle"];
			_driver_veh = _this select 0;
			_vehicle = _this select 1;
			sleep (240 + (random 100));
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



