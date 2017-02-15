//
// by Xeno: x_target_clear.sqf. Called on server from town or airbase trigger if all goals are achived
//
private ["_current_target_pos","_dummy","_rnd","_start_real","_points_array"];
if (!isServer) exitWith{};

#include "x_setup.sqf"

sleep 1.123;

deleteVehicle current_trigger;
sleep 0.01;

if ( count _this > 0 ) exitWith // airbase taken by our army, nothing to clear
{
    ["airbase_clear"] call XSendNetStartScriptClient;
    (-1) execVM "x_scripts\x_deleteunits.sqf";
};

counterattack = false;
_start_real = false;
#ifndef __TT__
if (count target_names == 22 && current_target_index != 5) then { // if maximal mission and not Rahmadi
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

if (current_counter < number_targets) then {
	sleep 15;
#ifdef __TT__
	kill_points_west = 0;
	kill_points_racs = 0;
	public_points = true;
#endif
	execVM "x_scripts\x_createnexttarget.sqf";
} else {
	if (count d_recapture_indices == 0) then {
		the_end = true;
		["the_end",the_end] call XSendNetVarClient;
	} else {
		[] spawn {
			while {count d_recapture_indices > 0} do {
				sleep 2.543;
			};
			the_end = true;
			["the_end",the_end] call XSendNetVarClient;
		};
	};
};

if (true) exitWith {};
