// by Xeno
// x_m30.sqf

#include "x_setup.sqf"
#include "x_macros.sqf"

#define __DEBUG__

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[18239,2943.84,0],[18186.4,3081.09,0]]; // index: 30,   scientist on Monte Asharah
x_sm_type = "normal"; // "convoy"

#ifdef __ACE__
#define __AA_DEFENCE_ON_ASHARAN__
#endif

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SM_30";// "Противник проводит эксперименты в кратере вулкана на острове Asharah. Ваша задача ликвидировать ученого. Внимание, ПВО острова усилено!"
	current_mission_resolved_text = localize "STR_SM_030";// "Задание выполнено! Ученый ликвидирован."
};

if (isServer) then {
	private ["_grps","_bpos","_sm_vehicle","_aa_types","_utype"];
	_officer = "Civilian19";
	__PossAndOther
	_grps = ["shilka", 2, "bmp", 1, "tank", 0, _pos_other,1,100,true] spawn XCreateArmor;
	sleep 2.123;

#ifdef __DEBUG__		
	hint localize format["%1 x_m30.sqf: mission started, scientist type is ""%2"", armors created", call SYG_missionTimeInfoStr, _officer];
#endif

	["specops", 0, "basic", 2, _pos_other, 100, true]  spawn XCreateInf;
/*
 	{
		private ["_grps"];
		_grps = _this call ;
#ifdef __DEBUG__		
		hint localize format["%1 x_m30.sqf: %2 basic groups created", call SYG_missionTimeInfoStr, count _grps];
#endif
	};
 */
	//	["specops", 1, "basic", 1, _poss,20] spawn XCreateInf;
	// as this group is near officer, rearm it with some special specops weapons
	sleep 1.123;
	["specops", 1, "basic", 1, _poss,50]  spawn
	{
		private ["_grps", "_cnt"];
		_grps = _this call XCreateInf;
		_cnt = (_grps select 0) call SYG_rearmSpecopsGroup;
#ifdef __DEBUG__		
		hint localize format["%1 x_m30.sqf: %2 of %3 specops rearmed", call SYG_missionTimeInfoStr, _cnt, count units (_grps select 0)];
#endif
	};
	
	sleep 2.111;
	_fortress = "Fortress2" createVehicle _poss;
	//_fortress setDir 290.789;
	__AddToExtraVec(_fortress)
	sleep 2.123;
	__WaitForGroup
	__GetEGrp(_newgroup)
	_sm_vehicle = _newgroup createUnit [_officer, _poss, [], 0, "FORM"];
	
	[_sm_vehicle] join _newgroup;
	
	//+++ Sygsky: rearm with random pistol
	if (d_enemy_side != "EAST") then
	{
		sleep 0.5;
		_sm_vehicle call SYG_rearmPistolero;
	};
	//--- Sygsky
	
	#ifndef __TT__
	_sm_vehicle addEventHandler ["killed", {_this call XKilledSMTargetNormal}];
	#endif
	#ifdef __TT__
	_sm_vehicle addEventHandler ["killed", {_this call XKilledSMTargetTT}];
	#endif
	sleep 2.123;
	_bpos = _fortress buildingPos 1;
	_sm_vehicle setPos _bpos;
	_leader = leader _newgroup;
	_leader setRank "COLONEL";
	_newgroup allowFleeing 0;
	_newgroup setBehaviour "AWARE";
	
#ifdef __AA_DEFENCE_ON_ASHARAN__
//+++ Sygsky: add more AA-defence	
	sleep 2.156;
	__WaitForGroup
	__GetEGrp(_newgroup)
	_aa_types = [if (d_enemy_side == "EAST") then {"Stinger_Pod_East"} else {"Stinger_Pod"},"ACE_ZU23M"];
	_utype = if (d_enemy_side == "EAST") then {d_crewman2_E} else {d_crewman2_W};
	_pntarr = [ [18266.2,2966.5,0], [18212.8,2960.9,0], [18240.4,2902.3,0], [17894.4,3406.75,0] ];
	[_newgroup, _aa_types, _utype, _pntarr] call SYG_createStaticWeaponGroup;
	[ _newgroup, ["ACE_ZU23M"], _utype, [ [17964.3,4022.6,0], [16839.09,5070.03,0] ] ] call SYG_createStaticWeaponGroup; // put ZSU-2 onto small desert islets

	_newgroup allowFleeing 0;
	//_newgroup setCombatMode "YELLOW"; // is set in SYG_createStaticWeaponGroup
	{ _x setDir (floor random 360) } forEach units _newgroup;
	_newgroup setSpeedMode "NORMAL";
	_grp_array = [_newgroup, _pos, 0, [], [], -1, 0, [], 100, -1];
	_grp_array execVM "x_scripts\x_groupsm.sqf";

	hint localize format["%1 x_m30.sqf: AA defence on Asharan is created (%2 vehicles)", call SYG_missionTimeInfoStr, count units _newgroup ];
#endif
	
	
};

if (true) exitWith {};