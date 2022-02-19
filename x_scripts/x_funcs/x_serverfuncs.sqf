// by Xeno
#include "x_setup.sqf"
#include "x_macros.sqf"

// add dead object(vehicle, unit) to the common dead list
XAddDead = {if (!((_this select 0) in dead_list)) then { dead_list set[ count dead_list,_this select 0] } };

// Adds vehicle to the check dead vehicles list
XAddCheckDead = {if (!((_this select 0) in check_vec_list)) then { check_vec_list set [count check_vec_list, _this select 0] } };

#ifdef __TT__

XAddKills = { private ["_points","_killer"];_points = _this select 0; _killer = _this select 1;switch (side _killer) do {case west: {kill_points_west = kill_points_west + _points;};case resistance: {kill_points_racs = kill_points_racs + _points; }; }; };
XAddPoints = { private ["_points","_killer"];_points = _this select 0;_killer = _this select 1;switch (side _killer) do {case west: {points_west = points_west + _points;};case resistance: {points_racs = points_racs + _points; }; }; };

#else

//#define __DEBUG__ 20 // to debug town splitted score each 20 ccore changed

/*
	Add score for observer kill on "killed" event
	4.13 Killed
	Triggered when the unit is killed.
	Local.
	Passed array: [unit, killer]
	unit: Object - Object the event handler is assigned to
	killer: Object - Object that killed the unit
	Contains the unit itself in case of collisions.
*/
SAddObserverKillScores = {
    private ["_killer","_observer"];
    _observer = _this select 0;
    _killer =  _this select 1;
    if ( isPlayer _killer ) then {
        hint localize format["+++ SAddObserverKillScores: observer (%1) killed by %2%3 (pos %4)",
            primaryWeapon _observer,
            name _killer,
            if( vehicle _killer != _killer) then { format["(%1)", typeOf (vehicle _killer)] } else {""},
            [_killer, "%1 m to %2 from %3", 10] call SYG_MsgOnPosE
        ];
    } else {
        if (isNull _killer) then {
            hint localize format["+++ SAddObserverKillScores: observer (%1) killed with unclear circumstances (killer is null) at %2",
                primaryWeapon _observer,
                [_observer, "%1 m to %2 from %3", 10] call SYG_MsgOnPosE
            ];
        } else {
            hint localize format["+++ SAddObserverKillScores: observer (%1) killed by %2%3 (pos %4)",
                primaryWeapon _observer,
                typeOf _killer,
                if( vehicle _killer != _killer) then { format["(%1)", typeOf (vehicle _killer)] } else {
                	if ( _observer == _killer) then {"(himself)"} else {""}
                },
                [_killer, "%1 m to %2 from %3", 10] call SYG_MsgOnPosE
            ];
        };
    };
    [ "syg_observer_kill", _killer, primaryWeapon _observer, _observer] call XSendNetStartScriptClient;
};
#endif

#ifdef __AI__
if (__RankedVer) then {
	// adds # points on enemy vehicle kill
	XAddKillsAI = {
		private ["_points","_killer"];
		_killer = _this select 1;
		if (isNull _killer) exitWith {};
		_points = _this select 0;
		_killer = vehicle _killer;
		if (!isPlayer _killer && side _killer != d_side_enemy) then {["d_ai_kill",_killer,_points] call XSendNetStartScriptClient;}
	};
};
#endif

x_creategroup = {
	can_create_group = false;
	private ["_found_empty","_grp","_i","_side","_side_str","_this","_tmp_grp","_tmp_grp_a","_tmp_time","_x"];
	if ( (typeName _this) != "ARRAY") then {_this = [_this];};
	_side = _this select 0;_grp = grpNull;
	_side_str = (switch (toUpper(_side)) do {case "EAST": {"east"};case "WEST": {"west"};case "RACS": {"resistance"};case "CIV": {"civilian"};});
	call compile format ["if (count groups_%1 > 0) then {for ""_i"" from 0 to (count groups_%1 - 1) do {if (_i > (count groups_%1 - 1)) exitWith {};_tmp_grp_a = groups_%1 select _i;if (typeName _tmp_grp_a == ""ARRAY"") then {_tmp_time = _tmp_grp_a select 1;if (time >= _tmp_time) then {_tmp_grp = _tmp_grp_a select 0;if (isNull _tmp_grp) then {groups_%1 set [_i, ""RM_ME""];} else {if (count (units _tmp_grp) == 0) then {deleteGroup _tmp_grp;groups_%1 set [_i, ""RM_ME""];};};};};sleep 0.012;};groups_%1 = groups_%1 - [""RM_ME""];};_grp = createGroup %1;groups_%1 set[count groups_%1,[_grp, time + 120]];",_side_str];
	can_create_group = true;
	_grp

};

/**
 * TODO: use this routine as main one soon
 * Group is stored in array as 2 item array: [_group, _time_to_check]
 * Not sure but it seems the initial time (120 seconds) is used here
 * to prevent newly created group from check during first 120 seconds after generation
 * What is the sense of such solution, don't know.
 */
