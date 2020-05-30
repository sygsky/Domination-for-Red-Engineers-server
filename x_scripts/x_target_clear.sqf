//
// by Xeno: x_target_clear.sqf. Called on server from town or airbase trigger if all goals are achieved
//
private ["_current_target_pos","_dummy","_rnd","_start_real","_points_array","_str"];
if (!isServer) exitWith{};

hint localize format["%1 execVM x_scripts\x_target_clear.sqf", _this];
#include "x_setup.sqf"

sleep 1.123;

deleteVehicle current_trigger;
sleep 0.01;

// TODO: for airbase initial mission, still not realized
_stop = false;
if ( (count _this > 0) && ( typeName (_this select 0) == "SCALAR" ) ) exitWith // e.g. [-1] execVM "x_target_clear.sqf": input param array not empty only for airbase taken by our army, nothing really to clear
{
    ["airbase_clear"] call XSendNetStartScriptClient; // inform about this event and exit
    _stop = true;
};

// but may be so: [thislist]  execVM "x_target_clear.sqf", and can count alive remnants
if ( count _this > 0 && ( typeName (_this select 0) == "ARRAY" )) then
{
    hint localize format[ "call to x_scripts\x_target_clear.sqf with remained enemy men %1, tanks %2, cars %3, statics %4",
        "Man" countType _this, "Tank" countType _this, "Car" countType _this, "StaticWeapon" countType _this];
};

if ( _stop ) exitWith {true};

counterattack = false;
_start_real = false;
#ifndef __TT__
if (number_targets == 22 && current_target_index != 5) then { // if maximal mission and not Rahmadi
#endif
	_rnd = random 100;
	// _rnd > 94 means counterattack, aka 5 % chance for a counterattack
	if (_rnd > 94) then {
		counterattack = true;
		_start_real = true;
		["an_countera", "start"] call XSendNetStartScriptClient;
		execVM "x_scripts\x_counterattack.sqf";
	};
#ifndef __TT__
};
#endif

while {counterattack} do {sleep 3.123};

if (_start_real) then {
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

if (current_counter < number_targets) then {
	execVM "x_scripts\x_gettargetbonus.sqf";
} else {
    // no bonus vehicle after last target town was cleared
	target_clear = true;
	["target_clear",target_clear, -1] call XSendNetStartScriptClient;
};

sleep 2.123;

current_target_index execVM "x_scripts\x_deleteunits.sqf";

sleep 4.321;

#ifndef __TT__
if (!d_no_para_at_all) then {
	if (current_counter < number_targets) then {
		execVM "x_scripts\x_createjumpflag.sqf";
	};
};
#endif

sleep 0.245;

if (d_do_delete_empty_main_target_vecs) then {
	[current_target_index] execVM "x_scripts\x_deleteempty.sqf";
};

d_run_illum = false;

// now decide what to do next
if (current_counter < number_targets) then {
	sleep 15;
#ifdef __TT__
	kill_points_west = 0;
	kill_points_racs = 0;
	public_points = true;
#endif
	execVM "x_scripts\x_createnexttarget.sqf";
} else {
    d_max_recaptures = 0;
//    stop_sm          = true;
//    publicVariable "stop_sm";
    // TODO: #368, wait until base cleared from enemies and
    // no recaptured towns and (resolved)
    // side mission completed (resolved)
    hint localize "+++ x_target_clear.sqf: run stop new target town creation system process as all target towns are liberated !!!";
    _str = "";
    if ( (count d_recapture_indices > 0) && (!stop_sm) ) then { _str = "STR_SYS_121_3_FULL" }
    else {
        if ( !stop_sm ) then { _str = "STR_SYS_121_3_SM" } else { _str = "STR_SYS_121_3_RECAPTURED"};
    };
    if (_str != "") then {
        [ "msg_to_user", "*", [ [ _str ] ], 0, 2, false, "fanfare" ] call  XSendNetStartScriptClient; // The enemy escaped! ..."
    };
    // while any town recaptured or side mission active
    while { !((count d_recapture_indices == 0) && stop_sm) } do { sleep 2.543; };
    the_end = true;
    ["the_end",the_end] call XSendNetVarClient;
    hint localize "+++ x_target_clear.sqf: the_end = true; !!!";
};

if (true) exitWith {};
