// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

#define ISLAS_SEPARATE_VERTICAL_LINE_X 4730

x_sm_pos = [
    // officer positions
    [4726.85,15689,0],[4385.75,15825.4,0],[4415.64,15790.9,0],[4375.74,15790.8,0],[4392.87,15521.3,0],[4532.88,15304.8,0],[4585.08,15287.2,0],[4978.4,15466.1,0],[4855.92,15535.1,0],[4930.69,15514.1,0],[4956.34,15760.8,0],[4949.85,15827.9,0],[4964.33,16067,0],[4987.25,15717.1,0],[4395.8,15350.6,0],
    // defence group positions (start at #16)
   [4574.74,15374.2,0],[4368.82,15737,0],[5044.83,15799.3,0],[4860.15,15679.2,0]]; // index: 25,   enemy officer on Isla del Vasal or Isla del Vida
x_sm_type = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

#define __SUPER_AA_DEFENSE__
#define __DEBUG__
#define DELAY_BEFORE_NEXT_CREATION 120


if (X_Client) then {
	current_mission_text = localize "STR_SYS_508"; //"Стало известно, что виновный в развязывании войны офицер, возглавивший агрессию на Сахрани, прячется на одном из этих островов Isla del Vasal или Isla del Vida. Ликвидируйте негодяя!";
	current_mission_resolved_text = localize "STR_SYS_509"; // "Задание выполнено! Офицер уничтожен.";
};