x_createGroupA = {
	can_create_group = false;
	private ["_found_empty","_grp","_i","_side","_side_arr","_tmp_grp_a","_tmp_grp","_tmp_time","_x"];
	_side = if ( (typeName _this) == "ARRAY") then { _this select 0 } else {_this};
	if (_side == "STRING") then {
		_side = (switch (toUpper(str(_side))) do {case "EAST": {east};case "WEST": {west};case "RACS": {resistance};case "CIV": {civilian};});
	};
	if (typeName _side != "SIDE") exitWith{ hint localize format["--- x_createGroup error: Expected side unknown, typeName  ""%1"", value %2", typeName _side, _side]};
	_grp = grpNull;
	_side_arr = switch (toUpper(str(_side))) do {case east: {groups_east};case west: {groups_west};case resistance: {groups_resistance};case civilian: {groups_civilian};};
	_found_empty = false;
	// 1. Clear all groups array from empty items
	if ( count _side_arr > 0 ) then {
		for "_i" from 0 to (count _side_arr - 1) do {
			if (_i > (count _side_arr - 1)) exitWith {};
			_tmp_grp_a = _side_arr select _i;
			if ( typeName _tmp_grp_a == "ARRAY" ) then {
				_tmp_time = _tmp_grp_a select 1;
				if (time >= _tmp_time) then {
				    // time is out to check this group to be null, empty oк with dead men only
					_tmp_grp = _tmp_grp_a select 0;
					if (isNull _tmp_grp) then {
						_side_arr set [_i, "RM_ME"];
						_found_empty = true;
					} else {
						if (count (units _tmp_grp) == 0) then { // empty group, remove it now
							deleteGroup _tmp_grp;
							_side_arr set [_i, "RM_ME"];
							_found_empty = true;
						} else { // not empty group, check it to be alive
						    {
                                if ( alive _x ) exitWith {
                                    // alive men found, set new timeout for the next 2 minutes
                                   _tmp_grp_a set [1, time + 120];
                                };
						    } forEach units _tmp_grp;
                        };
                    };
                };
			} ;
			sleep 0.012;
		};
		if ( _found_empty ) then {
			// Remove groups marked as delected. Note then items in the array may change their positons after it,
			// but is is not important here
			_side_arr call SYG_clearArray;
		};
	};
	// 2. Create and add new group to the array
	_grp = createGroup _side;
	_side_arr set[count _side_arr,[_grp, time + 120]];
	can_create_group = true;
	_grp
};

/**
 * Counts alive groups in designated array (for side east, west etc)
 * Call as: _enemy_grp_cnt =  _enemy_side call SYG_sideGroupsCount;
 */
SYG_sideGroupsCount = {
    private ["_side_arr", "_x", "_cnt","_grp_id","_side"];
    _side = _this;
    if (typeName _side == "STRING") then {
		_side = switch (toUpper(str(_side))) do {case "EAST": {east};case "WEST": {west};case "RACS": {resistance};case "CIV": {civilian};};
    };
    if (typeName _side != "SIDE") exitWith {hint localize format["--- Illegal arg to call SYG_sideGroupsCount: typeName = %1, _this = %2", typeName _side, _side]};
	_side_arr = switch (_side) do {case east: {groups_east};case west: {groups_west};case resistance: {groups_resistance};case civilian: {groups_civilian};};
	_cnt = 0;
	_grp_id = 0;
	{
		if (typeName _x == "ARRAY") then  {
			{
				if ( alive _x ) exitWith { _cnt = _cnt + 1 };
			} forEach units (_x select 0);
		} else {
			hint localize format["--- SYG_sideGroupsCount: group_%1[%2] = %3, skipped", toLower(str(_side)), _grp_id, _x ];
		};
		_grp_id = _grp_id + 1;
	} forEach _side_arr;
	_cnt
};

/**
 * Counts all groups for all sides in the mission
 */
SYG_allGroupsCount = {
    private [ "_x", "_cnt"];
    _cnt = 0;
    {
        _cnt = _cnt + (_x call SYG_sideGroupsCount);
    } forEach [east, west, resistance, civilian];
	_cnt
};


// Gets array of 100(or desinated N) base point in circle of designated radious
// call: _wp_arr = [_pnt, _radius <, _pnt_num>] call x_getwparray
x_getwparray = {
	private["_tc", "_radius","_wp_a","_point","_pnt_num"];
	_tc = _this select 0;
	_radius = _this select 1;
	_wp_a = [];
	if ( (count _this) > 2) then { _pnt_num = _this select 2 } else {_pnt_num = 100};
	_pnt_num = _pnt_num max 1; // not less than 1 point created
	for "_i" from 1 to _pnt_num do {
		_point = [_tc, _radius] call XfGetRanPointCircle;
		while {count _point == 0} do {
			_point = [_pos_center, _radius] call XfGetRanPointCircle;
			sleep 0.04;
		};
		_wp_a set [ count _wp_a, _point];
		sleep 0.032
	};
	_wp_a
};

// Gets array of 100 base point at the border of n the circle of designated radious
// call: _wp_arr = [_pnt, _border_radius] call x_getwparray2
x_getwparray2 = {
	private["_tc", "_radius","_wp_a","_point"];
	_tc = _this select 0;_radius = _this select 1;_wp_a = [];
	for "_i" from 1 to 100 do {
		_point = [_tc, _radius] call XfGetRanPointCircleOuter;
		while {count _point == 0} do {
			_point = [_tc, _radius] call XfGetRanPointCircleOuter;
			sleep 0.04;
		};
		_wp_a = _wp_a + [_point];
		sleep 0.032
	};
	_wp_a
};

// Gets array of 100 base point in rectangle of designated size
// call: _wp_arr = [_pos, _a, _b, _angle] call x_getwparray3
x_getwparray3 = {
	private ["_pos","_a","_b","_angle","_wp_a","_point"];
	_pos = _this select 0;_a = _this select 1;_b = _this select 2;_angle = _this select 3;_wp_a = [];
	for "_i" from 1 to 100 do {
		_point = [_pos, _a, _b, _angle] call XfGetRanPointSquare;
		while {count _point == 0} do {
			_point = [_pos, _a, _b, _angle] call XfGetRanPointSquare;
			sleep 0.04;
		};
		_wp_a = _wp_a + [_point];
		sleep 0.032
	};
	_wp_a
};

/**
 * Creates list of unit types to createAgent
 * Call: _vec_list = [_grp_type, _side<,_crew_count>] call x_getunitliste;
 * Where:
 *  _grp_type - mnemonic name for group kind, e.g. "basic" (ordinal infantry), "specops" (special operation forces) etc
 *  _side  - side string of future group, e.g. "WEST", "EAST" etc
 *  _crew_count - optional size of a new group (in the future)
 * Returns: array with [_unit_list, _vec_type, _crewtype];
 */
