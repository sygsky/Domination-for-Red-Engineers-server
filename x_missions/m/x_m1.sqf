// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[17763.2,12139.8,0], [17717.1,12040.1,0]]; // Officer, Tres Valles, second array = position Shilka
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif
if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (X_Client) then {
	current_mission_text = localize "STR_SM_1"; //"Сегодня к развалинам церкви в долине 'Tres Valles' прибывает офицер, родственник бывшего президента. По слухам, он готовится провести там свои масонские ритуалы. К тому-же, он уже в ответе за множество смертей среди мирного населения. Ликвидируйте его!";
	current_mission_resolved_text = localize "STR_SM_01"; //"Задание выполнено! Родственник президента ликвидирован!";
};

if (isServer) then {
	_officer = (if (d_enemy_side == "EAST") then {"OfficerE"} else {"ACE_USMC8541A2"});
	__PossAndOther
	["shilka", 2, "", 0, "", 0, _pos_other,1,0,false] spawn XCreateArmor;
	sleep 2.123;
	_fortress = "Fortress2" createVehicle _poss;
	_fortress setDir -133.325;
	__AddToExtraVec(_fortress)
	sleep 2.123;
	__WaitForGroup
	__GetEGrp(_ogroup)
	_sm_vehicle = _ogroup createUnit [_officer, _poss, [], 0, "FORM"];
	[_sm_vehicle] join _ogroup;

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
	sleep 2.123;
	
//	["specops", 1, "basic", 1, _poss, 100,true] spawn XCreateInf;
	
	// as this group is near officer, rearm it with some special specops weapons
	["specops", 1, "basic", 1, _poss, 100,true]  spawn 
	{
		private ["_grps","_cnt"];
		_grps = _this call XCreateInf;
		_cnt = (_grps select 0) call SYG_rearmSpecopsGroup;
#ifdef __DEBUG__		
		hint localize format["%1 x_m1.sqf: %2 of %3 specops rearmed", call SYG_missionTimeInfoStr, _cnt, count units (_grps select 0)];
#endif
	};

	sleep 2.123;
	_leadero = leader _ogroup;
	_leadero setRank "COLONEL";
	_ogroup allowFleeing 0;
	_ogroup setbehaviour "AWARE";
};

if (true) exitWith {};