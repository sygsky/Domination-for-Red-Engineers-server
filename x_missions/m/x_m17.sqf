// by Xeno
// x_m17.sqf
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[15318.3,9870.91,0], [15368.8,9875.38,0]]; // index: 17,   Officer in Valor
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SM_17";// "Сегодня в Valor прибыл вражеский офицер. Ваша задача ликвидация офицера!";
	current_mission_resolved_text = localize "STR_SM_017";// "Задание выполнено! Вражеский офицер уничтожен.";
};

if (isServer) then {

	#ifdef __ACE__
        _officer = (if (d_enemy_side == "EAST") then {"ACE_OfficerE"} else {"ACE_USMC8541A2"});
    #else
        _officer = (if (d_enemy_side == "EAST") then {"OfficerE"} else {"OfficerW"});
    #endif

	__PossAndOther
	["shilka", 1, "bmp", 1, "tank", 1, _pos_other,1,110,true] spawn XCreateArmor;
	sleep 2.123;
	
	//["specops", 1, "basic", 1, _poss,70,true] spawn XCreateInf;
	// as this group is near officer, rearm it with some special specops weapons
	["specops", 1, "basic", 1, _poss,70,true]  spawn 
	{
		private ["_grps","_cnt"];
		_grps = _this call XCreateInf;
		_cnt = (_grps select 0) call SYG_rearmSpecopsGroup;
#ifdef __DEBUG__		
		hint localize format["%1 x_m17.sqf: %2 of %3 specops rearmed", call SYG_missionTimeInfoStr, _cnt, count units (_grps select 0)];
#endif
	};
	
	sleep 2.111;
	_fortress = "Fortress2" createVehicle _poss;
//	_fortress setDir -133.325;
	__AddToExtraVec(_fortress)
	sleep 2.123;
	__WaitForGroup
	__GetEGrp(_newgroup)
	_sm_vehicle = _newgroup createUnit [_officer, _poss, [], 0, "FORM"];
	[_sm_vehicle] join _newgroup;
	
	//+++ Sygsky: rearm with random biggun
	if (d_enemy_side != "EAST") then
	{
		sleep 0.5;
		if ( _sm_vehicle call SYG_rearmHeavySniper) then
		{
            SM_HeavySniperCnt = 1;
            publicVariable "SM_HeavySniperCnt";
		};
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
};

if (true) exitWith {};