if (isServer) then {
#ifdef __ACE__
    _officer = (if (d_enemy_side == "EAST") then {"ACE_OfficerE"} else {"ACE_USMC8541A2"});
#else
    _officer = (if (d_enemy_side == "EAST") then {"OfficerE"} else {"OfficerW"});
#endif

	_ranside = floor random 15; // 0-14 - officer positions
	_poss = x_sm_pos select _ranside;
	//_fortress = "Fortress2" createVehicle _poss;
	//_fortress setDir 290.789;
	//extra_mission_vehicle_remover_array = extra_mission_vehicle_remover_array + [_fortress];
	//sleep 2.123;
	//__WaitForGroup
	//__GetEGrp(_newgroup)
	_newgroup = call SYG_createEnemyGroup;
	_sm_vehicle = _newgroup createUnit [_officer, _poss, [], 0, "FORM"];
	[_sm_vehicle] join _newgroup;
	
	//+++ Sygsky: rearm with M14. Original primary weapon for him was M16A4
	if (d_enemy_side == "WEST") then {
		sleep 0.5;
		[_sm_vehicle,1.0,SYG_M14_WPN_SET_STD_OPTICS] call SYG_rearmM14;
	};
	//--- Sygsky
	
	#ifndef __TT__
	_sm_vehicle addEventHandler ["killed", {_this call XKilledSMTargetNormal}];
	#endif
	#ifdef __TT__
	_sm_vehicle addEventHandler ["killed", {_this call XKilledSMTargetTT}];
	#endif
	sleep 2.123;
	//_bpos = _fortress buildingPos 1;
	//_sm_vehicle setPos _bpos;
	_leader = leader _newgroup;
	_leader setRank "COLONEL";
	_newgroup allowFleeing 0;
	_newgroup setBehaviour "AWARE";
	sleep 2.123;

	if (d_enemy_side == "WEST") then {
		// as this group is near officer, rearm it with some special specops weapons
		["specops", 1, "basic", 0, _poss, 80,true]  spawn 
		{
			private ["_grp_ret","_cnt"];
			_grp_ret = _this call XCreateInf;
			_cnt = (_grp_ret select 0) call SYG_rearmSpecopsGroup;
#ifdef __DEBUG__		
			hint localize format["+++ %1 x_m25.sqf: %2 of %3 specops rearmed", call SYG_missionTimeInfoStr, _cnt, count units (_grp_ret select 0)];
#endif
		};
	}
	else {
		["specops", 1, "basic", 0, _poss, 80,true] spawn XCreateInf;
	};
	
	
	sleep 2.111;
	_pos_other = x_sm_pos select 15;
	["shilka", 1, "bmp", 1, "tank", 0, _pos_other,1,130,true] spawn XCreateArmor;
	sleep 2.123;
	["specops", 0, "basic", 1, _pos_other,80,true] spawn XCreateInf;
	sleep 2.123;
	_pos_other = x_sm_pos select 16;
	["shilka", 1, "bmp", 1, "tank", 0, _pos_other,1,130,true] spawn XCreateArmor;
	sleep 2.123;
	["specops", 1, "basic", 0, _pos_other,0] spawn XCreateInf;
	sleep 2.123;
	_pos_other = x_sm_pos select 17;
	["shilka", 1, "bmp", 1, "tank", 0, _pos_other,1,130,true] spawn XCreateArmor;
	sleep 2.123;
	["specops", 0, "basic", 1, _pos_other,80,true] spawn XCreateInf;
	sleep 2.123;
	_pos_other = x_sm_pos select 18;
	["shilka", 1, "bmp", 1, "tank", 0, _pos_other,1,130,true] spawn XCreateArmor;
	sleep 2.123;
	["specops", 1, "basic", 0, _pos_other,80,true] spawn XCreateInf;
	// rearm specops that are near officer
	sleep 2.123;
	
#ifdef __SUPER_AA_DEFENSE__
	// Add super-defence for this Side Mission immediately
	// TODO: change this adding so that number of AA Pods (not MG) depends on players count 
	// up to the maximum limited count after some period

    //_Stinger_Pod_arr1 = [[4898.79,15460.7,6.87017],[5033.33,16123.4,0.0],[5155.62,15877.1,0.0]]; // Isla da Vida
    _Stinger_Pod_arr1 = [[4898.79,15460.7,6.9],[5033.33,16123.4,0.0],[5155.62,15877.1,0.0]]; // Isla da Vida

    //_Stinger_Pod_arr2 = [[4520.49,15279.3,5.84021],[4372.36,15264.6,0.0],[4348.18,15932.5,0.0]]; // Isla da Vassal
    _Stinger_Pod_arr2 = [[4520.49,15279.3,5.9],[4372.36,15264.6,0.0],[4348.18,15932.5,0.0]]; // Isla da Vassal

    _M2HD_mini_TriPod_arr = [[4359.98,15937,0.0],[4341.64,15541.9,0.0]]; // Isla da Vassal

	_utype = if (d_enemy_side == "EAST") then {d_crewman2_E} else {d_crewman2_W};
	_stingertype = ["ACE_ZU23M"] + [if (d_enemy_side == "EAST") then {"Stinger_Pod_East"} else {"Stinger_Pod"}];

	_mgtype = ["ACE_ZU23M"] + [if (d_enemy_side == "EAST") then {"DSHkM_Mini_TriPod"} else {"M2HD_mini_TriPod"}];   // Lucky player bonus :o)
	
	//__WaitForGroup
	//__GetEGrp(_grp)
	_grp = call SYG_createEnemyGroup;
	{ //  forEach weapon group
		{
			// call: [_grp, _wpntype, _unittype, _posarray, _delay] call _createStaticWeaponGroup;
			[_grp, _x select 0, _utype, _x select 1, DELAY_BEFORE_NEXT_CREATION] call SYG_createStaticWeaponGroup;
		} forEach _x;
		sleep 0.511;	
	} forEach	[
					[ [_stingertype,_Stinger_Pod_arr1] ], 
					[ [_stingertype,_Stinger_Pod_arr2],[_mgtype,_M2HD_mini_TriPod_arr] ] 
				];
	_grp allowFleeing 0;
	_grp setCombatMode "YELLOW";
	_grp setFormDir (floor random 360);
	_grp setSpeedMode "NORMAL";
	_grp_array = [_grp, _pos, 0, [], [], -1, 0, [], 100, -1];
	_grp_array execVM "x_scripts\x_groupsm.sqf";
				
#endif	
	
};

if (true) exitWith {};