x_getunitliste = {
	private ["_crewmember","_grptype","_how_many","_list","_one_man","_random","_side","_side_char","_unitliste","_vehiclename","_varray"];
	_grptype = _this select 0;_side = _this select 1;_unitliste = [];_vehiclename = "";_varray = [];
	_side_char = (switch (_side) do {case "EAST": {"E"};case "WEST": {"W"};case "RACS": {"G"};case "CIV": {"W"};});
	_crewmember = call compile format["d_crewman_%1",_side_char];

	switch (_grptype) do {
		case "basic": {_list = call compile format ["d_allmen_%1",_side_char];_unitliste = _list call XfRandomArrayVal;};
		case "specops": {_how_many = 2 + ceil random 3; _list = call compile format ["d_specops_%1",_side_char];for "_i" from 1 to _how_many do { _unitliste set [count _unitliste, _list call XfRandomArrayVal];};};
		// +++ Sygsky: big specops group (7-12 men)
		case "specopsbig": {_how_many = 6 + ceil random 6; _list = call compile format ["d_specops_%1",_side_char];for "_i" from 1 to _how_many do { _unitliste set [count _unitliste, _list call XfRandomArrayVal];};};
		case "artiobserver": {_unitliste = [call compile format["d_arti_observer_%1",_side_char]];};
		case "heli": {_list = call compile format ["d_allmen_%1",_side_char];_unitliste = _list call XfRandomArrayVal;};
		case "tank": {call compile format ["_varray = (d_veh_a_%1 select 0);",_side_char];_vehiclename = _varray call XfRandomArrayVal;};
		case "tank_desert": {call compile format ["_varray = d_veh_a_%1_desert;",_side_char];_vehiclename = _varray call XfRandomArrayVal;};
		case "bmp": {call compile format ["_varray = (d_veh_a_%1 select 1);",_side_char];_vehiclename = _varray call XfRandomArrayVal;};
		case "brdm": {call compile format ["_crewmember=d_crewman2_%1;_varray = (d_veh_a_%1 select 2);",_side_char];_vehiclename = _varray call XfRandomArrayVal;};
		case "shilka": {call compile format ["_varray = (d_veh_a_%1 select 3);",_side_char];_vehiclename = _varray call XfRandomArrayVal;};
		case "uaz_mg": {call compile format ["_crewmember=d_crewman2_%1;_varray = (d_veh_a_%1 select 4);",_side_char];_vehiclename = _varray call XfRandomArrayVal;};
		case "uaz_grenade": {call compile format ["_crewmember=d_crewman2_%1;_varray = (d_veh_a_%1 select 5);",_side_char];_vehiclename = _varray call XfRandomArrayVal;};
		case "DSHKM": {call compile format ["_crewmember=d_crewman2_%1;_varray = (d_veh_a_%1 select 6);",_side_char];_vehiclename = _varray call XfRandomArrayVal;};
		case "AGS": {call compile format ["_crewmember=d_crewman2_%1;_varray = (d_veh_a_%1 select 7);",_side_char];_vehiclename = _varray call XfRandomArrayVal;};
		case "D30": {call compile format ["_crewmember=d_crewman2_%1;_varray = (d_veh_a_%1 select 8);",_side_char];_vehiclename = _varray call XfRandomArrayVal;};
		case "uralfuel": {call compile format ["_crewmember=d_crewman2_%1;_varray = (d_veh_a_%1 select 9);",_side_char];_vehiclename = _varray call XfRandomArrayVal;};
		case "uralrep": {call compile format ["_crewmember=d_crewman2_%1;_varray = (d_veh_a_%1 select 10);",_side_char];_vehiclename = _varray call XfRandomArrayVal;};
		case "uralammo": {call compile format ["_crewmember=d_crewman2_%1;_varray = (d_veh_a_%1 select 11);",_side_char];_vehiclename = _varray call XfRandomArrayVal;};
		case "civilian": {for "_i" from 1 to 10 do {_random = floor random 19;_one_man = format ["Civilian%1", _random + 2];_unitliste set [count _unitliste,_one_man];};};
		case "sabotage": {_how_many = 6 + (ceil random 6); _list = call compile format ["d_sabotage_%1",_side_char];for "_i" from 1 to _how_many do {_unitliste set [count _unitliste , _list call XfRandomArrayVal];};};
		case "civbus": {_vehiclename = "Bus_city";_how_many = ceil random 8;for "_i" from 1 to _how_many do {_random = floor random 19;_one_man = format ["Civilian%1", _random + 2];_unitliste set [count _unitliste,_one_man];};};
		case "civcar": {_vehiclename = d_civ_cars select (floor (random (count d_civ_cars)));_how_many = ceil random 4;for "_i" from 1 to _how_many do {_random = floor random 19;_one_man = format ["Civilian%1", _random + 2];_unitliste set[count _unitliste, _one_man];};};
		case "civcity": {_how_many = ceil random 5;for "_i" from 1 to _how_many do {_random = floor random 19;_one_man = format ["Civilian%1", _random + 2];_unitliste set [count _unitliste,_one_man];};};
		// +++ Sygsky: air base enemy team
		case "airteam1": {_how_many = 6 + ceil random 6; _list = call compile format ["airbaseteam_%1",_side_char];for "_i" from 1 to _how_many do {_unitliste set [count _unitliste, _list call XfRandomArrayVal];};};
		case "airteam2": {_how_many = 1 + ceil random 3; _list = call compile format ["airbaseteam_pilots_%1",_side_char];for "_i" from 1 to _how_many do { _unitliste set [count _unitliste, _list call XfRandomArrayVal];};};
	};
/*
    if ( _grptype in ["basic","heli"]) then{
        hint localize format["+++ x_getunitliste %1 returns %2",_this, [_unitliste, _vehiclename, _crewmember]];
    };
*/
	[_unitliste, _vehiclename, _crewmember]
};

// Makes mixed vehicles group (e.g. for patrol)
x_getmixedliste = {
	private ["_side", "_ret_list", "_list","_x"];
	_side = _this select 0;
	_ret_list = [];
	
	{
		_list = [_x,_side] call x_getunitliste;
		_ret_list = _ret_list + [[_list select 1, _list select 2]];
		sleep 0.01;
	} forEach [switch (floor random 2) do {case 0: {"brdm"};case 1: {"uaz_mg"};}, "bmp", "tank", "shilka"];
	_ret_list
};

