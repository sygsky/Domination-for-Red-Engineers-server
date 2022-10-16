// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[10131.6,8377.25,0], [10115.8,8420.6,0]]; // index: 19,   Prime minister of Tadistan in Pesto
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SYS_140"; // "Премьер-министр Тадистана прибыл с визитом в Pesto. Накажите его!";
	current_mission_resolved_text = localize "STR_SYS_141"; //"Задание выполнено! Премьер-министр наказан.";
};

if (isServer) then {
	__PossAndOther
	["shilka", 1, "bmp", 1, "tank", 1, _pos_other,1,130,true] spawn XCreateArmor;
	sleep 2.123;
//	["specops", 1, "basic", 1, _poss,80,true] spawn XCreateInf;

	// as this group is near officer, rearm it with some special specops weapons
	["specops", 1, "basic", 1, _poss,80,true]  spawn 
	{
		private ["_grp_ret","_cnt"];
		_grp_ret = _this call XCreateInf;
		_cnt = (_grp_ret select 0) call SYG_rearmSpecopsGroup;
#ifdef __DEBUG__		
		hint localize format["+++ %1 x_m19.sqf: %2 of %3 specops rearmed", call SYG_missionTimeInfoStr, _cnt, count units (_grp_ret select 0)];
#endif
	};
	
	sleep 2.111;
	_fortress = "Fortress2" createVehicle _poss;
	_fortress setDir 290.789;
	__AddToExtraVec(_fortress)
	sleep 2.123;
	__WaitForGroup
	__GetEGrp(_newgroup)
	_sm_vehicle = _newgroup createUnit ["NorthPrimeMinister", _poss, [], 0, "FORM"];
	[_sm_vehicle] join _newgroup;
	
	//+++ Sygsky: rearm with random pistol
	sleep 0.3;
	[_sm_vehicle,call SYG_pilotEquipmentWest] call SYG_armUnit;
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
	_newgroup setbehaviour "AWARE";
};

if (true) exitWith {};