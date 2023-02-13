//
// by Xeno: x_target_clear.sqf. Called on server from town or airbase trigger if all goals are achieved
//
if (!isServer) exitWith{};
private ["_current_target_pos","_dummy","_rnd","_counter_attack","_points_array","_str","_last_town_index"];

// hint localize format["+++  %1 execVM x_scripts\x_target_clear.sqf", typeName _this];

#include "x_setup.sqf"

sleep 1.123;

deleteVehicle current_trigger;
sleep 0.01;

// TODO: for airbase initial mission, still not realized
if ( (count _this > 0) && ( typeName (_this select 0) == "SCALAR" ) ) exitWith  {// e.g. [-1] execVM "x_target_clear.sqf": input param array not empty only for airbase taken by our army, nothing really to clear
    ["airbase_clear"] call XSendNetStartScriptClient; // inform about this event and exit
};

// but may be so: [thislist]  execVM "x_target_clear.sqf", and can count alive remnants
if ( count _this > 0 ) then {
	if (  typeName (_this select 0) == "ARRAY" ) then {
		_this = _this select 0;
		hint localize format[ "+++ x_scripts\x_target_clear.sqf: %1 finished with alive enemy men %2, tanks %3, cars %4, statics %5",
			(target_names select current_target_index) select 1,
			"Man" countType _this, "Tank" countType _this, "Car" countType _this, "StaticWeapon" countType _this];
	};
};

counterattack = false;
_counter_attack = false;

#ifndef __TT__
if (number_targets >= 15 /* && current_target_index != 5 */ && (current_counter < number_targets)) then { // Now all towns have counter attacks
#endif

#ifndef __TOWN_WEAK_DEFENCE__
	_rnd = random number_targets;
	// _rnd < 5 % chance for a counterattack is nearly 1 town per 20 towns
	if (_rnd < (number_targets  * 0.05) ) then {
		counterattack = true;
		_counter_attack = true;
		[ "an_countera", "start", call SYG_getCounterAttackTrack ] call XSendNetStartScriptClient;
		execVM "x_scripts\x_counterattack.sqf";
	};
#endif

#ifndef __TT__
};
#endif

while {counterattack} do {sleep 3.123};

if (_counter_attack) then {
	["an_countera", "over"] call XSendNetStartScriptClient;
	sleep 2.321;
};

#ifndef __TT__
resolved_targets = resolved_targets + [current_target_index];
#endif

#ifdef __TT__

if (kill_points_west > kill_points_racs) then {
	mt_winner = 1;
	points_west = points_west + 10;
} else {
	if (kill_points_racs > kill_points_west) then {
		mt_winner = 2;
		points_racs = points_racs + 10;
	} else {
		if (kill_points_racs == kill_points_west) then {
			mt_winner = 3;
			points_west = points_west + 5;
			points_racs = points_racs + 5;
		};
	};
};
_points_array = [points_west,points_racs,kill_points_west,kill_points_racs];
["points_array",_points_array] call XSendNetStartScriptClient;
resolved_targets = resolved_targets + [[current_target_index,mt_winner]];
["mt_winner",mt_winner] call XSendNetVarClient;


sleep 0.5;
public_points = false;

#endif

sleep 0.5;

// pre-save last town index (newly liberated one)
_last_town_index = current_target_index;

//hint localize format["+++ DEBUG: x_target_clear.sqf: _last_town_index (%1) = current_target_index (%2)", _last_town_index,  current_target_index];

if (current_counter < number_targets) then {
	[_counter_attack,_last_town_index] execVM "x_scripts\x_gettargetbonus.sqf"; // inform user about counterattack and bonus score for it
} else {
    // no bonus vehicle after last target town was cleared
	target_clear = true;
	["target_clear",target_clear, -1, _counter_attack] call XSendNetStartScriptClient;
};

sleep 2.123;

_last_town_index execVM "x_scripts\x_deleteunits.sqf";

sleep 4.321;

#ifndef __TT__
if (!d_no_para_at_all) then {
//	hint localize format["+++ DEBUG: x_target_clear.sqf (x_createjumpflag.sqf): current_counter(%1) <  number_targets(%2) ?", current_counter, number_targets];
	if (current_counter < number_targets) then {
//		hint localize format["+++ DEBUG: x_target_clear.sqf (x_createjumpflag.sqf): %1 execVM ""x_scripts\x_createjumpflag.sqf""", _last_town_index];
		_last_town_index execVM "x_scripts\x_createjumpflag.sqf";
	} else {
		hint localize "--- x_target_clear.sqf (x_createjumpflag.sqf) not executed as current_counter >= number_targets";
	};
};
#endif

sleep 0.245;

if (d_do_delete_empty_main_target_vecs) then {
//	hint localize format["+++ DEBUG: x_target_clear.sqf: execVM  ""x_deleteempty.sqf"", _last_town_index = %1", _last_town_index];
	_last_town_index execVM "x_scripts\x_deleteempty.sqf";
};

d_run_illum = false;

// now decide what to do next
if (current_counter < number_targets) then {
	sleep 15; // TODO: sleep (60 + random(60)); // explore this variant, it may be very dangerous
#ifdef __TT__
	kill_points_west = 0;
	kill_points_racs = 0;
	public_points = true;
#endif
// todo: #437 - count number of new riuns in town and inform all players abpout
	_last_town_index execVM "scripts\countTargetRuins.sqf";
	execVM "x_scripts\x_createnexttarget.sqf";
} else {
    d_max_recaptures = 0;
//    stop_sm          = true;
//    publicVariable "stop_sm";
    // TODO: #368, wait until base cleared from enemies and
    // no recaptured towns and (implemented)
    // side mission completed (implemented)
    hint localize "+++ x_target_clear.sqf: run stop new target town creation system process as all target towns are liberated !!!";
    _str = "";
    if ( (count d_recapture_indices > 0) && (!stop_sm) ) then { _str = "STR_SYS_121_3_FULL" } // "For the complete liberation of the island, complete the SM and destroy the invaders"
    else {
        // "For the complete liberation of the island, complete the SM"
        // "For the complete liberation of the island, free the recaptured town"
        if ( !stop_sm ) then { _str = "STR_SYS_121_3_SM" } else { _str = "STR_SYS_121_3_RECAPTURED"};
    };
    if (_str != "") then {
        [ "msg_to_user", "*", [ [ _str ] ], 0, 2, false, "fanfare" ] call  XSendNetStartScriptClient; // The enemy escaped! ..."
    };
    // while any town recaptured or side mission active
    while { !((count d_recapture_indices == 0) && stop_sm) } do { sleep 2.543; };
    the_end = true;
    ["the_end",the_end] call XSendNetVarClient;
    _str = call SYG_missionTimeInfoStr;
    hint localize format["++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++", _str];
    hint localize format["+++ x_target_clear.sqf: the_end = true; Time to finish %1!!!", _str];
    hint localize format["++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++", _str];
};

if (true) exitWith {};