//
// Add all needed events to a newly created standard vehicle (for main/side mission action)
//
// call as: [_vehiсle<<, _do_points<,_smoke<,_wreck>>>] call SYG_addEvents;
SYG_addEvents = {
    private ["_vehicle"];
    _vehicle   = arg(0);

    if (_vehicle isKindOf "Tank") then { if (!d_found_gdtmodtracked) then {[_vehicle] spawn XGDTTracked}; };

    _vehicle call SYG_assignVecToSmokeOnHit;

    // add wreckage restore option
    if ( !( (typeOf _vehicle) in x_heli_wreck_lift_types) ) then {
		_vehicle addEventHandler ["killed", {_this spawn x_removevehi}]; // for good blasting on killed
		[_vehicle] call XAddCheckDead; // insert to dead vehicles list for follow handling and removing
    };

#ifdef __TT__
    if ( count _this > 1 ) then {
    	if ( _this select 1 ) then { _vehicle addEventHandler [ "killed", {[5, _this select 1] call XAddKills} ] };
    };
#endif
#ifndef __TT__
	#ifdef __AI__
    if (__RankedVer) then {
    	if (count _this > 1 ) then { // add/subtract points if vehicle is killed by someboby AI
	    	_vehicle addEventHandler ["killed", compile format[ "[%1, _this select 1] call XAddKillsAI;", _this select 1] ];
    	};
    };
	#endif
#endif

};

//
// Append remove code to a newly created standard vehicle (for main/side mission action) in ANY case, independently it is restorable or not
//
// call as: [_vehiсle<<, _do_points<,_smoke<,_wreck>>>] call SYG_addEventsAndDispose;
SYG_addEventsAndDispose = {
	if ( typeName _this == "OBJECT" ) then { _this = [ _this ]; };
    _this call SYG_addEvents;
    _vehicle = arg(0);
    // add dispose event
    if ( (typeOf _vehicle) in x_heli_wreck_lift_types ) then { // add dispose option even for wreckable vehicles too
        hint localize format["+++SYG_addEventsAndDispose: %1", typeOf _vehicle];
        _vehicle addEventHandler ["killed", {_this spawn x_removevehi}]; // for good blasting on killed
        [_vehicle] call XAddCheckDead; // prepare to insert to dead vehicles list for follow handling and removing
    };
};

// remove all standard vehicle event: hit, killed, dammaged, getin and getout
SYG_removeAllVehicleStdEvents = {
	if (typeName _this != "OBJECT") exitWith {};
	if (_this call SYG_removeVehicleHitDamKilEvents) then {
		if ( _this isKindOf "LandVehicle" || _this isKindOf "Air" || _this isKindOf "Ship") then  {
			_this removeAllEventHandlers "getin";
			_this removeAllEventHandlers "getout";
		#ifdef __AI__
			#ifdef __NO_AI_IN_PLANE__
			// check for any pilot or driver to be AI and get them out if yes
			if ( (_veh isKindOf "Plane") ) then { _veh addEventHandler ["getin", {_this execVM  "scripts\SYG_eventPlaneGetIn.sqf"}]; };
			#endif
		#endif
		};
	};
};

// remove all standard vehicle event: hit, killed, dammaged, getin and getout
SYG_removeVehicleHitDamKilEvents = {
	if (typeName _this != "OBJECT") exitWith {false};
	_this removeAllEventHandlers "hit";
	_this removeAllEventHandlers "dammaged";
	_this removeAllEventHandlers "killed";
	true
};

// Makes vehicle group on enemy side for sidemission (e.g. convoy) and main targets too
x_makevgroup = {
	private ["_numbervehicles", "_pos", "_crewmember", "_vehiclename", "_grp", "_radius", "_direction", "_do_points",
	"_the_vehicles", "_d_crewman", "_d_crewman2", "_no_crew", "_side_char", "_grpskill", "_n", "_vehicle", "_dir",
	"_cmdr", "_drvr", "_gnnr", "_unit","_x"];
	_numbervehicles = _this select 0;
	_pos = _this select 1;
	_crewmember = _this select 2;
	_vehiclename = _this select 3; // vehicle type name: (typeOf _vehicle)
	_grp = _this select 4;
	_radius = _this select 5;
	_direction = _this select 6;
	_do_points = (if (count _this > 7) then {true} else {false});
	_the_vehicles = [];
	
	_d_crewman = "";_d_crewman2 = "";
	_no_crew = (if (_crewmember == "") then {true} else {false});
	if (_no_crew) then {
		_side_char = (switch (d_enemy_side) do {case "EAST": {"E"};case "WEST": {"W"};case "RACS": {"G"};});
		call compile format ["_d_crewman = d_crewman_%1;_d_crewman2 = d_crewman2_%1;", _side_char];
	};
	
	#ifndef __ACE__
	_grpskill = (if (_vehiclename in ["M2StaticMG","AGS","M119","D30","DSHKM","DSHkM_Mini_TriPod","Stinger_Pod_East","TOW_TriPod_East","M2HD_mini_TriPod","MK19_TriPod","Stinger_Pod","TOW_TriPod"]) then {1.0} else {(d_skill_array select 0) + (random (d_skill_array select 1))});
	#else
	_grpskill = (d_skill_array select 0) + (random (d_skill_array select 1));
	#endif
	
	for "_n" from 1 to _numbervehicles do {
		sleep 0.331;
		_vehicle = createVehicle [_vehiclename, _pos, [], _radius, "NONE"];
		if (_no_crew) then {_crewmember = (if (_vehicle isKindOf "Tank") then {_d_crewman} else {_d_crewman2});};
		_dir = if (_direction != -1.111) then {_direction} else {random 360};
		_vehicle setDir _dir;
		_the_vehicles set [ count _the_vehicles, _vehicle ];
		sleep 0.543;
		
		[_vehicle, _grp, _crewmember, _grpskill] call SYG_populateVehicle;
		{
			__addDead(_x);
			#ifdef __TT__
			if (_do_points) then {_x addEventHandler ["killed", {[1,_this select 1] call XAddKills}]};
			#endif
			#ifdef __AI__
			if (__RankedVer) then {
				_x addEventHandler ["killed", {[1,_this select 1] call XAddKillsAI}];
			};
			#endif
			_x setUnitAbility ((d_skill_array select 0) + (random (d_skill_array select 1)));
			sleep 0.331;
		} forEach crew _vehicle;

//#ifndef __NEW__
        if (d_smoke) then { _vehicle call SYG_assignVecToSmokeOnHit; };
        if (!(_vehiclename in x_heli_wreck_lift_types)) then {//  this is not resurrectable vehicle, so remove it from the game if dead
            _vehicle addEventHandler ["killed", { _this spawn x_removevehi;} ];
            [_vehicle] call XAddCheckDead;
        };
		if ( _vehicle isKindOf "Tank" ) then {
			if (!d_found_gdtmodtracked) then {[_vehicle] spawn XGDTTracked; };
    #ifdef __TT__
            if (_do_points) then {_vehicle addEventHandler ["killed", {[5,_this select 1] call XAddKills;}]};
    #endif
    #ifdef __AI__
            if (__RankedVer) then {
                _vehicle addEventHandler ["killed", {[5,_this select 1] call XAddKillsAI;}];
            };
    #endif
        //  if (_vehicle isKindOf "Tank") then { ...
		} else {
	#ifdef __TT__
			if (_do_points) then {_vehicle addEventHandler ["killed", {[3,_this select 1] call XAddKills;}]};
	#endif
	#ifdef __AI__
			if (__RankedVer) then {
				_vehicle addEventHandler ["killed", {[3,_this select 1] call XAddKillsAI;}];
			};
	#endif
		};
//#else
//        [_vehicle, _do_points] call SYG_addEvents;
//#endif
		
		if (_vehicle isKindOf "Tank") then {
			if (d_lock_ai_armor) then {_vehicle lock true}
		} else {	
			if (_vehicle isKindOf "Car") then {
				if (d_lock_ai_car) then {_vehicle lock true}
			} else {
				if (_vehicle isKindOf "Air") then {
					if (d_lock_ai_air) then {_vehicle lock true}
				}
			}
		};
		
		#ifdef __MANDO__
		if ((typeOf _vehicle) in d_enemy_aa_vehicle) then {
			if ((random 100) < 33) then {
				[_vehicle] spawn {
					sleep (1 + (random 3));
					[(_this select 0), 1, ["Air"], 24, 500, 2000, 12, [0,0,0,3], 360, 0, [WEST, sideEnemy], true, false, true, true, 45]exec"mando_missiles\units\attackers\mando_patriot.sqs";
				};
			};
		};
		#endif
	}; // for "_n" from 1 to _numbervehicles do {
	_the_vehicles
};

