// OPC == On Player Connect
if (!isServer) exitWith{};
private ["_name", "_miscp", "_index", "_bit_array", "_var", "_bitasnum","_tmp_a","_new_p","_time"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __DEBUG_PRINT__

_name = _this select 0;

if (_name == "__SERVER__") exitWith {};

#ifdef __DEBUG_PRINT__
hint localize format[ "+++ x_scripts\x_serverOPC.sqf: player name is ""%1""", _name ];
#endif

//__DEBUG_NET("x_serverOPC player connected",_name)

if (!(_name in d_player_array_names)) then {
	d_player_array_names set [ count d_player_array_names, _name];
	d_player_array_misc set [count d_player_array_misc,[d_player_air_autokick, time, _name, 0,"",""]];
};

_name call SYG_townScoresAdd; // register player as current town pliberation participant

date_str = date;
_tmp_a = [];
_bit_array = [mt_radio_down,target_clear,all_sm_res,the_end,mr1_in_air,mr2_in_air,ari_available,ari2_available,d_jet_service_fac_rebuilding,d_chopper_service_fac_rebuilding,d_wreck_repair_fac_rebuilding];
{
	_var = _x getVariable "d_ammobox";
	if (format["%1",_var] == "<null>") then {
		_var = false;
	};
	_bit_array = _bit_array + [_var];
	_var = _x getVariable "d_ammobox_next";
	if (format["%1",_var] == "<null>") then {
		_var = -1;
	};
	_tmp_a = _tmp_a + [_var];
} forEach [MRR1,MRR2,HR1,HR2,HR3,HR4];

#ifdef __TT__
_bit_array = _bit_array + [mrr1_in_air,mrr2_in_air];
{
	_var = _x getVariable "d_ammobox";
	if (format["%1",_var] == "<null>") then {
		_var = false;
	};
	_bit_array = _bit_array + [_var];
	_var = _x getVariable "d_ammobox_next";
	if (format["%1",_var] == "<null>") then {
		_var = -1;
	};
	_tmp_a = _tmp_a + [_var];
} forEach [MRRR1,MRRR2,HRR1,HRR2,HRR3,HRR4];
#endif

_bitasnum = _bit_array call XfBitArrayToNum;

d_vars_array = [_bitasnum,date_str,current_target_index,current_mission_index,ammo_boxes,sec_kind,resolved_targets];
d_vars_array = d_vars_array + [jump_flags,truck1_cargo_array,truck2_cargo_array,mt_radio_pos,d_ammo_boxes,d_wreck_marker];
d_vars_array = d_vars_array + [d_jet_service_fac,d_chopper_service_fac,d_wreck_repair_fac,fRainLess,fRainMore,fFogLess,fFogMore,_tmp_a];

#ifdef __TT__
	points_array = [points_west,points_racs,kill_points_west,kill_points_racs];
	d_vars_array = d_vars_array + [points_array];
#endif

//__DEBUG_NET("x_serverOPC player connected d_vars_array",d_vars_array)

publicVariable "d_vars_array";
d_vars_array = [];

if (true) exitWith {};
