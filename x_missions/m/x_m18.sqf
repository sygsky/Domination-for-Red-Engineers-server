// by Xeno
// x_m18.sqf
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[9709.64,11010.8,0], [9655.45,11026.4,0]]; // index: 18,   Government member visit in Rashidah shipyard
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (X_Client) then {
	current_mission_text = localize "STR_SM_18"; // "Один из высокопоставленных чинов врага прибыл в Rashidah. Задача  - уничтожить его, пока он осматривает местную верфь!";
	current_mission_resolved_text = localize "STR_SM_018"; // "Задание выполнено! Вражеский чиновник уничтожен!";
};

if (isServer) then {
	__PossAndOther
	["shilka", 1, "bmp", 1, "tank", 1, _pos_other,1,120,true] spawn XCreateArmor;
	sleep 2.123;
	//["specops", 1, "basic", 1, _poss,100,true] spawn XCreateInf;
	// as this group is near officer, rearm it with some special specops weapons
	["specops", 1, "basic", 1, _poss,100,true]  spawn 
	{
		private ["_grps","_cnt"];
		_grps = _this call XCreateInf;
		_cnt = (_grps select 0) call SYG_rearmSpecopsGroup;
#ifdef __DEBUG__		
		hint localize format["%1 x_m18.sqf: %2 of %3 specops rearmed", call SYG_missionTimeInfoStr, _cnt, count units (_grps select 0)];
#endif
	};
	
	
	sleep 2.111;
	_fortress = "Fortress2" createVehicle _poss;
	//_fortress setDir -133.325;
	__AddToExtraVec(_fortress)
	// createGuardedPoint[d_side_enemy,position _fortress, -1, _fortress];
	sleep 2.123;
	__WaitForGroup
	__GetEGrp(_newgroup)
	_sm_vehicle = _newgroup createUnit ["King", _poss, [], 0, "FORM"];
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
	_newgroup setbehaviour "AWARE";
	//_leader setUnitPos "DOWN";
};

if (true) exitWith {};