// Makes infantry enemy group
// Params:
// position, unitlist, group, do_points (for TT mode)
x_makemgroup = {
	private ["_grp","_pos","_ret","_unitliste","_do_points","_x"];
	_pos = _this select 0;
	_unitliste = _this select 1;
	_grp = _this select 2;
	_ret = [];
	{
        _one_unit = _grp createUnit [_x, _pos, [], 10,"NONE"];
        [_one_unit] join _grp;
        _one_unit addEventHandler ["killed", {[_this select 0] call XAddDead;
        if (d_smoke) then {[_this select 0, _this select 1] spawn x_dosmoke}}];
#ifdef __TT__
    	_do_points = (if (count _this > 3) then {true} else {false});
        if (_do_points) then {_one_unit addEventHandler ["killed", {[1,_this select 1] call XAddKills;}];};
#endif
#ifdef __AI__
        if (__RankedVer) then {
            _one_unit addEventHandler ["killed", {[1,_this select 1] call XAddKillsAI}];
        };
#endif
        _one_unit setUnitAbility ((d_skill_array select 0) + (random (d_skill_array select 1)));
        _ret = _ret + [_one_unit];
        sleep 0.012
	} forEach _unitliste;
	_ret
};

//
// Creates group of infantry for side mission. All bodies will be automatically removed after SM if finished
// call as: ["specopsbig", 1, "basic", 2, _pos, 90, true] spawn {XCreateInf;
//
XCreateInf = {
	private ["_type1", "_numbergroups1", "_type2", "_numbergroups2", "_pos_center", "_radius", "_do_patrol", "_side",
	         "_gwp_formations", "_ret_grps", "_pos", "_nr", "_numbergroups", "_i", "_newgroup", "_unit_array", "_type",
	         "_units", "_leader", "_grp_array","_arr","_grpArr","_x"];
	_type1 = _this select 0;
	_numbergroups1 = _this select 1;
	_type2 = _this select 2;
	_numbergroups2 = _this select 3;
	_pos_center = _this select 4;
	_radius = _this select 5;
	_do_patrol = (if (count _this > 6) then {_this select 6} else {false});
	if (_radius < 50) then {_do_patrol = false;};
	_side = d_enemy_side;
	
	//_gwp_formations = ["COLUMN","STAG COLUMN","WEDGE","ECH LEFT","ECH RIGHT","VEE","LINE","DIAMOND"];
	_ret_grps = [];
	_pos = [];

    // main array of vehicle types and numbers of
    _arr = [ [ _numbergroups1, _type1 ], [ _numbergroups2, _type2 ]];
	{
        _grpArr = _x; // group description array
        // (_grpArr select 0) is number of vehicles in group
        // (_grpArr select 1) is type of units in group (basic, specops etc)
        if ((_grpArr select 0) > 0) then {
            for "_i" from 1 to (_grpArr select 0) do {
                while {!can_create_group} do {sleep (0.1 + (random 0.2))};
                _newgroup = [_side] call x_creategroup;
                _unit_array = [(_grpArr select 1), _side] call x_getunitliste;
                if (_radius > 0) then {
                    _pos = [_pos_center, _radius] call XfGetRanPointCircle;
                    while {count _pos == 0} do {
                        _pos = [_pos_center, _radius] call XfGetRanPointCircle;
                        sleep 0.04;
                    };
                } else {
                    _pos = _pos_center;
                };
                _units = [_pos, (_unit_array select 0), _newgroup] call x_makemgroup;
                sleep 2.045;
                _leader = leader _newgroup;
                _leader setRank "LIEUTENANT";
                _newgroup allowFleeing 0;
                if (!_do_patrol) then {
                    _newgroup setCombatMode "YELLOW";
                    _newgroup setFormation (d_gwp_formations call XfRandomArrayVal);
                    _newgroup setFormDir (floor random 360);
                    _newgroup setSpeedMode "NORMAL";
                };
                _ret_grps set [ count _ret_grps, _newgroup];
                _grp_array = (if (_do_patrol) then {[_newgroup, _pos, 0,[_pos_center,_radius],[],-1,0,[],50 + (random 100),1]} else {[_newgroup, _pos, 0,[],[],-1,0,[],300 + (random 50),-1]});
                _grp_array execVM "x_scripts\x_groupsm.sqf";
                {extra_mission_remover_array set [ count extra_mission_remover_array, _x ] } foreach _units;
                sleep 2.011;
            };
        };
		sleep 2.123;
	} forEach _arr;
	_ret_grps
};

