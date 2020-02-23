// by Xeno
// x_m35.sqf
private ["_sm_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[12492,10849,0],[12500.9,10883.5,0]]; // index: 35,   Government member Isla de Libertad (attention, the AI is placed in a Lighthouse, uses nearestObject ID)
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SM_35";// "Консультант министерства обороны США прибыл с малопонятной целью в Isla de Libertad. Ваша задача - его ликвидация.";
	current_mission_resolved_text = localize "STR_SM_035";// "Задание выполнено! Консультант министерства ликвидирован.";
};

if (isServer) then {
	#ifdef __ACE__
        _officer = (if (d_enemy_side == "EAST") then {"ACE_OfficerE"} else {"ACE_USMC0302"});
    #else
        _officer = (if (d_enemy_side == "EAST") then {"OfficerE"} else {"OfficerW"});
    #endif
	__PossAndOther
	["shilka", 1, "bmp", 2, "tank", 0, _pos_other,1,0] spawn XCreateArmor;
	sleep 2.123;
	_building = _poss nearestObject 53;
	__WaitForGroup
	__GetEGrp(_newgroup)
	_sm_vehicle = _newgroup createUnit [_officer, _poss, [], 0, "FORM"];
	[_sm_vehicle] join _newgroup;
	
	//+++ Sygsky: rearm with M14
	if (d_enemy_side != "EAST") then
	{
		sleep 0.5;
		[_sm_vehicle,1.0,SYG_M14_WPN_SET_STD_SD_OPTICS] call SYG_rearmM14;
	};
	//--- Sygsky
	
	#ifndef __TT__
	_sm_vehicle addEventHandler ["killed", {_this call XKilledSMTargetNormal}];
	#endif
	#ifdef __TT__
	_sm_vehicle addEventHandler ["killed", {_this call XKilledSMTargetTT}];
	#endif
	sleep 2.123;
	_bpos = _building buildingPos 1;
	_sm_vehicle setPos _bpos;
	sleep 2.123;
	_leader = leader _newgroup;
	_leader setRank "COLONEL";
	_newgroup allowFleeing 0;
	_newgroup setbehaviour "AWARE";
	sleep 2.123;
	//["specops", 1, "basic", 1, _poss,0] spawn XCreateInf;
		// as this group is near officer, rearm it with some special specops weapons
	["specops", 1, "basic", 1, _poss,0]  spawn 
	{
		private ["_grps","_cnt"];
		_grps = _this call XCreateInf;
		_cnt = (_grps select 0) call SYG_rearmSpecopsGroup;
#ifdef __DEBUG__		
		hint localize format["%1 x_m35.sqf: %2 of %3 specops rearmed", call SYG_missionTimeInfoStr, _cnt, count units (_grps select 0)];
#endif
	};

};

if (true) exitWith {};