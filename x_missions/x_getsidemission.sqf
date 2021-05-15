// by Xeno, x_getsidemission.sqf, server side
//private ["_bpos","_grps","_leader","_leadero","_nbuilding","_newgroup","_no_list","_ogroup","_pos_other","_pos_other2",
//		 "_posi_array","_poss","_sm_vehicle","_unitsg","_vehicle","_officer","_building2","_xtank","_xplane","_xchopper","_xarti"];

#include "x_setup.sqf"

#define __DEBUG__

if (!isServer) exitWith{};

if (all_sm_res || stop_sm) exitWith {};

if (current_mission_counter >= number_side_missions) exitWith {
	all_sm_res = true;
	["all_sm_res",all_sm_res] call XSendNetStartScriptClient;
#ifdef __DEBUG__
    hint localize "+++ x_getsidemission.sqf: all_sm_res = true, exit !!!";
#endif
};

// stop SM system if all towns are liberated!!!
if ((current_counter >= number_targets) /** && (!main_target_ready) */) exitWith {
    stop_sm = true;
    publicVariable "stop_sm";
    ["stop_sm", true] call XSendNetStartScriptClient;
#ifdef __DEBUG__
    hint localize "+++ x_getsidemission.sqf: stop_sm = true, side mission system stopped as all target towns are liberated !!!";
#endif
};

while {!main_target_ready} do {sleep 12.321};

// index of current side mission, not number of executed one
current_mission_index = side_missions_random select current_mission_counter;
// mission executed counter, at the start == 0
current_mission_counter = current_mission_counter + 1;

// Arrays for SM units and vehicles
extra_mission_remover_array = [];
extra_mission_vehicle_remover_array = [];

//current_mission_index = _this select 0;
//current_mission_index = 52;

#ifdef __DEBUG__
//hint localize format["x_getsidemission.sqf: side_missions_random is %1", side_missions_random];
hint localize format["+++ x_getsidemission.sqf: Preparing next Side Mission; current_mission_index %1, current_mission_counter %2", current_mission_index, current_mission_counter];
#endif


#ifdef __DEFAULT__
call compile format ["
	execVM ""x_missions\m\%2%1.sqf"";
", current_mission_index, d_mission_filename];
#endif

#ifdef __TT__
call compile format ["
	execVM ""x_missions\m\%2%1.sqf"";
", current_mission_index,d_mission_filename];
#endif

#ifdef __SCHMALFELDEN__
call compile format ["
	execVM ""x_missions\m_schmal\%2%1.sqf"";
", current_mission_index,d_mission_filename];
#endif

#ifdef __UHAO__
call compile format ["
	execVM ""x_missions\m_uhao\%2%1.sqf"";
", current_mission_index,d_mission_filename];
#endif

sleep 7.012;
["update_mission", current_mission_index, current_mission_counter, x_sm_pos select 0] call XSendNetStartScriptClient;

side_mission_resolved = false;
side_mission_winner = 0;

if (true) exitWith {};