// Creates group of vehicles for side mission. All vehicles will be automatically removed after SM is finished
// call as follow: ["shilka", 1, "bmp", 2, "tank", 0, _poss, 1, 200, true] spawn XCreateArmor;
XCreateArmor = {
	private ["_type1", "_numbergroups1", "_type2", "_numbergroups2", "_type3", "_numbergroups3", "_pos_center",
	"_patrol_area", "_numvehicles", "_radius", "_do_patrol", "_ret_grps", "_side", "_pos", "_nr", "_numbergroups", "_i",
	 "_newgroup", "_unit_array", "_type", "_vehicles", "_leader", "_grp_array","_x"];

	_type1         = _this select 0;
 	_numbergroups1 = _this select 1;
	_type2         = _this select 2;
	_numbergroups2 = _this select 3;
	_type3         = _this select 4;
	_numbergroups3 = _this select 5;

	_pos_center = _this select 6;   // circle (count 2) or rectangle (count 4)
    _patrol_area = + _pos_center;
	if ( count _pos_center == 4 ) then // rectangle
	{
	    _pos_center = _patrol_area select 0; // select center point as first item in array
	}
	else // circle
	{
	    _patrol_area = [ _patrol_area, _radius ]; // set patrol area as [ _center_point_pos_arr, _radius ]
	};
	_type1 = [_type1, _pos_center] call SYG_camouflageTank;
	_type2 = [_type2, _pos_center] call SYG_camouflageTank;
	_type3 = [_type3, _pos_center] call SYG_camouflageTank;

    // main array of vehicle types and numbers of
	_arr = [ [ _numbergroups1, _type1 ],[ _numbergroups2, _type2 ],[_numbergroups3, _type3 ] ];
//	_arr = [ [ _this select 1, _this select 0 ],[ _this select 3, _this select 2 ],[ _this select 5, _this select 4 ] ];

	_numvehicles = _this select 7; // number of vehicles in separatу group
	_radius      = _this select 8;
	_do_patrol   = (if (count _this == 10) then {_this select 9} else {false});
	if (_radius < 50) then {_do_patrol = false;};
	_ret_grps = [];
	
	_side = d_enemy_side;
	_gwp_formations = ["COLUMN","STAG COLUMN","WEDGE","ECH LEFT","ECH RIGHT","VEE","LINE","DIAMOND"];
	_pos = [];
	//
	//+++++++++++++++++++++ main loop
	//
    {
        _grpArr = _x; // group description array
        // (_grpArr select 0) is number of vehicles in group
        if ((_grpArr select 0) > 0) then {
            for "_i" from 1 to (_grpArr select 0) do {
                while {!can_create_group} do {sleep (0.1 + (random (0.2))) };
                _newgroup = [_side] call x_creategroup;
                if (_radius > 0) then {
                    _pos = [_pos_center, _radius] call XfGetRanPointCircle;
                    while {count _pos == 0} do {
                        _pos = [_pos_center, _radius] call XfGetRanPointCircle;
                        sleep 0.04;
                    };
                } else {
                    _pos = _pos_center;
                };
                _unit_array = [(_grpArr select 1), _side] call x_getunitliste; // (_grpArr select 1) is type of vehicle
                _vehicles = [_numvehicles, _pos, (_unit_array select 2), (_unit_array select 1), _newgroup, 0,-1.111] call x_makevgroup;
                {
                	extra_mission_vehicle_remover_array set[ count extra_mission_vehicle_remover_array, _x];
                	sleep 0.01;
                    {
                        extra_mission_remover_array set[count extra_mission_remover_array, _x];
                        sleep 0.01;
                    } forEach (crew _x);
                } forEach _vehicles;
                sleep 2.011;
                _vehicles = nil;
                _leader = leader _newgroup;
                _leader setRank "LIEUTENANT";
                _newgroup allowFleeing 0;
                if (!_do_patrol) then {
                    _newgroup setCombatMode "YELLOW";
                    _newgroup setFormation (d_gwp_formations call XfRandomArrayVal);
                    _newgroup setFormDir (floor random 360);
                    _newgroup setSpeedMode "NORMAL";
                };
                _ret_grps = _ret_grps + [_newgroup];
                _grp_array = (if (_do_patrol) then {[_newgroup, _pos, 0, _patrol_area, [], -1, 0, [], 300 + (random 50),1]} else {[_newgroup, _pos, 0,[],[],-1,0,[],300 + (random 50),-1]});
                _grp_array execVM "x_scripts\x_groupsm.sqf";
                sleep 2.011;
            };
        };
        sleep 2.123;
    } forEach _arr; // for each vehicle group create and run patrol procedure on it

/* *
	for "_nr" from 1 to 3 do {
		call compile format ["
			if (_numbergroups%1 > 0) then {
				for ""_i"" from 1 to _numbergroups%1 do {
					while {!can_create_group} do {sleep 0.1 + random (0.2)};
					_newgroup = [_side] call x_creategroup;
					if (_radius > 0) then {
						_pos = [_pos_center, _radius] call XfGetRanPointCircle;
						while {count _pos == 0} do {
							_pos = [_pos_center, _radius] call XfGetRanPointCircle;
							sleep 0.04;
						};
					} else {
						_pos = _pos_center;
					};
					_unit_array = [_type%1, _side] call x_getunitliste;
					_vehicles = [_numvehicles, _pos, (_unit_array select 2), (_unit_array select 1), _newgroup, 0,-1.111] call x_makevgroup;
					extra_mission_vehicle_remover_array = extra_mission_vehicle_remover_array + _vehicles;
					{
						{
							extra_mission_remover_array = extra_mission_remover_array + [_x];
							sleep 0.01;
						} foreach (crew _x);
					} forEach _vehicles;
					sleep 2.011;
					_vehicles = nil;
					_leader = leader _newgroup;
					_leader setRank ""LIEUTENANT"";
					_newgroup allowFleeing 0;
					if (!_do_patrol) then {
						_newgroup setCombatMode ""YELLOW"";
						_newgroup setFormation (d_gwp_formations call XfRandomArrayVal);
						_newgroup setFormDir (floor random 360);
						_newgroup setSpeedMode ""NORMAL"";
					};
					_ret_grps = _ret_grps + [_newgroup];
					_grp_array = (if (_do_patrol) then {[_newgroup, _pos, 0,[_pos_center,_radius],[],-1,0,[],300 + (random 50),1]} else {[_newgroup, _pos, 0,[],[],-1,0,[],300 + (random 50),-1]});
					_grp_array execVM ""x_scripts\x_groupsm.sqf"";
					sleep 2.011;
				};
			};
		", _nr];
		sleep 2.123;
	};
* */
	_ret_grps
};

if (d_smoke) then {
	GetSmokePos = {
		private ["_pp","_pe","_dis","_px","_py","_ex","_ey","_angle","_a","_b","_reta","_smokex","_smokey"];
		_pp = _this select 0;_pe = _this select 1;_dis = _pp distance _pe;_px = _pp select 0;_py = _pp select 1;_ex = _pe select 0;_ey = _pe select 1;_angle = 0; _a = (_px - _ex);_b = (_py - _ey);
		if (_a != 0 || _b != 0) then {_angle = _a atan2 _b;}; if ( _angle < 0 ) then {_angle = _angle + 360;};_reta = [];
		for "_i" from -6 to 6 step 3 do {_smokex = _px - ((_dis - 10) * sin (_angle + _i));_smokey = _py - ((_dis - 10) * cos (_angle + _i));_reta = _reta + [[_smokex,_smokey,5]];};
		_reta
	};
};

XGuardWP = {
	private ["_ggrp"];
	_ggrp = _this;
	_ggrp setCombatMode "YELLOW";
	_ggrp setFormation (["COLUMN","STAG COLUMN","WEDGE","ECH LEFT","ECH RIGHT","VEE","LINE","FILE","DIAMOND"] call XfRandomArrayVal);
	_ggrp setFormDir (floor random 360);
	_ggrp setSpeedMode "NORMAL";
	_ggrp setBehaviour "SAFE";
};

XGovernorWP = {
	private ["_ggrp"];
	_ggrp = _this;
	_ggrp setCombatMode "YELLOW";
	_ggrp setFormation ("DIAMOND");
	_ggrp setFormDir (floor random 360);
	_ggrp setSpeedMode "LIMITED";
	_ggrp setBehaviour "STEALTH";
};

XAttackWP = {
	private ["_ggrp","_gtarget_pos","_gwp"];
	_ggrp = _this select 0;
	_gtarget_pos = _this select 1;
	_ggrp setBehaviour "AWARE";
	_gwp = _ggrp addWaypoint [_gtarget_pos,30];
	_gwp setWaypointType "SAD";
	_gwp setWaypointCombatMode "YELLOW";
	_gwp setWaypointSpeed "FULL";
};

XNormalPatrol = {
	private ["_grp","_gwpf"];
	_grp = _this select 0;
	_gwpf = if ((_this select 1) == 0) then {["COLUMN","STAG COLUMN","FILE"]} else {["COLUMN"]};
	_grp setFormation (_gwpf call XfRandomArrayVal);
	_grp setCombatMode "YELLOW";
	_grp setSpeedMode "LIMITED";
	_grp setBehaviour "SAFE";
};

XCombatPatrol = {
	private ["_grp","_gwpf"];
	_grp = _this;
	_gwpf = ["LINE","WEDGE","FILE"];
	_grp setFormation (_gwpf call XfRandomArrayVal);
	_grp setCombatMode "YELLOW";
	_grp setSpeedMode "LIMITED";
	_grp setBehaviour "AWARE";
};

XStealthPatrol = {
	private ["_grp","_gwpf"];
	_grp = _this select 0;
	_gwpf = ["LINE","WEDGE","FILE"];
	_grp setFormation (_gwpf call XfRandomArrayVal);
	_grp setCombatMode "YELLOW";
	_grp setSpeedMode "LIMITED";
	_grp setBehaviour "STEALTH";
};

//
// Finds wreck vehicle on wreck service circle.
// Wreck is defined as follow: vehicle has variable "RECOVERABLE" in personal variable space and has damage >= 1
//
XGetWreck = {
	private ["_no","_obj"];
	_no = nearestObjects [position (_this select 0), _this select 1, 8];
	if (count _no == 0) exitWith { objNull };
	_obj = objNull;
	// find dead recoverable vechile on the circle
	{
		if ( (! alive _x) &&  (_x call SYG_vehIsRecoverable) ) exitWith {
		//	hint localize format["+++ XGetWreck: %1 on recovery service", typeOf _x];
			_obj = _x;
		};
	} forEach _no;
//		hint localize format["+++ XGetWreck: %1 on recovery service, but vehicle is not "RECOVERABLE"", typeOf _no];
	_obj
};

//
// Update player score in the storage
// Call as follow:
// ["d_ad_sc", name player || _player_id, _newscore, _mtkills] call XAddPlayerScore; // 4 params
//
XAddPlayerScore = {
	private [ "_index", "_parray" ];
	if (typeName (_this select 1) == "SCALAR") then { _index = _this select 1 } // client ID
	else { _index = d_player_array_names find ( _this select 1 ) };

	if (_index >= 0) exitWith {
		_parray = d_player_array_misc select _index;
#ifdef __DEBUG__
		if ( round( (_parray select 3) / __DEBUG__)  < round( (_this select 2) / __DEBUG__ ) ) then { // each next 10 scores print debug status to check functionality
			format["DEBUG: %1", (target_names select (maintargets_list select (current_counter - 1))) select 1] call SYG_townStatReport;
//			_arr  = call SYG_townStatCalcScores;
//			hint localize format["+++ SYG_townStatCalcScores: names  %1", _arr select 0];
//			hint localize format["+++ SYG_townStatCalcScores: scores %1", _arr select 1];
		};
#endif
		_parray set [3, _this select 2]; // update total score
		if ( (_this select 3 ) > 0 ) then {	// update a player town kills
			[_index, _this select 3] call SYG_townStatItemUpdate;
		};
	};
};

// Sends info about player score etc if found it in server cache
// input params: ["d_p_a", name player<, missionStart<,"RUSSIAN">>]
XGetPlayerPoints = {
	private ["_name", "_index", "_staff", "_sound"];
	_name = (_this select 1);
	_index = d_player_array_names find _name;
	//__DEBUG_NET("XGetPlayerPoints",_name)
	//__DEBUG_NET("XGetPlayerPoints",_index)
	_staff = if (_index >= 0) then { d_player_array_misc select _index } else { [] };
	// prepare also semi-unical (up to 15 users) suicide sound for this player as parameter index 3
	if ( (toUpper (_name)) == "YETI") then {
	    _sound = format["suicide_yeti_%1", floor (random 5)]; // personal suicide sound for yeti (0..4);
	} else {
		// try to find special sound for german players
		_sound = "";
		if (count _this > 3 ) then {
			if ( (_this select 3) == "GERMAN") exitWith {_sound = format["suicide_german_%1", _index mod 5 ]}; // German player suicide screams (0..4)
		};
		if (_sound == "") then { // get ordinal sound, not special
	    	_sound = _index call SYG_getSuicideScreamSoundById; // set sound from common list, not personal (yeti, any german player etc)
	    };
	};
	["d_player_stuff", _staff, SYG_dateStart, _sound, _index] call XSendNetStartScriptClient;
	hint localize format["+++ server->XGetPlayerPoints: ""d_p_a"" msg for ""%1"" received,  staff (scores %2) sent to the client, suicide snd ""%3"" +++", _name, _staff select 3, _sound];
};

// calls as follow: _near_enemy_arr = _grp_array call x_get_nenemy
// returns: known nearest enemy units array [_nearest_enemy,_pos_nearest,_leader knowsAbout _nearest_enemy]
//or empty array []  if no enemy known to the designated unit
x_get_nenemy = {
	private ["_grp_array", "_grp", "_leader", "_nearest_enemy", "_ret", "_pos_nearest", "_near_targets","_x"];
	_grp_array = _this;
	_grp = _grp_array select 0;
	if (isNull _grp || ({alive _x} count units _grp) == 0) exitWith {[]};
	_leader = leader _grp;
	_nearest_enemy = _leader findNearestEnemy (position _leader);
	_ret = [];
	if (!isNull _nearest_enemy) then {
		_pos_nearest = [];
		if (!isNull _leader && _leader distance _nearest_enemy < (_grp_array select 8)) then {
			if (_leader knowsAbout _nearest_enemy > 0.2) then {
				_near_targets = _leader nearTargets ((_leader distance _nearest_enemy) + 10);
				if (count _near_targets > 0) then {
					{
						if ((_x select 4) == _nearest_enemy) exitWith {
							_pos_nearest = _x select 0;
						};
						sleep 0.01;
					} forEach _near_targets;
				};
			};
		};
		_ret = if (count _pos_nearest > 0) then {[_nearest_enemy,_pos_nearest,_leader knowsAbout _nearest_enemy]} else {[]};
	};
	_ret
};

// calls as follow: _near_enemy_arr = [_grp, _dist] call x_get_nenemy
//              or: _near_enemy_arr = [_unit,_dist] call x_get_nenemy
// returns: known nearest enemy units array [_nearest_enemy,_pos_nearest,_leader knowsAbout _nearest_enemy]
//or empty array []  if no enemy known to the designated unit
grp_getnenemy = {
	private ["_grp", "_leader", "_nearest_enemy", "_ret", "_pos_nearest", "_near_targets","_dist","_x"];
	if ( typeName _this != "ARRAY" ) exitWith{[]};
	if ( count _this < 2 ) exitWith{[]};
	_grp = _this select 0;
	if ( typeName _grp == "OBJECT" ) then {_grp = group _grp;};
	if ( typeName _grp != "GROUP") exitWith {[]};
	if (isNull _grp || ({alive _x} count units _grp) == 0) exitWith {[]};
	_dist = _this select 1;
	_leader = _grp call SYG_getLeader;
	if (isNull _leader ) exitWith{[]};
	_nearest_enemy = _leader findNearestEnemy (position _leader);
	if ((_leader distance _nearest_enemy) <_dist) exitWith {[]};
	_ret = [];
	if (!isNull _nearest_enemy) then
	{
		_pos_nearest = [];
        if (_leader knowsAbout _nearest_enemy > 0.2) then {
            _near_targets = _leader nearTargets ((_leader distance _nearest_enemy) + 10);
            if (count _near_targets > 0) then {
                {
                    if ((_x select 4) == _nearest_enemy) exitWith {
                        _pos_nearest = _x select 0;
                    };
                    sleep 0.01;
                } forEach _near_targets;
            };
        };
		_ret = if (count _pos_nearest > 0) then {[_nearest_enemy,_pos_nearest,_leader knowsAbout _nearest_enemy]} else {[]};
	};
	_ret

};

// return true if nearest enemy exists, false if no enemy or enemy at distance more than 70 meters from original enemy position
x_get_nenemy2 = {
	private ["_epos", "_leader", "_ret", "_nearest_enemy"];
	_epos = _this select 0;_leader = _this select 1;_ret = false;
	_nearest_enemy = _leader findNearestEnemy _epos;
	if (!isNull _nearest_enemy) then {if (_nearest_enemy distance _epos < 70) then {_ret = true;};};
	_ret
};

XOutOfBounds = {
	private ["_vec", "_p_x", "_vehicle", "_p_y"];
	_vec = _this;
	_p_x = position _vehicle select 0;
	_p_y = position _vehicle select 1;
	if ((_p_x < 0 || _p_x > ((d_island_center select 0) * 2)) && (_p_y < 0 || _p_y > ((d_island_center select 1) * 2))) then {
		true
	} else {
		false
	}
};

xx_make_normal = {
	private ["_grp_array", "_grp"];
	_grp_array = _this;
	_grp = _grp_array select 0;
	
	if (_grp_array select 9 < 0) then {
		(units _grp) doMove (_grp_array select 1);
		_grp setCombatMode "YELLOW";
		_grp setSpeedMode "NORMAL";
		_grp setBehaviour "SAFE";
	} else {
		[_grp,_grp_array select 9] call XNormalPatrol;
	};
};
